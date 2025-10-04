import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uni_chat/llm_provider/api_service.dart';
import 'package:uni_chat/llm_provider/pre_build_providers.dart';
import 'package:uuid/uuid.dart';

import '../llm_provider/pre_built_models.dart';

class ApiProvider {
  final String id;
  final String name;
  final String type;
  final String apiEndpoint;
  final Set<ApiAbility> abilities;
  final bool isEnabled;

  ApiProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.apiEndpoint,
    required this.abilities,
    required this.isEnabled,
  });

  ApiProvider copyWith({
    String? id,
    String? name,
    String? type,
    String? apiEndpoint,
    Set<ApiAbility>? abilities,
    bool? isEnabled,
  }) {
    return ApiProvider(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      abilities: abilities ?? this.abilities,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'api_endpoint': apiEndpoint,
      'is_enabled': isEnabled ? 1 : 0,
      'abilities': jsonEncode(
        abilities.map((ability) => ability.index).toList(),
      ),
    };
  }

  factory ApiProvider.fromMap(Map<String, dynamic> map) {
    return ApiProvider(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      apiEndpoint: map['api_endpoint'],
      abilities: Set.from(
        (jsonDecode(map['abilities']) as List).map(
          (abilityIndex) => ApiAbility.values[abilityIndex as int],
        ),
      ),
      isEnabled: map['is_enabled'] == 1,
    );
  }
}

class ApiKey {
  final String id;
  final String providerId;
  final String keyValue;
  final String keyAlias;
  final bool isEnabled;

  ApiKey({
    required this.id,
    required this.providerId,
    required this.keyValue,
    required this.keyAlias,
    required this.isEnabled,
  });

  ApiKey copyWith({
    String? id,
    String? providerId,
    String? keyValue,
    String? keyAlias,
    bool? isEnabled,
  }) {
    return ApiKey(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      keyValue: keyValue ?? this.keyValue,
      keyAlias: keyAlias ?? this.keyAlias,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'provider_id': providerId,
      'key_value': keyValue,
      'key_alias': keyAlias,
      'is_enabled': isEnabled ? 1 : 0,
    };
  }

  factory ApiKey.fromMap(Map<String, dynamic> map) {
    return ApiKey(
      id: map['id'],
      providerId: map['provider_id'],
      keyValue: map['key_value'],
      keyAlias: map['key_alias'],
      isEnabled: map['is_enabled'] == 1,
    );
  }
}

class Model {
  final String id;
  final String friendlyName;
  final bool isEnabled;
  final String family;
  final Set<ModelAbility> abilities;

  Model({
    required this.id,
    required this.friendlyName,
    required this.isEnabled,
    required this.family,
    required this.abilities,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'friendly_name': friendlyName,
      'is_enabled': isEnabled ? 1 : 0,
      'family': family,
      'abilities': jsonEncode(
        abilities.map((ability) => ability.index).toList(),
      ),
    };
  }

  factory Model.fromMap(Map<String, dynamic> map) {
    return Model(
      id: map['id'],
      family: map['family'],
      friendlyName: map['friendly_name'],
      isEnabled: map['is_enabled'] == 1,
      abilities: Set.from(
        (jsonDecode(map['abilities']) as List).map(
          (abilityIndex) => ModelAbility.values[abilityIndex as int],
        ),
      ),
    );
  }

  ModelsConfigData toConfigData() {
    return ModelsConfigData(
      callName: "",
      friendlyName: friendlyName,
      abilities: abilities,
      family: family,
    );
  }
}

class ProviderModelConfig {
  final String id;
  final String providerId;
  final String modelId;
  final String callName;
  final bool isEnabled;

  ProviderModelConfig({
    required this.id,
    required this.providerId,
    required this.modelId,
    required this.callName,
    required this.isEnabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'provider_id': providerId,
      'model_id': modelId,
      'call_name': callName,
      'is_enabled': isEnabled ? 1 : 0,
    };
  }

  factory ProviderModelConfig.fromMap(Map<String, dynamic> map) {
    return ProviderModelConfig(
      id: map['id'] as String,
      providerId: map['provider_id'] as String,
      modelId: map['model_id'] as String,
      callName: map['call_name'] as String,
      isEnabled: map['is_enabled'] == 1,
    );
  }
}

class ApiDatabaseService {
  static final ApiDatabaseService instance =
      ApiDatabaseService._privateConstructor();
  static Database? _database;
  static const _uuid = Uuid();

  ApiDatabaseService._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbDirectory = p.join(documentsDirectory.path, 'api_config');

    // Ensure the directory exists
    final directory = Directory(dbDirectory);
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }

    final dbPath = p.join(dbDirectory, 'api_configs.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建提供商表
    await db.execute('''
      CREATE TABLE api_providers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        api_endpoint TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        abilities TEXT
      )
    ''');

    // 创建API密钥表
    await db.execute('''
      CREATE TABLE api_keys (
        id TEXT PRIMARY KEY,
        provider_id TEXT NOT NULL,
        key_value TEXT NOT NULL,
        key_alias TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (provider_id) REFERENCES api_providers (id) ON DELETE CASCADE
      )
    ''');

    // 创建全局模型表
    await db.execute('''
      CREATE TABLE models (
        id TEXT PRIMARY KEY,
        friendly_name TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        family TEXT,
        abilities TEXT
      )
    ''');

    // 创建提供商-模型关联表
    await db.execute('''
      CREATE TABLE provider_model_configs (
        id TEXT PRIMARY KEY,
        provider_id TEXT NOT NULL,
        model_id TEXT NOT NULL,
        call_name TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (provider_id) REFERENCES api_providers (id) ON DELETE CASCADE,
        FOREIGN KEY (model_id) REFERENCES models (id) ON DELETE CASCADE
      )
    ''');

    // 为外键创建索引以提高查询性能
    await db.execute(
      'CREATE INDEX idx_api_keys_provider_id ON api_keys (provider_id)',
    );
    await db.execute(
      'CREATE INDEX idx_provider_model_configs_provider_id ON provider_model_configs (provider_id)',
    );
    await db.execute(
      'CREATE INDEX idx_provider_model_configs_model_id ON provider_model_configs (model_id)',
    );
  }

  // --- Provider CRUD Methods ---

  Future<ApiProvider> createProvider({
    required String name,
    required String type,
    required String apiEndpoint,
    required Set<ApiAbility> abilities,
    bool isEnabled = true,
  }) async {
    final db = await database;
    final provider = ApiProvider(
      id: _uuid.v4(),
      name: name,
      type: type,
      abilities: abilities,
      apiEndpoint: apiEndpoint,
      isEnabled: isEnabled,
    );

    await db.insert('api_providers', provider.toMap());
    return provider;
  }

  Future<ApiProvider?> getProvider(String providerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'api_providers',
      where: 'id = ?',
      whereArgs: [providerId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return ApiProvider.fromMap(maps.first);
    }

    return null;
  }

  Future<(ApiProvider?, Model?)> getProviderAndModelByModelConfig(
    String modelConfigId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'provider_model_configs',
      where: 'id = ?',
      whereArgs: [modelConfigId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      var provider = await db.query(
        'api_providers',
        where: 'id = ?',
        whereArgs: [maps.first['provider_id']],
        limit: 1,
      );
      var model = await db.query(
        'models',
        where: 'id = ?',
        whereArgs: [maps.first['model_id']],
        limit: 1,
      );
      return (
        (provider.firstOrNull != null)
            ? ApiProvider.fromMap(provider.first)
            : null,
        (model.firstOrNull != null) ? Model.fromMap(model.first) : null,
      );
    }
    return (null, null);
  }

  Future<List<ApiProvider>> getAllProviders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('api_providers');
    return maps.map((map) => ApiProvider.fromMap(map)).toList();
  }

  Future<void> updateProvider(ApiProvider provider) async {
    final db = await database;
    await db.update(
      'api_providers',
      provider.toMap(),
      where: 'id = ?',
      whereArgs: [provider.id],
    );
  }

  Future<List<ApiProvider>> getProvidersByModel(String modelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
    SELECT ap.* FROM api_providers ap
    JOIN provider_model_configs pmc ON ap.id = pmc.provider_id
    WHERE pmc.model_id = ?
  ''',
      [modelId],
    );
    return maps.map((map) => ApiProvider.fromMap(map)).toList();
  }

  Future<void> deleteProvider(String providerId) async {
    final db = await database;
    await db.delete('api_providers', where: 'id = ?', whereArgs: [providerId]);
  }

  // --- API Key CRUD Methods ---

  Future<ApiKey> createOrUpdateApiKey({required ApiKey apiKey}) async {
    final db = await database;
    var old = (await db.query(
      'api_keys',
      where: 'id = ?',
      whereArgs: [apiKey.id],
    )).firstOrNull;
    if (old != null) {
      var am = apiKey.toMap();
      am.remove('id');
      await db.update('api_keys', am, where: 'id = ?', whereArgs: [apiKey.id]);
      return apiKey;
    }

    await db.insert('api_keys', apiKey.toMap());
    return apiKey;
  }

  Future<ApiKey?> getApiKey(String keyId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'api_keys',
      where: 'id = ?',
      whereArgs: [keyId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return ApiKey.fromMap(maps.first);
    }

    return null;
  }

  Future<List<ApiKey>> getApiKeysByProvider(String providerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'api_keys',
      where: 'provider_id = ?',
      whereArgs: [providerId],
    );
    return maps.map((map) => ApiKey.fromMap(map)).toList();
  }

  Future<List<ApiKey>> getAllApiKeys() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('api_keys');
    return maps.map((map) => ApiKey.fromMap(map)).toList();
  }

  Future<void> deleteApiKey(String keyId) async {
    final db = await database;
    await db.delete('api_keys', where: 'id = ?', whereArgs: [keyId]);
  }

  Future<void> deleteAllKeysByProvider(String providerId) async {
    final db = await database;
    await db.delete(
      'api_keys',
      where: 'provider_id = ?',
      whereArgs: [providerId],
    );
  }

  // --- Model CRUD Methods ---

  Future<Model> createModel({
    required String friendlyName,
    required Set<ModelAbility> abilities,
    required String family,
    bool isEnabled = true,
  }) async {
    final db = await database;
    final model = Model(
      id: _uuid.v4(),
      friendlyName: friendlyName,
      isEnabled: isEnabled,
      family: family,
      abilities: abilities,
    );

    await db.insert('models', model.toMap());
    return model;
  }

  Future<Model> findOrCreateModel(ModelsConfigData modelConfigData) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'models',
      where: 'friendly_name = ?',
      whereArgs: [modelConfigData.friendlyName],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Model.fromMap(maps.first);
    } else {
      return await createModel(
        friendlyName: modelConfigData.friendlyName,
        abilities: modelConfigData.abilities,
        family: modelConfigData.family ?? '',
      );
    }
  }

  Future<Model?> getModel(String modelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'models',
      where: 'id = ?',
      whereArgs: [modelId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Model.fromMap(maps.first);
    }

    return null;
  }

  Future<List<Model>> getModelsByProvider(String providerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT m.* FROM models m
      JOIN provider_model_configs pmc ON m.id = pmc.model_id
      WHERE pmc.provider_id = ?
    ''',
      [providerId],
    );
    return maps.map((map) => Model.fromMap(map)).toList();
  }

  Future<List<Model>> getAllModels({
    Set<ModelAbility>? withAbilities,
    Set<ModelAbility>? exceptAbilities,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('models');
    var results = maps.map((map) => Model.fromMap(map)).toList();

    if (withAbilities != null) {
      results = results
          .where((model) => model.abilities.containsAll(withAbilities))
          .toList();
    }

    if (exceptAbilities != null) {
      results = results
          .where(
            (model) => !exceptAbilities.any(
              (ability) => model.abilities.contains(ability),
            ),
          )
          .toList();
    }

    return results;
  }

  Future<List<Model>> getEnabledModelsByProvider(String providerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT m.* FROM models m
      JOIN provider_model_configs pmc ON m.id = pmc.model_id
      WHERE pmc.provider_id = ? AND pmc.is_enabled = 1 AND m.is_enabled = 1
    ''',
      [providerId],
    );
    return maps.map((map) => Model.fromMap(map)).toList();
  }

  Future<void> updateModel(Model model) async {
    final db = await database;
    await db.update(
      'models',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> deleteModel(String modelId) async {
    final db = await database;
    await db.delete('models', where: 'id = ?', whereArgs: [modelId]);
  }

  // --- ProviderModelConfig CRUD Methods ---

  Future<ProviderModelConfig> createOrUpdateProviderModelConfig({
    required ModelsConfigData modelConfigData,
    required String providerId,
    required String modelId,
  }) async {
    final config = ProviderModelConfig(
      id: modelConfigData.id,
      providerId: providerId,
      modelId: modelId,
      callName: modelConfigData.callName,
      isEnabled: true,
    );
    final db = await database;
    final oldConf = (await db.query(
      'provider_model_configs',
      where: 'id = ?',
      whereArgs: [modelConfigData.id],
      limit: 1,
    )).firstOrNull;

    if (oldConf != null) {
      var cm = config.toMap();
      cm.remove('id');
      await db.update(
        'provider_model_configs',
        cm,
        where: 'id = ?',
        whereArgs: [modelConfigData.id],
      );
      return config;
    }

    await db.insert('provider_model_configs', config.toMap());
    return config;
  }

  Future<ProviderModelConfig?> getProviderModelConfig(String configId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'provider_model_configs',
      where: 'id = ?',
      whereArgs: [configId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return ProviderModelConfig.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ProviderModelConfig>> getProviderModelConfigsForProvider(
    String providerId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'provider_model_configs',
      where: 'provider_id = ?',
      whereArgs: [providerId],
    );
    return maps.map((map) => ProviderModelConfig.fromMap(map)).toList();
  }

  Future<void> updateProviderModelConfig(ProviderModelConfig config) async {
    final db = await database;
    await db.update(
      'provider_model_configs',
      config.toMap(),
      where: 'id = ?',
      whereArgs: [config.id],
    );
  }

  Future<List<ProviderModelConfig>> getProviderModelConfigsForModelWithProvider(
    String modelId,
    String providerId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'provider_model_configs',
      where: 'model_id = ? AND provider_id = ?',
      whereArgs: [modelId, providerId],
    );
    return maps.map((map) => ProviderModelConfig.fromMap(map)).toList();
  }

  Future<void> deleteProviderModelConfig(String configId) async {
    final db = await database;
    await db.delete(
      'provider_model_configs',
      where: 'id = ?',
      whereArgs: [configId],
    );
  }

  Future<void> deleteAllModelConfigsByProvider(String providerId) async {
    final db = await database;
    await db.delete(
      'provider_model_configs',
      where: 'provider_id = ?',
      whereArgs: [providerId],
    );
  }
}
