import 'dart:convert';

import 'package:uni_chat/api_configs/api_service.dart';

import 'api_database.dart';
import 'api_models.dart';

/// API Key resolver
/// # TL；DR：
/// After debugging with the google apis I realized that some providers such as google will return a detailed quota report when 429.
///
/// Apparently,the apikey select strategy will be smarter with these quota infos.
/// So we should apply a **tailored** strategy based on the provider type.
/// # HOWTO:
/// Its easy to implement a tailored strategy.
/// Unichat stores the invoke data in string (json) formats , so the type of data you store can be highly customized.
/// 1. Create a data class that can store the invoke data with to and from json methods.
/// 2. Implement the base resolver class and provide the resolve methods.
/// (See the General edition for reference)
/// 3. Modify the @getInstance method to return the tailored resolver when need based on the provider data given.
/// A common way is to decide which resolver based on the "preset" column of the api_provider class. Which indicates which kind of provider this is created from.
/// 4. You're all done!
/// >[!warning] The resolver instance will be create on ever invokes. If this time's returns a 429, then this process will be done again unitil 200 is received or an "No api keys available error is thrown"
/// > see the [ApiClient] and [ApiClient.getStreamingResponse] for more details.
abstract class BaseApiKeyResolver {
  /// This method will be called to select the most suitable key for the provider.
  /// You can implement any strategy you want.
  /// A "No available key" will be thrown if no key is available.
  Future<ApiKey> resolveKey(Model model);

  /// This method will be called when an invoke is finished.Which should then write the invoke data to db.Such as 429s or 200s.
  Future<void> updateData(InvokeResult invokeResult);

  /// On invoke a new call , this method will be called to select the most suitable resolver for the provider.
  /// Note that a db future containing  the keys and their invoke data (in json strings) are provided , which you can use in constructors.
  /// >[!note] The database return the api keys in random orders (in sql feature) so you don't have to do it yourself.
  static Future<BaseApiKeyResolver> getInstance(
    Future<List<({ApiKey key, String? invokeDataJson})>> dbFuture, {
    ApiProvider? apiProvider,
  }) {
    return GeneralApiKeyResolver.getInstance(dbFuture);
  }
}

class GeneralApiKeyInvokeData {
  int retryCount;
  DateTime? nextAvailableTime;
  int? lastStatusCode;

  int todayUsedTokens;
  int requestToday;
  DateTime? resetTime;
  GeneralApiKeyInvokeData({
    required this.retryCount,
    this.nextAvailableTime,
    this.lastStatusCode,
    required this.todayUsedTokens,
    required this.requestToday,
    this.resetTime,
  });

  factory GeneralApiKeyInvokeData.fromMap(Map<String, dynamic> map) {
    return GeneralApiKeyInvokeData(
      retryCount: map['retryCount'],
      nextAvailableTime: map['nextAvailableTime'],
      lastStatusCode: map['lastStatusCode'],
      todayUsedTokens: map['todayUsedTokens'],
      requestToday: map['requestToday'],
      resetTime: map['resetTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'retryCount': retryCount,
      'nextAvailableTime': nextAvailableTime,
      'lastStatusCode': lastStatusCode,
      'todayUsedTokens': todayUsedTokens,
      'requestToday': requestToday,
      'resetTime': resetTime,
    };
  }

  GeneralApiKeyInvokeData copyWith({
    int? retryCount,
    DateTime? nextAvailableTime,
    int? lastStatusCode,
    int? todayUsedTokens,
    int? requestToday,
    DateTime? resetTime,
  }) {
    return GeneralApiKeyInvokeData(
      retryCount: retryCount ?? this.retryCount,
      nextAvailableTime: nextAvailableTime ?? this.nextAvailableTime,
      lastStatusCode: lastStatusCode ?? this.lastStatusCode,
      todayUsedTokens: todayUsedTokens ?? this.todayUsedTokens,
      requestToday: requestToday ?? this.requestToday,
      resetTime: resetTime ?? this.resetTime,
    );
  }
}

class GeneralApiKeyResolver implements BaseApiKeyResolver {
  final List<({ApiKey key, GeneralApiKeyInvokeData invokeData})> keys;
  final List<ApiKey>? newKeys;
  GeneralApiKeyResolver._private(this.keys, this.newKeys);

  KeyInfo? selectedKey;
  @override
  Future<ApiKey> resolveKey(Model model) async {
    if (newKeys != null) {
      return newKeys!.first;
    }
    final now = DateTime.timestamp();

    // 1. 定义筛选档位 (Tiering)
    // 档位从高到低：200/新Key > 429待命 > 其他错误待命
    final List<bool Function(KeyInfo)> tiers = [
      (k) =>
          (k.invokeData.lastStatusCode == null ||
          k.invokeData.lastStatusCode == 200),
      (k) =>
          k.invokeData.lastStatusCode == 429 &&
          (k.invokeData.nextAvailableTime == null ||
              k.invokeData.nextAvailableTime!.isBefore(now)),
      (k) =>
          ![200, 429, 401, 400].contains(k.invokeData.lastStatusCode) &&
          (k.invokeData.nextAvailableTime == null ||
              k.invokeData.nextAvailableTime!.isBefore(now)),
    ];

    // 2. 按档位依次尝试
    for (var isMatchTier in tiers) {
      final candidates = keys
          .where((k) => _isNotExceeded(k, now) && isMatchTier(k))
          .toList();

      for (var k in candidates) {
        if (await _checkRpm(k)) return k.key; // 检查通过则返回
      }
    }

    // 3. 最后保底：如果全都在冷却，选一个最快能用的
    keys.sort(
      (a, b) => a.invokeData.nextAvailableTime!.compareTo(
        b.invokeData.nextAvailableTime!,
      ),
    );
    return keys
        .firstWhere(
          (k) =>
              ![401, 403].contains(k.invokeData.lastStatusCode) &&
              k.invokeData.retryCount <= overLimitRetryCountsMinutes.length,
          orElse: () => throw "No available key",
        )
        .key;
  }

  // 基础限额判定
  bool _isNotExceeded(KeyInfo k, DateTime now) {
    final d = k.invokeData;
    if (d.resetTime != null && d.resetTime!.isAfter(now)) {
      if (k.key.tokenLimit != null && d.todayUsedTokens >= k.key.tokenLimit!) {
        return false;
      }
      if (k.key.rpd != null && d.requestToday >= k.key.rpd!) return false;
    }
    return true;
  }

  // RPM 判定
  Future<bool> _checkRpm(KeyInfo k) async {
    if (k.key.rpd == null) return true; // 未设置RPM则不限
    final history = await ApiDatabase.instance.getHistory(k.key);
    final minuteAgo = DateTime.timestamp().subtract(Duration(minutes: 1));
    // 检查最近一分钟的调用次数是否超过限制
    return history.where((h) => h.time.isAfter(minuteAgo)).length < k.key.rpd!;
  }

  static Future<GeneralApiKeyResolver> getInstance(
    Future<List<({ApiKey key, String? invokeDataJson})>> dbFuture,
  ) async {
    var dbf = await dbFuture;
    var ks = <({ApiKey key, GeneralApiKeyInvokeData invokeData})>[];
    var newKeys = <ApiKey>[];
    for (var k in dbf) {
      GeneralApiKeyInvokeData? data;
      if (k.invokeDataJson == null) {
        newKeys.add(k.key);
        continue;
      }
      try {
        data = GeneralApiKeyInvokeData.fromMap(jsonDecode(k.invokeDataJson!));
      } catch (e) {
        // if the invoke data is not valid , treat it as a new key
        print(e);
        newKeys.add(k.key);
        continue;
      }
      ks.add((key: k.key, invokeData: data));
    }
    return GeneralApiKeyResolver._private(
      ks,
      (newKeys.isEmpty) ? null : newKeys,
    );
  }

  @override
  Future<void> updateData(InvokeResult invokeResult) async {
    if (selectedKey == null) return;
    if (invokeResult.statusCode == 200) {
      await ApiDatabase.instance.updateApiKeyInvokeData(
        selectedKey!.key,
        jsonEncode(handleOk(invokeResult).toMap()),
      );
    } else if (invokeResult.statusCode == 429) {
      await ApiDatabase.instance.updateApiKeyInvokeData(
        selectedKey!.key,
        jsonEncode(handleOverLimit(invokeResult).toMap()),
      );
    } else {
      //401 402 403 are also processed here but will not be used again
      await ApiDatabase.instance.updateApiKeyInvokeData(
        selectedKey!.key,
        jsonEncode(handleError(invokeResult).toMap()),
      );
    }
  }

  static List<int> overLimitRetryCountsMinutes = [1, 1, 5, 60];
  static List<int> errorRetryCountsMinutes = [1, 5, 10, 60, 120, 180];

  GeneralApiKeyInvokeData handleError(InvokeResult invokeData) {
    var keyI = selectedKey!.invokeData;
    late DateTime nextAvailableTime;
    var dt = DateTime.timestamp();
    if (keyI.retryCount > errorRetryCountsMinutes.length - 1) {
      nextAvailableTime = DateTime.utc(dt.year, dt.month, dt.day + 1);
    } else {
      nextAvailableTime = dt.add(
        Duration(minutes: errorRetryCountsMinutes[keyI.retryCount]),
      );
    }
    var id = keyI.copyWith(
      lastStatusCode: invokeData.statusCode,
      retryCount: keyI.retryCount + 1,
      nextAvailableTime: nextAvailableTime,
      requestToday: keyI.requestToday++,
    );
    return id;
  }

  GeneralApiKeyInvokeData handleOverLimit(InvokeResult invokeData) {
    var keyI = selectedKey!.invokeData;
    late DateTime nextAvailableTime;
    var dt = DateTime.timestamp();
    if (keyI.retryCount > overLimitRetryCountsMinutes.length - 1) {
      nextAvailableTime = DateTime.utc(dt.year, dt.month, dt.day + 1);
    } else {
      nextAvailableTime = dt.add(
        Duration(minutes: overLimitRetryCountsMinutes[keyI.retryCount]),
      );
    }
    var id = keyI.copyWith(
      lastStatusCode: invokeData.statusCode,
      retryCount: keyI.retryCount + 1,
      nextAvailableTime: nextAvailableTime,
      requestToday: keyI.requestToday++,
    );
    return id;
  }

  GeneralApiKeyInvokeData handleOk(InvokeResult invokeData) {
    var keyI = selectedKey!.invokeData;
    var dt = DateTime.timestamp();
    DateTime? rt;
    late int tut;
    late int rtd;
    if (keyI.resetTime == null || keyI.resetTime!.isBefore(dt)) {
      rt = DateTime.utc(dt.year, dt.month, dt.day + 1);
      tut = 0;
      rtd = 1;
    } else {
      tut =
          keyI.todayUsedTokens +
          ((invokeData.usage != null) ? invokeData.usage!.total : 0);
      rtd = keyI.requestToday++;
    }
    var id = GeneralApiKeyInvokeData(
      retryCount: 0,
      lastStatusCode: invokeData.statusCode,
      todayUsedTokens: tut,
      requestToday: rtd,
      resetTime: rt ?? keyI.resetTime,
      //TODO: auto set reset time according to the api timezone
    );
    return id;
  }
}
