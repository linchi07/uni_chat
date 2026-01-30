import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/api_configs/database_models.dart';
import 'package:uni_chat/utils/file_utils.dart';

import '../settings_page/api_configure.dart' show ApiConfigure;
import 'database_converters.dart';

part 'api_database.g.dart';

@DriftDatabase(
  tables: [
    Models,
    ProviderModelConfigs,
    ProviderPresetsTable,
    ApiProviders,
    ApiKeysTable,
    ApiKeyUsages,
  ],
)
class _ApiDb extends _$_ApiDb {
  _ApiDb() : super(_onOpen());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _onOpen() {
    return driftDatabase(
      name: 'api_configs',
      native: DriftNativeOptions(
        databasePath: () async {
          return await PathProvider.getPath("api_config.db");
        },
      ),
    );
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (mig) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onCreate: (mig) async {
        await mig.createAll();
        await loadDefaultData();
      },
    );
  }

  Future<void> insertModel(Model model) {
    return into(models).insert(model);
  }

  Future<List<Model>> getAllModels() => select(models).get();

  Future<Model?> getModelById(String id) =>
      (select(models)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<bool> updateModel(Model model) {
    return update(models).replace(model);
  }

  Future<List<ApiProvider>> getAllApiProviders() => select(apiProviders).get();

  Future<ApiProvider?> getApiProviderById(String id) =>
      (select(apiProviders)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> deleteApiProvider(String id) {
    return transaction(() async {
      var p = await (select(
        apiProviders,
      )..where((e) => e.id.equals(id))).getSingleOrNull();
      if (p != null && p.preset != null) {
        await (update(providerPresetsTable)
              ..where((e) => e.id.equals(p.preset!)))
            .write(ProviderPresetsTableCompanion(available: Value(true)));
      }
      await (delete(apiProviders)..where((e) => e.id.equals(id))).go();
    });
  }

  Future<void> saveApiConfigure(ApiConfigure configure) {
    var pv = configure.toProvider();
    return transaction(() async {
      var old = await (select(
        apiProviders,
      )..where((e) => e.id.equals(pv.id))).getSingleOrNull();
      if (old != null) {
        await (update(
          apiProviders,
        )..where((e) => e.id.equals(pv.id))).write(pv);

        var oldKeys = await (select(
          apiKeysTable,
        )..where((e) => e.providerId.equals(pv.id))).get();
        var os = {for (var e in oldKeys) e.id: false};
        for (var k in configure.keys) {
          var old = os[k.id];
          if (old != null) {
            await (update(
              apiKeysTable,
            )..where((e) => e.id.equals(k.id))).write(k);
            os[k.id] = true;
          } else {
            await into(apiKeysTable).insert(k);
          }
        }
        for (var k in os.entries) {
          if (!k.value) {
            await (delete(apiKeysTable)..where((e) => e.id.equals(k.key))).go();
          }
        }

        await (delete(
          providerModelConfigs,
        )..where((e) => e.providerId.equals(pv.id))).go();
        for (var m in configure.models) {
          await into(providerModelConfigs).insert(m.config);
        }

        if (configure.providerPreset != null &&
            configure.type == ProviderPresetType.singleInstance) {
          await (update(providerPresetsTable)
                ..where((e) => e.id.equals(configure.providerPreset!.id)))
              .write(ProviderPresetsTableCompanion(available: Value(false)));
        }
      } else {
        await into(apiProviders).insert(pv);
        for (var k in configure.keys) {
          await into(apiKeysTable).insert(k);
        }
        for (var m in configure.models) {
          await into(providerModelConfigs).insert(m.config);
        }
        if (configure.providerPreset != null &&
            configure.type == ProviderPresetType.singleInstance) {
          await (update(providerPresetsTable)
                ..where((e) => e.id.equals(configure.providerPreset!.id)))
              .write(ProviderPresetsTableCompanion(available: Value(false)));
        }
      }
    });
  }

  Future<List<ApiKey>> getApiKeys(String providerId) async {
    var r = await (select(
      apiKeysTable,
    )..where((e) => e.providerId.equals(providerId))).get();
    return r
        .map(
          (e) => ApiKey(
            e.providerId,
            e.id,
            e.key,
            remark: e.remark,
            enabled: e.enabled,
            rpm: e.rpm,
            rpd: e.rpd,
            tokenLimit: e.tokenLimit,
          ),
        )
        .toList();
  }

  Future<void> insertApikeyUsage(ApiKeyUsage usage) =>
      into(apiKeyUsages).insert(usage);

  Future<List<({ApiKey key,String? invokeDataJson})>> getAvailableApiKeys(
    String providerId,
  ) async {
    var r =
        await (select(apiKeysTable)
              ..where((e) {
                return e.enabled.equals(true) & e.providerId.equals(providerId);
              })
              ..orderBy([(e) => OrderingTerm.random()]))
            .get();

    var result = <({ApiKey key,String? invokeDataJson})>[];
    for (var k in r) {
      var key = ApiKey(
        k.providerId,
        k.id,
        k.key,
        rpm: k.rpm,
        rpd: k.rpd,
        tokenLimit: k.tokenLimit,
      );
      result.add((key: key, invokeDataJson: k.invokeData));
    }
    return result;
  }

  Future<List<ApiKeyUsage>> getHistory(ApiKey key) {
    return (select(apiKeyUsages)
          ..orderBy([(e) => OrderingTerm.desc(e.time)])
          ..where((e) => e.apiKeyId.equals(key.id))
          ..limit((key.rpm ?? 5)))
        .get();
  }

  Future<void> updateApiKeyInvokeData(ApiKey key,String dataJson) {
    return (update(apiKeysTable)..where((e) => e.id.equals(key.id))).write(
      ApiKeysTableCompanion(
        invokeData: Value(dataJson),
      ),
    );
  }

  Future<int> insertProviderModelConfig(ProviderModelConfig config) =>
      into(providerModelConfigs).insert(config);

  Future<List<ProviderModelConfig>> getProviderModelConfigsByModelId(
    String modelId,
  ) => (select(
    providerModelConfigs,
  )..where((e) => e.modelId.equals(modelId))).get();

  Future<List<ApiProvider>> getApiProviderByModelId(String modelId) =>
      (select(providerModelConfigs).join([
            innerJoin(
              apiProviders,
              providerModelConfigs.providerId.equalsExp(apiProviders.id),
            ),
          ])..where(providerModelConfigs.modelId.equals(modelId)))
          .map((e) => e.readTable(apiProviders))
          .get();

  Future<List<ProviderModelConfig>> getProviderModelConfigsByProviderId(
    String providerId,
  ) => (select(
    providerModelConfigs,
  )..where((e) => e.providerId.equals(providerId))).get();

  Future<int> insertProviderPreset(ProviderPreset preset) =>
      into(providerPresetsTable).insert(preset.companion);

  Future<List<ProviderPreset>> getAllProviderPresets({
    bool onlyAvailable = false,
  }) async {
    if (onlyAvailable) {
      var data = await (select(
        providerPresetsTable,
      )..where((e) => e.available.equals(true))).get();
      return data
          .map(
            (e) => ProviderPreset(
              id: e.id,
              i18nName: e.i18nName,
              type: e.type,
              apiType: e.apiType,
              endpoint: e.endpoint,
              models: e.models,
            ),
          )
          .toList();
    } else {
      return (select(providerPresetsTable)
          .map(
            (e) => ProviderPreset(
              id: e.id,
              i18nName: e.i18nName,
              type: e.type,
              apiType: e.apiType,
              endpoint: e.endpoint,
              models: e.models,
            ),
          )
          .get());
    }
  }

  Future<ProviderModelConfig?> getProviderModelConfig(
    String providerId,
    String modelId,
  ) {
    return (select(providerModelConfigs)..where(
          (e) => e.providerId.equals(providerId) & e.modelId.equals(modelId),
        ))
        .getSingleOrNull();
  }

  Future<ProviderPreset?> getProviderPresetById(String id) =>
      (select(providerPresetsTable)..where((e) => e.id.equals(id)))
          .map(
            (e) => ProviderPreset(
              id: e.id,
              i18nName: e.i18nName,
              type: e.type,
              apiType: e.apiType,
              endpoint: e.endpoint,
              models: e.models,
            ),
          )
          .getSingleOrNull();

  Future<List<Model>> getAvailableModels() {
    return (select(providerModelConfigs).join([
      innerJoin(models, providerModelConfigs.modelId.equalsExp(models.id)),
    ])).map((t) => t.readTable(models)).get();
  }

  Future<void> loadDefaultData() async {
    final String response = await rootBundle.loadString(
      'resources/data/model.json',
    );
    try {
      // 2. 解析为 JSON 对象
      final data = jsonDecode(response) as List<dynamic>;
      for (var map in data) {
        List<ModelParameters>? parameters;
        var pr = map['parameters'];
        if (pr != null) {
          parameters = [];
          for (var i in (pr as List)) {
            var obj = ModelParameters.fromMap(i);
            if (obj != null) {
              parameters.add(obj);
            }
          }
          if (parameters.isEmpty) {
            parameters = null;
          }
        }

        var m = Model(
          id: map['id'],
          family: map['family'],
          friendlyName: map['friendly_name'],
          // abilities: XModelAlibity.fromList((jsonDecode(map['abilities']) as List)),
          // dart的json decode简直就是傻逼中的傻逼
          // 这里前面已经decode一次之后，他就变成list dynamic了，然后如果用处理数据库的那一套逻辑，再decode一遍（因为数据库出来就是map,不会有第一次的decode）
          // 就会报错。所以说必须为数据库和json维护两套逻辑 真tm醉了 你已经是list dynamic了再decode直接返回不好了吗 😅
          abilities: XModelAlibity.fromList((map['abilities'] as List)),
          contextLength: map['context_length'],
          maxCompletionTokens: map['max_completion_tokens'],
          pricing: map['pricing'] != null
              ? ModelPricing.fromMap(map['pricing'])
              : null,
          parameters: parameters,
        );
        await into(models).insert(m);
      }
      for (var p in ProviderPreset.presets) {
        await into(providerPresetsTable).insert(p);
      }
    } catch (e) {
      print(e);
    }
  }
}

class ApiDatabase {
  // 私有的静态实例
  static ApiDatabase? _instance;

  late _ApiDb _adb;
  //this is not android debug bridge
  // 工厂构造函数，确保只有一个实例
  factory ApiDatabase() {
    _instance ??= ApiDatabase._internal();
    return _instance!;
  }

  // 提供外部访问的实例属性
  static ApiDatabase get instance {
    _instance ??= ApiDatabase();
    return _instance!;
  }

  // 私有构造函数
  ApiDatabase._internal() {
    _adb = _ApiDb();
  }

  // 在 ApiDatabase 类中添加以下方法

  // Model 表操作
  Future<void> insertModel(Model model) => _adb.insertModel(model);

  Future<List<Model>> getAllModels() => _adb.getAllModels();

  Future<Model?> getModelById(String id) => _adb.getModelById(id);

  Future<List<ApiProvider>> getAllProviders() => _adb.getAllApiProviders();

  Future<ApiProvider?> getProviderById(String id) =>
      _adb.getApiProviderById(id);

  Future<List<ApiKey>> getApiKeys(String providerId) =>
      _adb.getApiKeys(providerId);

  Future<List<ProviderModelConfig>> getProviderModelConfigsByModelId(
    String modelId,
  ) => _adb.getProviderModelConfigsByModelId(modelId);

  Future<List<ProviderPreset>> getAllProviderPresets({
    bool onlyAvailable = false,
  }) => _adb.getAllProviderPresets(onlyAvailable: onlyAvailable);

  Future<ProviderPreset?> getProviderPresetById(String id) =>
      _adb.getProviderPresetById(id);

  Future<void> saveApiConfigure(ApiConfigure configure) =>
      _adb.saveApiConfigure(configure);

  Future<void> deleteApiProvider(String id) => _adb.deleteApiProvider(id);

  Future<List<ProviderModelConfig>> getProviderModelConfigs(
    String providerID,
  ) => _adb.getProviderModelConfigsByProviderId(providerID);
  Future<void> insertApikeyUsage(ApiKeyUsage usage) =>
      _adb.insertApikeyUsage(usage);

  Future<List<({ApiKey key,String? invokeDataJson})>> getAvailableApiKeys(
    String providerId,
  ) => _adb.getAvailableApiKeys(providerId);

  Future<ProviderModelConfig?> getProviderModelConfig(
    String providerId,
    String modelId,
  ) => _adb.getProviderModelConfig(providerId, modelId);

  Future<List<ApiKeyUsage>> getHistory(ApiKey key) => _adb.getHistory(key);
  Future<List<Model>> getAvailableModels() => _adb.getAvailableModels();
  Future<List<ApiProvider>> getApiProviderByModelId(String modelId) =>
      _adb.getApiProviderByModelId(modelId);
  Future<void> updateApiKeyInvokeData(ApiKey key,String dataJson) =>
      _adb.updateApiKeyInvokeData(key, dataJson);
}
