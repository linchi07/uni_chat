import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uni_chat/Agent/agentProvider.dart';
import 'package:uuid/uuid.dart';

import '../Chat/chat_models.dart';
import '../Persona/persona_provider.dart';

class AgentData {
  final String id;
  final String name;
  final String modelProviderConfigureId;
  final String? description;
  final String? systemPrompt;
  final String? knowledgeBases;
  final ModelSpecifics modelSpecifics;
  final DateTime createdAt;

  AgentData({
    required this.id,
    required this.name,
    required this.modelProviderConfigureId,
    required this.modelSpecifics,
    this.description,
    this.systemPrompt,
    this.knowledgeBases,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'system_prompt': systemPrompt,
      'knowledge_bases': knowledgeBases,
      'created_at': createdAt.toIso8601String(),
    };
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
      createdAt: DateTime.parse(map['created_at']),
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
      knowledgeBases: map['knowledge_bases'],
      createdAt: DateTime.parse(map['created_at']),
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
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_agent_name ON agents (name)');

    // 修改：创建 sessions 表，添加 agent_id 和外键
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        agent_id TEXT,
        title TEXT NOT NULL,
        created_at TEXT NOT NULL,
        modified_at TEXT NOT NULL,
        FOREIGN KEY (agent_id) REFERENCES agents (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        sender TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE attachments (
        id TEXT PRIMARY KEY,
        message_id TEXT NOT NULL,
        original_name TEXT NOT NULL,
        upload_time TEXT NOT NULL,
        provider_info TEXT,
        FOREIGN KEY (message_id) REFERENCES messages (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE panelLayout (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        layout_info TEXT,
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE
      )
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
      'CREATE INDEX idx_messages_session_id ON messages (session_id)',
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

  // --- Session CRUD Methods ---

  Future<ChatSession> createSession({
    String? title,
    required String agentId,
  }) async {
    final db = await database;
    final now = DateTime.now();
    // Note: The ChatSession model will need to be updated to include agentId
    final newSession = ChatSession(
      id: _uuid.v4(),
      agentId: agentId, // This will require a model change
      name: title ?? 'New Chat - ${now.toIso8601String()}',
      creationTime: now,
      lastMessageTime: now,
    );

    await db.insert('sessions', {
      'id': newSession.id,
      'agent_id': newSession.agentId,
      'title': newSession.name,
      'created_at': newSession.creationTime.toIso8601String(),
      'modified_at': newSession.lastMessageTime.toIso8601String(),
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
        creationTime: DateTime.parse(map['created_at']),
        lastMessageTime: DateTime.parse(map['modified_at']),
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
        creationTime: DateTime.parse(map['created_at']),
        lastMessageTime: DateTime.parse(map['modified_at']),
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
        creationTime: DateTime.parse(map['created_at']),
        lastMessageTime: DateTime.parse(map['modified_at']),
      );
    }).toList();
  }

  Future<void> updateSessionTitle(String sessionId, String newTitle) async {
    final db = await database;
    await db.update(
      'sessions',
      {'title': newTitle, 'modified_at': DateTime.now().toIso8601String()},
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
    ChatMessage message,
    Map<String, ChatFile> uploadedFiles,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      // 1. Insert the message
      await txn.insert('messages', {
        'id': message.id,
        'session_id': sessionId,
        'sender': message.sender
            .toString()
            .split('.')
            .last, // 'MessageSender.user' -> 'user'
        'content': message.content,
        'timestamp': message.timestamp.toIso8601String(),
      });

      // 2. Insert or update attachments
      if (message.attachedFiles != null) {
        for (final fileId in message.attachedFiles!) {
          final attachmentFile = uploadedFiles[fileId];
          if (attachmentFile != null) {
            await _addOrUpdateAttachment(txn, message.id, attachmentFile);
          }
        }
      }
    });
    // Update session's modified_at timestamp
    await db.update(
      'sessions',
      {'modified_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<(List<ChatMessage>, Map<String, ChatFile>)> getMessagesForSession(
    String sessionId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> messageMaps = await db.query(
      'messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );

    final List<ChatMessage> messages = [];
    final Map<String, ChatFile> files = {};

    for (final messageMap in messageMaps) {
      final messageId = messageMap['id'] as String;
      final attachments = await _getAttachmentsForMessage(db, messageId);
      final attachmentIds = <String>[];

      for (final attachment in attachments) {
        files[attachment.name] = attachment;
        attachmentIds.add(attachment.name);
      }

      messages.add(
        ChatMessage(
          id: messageId,
          sender: MessageSender.values.firstWhere(
            (e) => e.toString().split('.').last == messageMap['sender'],
          ),
          content: messageMap['content'],
          timestamp: DateTime.parse(messageMap['timestamp']),
          attachedFiles: attachmentIds.isNotEmpty ? attachmentIds : null,
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
        uploadTime: DateTime.parse(map['upload_time']),
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
