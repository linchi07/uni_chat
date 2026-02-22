import 'dart:convert';
import 'package:drift/drift.dart';
import '../Chat/chat_models.dart';
import '../Persona/persona_provider.dart';

class StringMapConverter extends TypeConverter<Map<String, dynamic>, String> {
  const StringMapConverter();
  @override
  Map<String, dynamic> fromSql(String fromDb) =>
      jsonDecode(fromDb) as Map<String, dynamic>;
  @override
  String toSql(Map<String, dynamic> value) => jsonEncode(value);
}

class ChatAttachmentsConverter extends TypeConverter<List<ChatFile>, String> {
  const ChatAttachmentsConverter();
  @override
  List<ChatFile> fromSql(String fromDb) {
    if (fromDb.trim() == 'null' || fromDb.isEmpty) return [];
    var dec = jsonDecode(fromDb);
    if (dec is List && dec.isNotEmpty) {
      return dec
          .map((e) => ChatFile.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  String toSql(List<ChatFile> value) =>
      jsonEncode(value.map((e) => e.toMap()).toList());
}

class PersonaDataConverter
    extends TypeConverter<Map<String, PersonaDataEntry>, String> {
  const PersonaDataConverter();
  @override
  Map<String, PersonaDataEntry> fromSql(String fromDb) {
    if (fromDb.trim() == 'null' || fromDb.isEmpty) return {};
    var dec = jsonDecode(fromDb) as Map<String, dynamic>;
    return dec.map(
      (key, value) => MapEntry(
        key,
        PersonaDataEntry.fromMap(value as Map<String, dynamic>),
      ),
    );
  }

  @override
  String toSql(Map<String, PersonaDataEntry> value) {
    return jsonEncode(value.map((key, val) => MapEntry(key, val.toMap())));
  }
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();
  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return fromDb.split(',');
  }

  @override
  String toSql(List<String> value) {
    if (value.isEmpty) return '';
    return value.join(',');
  }
}

@DataClassName('AgentDbModel')
@TableIndex(name: 'idx_agent_name', columns: {#name})
class Agents extends Table {
  TextColumn get id => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get configure => text()();
  TextColumn get createdAt => text().named('created_at')();
  BoolColumn get isDefault =>
      boolean().named('is_default').withDefault(const Constant(false))();
}

@DataClassName('SessionDbModel')
@TableIndex(name: 'idx_sessions_agent_id', columns: {#agentId})
class Sessions extends Table {
  TextColumn get id => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get agentId => text()
      .named('agent_id')
      .nullable()
      .references(Agents, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get modifiedAt => dateTime().named('modified_at')();
  TextColumn get agentOverride => text().named('agent_override').nullable()();
  TextColumn get personaId => text().named('persona_id').nullable()();
  TextColumn get branchInfo => text().named('branch_info').nullable()();
}

@DataClassName('MessageDbModel')
class Messages extends Table {
  TextColumn get id => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get sender => text()();
  TextColumn get senderId => text().named('sender_id')();
  TextColumn get content => text()();
  TextColumn get data => text().nullable().map(const StringMapConverter())();
  TextColumn get persistentDataPointer =>
      text().named('persistent_data_pointer').nullable()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get attachments =>
      text().nullable().map(const ChatAttachmentsConverter())();
}

@DataClassName('MessageRelationDbModel')
@TableIndex(name: 'idx_message_relations_session_id', columns: {#sessionId})
@TableIndex(name: 'idx_message_relations_message_id', columns: {#messageId})
class MessageRelations extends Table {
  TextColumn get id => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get sessionId => text()
      .named('session_id')
      .references(Sessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get messageId => text()
      .named('message_id')
      .nullable()
      .references(Messages, #id, onDelete: KeyAction.cascade)();
  TextColumn get parentId => text().named('parent_id').nullable()();
  TextColumn get childIds =>
      text().named('child_ids').nullable().map(const StringListConverter())();
  IntColumn get enabledChildIndex => integer()
      .named('enabled_child_index')
      .withDefault(const Constant(0))
      .nullable()();
}

class PersistentData extends Table {
  @override
  String get tableName => 'persistent_data';

  TextColumn get id => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get data => text().nullable()();
}

@DataClassName('PersonaDbModel')
@TableIndex(name: 'idx_personas_is_default', columns: {#isDefault})
@TableIndex(name: 'idx_personas_name', columns: {#name})
class Personas extends Table {
  TextColumn get id => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get name => text()();
  TextColumn get content => text()();
  TextColumn get data => text().nullable().map(const PersonaDataConverter())();
  BoolColumn get isDefault =>
      boolean().named('is_default').withDefault(const Constant(false))();
}
