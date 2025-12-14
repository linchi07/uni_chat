import 'dart:isolate';

import 'package:entao_jsonrpc/entao_jsonrpc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uni_chat/llm_provider/pre_build_providers.dart';
import 'package:uni_chat/utils/file_utils.dart';
import 'package:uni_chat/utils/transfer_layer/isolate.dart';
import 'package:uuid/uuid.dart';

import '../utils/api_database_service.dart';
import 'api_service.dart';

class LLMServiceWrapper extends IsolateManager {
  static LLMServiceWrapper? _instance;
  LLMServiceWrapper._internal() : super.internal();

  static Future<LLMServiceWrapper> get instance async {
    if (_instance != null) {
      return _instance!;
    }
    _instance = LLMServiceWrapper._internal();
    await _instance!.init();
    var rp = ReceivePort();
    var sp = await _instance!.getSendPort(rp.sendPort);
    _instance!.messenger = LLMServiceMessenger.constructor(rp, sp);
    return _instance!;
  }

  late LLMServiceMessenger messenger;
  @override
  Future<void> onSpawn(RpcServer server) async {
    super.onSpawn(server);
    var i = await LLMServiceServer.instance;
    server.add(
      'getProvider',
      (context) {
        return i.getProvider(context['providerId']);
      },
      expand: false,
      context: true,
    );
    server.add('getAllProviders', i.getAllProviders, expand: false);
    server.add(
      'updateProvider',
      i.updateProvider,
      expand: false,
      context: true,
    );
    server.add(
      'getProvidersByModel',
      (context) => i.getProvidersByModel(context['modelId']),
      expand: false,
      context: true,
    );
    server.add(
      'deleteProvider',
      (context) => i.deleteProvider(context['providerId']),
      expand: false,
      context: true,
    );
    server.add(
      'createOrUpdateApiKey',
      (context) => i.createOrUpdateApiKey(apiKey: context['key']),
      expand: false,
      context: true,
    );
    server.add(
      'getApiKey',
      (context) => i.getApiKey(context['keyId']),
      expand: false,
      context: true,
    );
    server.add(
      'getApiKeyByProvider',
      (context) => i.getApiKeysByProvider(context['providerId']),
      expand: false,
      context: true,
    );
    server.add(
      'deleteApiKey',
      (context) => i.deleteApiKey(context['keyId']),
      expand: false,
      context: true,
    );
    server.add('getAllModels', i.getAllModels, expand: false);
    server.add(
      'getModelsByProvider',
      (context) => i.getModelsByProvider(context['providerId']),
      expand: false,
      context: true,
    );
    server.add(
      'updateModel',
      (context) => i.updateModel(context['model']),
      expand: false,
      context: true,
    );
    server.add('deleteModel', (context) => i.deleteModel(context['modelId']));
    server.add(
      'createOrUpdateProviderModelConfig',
      i.createOrUpdateProviderModelConfig,
      expand: false,
      context: true,
    );
    server.add(
      'getProviderModelConfig',
      (context) => i.getProviderModelConfig(context['configId']),
      expand: false,
      context: true,
    );
    server.add(
      "getProviderModelConfigsForProvider",
      (context) => i.getProviderModelConfigsForProvider(context['providerId']),
      expand: false,
      context: true,
    );
    server.add(
      'updateProviderModelConfig',
      (context) => i.updateProviderModelConfig(context),
      expand: false,
      context: true,
    );
    server.add(
      'getProviderModelConfigsForModelWithProvider',
      (context) => i.getProviderModelConfigsForModelWithProvider(
        context['modelId'],
        context['providerId'],
      ),
      expand: false,
      context: true,
    );
    server.add(
      'deleteProviderModelConfig',
      (context) => i.deleteProviderModelConfig(context['configId']),
      expand: false,
      context: true,
    );
    server.add(
      "deleteAllModelConfigsByProvider",
      (context) => i.deleteAllModelConfigsByProvider(context['providerId']),
      expand: false,
      context: true,
    );
  }
}

class LLMServiceMessenger extends IsolateMessenger {
  LLMServiceMessenger.constructor(super.receivePort, super.sendPort);
  final _uuid = Uuid();
  Future<ApiProvider> createProvider({
    required String name,
    required String type,
    required String apiEndpoint,
    required Set<ApiAbility> abilities,
    bool isEnabled = true,
  }) async {
    final provider = ApiProvider(
      id: _uuid.v4(),
      name: name,
      type: type,
      abilities: abilities,
      apiEndpoint: apiEndpoint,
      isEnabled: isEnabled,
    );
    await send('createProvider', map: provider.toMap());
    return provider;
  }

  Future<ApiProvider> getProvider(String providerId) async {
    final provider = await send('getProvider', map: {'providerId': providerId});
    if (provider == null) {
      throw Exception('Provider not found');
    }
    if (provider is! Map<String, dynamic>) {
      throw Exception('format error');
    }
    return ApiProvider.fromMap(provider);
  }

  Future<List<ApiProvider>> getAllProviders() async {
    final result = await send('getAllProviders');
    if (result is! List<Map<String, dynamic>>) {
      throw Exception('format error');
    }
    var providers = result;
    return providers.map((e) => ApiProvider.fromMap(e)).toList();
  }

  Future<void> updateProvider(ApiProvider provider) async {
    await send('updateProvider', map: provider.toMap());
  }

  Future<List<ApiProvider>> getProvidersByModel(String modelId) async {
    final result = await send('getProvidersByModel', map: {'modelId': modelId});
    if (result is! List<Map<String, dynamic>>) {
      throw Exception('format error');
    }
    return result.map((e) => ApiProvider.fromMap(e)).toList();
  }

  Future<void> deleteProvider(String providerId) async {
    await send('deleteProvider', map: {'providerId': providerId});
  }

  Future<void> createOrUpdateApiKey({required ApiKey key}) async {
    await send('createOrUpdateApiKey', map: key.toMap());
  }

  Future<ApiKey?> getApiKey(String keyId) async {
    final result = await send('getApiKey', map: {'keyId': keyId});
    if (result == null) {
      return null;
    }
    if (result is! Map<String, dynamic>) {
      throw Exception('format error');
    }
    return ApiKey.fromMap(result);
  }

  Future<List<ApiKey>> getApiKeyByProvider(String providerId) async {
    final result = await send(
      'getApiKeyByProvider',
      map: {'providerId': providerId},
    );
    if (result is! List<Map<String, dynamic>>) {
      throw Exception('format error');
    }
    return result.map((e) => ApiKey.fromMap(e)).toList();
  }

  Future<void> deleteApiKey(String keyId) async {
    await send('deleteApiKey', map: {'keyId': keyId});
  }

  Future<List<Model>> getAllModels() async {
    final result = await send('getAllModels');
    if (result is! List<Map<String, dynamic>>) {
      throw Exception('format error');
    }
    return result.map((e) => Model.fromMap(e)).toList();
  }

  Future<List<Model>> getModelsByProvider(String providerId) async {
    final result = await send(
      'getModelsByProvider',
      map: {'providerId': providerId},
    );
    if (result is! List<Map<String, dynamic>>) {
      throw Exception('format error');
    }
    return result.map((e) => Model.fromMap(e)).toList();
  }

  Future<void> updateModel(Model model) async {
    await send('updateModel', map: model.toMap());
  }

  Future<void> deleteModel(String modelId) async {
    await send('deleteModel', map: {'modelId': modelId});
  }

  Future<ProviderModelConfig> createOrUpdateProviderModelConfig({
    required ModelsConfigData modelConfigData,
    required String providerId,
    required String modelId,
  }) async {
    final config = ProviderModelConfig(
      id: Uuid().v7(),
      providerId: providerId,
      modelId: modelId,
      callName: modelConfigData.callName,
    );
    await send('createOrUpdateProviderModelConfig', map: config.toMap());
    return config;
  }

  Future<ProviderModelConfig> getProviderModelConfig(String configId) async {
    final result = await send(
      'getProviderModelConfig',
      map: {'configId': configId},
    );
    if (result is! Map<String, dynamic>) {
      throw Exception('format error');
    }
    return ProviderModelConfig.fromMap(result);
  }

  Future<List<ProviderModelConfig>> getProviderModelConfigsForProvider(
    String providerId,
  ) async {
    final result = await send(
      'getProviderModelConfigsForProvider',
      map: {'providerId': providerId},
    );
    if (result is! List<Map<String, dynamic>>) {
      throw Exception('format error');
    }
    return result.map((e) => ProviderModelConfig.fromMap(e)).toList();
  }

  Future<void> updateProviderModelConfig(ProviderModelConfig config) async {
    await send('updateProviderModelConfig', map: config.toMap());
  }

  Future<List<ProviderModelConfig>> getProviderModelConfigsForModelWithProvider(
    String modelId,
    String providerId,
  ) async {
    final result = await send(
      'getProviderModelConfigsForModelWithProvider',
      map: {'modelId': modelId, 'providerId': providerId},
    );
    if (result is! List<Map<String, dynamic>>) {
      throw Exception('format error');
    }
    return result.map((e) => ProviderModelConfig.fromMap(e)).toList();
  }

  Future<void> deleteProviderModelConfig(String configId) async {
    await send('deleteProviderModelConfig', map: {'configId': configId});
  }

  Future<void> deleteAllModelConfigsByProvider(String providerId) async {
    await send(
      'deleteAllModelConfigsByProvider',
      map: {'providerId': providerId},
    );
  }
}

class LLMServiceServer {
  late Database db;
  static late final LLMServiceServer? _instance;
  LLMServiceServer._internal();
  static Future<LLMServiceServer> get instance async {
    if (_instance != null) {
      return _instance!;
    }
    _instance = LLMServiceServer._internal();
    _instance!.db = await _instance!._initDatabase();
    return _instance!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      await PathProvider.getPath("api_configs.db"),
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE config_versions (
        config TEXT PRIMARY KEY,
        version INTEGER NOT NULL
      )
    ''');

    // 创建提供商表
    await db.execute('''
      CREATE TABLE api_providers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        api_endpoint TEXT NOT NULL,
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
        abilities_override TEXT
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

  Future<void> createProvider(Map<String, dynamic> map) async {
    await db.insert('api_providers', map);
  }

  Future<Map<String, dynamic>?> getProvider(String providerId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'api_providers',
      where: 'id = ?',
      whereArgs: [providerId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllProviders() async {
    final List<Map<String, dynamic>> maps = await db.query('api_providers');
    return maps.toList();
  }

  Future<void> updateProvider(Map<String, dynamic> provider) async {
    await db.update(
      'api_providers',
      provider,
      where: 'id = ?',
      whereArgs: [provider['id']],
    );
  }

  Future<List<Map<String, dynamic>>> getProvidersByModel(String modelId) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
    SELECT ap.* FROM api_providers ap
    JOIN provider_model_configs pmc ON ap.id = pmc.provider_id
    WHERE pmc.model_id = ?
  ''',
      [modelId],
    );
    return maps.toList();
  }

  Future<void> deleteProvider(String providerId) async {
    await db.delete('api_providers', where: 'id = ?', whereArgs: [providerId]);
  }

  Future<void> createOrUpdateApiKey({
    required Map<String, dynamic> apiKey,
  }) async {
    var old = (await db.query(
      'api_keys',
      where: 'id = ?',
      whereArgs: [apiKey['id']],
    )).firstOrNull;
    if (old != null) {
      var am = apiKey;
      am.remove('id');
      await db.update(
        'api_keys',
        am,
        where: 'id = ?',
        whereArgs: [apiKey['id']],
      );
    }

    await db.insert('api_keys', apiKey);
  }

  Future<Map<String, dynamic>?> getApiKey(String keyId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'api_keys',
      where: 'id = ?',
      whereArgs: [keyId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> getApiKeysByProvider(
    String providerId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'api_keys',
      where: 'provider_id = ?',
      whereArgs: [providerId],
    );
    return maps.toList();
  }

  /*
  Future<List<Map<String, dynamic>>> getAllApiKeys() async {
    final List<Map<String, dynamic>> maps = await db.query('api_keys');
    return maps.toList();
  }
*/
  Future<void> deleteApiKey(String keyId) async {
    await db.delete('api_keys', where: 'id = ?', whereArgs: [keyId]);
  }

  /*
  Future<void> deleteAllKeysByProvider(String providerId) async {
    await db.delete(
      'api_keys',
      where: 'provider_id = ?',
      whereArgs: [providerId],
    );
  }
*/
  Future<List<Map<String, dynamic>>> getAllModels() async {
    final List<Map<String, dynamic>> maps = await db.query('models');
    return maps.toList();
  }

  Future<List<Map<String, dynamic>>> getModelsByProvider(
    String providerId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT m.* FROM models m
      JOIN provider_model_configs pmc ON m.id = pmc.model_id
      WHERE pmc.provider_id = ?
    ''',
      [providerId],
    );
    return maps.toList();
  }

  Future<void> updateModel(Map<String, dynamic> model) async {
    await db.update('models', model, where: 'id = ?', whereArgs: [model['id']]);
  }

  Future<void> deleteModel(String modelId) async {
    await db.delete('models', where: 'id = ?', whereArgs: [modelId]);
  }

  // --- ProviderModelConfig CRUD Methods ---

  Future<void> createOrUpdateProviderModelConfig(
    Map<String, dynamic> modelConfigData,
  ) async {
    final oldConf = (await db.query(
      'provider_model_configs',
      where: 'id = ?',
      whereArgs: [modelConfigData['id']],
      limit: 1,
    )).firstOrNull;

    if (oldConf != null) {
      modelConfigData.remove('id');
      await db.update(
        'provider_model_configs',
        modelConfigData,
        where: 'id = ?',
        whereArgs: [modelConfigData['id']],
      );
      return;
    }
    await db.insert('provider_model_configs', modelConfigData);
  }

  Future<ProviderModelConfig?> getProviderModelConfig(String configId) async {
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

  Future<List<Map<String, dynamic>>> getProviderModelConfigsForProvider(
    String providerId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'provider_model_configs',
      where: 'provider_id = ?',
      whereArgs: [providerId],
    );
    return maps.toList();
  }

  Future<void> updateProviderModelConfig(Map<String, dynamic> config) async {
    await db.update(
      'provider_model_configs',
      config,
      where: 'id = ?',
      whereArgs: [config['id']],
    );
  }

  Future<List<Map<String, dynamic>>>
  getProviderModelConfigsForModelWithProvider(
    String modelId,
    String providerId,
  ) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'provider_model_configs',
      where: 'model_id = ? AND provider_id = ?',
      whereArgs: [modelId, providerId],
    );
    return maps.toList();
  }

  Future<void> deleteProviderModelConfig(String configId) async {
    await db.delete(
      'provider_model_configs',
      where: 'id = ?',
      whereArgs: [configId],
    );
  }

  Future<void> deleteAllModelConfigsByProvider(String providerId) async {
    await db.delete(
      'provider_model_configs',
      where: 'provider_id = ?',
      whereArgs: [providerId],
    );
  }
}
