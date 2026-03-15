import 'package:drift/drift.dart' hide Column;
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uni_chat/error_handling.dart';
import 'package:uuid/uuid.dart';

import '../Agent/agent_models.dart';
import '../Chat/chat_models.dart';
import '../Persona/persona_provider.dart';
import '../utils/file_utils.dart';
import 'chat_tables.dart';

part 'database_service.g.dart';

@DriftDatabase(
  tables: [
    Agents,
    Sessions,
    MessageRelations,
    Messages,
    PersistentData,
    Personas,
  ],
)
class _ChatDb extends _$_ChatDb {
  _ChatDb() : super(_onOpen());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _onOpen() {
    return driftDatabase(
      name: 'chat_session_saves',
      native: DriftNativeOptions(
        databasePath: () async {
          return await PathProvider.getPath("chat/session_saves.db");
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
      },
      onUpgrade: (mig, from, to) async {
        if (from > to) {
          throw DatabaseDowngradeException("chat_session_saves.db", from, to);
        }
      },
    );
  }
}

class DatabaseService {
  static final DatabaseService instance = DatabaseService._privateConstructor();
  late final _ChatDb _db;
  static const _uuid = Uuid();

  DatabaseService._privateConstructor() {
    _db = _ChatDb();
  }

  Future<void> init() async {
    await _db.customSelect('SELECT 1').get();
  }

  // --- Agent CRUD ---
  Future<void> createOrUpdateAgent(AgentData agent) async {
    await _db.into(_db.agents).insert(agent, mode: InsertMode.insertOrReplace);
  }

  Future<AgentData?> getAgent(String agentId) async {
    var agentDb = await (_db.select(
      _db.agents,
    )..where((t) => t.id.equals(agentId))).getSingleOrNull();
    if (agentDb != null) {
      return AgentData.fromAgentDBModel(agentDb);
    }
    return null;
  }

  Future<List<AgentData>> getAllAgents() async {
    final list = await (_db.select(
      _db.agents,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    return list.map((e) => AgentData.fromAgentDBModel(e)).toList();
  }

  Future<void> deleteAgent(String agentId) async {
    await (_db.delete(_db.agents)..where((t) => t.id.equals(agentId))).go();
  }

  Future<AgentData?> loadDefaultAgent() async {
    var a =
        await (_db.select(_db.agents)
              ..where((t) => t.isDefault)
              ..limit(1))
            .getSingleOrNull();
    if (a != null) return AgentData.fromAgentDBModel(a);

    var any = await (_db.select(_db.agents)..limit(1)).getSingleOrNull();
    if (any != null) {
      await setDefaultAgent(any.id);
      return AgentData.fromAgentDBModel(any);
    }
    return null;
  }

  Future<void> setDefaultAgent(String agentId) async {
    await _db.transaction(() async {
      await (_db.update(_db.agents)..where((t) => t.isDefault)).write(
        const AgentsCompanion(isDefault: Value(true)),
      );
      await (_db.update(_db.agents)..where((t) => t.id.equals(agentId))).write(
        const AgentsCompanion(isDefault: Value(true)),
      );
    });
  }

  // --- Session CRUD ---
  Future<ChatSession> createSession({
    required ChatSession newSession,
    required ChatMessage root,
    ChatMessage? opening,
  }) async {
    var m1 = SessionDbModel(
      id: newSession.id,
      agentId: newSession.agentId,
      title: newSession.name,
      createdAt: newSession.creationTime,
      modifiedAt: newSession.lastMessageTime,
      personaId: newSession.persona,
      branchInfo: newSession.branchInfo?.toJsonString(),
    );
    var m2 = MessageRelationDbModel(
      id: root.id, // root relation has id == sessionId
      sessionId: newSession.id,
      childIds: root.childIds,
      enabledChildIndex: root.enabledChild,
    );
    dynamic m3, m4;
    if (opening != null) {
      m3 = MessageDbModel(
        id: opening.messageId!,
        sender: opening.sender.name,
        senderId: opening.senderId,
        content: opening.content,
        timestamp: opening.timestamp,
        data: opening.data,
        attachments: opening.attachedFiles,
      );
      m4 = MessageRelationDbModel(
        id: opening.id,
        sessionId: newSession.id,
        messageId: opening.messageId,
        parentId: opening.parent,
        childIds: opening.childIds,
        enabledChildIndex: opening.enabledChild,
      );
      await _db.transaction(() async {});
    }
    // avoid the data race condition when doing async operations
    await _db.transaction(() async {
      await _db.into(_db.sessions).insert(m1);
      await _db.into(_db.messageRelations).insert(m2);
      if (opening != null) {
        await _db.into(_db.messages).insert(m3);
        await _db.into(_db.messageRelations).insert(m4);
      }
    });
    return newSession;
  }

  Future<ChatSession?> getSession(String sessionId) async {
    var session = await (_db.select(
      _db.sessions,
    )..where((t) => t.id.equals(sessionId))).getSingleOrNull();
    if (session != null) return ChatSession.fromSessionDbModel(session);
    return null;
  }

  Future<List<ChatSession>> getAllSessionsByAgent(String agentId) async {
    final list =
        await (_db.select(_db.sessions)
              ..where((t) => t.agentId.equals(agentId))
              ..orderBy([(t) => OrderingTerm.desc(t.modifiedAt)]))
            .get();
    return list.map((e) => ChatSession.fromSessionDbModel(e)).toList();
  }

  Future<List<ChatSession>> getAllSessions() async {
    final list = await (_db.select(
      _db.sessions,
    )..orderBy([(t) => OrderingTerm.desc(t.modifiedAt)])).get();
    return list.map((e) => ChatSession.fromSessionDbModel(e)).toList();
  }

  Future<List<({String id, String title})>> getSessionTitles(
    List<String> sessionIds,
  ) async {
    if (sessionIds.isEmpty) return [];
    final query = _db.select(_db.sessions)..where((t) => t.id.isIn(sessionIds));
    final results = await query.get();
    return [for (var row in results) (id: row.id, title: row.title)];
  }

  Future<void> updateSessionTitle(String sessionId, String newTitle) async {
    await (_db.update(
      _db.sessions,
    )..where((t) => t.id.equals(sessionId))).write(
      SessionsCompanion(
        title: Value(newTitle),
        modifiedAt: Value(DateTime.now()),
      ),
    );
  }

  /// When we branch from a specific message, what we actually want is to make sure the branch we are currently on is copied until the branch message.
  /// So the excluded message ids are those behind the message we branch which are on the same branch.
  Future<ChatSession?> branchSessionFromMessage(
    String originSessionId,
    String branchMessageId,
    String newTitle,
  ) async {
    ChatSession? session = await getSession(originSessionId);
    if (session == null) return null;

    final query = _db.select(_db.messageRelations)
      ..where((t) => t.sessionId.equals(originSessionId));
    final relations = await query.get();

    // We only create branch session
    final now = DateTime.now();
    final newSessionId = _uuid.v7();

    BranchInfo targetBranchInfo = BranchInfo(
      origin: BranchInfoData(
        sessionId: originSessionId,
        messageId: branchMessageId,
      ),
    );

    final newSession = ChatSession(
      id: newSessionId,
      agentId: session.agentId,
      persona: session.persona,
      name: newTitle,
      creationTime: now,
      lastMessageTime: now,
      branchInfo: targetBranchInfo,
    );

    var m1 = SessionDbModel(
      id: newSession.id,
      agentId: newSession.agentId,
      title: newSession.name,
      createdAt: newSession.creationTime,
      modifiedAt: newSession.lastMessageTime,
      personaId: newSession.persona,
      branchInfo: newSession.branchInfo?.toJsonString(),
    );

    // Update origin session's branch info
    BranchInfo originBranchInfo = session.branchInfo ?? BranchInfo();
    originBranchInfo.branches.add(
      BranchInfoData(sessionId: newSessionId, messageId: branchMessageId),
    );

    Map<String, MessageRelationDbModel> relMap = {
      for (var rel in relations) rel.id: rel,
    };
    MessageRelationDbModel? branchPointRelation;

    for (var rel in relations) {
      if (rel.messageId == branchMessageId) {
        branchPointRelation = rel;
        break;
      }
    }

    if (branchPointRelation == null) {
      return null;
    }

    // Determine descendants of branchPointRelation to discard
    Set<String> descendantsToDiscard = {};
    List<String> queue = List.from(branchPointRelation.childIds ?? []);
    while (queue.isNotEmpty) {
      var cur = queue.removeLast();
      descendantsToDiscard.add(cur);
      var children = relMap[cur]?.childIds ?? [];
      queue.addAll(children);
    }

    // Determine path from root to branchPoint to update active branches
    Set<String> pathToBranchPoint = {branchPointRelation.id};
    String? currentParent = branchPointRelation.parentId;
    while (currentParent != null) {
      pathToBranchPoint.add(currentParent);
      currentParent = relMap[currentParent]?.parentId;
    }

    // duplicate all kept relations using a map
    Map<String, String> oldToNewRelationId = {};
    for (var rel in relations) {
      if (!descendantsToDiscard.contains(rel.id)) {
        oldToNewRelationId[rel.id] = _uuid.v7();
      }
    }

    // copy the relations into new objects
    List<MessageRelationDbModel> newRelations = [];

    for (var rel in relations) {
      if (descendantsToDiscard.contains(rel.id)) continue;

      List<String> childIdsList = [];
      var enableIdx = 0;
      if (rel.childIds != null && rel.childIds!.isNotEmpty) {
        var oldSelected =
            rel.enabledChildIndex != null &&
                rel.enabledChildIndex! < rel.childIds!.length
            ? rel.childIds![rel.enabledChildIndex!]
            : null;

        bool isAnyChildInPath = false;
        for (var oldChild in rel.childIds!) {
          var nId = oldToNewRelationId[oldChild];
          if (nId != null) {
            childIdsList.add(nId);

            // Auto-select the child if it's on the path to the branch point
            if (pathToBranchPoint.contains(oldChild)) {
              enableIdx = childIdsList.length - 1;
              isAnyChildInPath = true;
            } else if (!isAnyChildInPath && oldSelected == oldChild) {
              enableIdx = childIdsList.length - 1;
            }
          }
        }
      }

      var newRel = rel.copyWith(
        id: oldToNewRelationId[rel.id],
        sessionId: newSessionId,
        parentId: Value(
          rel.parentId == null ? null : oldToNewRelationId[rel.parentId],
        ),
        childIds: Value(childIdsList.isEmpty ? null : childIdsList),
        enabledChildIndex: Value(childIdsList.isEmpty ? null : enableIdx),
      );
      newRelations.add(newRel);
    }

    await _db.transaction(() async {
      // 1. insert new session
      await _db.into(_db.sessions).insert(m1);

      // 2. insert all new relations
      await _db.batch((batch) {
        batch.insertAll(_db.messageRelations, newRelations);
      });

      // 3. update origin session branch info
      await (_db.update(
        _db.sessions,
      )..where((t) => t.id.equals(originSessionId))).write(
        SessionsCompanion(branchInfo: Value(originBranchInfo.toJsonString())),
      );
    });

    return newSession;
  }

  Future<void> deleteSession(String sessionId) async {
    await (_db.delete(_db.sessions)..where((t) => t.id.equals(sessionId))).go();
  }

  Future<void> updateActiveIndex(String id, int newIndex) async {
    await (_db.update(_db.messageRelations)..where((t) => t.id.equals(id)))
        .write(MessageRelationsCompanion(enabledChildIndex: Value(newIndex)));
  }

  // --- Message CRUD ---
  Future<void> addMessage(
    String sessionId,
    ChatMessage message, {
    ChatMessage? modifiedParent,
  }) async {
    var m1 = MessageDbModel(
      id: message.messageId!,
      sender: message.sender.name,
      senderId: message.senderId,
      content: message.content,
      timestamp: message.timestamp,
      data: message.data,
      attachments: message.attachedFiles,
    );
    var m2 = MessageRelationDbModel(
      id: message.id,
      sessionId: sessionId,
      messageId: message.messageId,
      parentId: message.parent,
      childIds: message.childIds,
      enabledChildIndex: message.enabledChild,
    );
    dynamic m3;
    if (modifiedParent != null) {
      m3 = MessageRelationsCompanion(
        childIds: Value(modifiedParent.childIds),
        enabledChildIndex: Value(modifiedParent.enabledChild),
      );
    }
    await _db.transaction(() async {
      await _db.into(_db.messages).insert(m1);
      await _db.into(_db.messageRelations).insert(m2);
      if (modifiedParent != null) {
        await (_db.update(
          _db.messageRelations,
        )..where((t) => t.id.equals(modifiedParent.id))).write(m3);
      }
      await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId)))
          .write(SessionsCompanion(modifiedAt: Value(DateTime.now())));
    });
  }

  Future<({ChatMessage? root, Map<String, ChatMessage> messages})>
  getMessagesForSession(String sessionId) async {
    final query = _db.select(_db.messageRelations).join([
      leftOuterJoin(
        _db.messages,
        _db.messages.id.equalsExp(_db.messageRelations.messageId),
      ),
    ])..where(_db.messageRelations.sessionId.equals(sessionId));

    final rows = await query.get();
    if (rows.isEmpty) return (root: null, messages: <String, ChatMessage>{});

    var result = <String, ChatMessage>{};
    ChatMessage? root;
    for (final row in rows) {
      var rel = row.readTable(_db.messageRelations);
      var msg = row.readTableOrNull(_db.messages);
      var obj = ChatMessage(
        id: rel.id,
        messageId: msg?.id,
        parent: rel.parentId,
        childIds: rel.childIds ?? [],
        sender: MessageSenderExtension.fromString(msg?.sender ?? 'internal'),
        data: msg?.data,
        senderId: msg?.senderId ?? '',
        attachedFiles: msg?.attachments,
        content: msg?.content ?? '',
        timestamp: msg?.timestamp ?? DateTime.now(),
        enabledChild: rel.enabledChildIndex ?? 0,
      );
      if (obj.parent == null) {
        root = obj;
      }
      result[obj.id] = obj;
    }
    if (root == null) {
      throw ChatException(
        ChatExceptionType.failParsingMessage,
        message: 'No root message found , data is corrupted',
      );
    }
    return (root: root, messages: result);
  }

  Future<List<ChatMessage>> getMessageListForSession(String sessionId) async {
    final sql = '''
WITH RECURSIVE chat_tree AS (
    SELECT 
        id, 
        message_id,
        child_ids, 
        enabled_child_index,
        0 AS depth
    FROM message_relations
    WHERE session_id = ? AND parent_id IS NULL

    UNION ALL

    SELECT 
        r.id,
        r.message_id,
        r.child_ids,
        r.enabled_child_index,
        ct.depth + 1
    FROM message_relations r
    JOIN chat_tree ct ON r.id = substr(
        ct.child_ids, 
        (ct.enabled_child_index * 37) + 1, 
        36
    )
    WHERE r.session_id = ?
)
SELECT 
    m.id AS message_id,
    m.sender,
    m.sender_id,
    m.content,
    m.timestamp,
    m.attachments,
    t.id AS id,
    t.child_ids,
    t.enabled_child_index
FROM chat_tree t
JOIN messages m ON t.message_id = m.id
WHERE t.depth > 0
ORDER BY t.depth DESC;
''';
    // the previewed message do not need the "data" or "attachments" field

    final rows = await _db
        .customSelect(
          sql,
          variables: [
            Variable.withString(sessionId),
            Variable.withString(sessionId),
          ],
        )
        .get();

    return rows.map((row) => ChatMessage.fromMap(row.data)).toList();
  }

  // --- Persona CRUD ---
  Future<void> createOrUpdatePersona(Persona persona) async {
    await _db.transaction(() async {
      if (persona.isDefault) {
        await (_db.update(_db.personas)..where((t) => t.isDefault)).write(
          const PersonasCompanion(isDefault: Value(false)),
        );
      }
      await _db
          .into(_db.personas)
          .insert(
            PersonaDbModel(
              id: persona.id,
              name: persona.name,
              content: persona.content,
              data: persona.data,
              isDefault: persona.isDefault,
            ),
            mode: InsertMode.insertOrReplace,
          );
    });
  }

  Future<List<Persona>> getAllPersonas() async {
    final maps = await _db.select(_db.personas).get();
    return maps.map((map) => Persona.fromDBModel(map)).toList();
  }

  Future<Persona?> getPersonaById(String id) async {
    final map = await (_db.select(
      _db.personas,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (map != null) return Persona.fromDBModel(map);
    return null;
  }

  Future<void> deletePersona(String id) async {
    await (_db.delete(_db.personas)..where((t) => t.id.equals(id))).go();
  }

  Future<Persona?> getDefaultPersona() async {
    final map =
        await (_db.select(_db.personas)
              ..where((t) => t.isDefault)
              ..limit(1))
            .getSingleOrNull();
    if (map != null) return Persona.fromDBModel(map);

    final any = await (_db.select(_db.personas)..limit(1)).getSingleOrNull();
    if (any != null) {
      await setPersonaAsDefault(any.id);
      return Persona.fromDBModel(any);
    }
    return null;
  }

  Future<void> setPersonaAsDefault(String personaId) async {
    await _db.transaction(() async {
      await (_db.update(_db.personas)..where((t) => t.isDefault)).write(
        const PersonasCompanion(isDefault: Value(false)),
      );

      final rowsAffected =
          await (_db.update(_db.personas)..where((t) => t.id.equals(personaId)))
              .write(const PersonasCompanion(isDefault: Value(true)));

      if (rowsAffected == 0) {
        throw PersonaException(PersonaExceptionType.personaNotFound);
      }
    });
  }
}
