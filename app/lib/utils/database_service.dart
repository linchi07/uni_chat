import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uni_chat/Agent/agentProvider.dart';
import 'package:uuid/uuid.dart';

import '../Chat/chat_models.dart';
import '../Persona/persona_provider.dart';
import 'file_utils.dart';

class AgentData {
  final String id;
  final String name;
  final String modelProviderConfigureId;
  final String? description;
  final String? systemPrompt;
  late final List<String> knowledgeBases;
  final ModelSpecifics modelSpecifics;
  final DateTime createdAt;
  final bool isDefault;

  AgentData({
    required this.id,
    required this.name,
    required this.modelProviderConfigureId,
    required this.modelSpecifics,
    this.description,
    this.systemPrompt,
    List<String>? knowledgeBases,
    required this.createdAt,
    this.isDefault = false,
  }) {
    this.knowledgeBases = knowledgeBases ?? [];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'system_prompt': systemPrompt,
      'knowledge_bases': jsonEncode(knowledgeBases),
      'created_at': createdAt.toIso8601String(),
      'is_default': isDefault ? 1 : 0,
    };
  }

  Future<File?> getAvatar() async {
    var f = await PathProvider.getPath("chat/avatars/$id");
    var f1 = File("$f.png");
    if (await f1.exists()) {
      return f1;
    } else {
      var f2 = File("$f.jpg");
      if (await f2.exists()) {
        return f2;
      }
      var f3 = File("$f.jpeg");
      if (await f3.exists()) {
        return f3;
      }
    }
    return null;
  }

  String _parameterToJson() {
    Map<String, dynamic> parameters = {
      'model_provider_configure_id': modelProviderConfigureId,
      'system_prompt': systemPrompt,
      'knowledge_bases': knowledgeBases,
      'model_specifics': modelSpecifics.toJson(),
    };
    return jsonEncode(parameters);
  }

  Map<String, dynamic> toDatabaseStorage() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'configure': _parameterToJson(),
      'created_at': createdAt.toIso8601String(),
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory AgentData.fromDatabaseStorage(Map<String, dynamic> map) {
    var parameters = jsonDecode(map['configure']);
    return AgentData(
      id: map['id'] as String,
      name: map['name'] as String,
      modelProviderConfigureId:
          parameters['model_provider_configure_id'] as String,
      modelSpecifics: ModelSpecifics.fromJson(parameters['model_specifics']),
      description: map['description'] as String?,
      systemPrompt: parameters['system_prompt'] as String?,
      knowledgeBases: (parameters['knowledge_bases'] as List<dynamic>)
          .cast<String>(),
      createdAt: DateTime.parse(map['created_at']),
      isDefault: map['is_default'] == 1,
    );
  }

  factory AgentData.fromMap(Map<String, dynamic> map) {
    return AgentData(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      modelSpecifics: ModelSpecifics.fromJson(map['model_specifics']),
      modelProviderConfigureId: map['model_provider_configure_id'],
      systemPrompt: map['system_prompt'],
      knowledgeBases: (map['knowledge_bases'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(map['created_at']),
      isDefault: map['is_default'] == 1,
    );
  }
}

class DatabaseService {
  static final DatabaseService instance = DatabaseService._privateConstructor();
  static Database? _database;
  static const _uuid = Uuid();

  DatabaseService._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbDirectory = p.join(documentsDirectory.path, 'chat');

    // Ensure the directory exists
    await Directory(dbDirectory).create(recursive: true);

    final dbPath = p.join(dbDirectory, 'session_saves.db');

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
    // 新增：创建 agents 表
    await db.execute('''
      CREATE TABLE agents (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        configure TEXT,
        created_at TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('CREATE INDEX idx_agent_name ON agents (name)');

    // 修改：创建 sessions 表，添加 agent_id 和外键
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        agent_id TEXT,
        title TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        modified_at INTEGER NOT NULL,
        agent_override TEXT, -- 可以在会话层面覆盖agents的部分参数类似于 copy with 保留备用
        branch_info TEXT, -- 存储分支信息
        root_info TEXT, -- 存储根信息
        FOREIGN KEY (agent_id) REFERENCES agents (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE message_relations(
      id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      message_id TEXT NOT NULL,
      parent_id TEXT,
      child_ids TEXT,
      is_enabled INTEGER NOT NULL DEFAULT 1, -- 同时只能存在且必须存在一个 
      FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE,
      FOREIGN KEY (message_id) REFERENCES messages (id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_message_relations_session_id ON message_relations (session_id)',
    );
    await db.execute(
      'CREATE INDEX idx_message_relations_message_id ON message_relations (message_id)',
    );

    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        sender TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        attachments TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_data
      id TEXT PRIMARY KEY, -- 此处的prikey和message key 是完全相同的。
      data TEXT,
      persistent_data_props TEXT -- 对话消息级别的持久化储存（只储存指针，数据在persistent_data表中）
      ''');

    await db.execute('''
      CREATE TABLE persistent_data
      id TEXT PRIMARY KEY,
      data TEXT
      ''');

    await db.execute('''
        CREATE TABLE personas (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        content TEXT NOT NULL,
        data TEXT,                  
        is_default INTEGER NOT NULL DEFAULT 0 
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_personas_is_default ON personas (is_default)
      WHERE is_default = 1
    ''');
    await db.execute('''
      CREATE INDEX idx_personas_name ON personas (name)
    ''');

    // 为外键创建索引以提高查询性能
    await db.execute(
      'CREATE INDEX idx_sessions_agent_id ON sessions (agent_id)',
    );
    await db.execute(
      'CREATE INDEX idx_panelLayout_session_id ON panelLayout (session_id)',
    );
    await db.execute(
      'CREATE INDEX idx_attachments_message_id ON attachments (message_id)',
    );
  }

  Future<void> createOrUpdateAgent(AgentData agent) async {
    final db = await database;
    var agentExists = (await db.query(
      'agents',
      where: 'id = ?',
      whereArgs: [agent.id],
      limit: 1,
    )).firstOrNull;
    if (agentExists != null) {
      var d = agent.toDatabaseStorage();
      d.remove('id');
      await db.update('agents', d, where: 'id = ?', whereArgs: [agent.id]);
      return;
    }
    await db.insert('agents', agent.toDatabaseStorage());
  }

  Future<AgentData?> getAgent(String agentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'agents',
      where: 'id = ?',
      whereArgs: [agentId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return AgentData.fromDatabaseStorage(maps.first);
    }

    return null;
  }

  Future<List<AgentData>> getAllAgents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'agents',
      orderBy: 'name ASC',
    );

    return maps.map((map) => AgentData.fromDatabaseStorage(map)).toList();
  }

  Future<void> deleteAgent(String agentId) async {
    final db = await database;
    await db.delete('agents', where: 'id = ?', whereArgs: [agentId]);
  }

  Future<AgentData?> loadDefaultAgent() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'agents',
      where: 'is_default = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return AgentData.fromDatabaseStorage(maps.first);
    }

    // 如果没有默认agent，返回第一个agent作为默认
    final List<Map<String, dynamic>> allAgents = await db.query(
      'agents',
      limit: 1,
    );

    if (allAgents.isNotEmpty) {
      // 将第一个agent设为默认
      await setDefaultAgent(allAgents.first['id'] as String);
      return AgentData.fromDatabaseStorage(allAgents.first);
    }

    return null;
  }

  // 设置默认agent，使用事务保证原子性
  Future<void> setDefaultAgent(String agentId) async {
    final db = await database;
    await db.transaction((txn) async {
      // 步骤1: 将当前所有默认agent设为非默认
      await txn.update(
        'agents',
        {'is_default': 0},
        where: 'is_default = ?',
        whereArgs: [1],
      );

      // 步骤2: 将指定agent设为默认
      final rowsAffected = await txn.update(
        'agents',
        {'is_default': 1},
        where: 'id = ?',
        whereArgs: [agentId],
      );

      if (rowsAffected == 0) {
        throw Exception("Agent with ID $agentId not found.");
      }
    });
  }

  // --- Session CRUD Methods ---

  Future<ChatSession> createSession({
    String? title,
    required String agentId,
  }) async {
    final db = await database;
    final now = DateTime.now();
    final newSession = ChatSession(
      id: _uuid.v4(),
      agentId: agentId,
      name: title ?? 'New Chat - ${now.toIso8601String()}',
      creationTime: now,
      lastMessageTime: now,
    );

    await db.insert('sessions', {
      'id': newSession.id,
      'agent_id': newSession.agentId,
      'title': newSession.name,
      'created_at': newSession.creationTime.microsecondsSinceEpoch,
      'modified_at': newSession.lastMessageTime.microsecondsSinceEpoch,
    });

    return newSession;
  }

  Future<ChatSession?> getSession(String sessionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      // This will require the ChatSession model to be updated
      return ChatSession(
        id: map['id'],
        agentId: map['agent_id'],
        name: map['title'],
        creationTime: DateTime.fromMicrosecondsSinceEpoch(map['created_at']),
        lastMessageTime: DateTime.fromMicrosecondsSinceEpoch(
          map['modified_at'],
        ),
      );
    }

    return null;
  }

  Future<List<ChatSession>> getAllSessionsByAgent(String agentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      where: 'agent_id = ?',
      whereArgs: [agentId],
      orderBy: 'modified_at DESC',
    );
    return maps.map((map) {
      // This will require the ChatSession model to be updated
      return ChatSession(
        id: map['id'],
        agentId: map['agent_id'],
        name: map['title'],
        creationTime: DateTime.fromMicrosecondsSinceEpoch(
          map['created_at'] as int,
        ),
        lastMessageTime: DateTime.fromMicrosecondsSinceEpoch(
          map['modified_at'] as int,
        ),
      );
    }).toList();
  }

  Future<List<ChatSession>> getAllSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sessions',
      orderBy: 'modified_at DESC',
    );
    return maps.map((map) {
      // This will require the ChatSession model to be updated
      return ChatSession(
        id: map['id'],
        agentId: map['agent_id'],
        name: map['title'],
        creationTime: DateTime.fromMicrosecondsSinceEpoch(
          map['created_at'] as int,
        ),
        lastMessageTime: DateTime.fromMicrosecondsSinceEpoch(
          map['modified_at'] as int,
        ),
      );
    }).toList();
  }

  Future<void> updateSessionTitle(String sessionId, String newTitle) async {
    final db = await database;
    await db.update(
      'sessions',
      {'title': newTitle, 'modified_at': DateTime.now().microsecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> deleteSession(String sessionId) async {
    final db = await database;
    await db.delete('sessions', where: 'id = ?', whereArgs: [sessionId]);
  }

  // --- Message & Attachment CRUD Methods ---

  Future<void> addMessage(
    String sessionId,
    int sessionOrder,
    ChatMessageDisplay message,
    Map<String, ChatFile> uploadedFiles,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('messages', {
        'id': message.content.id,
        'sender': message.content.sender
            .toString()
            .split('.')
            .last, // 'message.contentSender.user' -> 'user'
        'content': message.content.content,
        'timestamp': message.content.timestamp.microsecondsSinceEpoch,
      });
      // 2. Insert or update attachments
      if (message.content.attachedFiles != null) {
        for (final fileId in message.content.attachedFiles!) {
          final attachmentFile = uploadedFiles[fileId];
          if (attachmentFile != null) {
            await _addOrUpdateAttachment(
              txn,
              message.content.id,
              attachmentFile,
            );
          }
        }
      }
      var messageOrder = message.currentMessageNo;
      //当这不是第一条消息时，我们可以断定先前有消息是原来的默认消息，需要修改当前消息为默认
      if (messageOrder != 0) {
        await txn.update(
          'message_relations',
          {'is_enabled': 0},
          where: 'session_id = ? AND is_enabled = 1',
          whereArgs: [sessionId],
        );
      }
      // 现在插入新的relation，由于数据库默认插入的时候is enabled = 1 所以不用额外修改
      await txn.insert('message_relations', {
        'session_id': sessionId,
        'message_id': message.content.id,
        'session_order': sessionOrder,
        'message_order': messageOrder,
      });
      await txn.update(
        'sessions',
        {'modified_at': DateTime.now().microsecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [sessionId],
      );
    });
  }

  Future<ChatMessageDisplay> selectAndUpdateMessage(
    String sessionId,
    int order,
    int messageOrder,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> messageMaps = await db.rawQuery(
      '''SELECT
    T1.id AS message_id,
    T1.sender,
    T1.content,
    T1.timestamp,
    T2.id as relation_id
FROM
    messages T1
JOIN
    message_relations T2 ON T1.id = T2.message_id
WHERE
    T2.session_id = ? AND T2.session_order = ? AND T2.message_order = ?;''',
      [sessionId, order, messageOrder],
    );
    final messageMap = messageMaps.first;
    var id = messageMap['message_id'] as String;
    final attachments = await _getAttachmentsForMessage(db, id);
    final Map<String, ChatFile> files = {};
    final attachmentIds = <String>[];

    for (final attachment in attachments) {
      files[attachment.name] = attachment;
      attachmentIds.add(attachment.name);
    }
    //将新的消息设置为默认
    await db.transaction((trx) async {
      await trx.update(
        'sessions',
        {'is_enabled': 0},
        where: 'session_id = ? AND is_enabled = 1',
        whereArgs: [sessionId],
      );
      await trx.update(
        'message_relations',
        {'is_enabled': 1},
        where: 'id = ?',
        whereArgs: [messageMap['relation_id'] as int],
      );
    });

    return ChatMessageDisplay(
      content: ChatMessage(
        id: id,
        sender: MessageSender.values.firstWhere(
          (e) => e.toString().split('.').last == messageMap['sender'],
        ),
        content: messageMap['content'],
        timestamp: DateTime.fromMicrosecondsSinceEpoch(
          messageMap['timestamp'] as int,
        ),
        attachedFiles: attachmentIds.isNotEmpty ? attachmentIds : null,
      ),
    );
  }

  Future<(List<ChatMessageDisplay>, Map<String, ChatFile>)>
  getMessagesForSession(String sessionId, {bool onlyEnabled = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> messageMaps = await db.rawQuery(
      '''SELECT
    T1.id AS message_id,
    T1.sender,
    T1.content,
    T1.timestamp,
    T2.message_order,
    T3.total_message_count
FROM
    messages T1
JOIN
    message_relations T2 ON T1.id = T2.message_id
JOIN 
    (
        SELECT 
            message_id, 
            COUNT(*) AS total_message_count 
        FROM 
            message_relations 
        GROUP BY 
            message_id
    ) T3 ON T1.id = T3.message_id
WHERE
    T2.session_id = ? AND T2.is_enabled = 1
ORDER BY
    T2.session_order ASC;''',
      [sessionId],
    );

    final List<ChatMessageDisplay> messages = [];
    final Map<String, ChatFile> files = {};

    for (final messageMap in messageMaps) {
      final messageId = messageMap['message_id'] as String;
      final attachments = await _getAttachmentsForMessage(db, messageId);
      final attachmentIds = <String>[];

      for (final attachment in attachments) {
        files[attachment.name] = attachment;
        attachmentIds.add(attachment.name);
      }

      messages.add(
        ChatMessageDisplay(
          currentMessageNo: messageMap['message_order'] as int,
          totalMessageCount: messageMap['total_message_count'] as int,
          content: ChatMessage(
            id: messageId,
            sender: MessageSender.values.firstWhere(
              (e) => e.toString().split('.').last == messageMap['sender'],
            ),
            content: messageMap['content'],
            timestamp: DateTime.fromMicrosecondsSinceEpoch(
              messageMap['timestamp'] as int,
            ),
            attachedFiles: attachmentIds.isNotEmpty ? attachmentIds : null,
          ),
        ),
      );
    }

    return (messages, files);
  }

  // --- Private helper methods for attachments ---

  Future<void> _addOrUpdateAttachment(
    Transaction txn,
    String messageId,
    ChatFile attachment,
  ) async {
    final serializableProviderInfo = attachment.providerInfo.map(
      (key, value) =>
          MapEntry(key, {'id': value.$1, 'expiry': value.$2.toIso8601String()}),
    );

    await txn.insert('attachments', {
      'id': attachment.name, // The 'name' field is the UUID
      'message_id': messageId,
      'original_name': attachment.original_name,
      'upload_time': attachment.uploadTime.toIso8601String(),
      'provider_info': jsonEncode(serializableProviderInfo),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ChatFile>> _getAttachmentsForMessage(
    Database db,
    String messageId,
  ) async {
    final List<Map<String, dynamic>> attachmentMaps = await db.query(
      'attachments',
      where: 'message_id = ?',
      whereArgs: [messageId],
    );

    if (attachmentMaps.isEmpty) {
      return [];
    }

    return attachmentMaps.map((map) {
      final providerInfoString = map['provider_info'] as String?;
      Map<String, (String, DateTime)> providerInfo = {};

      if (providerInfoString != null && providerInfoString.isNotEmpty) {
        final decodedInfo =
            jsonDecode(providerInfoString) as Map<String, dynamic>;
        providerInfo = decodedInfo.map((key, value) {
          final infoMap = value as Map<String, dynamic>;
          return MapEntry(key, (
            infoMap['id'] as String,
            DateTime.parse(infoMap['expiry'] as String),
          ));
        });
      }

      return ChatFile(
        name: map['id'],
        original_name: map['original_name'],
        uploadTime: DateTime.fromMicrosecondsSinceEpoch(map['upload_time']),
        providerInfo: providerInfo,
      );
    }).toList();
  }

  Future<void> writeLayout(String sessionId, String layoutInfo) async {
    final db = await database;

    // 检查是否已存在对应 session_id 的记录
    final List<Map<String, dynamic>> existingRecords = await db.query(
      'panelLayout',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );

    if (existingRecords.isNotEmpty) {
      // 如果存在记录，则更新 layout_info
      await db.update(
        'panelLayout',
        {'layout_info': layoutInfo},
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );
    } else {
      // 如果不存在记录，则创建新记录
      await db.insert('panelLayout', {
        'id': _uuid.v4(), // 生成新的 UUID 作为主键
        'session_id': sessionId,
        'layout_info': layoutInfo,
      });
    }
  }

  Future<String?> readLayout(String sessionId) async {
    final db = await database;
    final List<Map<String, dynamic>> records = await db.query(
      'panelLayout',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );

    if (records.isNotEmpty) {
      return records.first['layout_info'] as String?;
    } else {
      return null;
    }
  }

  // --- 1. Create (创建) ---
  Future<void> createOrUpdatePersona(Persona persona) async {
    final db = await database;
    await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query(
        "personas",
        where: 'id = ?',
        whereArgs: [persona.id],
        limit: 1,
      );

      // 如果要创建默认的，则先将所有默认的设为非默认
      if (persona.isDefault) {
        final List<Map<String, dynamic>> defaultMaps = await txn.query(
          "personas",
          where: 'is_default = ?',
          whereArgs: [1],
          limit: 1,
        );
        if (defaultMaps.isNotEmpty) {
          await txn.update(
            "personas",
            {'is_default': 0},
            where: 'id = ?',
            whereArgs: [defaultMaps.first['id']],
          );
        }
      }

      if (maps.isNotEmpty) {
        // 如果已存在，则更新
        await txn.update(
          "personas",
          persona.toMap(),
          where: 'id = ?',
          whereArgs: [persona.id],
        );
      } else {
        await txn.insert(
          "personas",
          persona.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // --- 2. Read (读取所有) ---
  Future<List<Persona>> getAllPersonas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query("personas");

    return List.generate(maps.length, (i) {
      return Persona.fromMap(maps[i]);
    });
  }

  Future<Persona?> getPersonaById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      "personas",
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Persona.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // --- 4. Delete (删除) ---
  Future<void> deletePersona(String id) async {
    final db = await database;
    await db.delete("personas", where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------------------
  // --- 5. Load Default (加载默认项) ---
  // ------------------------------------
  Future<Persona?> getDefaultPersona() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      "personas",
      where: 'is_default = ?',
      whereArgs: [1], // 查找 is_default 为 1 的记录
      limit: 1, // 理论上只应该有一条
    );

    if (maps.isNotEmpty) {
      return Persona.fromMap(maps.first);
    } else {
      //当默认没有时，同时如果存在项的时候返回第一个作为默认
      final List<Map<String, dynamic>> maps = await db.query("personas");
      if (maps.isNotEmpty) {
        //将其设置为默认
        await setPersonaAsDefault(maps.first['id']);
        return Persona.fromMap(maps.first);
      }
    }
    return null;
  }

  // ------------------------------------
  // --- 6. Set Default (设置默认项) ---
  // ------------------------------------
  Future<void> setPersonaAsDefault(String personaId) async {
    // 确保整个操作是原子的（要么都成功，要么都失败），防止出现多个默认项
    final db = await database;
    await db.transaction((txn) async {
      // 步骤 1: 将所有现有的默认项设置为非默认 (0)
      await txn.update(
        "personas",
        {'is_default': 0},
        where: 'is_default = ?',
        whereArgs: [1],
      );

      // 步骤 2: 将指定的 Persona 设置为默认 (1)
      final rowsAffected = await txn.update(
        "personas",
        {'is_default': 1},
        where: 'id = ?',
        whereArgs: [personaId],
      );

      if (rowsAffected == 0) {
        // 可以在这里处理一个错误，比如要设置的 ID 不存在
        throw Exception("Persona with ID $personaId not found.");
      }
    });
  }
}
