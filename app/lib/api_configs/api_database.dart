import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/api_configs/database_models.dart';
import 'package:uni_chat/utils/file_utils.dart';

import '../settings_page/api_configure.dart' show ApiConfigure;
import '../utils/llm_icons.dart';
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
  _ApiDb.connect(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 3;

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
      onUpgrade: (mig, from, to) async {
        if (from < 2) {
          // Add new columns to ApiKeyUsages
          await customStatement(
            'ALTER TABLE api_key_usages ADD COLUMN prompt_tokens INTEGER NOT NULL DEFAULT 0',
          );
          await customStatement(
            'ALTER TABLE api_key_usages ADD COLUMN completion_tokens INTEGER NOT NULL DEFAULT 0',
          );
          await customStatement(
            'ALTER TABLE api_key_usages ADD COLUMN total_tokens INTEGER NOT NULL DEFAULT 0',
          );
          await customStatement(
            'ALTER TABLE api_key_usages ADD COLUMN cached_tokens INTEGER NOT NULL DEFAULT 0',
          );
        }
        if (from < 3) {
          // api_key_usages: add cost and currency
          await customStatement(
            'ALTER TABLE api_key_usages ADD COLUMN cost REAL',
          );
          await customStatement(
            'ALTER TABLE api_key_usages ADD COLUMN currency TEXT',
          );

          // provider_model_configs: rename pricing_override to pricing
          // Since drift doesn't have a direct renameColumn helper for custom migration blocks easily without issues,
          // we use customStatement if possible, or use mig.renameColumn if using drift's new migration steps.
          // For simplicity and safety in SQLite:
          await customStatement(
            'ALTER TABLE provider_model_configs RENAME COLUMN pricing_override TO pricing',
          );
        }
      },
    );
  }

  // Token Stats Queries
  Future<List<({DateTime time, int total, double? cost, String? currency})>>
  getUsageStats(
    String providerId, {
    required DateTime start,
    required DateTime end,
  }) async {
    var query = select(apiKeyUsages).join([
      innerJoin(apiKeysTable, apiKeysTable.id.equalsExp(apiKeyUsages.apiKeyId)),
    ]);

    query.where(
      apiKeysTable.providerId.equals(providerId) &
          apiKeyUsages.time.isBetweenValues(start, end),
    );

    query.orderBy([OrderingTerm.desc(apiKeyUsages.time)]);

    final results = await query.get();
    return results.map((row) {
      final usage = row.readTable(apiKeyUsages);
      return (
        time: usage.time,
        total: usage.totalTokens ?? 0,
        cost: usage.cost,
        currency: usage.currency,
      );
    }).toList();
  }

  Future<List<({Model? model, String modelId, int total, double cost})>>
  getModelUsageBuckets(
    String providerId, {
    required DateTime start,
    required DateTime end,
  }) async {
    final totalSum = apiKeyUsages.totalTokens.sum();
    final costSum = apiKeyUsages.cost.sum();

    var query = select(apiKeyUsages).join([
      innerJoin(apiKeysTable, apiKeysTable.id.equalsExp(apiKeyUsages.apiKeyId)),
      leftOuterJoin(models, models.id.equalsExp(apiKeyUsages.modelId)),
    ]);

    query.where(
      apiKeysTable.providerId.equals(providerId) &
          apiKeyUsages.time.isBetweenValues(start, end),
    );

    query.groupBy([apiKeyUsages.modelId]);
    query.orderBy([OrderingTerm.desc(totalSum)]);

    query.addColumns([totalSum, costSum]);
    final results = await query.get();
    return results.map((row) {
      return (
        model: row.readTableOrNull(models),
        modelId: row.read<String>(apiKeyUsages.modelId)!,
        total: row.read<int>(totalSum) ?? 0,
        cost: row.read<double>(costSum) ?? 0.0,
      );
    }).toList();
  }

  Future<List<({ApiKey key, int total, double cost})>> getKeyUsageBuckets(
    String providerId, {
    required DateTime start,
    required DateTime end,
  }) async {
    final totalSum = apiKeyUsages.totalTokens.sum();
    final costSum = apiKeyUsages.cost.sum();

    var query = select(apiKeyUsages).join([
      innerJoin(apiKeysTable, apiKeysTable.id.equalsExp(apiKeyUsages.apiKeyId)),
    ]);

    query.where(
      apiKeysTable.providerId.equals(providerId) &
          apiKeyUsages.time.isBetweenValues(start, end),
    );

    query.groupBy([apiKeyUsages.apiKeyId]);
    query.orderBy([OrderingTerm.desc(totalSum)]);

    query.addColumns([totalSum, costSum]);
    final results = await query.get();
    return results.map((row) {
      final keyData = row.readTable(apiKeysTable);
      return (
        key: ApiKey(
          keyData.providerId,
          keyData.id,
          keyData.key,
          remark: keyData.remark,
          enabled: keyData.enabled,
          rpm: keyData.rpm,
          rpd: keyData.rpd,
          tokenLimit: keyData.tokenLimit,
        ),
        total: row.read<int>(totalSum) ?? 0,
        cost: row.read<double>(costSum) ?? 0.0,
      );
    }).toList();
  }

  Future<({int prompt, int completion, int cached, Map<String, double> costs})>
  getUsageSummary(
    String providerId, {
    required DateTime start,
    required DateTime end,
  }) async {
    final promptSum = apiKeyUsages.promptTokens.sum();
    final completionSum = apiKeyUsages.completionTokens.sum();
    final cachedSum = apiKeyUsages.cachedTokens.sum();
    final costSum = apiKeyUsages.cost.sum();

    final query = selectOnly(apiKeyUsages).join([
      innerJoin(apiKeysTable, apiKeysTable.id.equalsExp(apiKeyUsages.apiKeyId)),
    ]);

    query.addColumns([
      promptSum,
      completionSum,
      cachedSum,
      costSum,
      apiKeyUsages.currency,
    ]);
    query.where(
      apiKeysTable.providerId.equals(providerId) &
          apiKeyUsages.time.isBetweenValues(start, end),
    );
    query.groupBy([apiKeyUsages.currency]);

    final results = await query.get();
    int totalPrompt = 0;
    int totalCompletion = 0;
    int totalCached = 0;
    final Map<String, double> costs = {};

    for (var row in results) {
      totalPrompt += row.read(promptSum) ?? 0;
      totalCompletion += row.read(completionSum) ?? 0;
      totalCached += row.read(cachedSum) ?? 0;

      final currency = row.read(apiKeyUsages.currency);
      final totalCost = row.read<double>(costSum);
      if (currency != null && totalCost != null) {
        costs[currency] = totalCost;
      }
    }

    return (
      prompt: totalPrompt,
      completion: totalCompletion,
      cached: totalCached,
      costs: costs,
    );
  }

  Future<List<({ApiKeyUsage usage, Model? model})>> getDetailedUsageLogs(
    String providerId, {
    DateTime? start,
    DateTime? end,
  }) async {
    var query = select(apiKeyUsages).join([
      innerJoin(apiKeysTable, apiKeysTable.id.equalsExp(apiKeyUsages.apiKeyId)),
      leftOuterJoin(models, models.id.equalsExp(apiKeyUsages.modelId)),
    ]);

    query.where(apiKeysTable.providerId.equals(providerId));
    if (start != null) {
      query.where(apiKeyUsages.time.isBiggerOrEqualValue(start));
    }
    if (end != null) {
      query.where(apiKeyUsages.time.isSmallerOrEqualValue(end));
    }

    query.orderBy([OrderingTerm.desc(apiKeyUsages.time)]);

    final results = await query.get();
    return results.map((row) {
      return (
        usage: row.readTable(apiKeyUsages),
        model: row.readTableOrNull(models),
      );
    }).toList();
  }

  Future<
    Map<String, ({int totalTokens, int callCount, Map<String, double> costs})>
  >
  getAllProvidersUsageSummaries(DateTime start) async {
    final totalSum = apiKeyUsages.totalTokens.sum();
    final callCountCol = apiKeyUsages.apiKeyId.count();
    final costSum = apiKeyUsages.cost.sum();

    final query = selectOnly(apiKeyUsages).join([
      innerJoin(apiKeysTable, apiKeysTable.id.equalsExp(apiKeyUsages.apiKeyId)),
    ]);

    query.addColumns([
      totalSum,
      callCountCol,
      apiKeysTable.providerId,
      apiKeyUsages.currency,
      costSum,
    ]);
    query.where(apiKeyUsages.time.isBiggerOrEqualValue(start));
    query.groupBy([apiKeysTable.providerId, apiKeyUsages.currency]);

    final results = await query.get();

    final Map<
      String,
      ({int totalTokens, int callCount, Map<String, double> costs})
    >
    map = {};
    for (final row in results) {
      final pid = row.read(apiKeysTable.providerId);
      if (pid == null) continue;

      final existing =
          map[pid] ?? (totalTokens: 0, callCount: 0, costs: <String, double>{});

      final cur = row.read(apiKeyUsages.currency);
      final val = row.read<double>(costSum);

      final newCosts = Map<String, double>.from(existing.costs);
      if (cur != null && val != null) {
        newCosts[cur] = (newCosts[cur] ?? 0) + val;
      }

      map[pid] = (
        totalTokens: existing.totalTokens + (row.read(totalSum) ?? 0),
        callCount: existing.callCount + (row.read(callCountCol) ?? 0),
        costs: newCosts,
      );
    }
    return map;
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

  Future<void> upsertModel(Model model) {
    return into(models).insert(
      model,
      onConflict: DoUpdate(
        (old) => ModelsCompanion(
          friendlyName: Value(model.friendlyName),
          family: Value(model.family),
          abilities: Value(model.abilities),
          contextLength: Value(model.contextLength),
          maxCompletionTokens: Value(model.maxCompletionTokens),
          parameters: Value(model.parameters),
        ),
      ),
    );
  }

  Future<void> upsertProviderPreset(ProviderPreset preset) {
    return into(
      providerPresetsTable,
    ).insert(preset.companion, onConflict: DoUpdate((old) => preset.companion));
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
        // 1. Update Provider
        await (update(
          apiProviders,
        )..where((e) => e.id.equals(pv.id))).write(pv);

        // 2. Diff Api Keys
        var oldKeys = await (select(
          apiKeysTable,
        )..where((e) => e.providerId.equals(pv.id))).get();
        var osKeys = {for (var e in oldKeys) e.id: false};
        for (var k in configure.keys) {
          if (osKeys.containsKey(k.id)) {
            await (update(
              apiKeysTable,
            )..where((e) => e.id.equals(k.id))).write(k);
            osKeys[k.id] = true;
          } else {
            await into(apiKeysTable).insert(k);
          }
        }
        for (var k in osKeys.entries) {
          if (!k.value) {
            await (delete(apiKeysTable)..where((e) => e.id.equals(k.key))).go();
          }
        }

        // 3. Diff Model Configs
        var oldConfigs = await (select(
          providerModelConfigs,
        )..where((e) => e.providerId.equals(pv.id))).get();
        var osConfigs = {for (var e in oldConfigs) e.modelId: false};

        for (var m in configure.models) {
          if (osConfigs.containsKey(m.config.modelId)) {
            await (update(providerModelConfigs)..where(
                  (e) =>
                      e.providerId.equals(pv.id) &
                      e.modelId.equals(m.config.modelId),
                ))
                .write(m.config);
            osConfigs[m.config.modelId] = true;
          } else {
            await into(providerModelConfigs).insert(m.config);
          }
        }
        for (var entry in osConfigs.entries) {
          if (!entry.value) {
            await (delete(providerModelConfigs)..where(
                  (e) =>
                      e.providerId.equals(pv.id) & e.modelId.equals(entry.key),
                ))
                .go();
          }
        }

        // 4. Update Preset status
        if (configure.providerPreset != null &&
            configure.type == ProviderPresetType.singleInstance) {
          await (update(providerPresetsTable)
                ..where((e) => e.id.equals(configure.providerPreset!.id)))
              .write(ProviderPresetsTableCompanion(available: Value(false)));
        }
      } else {
        // Initial insert
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
            invokeData: e.invokeData,
          ),
        )
        .toList();
  }

  Future<void> insertApikeyUsage(ApiKeyUsage usage) =>
      into(apiKeyUsages).insert(usage);

  Future<List<({ApiKey key, String? invokeDataJson})>> getAvailableApiKeys(
    String providerId,
  ) async {
    var r =
        await (select(apiKeysTable)
              ..where((e) {
                return e.enabled.equals(true) & e.providerId.equals(providerId);
              })
              ..orderBy([(e) => OrderingTerm.random()]))
            .get();

    var result = <({ApiKey key, String? invokeDataJson})>[];
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

  Future<void> updateApiKeyInvokeData(ApiKey key, String dataJson) {
    return (update(apiKeysTable)..where((e) => e.id.equals(key.id))).write(
      ApiKeysTableCompanion(invokeData: Value(dataJson)),
    );
  }

  // Token Usage Statistics
  Future<List<TypedResult>> getProviderUsage(
    String providerId, {
    DateTime? start,
    DateTime? end,
  }) {
    var query = select(apiKeyUsages).join([
      innerJoin(apiKeysTable, apiKeysTable.id.equalsExp(apiKeyUsages.apiKeyId)),
      leftOuterJoin(models, models.id.equalsExp(apiKeyUsages.modelId)),
    ]);

    query.where(apiKeysTable.providerId.equals(providerId));
    if (start != null) {
      query.where(apiKeyUsages.time.isBiggerOrEqualValue(start));
    }
    if (end != null) {
      query.where(apiKeyUsages.time.isSmallerOrEqualValue(end));
    }

    return query.get();
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
        List<ModelParamName>? parameters;
        var pr = map['parameters'];
        if (pr != null) {
          parameters = (pr as List)
              .map((e) => ModelParamName.values.byName(e))
              .toList();
          if (parameters.isEmpty) {
            parameters = null;
          }
        }

        var m = Model(
          id: map['id'],
          family: map['family'],
          friendlyName: map['friendly_name'],
          // abilities: XModelAlibity.fromList((jsonDecode(map['abilities']) as List)),
          // JSON 已经过一级解析，直接使用 List 处理以避免重复解析错误
          abilities: XModelAlibity.fromList((map['abilities'] as List)),
          contextLength: map['context_length'],
          maxCompletionTokens: map['max_completion_tokens'],
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

  Future<void> processModelsUpdateMapList(List<dynamic> dataList) async {
    await computeWithDatabase(
      computation: (db) async {
        await db.transaction(() async {
          for (var map in dataList) {
            try {
              List<ModelParamName>? parameters;
              var pr = map['parameters'];
              if (pr != null) {
                parameters = (pr as List)
                    .map((e) => ModelParamName.values.byName(e))
                    .toList();
                if (parameters.isEmpty) {
                  parameters = null;
                }
              }

              var m = Model(
                id: map['id'],
                family: map['family'],
                friendlyName: map['friendly_name'],
                abilities: XModelAlibity.fromList((map['abilities'] as List)),
                contextLength: map['context_length'],
                maxCompletionTokens: map['max_completion_tokens'],
                parameters: parameters,
              );
              await db
                  .into(db.models)
                  .insert(
                    m,
                    onConflict: DoUpdate(
                      (old) => ModelsCompanion(
                        friendlyName: Value(m.friendlyName),
                        family: Value(m.family),
                        abilities: Value(m.abilities),
                        contextLength: Value(m.contextLength),
                        maxCompletionTokens: Value(m.maxCompletionTokens),
                        parameters: Value(m.parameters),
                      ),
                    ),
                  );
              // if the user set a model that has the same friendly name as the official ones
              // this makes sure that we will skip the conflict model update will still update the other models
            } catch (e) {
              print(e);
              continue;
            }
          }
        });
      },
      connect: (connection) => _ApiDb.connect(connection),
    );
  }

  Future<void> processProvidersUpdateMapList(List<dynamic> dataList) async {
    await computeWithDatabase(
      computation: (db) async {
        await db.transaction(() async {
          for (var map in dataList) {
            var p = ProviderPreset.fromMap(map);
            await db
                .into(db.providerPresetsTable)
                .insert(
                  p.companion,
                  onConflict: DoUpdate((old) => p.companion),
                );
          }
        });
      },
      connect: (connection) => _ApiDb.connect(connection),
    );
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

  Future<void> init() async {
    //触发检测，防止数据库版本不对导致的问题
    await _adb.customSelect('SELECT 1').get();
  }

  // 在 ApiDatabase 类中添加以下方法

  // Model 表操作
  Future<void> insertModel(Model model) => _adb.insertModel(model);

  Future<void> upsertModel(Model model) => _adb.upsertModel(model);

  Future<void> upsertProviderPreset(ProviderPreset preset) =>
      _adb.upsertProviderPreset(preset);

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

  Future<List<({ApiKey key, String? invokeDataJson})>> getAvailableApiKeys(
    String providerId,
  ) => _adb.getAvailableApiKeys(providerId);

  Future<void> processModelsUpdateMapList(List<dynamic> dataList) =>
      _adb.processModelsUpdateMapList(dataList);

  Future<void> processProvidersUpdateMapList(List<dynamic> dataList) =>
      _adb.processProvidersUpdateMapList(dataList);
  Future<ProviderModelConfig?> getProviderModelConfig(
    String providerId,
    String modelId,
  ) => _adb.getProviderModelConfig(providerId, modelId);

  Future<List<ApiKeyUsage>> getHistory(ApiKey key) => _adb.getHistory(key);
  Future<List<Model>> getAvailableModels() => _adb.getAvailableModels();
  Future<List<ApiProvider>> getApiProviderByModelId(String modelId) =>
      _adb.getApiProviderByModelId(modelId);
  Future<void> updateApiKeyInvokeData(ApiKey key, String dataJson) =>
      _adb.updateApiKeyInvokeData(key, dataJson);

  Future<List<({DateTime time, int total, double? cost, String? currency})>>
  getTrendBuckets(
    String providerId, {
    required DateTime start,
    required DateTime end,
  }) => _adb.getUsageStats(providerId, start: start, end: end);

  Future<({int prompt, int completion, int cached, Map<String, double> costs})>
  getUsageSummary(
    String providerId, {
    required DateTime start,
    required DateTime end,
  }) => _adb.getUsageSummary(providerId, start: start, end: end);

  Future<List<({Model? model, String modelId, int total, double cost})>>
  getModelUsageBuckets(
    String providerId, {
    required DateTime start,
    required DateTime end,
  }) => _adb.getModelUsageBuckets(providerId, start: start, end: end);

  Future<List<({ApiKey key, int total, double cost})>> getKeyUsageBuckets(
    String providerId, {
    required DateTime start,
    required DateTime end,
  }) => _adb.getKeyUsageBuckets(providerId, start: start, end: end);

  Future<List<({ApiKeyUsage usage, Model? model})>> getDetailedUsageLogs(
    String providerId, {
    DateTime? start,
    DateTime? end,
  }) => _adb.getDetailedUsageLogs(providerId, start: start, end: end);

  Future<
    Map<String, ({int totalTokens, int callCount, Map<String, double> costs})>
  >
  getAllProvidersUsageSummaries(DateTime start) =>
      _adb.getAllProvidersUsageSummaries(start);
}
