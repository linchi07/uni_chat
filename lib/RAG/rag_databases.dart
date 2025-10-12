import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:jieba_flutter/analysis/jieba_segmenter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uni_chat/RAG/rag_process.dart';
import 'package:uni_chat/RAG/rag_settings.dart';
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
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
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

        // 删除触发器
        await db.execute('''
  CREATE TRIGGER original_contents_ad AFTER DELETE ON original_contents
  BEGIN
    INSERT INTO original_contents_fts(original_contents_fts, rowid, key_words) 
    VALUES('delete', old.row_id, old.key_words);
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
    chunk_metadata TEXT,
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

  /// 更新记忆库
  /// 注意！ 不论是任意更新，哪怕手动将status 写为 OK
  /// 在触发更新的时候，都会将status 写为 Pending
  /// 需要手动调用OK函数
  Future<void> insertOrUpdateKnowledgeBase(KnowledgeBase kb) async {
    final db = await database;
    kb.status = KnowledgeBaseStat.pending;
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

  // 将数据库设置为OK
  Future<void> setBaseOk(String id) async {
    final db = await database;
    await db.update(
      'knowledge_bases',
      {'status': 'KnowledgeBaseStat.OK'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 获取所有知识库
  Future<List<KnowledgeBase>> getAllKnowledgeBases() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('knowledge_bases');

    return maps.map((map) => KnowledgeBase.fromMap(map)).toList();
  }

  Future<KnowledgeBase?> getKnowledgeBaseById(String knowledgeBaseId) async {
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

  Future<void> deleteKnowledgeBase(String knowledgeBaseId) async {
    final db = await database;
    await db.delete(
      'knowledge_bases',
      where: 'id = ?',
      whereArgs: [knowledgeBaseId],
    );
  }

  Future<Set<RAGIndexMethod>> getIndexMethodOfKnowledgeBase(
    String knowledgeBaseId,
  ) async {
    final db = await database;
    Set<RAGIndexMethod> indexMethods = <RAGIndexMethod>{};

    // 使用三个并行的 EXISTS 查询
    final List<Future<bool>> queries = [
      _existsQuery(db, knowledgeBaseId, 'is_vec_index'),
      _existsQuery(db, knowledgeBaseId, 'is_keyword_index'),
      _existsQuery(db, knowledgeBaseId, 'is_regex_index'),
    ];

    final List<bool> results = await Future.wait(queries);

    if (results[0]) indexMethods.add(RAGIndexMethod.vector);
    if (results[1]) indexMethods.add(RAGIndexMethod.keyword);
    if (results[2]) indexMethods.add(RAGIndexMethod.regex);

    return indexMethods;
  }

  Future<bool> _existsQuery(
    Database db,
    String knowledgeBaseId,
    String column,
  ) async {
    final result = await db.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM original_contents WHERE knowledge_base_id = ? AND $column = 1) as exists_result',
      [knowledgeBaseId],
    );
    return result.first['exists_result'] == 1;
  }

  Future<List<KnowledgeBase>?> getNotOkKnowledgeBase() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'knowledge_bases',
      where: 'status != ?',
      whereArgs: [KnowledgeBaseStat.OK.toString()],
    );
    if (maps.isEmpty) {
      return null;
    }
    return maps.map((e) => KnowledgeBase.fromMap(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getRawOriginalContentOfBase(
    String knowledgeBaseId, {
    Set<RAGIndexMethod>? indexMethod,
    bool getOnlyUnfinished = false,
  }) async {
    final db = await database;
    List<Object?> whereArgs = [knowledgeBaseId];
    List<String> whereConditions = ['knowledge_base_id = ?'];

    if (indexMethod != null) {
      whereConditions.add(
        'is_vec_index = ? AND is_keyword_index = ? AND is_regex_index = ?',
      );
      if (indexMethod.contains(RAGIndexMethod.vector)) {
        whereArgs.add(1);
      } else {
        whereArgs.add(0);
      }
      if (indexMethod.contains(RAGIndexMethod.keyword)) {
        whereArgs.add(1);
      } else {
        whereArgs.add(0);
      }
      if (indexMethod.contains(RAGIndexMethod.regex)) {
        whereArgs.add(1);
      } else {
        whereArgs.add(1);
      }
    }

    if (getOnlyUnfinished) {
      if (indexMethod?.contains(RAGIndexMethod.vector) ?? false) {
        whereConditions.add('is_embedded = ?');
        whereArgs.add(0);
      }
      if (indexMethod?.contains(RAGIndexMethod.keyword) ?? false) {
        whereConditions.add('is_tokenized = ?');
        whereArgs.add(0);
      }
    }

    return await db.query(
      'original_contents',
      where: whereConditions.join(' AND '),
      whereArgs: whereArgs,
    );
  }

  Future<List<SimpleContent>> getKeywordsMatchSimpleContent(
    String baseId,
    String content,
  ) async {
    await JiebaSegmenter.init();
    List<String> searchTokens = JiebaSegmenter().sentenceProcess(content);
    String ftsQuery = searchTokens.join(' OR ');

    // 2. 执行 FTS 查询。关键：使用 JOIN 从主表取出原始关键词！
    // 这一步直接从可能匹配的条目中，把我们需要精确匹配的原始关键词拿出来
    var db = await database;
    final List<Map<String, dynamic>> coarseResults = await db.rawQuery(
      '''
    SELECT T2.content ,T2.metadata,T2.hash FROM original_contents_fts AS T1
    JOIN original_contents AS T2 ON T1.rowid = T2.row_id
    WHERE T1.original_contents_fts MATCH ? AND T2.knowledge_base_id = ? AND T2.is_keyword_index = 1 AND T2.is_tokenized = 1
  ''',
      [ftsQuery, baseId],
    );
    return coarseResults
        .map((e) => SimpleContent.fromOriginalContent(e))
        .toList();
  }

  Future<List<SimpleContent>> getManySimpleContentOfContentChunk(
    List<String> cid,
  ) async {
    final db = await database;
    if (cid.isEmpty) return [];

    final placeholders = List.generate(cid.length, (index) => '?').join(',');

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
     SELECT 
    cc.content,
    cc.hash,
    oc.metadata as original_metadata,
    oc.hash as original_hash
  FROM content_chunks cc
  LEFT JOIN original_contents oc ON cc.original_content_id = oc.id
  WHERE cc.id IN ($placeholders)
  ''', cid);

    return maps.map((map) {
      return SimpleContent.fromMapContentChunk(
        map,
        map['original_metadata'],
        map['original_hash'],
      );
    }).toList();
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

  Future<List<SimpleContent>> getManySimpleContents(
    List<String> contentIds,
  ) async {
    final db = await database;
    final placeholders = List.generate(
      contentIds.length,
      (index) => '?',
    ).join(',');

    final List<Map<String, dynamic>> maps = await db.query(
      'original_contents',
      columns: ['content', 'metadata', 'hash'],
      where: 'id IN ($placeholders)',
      whereArgs: contentIds,
    );

    return maps.map((map) => SimpleContent.fromOriginalContent(map)).toList();
  }

  Future<List<(String, RegExp)>> getOriginalContentRequireRegex(
    String knowledgeBaseId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'original_contents',
      where: 'knowledge_base_id = ? and is_regex_index = ?',
      whereArgs: [knowledgeBaseId, 1],
    );
    List<(String, RegExp)> result = [];
    for (var item in maps) {
      var r = item['regex'] != null
          ? (jsonDecode(item['regex']) as List<dynamic>).cast<String>()
          : null;
      if (r != null) {
        result.add((item['id'], RegExp(jsonDecode(r.first))));
      }
    }
    return result;
  }

  // 插入原始内容
  Future<void> insertOriginalContent(OriginalContent oc) async {
    final db = await database;
    await db.insert('original_contents', oc.toMap());
  }

  // 插入原始内容
  Future<void> updateOriginalContent(OriginalContent oc) async {
    final db = await database;
    var old = await db.query(
      'original_contents',
      where: "id = ?",
      whereArgs: [oc.id],
      limit: 1,
    );
    if (old.isEmpty) {
      await insertOriginalContent(oc);
      return;
    }
    var requireReEmbedding =
        ((oc.hash == null || (old.first['hash'] as int != oc.hash)) &&
        oc.indexMethod.contains(RAGIndexMethod.vector));
    var requireReTokenized =
        (oc.indexMethod.contains(RAGIndexMethod.keyword) &&
        oc.keyWords != old.first['key_words']);
    if (requireReEmbedding) {
      //当设置为向量索引同时内容改变时，让向量索引失效
      //由于设置了级联删除，删除oc向量索引也会全部删除
      //也就是这种时候就直接删除再插入了
      await db.transaction((txn) async {
        await txn.delete(
          'original_contents',
          where: "id = ?",
          whereArgs: [oc.id],
        );
        oc.isEmbedded = !requireReEmbedding;
        oc.isTokenized = !requireReTokenized;
        var m = oc.toMap();
        await txn.insert('original_contents', m);
        return;
      });
    }
    //如果只是需要重新分词的话，则只更新分词字段即可
    oc.isTokenized = !requireReTokenized;
    oc.isEmbedded = !requireReEmbedding;
    var m = oc.toMap();
    m.remove('id');
    await db.update(
      'original_contents',
      m,
      where: "id = ?",
      whereArgs: [oc.id],
    );
  }

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

  ///使用一个事务批量更新数据库
  ///[anythingElse]如果这个失败了，那么其他数据库也会回滚，实际上就是拿来写向量数据库的
  Future<void> updateDBsWithTransaction(
    ContentProcessResult cpr, [
    Future<void> Function()? anythingElse,
  ]) {
    return database.then((db) async {
      await db.transaction((txn) async {
        if (cpr.writeOrUpdateToOriginalContent != null) {
          var oc = cpr.writeOrUpdateToOriginalContent!;
          await txn.insert(
            'original_contents',
            oc,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        for (var rawChunk in cpr.writeToContentChunkRaw) {
          await txn.insert(
            'content_chunks',
            rawChunk,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        if (anythingElse != null) {
          await anythingElse();
        }
        if (cpr.writeToFts5 != null) {
          await txn.insert('original_contents_fts', {
            'rowid': cpr.writeToFts5!.$1,
            'key_words': cpr.writeToFts5!.$2,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });
    });
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

  ///更新知识库的整个内容
  ///kb需要单独传入
  Future<void> insertOrUpdateKnowledgeBaseWithRAGConfig(
    RagEditState config,
    KnowledgeBase kb,
  ) async {
    final db = await database;
    //此处不能开新的事务或者调用db，否则会造成数据库死锁
    await db.transaction((trx) async {
      kb.status = KnowledgeBaseStat.pending;
      final count = await trx.rawQuery(
        'SELECT COUNT(*) FROM knowledge_bases WHERE id = ?',
        [kb.id],
      );
      if (count.first['COUNT(*)'] == 0) {
        await trx.insert('knowledge_bases', kb.toMap());
      } else {
        await trx.update(
          'knowledge_bases',
          kb.toMap(),
          where: 'id = ?',
          whereArgs: [kb.id],
        );
      }

      ///删除需要删除的内容
      final placeholders = List.generate(
        config.contentRemoveRequireConfirmed.length,
        (index) => '?',
      ).join(',');
      await trx.delete(
        'original_contents',
        where: 'id IN ($placeholders)',
        whereArgs: config.contentRemoveRequireConfirmed.toList(),
      );

      ///添加新添加的记忆
      for (var o in config.memoriesAddRequireConfirmed.values) {
        if (o.content.isNotEmpty &&
            (o.metadata.originalName?.isNotEmpty ?? false)) {
          o.content.trim();
          o.metadata.originalName = o.metadata.originalName!.trim();
          await trx.insert('original_contents', o.toMap());
        }
      }

      ///更新已修改的内容
      for (var c in config.contentModifiedRequireConfirmed.values) {
        if (c.content.isNotEmpty &&
            (c.metadata.originalName?.isNotEmpty ?? false)) {
          c.hash = await RagProcessor.xxH3(c.content);
          var old = await trx.query(
            'original_contents',
            where: "id = ?",
            whereArgs: [c.id],
            limit: 1,
          );
          if (old.isEmpty) {
            await trx.insert('original_contents', c.toMap());
            return;
          }
          var requireReEmbedding =
              ((c.hash == null || (old.first['hash'] as int != c.hash)) &&
              c.indexMethod.contains(RAGIndexMethod.vector));
          var requireReTokenized =
              (c.indexMethod.contains(RAGIndexMethod.keyword) &&
              c.keyWords != old.first['key_words']);
          if (requireReEmbedding) {
            //当设置为向量索引同时内容改变时，让向量索引失效
            //由于设置了级联删除，删除c向量索引也会全部删除
            //也就是这种时候就直接删除再插入了
            await trx.delete(
              'original_contents',
              where: "id = ?",
              whereArgs: [c.id],
            );
            c.isEmbedded = !requireReEmbedding;
            c.isTokenized = !requireReTokenized;
            var m = c.toMap();
            await trx.insert('original_contents', m);
          } else {
            //如果只是需要重新分词的话，则只更新分词字段即可
            c.isTokenized = !requireReTokenized;
            c.isEmbedded = !requireReEmbedding;
            var m = c.toMap();
            m.remove('id');
            await trx.update(
              'original_contents',
              m,
              where: "id = ?",
              whereArgs: [c.id],
            );
          }
        }
      }

      ///添加新的索引规则
      for (var rule in config.indexRules.values) {
        var r = await trx.query(
          'auto_index_rules',
          where: 'id = ?',
          whereArgs: [rule.id],
        );
        var rm = rule.toMap();
        if (r.isEmpty) {
          // 插入规则
          rm.remove("agents");
          await trx.insert('auto_index_rules', rm);
          // 插入agent关联关系
          for (var agent in rule.agents) {
            await trx.insert('agent_rule_relations', {
              'agent_id': agent,
              'rule_id': rule.id,
            });
          }
        } else {
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
        }
      }
    });
    return;
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
      //传回来的map不可✍写
      var newMap = ruleMap.map((key, value) => MapEntry(key, value));
      newMap['agents'] = jsonEncode(agents);
      rules.add(AutoIndexRule.fromMap(newMap));
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
  late final Box<VectorQueryObject2048>? _store2048;
  late final int dimension;
  late Store _store;
  //连接到同一个数据库的实例只能初始化一次，否则要close。
  //而且dart没有天杀的西沟函数，真的是服了
  void close() {
    _store.close();
  }

  final String path;
  VectorSearchManager(this.path, this.dimension) {
    _store = Store(
      getObjectBoxModel(),
      directory: path,
      macosApplicationGroup: "LZ87PRQRHH.objbox",
    );
    switch (dimension) {
      case 384:
        _store384 = Box<VectorQueryObject384>((_store));
        break;
      case 768:
        _store768 = Box<VectorQueryObject768>((_store));
        break;
      case 1024:
        _store1024 = Box<VectorQueryObject1024>((_store));
        break;
      case 1536:
        _store1536 = Box<VectorQueryObject1536>((_store));
        break;
      case 2048:
        _store2048 = Box<VectorQueryObject2048>((_store));
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
                Float32List.fromList(queryVec),
                maxResultCount,
              ),
            )
            .build();
        result = await queryObject.findAsync();
        break;
      case 2048:
        final queryObject = _store2048!
            .query(
              VectorQueryObject2048_.embedding.nearestNeighborsF32(
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
        List<VectorQueryObject384> convertedList = objects
            .cast<VectorQueryObject384>();
        return await _store384!.putManyAsync(convertedList);
      case 768:
        List<VectorQueryObject768> convertedList = objects
            .cast<VectorQueryObject768>();
        return await _store768!.putManyAsync(convertedList);
      case 1024:
        List<VectorQueryObject1024> convertedList = objects
            .cast<VectorQueryObject1024>();
        return await _store1024!.putManyAsync(convertedList);
      case 1536:
        List<VectorQueryObject1536> convertedList = objects
            .cast<VectorQueryObject1536>();
        return await _store1536!.putManyAsync(convertedList);
      case 2048:
        List<VectorQueryObject2048> convertedList = objects
            .cast<VectorQueryObject2048>();
        return await _store2048!.putManyAsync(convertedList);
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
      case 2048:
        return await _store2048!.getAsync(id);
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
      case 2048:
        return await _store2048!.getAllAsync();
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
      case 2048:
        return await _store2048!.removeManyAsync(ids);
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
      case 2048:
        await _store2048!.removeAllAsync();
        break;
      default:
        throw Exception('Invalid dimension for clear');
    }
  }
}
