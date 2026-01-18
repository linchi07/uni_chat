import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/utils/file_utils.dart';

import '../settings_page/api_configure.dart' show ApiConfigure;

class ApiDatabase {
  // 私有的静态实例
  static ApiDatabase? _instance;
  Future<Database> get database async {
    if (_db == null) {
      await _initialize();
    }
    return _db!;
  }

  Database? _db;
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
  ApiDatabase._internal();

  Future<void> _initialize() async {
    _db = await openDatabase(
      await PathProvider.getPath("api_config.db"),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE version (
            identifier TEXT PRIMARY KEY,
            version TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE model (
            id TEXT PRIMARY KEY,
            friendly_name TEXT,
            family TEXT,
            abilities TEXT,
            description TEXT,
            context_length INTEGER,
            max_completion_tokens INTEGER,
            pricing TEXT,
            parameters TEXT
          )
        ''');

        await db.execute('''
          CREATE INDEX model_name_idx ON model (friendly_name);
        ''');

        await db.execute('''
          CREATE TABLE provider_model_config (
            provider_id TEXT NOT NULL,
            model_id TEXT NOT NULL,
            call_name TEXT NOT NULL,
            abilities_override TEXT,
            parameters_override TEXT,
            pricing_override TEXT,
            UNIQUE (provider_id, model_id),
            FOREIGN KEY (model_id) REFERENCES model(id) ON DELETE CASCADE,
            FOREIGN KEY (provider_id) REFERENCES api_provider(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE INDEX provider_model_config_idx ON provider_model_config (model_id);
        ''');

        await db.execute('''
          CREATE TABLE provider_preset(
            id TEXT PRIMARY KEY,
            i18n_name TEXT NOT NULL,
            type TEXT NOT NULL,
            api_type TEXT NOT NULL,
            endpoint TEXT,
            models TEXT,
            available INTEGER DEFAULT 1
          )
        ''');

        await db.execute('''
          CREATE TABLE api_provider (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            endpoint TEXT NOT NULL,
            preset TEXT
          )
        ''');

        await db.execute('''
           CREATE TABLE api_keys (
            id TEXT PRIMARY KEY,
            provider_id TEXT NOT NULL,
            key TEXT NOT NULL,
            remark TEXT,
            rpm INTEGER,
            rpd INTEGER,
            token_limit INTEGER,
            is_enabled INTEGER DEFAULT 1,
            FOREIGN KEY (provider_id) REFERENCES api_provider(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE INDEX api_keys_idx ON api_keys (provider_id);
        ''');

        await loadDefaultData(db);
      },
    );
  }

  Future<void> loadDefaultData(Database db) async {
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
          description: map['description'],
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
        await db.insert("model", m.toMap());
      }
      for (var p in ProviderPreset.presets) {
        await db.insert("provider_preset", p.toMap());
      }
      await db.insert("version", {'identifier': 'model', 'version': '1'});
    } catch (e) {
      print(e);
    }
  }

  // 在 ApiDatabase 类中添加以下方法

  // Model 表操作
  Future<int> insertModel(Model model) async {
    final db = await database;
    return await db.insert(
      'model',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Model>> getAllModels() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('model');

    return List.generate(maps.length, (i) {
      return Model.fromMap(maps[i]);
    });
  }

  Future<Model?> getModelById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'model',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Model.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Model>> getModelsBatch(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final db = await database;
    var r = await db.query(
      'model',
      where: 'id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );
    return r.map((e) => Model.fromMap(e)).toList();
  }

  Future<List<Model>> searchModel(String likeKeyWord) async {
    final db = await database;
    var r = await db.query(
      'model',
      where: 'friendly_name LIKE ?',
      whereArgs: ['%$likeKeyWord%'],
    );
    return r.map((e) => Model.fromMap(e)).toList();
  }

  Future<int> updateModel(Model model) async {
    final db = await database;
    return await db.update(
      'model',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<int> deleteModel(String id) async {
    final db = await database;
    return await db.delete('model', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ApiProvider>> getAllProviders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('api_provider');
    return maps.map((e) => ApiProvider.fromMap(e)).toList();
  }

  Future<ApiProvider?> getProviderById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'api_provider',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    return ApiProvider.fromMap(maps.first);
  }

  Future<List<ApiKey>> getApiKeys(String providerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'api_keys',
      where: 'provider_id = ?',
      whereArgs: [providerId],
    );
    return maps.map((e) => ApiKey.fromMap(e)).toList();
  }

  Future<int> insertProviderModelConfig(ProviderModelConfig config) async {
    final db = await database;
    return await db.insert(
      'provider_model_config',
      config.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProviderModelConfig>> getAllProviderModelConfigs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'provider_model_config',
    );
    return maps.map((e) => ProviderModelConfig.fromMap(e)).toList();
  }

  Future<List<ProviderModelConfig>> getProviderModelConfigsByModelId(
    String modelId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'provider_model_config',
      where: 'modelId = ?',
      whereArgs: [modelId],
    );
    return maps.map((e) => ProviderModelConfig.fromMap(e)).toList();
  }

  Future<int> updateProviderModelConfig(ProviderModelConfig config) async {
    final db = await database;
    return await db.update(
      'provider_model_config',
      config.toMap(),
      where: 'providerId = ? AND modelId = ?',
      whereArgs: [config.providerId, config.modelId],
    );
  }

  Future<int> deleteProviderModelConfig(
    String providerId,
    String modelId,
  ) async {
    final db = await database;
    return await db.delete(
      'provider_model_config',
      where: 'providerId = ? AND modelId = ?',
      whereArgs: [providerId, modelId],
    );
  }

  // ProviderPreset 表操作
  Future<int> insertProviderPreset(ProviderPreset preset) async {
    final db = await database;
    return await db.insert(
      'provider_preset',
      preset.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProviderPreset>> getAllProviderPresets({
    bool? onlyAvailable = false,
  }) async {
    final db = await database;
    late final List<Map<String, dynamic>> maps;
    if (onlyAvailable == true) {
      maps = await db.query(
        'provider_preset',
        where: 'available = ?',
        whereArgs: [1],
      );
    } else {
      maps = await db.query('provider_preset');
    }
    try {
      return List.generate(maps.length, (i) {
        return ProviderPreset.fromMap(maps[i]);
      });
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<ProviderPreset?> getProviderPresetById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'provider_preset',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ProviderPreset.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateProviderPreset(ProviderPreset preset) async {
    final db = await database;
    return await db.update(
      'provider_preset',
      preset.toMap(),
      where: 'id = ?',
      whereArgs: [preset.id],
    );
  }

  Future<int> deleteProviderPreset(String id) async {
    final db = await database;
    return await db.delete('provider_preset', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveApiConfigure(ApiConfigure configure) async {
    final db = await database;
    var pv = configure.toProvider();
    await db.transaction((trc) async {
      await trc.insert(
        "api_provider",
        pv.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (var k in configure.keys) {
        await trc.insert(
          "api_keys",
          k.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (var m in configure.models) {
        await trc.insert(
          "provider_model_config",
          m.config.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      if (configure.providerPreset != null &&
          configure.type == ProviderPresetType.singleInstance) {
        var cppm = configure.providerPreset!.toMap();
        cppm["available"] = 0;
        await trc.update(
          "provider_preset",
          cppm,
          where: "id = ?",
          whereArgs: [configure.providerPreset!.id],
        );
      }
    });
  }

  Future<void> deleteApiProvider(String id) async {
    final db = await database;
    await db.transaction((trc) async {
      List<Map<String, dynamic>> d = await trc.query(
        "api_provider",
        where: "id = ?",
        whereArgs: [id],
        limit: 1,
      );
      if (d.firstOrNull != null && d.first['preset'] != null) {
        await trc.update(
          "provider_preset",
          {"available": 1},
          where: "id = ?",
          whereArgs: [d.first['preset']],
        );
      }
      await trc.delete("api_provider", where: "id = ?", whereArgs: [id]);
    });
  }

  Future<List<ProviderModelConfig>> getProviderModelConfigs(
    String providerID,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'provider_model_config',
      where: 'provider_id = ?',
      whereArgs: [providerID],
    );
    return maps.map((e) => ProviderModelConfig.fromMap(e)).toList();
  }
}
