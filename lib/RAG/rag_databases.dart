import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:uni_chat/utils/file_utils.dart';

import '../objectbox.g.dart';
import 'rag_entity.dart';

class RAGDatabaseManager {
  static final RAGDatabaseManager _instance = RAGDatabaseManager._internal();
  factory RAGDatabaseManager() => _instance;
  RAGDatabaseManager._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = await PathProvider.getPath('RAG/contents.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 创建知识库表
        await db.execute('''
  CREATE TABLE knowledge_bases (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    default_index_method TEXT NOT NULL,
    embeddings TEXT NOT NULL,
    created_at TEXT NOT NULL,
    status TEXT NOT NULL
  )
''');

        // 在index_method上创建索引
        await db.execute('''
  CREATE INDEX idx_knowledge_bases_name
  ON knowledge_bases (name)
''');

        //这里非常重要，必须要用数字主键，为了用fts5，但是这只是数据库层面，我们应用层依然把id当成主键
        // 创建原始内容表
        await db.execute('''
  CREATE TABLE original_contents (
    row_id INTEGER PRIMARY KEY AUTOINCREMENT,
    id TEXT UNIQUE NOT NULL,
    knowledge_base_id TEXT NOT NULL,
    content TEXT NOT NULL,
    key_words TEXT NOT NULL,
    inserted_at TEXT NOT NULL,
    content_type TEXT NOT NULL,
    is_vec_index INTEGER NOT NULL DEFAULT 0,
    is_keyword_index INTEGER NOT NULL DEFAULT 0,
    is_regex_index INTEGER NOT NULL DEFAULT 0,
    metadata TEXT NOT NULL,
    is_embedded INTEGER NOT NULL DEFAULT 0,
    is_tokenized INTEGER NOT NULL DEFAULT 0,
    regex TEXT NOT NULL,
    hash INTEGER,
    FOREIGN KEY (knowledge_base_id) REFERENCES knowledge_bases(id) ON DELETE CASCADE
  )
''');
        // 在index_method上创建索引
        await db.execute('''
  CREATE INDEX idx_original_contents_id
  ON original_contents (id)
''');

        await db.execute('''
  CREATE VIRTUAL TABLE original_contents_fts USING fts5(
    key_words, 
    content='original_contents', 
    content_rowid='row_id'
  )
''');

        // 创建一个触发器，当 original_contents 表插入数据时，自动更新 FTS5 表
        await db.execute('''
  CREATE TRIGGER original_contents_ai AFTER INSERT ON original_contents
  BEGIN
    INSERT INTO original_contents_fts(rowid, key_words) VALUES (new.row_id, new.key_words);
  END
''');

        // 更新触发器
        await db.execute('''
  CREATE TRIGGER original_contents_au AFTER UPDATE ON original_contents
  BEGIN
    INSERT INTO original_contents_fts(original_contents_fts, rowid, key_words) 
    VALUES('delete', old.row_id, old.key_words);
    INSERT INTO original_contents_fts(rowid, key_words) VALUES (new.row_id, new.key_words);
  END
''');

        // 删除触发器
        await db.execute('''
  CREATE TRIGGER original_contents_ad AFTER DELETE ON original_contents
  BEGIN
    INSERT INTO original_contents_fts(original_contents_fts, rowid, key_words) 
    VALUES('delete', old.id, old.key_words);
  END
''');

        // 在knowledge_base_id上创建索引
        await db.execute('''
  CREATE INDEX idx_original_contents_knowledge_base_id 
  ON original_contents (knowledge_base_id)
''');

        // 创建内容块表
        await db.execute('''
  CREATE TABLE content_chunks (
    id TEXT PRIMARY KEY,
    knowledge_base_id TEXT NOT NULL,
    original_content_id TEXT NOT NULL,
    content TEXT NOT NULL,
    hash INTEGER NOT NULL ,
    metadata TEXT,
    FOREIGN KEY (knowledge_base_id) REFERENCES knowledge_bases(id) ON DELETE CASCADE,
    FOREIGN KEY (original_content_id) REFERENCES original_contents(id) ON DELETE CASCADE
  )
''');

        // 在knowledge_base_id上创建索引
        await db.execute('''
  CREATE INDEX idx_content_chunks_knowledge_base_id 
  ON content_chunks (knowledge_base_id)
''');

        // 在knowledge_base_id上创建索引
        await db.execute('''
  CREATE INDEX idx_content_chunks_original_content_id
  ON content_chunks (original_content_id)
''');

        await db.execute('''
CREATE TABLE auto_index_rules (
  id TEXT PRIMARY KEY,
  knowledge_base_id TEXT NOT NULL,
  rag_index_method TEXT NOT NULL,
  keyword TEXT,
  issuer TEXT,
  regex TEXT,
  auto_index_method TEXT NOT NULL,
  FOREIGN KEY (knowledge_base_id) REFERENCES knowledge_bases(id) ON DELETE CASCADE
)
''');

        // 创建Agent与规则的关系表
        await db.execute('''
CREATE TABLE agent_rule_relations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  agent_id TEXT NOT NULL,
  rule_id TEXT NOT NULL,
  FOREIGN KEY (rule_id) REFERENCES auto_index_rules(id) ON DELETE CASCADE
)
''');

        // 在agent_id和rule_id上创建索引以提高查询性能
        await db.execute('''
CREATE INDEX idx_agent_rule_relations_agent_id 
ON agent_rule_relations (agent_id)
''');
      },
    );
  }

  // 插入知识库
  Future<void> insertOrUpdateKnowledgeBase(KnowledgeBase kb) async {
    final db = await database;
    await db.transaction((txn) async {
      final count = await txn.rawQuery(
        'SELECT COUNT(*) FROM knowledge_bases WHERE id = ?',
        [kb.id],
      );
      if (count.first['COUNT(*)'] == 0) {
        await txn.insert('knowledge_bases', kb.toMap());
      } else {
        await txn.update(
          'knowledge_bases',
          kb.toMap(),
          where: 'id = ?',
          whereArgs: [kb.id],
        );
      }
    });
  }

  // 获取所有知识库
  Future<List<KnowledgeBase>> getAllKnowledgeBases() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('knowledge_bases');

    return maps.map((map) => KnowledgeBase.fromMap(map)).toList();
  }

  Future<KnowledgeBase?> getKnowledgeBasesById(String knowledgeBaseId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'knowledge_bases',
      where: 'id = ?',
      whereArgs: [knowledgeBaseId],
      limit: 1,
    );
    if (maps.isEmpty) {
      return null;
    }

    return KnowledgeBase.fromMap(maps.first);
  }

  Future<List<OriginalContent>> getAllOriginalContentOfKnowledgeBaseIdWithType(
    String knowledgeBaseId,
    RagContentType contentType,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'original_contents',
      where: 'knowledge_base_id = ? and content_type = ?',
      whereArgs: [knowledgeBaseId, contentType.toString()],
    );

    return maps.map((map) => OriginalContent.fromMap(map)).toList();
  }

  // 插入原始内容
  Future<void> insertOriginalContent(OriginalContent oc) async {
    final db = await database;
    print(oc.toMap());
    await db.insert('original_contents', oc.toMap());
  }

  // 插入原始内容
  Future<void> updateOriginalContent(OriginalContent oc) async {
    final db = await database;
    var m = oc.toMap();
    m.remove("id");
    await db.update('original_contents', m);
  }

  // 插入原始内容
  Future<void> deleteOriginalContent(String id) async {
    final db = await database;
    await db.delete('original_contents', where: 'id = ?', whereArgs: [id]);
  }

  // 插入内容块
  Future<void> insertContentChunk(ContentChunk cc) async {
    final db = await database;
    await db.insert('content_chunks', cc.toMap());
  }

  Future<ContentChunk?> getContentChunkById(
    String contentChunkId,
    String knowledgeBaseId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'content_chunks',
      where: 'knowledge_base_id = ? and id = ?',
      whereArgs: [knowledgeBaseId, contentChunkId],
      limit: 1,
    );
    if (maps.isEmpty) {
      return null;
    }
    return ContentChunk.fromMap(maps.first);
  }

  Future<List<ContentChunk>> keywordsMatchContent(
    String content,
    String knowledgeBaseId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'content_chunks',
      where: 'knowledge_base_id = ? and index_method = ? and key_words like ?',
      whereArgs: [knowledgeBaseId, '%$content%', 'keyword'],
    );
    return maps.map((map) => ContentChunk.fromMap(map)).toList();
  }

  // 获取特定知识库的所有内容块
  Future<List<ContentChunk>> getContentChunksByKnowledgeBaseId(
    String knowledgeBaseId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'content_chunks',
      where: 'knowledge_base_id = ?',
      whereArgs: [knowledgeBaseId],
    );

    return maps.map((map) => ContentChunk.fromMap(map)).toList();
  }

  // 插入自动索引规则（同时处理关联关系）
  Future<void> insertOrUpdateAutoIndexRule(AutoIndexRule rule) async {
    final db = await database;
    var r = await db.query(
      'auto_index_rules',
      where: 'id = ?',
      whereArgs: [rule.id],
    );
    if (r.isEmpty) {
      await db.transaction((trx) async {
        // 插入规则
        var rm = rule.toMap();
        rm.remove("agents");
        await trx.insert('auto_index_rules', rm);

        // 插入agent关联关系
        for (var agent in rule.agents) {
          await trx.insert('agent_rule_relations', {
            'agent_id': agent,
            'rule_id': rule.id,
          });
        }
      });
    } else {
      await updateAutoIndexRule(rule);
    }
  }

  Future<List<AutoIndexRule>> getAutoIndexRulesByBase(String baseId) async {
    final db = await database;
    var ruleMaps = await db.query(
      'auto_index_rules',
      where: 'knowledge_base_id = ?',
      whereArgs: [baseId],
    );
    // 获取关联的agents
    for (var ruleMap in ruleMaps) {
      final List<Map<String, dynamic>> agentMaps = await db.query(
        'agent_rule_relations',
        where: 'rule_id = ?',
        whereArgs: [ruleMap['id'] ?? ""],
      );

      final List<String> agents = agentMaps
          .map((map) => map['agent_id'] as String)
          .toList();

      ruleMap['agents'] = jsonEncode(agents);
    }
    return ruleMaps.map((map) => AutoIndexRule.fromMap(map)).toList();
  }

  // 根据ID获取自动索引规则
  Future<AutoIndexRule?> getAutoIndexRuleById(String ruleId) async {
    final db = await database;

    // 获取规则基本信息
    final List<Map<String, dynamic>> ruleMaps = await db.query(
      'auto_index_rules',
      where: 'id = ?',
      whereArgs: [ruleId],
      limit: 1,
    );

    if (ruleMaps.isEmpty) return null;

    // 获取关联的agents
    final List<Map<String, dynamic>> agentMaps = await db.query(
      'agent_rule_relations',
      where: 'rule_id = ?',
      whereArgs: [ruleId],
    );

    final List<String> agents = agentMaps
        .map((map) => map['agent_id'] as String)
        .toList();

    // 构造完整的AutoIndexRule对象
    final ruleMap = ruleMaps.first;
    ruleMap['agents'] = jsonEncode(agents);

    return AutoIndexRule.fromMap(ruleMap);
  }

  // 根据agent ID获取所有关联的规则
  Future<List<AutoIndexRule>> getAutoIndexRulesByAgentId(String agentId) async {
    final db = await database;

    // 先通过关系表找到所有关联的规则ID
    final List<Map<String, dynamic>> relationMaps = await db.query(
      'agent_rule_relations',
      where: 'agent_id = ?',
      whereArgs: [agentId],
    );

    final List<String> ruleIds = relationMaps
        .map((map) => map['rule_id'] as String)
        .toList();

    if (ruleIds.isEmpty) return [];

    // 批量获取规则信息
    final placeholders = List.generate(
      ruleIds.length,
      (index) => '?',
    ).join(',');
    final List<Map<String, dynamic>> ruleMaps = await db.query(
      'auto_index_rules',
      where: 'id IN ($placeholders)',
      whereArgs: ruleIds,
    );

    // 为每个规则获取关联的agents
    final List<AutoIndexRule> rules = [];
    for (var ruleMap in ruleMaps) {
      final List<Map<String, dynamic>> agentMaps = await db.query(
        'agent_rule_relations',
        where: 'rule_id = ?',
        whereArgs: [ruleMap['id']],
      );

      final List<String> agents = agentMaps
          .map((map) => map['agent_id'] as String)
          .toList();

      ruleMap['agents'] = jsonEncode(agents);
      rules.add(AutoIndexRule.fromMap(ruleMap));
    }

    return rules;
  }

  // 更新自动索引规则
  Future<void> updateAutoIndexRule(AutoIndexRule rule) async {
    final db = await database;
    await db.transaction((trx) async {
      var rm = rule.toMap();
      rm.remove("agents");
      //agents 由关系表处理，只是封装了
      // 更新规则
      await trx.update(
        'auto_index_rules',
        rm,
        where: 'id = ?',
        whereArgs: [rule.id],
      );

      // 删除旧的关联关系
      await trx.delete(
        'agent_rule_relations',
        where: 'rule_id = ?',
        whereArgs: [rule.id],
      );

      // 插入新的关联关系
      for (var agent in rule.agents) {
        await trx.insert('agent_rule_relations', {
          'agent_id': agent,
          'rule_id': rule.id,
        });
      }
    });
  }

  // 删除自动索引规则（关联关系会自动删除，因为设置了外键约束）
  Future<void> deleteAutoIndexRule(String ruleId) async {
    final db = await database;
    await db.delete('auto_index_rules', where: 'id = ?', whereArgs: [ruleId]);
  }

  // 获取特定知识库的所有自动索引规则
  Future<List<AutoIndexRule>> getAutoIndexRulesByKnowledgeBaseId(
    String knowledgeBaseId,
  ) async {
    final db = await database;

    // 获取该知识库下的所有规则
    final List<Map<String, dynamic>> ruleMaps = await db.query(
      'auto_index_rules',
      where: 'knowledge_base_id = ?',
      whereArgs: [knowledgeBaseId],
    );

    // 为每个规则获取关联的agents
    final List<AutoIndexRule> rules = [];
    for (var ruleMap in ruleMaps) {
      final List<Map<String, dynamic>> agentMaps = await db.query(
        'agent_rule_relations',
        where: 'rule_id = ?',
        whereArgs: [ruleMap['id']],
      );

      final List<String> agents = agentMaps
          .map((map) => map['agent_id'] as String)
          .toList();
      var newMap = ruleMap.map((key, value) => MapEntry(key, value));
      //某个傻逼规定这个地方的map是只读的
      newMap['agents'] = jsonEncode(agents);
      rules.add(AutoIndexRule.fromMap(newMap));
    }

    return rules;
  }

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

class VectorSearchManager {
  bool isInitialized = false;
  late final Box<VectorQueryObject384>? _store384;
  late final Box<VectorQueryObject768>? _store768;
  late final Box<VectorQueryObject1024>? _store1024;
  late final Box<VectorQueryObject1536>? _store1536;
  late final int dimension;

  final String path;
  VectorSearchManager(this.path, this.dimension) {
    switch (dimension) {
      case 384:
        _store384 = Box<VectorQueryObject384>(
          (Store(getObjectBoxModel(), directory: path)),
        );
        break;
      case 768:
        _store768 = Box<VectorQueryObject768>(
          (Store(getObjectBoxModel(), directory: path)),
        );
        break;
      case 1024:
        _store1024 = Box<VectorQueryObject1024>(
          (Store(getObjectBoxModel(), directory: path)),
        );
        break;
      case 1536:
        _store1536 = Box<VectorQueryObject1536>(
          (Store(getObjectBoxModel(), directory: path)),
        );
        break;
      default:
        throw Exception('Invalid dimension');
    }
    isInitialized = true;
  }

  Future<List<VectorQueryObject>> vecQuery(
    List<double> queryVec,
    int maxResultCount,
  ) async {
    if (!isInitialized) {
      throw Exception('VectorSearchManager not initialized');
    }
    List<VectorQueryObject> result = [];
    switch (dimension) {
      case 384:
        final queryObject = _store384!
            .query(
              VectorQueryObject384_.embedding.nearestNeighborsF32(
                queryVec,
                maxResultCount,
              ),
            )
            .build();
        result = await queryObject.findAsync();
        break;
      case 768:
        final queryObject = _store768!
            .query(
              VectorQueryObject768_.embedding.nearestNeighborsF32(
                queryVec,
                maxResultCount,
              ),
            )
            .build();
        result = await queryObject.findAsync();
        break;
      case 1024:
        final queryObject = _store1024!
            .query(
              VectorQueryObject1024_.embedding.nearestNeighborsF32(
                queryVec,
                maxResultCount,
              ),
            )
            .build();
        result = await queryObject.findAsync();
        break;
      case 1536:
        final queryObject = _store1536!
            .query(
              VectorQueryObject1536_.embedding.nearestNeighborsF32(
                queryVec,
                maxResultCount,
              ),
            )
            .build();
        result = await queryObject.findAsync();
        break;
    }
    return result;
  }

  void _checkInitialized() {
    if (!isInitialized) {
      throw Exception(
        'VectorSearchManager not initialized or has been closed.',
      );
    }
  }

  // == NEW CRUD METHODS ==

  /// (Create/Update) Puts (inserts or updates) a list of vector objects into the database.
  /// Returns a list of the ObjectBox IDs for the put objects.
  Future<List<int>> putMany(List<VectorQueryObject> objects) async {
    _checkInitialized();
    switch (dimension) {
      case 384:
        return await _store384!.putManyAsync(
          objects as List<VectorQueryObject384>,
        );
      case 768:
        return await _store768!.putManyAsync(
          objects as List<VectorQueryObject768>,
        );
      case 1024:
        return await _store1024!.putManyAsync(
          objects as List<VectorQueryObject1024>,
        );
      case 1536:
        return await _store1536!.putManyAsync(
          objects as List<VectorQueryObject1536>,
        );
      default:
        // This case should ideally not be reached if constructor logic is sound
        throw Exception('Invalid dimension for putMany');
    }
  }

  /// (Read) Gets a single object by its ObjectBox ID.
  Future<VectorQueryObject?> getById(int id) async {
    _checkInitialized();
    switch (dimension) {
      case 384:
        return await _store384!.getAsync(id);
      case 768:
        return await _store768!.getAsync(id);
      case 1024:
        return await _store1024!.getAsync(id);
      case 1536:
        return await _store1536!.getAsync(id);
      default:
        throw Exception('Invalid dimension for getById');
    }
  }

  /// (Read) Gets all objects from the database.
  Future<List<VectorQueryObject>> getAll() async {
    _checkInitialized();
    switch (dimension) {
      case 384:
        return await _store384!.getAllAsync();
      case 768:
        return await _store768!.getAllAsync();
      case 1024:
        return await _store1024!.getAllAsync();
      case 1536:
        return await _store1536!.getAllAsync();
      default:
        throw Exception('Invalid dimension for getAll');
    }
  }

  /// (Delete) Deletes multiple objects from the database based on their ObjectBox IDs.
  /// Returns the count of deleted objects.
  Future<int> deleteMany(List<int> ids) async {
    _checkInitialized();
    switch (dimension) {
      case 384:
        return await _store384!.removeManyAsync(ids);
      case 768:
        return await _store768!.removeManyAsync(ids);
      case 1024:
        return await _store1024!.removeManyAsync(ids);
      case 1536:
        return await _store1536!.removeManyAsync(ids);
      default:
        throw Exception('Invalid dimension for deleteMany');
    }
  }

  /// (Delete) Deletes all objects from the database.
  Future<void> clear() async {
    _checkInitialized();
    switch (dimension) {
      case 384:
        await _store384!.removeAllAsync();
        break;
      case 768:
        await _store768!.removeAllAsync();
        break;
      case 1024:
        await _store1024!.removeAllAsync();
        break;
      case 1536:
        await _store1536!.removeAllAsync();
        break;
      default:
        throw Exception('Invalid dimension for clear');
    }
  }
}
