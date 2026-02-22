// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_service.dart';

// ignore_for_file: type=lint
class $AgentsTable extends Agents with TableInfo<$AgentsTable, AgentDbModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _configureMeta = const VerificationMeta(
    'configure',
  );
  @override
  late final GeneratedColumn<String> configure = GeneratedColumn<String>(
    'configure',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    configure,
    createdAt,
    isDefault,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agents';
  @override
  VerificationContext validateIntegrity(
    Insertable<AgentDbModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('configure')) {
      context.handle(
        _configureMeta,
        configure.isAcceptableOrUnknown(data['configure']!, _configureMeta),
      );
    } else if (isInserting) {
      context.missing(_configureMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AgentDbModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgentDbModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      configure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}configure'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $AgentsTable createAlias(String alias) {
    return $AgentsTable(attachedDatabase, alias);
  }
}

class AgentDbModel extends DataClass implements Insertable<AgentDbModel> {
  final String id;
  final String name;
  final String? description;
  final String configure;
  final String createdAt;
  final bool isDefault;
  const AgentDbModel({
    required this.id,
    required this.name,
    this.description,
    required this.configure,
    required this.createdAt,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['configure'] = Variable<String>(configure);
    map['created_at'] = Variable<String>(createdAt);
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  AgentsCompanion toCompanion(bool nullToAbsent) {
    return AgentsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      configure: Value(configure),
      createdAt: Value(createdAt),
      isDefault: Value(isDefault),
    );
  }

  factory AgentDbModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgentDbModel(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      configure: serializer.fromJson<String>(json['configure']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'configure': serializer.toJson<String>(configure),
      'createdAt': serializer.toJson<String>(createdAt),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  AgentDbModel copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    String? configure,
    String? createdAt,
    bool? isDefault,
  }) => AgentDbModel(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    configure: configure ?? this.configure,
    createdAt: createdAt ?? this.createdAt,
    isDefault: isDefault ?? this.isDefault,
  );
  AgentDbModel copyWithCompanion(AgentsCompanion data) {
    return AgentDbModel(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      configure: data.configure.present ? data.configure.value : this.configure,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgentDbModel(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('configure: $configure, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, configure, createdAt, isDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgentDbModel &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.configure == this.configure &&
          other.createdAt == this.createdAt &&
          other.isDefault == this.isDefault);
}

class AgentsCompanion extends UpdateCompanion<AgentDbModel> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> configure;
  final Value<String> createdAt;
  final Value<bool> isDefault;
  final Value<int> rowid;
  const AgentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.configure = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgentsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String configure,
    required String createdAt,
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       configure = Value(configure),
       createdAt = Value(createdAt);
  static Insertable<AgentDbModel> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? configure,
    Expression<String>? createdAt,
    Expression<bool>? isDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (configure != null) 'configure': configure,
      if (createdAt != null) 'created_at': createdAt,
      if (isDefault != null) 'is_default': isDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgentsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? configure,
    Value<String>? createdAt,
    Value<bool>? isDefault,
    Value<int>? rowid,
  }) {
    return AgentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      configure: configure ?? this.configure,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (configure.present) {
      map['configure'] = Variable<String>(configure.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('configure: $configure, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDefault: $isDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionDbModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _agentIdMeta = const VerificationMeta(
    'agentId',
  );
  @override
  late final GeneratedColumn<String> agentId = GeneratedColumn<String>(
    'agent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES agents (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> modifiedAt = GeneratedColumn<DateTime>(
    'modified_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _agentOverrideMeta = const VerificationMeta(
    'agentOverride',
  );
  @override
  late final GeneratedColumn<String> agentOverride = GeneratedColumn<String>(
    'agent_override',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personaIdMeta = const VerificationMeta(
    'personaId',
  );
  @override
  late final GeneratedColumn<String> personaId = GeneratedColumn<String>(
    'persona_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _branchInfoMeta = const VerificationMeta(
    'branchInfo',
  );
  @override
  late final GeneratedColumn<String> branchInfo = GeneratedColumn<String>(
    'branch_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    agentId,
    title,
    createdAt,
    modifiedAt,
    agentOverride,
    personaId,
    branchInfo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionDbModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('agent_id')) {
      context.handle(
        _agentIdMeta,
        agentId.isAcceptableOrUnknown(data['agent_id']!, _agentIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_modifiedAtMeta);
    }
    if (data.containsKey('agent_override')) {
      context.handle(
        _agentOverrideMeta,
        agentOverride.isAcceptableOrUnknown(
          data['agent_override']!,
          _agentOverrideMeta,
        ),
      );
    }
    if (data.containsKey('persona_id')) {
      context.handle(
        _personaIdMeta,
        personaId.isAcceptableOrUnknown(data['persona_id']!, _personaIdMeta),
      );
    }
    if (data.containsKey('branch_info')) {
      context.handle(
        _branchInfoMeta,
        branchInfo.isAcceptableOrUnknown(data['branch_info']!, _branchInfoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionDbModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionDbModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      agentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}modified_at'],
      )!,
      agentOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_override'],
      ),
      personaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}persona_id'],
      ),
      branchInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch_info'],
      ),
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionDbModel extends DataClass implements Insertable<SessionDbModel> {
  final String id;
  final String? agentId;
  final String title;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String? agentOverride;
  final String? personaId;
  final String? branchInfo;
  const SessionDbModel({
    required this.id,
    this.agentId,
    required this.title,
    required this.createdAt,
    required this.modifiedAt,
    this.agentOverride,
    this.personaId,
    this.branchInfo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || agentId != null) {
      map['agent_id'] = Variable<String>(agentId);
    }
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['modified_at'] = Variable<DateTime>(modifiedAt);
    if (!nullToAbsent || agentOverride != null) {
      map['agent_override'] = Variable<String>(agentOverride);
    }
    if (!nullToAbsent || personaId != null) {
      map['persona_id'] = Variable<String>(personaId);
    }
    if (!nullToAbsent || branchInfo != null) {
      map['branch_info'] = Variable<String>(branchInfo);
    }
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      agentId: agentId == null && nullToAbsent
          ? const Value.absent()
          : Value(agentId),
      title: Value(title),
      createdAt: Value(createdAt),
      modifiedAt: Value(modifiedAt),
      agentOverride: agentOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(agentOverride),
      personaId: personaId == null && nullToAbsent
          ? const Value.absent()
          : Value(personaId),
      branchInfo: branchInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(branchInfo),
    );
  }

  factory SessionDbModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionDbModel(
      id: serializer.fromJson<String>(json['id']),
      agentId: serializer.fromJson<String?>(json['agentId']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      modifiedAt: serializer.fromJson<DateTime>(json['modifiedAt']),
      agentOverride: serializer.fromJson<String?>(json['agentOverride']),
      personaId: serializer.fromJson<String?>(json['personaId']),
      branchInfo: serializer.fromJson<String?>(json['branchInfo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'agentId': serializer.toJson<String?>(agentId),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'modifiedAt': serializer.toJson<DateTime>(modifiedAt),
      'agentOverride': serializer.toJson<String?>(agentOverride),
      'personaId': serializer.toJson<String?>(personaId),
      'branchInfo': serializer.toJson<String?>(branchInfo),
    };
  }

  SessionDbModel copyWith({
    String? id,
    Value<String?> agentId = const Value.absent(),
    String? title,
    DateTime? createdAt,
    DateTime? modifiedAt,
    Value<String?> agentOverride = const Value.absent(),
    Value<String?> personaId = const Value.absent(),
    Value<String?> branchInfo = const Value.absent(),
  }) => SessionDbModel(
    id: id ?? this.id,
    agentId: agentId.present ? agentId.value : this.agentId,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    modifiedAt: modifiedAt ?? this.modifiedAt,
    agentOverride: agentOverride.present
        ? agentOverride.value
        : this.agentOverride,
    personaId: personaId.present ? personaId.value : this.personaId,
    branchInfo: branchInfo.present ? branchInfo.value : this.branchInfo,
  );
  SessionDbModel copyWithCompanion(SessionsCompanion data) {
    return SessionDbModel(
      id: data.id.present ? data.id.value : this.id,
      agentId: data.agentId.present ? data.agentId.value : this.agentId,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
      agentOverride: data.agentOverride.present
          ? data.agentOverride.value
          : this.agentOverride,
      personaId: data.personaId.present ? data.personaId.value : this.personaId,
      branchInfo: data.branchInfo.present
          ? data.branchInfo.value
          : this.branchInfo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionDbModel(')
          ..write('id: $id, ')
          ..write('agentId: $agentId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('agentOverride: $agentOverride, ')
          ..write('personaId: $personaId, ')
          ..write('branchInfo: $branchInfo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    agentId,
    title,
    createdAt,
    modifiedAt,
    agentOverride,
    personaId,
    branchInfo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionDbModel &&
          other.id == this.id &&
          other.agentId == this.agentId &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.modifiedAt == this.modifiedAt &&
          other.agentOverride == this.agentOverride &&
          other.personaId == this.personaId &&
          other.branchInfo == this.branchInfo);
}

class SessionsCompanion extends UpdateCompanion<SessionDbModel> {
  final Value<String> id;
  final Value<String?> agentId;
  final Value<String> title;
  final Value<DateTime> createdAt;
  final Value<DateTime> modifiedAt;
  final Value<String?> agentOverride;
  final Value<String?> personaId;
  final Value<String?> branchInfo;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.agentId = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.agentOverride = const Value.absent(),
    this.personaId = const Value.absent(),
    this.branchInfo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    this.agentId = const Value.absent(),
    required String title,
    required DateTime createdAt,
    required DateTime modifiedAt,
    this.agentOverride = const Value.absent(),
    this.personaId = const Value.absent(),
    this.branchInfo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       createdAt = Value(createdAt),
       modifiedAt = Value(modifiedAt);
  static Insertable<SessionDbModel> custom({
    Expression<String>? id,
    Expression<String>? agentId,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? modifiedAt,
    Expression<String>? agentOverride,
    Expression<String>? personaId,
    Expression<String>? branchInfo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (agentId != null) 'agent_id': agentId,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (agentOverride != null) 'agent_override': agentOverride,
      if (personaId != null) 'persona_id': personaId,
      if (branchInfo != null) 'branch_info': branchInfo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? agentId,
    Value<String>? title,
    Value<DateTime>? createdAt,
    Value<DateTime>? modifiedAt,
    Value<String?>? agentOverride,
    Value<String?>? personaId,
    Value<String?>? branchInfo,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      agentOverride: agentOverride ?? this.agentOverride,
      personaId: personaId ?? this.personaId,
      branchInfo: branchInfo ?? this.branchInfo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (agentId.present) {
      map['agent_id'] = Variable<String>(agentId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<DateTime>(modifiedAt.value);
    }
    if (agentOverride.present) {
      map['agent_override'] = Variable<String>(agentOverride.value);
    }
    if (personaId.present) {
      map['persona_id'] = Variable<String>(personaId.value);
    }
    if (branchInfo.present) {
      map['branch_info'] = Variable<String>(branchInfo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('agentId: $agentId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('agentOverride: $agentOverride, ')
          ..write('personaId: $personaId, ')
          ..write('branchInfo: $branchInfo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages
    with TableInfo<$MessagesTable, MessageDbModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String>
  data = GeneratedColumn<String>(
    'data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<Map<String, dynamic>?>($MessagesTable.$converterdatan);
  static const VerificationMeta _persistentDataPointerMeta =
      const VerificationMeta('persistentDataPointer');
  @override
  late final GeneratedColumn<String> persistentDataPointer =
      GeneratedColumn<String>(
        'persistent_data_pointer',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<ChatFile>?, String>
  attachments = GeneratedColumn<String>(
    'attachments',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<List<ChatFile>?>($MessagesTable.$converterattachmentsn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sender,
    senderId,
    content,
    data,
    persistentDataPointer,
    timestamp,
    attachments,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageDbModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    } else if (isInserting) {
      context.missing(_senderMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('persistent_data_pointer')) {
      context.handle(
        _persistentDataPointerMeta,
        persistentDataPointer.isAcceptableOrUnknown(
          data['persistent_data_pointer']!,
          _persistentDataPointerMeta,
        ),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageDbModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageDbModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      data: $MessagesTable.$converterdatan.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}data'],
        ),
      ),
      persistentDataPointer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}persistent_data_pointer'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      attachments: $MessagesTable.$converterattachmentsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}attachments'],
        ),
      ),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $converterdata =
      const StringMapConverter();
  static TypeConverter<Map<String, dynamic>?, String?> $converterdatan =
      NullAwareTypeConverter.wrap($converterdata);
  static TypeConverter<List<ChatFile>, String> $converterattachments =
      const ChatAttachmentsConverter();
  static TypeConverter<List<ChatFile>?, String?> $converterattachmentsn =
      NullAwareTypeConverter.wrap($converterattachments);
}

class MessageDbModel extends DataClass implements Insertable<MessageDbModel> {
  final String id;
  final String sender;
  final String senderId;
  final String content;
  final Map<String, dynamic>? data;
  final String? persistentDataPointer;
  final DateTime timestamp;
  final List<ChatFile>? attachments;
  const MessageDbModel({
    required this.id,
    required this.sender,
    required this.senderId,
    required this.content,
    this.data,
    this.persistentDataPointer,
    required this.timestamp,
    this.attachments,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sender'] = Variable<String>(sender);
    map['sender_id'] = Variable<String>(senderId);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(
        $MessagesTable.$converterdatan.toSql(data),
      );
    }
    if (!nullToAbsent || persistentDataPointer != null) {
      map['persistent_data_pointer'] = Variable<String>(persistentDataPointer);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || attachments != null) {
      map['attachments'] = Variable<String>(
        $MessagesTable.$converterattachmentsn.toSql(attachments),
      );
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      sender: Value(sender),
      senderId: Value(senderId),
      content: Value(content),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      persistentDataPointer: persistentDataPointer == null && nullToAbsent
          ? const Value.absent()
          : Value(persistentDataPointer),
      timestamp: Value(timestamp),
      attachments: attachments == null && nullToAbsent
          ? const Value.absent()
          : Value(attachments),
    );
  }

  factory MessageDbModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageDbModel(
      id: serializer.fromJson<String>(json['id']),
      sender: serializer.fromJson<String>(json['sender']),
      senderId: serializer.fromJson<String>(json['senderId']),
      content: serializer.fromJson<String>(json['content']),
      data: serializer.fromJson<Map<String, dynamic>?>(json['data']),
      persistentDataPointer: serializer.fromJson<String?>(
        json['persistentDataPointer'],
      ),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      attachments: serializer.fromJson<List<ChatFile>?>(json['attachments']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sender': serializer.toJson<String>(sender),
      'senderId': serializer.toJson<String>(senderId),
      'content': serializer.toJson<String>(content),
      'data': serializer.toJson<Map<String, dynamic>?>(data),
      'persistentDataPointer': serializer.toJson<String?>(
        persistentDataPointer,
      ),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'attachments': serializer.toJson<List<ChatFile>?>(attachments),
    };
  }

  MessageDbModel copyWith({
    String? id,
    String? sender,
    String? senderId,
    String? content,
    Value<Map<String, dynamic>?> data = const Value.absent(),
    Value<String?> persistentDataPointer = const Value.absent(),
    DateTime? timestamp,
    Value<List<ChatFile>?> attachments = const Value.absent(),
  }) => MessageDbModel(
    id: id ?? this.id,
    sender: sender ?? this.sender,
    senderId: senderId ?? this.senderId,
    content: content ?? this.content,
    data: data.present ? data.value : this.data,
    persistentDataPointer: persistentDataPointer.present
        ? persistentDataPointer.value
        : this.persistentDataPointer,
    timestamp: timestamp ?? this.timestamp,
    attachments: attachments.present ? attachments.value : this.attachments,
  );
  MessageDbModel copyWithCompanion(MessagesCompanion data) {
    return MessageDbModel(
      id: data.id.present ? data.id.value : this.id,
      sender: data.sender.present ? data.sender.value : this.sender,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      content: data.content.present ? data.content.value : this.content,
      data: data.data.present ? data.data.value : this.data,
      persistentDataPointer: data.persistentDataPointer.present
          ? data.persistentDataPointer.value
          : this.persistentDataPointer,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      attachments: data.attachments.present
          ? data.attachments.value
          : this.attachments,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageDbModel(')
          ..write('id: $id, ')
          ..write('sender: $sender, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('data: $data, ')
          ..write('persistentDataPointer: $persistentDataPointer, ')
          ..write('timestamp: $timestamp, ')
          ..write('attachments: $attachments')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sender,
    senderId,
    content,
    data,
    persistentDataPointer,
    timestamp,
    attachments,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageDbModel &&
          other.id == this.id &&
          other.sender == this.sender &&
          other.senderId == this.senderId &&
          other.content == this.content &&
          other.data == this.data &&
          other.persistentDataPointer == this.persistentDataPointer &&
          other.timestamp == this.timestamp &&
          other.attachments == this.attachments);
}

class MessagesCompanion extends UpdateCompanion<MessageDbModel> {
  final Value<String> id;
  final Value<String> sender;
  final Value<String> senderId;
  final Value<String> content;
  final Value<Map<String, dynamic>?> data;
  final Value<String?> persistentDataPointer;
  final Value<DateTime> timestamp;
  final Value<List<ChatFile>?> attachments;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.sender = const Value.absent(),
    this.senderId = const Value.absent(),
    this.content = const Value.absent(),
    this.data = const Value.absent(),
    this.persistentDataPointer = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.attachments = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String sender,
    required String senderId,
    required String content,
    this.data = const Value.absent(),
    this.persistentDataPointer = const Value.absent(),
    required DateTime timestamp,
    this.attachments = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sender = Value(sender),
       senderId = Value(senderId),
       content = Value(content),
       timestamp = Value(timestamp);
  static Insertable<MessageDbModel> custom({
    Expression<String>? id,
    Expression<String>? sender,
    Expression<String>? senderId,
    Expression<String>? content,
    Expression<String>? data,
    Expression<String>? persistentDataPointer,
    Expression<DateTime>? timestamp,
    Expression<String>? attachments,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sender != null) 'sender': sender,
      if (senderId != null) 'sender_id': senderId,
      if (content != null) 'content': content,
      if (data != null) 'data': data,
      if (persistentDataPointer != null)
        'persistent_data_pointer': persistentDataPointer,
      if (timestamp != null) 'timestamp': timestamp,
      if (attachments != null) 'attachments': attachments,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? sender,
    Value<String>? senderId,
    Value<String>? content,
    Value<Map<String, dynamic>?>? data,
    Value<String?>? persistentDataPointer,
    Value<DateTime>? timestamp,
    Value<List<ChatFile>?>? attachments,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      data: data ?? this.data,
      persistentDataPointer:
          persistentDataPointer ?? this.persistentDataPointer,
      timestamp: timestamp ?? this.timestamp,
      attachments: attachments ?? this.attachments,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(
        $MessagesTable.$converterdatan.toSql(data.value),
      );
    }
    if (persistentDataPointer.present) {
      map['persistent_data_pointer'] = Variable<String>(
        persistentDataPointer.value,
      );
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (attachments.present) {
      map['attachments'] = Variable<String>(
        $MessagesTable.$converterattachmentsn.toSql(attachments.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('sender: $sender, ')
          ..write('senderId: $senderId, ')
          ..write('content: $content, ')
          ..write('data: $data, ')
          ..write('persistentDataPointer: $persistentDataPointer, ')
          ..write('timestamp: $timestamp, ')
          ..write('attachments: $attachments, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessageRelationsTable extends MessageRelations
    with TableInfo<$MessageRelationsTable, MessageRelationDbModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageRelationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES messages (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> childIds =
      GeneratedColumn<String>(
        'child_ids',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>(
        $MessageRelationsTable.$converterchildIdsn,
      );
  static const VerificationMeta _enabledChildIndexMeta = const VerificationMeta(
    'enabledChildIndex',
  );
  @override
  late final GeneratedColumn<int> enabledChildIndex = GeneratedColumn<int>(
    'enabled_child_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    messageId,
    parentId,
    childIds,
    enabledChildIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_relations';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageRelationDbModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('enabled_child_index')) {
      context.handle(
        _enabledChildIndexMeta,
        enabledChildIndex.isAcceptableOrUnknown(
          data['enabled_child_index']!,
          _enabledChildIndexMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageRelationDbModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageRelationDbModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      ),
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      childIds: $MessageRelationsTable.$converterchildIdsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}child_ids'],
        ),
      ),
      enabledChildIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}enabled_child_index'],
      ),
    );
  }

  @override
  $MessageRelationsTable createAlias(String alias) {
    return $MessageRelationsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterchildIds =
      const StringListConverter();
  static TypeConverter<List<String>?, String?> $converterchildIdsn =
      NullAwareTypeConverter.wrap($converterchildIds);
}

class MessageRelationDbModel extends DataClass
    implements Insertable<MessageRelationDbModel> {
  final String id;
  final String sessionId;
  final String? messageId;
  final String? parentId;
  final List<String>? childIds;
  final int? enabledChildIndex;
  const MessageRelationDbModel({
    required this.id,
    required this.sessionId,
    this.messageId,
    this.parentId,
    this.childIds,
    this.enabledChildIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    if (!nullToAbsent || messageId != null) {
      map['message_id'] = Variable<String>(messageId);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || childIds != null) {
      map['child_ids'] = Variable<String>(
        $MessageRelationsTable.$converterchildIdsn.toSql(childIds),
      );
    }
    if (!nullToAbsent || enabledChildIndex != null) {
      map['enabled_child_index'] = Variable<int>(enabledChildIndex);
    }
    return map;
  }

  MessageRelationsCompanion toCompanion(bool nullToAbsent) {
    return MessageRelationsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      messageId: messageId == null && nullToAbsent
          ? const Value.absent()
          : Value(messageId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      childIds: childIds == null && nullToAbsent
          ? const Value.absent()
          : Value(childIds),
      enabledChildIndex: enabledChildIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(enabledChildIndex),
    );
  }

  factory MessageRelationDbModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageRelationDbModel(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      messageId: serializer.fromJson<String?>(json['messageId']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      childIds: serializer.fromJson<List<String>?>(json['childIds']),
      enabledChildIndex: serializer.fromJson<int?>(json['enabledChildIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'messageId': serializer.toJson<String?>(messageId),
      'parentId': serializer.toJson<String?>(parentId),
      'childIds': serializer.toJson<List<String>?>(childIds),
      'enabledChildIndex': serializer.toJson<int?>(enabledChildIndex),
    };
  }

  MessageRelationDbModel copyWith({
    String? id,
    String? sessionId,
    Value<String?> messageId = const Value.absent(),
    Value<String?> parentId = const Value.absent(),
    Value<List<String>?> childIds = const Value.absent(),
    Value<int?> enabledChildIndex = const Value.absent(),
  }) => MessageRelationDbModel(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    messageId: messageId.present ? messageId.value : this.messageId,
    parentId: parentId.present ? parentId.value : this.parentId,
    childIds: childIds.present ? childIds.value : this.childIds,
    enabledChildIndex: enabledChildIndex.present
        ? enabledChildIndex.value
        : this.enabledChildIndex,
  );
  MessageRelationDbModel copyWithCompanion(MessageRelationsCompanion data) {
    return MessageRelationDbModel(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      childIds: data.childIds.present ? data.childIds.value : this.childIds,
      enabledChildIndex: data.enabledChildIndex.present
          ? data.enabledChildIndex.value
          : this.enabledChildIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageRelationDbModel(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('messageId: $messageId, ')
          ..write('parentId: $parentId, ')
          ..write('childIds: $childIds, ')
          ..write('enabledChildIndex: $enabledChildIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    messageId,
    parentId,
    childIds,
    enabledChildIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageRelationDbModel &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.messageId == this.messageId &&
          other.parentId == this.parentId &&
          other.childIds == this.childIds &&
          other.enabledChildIndex == this.enabledChildIndex);
}

class MessageRelationsCompanion
    extends UpdateCompanion<MessageRelationDbModel> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String?> messageId;
  final Value<String?> parentId;
  final Value<List<String>?> childIds;
  final Value<int?> enabledChildIndex;
  final Value<int> rowid;
  const MessageRelationsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.messageId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.childIds = const Value.absent(),
    this.enabledChildIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageRelationsCompanion.insert({
    required String id,
    required String sessionId,
    this.messageId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.childIds = const Value.absent(),
    this.enabledChildIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId);
  static Insertable<MessageRelationDbModel> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? messageId,
    Expression<String>? parentId,
    Expression<String>? childIds,
    Expression<int>? enabledChildIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (messageId != null) 'message_id': messageId,
      if (parentId != null) 'parent_id': parentId,
      if (childIds != null) 'child_ids': childIds,
      if (enabledChildIndex != null) 'enabled_child_index': enabledChildIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageRelationsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String?>? messageId,
    Value<String?>? parentId,
    Value<List<String>?>? childIds,
    Value<int?>? enabledChildIndex,
    Value<int>? rowid,
  }) {
    return MessageRelationsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      messageId: messageId ?? this.messageId,
      parentId: parentId ?? this.parentId,
      childIds: childIds ?? this.childIds,
      enabledChildIndex: enabledChildIndex ?? this.enabledChildIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (childIds.present) {
      map['child_ids'] = Variable<String>(
        $MessageRelationsTable.$converterchildIdsn.toSql(childIds.value),
      );
    }
    if (enabledChildIndex.present) {
      map['enabled_child_index'] = Variable<int>(enabledChildIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageRelationsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('messageId: $messageId, ')
          ..write('parentId: $parentId, ')
          ..write('childIds: $childIds, ')
          ..write('enabledChildIndex: $enabledChildIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersistentDataTable extends PersistentData
    with TableInfo<$PersistentDataTable, PersistentDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersistentDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'persistent_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersistentDataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersistentDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersistentDataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      ),
    );
  }

  @override
  $PersistentDataTable createAlias(String alias) {
    return $PersistentDataTable(attachedDatabase, alias);
  }
}

class PersistentDataData extends DataClass
    implements Insertable<PersistentDataData> {
  final String id;
  final String? data;
  const PersistentDataData({required this.id, this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    return map;
  }

  PersistentDataCompanion toCompanion(bool nullToAbsent) {
    return PersistentDataCompanion(
      id: Value(id),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
    );
  }

  factory PersistentDataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersistentDataData(
      id: serializer.fromJson<String>(json['id']),
      data: serializer.fromJson<String?>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'data': serializer.toJson<String?>(data),
    };
  }

  PersistentDataData copyWith({
    String? id,
    Value<String?> data = const Value.absent(),
  }) => PersistentDataData(
    id: id ?? this.id,
    data: data.present ? data.value : this.data,
  );
  PersistentDataData copyWithCompanion(PersistentDataCompanion data) {
    return PersistentDataData(
      id: data.id.present ? data.id.value : this.id,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersistentDataData(')
          ..write('id: $id, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersistentDataData &&
          other.id == this.id &&
          other.data == this.data);
}

class PersistentDataCompanion extends UpdateCompanion<PersistentDataData> {
  final Value<String> id;
  final Value<String?> data;
  final Value<int> rowid;
  const PersistentDataCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersistentDataCompanion.insert({
    required String id,
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<PersistentDataData> custom({
    Expression<String>? id,
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersistentDataCompanion copyWith({
    Value<String>? id,
    Value<String?>? data,
    Value<int>? rowid,
  }) {
    return PersistentDataCompanion(
      id: id ?? this.id,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersistentDataCompanion(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonasTable extends Personas
    with TableInfo<$PersonasTable, PersonaDbModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<
    Map<String, PersonaDataEntry>?,
    String
  >
  data =
      GeneratedColumn<String>(
        'data',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Map<String, PersonaDataEntry>?>(
        $PersonasTable.$converterdatan,
      );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, content, data, isDefault];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personas';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonaDbModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonaDbModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonaDbModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      data: $PersonasTable.$converterdatan.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}data'],
        ),
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $PersonasTable createAlias(String alias) {
    return $PersonasTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, PersonaDataEntry>, String> $converterdata =
      const PersonaDataConverter();
  static TypeConverter<Map<String, PersonaDataEntry>?, String?>
  $converterdatan = NullAwareTypeConverter.wrap($converterdata);
}

class PersonaDbModel extends DataClass implements Insertable<PersonaDbModel> {
  final String id;
  final String name;
  final String content;
  final Map<String, PersonaDataEntry>? data;
  final bool isDefault;
  const PersonaDbModel({
    required this.id,
    required this.name,
    required this.content,
    this.data,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(
        $PersonasTable.$converterdatan.toSql(data),
      );
    }
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  PersonasCompanion toCompanion(bool nullToAbsent) {
    return PersonasCompanion(
      id: Value(id),
      name: Value(name),
      content: Value(content),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      isDefault: Value(isDefault),
    );
  }

  factory PersonaDbModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonaDbModel(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      content: serializer.fromJson<String>(json['content']),
      data: serializer.fromJson<Map<String, PersonaDataEntry>?>(json['data']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'content': serializer.toJson<String>(content),
      'data': serializer.toJson<Map<String, PersonaDataEntry>?>(data),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  PersonaDbModel copyWith({
    String? id,
    String? name,
    String? content,
    Value<Map<String, PersonaDataEntry>?> data = const Value.absent(),
    bool? isDefault,
  }) => PersonaDbModel(
    id: id ?? this.id,
    name: name ?? this.name,
    content: content ?? this.content,
    data: data.present ? data.value : this.data,
    isDefault: isDefault ?? this.isDefault,
  );
  PersonaDbModel copyWithCompanion(PersonasCompanion data) {
    return PersonaDbModel(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      content: data.content.present ? data.content.value : this.content,
      data: data.data.present ? data.data.value : this.data,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonaDbModel(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('data: $data, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, content, data, isDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonaDbModel &&
          other.id == this.id &&
          other.name == this.name &&
          other.content == this.content &&
          other.data == this.data &&
          other.isDefault == this.isDefault);
}

class PersonasCompanion extends UpdateCompanion<PersonaDbModel> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> content;
  final Value<Map<String, PersonaDataEntry>?> data;
  final Value<bool> isDefault;
  final Value<int> rowid;
  const PersonasCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.content = const Value.absent(),
    this.data = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonasCompanion.insert({
    required String id,
    required String name,
    required String content,
    this.data = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       content = Value(content);
  static Insertable<PersonaDbModel> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? content,
    Expression<String>? data,
    Expression<bool>? isDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (content != null) 'content': content,
      if (data != null) 'data': data,
      if (isDefault != null) 'is_default': isDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonasCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? content,
    Value<Map<String, PersonaDataEntry>?>? data,
    Value<bool>? isDefault,
    Value<int>? rowid,
  }) {
    return PersonasCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      content: content ?? this.content,
      data: data ?? this.data,
      isDefault: isDefault ?? this.isDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(
        $PersonasTable.$converterdatan.toSql(data.value),
      );
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonasCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('data: $data, ')
          ..write('isDefault: $isDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$_ChatDb extends GeneratedDatabase {
  _$_ChatDb(QueryExecutor e) : super(e);
  $_ChatDbManager get managers => $_ChatDbManager(this);
  late final $AgentsTable agents = $AgentsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $MessageRelationsTable messageRelations = $MessageRelationsTable(
    this,
  );
  late final $PersistentDataTable persistentData = $PersistentDataTable(this);
  late final $PersonasTable personas = $PersonasTable(this);
  late final Index idxAgentName = Index(
    'idx_agent_name',
    'CREATE INDEX idx_agent_name ON agents (name)',
  );
  late final Index idxSessionsAgentId = Index(
    'idx_sessions_agent_id',
    'CREATE INDEX idx_sessions_agent_id ON sessions (agent_id)',
  );
  late final Index idxMessageRelationsSessionId = Index(
    'idx_message_relations_session_id',
    'CREATE INDEX idx_message_relations_session_id ON message_relations (session_id)',
  );
  late final Index idxMessageRelationsMessageId = Index(
    'idx_message_relations_message_id',
    'CREATE INDEX idx_message_relations_message_id ON message_relations (message_id)',
  );
  late final Index idxPersonasIsDefault = Index(
    'idx_personas_is_default',
    'CREATE INDEX idx_personas_is_default ON personas (is_default)',
  );
  late final Index idxPersonasName = Index(
    'idx_personas_name',
    'CREATE INDEX idx_personas_name ON personas (name)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    agents,
    sessions,
    messages,
    messageRelations,
    persistentData,
    personas,
    idxAgentName,
    idxSessionsAgentId,
    idxMessageRelationsSessionId,
    idxMessageRelationsMessageId,
    idxPersonasIsDefault,
    idxPersonasName,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'agents',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sessions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('message_relations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'messages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('message_relations', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AgentsTableCreateCompanionBuilder =
    AgentsCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      required String configure,
      required String createdAt,
      Value<bool> isDefault,
      Value<int> rowid,
    });
typedef $$AgentsTableUpdateCompanionBuilder =
    AgentsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String> configure,
      Value<String> createdAt,
      Value<bool> isDefault,
      Value<int> rowid,
    });

final class $$AgentsTableReferences
    extends BaseReferences<_$_ChatDb, $AgentsTable, AgentDbModel> {
  $$AgentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionsTable, List<SessionDbModel>>
  _sessionsRefsTable(_$_ChatDb db) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: $_aliasNameGenerator(db.agents.id, db.sessions.agentId),
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.agentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AgentsTableFilterComposer extends Composer<_$_ChatDb, $AgentsTable> {
  $$AgentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configure => $composableBuilder(
    column: $table.configure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.agentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AgentsTableOrderingComposer extends Composer<_$_ChatDb, $AgentsTable> {
  $$AgentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configure => $composableBuilder(
    column: $table.configure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AgentsTableAnnotationComposer
    extends Composer<_$_ChatDb, $AgentsTable> {
  $$AgentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get configure =>
      $composableBuilder(column: $table.configure, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.agentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AgentsTableTableManager
    extends
        RootTableManager<
          _$_ChatDb,
          $AgentsTable,
          AgentDbModel,
          $$AgentsTableFilterComposer,
          $$AgentsTableOrderingComposer,
          $$AgentsTableAnnotationComposer,
          $$AgentsTableCreateCompanionBuilder,
          $$AgentsTableUpdateCompanionBuilder,
          (AgentDbModel, $$AgentsTableReferences),
          AgentDbModel,
          PrefetchHooks Function({bool sessionsRefs})
        > {
  $$AgentsTableTableManager(_$_ChatDb db, $AgentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> configure = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgentsCompanion(
                id: id,
                name: name,
                description: description,
                configure: configure,
                createdAt: createdAt,
                isDefault: isDefault,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                required String configure,
                required String createdAt,
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgentsCompanion.insert(
                id: id,
                name: name,
                description: description,
                configure: configure,
                createdAt: createdAt,
                isDefault: isDefault,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AgentsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({sessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sessionsRefs) db.sessions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionsRefs)
                    await $_getPrefetchedData<
                      AgentDbModel,
                      $AgentsTable,
                      SessionDbModel
                    >(
                      currentTable: table,
                      referencedTable: $$AgentsTableReferences
                          ._sessionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AgentsTableReferences(db, table, p0).sessionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.agentId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AgentsTableProcessedTableManager =
    ProcessedTableManager<
      _$_ChatDb,
      $AgentsTable,
      AgentDbModel,
      $$AgentsTableFilterComposer,
      $$AgentsTableOrderingComposer,
      $$AgentsTableAnnotationComposer,
      $$AgentsTableCreateCompanionBuilder,
      $$AgentsTableUpdateCompanionBuilder,
      (AgentDbModel, $$AgentsTableReferences),
      AgentDbModel,
      PrefetchHooks Function({bool sessionsRefs})
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String id,
      Value<String?> agentId,
      required String title,
      required DateTime createdAt,
      required DateTime modifiedAt,
      Value<String?> agentOverride,
      Value<String?> personaId,
      Value<String?> branchInfo,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> id,
      Value<String?> agentId,
      Value<String> title,
      Value<DateTime> createdAt,
      Value<DateTime> modifiedAt,
      Value<String?> agentOverride,
      Value<String?> personaId,
      Value<String?> branchInfo,
      Value<int> rowid,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$_ChatDb, $SessionsTable, SessionDbModel> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AgentsTable _agentIdTable(_$_ChatDb db) => db.agents.createAlias(
    $_aliasNameGenerator(db.sessions.agentId, db.agents.id),
  );

  $$AgentsTableProcessedTableManager? get agentId {
    final $_column = $_itemColumn<String>('agent_id');
    if ($_column == null) return null;
    final manager = $$AgentsTableTableManager(
      $_db,
      $_db.agents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_agentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $MessageRelationsTable,
    List<MessageRelationDbModel>
  >
  _messageRelationsRefsTable(_$_ChatDb db) => MultiTypedResultKey.fromTable(
    db.messageRelations,
    aliasName: $_aliasNameGenerator(
      db.sessions.id,
      db.messageRelations.sessionId,
    ),
  );

  $$MessageRelationsTableProcessedTableManager get messageRelationsRefs {
    final manager = $$MessageRelationsTableTableManager(
      $_db,
      $_db.messageRelations,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _messageRelationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$_ChatDb, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentOverride => $composableBuilder(
    column: $table.agentOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personaId => $composableBuilder(
    column: $table.personaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branchInfo => $composableBuilder(
    column: $table.branchInfo,
    builder: (column) => ColumnFilters(column),
  );

  $$AgentsTableFilterComposer get agentId {
    final $$AgentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.agentId,
      referencedTable: $db.agents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AgentsTableFilterComposer(
            $db: $db,
            $table: $db.agents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> messageRelationsRefs(
    Expression<bool> Function($$MessageRelationsTableFilterComposer f) f,
  ) {
    final $$MessageRelationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messageRelations,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageRelationsTableFilterComposer(
            $db: $db,
            $table: $db.messageRelations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$_ChatDb, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentOverride => $composableBuilder(
    column: $table.agentOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personaId => $composableBuilder(
    column: $table.personaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branchInfo => $composableBuilder(
    column: $table.branchInfo,
    builder: (column) => ColumnOrderings(column),
  );

  $$AgentsTableOrderingComposer get agentId {
    final $$AgentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.agentId,
      referencedTable: $db.agents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AgentsTableOrderingComposer(
            $db: $db,
            $table: $db.agents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$_ChatDb, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get agentOverride => $composableBuilder(
    column: $table.agentOverride,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personaId =>
      $composableBuilder(column: $table.personaId, builder: (column) => column);

  GeneratedColumn<String> get branchInfo => $composableBuilder(
    column: $table.branchInfo,
    builder: (column) => column,
  );

  $$AgentsTableAnnotationComposer get agentId {
    final $$AgentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.agentId,
      referencedTable: $db.agents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AgentsTableAnnotationComposer(
            $db: $db,
            $table: $db.agents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> messageRelationsRefs<T extends Object>(
    Expression<T> Function($$MessageRelationsTableAnnotationComposer a) f,
  ) {
    final $$MessageRelationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messageRelations,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageRelationsTableAnnotationComposer(
            $db: $db,
            $table: $db.messageRelations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$_ChatDb,
          $SessionsTable,
          SessionDbModel,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (SessionDbModel, $$SessionsTableReferences),
          SessionDbModel,
          PrefetchHooks Function({bool agentId, bool messageRelationsRefs})
        > {
  $$SessionsTableTableManager(_$_ChatDb db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> agentId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> modifiedAt = const Value.absent(),
                Value<String?> agentOverride = const Value.absent(),
                Value<String?> personaId = const Value.absent(),
                Value<String?> branchInfo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                agentId: agentId,
                title: title,
                createdAt: createdAt,
                modifiedAt: modifiedAt,
                agentOverride: agentOverride,
                personaId: personaId,
                branchInfo: branchInfo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> agentId = const Value.absent(),
                required String title,
                required DateTime createdAt,
                required DateTime modifiedAt,
                Value<String?> agentOverride = const Value.absent(),
                Value<String?> personaId = const Value.absent(),
                Value<String?> branchInfo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                agentId: agentId,
                title: title,
                createdAt: createdAt,
                modifiedAt: modifiedAt,
                agentOverride: agentOverride,
                personaId: personaId,
                branchInfo: branchInfo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({agentId = false, messageRelationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (messageRelationsRefs) db.messageRelations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (agentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.agentId,
                                    referencedTable: $$SessionsTableReferences
                                        ._agentIdTable(db),
                                    referencedColumn: $$SessionsTableReferences
                                        ._agentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (messageRelationsRefs)
                        await $_getPrefetchedData<
                          SessionDbModel,
                          $SessionsTable,
                          MessageRelationDbModel
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._messageRelationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).messageRelationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$_ChatDb,
      $SessionsTable,
      SessionDbModel,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (SessionDbModel, $$SessionsTableReferences),
      SessionDbModel,
      PrefetchHooks Function({bool agentId, bool messageRelationsRefs})
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required String id,
      required String sender,
      required String senderId,
      required String content,
      Value<Map<String, dynamic>?> data,
      Value<String?> persistentDataPointer,
      required DateTime timestamp,
      Value<List<ChatFile>?> attachments,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<String> sender,
      Value<String> senderId,
      Value<String> content,
      Value<Map<String, dynamic>?> data,
      Value<String?> persistentDataPointer,
      Value<DateTime> timestamp,
      Value<List<ChatFile>?> attachments,
      Value<int> rowid,
    });

final class $$MessagesTableReferences
    extends BaseReferences<_$_ChatDb, $MessagesTable, MessageDbModel> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $MessageRelationsTable,
    List<MessageRelationDbModel>
  >
  _messageRelationsRefsTable(_$_ChatDb db) => MultiTypedResultKey.fromTable(
    db.messageRelations,
    aliasName: $_aliasNameGenerator(
      db.messages.id,
      db.messageRelations.messageId,
    ),
  );

  $$MessageRelationsTableProcessedTableManager get messageRelationsRefs {
    final manager = $$MessageRelationsTableTableManager(
      $_db,
      $_db.messageRelations,
    ).filter((f) => f.messageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _messageRelationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$_ChatDb, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>?,
    Map<String, dynamic>,
    String
  >
  get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get persistentDataPointer => $composableBuilder(
    column: $table.persistentDataPointer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<ChatFile>?, List<ChatFile>, String>
  get attachments => $composableBuilder(
    column: $table.attachments,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> messageRelationsRefs(
    Expression<bool> Function($$MessageRelationsTableFilterComposer f) f,
  ) {
    final $$MessageRelationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messageRelations,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageRelationsTableFilterComposer(
            $db: $db,
            $table: $db.messageRelations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$_ChatDb, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get persistentDataPointer => $composableBuilder(
    column: $table.persistentDataPointer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachments => $composableBuilder(
    column: $table.attachments,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$_ChatDb, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>?, String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get persistentDataPointer => $composableBuilder(
    column: $table.persistentDataPointer,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<ChatFile>?, String> get attachments =>
      $composableBuilder(
        column: $table.attachments,
        builder: (column) => column,
      );

  Expression<T> messageRelationsRefs<T extends Object>(
    Expression<T> Function($$MessageRelationsTableAnnotationComposer a) f,
  ) {
    final $$MessageRelationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messageRelations,
      getReferencedColumn: (t) => t.messageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessageRelationsTableAnnotationComposer(
            $db: $db,
            $table: $db.messageRelations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$_ChatDb,
          $MessagesTable,
          MessageDbModel,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (MessageDbModel, $$MessagesTableReferences),
          MessageDbModel,
          PrefetchHooks Function({bool messageRelationsRefs})
        > {
  $$MessagesTableTableManager(_$_ChatDb db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sender = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<Map<String, dynamic>?> data = const Value.absent(),
                Value<String?> persistentDataPointer = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<List<ChatFile>?> attachments = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                sender: sender,
                senderId: senderId,
                content: content,
                data: data,
                persistentDataPointer: persistentDataPointer,
                timestamp: timestamp,
                attachments: attachments,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sender,
                required String senderId,
                required String content,
                Value<Map<String, dynamic>?> data = const Value.absent(),
                Value<String?> persistentDataPointer = const Value.absent(),
                required DateTime timestamp,
                Value<List<ChatFile>?> attachments = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                sender: sender,
                senderId: senderId,
                content: content,
                data: data,
                persistentDataPointer: persistentDataPointer,
                timestamp: timestamp,
                attachments: attachments,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({messageRelationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (messageRelationsRefs) db.messageRelations,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messageRelationsRefs)
                    await $_getPrefetchedData<
                      MessageDbModel,
                      $MessagesTable,
                      MessageRelationDbModel
                    >(
                      currentTable: table,
                      referencedTable: $$MessagesTableReferences
                          ._messageRelationsRefsTable(db),
                      managerFromTypedResult: (p0) => $$MessagesTableReferences(
                        db,
                        table,
                        p0,
                      ).messageRelationsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.messageId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$_ChatDb,
      $MessagesTable,
      MessageDbModel,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (MessageDbModel, $$MessagesTableReferences),
      MessageDbModel,
      PrefetchHooks Function({bool messageRelationsRefs})
    >;
typedef $$MessageRelationsTableCreateCompanionBuilder =
    MessageRelationsCompanion Function({
      required String id,
      required String sessionId,
      Value<String?> messageId,
      Value<String?> parentId,
      Value<List<String>?> childIds,
      Value<int?> enabledChildIndex,
      Value<int> rowid,
    });
typedef $$MessageRelationsTableUpdateCompanionBuilder =
    MessageRelationsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String?> messageId,
      Value<String?> parentId,
      Value<List<String>?> childIds,
      Value<int?> enabledChildIndex,
      Value<int> rowid,
    });

final class $$MessageRelationsTableReferences
    extends
        BaseReferences<
          _$_ChatDb,
          $MessageRelationsTable,
          MessageRelationDbModel
        > {
  $$MessageRelationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$_ChatDb db) =>
      db.sessions.createAlias(
        $_aliasNameGenerator(db.messageRelations.sessionId, db.sessions.id),
      );

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MessagesTable _messageIdTable(_$_ChatDb db) =>
      db.messages.createAlias(
        $_aliasNameGenerator(db.messageRelations.messageId, db.messages.id),
      );

  $$MessagesTableProcessedTableManager? get messageId {
    final $_column = $_itemColumn<String>('message_id');
    if ($_column == null) return null;
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_messageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MessageRelationsTableFilterComposer
    extends Composer<_$_ChatDb, $MessageRelationsTable> {
  $$MessageRelationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get childIds => $composableBuilder(
    column: $table.childIds,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get enabledChildIndex => $composableBuilder(
    column: $table.enabledChildIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MessagesTableFilterComposer get messageId {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessageRelationsTableOrderingComposer
    extends Composer<_$_ChatDb, $MessageRelationsTable> {
  $$MessageRelationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childIds => $composableBuilder(
    column: $table.childIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get enabledChildIndex => $composableBuilder(
    column: $table.enabledChildIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MessagesTableOrderingComposer get messageId {
    final $$MessagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableOrderingComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessageRelationsTableAnnotationComposer
    extends Composer<_$_ChatDb, $MessageRelationsTable> {
  $$MessageRelationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get childIds =>
      $composableBuilder(column: $table.childIds, builder: (column) => column);

  GeneratedColumn<int> get enabledChildIndex => $composableBuilder(
    column: $table.enabledChildIndex,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MessagesTableAnnotationComposer get messageId {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.messageId,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessageRelationsTableTableManager
    extends
        RootTableManager<
          _$_ChatDb,
          $MessageRelationsTable,
          MessageRelationDbModel,
          $$MessageRelationsTableFilterComposer,
          $$MessageRelationsTableOrderingComposer,
          $$MessageRelationsTableAnnotationComposer,
          $$MessageRelationsTableCreateCompanionBuilder,
          $$MessageRelationsTableUpdateCompanionBuilder,
          (MessageRelationDbModel, $$MessageRelationsTableReferences),
          MessageRelationDbModel,
          PrefetchHooks Function({bool sessionId, bool messageId})
        > {
  $$MessageRelationsTableTableManager(
    _$_ChatDb db,
    $MessageRelationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageRelationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageRelationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageRelationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String?> messageId = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<List<String>?> childIds = const Value.absent(),
                Value<int?> enabledChildIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageRelationsCompanion(
                id: id,
                sessionId: sessionId,
                messageId: messageId,
                parentId: parentId,
                childIds: childIds,
                enabledChildIndex: enabledChildIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                Value<String?> messageId = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<List<String>?> childIds = const Value.absent(),
                Value<int?> enabledChildIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageRelationsCompanion.insert(
                id: id,
                sessionId: sessionId,
                messageId: messageId,
                parentId: parentId,
                childIds: childIds,
                enabledChildIndex: enabledChildIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessageRelationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, messageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$MessageRelationsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$MessageRelationsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (messageId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.messageId,
                                referencedTable:
                                    $$MessageRelationsTableReferences
                                        ._messageIdTable(db),
                                referencedColumn:
                                    $$MessageRelationsTableReferences
                                        ._messageIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MessageRelationsTableProcessedTableManager =
    ProcessedTableManager<
      _$_ChatDb,
      $MessageRelationsTable,
      MessageRelationDbModel,
      $$MessageRelationsTableFilterComposer,
      $$MessageRelationsTableOrderingComposer,
      $$MessageRelationsTableAnnotationComposer,
      $$MessageRelationsTableCreateCompanionBuilder,
      $$MessageRelationsTableUpdateCompanionBuilder,
      (MessageRelationDbModel, $$MessageRelationsTableReferences),
      MessageRelationDbModel,
      PrefetchHooks Function({bool sessionId, bool messageId})
    >;
typedef $$PersistentDataTableCreateCompanionBuilder =
    PersistentDataCompanion Function({
      required String id,
      Value<String?> data,
      Value<int> rowid,
    });
typedef $$PersistentDataTableUpdateCompanionBuilder =
    PersistentDataCompanion Function({
      Value<String> id,
      Value<String?> data,
      Value<int> rowid,
    });

class $$PersistentDataTableFilterComposer
    extends Composer<_$_ChatDb, $PersistentDataTable> {
  $$PersistentDataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersistentDataTableOrderingComposer
    extends Composer<_$_ChatDb, $PersistentDataTable> {
  $$PersistentDataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersistentDataTableAnnotationComposer
    extends Composer<_$_ChatDb, $PersistentDataTable> {
  $$PersistentDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$PersistentDataTableTableManager
    extends
        RootTableManager<
          _$_ChatDb,
          $PersistentDataTable,
          PersistentDataData,
          $$PersistentDataTableFilterComposer,
          $$PersistentDataTableOrderingComposer,
          $$PersistentDataTableAnnotationComposer,
          $$PersistentDataTableCreateCompanionBuilder,
          $$PersistentDataTableUpdateCompanionBuilder,
          (
            PersistentDataData,
            BaseReferences<_$_ChatDb, $PersistentDataTable, PersistentDataData>,
          ),
          PersistentDataData,
          PrefetchHooks Function()
        > {
  $$PersistentDataTableTableManager(_$_ChatDb db, $PersistentDataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersistentDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersistentDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersistentDataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> data = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersistentDataCompanion(id: id, data: data, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> data = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersistentDataCompanion.insert(
                id: id,
                data: data,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersistentDataTableProcessedTableManager =
    ProcessedTableManager<
      _$_ChatDb,
      $PersistentDataTable,
      PersistentDataData,
      $$PersistentDataTableFilterComposer,
      $$PersistentDataTableOrderingComposer,
      $$PersistentDataTableAnnotationComposer,
      $$PersistentDataTableCreateCompanionBuilder,
      $$PersistentDataTableUpdateCompanionBuilder,
      (
        PersistentDataData,
        BaseReferences<_$_ChatDb, $PersistentDataTable, PersistentDataData>,
      ),
      PersistentDataData,
      PrefetchHooks Function()
    >;
typedef $$PersonasTableCreateCompanionBuilder =
    PersonasCompanion Function({
      required String id,
      required String name,
      required String content,
      Value<Map<String, PersonaDataEntry>?> data,
      Value<bool> isDefault,
      Value<int> rowid,
    });
typedef $$PersonasTableUpdateCompanionBuilder =
    PersonasCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> content,
      Value<Map<String, PersonaDataEntry>?> data,
      Value<bool> isDefault,
      Value<int> rowid,
    });

class $$PersonasTableFilterComposer
    extends Composer<_$_ChatDb, $PersonasTable> {
  $$PersonasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, PersonaDataEntry>?,
    Map<String, PersonaDataEntry>,
    String
  >
  get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonasTableOrderingComposer
    extends Composer<_$_ChatDb, $PersonasTable> {
  $$PersonasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonasTableAnnotationComposer
    extends Composer<_$_ChatDb, $PersonasTable> {
  $$PersonasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, PersonaDataEntry>?, String>
  get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);
}

class $$PersonasTableTableManager
    extends
        RootTableManager<
          _$_ChatDb,
          $PersonasTable,
          PersonaDbModel,
          $$PersonasTableFilterComposer,
          $$PersonasTableOrderingComposer,
          $$PersonasTableAnnotationComposer,
          $$PersonasTableCreateCompanionBuilder,
          $$PersonasTableUpdateCompanionBuilder,
          (
            PersonaDbModel,
            BaseReferences<_$_ChatDb, $PersonasTable, PersonaDbModel>,
          ),
          PersonaDbModel,
          PrefetchHooks Function()
        > {
  $$PersonasTableTableManager(_$_ChatDb db, $PersonasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<Map<String, PersonaDataEntry>?> data =
                    const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonasCompanion(
                id: id,
                name: name,
                content: content,
                data: data,
                isDefault: isDefault,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String content,
                Value<Map<String, PersonaDataEntry>?> data =
                    const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonasCompanion.insert(
                id: id,
                name: name,
                content: content,
                data: data,
                isDefault: isDefault,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonasTableProcessedTableManager =
    ProcessedTableManager<
      _$_ChatDb,
      $PersonasTable,
      PersonaDbModel,
      $$PersonasTableFilterComposer,
      $$PersonasTableOrderingComposer,
      $$PersonasTableAnnotationComposer,
      $$PersonasTableCreateCompanionBuilder,
      $$PersonasTableUpdateCompanionBuilder,
      (
        PersonaDbModel,
        BaseReferences<_$_ChatDb, $PersonasTable, PersonaDbModel>,
      ),
      PersonaDbModel,
      PrefetchHooks Function()
    >;

class $_ChatDbManager {
  final _$_ChatDb _db;
  $_ChatDbManager(this._db);
  $$AgentsTableTableManager get agents =>
      $$AgentsTableTableManager(_db, _db.agents);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$MessageRelationsTableTableManager get messageRelations =>
      $$MessageRelationsTableTableManager(_db, _db.messageRelations);
  $$PersistentDataTableTableManager get persistentData =>
      $$PersistentDataTableTableManager(_db, _db.persistentData);
  $$PersonasTableTableManager get personas =>
      $$PersonasTableTableManager(_db, _db.personas);
}
