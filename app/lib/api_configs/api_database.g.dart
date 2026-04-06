// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_database.dart';

// ignore_for_file: type=lint
class $ModelsTable extends Models with TableInfo<$ModelsTable, Model> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _friendlyNameMeta = const VerificationMeta(
    'friendlyName',
  );
  @override
  late final GeneratedColumn<String> friendlyName = GeneratedColumn<String>(
    'friendly_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyMeta = const VerificationMeta('family');
  @override
  late final GeneratedColumn<String> family = GeneratedColumn<String>(
    'family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Set<ModelAbility>, String>
  abilities = GeneratedColumn<String>(
    'abilities',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Set<ModelAbility>>($ModelsTable.$converterabilities);
  static const VerificationMeta _contextLengthMeta = const VerificationMeta(
    'contextLength',
  );
  @override
  late final GeneratedColumn<int> contextLength = GeneratedColumn<int>(
    'context_length',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxCompletionTokensMeta =
      const VerificationMeta('maxCompletionTokens');
  @override
  late final GeneratedColumn<int> maxCompletionTokens = GeneratedColumn<int>(
    'max_completion_tokens',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<ModelParamName>?, String>
  parameters = GeneratedColumn<String>(
    'parameters',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<List<ModelParamName>?>($ModelsTable.$converterparametersn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    friendlyName,
    family,
    abilities,
    contextLength,
    maxCompletionTokens,
    parameters,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'models';
  @override
  VerificationContext validateIntegrity(
    Insertable<Model> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('friendly_name')) {
      context.handle(
        _friendlyNameMeta,
        friendlyName.isAcceptableOrUnknown(
          data['friendly_name']!,
          _friendlyNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_friendlyNameMeta);
    }
    if (data.containsKey('family')) {
      context.handle(
        _familyMeta,
        family.isAcceptableOrUnknown(data['family']!, _familyMeta),
      );
    } else if (isInserting) {
      context.missing(_familyMeta);
    }
    if (data.containsKey('context_length')) {
      context.handle(
        _contextLengthMeta,
        contextLength.isAcceptableOrUnknown(
          data['context_length']!,
          _contextLengthMeta,
        ),
      );
    }
    if (data.containsKey('max_completion_tokens')) {
      context.handle(
        _maxCompletionTokensMeta,
        maxCompletionTokens.isAcceptableOrUnknown(
          data['max_completion_tokens']!,
          _maxCompletionTokensMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {friendlyName},
  ];
  @override
  Model map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Model(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      friendlyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}friendly_name'],
      )!,
      family: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family'],
      )!,
      abilities: $ModelsTable.$converterabilities.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}abilities'],
        )!,
      ),
      contextLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}context_length'],
      ),
      maxCompletionTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_completion_tokens'],
      ),
      parameters: $ModelsTable.$converterparametersn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}parameters'],
        ),
      ),
    );
  }

  @override
  $ModelsTable createAlias(String alias) {
    return $ModelsTable(attachedDatabase, alias);
  }

  static TypeConverter<Set<ModelAbility>, String> $converterabilities =
      ModelAbilitySetConverter();
  static TypeConverter<List<ModelParamName>, String> $converterparameters =
      ModelParamListConverter();
  static TypeConverter<List<ModelParamName>?, String?> $converterparametersn =
      NullAwareTypeConverter.wrap($converterparameters);
}

class ModelsCompanion extends UpdateCompanion<Model> {
  final Value<String> id;
  final Value<String> friendlyName;
  final Value<String> family;
  final Value<Set<ModelAbility>> abilities;
  final Value<int?> contextLength;
  final Value<int?> maxCompletionTokens;
  final Value<List<ModelParamName>?> parameters;
  final Value<int> rowid;
  const ModelsCompanion({
    this.id = const Value.absent(),
    this.friendlyName = const Value.absent(),
    this.family = const Value.absent(),
    this.abilities = const Value.absent(),
    this.contextLength = const Value.absent(),
    this.maxCompletionTokens = const Value.absent(),
    this.parameters = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModelsCompanion.insert({
    required String id,
    required String friendlyName,
    required String family,
    required Set<ModelAbility> abilities,
    this.contextLength = const Value.absent(),
    this.maxCompletionTokens = const Value.absent(),
    this.parameters = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       friendlyName = Value(friendlyName),
       family = Value(family),
       abilities = Value(abilities);
  static Insertable<Model> custom({
    Expression<String>? id,
    Expression<String>? friendlyName,
    Expression<String>? family,
    Expression<String>? abilities,
    Expression<int>? contextLength,
    Expression<int>? maxCompletionTokens,
    Expression<String>? parameters,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (friendlyName != null) 'friendly_name': friendlyName,
      if (family != null) 'family': family,
      if (abilities != null) 'abilities': abilities,
      if (contextLength != null) 'context_length': contextLength,
      if (maxCompletionTokens != null)
        'max_completion_tokens': maxCompletionTokens,
      if (parameters != null) 'parameters': parameters,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModelsCompanion copyWith({
    Value<String>? id,
    Value<String>? friendlyName,
    Value<String>? family,
    Value<Set<ModelAbility>>? abilities,
    Value<int?>? contextLength,
    Value<int?>? maxCompletionTokens,
    Value<List<ModelParamName>?>? parameters,
    Value<int>? rowid,
  }) {
    return ModelsCompanion(
      id: id ?? this.id,
      friendlyName: friendlyName ?? this.friendlyName,
      family: family ?? this.family,
      abilities: abilities ?? this.abilities,
      contextLength: contextLength ?? this.contextLength,
      maxCompletionTokens: maxCompletionTokens ?? this.maxCompletionTokens,
      parameters: parameters ?? this.parameters,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (friendlyName.present) {
      map['friendly_name'] = Variable<String>(friendlyName.value);
    }
    if (family.present) {
      map['family'] = Variable<String>(family.value);
    }
    if (abilities.present) {
      map['abilities'] = Variable<String>(
        $ModelsTable.$converterabilities.toSql(abilities.value),
      );
    }
    if (contextLength.present) {
      map['context_length'] = Variable<int>(contextLength.value);
    }
    if (maxCompletionTokens.present) {
      map['max_completion_tokens'] = Variable<int>(maxCompletionTokens.value);
    }
    if (parameters.present) {
      map['parameters'] = Variable<String>(
        $ModelsTable.$converterparametersn.toSql(parameters.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModelsCompanion(')
          ..write('id: $id, ')
          ..write('friendlyName: $friendlyName, ')
          ..write('family: $family, ')
          ..write('abilities: $abilities, ')
          ..write('contextLength: $contextLength, ')
          ..write('maxCompletionTokens: $maxCompletionTokens, ')
          ..write('parameters: $parameters, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApiProvidersTable extends ApiProviders
    with TableInfo<$ApiProvidersTable, ApiProvider> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApiProvidersTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<ApiType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ApiType>($ApiProvidersTable.$convertertype);
  static const VerificationMeta _endpointMeta = const VerificationMeta(
    'endpoint',
  );
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
    'endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _presetMeta = const VerificationMeta('preset');
  @override
  late final GeneratedColumn<String> preset = GeneratedColumn<String>(
    'preset',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, type, endpoint, preset];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'api_providers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApiProvider> instance, {
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
    if (data.containsKey('endpoint')) {
      context.handle(
        _endpointMeta,
        endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta),
      );
    } else if (isInserting) {
      context.missing(_endpointMeta);
    }
    if (data.containsKey('preset')) {
      context.handle(
        _presetMeta,
        preset.isAcceptableOrUnknown(data['preset']!, _presetMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ApiProvider map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApiProvider(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $ApiProvidersTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      endpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint'],
      )!,
      preset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset'],
      ),
    );
  }

  @override
  $ApiProvidersTable createAlias(String alias) {
    return $ApiProvidersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ApiType, String, String> $convertertype =
      const EnumNameConverter<ApiType>(ApiType.values);
}

class ApiProvidersCompanion extends UpdateCompanion<ApiProvider> {
  final Value<String> id;
  final Value<String> name;
  final Value<ApiType> type;
  final Value<String> endpoint;
  final Value<String?> preset;
  final Value<int> rowid;
  const ApiProvidersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.preset = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApiProvidersCompanion.insert({
    required String id,
    required String name,
    required ApiType type,
    required String endpoint,
    this.preset = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       endpoint = Value(endpoint);
  static Insertable<ApiProvider> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? endpoint,
    Expression<String>? preset,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (endpoint != null) 'endpoint': endpoint,
      if (preset != null) 'preset': preset,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApiProvidersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<ApiType>? type,
    Value<String>? endpoint,
    Value<String?>? preset,
    Value<int>? rowid,
  }) {
    return ApiProvidersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      endpoint: endpoint ?? this.endpoint,
      preset: preset ?? this.preset,
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
    if (type.present) {
      map['type'] = Variable<String>(
        $ApiProvidersTable.$convertertype.toSql(type.value),
      );
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (preset.present) {
      map['preset'] = Variable<String>(preset.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApiProvidersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('endpoint: $endpoint, ')
          ..write('preset: $preset, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProviderModelConfigsTable extends ProviderModelConfigs
    with TableInfo<$ProviderModelConfigsTable, ProviderModelConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProviderModelConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES api_providers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES models (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _callNameMeta = const VerificationMeta(
    'callName',
  );
  @override
  late final GeneratedColumn<String> callName = GeneratedColumn<String>(
    'call_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Set<ModelAbility>?, String>
  abilitiesOverride =
      GeneratedColumn<String>(
        'abilities_override',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Set<ModelAbility>?>(
        $ProviderModelConfigsTable.$converterabilitiesOverriden,
      );
  @override
  late final GeneratedColumnWithTypeConverter<ModelPricing?, String> pricing =
      GeneratedColumn<String>(
        'pricing',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<ModelPricing?>(
        $ProviderModelConfigsTable.$converterpricingn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<List<ModelParamName>?, String>
  parametersOverride =
      GeneratedColumn<String>(
        'parameters_override',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<ModelParamName>?>(
        $ProviderModelConfigsTable.$converterparametersOverriden,
      );
  @override
  List<GeneratedColumn> get $columns => [
    providerId,
    modelId,
    callName,
    abilitiesOverride,
    pricing,
    parametersOverride,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provider_model_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProviderModelConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('call_name')) {
      context.handle(
        _callNameMeta,
        callName.isAcceptableOrUnknown(data['call_name']!, _callNameMeta),
      );
    } else if (isInserting) {
      context.missing(_callNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {providerId, modelId};
  @override
  ProviderModelConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProviderModelConfig(
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      callName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}call_name'],
      )!,
      abilitiesOverride: $ProviderModelConfigsTable.$converterabilitiesOverriden
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}abilities_override'],
            ),
          ),
      pricing: $ProviderModelConfigsTable.$converterpricingn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}pricing'],
        ),
      ),
      parametersOverride: $ProviderModelConfigsTable
          .$converterparametersOverriden
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}parameters_override'],
            ),
          ),
    );
  }

  @override
  $ProviderModelConfigsTable createAlias(String alias) {
    return $ProviderModelConfigsTable(attachedDatabase, alias);
  }

  static TypeConverter<Set<ModelAbility>, String> $converterabilitiesOverride =
      ModelAbilitySetConverter();
  static TypeConverter<Set<ModelAbility>?, String?>
  $converterabilitiesOverriden = NullAwareTypeConverter.wrap(
    $converterabilitiesOverride,
  );
  static TypeConverter<ModelPricing, String> $converterpricing =
      ModelPricingConverter();
  static TypeConverter<ModelPricing?, String?> $converterpricingn =
      NullAwareTypeConverter.wrap($converterpricing);
  static TypeConverter<List<ModelParamName>, String>
  $converterparametersOverride = ModelParamListConverter();
  static TypeConverter<List<ModelParamName>?, String?>
  $converterparametersOverriden = NullAwareTypeConverter.wrap(
    $converterparametersOverride,
  );
}

class ProviderModelConfigsCompanion
    extends UpdateCompanion<ProviderModelConfig> {
  final Value<String> providerId;
  final Value<String> modelId;
  final Value<String> callName;
  final Value<Set<ModelAbility>?> abilitiesOverride;
  final Value<ModelPricing?> pricing;
  final Value<List<ModelParamName>?> parametersOverride;
  final Value<int> rowid;
  const ProviderModelConfigsCompanion({
    this.providerId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.callName = const Value.absent(),
    this.abilitiesOverride = const Value.absent(),
    this.pricing = const Value.absent(),
    this.parametersOverride = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProviderModelConfigsCompanion.insert({
    required String providerId,
    required String modelId,
    required String callName,
    this.abilitiesOverride = const Value.absent(),
    this.pricing = const Value.absent(),
    this.parametersOverride = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : providerId = Value(providerId),
       modelId = Value(modelId),
       callName = Value(callName);
  static Insertable<ProviderModelConfig> custom({
    Expression<String>? providerId,
    Expression<String>? modelId,
    Expression<String>? callName,
    Expression<String>? abilitiesOverride,
    Expression<String>? pricing,
    Expression<String>? parametersOverride,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (providerId != null) 'provider_id': providerId,
      if (modelId != null) 'model_id': modelId,
      if (callName != null) 'call_name': callName,
      if (abilitiesOverride != null) 'abilities_override': abilitiesOverride,
      if (pricing != null) 'pricing': pricing,
      if (parametersOverride != null) 'parameters_override': parametersOverride,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProviderModelConfigsCompanion copyWith({
    Value<String>? providerId,
    Value<String>? modelId,
    Value<String>? callName,
    Value<Set<ModelAbility>?>? abilitiesOverride,
    Value<ModelPricing?>? pricing,
    Value<List<ModelParamName>?>? parametersOverride,
    Value<int>? rowid,
  }) {
    return ProviderModelConfigsCompanion(
      providerId: providerId ?? this.providerId,
      modelId: modelId ?? this.modelId,
      callName: callName ?? this.callName,
      abilitiesOverride: abilitiesOverride ?? this.abilitiesOverride,
      pricing: pricing ?? this.pricing,
      parametersOverride: parametersOverride ?? this.parametersOverride,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (callName.present) {
      map['call_name'] = Variable<String>(callName.value);
    }
    if (abilitiesOverride.present) {
      map['abilities_override'] = Variable<String>(
        $ProviderModelConfigsTable.$converterabilitiesOverriden.toSql(
          abilitiesOverride.value,
        ),
      );
    }
    if (pricing.present) {
      map['pricing'] = Variable<String>(
        $ProviderModelConfigsTable.$converterpricingn.toSql(pricing.value),
      );
    }
    if (parametersOverride.present) {
      map['parameters_override'] = Variable<String>(
        $ProviderModelConfigsTable.$converterparametersOverriden.toSql(
          parametersOverride.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProviderModelConfigsCompanion(')
          ..write('providerId: $providerId, ')
          ..write('modelId: $modelId, ')
          ..write('callName: $callName, ')
          ..write('abilitiesOverride: $abilitiesOverride, ')
          ..write('pricing: $pricing, ')
          ..write('parametersOverride: $parametersOverride, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$ProviderModelConfigInsertable
    implements Insertable<ProviderModelConfig> {
  ProviderModelConfig _object;
  _$ProviderModelConfigInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return ProviderModelConfigsCompanion(
      providerId: Value(_object.providerId),
      modelId: Value(_object.modelId),
      callName: Value(_object.callName),
      abilitiesOverride: Value(_object.abilitiesOverride),
      pricing: Value(_object.pricing),
      parametersOverride: Value(_object.parametersOverride),
    ).toColumns(false);
  }
}

extension ProviderModelConfigToInsertable on ProviderModelConfig {
  _$ProviderModelConfigInsertable toInsertable() {
    return _$ProviderModelConfigInsertable(this);
  }
}

class $ProviderPresetsTableTable extends ProviderPresetsTable
    with TableInfo<$ProviderPresetsTableTable, ProviderPresetsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProviderPresetsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
  i18nName =
      GeneratedColumn<String>(
        'i18n_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Map<String, String>>(
        $ProviderPresetsTableTable.$converteri18nName,
      );
  @override
  late final GeneratedColumnWithTypeConverter<ProviderPresetType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ProviderPresetType>(
        $ProviderPresetsTableTable.$convertertype,
      );
  static const VerificationMeta _endpointMeta = const VerificationMeta(
    'endpoint',
  );
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
    'endpoint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ApiType, String> apiType =
      GeneratedColumn<String>(
        'api_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ApiType>($ProviderPresetsTableTable.$converterapiType);
  @override
  late final GeneratedColumnWithTypeConverter<
    List<ProviderModelConfig>?,
    String
  >
  models =
      GeneratedColumn<String>(
        'models',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<ProviderModelConfig>?>(
        $ProviderPresetsTableTable.$convertermodelsn,
      );
  static const VerificationMeta _availableMeta = const VerificationMeta(
    'available',
  );
  @override
  late final GeneratedColumn<bool> available = GeneratedColumn<bool>(
    'available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("available" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    i18nName,
    type,
    endpoint,
    apiType,
    models,
    available,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'provider_presets';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProviderPresetsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('endpoint')) {
      context.handle(
        _endpointMeta,
        endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta),
      );
    }
    if (data.containsKey('available')) {
      context.handle(
        _availableMeta,
        available.isAcceptableOrUnknown(data['available']!, _availableMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProviderPresetsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProviderPresetsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      i18nName: $ProviderPresetsTableTable.$converteri18nName.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}i18n_name'],
        )!,
      ),
      type: $ProviderPresetsTableTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      endpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endpoint'],
      ),
      apiType: $ProviderPresetsTableTable.$converterapiType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}api_type'],
        )!,
      ),
      models: $ProviderPresetsTableTable.$convertermodelsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}models'],
        ),
      ),
      available: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}available'],
      )!,
    );
  }

  @override
  $ProviderPresetsTableTable createAlias(String alias) {
    return $ProviderPresetsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, String>, String> $converteri18nName =
      StringMapConverter();
  static JsonTypeConverter2<ProviderPresetType, String, String> $convertertype =
      const EnumNameConverter<ProviderPresetType>(ProviderPresetType.values);
  static JsonTypeConverter2<ApiType, String, String> $converterapiType =
      const EnumNameConverter<ApiType>(ApiType.values);
  static TypeConverter<List<ProviderModelConfig>, String> $convertermodels =
      ProviderModelConfigListConverter();
  static TypeConverter<List<ProviderModelConfig>?, String?> $convertermodelsn =
      NullAwareTypeConverter.wrap($convertermodels);
}

class ProviderPresetsTableData extends DataClass
    implements Insertable<ProviderPresetsTableData> {
  final String id;
  final Map<String, String> i18nName;
  final ProviderPresetType type;
  final String? endpoint;
  final ApiType apiType;
  final List<ProviderModelConfig>? models;
  final bool available;
  const ProviderPresetsTableData({
    required this.id,
    required this.i18nName,
    required this.type,
    this.endpoint,
    required this.apiType,
    this.models,
    required this.available,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['i18n_name'] = Variable<String>(
        $ProviderPresetsTableTable.$converteri18nName.toSql(i18nName),
      );
    }
    {
      map['type'] = Variable<String>(
        $ProviderPresetsTableTable.$convertertype.toSql(type),
      );
    }
    if (!nullToAbsent || endpoint != null) {
      map['endpoint'] = Variable<String>(endpoint);
    }
    {
      map['api_type'] = Variable<String>(
        $ProviderPresetsTableTable.$converterapiType.toSql(apiType),
      );
    }
    if (!nullToAbsent || models != null) {
      map['models'] = Variable<String>(
        $ProviderPresetsTableTable.$convertermodelsn.toSql(models),
      );
    }
    map['available'] = Variable<bool>(available);
    return map;
  }

  ProviderPresetsTableCompanion toCompanion(bool nullToAbsent) {
    return ProviderPresetsTableCompanion(
      id: Value(id),
      i18nName: Value(i18nName),
      type: Value(type),
      endpoint: endpoint == null && nullToAbsent
          ? const Value.absent()
          : Value(endpoint),
      apiType: Value(apiType),
      models: models == null && nullToAbsent
          ? const Value.absent()
          : Value(models),
      available: Value(available),
    );
  }

  factory ProviderPresetsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProviderPresetsTableData(
      id: serializer.fromJson<String>(json['id']),
      i18nName: serializer.fromJson<Map<String, String>>(json['i18nName']),
      type: $ProviderPresetsTableTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      endpoint: serializer.fromJson<String?>(json['endpoint']),
      apiType: $ProviderPresetsTableTable.$converterapiType.fromJson(
        serializer.fromJson<String>(json['apiType']),
      ),
      models: serializer.fromJson<List<ProviderModelConfig>?>(json['models']),
      available: serializer.fromJson<bool>(json['available']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'i18nName': serializer.toJson<Map<String, String>>(i18nName),
      'type': serializer.toJson<String>(
        $ProviderPresetsTableTable.$convertertype.toJson(type),
      ),
      'endpoint': serializer.toJson<String?>(endpoint),
      'apiType': serializer.toJson<String>(
        $ProviderPresetsTableTable.$converterapiType.toJson(apiType),
      ),
      'models': serializer.toJson<List<ProviderModelConfig>?>(models),
      'available': serializer.toJson<bool>(available),
    };
  }

  ProviderPresetsTableData copyWith({
    String? id,
    Map<String, String>? i18nName,
    ProviderPresetType? type,
    Value<String?> endpoint = const Value.absent(),
    ApiType? apiType,
    Value<List<ProviderModelConfig>?> models = const Value.absent(),
    bool? available,
  }) => ProviderPresetsTableData(
    id: id ?? this.id,
    i18nName: i18nName ?? this.i18nName,
    type: type ?? this.type,
    endpoint: endpoint.present ? endpoint.value : this.endpoint,
    apiType: apiType ?? this.apiType,
    models: models.present ? models.value : this.models,
    available: available ?? this.available,
  );
  ProviderPresetsTableData copyWithCompanion(
    ProviderPresetsTableCompanion data,
  ) {
    return ProviderPresetsTableData(
      id: data.id.present ? data.id.value : this.id,
      i18nName: data.i18nName.present ? data.i18nName.value : this.i18nName,
      type: data.type.present ? data.type.value : this.type,
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      apiType: data.apiType.present ? data.apiType.value : this.apiType,
      models: data.models.present ? data.models.value : this.models,
      available: data.available.present ? data.available.value : this.available,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProviderPresetsTableData(')
          ..write('id: $id, ')
          ..write('i18nName: $i18nName, ')
          ..write('type: $type, ')
          ..write('endpoint: $endpoint, ')
          ..write('apiType: $apiType, ')
          ..write('models: $models, ')
          ..write('available: $available')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, i18nName, type, endpoint, apiType, models, available);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProviderPresetsTableData &&
          other.id == this.id &&
          other.i18nName == this.i18nName &&
          other.type == this.type &&
          other.endpoint == this.endpoint &&
          other.apiType == this.apiType &&
          other.models == this.models &&
          other.available == this.available);
}

class ProviderPresetsTableCompanion
    extends UpdateCompanion<ProviderPresetsTableData> {
  final Value<String> id;
  final Value<Map<String, String>> i18nName;
  final Value<ProviderPresetType> type;
  final Value<String?> endpoint;
  final Value<ApiType> apiType;
  final Value<List<ProviderModelConfig>?> models;
  final Value<bool> available;
  final Value<int> rowid;
  const ProviderPresetsTableCompanion({
    this.id = const Value.absent(),
    this.i18nName = const Value.absent(),
    this.type = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.apiType = const Value.absent(),
    this.models = const Value.absent(),
    this.available = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProviderPresetsTableCompanion.insert({
    required String id,
    required Map<String, String> i18nName,
    required ProviderPresetType type,
    this.endpoint = const Value.absent(),
    required ApiType apiType,
    this.models = const Value.absent(),
    this.available = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       i18nName = Value(i18nName),
       type = Value(type),
       apiType = Value(apiType);
  static Insertable<ProviderPresetsTableData> custom({
    Expression<String>? id,
    Expression<String>? i18nName,
    Expression<String>? type,
    Expression<String>? endpoint,
    Expression<String>? apiType,
    Expression<String>? models,
    Expression<bool>? available,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (i18nName != null) 'i18n_name': i18nName,
      if (type != null) 'type': type,
      if (endpoint != null) 'endpoint': endpoint,
      if (apiType != null) 'api_type': apiType,
      if (models != null) 'models': models,
      if (available != null) 'available': available,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProviderPresetsTableCompanion copyWith({
    Value<String>? id,
    Value<Map<String, String>>? i18nName,
    Value<ProviderPresetType>? type,
    Value<String?>? endpoint,
    Value<ApiType>? apiType,
    Value<List<ProviderModelConfig>?>? models,
    Value<bool>? available,
    Value<int>? rowid,
  }) {
    return ProviderPresetsTableCompanion(
      id: id ?? this.id,
      i18nName: i18nName ?? this.i18nName,
      type: type ?? this.type,
      endpoint: endpoint ?? this.endpoint,
      apiType: apiType ?? this.apiType,
      models: models ?? this.models,
      available: available ?? this.available,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (i18nName.present) {
      map['i18n_name'] = Variable<String>(
        $ProviderPresetsTableTable.$converteri18nName.toSql(i18nName.value),
      );
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $ProviderPresetsTableTable.$convertertype.toSql(type.value),
      );
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (apiType.present) {
      map['api_type'] = Variable<String>(
        $ProviderPresetsTableTable.$converterapiType.toSql(apiType.value),
      );
    }
    if (models.present) {
      map['models'] = Variable<String>(
        $ProviderPresetsTableTable.$convertermodelsn.toSql(models.value),
      );
    }
    if (available.present) {
      map['available'] = Variable<bool>(available.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProviderPresetsTableCompanion(')
          ..write('id: $id, ')
          ..write('i18nName: $i18nName, ')
          ..write('type: $type, ')
          ..write('endpoint: $endpoint, ')
          ..write('apiType: $apiType, ')
          ..write('models: $models, ')
          ..write('available: $available, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApiKeysTableTable extends ApiKeysTable
    with TableInfo<$ApiKeysTableTable, ApiKeysTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApiKeysTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES api_providers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rpmMeta = const VerificationMeta('rpm');
  @override
  late final GeneratedColumn<int> rpm = GeneratedColumn<int>(
    'rpm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rpdMeta = const VerificationMeta('rpd');
  @override
  late final GeneratedColumn<int> rpd = GeneratedColumn<int>(
    'rpd',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokenLimitMeta = const VerificationMeta(
    'tokenLimit',
  );
  @override
  late final GeneratedColumn<int> tokenLimit = GeneratedColumn<int>(
    'token_limit',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _invokeDataMeta = const VerificationMeta(
    'invokeData',
  );
  @override
  late final GeneratedColumn<String> invokeData = GeneratedColumn<String>(
    'invoke_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    providerId,
    key,
    remark,
    rpm,
    rpd,
    tokenLimit,
    enabled,
    invokeData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'api_keys';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApiKeysTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    if (data.containsKey('rpm')) {
      context.handle(
        _rpmMeta,
        rpm.isAcceptableOrUnknown(data['rpm']!, _rpmMeta),
      );
    }
    if (data.containsKey('rpd')) {
      context.handle(
        _rpdMeta,
        rpd.isAcceptableOrUnknown(data['rpd']!, _rpdMeta),
      );
    }
    if (data.containsKey('token_limit')) {
      context.handle(
        _tokenLimitMeta,
        tokenLimit.isAcceptableOrUnknown(data['token_limit']!, _tokenLimitMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('invoke_data')) {
      context.handle(
        _invokeDataMeta,
        invokeData.isAcceptableOrUnknown(data['invoke_data']!, _invokeDataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ApiKeysTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApiKeysTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
      rpm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rpm'],
      ),
      rpd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rpd'],
      ),
      tokenLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}token_limit'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      invokeData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoke_data'],
      ),
    );
  }

  @override
  $ApiKeysTableTable createAlias(String alias) {
    return $ApiKeysTableTable(attachedDatabase, alias);
  }
}

class ApiKeysTableData extends DataClass
    implements Insertable<ApiKeysTableData> {
  final String id;
  final String providerId;
  final String key;
  final String? remark;
  final int? rpm;
  final int? rpd;
  final int? tokenLimit;
  final bool enabled;
  final String? invokeData;
  const ApiKeysTableData({
    required this.id,
    required this.providerId,
    required this.key,
    this.remark,
    this.rpm,
    this.rpd,
    this.tokenLimit,
    required this.enabled,
    this.invokeData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['provider_id'] = Variable<String>(providerId);
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    if (!nullToAbsent || rpm != null) {
      map['rpm'] = Variable<int>(rpm);
    }
    if (!nullToAbsent || rpd != null) {
      map['rpd'] = Variable<int>(rpd);
    }
    if (!nullToAbsent || tokenLimit != null) {
      map['token_limit'] = Variable<int>(tokenLimit);
    }
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || invokeData != null) {
      map['invoke_data'] = Variable<String>(invokeData);
    }
    return map;
  }

  ApiKeysTableCompanion toCompanion(bool nullToAbsent) {
    return ApiKeysTableCompanion(
      id: Value(id),
      providerId: Value(providerId),
      key: Value(key),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
      rpm: rpm == null && nullToAbsent ? const Value.absent() : Value(rpm),
      rpd: rpd == null && nullToAbsent ? const Value.absent() : Value(rpd),
      tokenLimit: tokenLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(tokenLimit),
      enabled: Value(enabled),
      invokeData: invokeData == null && nullToAbsent
          ? const Value.absent()
          : Value(invokeData),
    );
  }

  factory ApiKeysTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ApiKeysTableData(
      id: serializer.fromJson<String>(json['id']),
      providerId: serializer.fromJson<String>(json['providerId']),
      key: serializer.fromJson<String>(json['key']),
      remark: serializer.fromJson<String?>(json['remark']),
      rpm: serializer.fromJson<int?>(json['rpm']),
      rpd: serializer.fromJson<int?>(json['rpd']),
      tokenLimit: serializer.fromJson<int?>(json['tokenLimit']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      invokeData: serializer.fromJson<String?>(json['invokeData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'providerId': serializer.toJson<String>(providerId),
      'key': serializer.toJson<String>(key),
      'remark': serializer.toJson<String?>(remark),
      'rpm': serializer.toJson<int?>(rpm),
      'rpd': serializer.toJson<int?>(rpd),
      'tokenLimit': serializer.toJson<int?>(tokenLimit),
      'enabled': serializer.toJson<bool>(enabled),
      'invokeData': serializer.toJson<String?>(invokeData),
    };
  }

  ApiKeysTableData copyWith({
    String? id,
    String? providerId,
    String? key,
    Value<String?> remark = const Value.absent(),
    Value<int?> rpm = const Value.absent(),
    Value<int?> rpd = const Value.absent(),
    Value<int?> tokenLimit = const Value.absent(),
    bool? enabled,
    Value<String?> invokeData = const Value.absent(),
  }) => ApiKeysTableData(
    id: id ?? this.id,
    providerId: providerId ?? this.providerId,
    key: key ?? this.key,
    remark: remark.present ? remark.value : this.remark,
    rpm: rpm.present ? rpm.value : this.rpm,
    rpd: rpd.present ? rpd.value : this.rpd,
    tokenLimit: tokenLimit.present ? tokenLimit.value : this.tokenLimit,
    enabled: enabled ?? this.enabled,
    invokeData: invokeData.present ? invokeData.value : this.invokeData,
  );
  ApiKeysTableData copyWithCompanion(ApiKeysTableCompanion data) {
    return ApiKeysTableData(
      id: data.id.present ? data.id.value : this.id,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      key: data.key.present ? data.key.value : this.key,
      remark: data.remark.present ? data.remark.value : this.remark,
      rpm: data.rpm.present ? data.rpm.value : this.rpm,
      rpd: data.rpd.present ? data.rpd.value : this.rpd,
      tokenLimit: data.tokenLimit.present
          ? data.tokenLimit.value
          : this.tokenLimit,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      invokeData: data.invokeData.present
          ? data.invokeData.value
          : this.invokeData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ApiKeysTableData(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('key: $key, ')
          ..write('remark: $remark, ')
          ..write('rpm: $rpm, ')
          ..write('rpd: $rpd, ')
          ..write('tokenLimit: $tokenLimit, ')
          ..write('enabled: $enabled, ')
          ..write('invokeData: $invokeData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    providerId,
    key,
    remark,
    rpm,
    rpd,
    tokenLimit,
    enabled,
    invokeData,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApiKeysTableData &&
          other.id == this.id &&
          other.providerId == this.providerId &&
          other.key == this.key &&
          other.remark == this.remark &&
          other.rpm == this.rpm &&
          other.rpd == this.rpd &&
          other.tokenLimit == this.tokenLimit &&
          other.enabled == this.enabled &&
          other.invokeData == this.invokeData);
}

class ApiKeysTableCompanion extends UpdateCompanion<ApiKeysTableData> {
  final Value<String> id;
  final Value<String> providerId;
  final Value<String> key;
  final Value<String?> remark;
  final Value<int?> rpm;
  final Value<int?> rpd;
  final Value<int?> tokenLimit;
  final Value<bool> enabled;
  final Value<String?> invokeData;
  final Value<int> rowid;
  const ApiKeysTableCompanion({
    this.id = const Value.absent(),
    this.providerId = const Value.absent(),
    this.key = const Value.absent(),
    this.remark = const Value.absent(),
    this.rpm = const Value.absent(),
    this.rpd = const Value.absent(),
    this.tokenLimit = const Value.absent(),
    this.enabled = const Value.absent(),
    this.invokeData = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApiKeysTableCompanion.insert({
    required String id,
    required String providerId,
    required String key,
    this.remark = const Value.absent(),
    this.rpm = const Value.absent(),
    this.rpd = const Value.absent(),
    this.tokenLimit = const Value.absent(),
    this.enabled = const Value.absent(),
    this.invokeData = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       providerId = Value(providerId),
       key = Value(key);
  static Insertable<ApiKeysTableData> custom({
    Expression<String>? id,
    Expression<String>? providerId,
    Expression<String>? key,
    Expression<String>? remark,
    Expression<int>? rpm,
    Expression<int>? rpd,
    Expression<int>? tokenLimit,
    Expression<bool>? enabled,
    Expression<String>? invokeData,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (providerId != null) 'provider_id': providerId,
      if (key != null) 'key': key,
      if (remark != null) 'remark': remark,
      if (rpm != null) 'rpm': rpm,
      if (rpd != null) 'rpd': rpd,
      if (tokenLimit != null) 'token_limit': tokenLimit,
      if (enabled != null) 'enabled': enabled,
      if (invokeData != null) 'invoke_data': invokeData,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApiKeysTableCompanion copyWith({
    Value<String>? id,
    Value<String>? providerId,
    Value<String>? key,
    Value<String?>? remark,
    Value<int?>? rpm,
    Value<int?>? rpd,
    Value<int?>? tokenLimit,
    Value<bool>? enabled,
    Value<String?>? invokeData,
    Value<int>? rowid,
  }) {
    return ApiKeysTableCompanion(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      key: key ?? this.key,
      remark: remark ?? this.remark,
      rpm: rpm ?? this.rpm,
      rpd: rpd ?? this.rpd,
      tokenLimit: tokenLimit ?? this.tokenLimit,
      enabled: enabled ?? this.enabled,
      invokeData: invokeData ?? this.invokeData,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (rpm.present) {
      map['rpm'] = Variable<int>(rpm.value);
    }
    if (rpd.present) {
      map['rpd'] = Variable<int>(rpd.value);
    }
    if (tokenLimit.present) {
      map['token_limit'] = Variable<int>(tokenLimit.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (invokeData.present) {
      map['invoke_data'] = Variable<String>(invokeData.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApiKeysTableCompanion(')
          ..write('id: $id, ')
          ..write('providerId: $providerId, ')
          ..write('key: $key, ')
          ..write('remark: $remark, ')
          ..write('rpm: $rpm, ')
          ..write('rpd: $rpd, ')
          ..write('tokenLimit: $tokenLimit, ')
          ..write('enabled: $enabled, ')
          ..write('invokeData: $invokeData, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApiKeyUsagesTable extends ApiKeyUsages
    with TableInfo<$ApiKeyUsagesTable, ApiKeyUsage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApiKeyUsagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _apiKeyIdMeta = const VerificationMeta(
    'apiKeyId',
  );
  @override
  late final GeneratedColumn<String> apiKeyId = GeneratedColumn<String>(
    'api_key_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES api_keys (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
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
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TokenUsage, String> usage =
      GeneratedColumn<String>(
        'usage',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TokenUsage>($ApiKeyUsagesTable.$converterusage);
  static const VerificationMeta _promptTokensMeta = const VerificationMeta(
    'promptTokens',
  );
  @override
  late final GeneratedColumn<int> promptTokens = GeneratedColumn<int>(
    'prompt_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completionTokensMeta = const VerificationMeta(
    'completionTokens',
  );
  @override
  late final GeneratedColumn<int> completionTokens = GeneratedColumn<int>(
    'completion_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalTokensMeta = const VerificationMeta(
    'totalTokens',
  );
  @override
  late final GeneratedColumn<int> totalTokens = GeneratedColumn<int>(
    'total_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cachedTokensMeta = const VerificationMeta(
    'cachedTokens',
  );
  @override
  late final GeneratedColumn<int> cachedTokens = GeneratedColumn<int>(
    'cached_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    apiKeyId,
    modelId,
    agentId,
    time,
    usage,
    promptTokens,
    completionTokens,
    totalTokens,
    cachedTokens,
    cost,
    currency,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'api_key_usages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApiKeyUsage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('api_key_id')) {
      context.handle(
        _apiKeyIdMeta,
        apiKeyId.isAcceptableOrUnknown(data['api_key_id']!, _apiKeyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_apiKeyIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('agent_id')) {
      context.handle(
        _agentIdMeta,
        agentId.isAcceptableOrUnknown(data['agent_id']!, _agentIdMeta),
      );
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('prompt_tokens')) {
      context.handle(
        _promptTokensMeta,
        promptTokens.isAcceptableOrUnknown(
          data['prompt_tokens']!,
          _promptTokensMeta,
        ),
      );
    }
    if (data.containsKey('completion_tokens')) {
      context.handle(
        _completionTokensMeta,
        completionTokens.isAcceptableOrUnknown(
          data['completion_tokens']!,
          _completionTokensMeta,
        ),
      );
    }
    if (data.containsKey('total_tokens')) {
      context.handle(
        _totalTokensMeta,
        totalTokens.isAcceptableOrUnknown(
          data['total_tokens']!,
          _totalTokensMeta,
        ),
      );
    }
    if (data.containsKey('cached_tokens')) {
      context.handle(
        _cachedTokensMeta,
        cachedTokens.isAcceptableOrUnknown(
          data['cached_tokens']!,
          _cachedTokensMeta,
        ),
      );
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ApiKeyUsage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApiKeyUsage(
      apiKeyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_key_id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      agentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_id'],
      ),
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
      usage: $ApiKeyUsagesTable.$converterusage.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}usage'],
        )!,
      ),
      promptTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prompt_tokens'],
      )!,
      completionTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completion_tokens'],
      )!,
      totalTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_tokens'],
      )!,
      cachedTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cached_tokens'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      ),
    );
  }

  @override
  $ApiKeyUsagesTable createAlias(String alias) {
    return $ApiKeyUsagesTable(attachedDatabase, alias);
  }

  static TypeConverter<TokenUsage, String> $converterusage =
      TokenUsageConverter();
}

class ApiKeyUsagesCompanion extends UpdateCompanion<ApiKeyUsage> {
  final Value<String> apiKeyId;
  final Value<String> modelId;
  final Value<String?> agentId;
  final Value<DateTime> time;
  final Value<TokenUsage> usage;
  final Value<int> promptTokens;
  final Value<int> completionTokens;
  final Value<int> totalTokens;
  final Value<int> cachedTokens;
  final Value<double?> cost;
  final Value<String?> currency;
  final Value<int> rowid;
  const ApiKeyUsagesCompanion({
    this.apiKeyId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.agentId = const Value.absent(),
    this.time = const Value.absent(),
    this.usage = const Value.absent(),
    this.promptTokens = const Value.absent(),
    this.completionTokens = const Value.absent(),
    this.totalTokens = const Value.absent(),
    this.cachedTokens = const Value.absent(),
    this.cost = const Value.absent(),
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApiKeyUsagesCompanion.insert({
    required String apiKeyId,
    required String modelId,
    this.agentId = const Value.absent(),
    required DateTime time,
    required TokenUsage usage,
    this.promptTokens = const Value.absent(),
    this.completionTokens = const Value.absent(),
    this.totalTokens = const Value.absent(),
    this.cachedTokens = const Value.absent(),
    this.cost = const Value.absent(),
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : apiKeyId = Value(apiKeyId),
       modelId = Value(modelId),
       time = Value(time),
       usage = Value(usage);
  static Insertable<ApiKeyUsage> custom({
    Expression<String>? apiKeyId,
    Expression<String>? modelId,
    Expression<String>? agentId,
    Expression<DateTime>? time,
    Expression<String>? usage,
    Expression<int>? promptTokens,
    Expression<int>? completionTokens,
    Expression<int>? totalTokens,
    Expression<int>? cachedTokens,
    Expression<double>? cost,
    Expression<String>? currency,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (apiKeyId != null) 'api_key_id': apiKeyId,
      if (modelId != null) 'model_id': modelId,
      if (agentId != null) 'agent_id': agentId,
      if (time != null) 'time': time,
      if (usage != null) 'usage': usage,
      if (promptTokens != null) 'prompt_tokens': promptTokens,
      if (completionTokens != null) 'completion_tokens': completionTokens,
      if (totalTokens != null) 'total_tokens': totalTokens,
      if (cachedTokens != null) 'cached_tokens': cachedTokens,
      if (cost != null) 'cost': cost,
      if (currency != null) 'currency': currency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApiKeyUsagesCompanion copyWith({
    Value<String>? apiKeyId,
    Value<String>? modelId,
    Value<String?>? agentId,
    Value<DateTime>? time,
    Value<TokenUsage>? usage,
    Value<int>? promptTokens,
    Value<int>? completionTokens,
    Value<int>? totalTokens,
    Value<int>? cachedTokens,
    Value<double?>? cost,
    Value<String?>? currency,
    Value<int>? rowid,
  }) {
    return ApiKeyUsagesCompanion(
      apiKeyId: apiKeyId ?? this.apiKeyId,
      modelId: modelId ?? this.modelId,
      agentId: agentId ?? this.agentId,
      time: time ?? this.time,
      usage: usage ?? this.usage,
      promptTokens: promptTokens ?? this.promptTokens,
      completionTokens: completionTokens ?? this.completionTokens,
      totalTokens: totalTokens ?? this.totalTokens,
      cachedTokens: cachedTokens ?? this.cachedTokens,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (apiKeyId.present) {
      map['api_key_id'] = Variable<String>(apiKeyId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (agentId.present) {
      map['agent_id'] = Variable<String>(agentId.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (usage.present) {
      map['usage'] = Variable<String>(
        $ApiKeyUsagesTable.$converterusage.toSql(usage.value),
      );
    }
    if (promptTokens.present) {
      map['prompt_tokens'] = Variable<int>(promptTokens.value);
    }
    if (completionTokens.present) {
      map['completion_tokens'] = Variable<int>(completionTokens.value);
    }
    if (totalTokens.present) {
      map['total_tokens'] = Variable<int>(totalTokens.value);
    }
    if (cachedTokens.present) {
      map['cached_tokens'] = Variable<int>(cachedTokens.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApiKeyUsagesCompanion(')
          ..write('apiKeyId: $apiKeyId, ')
          ..write('modelId: $modelId, ')
          ..write('agentId: $agentId, ')
          ..write('time: $time, ')
          ..write('usage: $usage, ')
          ..write('promptTokens: $promptTokens, ')
          ..write('completionTokens: $completionTokens, ')
          ..write('totalTokens: $totalTokens, ')
          ..write('cachedTokens: $cachedTokens, ')
          ..write('cost: $cost, ')
          ..write('currency: $currency, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$_ApiDb extends GeneratedDatabase {
  _$_ApiDb(QueryExecutor e) : super(e);
  $_ApiDbManager get managers => $_ApiDbManager(this);
  late final $ModelsTable models = $ModelsTable(this);
  late final $ApiProvidersTable apiProviders = $ApiProvidersTable(this);
  late final $ProviderModelConfigsTable providerModelConfigs =
      $ProviderModelConfigsTable(this);
  late final $ProviderPresetsTableTable providerPresetsTable =
      $ProviderPresetsTableTable(this);
  late final $ApiKeysTableTable apiKeysTable = $ApiKeysTableTable(this);
  late final $ApiKeyUsagesTable apiKeyUsages = $ApiKeyUsagesTable(this);
  late final Index keyUsageTimeIdx = Index(
    'key_usage_time_idx',
    'CREATE INDEX key_usage_time_idx ON api_key_usages (time)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    models,
    apiProviders,
    providerModelConfigs,
    providerPresetsTable,
    apiKeysTable,
    apiKeyUsages,
    keyUsageTimeIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'api_providers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('provider_model_configs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'models',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('provider_model_configs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'api_providers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('api_keys', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'api_keys',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('api_key_usages', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ModelsTableCreateCompanionBuilder =
    ModelsCompanion Function({
      required String id,
      required String friendlyName,
      required String family,
      required Set<ModelAbility> abilities,
      Value<int?> contextLength,
      Value<int?> maxCompletionTokens,
      Value<List<ModelParamName>?> parameters,
      Value<int> rowid,
    });
typedef $$ModelsTableUpdateCompanionBuilder =
    ModelsCompanion Function({
      Value<String> id,
      Value<String> friendlyName,
      Value<String> family,
      Value<Set<ModelAbility>> abilities,
      Value<int?> contextLength,
      Value<int?> maxCompletionTokens,
      Value<List<ModelParamName>?> parameters,
      Value<int> rowid,
    });

final class $$ModelsTableReferences
    extends BaseReferences<_$_ApiDb, $ModelsTable, Model> {
  $$ModelsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $ProviderModelConfigsTable,
    List<ProviderModelConfig>
  >
  _providerModelConfigsRefsTable(_$_ApiDb db) => MultiTypedResultKey.fromTable(
    db.providerModelConfigs,
    aliasName: $_aliasNameGenerator(
      db.models.id,
      db.providerModelConfigs.modelId,
    ),
  );

  $$ProviderModelConfigsTableProcessedTableManager
  get providerModelConfigsRefs {
    final manager = $$ProviderModelConfigsTableTableManager(
      $_db,
      $_db.providerModelConfigs,
    ).filter((f) => f.modelId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _providerModelConfigsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ModelsTableFilterComposer extends Composer<_$_ApiDb, $ModelsTable> {
  $$ModelsTableFilterComposer({
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

  ColumnFilters<String> get friendlyName => $composableBuilder(
    column: $table.friendlyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Set<ModelAbility>, Set<ModelAbility>, String>
  get abilities => $composableBuilder(
    column: $table.abilities,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get contextLength => $composableBuilder(
    column: $table.contextLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxCompletionTokens => $composableBuilder(
    column: $table.maxCompletionTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<ModelParamName>?,
    List<ModelParamName>,
    String
  >
  get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> providerModelConfigsRefs(
    Expression<bool> Function($$ProviderModelConfigsTableFilterComposer f) f,
  ) {
    final $$ProviderModelConfigsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.providerModelConfigs,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProviderModelConfigsTableFilterComposer(
            $db: $db,
            $table: $db.providerModelConfigs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ModelsTableOrderingComposer extends Composer<_$_ApiDb, $ModelsTable> {
  $$ModelsTableOrderingComposer({
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

  ColumnOrderings<String> get friendlyName => $composableBuilder(
    column: $table.friendlyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abilities => $composableBuilder(
    column: $table.abilities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contextLength => $composableBuilder(
    column: $table.contextLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxCompletionTokens => $composableBuilder(
    column: $table.maxCompletionTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModelsTableAnnotationComposer extends Composer<_$_ApiDb, $ModelsTable> {
  $$ModelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get friendlyName => $composableBuilder(
    column: $table.friendlyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get family =>
      $composableBuilder(column: $table.family, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Set<ModelAbility>, String> get abilities =>
      $composableBuilder(column: $table.abilities, builder: (column) => column);

  GeneratedColumn<int> get contextLength => $composableBuilder(
    column: $table.contextLength,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxCompletionTokens => $composableBuilder(
    column: $table.maxCompletionTokens,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<ModelParamName>?, String>
  get parameters => $composableBuilder(
    column: $table.parameters,
    builder: (column) => column,
  );

  Expression<T> providerModelConfigsRefs<T extends Object>(
    Expression<T> Function($$ProviderModelConfigsTableAnnotationComposer a) f,
  ) {
    final $$ProviderModelConfigsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.providerModelConfigs,
          getReferencedColumn: (t) => t.modelId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProviderModelConfigsTableAnnotationComposer(
                $db: $db,
                $table: $db.providerModelConfigs,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ModelsTableTableManager
    extends
        RootTableManager<
          _$_ApiDb,
          $ModelsTable,
          Model,
          $$ModelsTableFilterComposer,
          $$ModelsTableOrderingComposer,
          $$ModelsTableAnnotationComposer,
          $$ModelsTableCreateCompanionBuilder,
          $$ModelsTableUpdateCompanionBuilder,
          (Model, $$ModelsTableReferences),
          Model,
          PrefetchHooks Function({bool providerModelConfigsRefs})
        > {
  $$ModelsTableTableManager(_$_ApiDb db, $ModelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> friendlyName = const Value.absent(),
                Value<String> family = const Value.absent(),
                Value<Set<ModelAbility>> abilities = const Value.absent(),
                Value<int?> contextLength = const Value.absent(),
                Value<int?> maxCompletionTokens = const Value.absent(),
                Value<List<ModelParamName>?> parameters = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModelsCompanion(
                id: id,
                friendlyName: friendlyName,
                family: family,
                abilities: abilities,
                contextLength: contextLength,
                maxCompletionTokens: maxCompletionTokens,
                parameters: parameters,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String friendlyName,
                required String family,
                required Set<ModelAbility> abilities,
                Value<int?> contextLength = const Value.absent(),
                Value<int?> maxCompletionTokens = const Value.absent(),
                Value<List<ModelParamName>?> parameters = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModelsCompanion.insert(
                id: id,
                friendlyName: friendlyName,
                family: family,
                abilities: abilities,
                contextLength: contextLength,
                maxCompletionTokens: maxCompletionTokens,
                parameters: parameters,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ModelsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({providerModelConfigsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (providerModelConfigsRefs) db.providerModelConfigs,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (providerModelConfigsRefs)
                    await $_getPrefetchedData<
                      Model,
                      $ModelsTable,
                      ProviderModelConfig
                    >(
                      currentTable: table,
                      referencedTable: $$ModelsTableReferences
                          ._providerModelConfigsRefsTable(db),
                      managerFromTypedResult: (p0) => $$ModelsTableReferences(
                        db,
                        table,
                        p0,
                      ).providerModelConfigsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.modelId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ModelsTableProcessedTableManager =
    ProcessedTableManager<
      _$_ApiDb,
      $ModelsTable,
      Model,
      $$ModelsTableFilterComposer,
      $$ModelsTableOrderingComposer,
      $$ModelsTableAnnotationComposer,
      $$ModelsTableCreateCompanionBuilder,
      $$ModelsTableUpdateCompanionBuilder,
      (Model, $$ModelsTableReferences),
      Model,
      PrefetchHooks Function({bool providerModelConfigsRefs})
    >;
typedef $$ApiProvidersTableCreateCompanionBuilder =
    ApiProvidersCompanion Function({
      required String id,
      required String name,
      required ApiType type,
      required String endpoint,
      Value<String?> preset,
      Value<int> rowid,
    });
typedef $$ApiProvidersTableUpdateCompanionBuilder =
    ApiProvidersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<ApiType> type,
      Value<String> endpoint,
      Value<String?> preset,
      Value<int> rowid,
    });

final class $$ApiProvidersTableReferences
    extends BaseReferences<_$_ApiDb, $ApiProvidersTable, ApiProvider> {
  $$ApiProvidersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $ProviderModelConfigsTable,
    List<ProviderModelConfig>
  >
  _providerModelConfigsRefsTable(_$_ApiDb db) => MultiTypedResultKey.fromTable(
    db.providerModelConfigs,
    aliasName: $_aliasNameGenerator(
      db.apiProviders.id,
      db.providerModelConfigs.providerId,
    ),
  );

  $$ProviderModelConfigsTableProcessedTableManager
  get providerModelConfigsRefs {
    final manager = $$ProviderModelConfigsTableTableManager(
      $_db,
      $_db.providerModelConfigs,
    ).filter((f) => f.providerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _providerModelConfigsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ApiKeysTableTable, List<ApiKeysTableData>>
  _apiKeysTableRefsTable(_$_ApiDb db) => MultiTypedResultKey.fromTable(
    db.apiKeysTable,
    aliasName: $_aliasNameGenerator(
      db.apiProviders.id,
      db.apiKeysTable.providerId,
    ),
  );

  $$ApiKeysTableTableProcessedTableManager get apiKeysTableRefs {
    final manager = $$ApiKeysTableTableTableManager(
      $_db,
      $_db.apiKeysTable,
    ).filter((f) => f.providerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_apiKeysTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ApiProvidersTableFilterComposer
    extends Composer<_$_ApiDb, $ApiProvidersTable> {
  $$ApiProvidersTableFilterComposer({
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

  ColumnWithTypeConverterFilters<ApiType, ApiType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preset => $composableBuilder(
    column: $table.preset,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> providerModelConfigsRefs(
    Expression<bool> Function($$ProviderModelConfigsTableFilterComposer f) f,
  ) {
    final $$ProviderModelConfigsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.providerModelConfigs,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProviderModelConfigsTableFilterComposer(
            $db: $db,
            $table: $db.providerModelConfigs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> apiKeysTableRefs(
    Expression<bool> Function($$ApiKeysTableTableFilterComposer f) f,
  ) {
    final $$ApiKeysTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.apiKeysTable,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApiKeysTableTableFilterComposer(
            $db: $db,
            $table: $db.apiKeysTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ApiProvidersTableOrderingComposer
    extends Composer<_$_ApiDb, $ApiProvidersTable> {
  $$ApiProvidersTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preset => $composableBuilder(
    column: $table.preset,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ApiProvidersTableAnnotationComposer
    extends Composer<_$_ApiDb, $ApiProvidersTable> {
  $$ApiProvidersTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<ApiType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<String> get preset =>
      $composableBuilder(column: $table.preset, builder: (column) => column);

  Expression<T> providerModelConfigsRefs<T extends Object>(
    Expression<T> Function($$ProviderModelConfigsTableAnnotationComposer a) f,
  ) {
    final $$ProviderModelConfigsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.providerModelConfigs,
          getReferencedColumn: (t) => t.providerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProviderModelConfigsTableAnnotationComposer(
                $db: $db,
                $table: $db.providerModelConfigs,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> apiKeysTableRefs<T extends Object>(
    Expression<T> Function($$ApiKeysTableTableAnnotationComposer a) f,
  ) {
    final $$ApiKeysTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.apiKeysTable,
      getReferencedColumn: (t) => t.providerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApiKeysTableTableAnnotationComposer(
            $db: $db,
            $table: $db.apiKeysTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ApiProvidersTableTableManager
    extends
        RootTableManager<
          _$_ApiDb,
          $ApiProvidersTable,
          ApiProvider,
          $$ApiProvidersTableFilterComposer,
          $$ApiProvidersTableOrderingComposer,
          $$ApiProvidersTableAnnotationComposer,
          $$ApiProvidersTableCreateCompanionBuilder,
          $$ApiProvidersTableUpdateCompanionBuilder,
          (ApiProvider, $$ApiProvidersTableReferences),
          ApiProvider,
          PrefetchHooks Function({
            bool providerModelConfigsRefs,
            bool apiKeysTableRefs,
          })
        > {
  $$ApiProvidersTableTableManager(_$_ApiDb db, $ApiProvidersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApiProvidersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApiProvidersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApiProvidersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<ApiType> type = const Value.absent(),
                Value<String> endpoint = const Value.absent(),
                Value<String?> preset = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiProvidersCompanion(
                id: id,
                name: name,
                type: type,
                endpoint: endpoint,
                preset: preset,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required ApiType type,
                required String endpoint,
                Value<String?> preset = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiProvidersCompanion.insert(
                id: id,
                name: name,
                type: type,
                endpoint: endpoint,
                preset: preset,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ApiProvidersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({providerModelConfigsRefs = false, apiKeysTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (providerModelConfigsRefs) db.providerModelConfigs,
                    if (apiKeysTableRefs) db.apiKeysTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (providerModelConfigsRefs)
                        await $_getPrefetchedData<
                          ApiProvider,
                          $ApiProvidersTable,
                          ProviderModelConfig
                        >(
                          currentTable: table,
                          referencedTable: $$ApiProvidersTableReferences
                              ._providerModelConfigsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ApiProvidersTableReferences(
                                db,
                                table,
                                p0,
                              ).providerModelConfigsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.providerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (apiKeysTableRefs)
                        await $_getPrefetchedData<
                          ApiProvider,
                          $ApiProvidersTable,
                          ApiKeysTableData
                        >(
                          currentTable: table,
                          referencedTable: $$ApiProvidersTableReferences
                              ._apiKeysTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ApiProvidersTableReferences(
                                db,
                                table,
                                p0,
                              ).apiKeysTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.providerId == item.id,
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

typedef $$ApiProvidersTableProcessedTableManager =
    ProcessedTableManager<
      _$_ApiDb,
      $ApiProvidersTable,
      ApiProvider,
      $$ApiProvidersTableFilterComposer,
      $$ApiProvidersTableOrderingComposer,
      $$ApiProvidersTableAnnotationComposer,
      $$ApiProvidersTableCreateCompanionBuilder,
      $$ApiProvidersTableUpdateCompanionBuilder,
      (ApiProvider, $$ApiProvidersTableReferences),
      ApiProvider,
      PrefetchHooks Function({
        bool providerModelConfigsRefs,
        bool apiKeysTableRefs,
      })
    >;
typedef $$ProviderModelConfigsTableCreateCompanionBuilder =
    ProviderModelConfigsCompanion Function({
      required String providerId,
      required String modelId,
      required String callName,
      Value<Set<ModelAbility>?> abilitiesOverride,
      Value<ModelPricing?> pricing,
      Value<List<ModelParamName>?> parametersOverride,
      Value<int> rowid,
    });
typedef $$ProviderModelConfigsTableUpdateCompanionBuilder =
    ProviderModelConfigsCompanion Function({
      Value<String> providerId,
      Value<String> modelId,
      Value<String> callName,
      Value<Set<ModelAbility>?> abilitiesOverride,
      Value<ModelPricing?> pricing,
      Value<List<ModelParamName>?> parametersOverride,
      Value<int> rowid,
    });

final class $$ProviderModelConfigsTableReferences
    extends
        BaseReferences<
          _$_ApiDb,
          $ProviderModelConfigsTable,
          ProviderModelConfig
        > {
  $$ProviderModelConfigsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ApiProvidersTable _providerIdTable(_$_ApiDb db) =>
      db.apiProviders.createAlias(
        $_aliasNameGenerator(
          db.providerModelConfigs.providerId,
          db.apiProviders.id,
        ),
      );

  $$ApiProvidersTableProcessedTableManager get providerId {
    final $_column = $_itemColumn<String>('provider_id')!;

    final manager = $$ApiProvidersTableTableManager(
      $_db,
      $_db.apiProviders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_providerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ModelsTable _modelIdTable(_$_ApiDb db) => db.models.createAlias(
    $_aliasNameGenerator(db.providerModelConfigs.modelId, db.models.id),
  );

  $$ModelsTableProcessedTableManager get modelId {
    final $_column = $_itemColumn<String>('model_id')!;

    final manager = $$ModelsTableTableManager(
      $_db,
      $_db.models,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_modelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProviderModelConfigsTableFilterComposer
    extends Composer<_$_ApiDb, $ProviderModelConfigsTable> {
  $$ProviderModelConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get callName => $composableBuilder(
    column: $table.callName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Set<ModelAbility>?, Set<ModelAbility>, String>
  get abilitiesOverride => $composableBuilder(
    column: $table.abilitiesOverride,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ModelPricing?, ModelPricing, String>
  get pricing => $composableBuilder(
    column: $table.pricing,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<ModelParamName>?,
    List<ModelParamName>,
    String
  >
  get parametersOverride => $composableBuilder(
    column: $table.parametersOverride,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$ApiProvidersTableFilterComposer get providerId {
    final $$ApiProvidersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.apiProviders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApiProvidersTableFilterComposer(
            $db: $db,
            $table: $db.apiProviders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ModelsTableFilterComposer get modelId {
    final $$ModelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.models,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModelsTableFilterComposer(
            $db: $db,
            $table: $db.models,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProviderModelConfigsTableOrderingComposer
    extends Composer<_$_ApiDb, $ProviderModelConfigsTable> {
  $$ProviderModelConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get callName => $composableBuilder(
    column: $table.callName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get abilitiesOverride => $composableBuilder(
    column: $table.abilitiesOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pricing => $composableBuilder(
    column: $table.pricing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parametersOverride => $composableBuilder(
    column: $table.parametersOverride,
    builder: (column) => ColumnOrderings(column),
  );

  $$ApiProvidersTableOrderingComposer get providerId {
    final $$ApiProvidersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.apiProviders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApiProvidersTableOrderingComposer(
            $db: $db,
            $table: $db.apiProviders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ModelsTableOrderingComposer get modelId {
    final $$ModelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.models,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModelsTableOrderingComposer(
            $db: $db,
            $table: $db.models,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProviderModelConfigsTableAnnotationComposer
    extends Composer<_$_ApiDb, $ProviderModelConfigsTable> {
  $$ProviderModelConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get callName =>
      $composableBuilder(column: $table.callName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Set<ModelAbility>?, String>
  get abilitiesOverride => $composableBuilder(
    column: $table.abilitiesOverride,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ModelPricing?, String> get pricing =>
      $composableBuilder(column: $table.pricing, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<ModelParamName>?, String>
  get parametersOverride => $composableBuilder(
    column: $table.parametersOverride,
    builder: (column) => column,
  );

  $$ApiProvidersTableAnnotationComposer get providerId {
    final $$ApiProvidersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.apiProviders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApiProvidersTableAnnotationComposer(
            $db: $db,
            $table: $db.apiProviders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ModelsTableAnnotationComposer get modelId {
    final $$ModelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.models,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ModelsTableAnnotationComposer(
            $db: $db,
            $table: $db.models,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProviderModelConfigsTableTableManager
    extends
        RootTableManager<
          _$_ApiDb,
          $ProviderModelConfigsTable,
          ProviderModelConfig,
          $$ProviderModelConfigsTableFilterComposer,
          $$ProviderModelConfigsTableOrderingComposer,
          $$ProviderModelConfigsTableAnnotationComposer,
          $$ProviderModelConfigsTableCreateCompanionBuilder,
          $$ProviderModelConfigsTableUpdateCompanionBuilder,
          (ProviderModelConfig, $$ProviderModelConfigsTableReferences),
          ProviderModelConfig,
          PrefetchHooks Function({bool providerId, bool modelId})
        > {
  $$ProviderModelConfigsTableTableManager(
    _$_ApiDb db,
    $ProviderModelConfigsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProviderModelConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProviderModelConfigsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProviderModelConfigsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> providerId = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String> callName = const Value.absent(),
                Value<Set<ModelAbility>?> abilitiesOverride =
                    const Value.absent(),
                Value<ModelPricing?> pricing = const Value.absent(),
                Value<List<ModelParamName>?> parametersOverride =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProviderModelConfigsCompanion(
                providerId: providerId,
                modelId: modelId,
                callName: callName,
                abilitiesOverride: abilitiesOverride,
                pricing: pricing,
                parametersOverride: parametersOverride,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String providerId,
                required String modelId,
                required String callName,
                Value<Set<ModelAbility>?> abilitiesOverride =
                    const Value.absent(),
                Value<ModelPricing?> pricing = const Value.absent(),
                Value<List<ModelParamName>?> parametersOverride =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProviderModelConfigsCompanion.insert(
                providerId: providerId,
                modelId: modelId,
                callName: callName,
                abilitiesOverride: abilitiesOverride,
                pricing: pricing,
                parametersOverride: parametersOverride,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProviderModelConfigsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({providerId = false, modelId = false}) {
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
                    if (providerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.providerId,
                                referencedTable:
                                    $$ProviderModelConfigsTableReferences
                                        ._providerIdTable(db),
                                referencedColumn:
                                    $$ProviderModelConfigsTableReferences
                                        ._providerIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (modelId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.modelId,
                                referencedTable:
                                    $$ProviderModelConfigsTableReferences
                                        ._modelIdTable(db),
                                referencedColumn:
                                    $$ProviderModelConfigsTableReferences
                                        ._modelIdTable(db)
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

typedef $$ProviderModelConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$_ApiDb,
      $ProviderModelConfigsTable,
      ProviderModelConfig,
      $$ProviderModelConfigsTableFilterComposer,
      $$ProviderModelConfigsTableOrderingComposer,
      $$ProviderModelConfigsTableAnnotationComposer,
      $$ProviderModelConfigsTableCreateCompanionBuilder,
      $$ProviderModelConfigsTableUpdateCompanionBuilder,
      (ProviderModelConfig, $$ProviderModelConfigsTableReferences),
      ProviderModelConfig,
      PrefetchHooks Function({bool providerId, bool modelId})
    >;
typedef $$ProviderPresetsTableTableCreateCompanionBuilder =
    ProviderPresetsTableCompanion Function({
      required String id,
      required Map<String, String> i18nName,
      required ProviderPresetType type,
      Value<String?> endpoint,
      required ApiType apiType,
      Value<List<ProviderModelConfig>?> models,
      Value<bool> available,
      Value<int> rowid,
    });
typedef $$ProviderPresetsTableTableUpdateCompanionBuilder =
    ProviderPresetsTableCompanion Function({
      Value<String> id,
      Value<Map<String, String>> i18nName,
      Value<ProviderPresetType> type,
      Value<String?> endpoint,
      Value<ApiType> apiType,
      Value<List<ProviderModelConfig>?> models,
      Value<bool> available,
      Value<int> rowid,
    });

class $$ProviderPresetsTableTableFilterComposer
    extends Composer<_$_ApiDb, $ProviderPresetsTableTable> {
  $$ProviderPresetsTableTableFilterComposer({
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

  ColumnWithTypeConverterFilters<
    Map<String, String>,
    Map<String, String>,
    String
  >
  get i18nName => $composableBuilder(
    column: $table.i18nName,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ProviderPresetType, ProviderPresetType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ApiType, ApiType, String> get apiType =>
      $composableBuilder(
        column: $table.apiType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<
    List<ProviderModelConfig>?,
    List<ProviderModelConfig>,
    String
  >
  get models => $composableBuilder(
    column: $table.models,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get available => $composableBuilder(
    column: $table.available,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProviderPresetsTableTableOrderingComposer
    extends Composer<_$_ApiDb, $ProviderPresetsTableTable> {
  $$ProviderPresetsTableTableOrderingComposer({
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

  ColumnOrderings<String> get i18nName => $composableBuilder(
    column: $table.i18nName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endpoint => $composableBuilder(
    column: $table.endpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiType => $composableBuilder(
    column: $table.apiType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get models => $composableBuilder(
    column: $table.models,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get available => $composableBuilder(
    column: $table.available,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProviderPresetsTableTableAnnotationComposer
    extends Composer<_$_ApiDb, $ProviderPresetsTableTable> {
  $$ProviderPresetsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String> get i18nName =>
      $composableBuilder(column: $table.i18nName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ProviderPresetType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ApiType, String> get apiType =>
      $composableBuilder(column: $table.apiType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<ProviderModelConfig>?, String>
  get models =>
      $composableBuilder(column: $table.models, builder: (column) => column);

  GeneratedColumn<bool> get available =>
      $composableBuilder(column: $table.available, builder: (column) => column);
}

class $$ProviderPresetsTableTableTableManager
    extends
        RootTableManager<
          _$_ApiDb,
          $ProviderPresetsTableTable,
          ProviderPresetsTableData,
          $$ProviderPresetsTableTableFilterComposer,
          $$ProviderPresetsTableTableOrderingComposer,
          $$ProviderPresetsTableTableAnnotationComposer,
          $$ProviderPresetsTableTableCreateCompanionBuilder,
          $$ProviderPresetsTableTableUpdateCompanionBuilder,
          (
            ProviderPresetsTableData,
            BaseReferences<
              _$_ApiDb,
              $ProviderPresetsTableTable,
              ProviderPresetsTableData
            >,
          ),
          ProviderPresetsTableData,
          PrefetchHooks Function()
        > {
  $$ProviderPresetsTableTableTableManager(
    _$_ApiDb db,
    $ProviderPresetsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProviderPresetsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProviderPresetsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProviderPresetsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Map<String, String>> i18nName = const Value.absent(),
                Value<ProviderPresetType> type = const Value.absent(),
                Value<String?> endpoint = const Value.absent(),
                Value<ApiType> apiType = const Value.absent(),
                Value<List<ProviderModelConfig>?> models = const Value.absent(),
                Value<bool> available = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProviderPresetsTableCompanion(
                id: id,
                i18nName: i18nName,
                type: type,
                endpoint: endpoint,
                apiType: apiType,
                models: models,
                available: available,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required Map<String, String> i18nName,
                required ProviderPresetType type,
                Value<String?> endpoint = const Value.absent(),
                required ApiType apiType,
                Value<List<ProviderModelConfig>?> models = const Value.absent(),
                Value<bool> available = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProviderPresetsTableCompanion.insert(
                id: id,
                i18nName: i18nName,
                type: type,
                endpoint: endpoint,
                apiType: apiType,
                models: models,
                available: available,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProviderPresetsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$_ApiDb,
      $ProviderPresetsTableTable,
      ProviderPresetsTableData,
      $$ProviderPresetsTableTableFilterComposer,
      $$ProviderPresetsTableTableOrderingComposer,
      $$ProviderPresetsTableTableAnnotationComposer,
      $$ProviderPresetsTableTableCreateCompanionBuilder,
      $$ProviderPresetsTableTableUpdateCompanionBuilder,
      (
        ProviderPresetsTableData,
        BaseReferences<
          _$_ApiDb,
          $ProviderPresetsTableTable,
          ProviderPresetsTableData
        >,
      ),
      ProviderPresetsTableData,
      PrefetchHooks Function()
    >;
typedef $$ApiKeysTableTableCreateCompanionBuilder =
    ApiKeysTableCompanion Function({
      required String id,
      required String providerId,
      required String key,
      Value<String?> remark,
      Value<int?> rpm,
      Value<int?> rpd,
      Value<int?> tokenLimit,
      Value<bool> enabled,
      Value<String?> invokeData,
      Value<int> rowid,
    });
typedef $$ApiKeysTableTableUpdateCompanionBuilder =
    ApiKeysTableCompanion Function({
      Value<String> id,
      Value<String> providerId,
      Value<String> key,
      Value<String?> remark,
      Value<int?> rpm,
      Value<int?> rpd,
      Value<int?> tokenLimit,
      Value<bool> enabled,
      Value<String?> invokeData,
      Value<int> rowid,
    });

final class $$ApiKeysTableTableReferences
    extends BaseReferences<_$_ApiDb, $ApiKeysTableTable, ApiKeysTableData> {
  $$ApiKeysTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ApiProvidersTable _providerIdTable(_$_ApiDb db) =>
      db.apiProviders.createAlias(
        $_aliasNameGenerator(db.apiKeysTable.providerId, db.apiProviders.id),
      );

  $$ApiProvidersTableProcessedTableManager get providerId {
    final $_column = $_itemColumn<String>('provider_id')!;

    final manager = $$ApiProvidersTableTableManager(
      $_db,
      $_db.apiProviders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_providerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ApiKeyUsagesTable, List<ApiKeyUsage>>
  _apiKeyUsagesRefsTable(_$_ApiDb db) => MultiTypedResultKey.fromTable(
    db.apiKeyUsages,
    aliasName: $_aliasNameGenerator(
      db.apiKeysTable.id,
      db.apiKeyUsages.apiKeyId,
    ),
  );

  $$ApiKeyUsagesTableProcessedTableManager get apiKeyUsagesRefs {
    final manager = $$ApiKeyUsagesTableTableManager(
      $_db,
      $_db.apiKeyUsages,
    ).filter((f) => f.apiKeyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_apiKeyUsagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ApiKeysTableTableFilterComposer
    extends Composer<_$_ApiDb, $ApiKeysTableTable> {
  $$ApiKeysTableTableFilterComposer({
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

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rpm => $composableBuilder(
    column: $table.rpm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rpd => $composableBuilder(
    column: $table.rpd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokenLimit => $composableBuilder(
    column: $table.tokenLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invokeData => $composableBuilder(
    column: $table.invokeData,
    builder: (column) => ColumnFilters(column),
  );

  $$ApiProvidersTableFilterComposer get providerId {
    final $$ApiProvidersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.apiProviders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApiProvidersTableFilterComposer(
            $db: $db,
            $table: $db.apiProviders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> apiKeyUsagesRefs(
    Expression<bool> Function($$ApiKeyUsagesTableFilterComposer f) f,
  ) {
    final $$ApiKeyUsagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.apiKeyUsages,
      getReferencedColumn: (t) => t.apiKeyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApiKeyUsagesTableFilterComposer(
            $db: $db,
            $table: $db.apiKeyUsages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ApiKeysTableTableOrderingComposer
    extends Composer<_$_ApiDb, $ApiKeysTableTable> {
  $$ApiKeysTableTableOrderingComposer({
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

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rpm => $composableBuilder(
    column: $table.rpm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rpd => $composableBuilder(
    column: $table.rpd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokenLimit => $composableBuilder(
    column: $table.tokenLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invokeData => $composableBuilder(
    column: $table.invokeData,
    builder: (column) => ColumnOrderings(column),
  );

  $$ApiProvidersTableOrderingComposer get providerId {
    final $$ApiProvidersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.apiProviders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApiProvidersTableOrderingComposer(
            $db: $db,
            $table: $db.apiProviders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ApiKeysTableTableAnnotationComposer
    extends Composer<_$_ApiDb, $ApiKeysTableTable> {
  $$ApiKeysTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);

  GeneratedColumn<int> get rpm =>
      $composableBuilder(column: $table.rpm, builder: (column) => column);

  GeneratedColumn<int> get rpd =>
      $composableBuilder(column: $table.rpd, builder: (column) => column);

  GeneratedColumn<int> get tokenLimit => $composableBuilder(
    column: $table.tokenLimit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get invokeData => $composableBuilder(
    column: $table.invokeData,
    builder: (column) => column,
  );

  $$ApiProvidersTableAnnotationComposer get providerId {
    final $$ApiProvidersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.providerId,
      referencedTable: $db.apiProviders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApiProvidersTableAnnotationComposer(
            $db: $db,
            $table: $db.apiProviders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> apiKeyUsagesRefs<T extends Object>(
    Expression<T> Function($$ApiKeyUsagesTableAnnotationComposer a) f,
  ) {
    final $$ApiKeyUsagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.apiKeyUsages,
      getReferencedColumn: (t) => t.apiKeyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApiKeyUsagesTableAnnotationComposer(
            $db: $db,
            $table: $db.apiKeyUsages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ApiKeysTableTableTableManager
    extends
        RootTableManager<
          _$_ApiDb,
          $ApiKeysTableTable,
          ApiKeysTableData,
          $$ApiKeysTableTableFilterComposer,
          $$ApiKeysTableTableOrderingComposer,
          $$ApiKeysTableTableAnnotationComposer,
          $$ApiKeysTableTableCreateCompanionBuilder,
          $$ApiKeysTableTableUpdateCompanionBuilder,
          (ApiKeysTableData, $$ApiKeysTableTableReferences),
          ApiKeysTableData,
          PrefetchHooks Function({bool providerId, bool apiKeyUsagesRefs})
        > {
  $$ApiKeysTableTableTableManager(_$_ApiDb db, $ApiKeysTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApiKeysTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApiKeysTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApiKeysTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int?> rpm = const Value.absent(),
                Value<int?> rpd = const Value.absent(),
                Value<int?> tokenLimit = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String?> invokeData = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiKeysTableCompanion(
                id: id,
                providerId: providerId,
                key: key,
                remark: remark,
                rpm: rpm,
                rpd: rpd,
                tokenLimit: tokenLimit,
                enabled: enabled,
                invokeData: invokeData,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String providerId,
                required String key,
                Value<String?> remark = const Value.absent(),
                Value<int?> rpm = const Value.absent(),
                Value<int?> rpd = const Value.absent(),
                Value<int?> tokenLimit = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String?> invokeData = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiKeysTableCompanion.insert(
                id: id,
                providerId: providerId,
                key: key,
                remark: remark,
                rpm: rpm,
                rpd: rpd,
                tokenLimit: tokenLimit,
                enabled: enabled,
                invokeData: invokeData,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ApiKeysTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({providerId = false, apiKeyUsagesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (apiKeyUsagesRefs) db.apiKeyUsages,
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
                        if (providerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.providerId,
                                    referencedTable:
                                        $$ApiKeysTableTableReferences
                                            ._providerIdTable(db),
                                    referencedColumn:
                                        $$ApiKeysTableTableReferences
                                            ._providerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (apiKeyUsagesRefs)
                        await $_getPrefetchedData<
                          ApiKeysTableData,
                          $ApiKeysTableTable,
                          ApiKeyUsage
                        >(
                          currentTable: table,
                          referencedTable: $$ApiKeysTableTableReferences
                              ._apiKeyUsagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ApiKeysTableTableReferences(
                                db,
                                table,
                                p0,
                              ).apiKeyUsagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.apiKeyId == item.id,
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

typedef $$ApiKeysTableTableProcessedTableManager =
    ProcessedTableManager<
      _$_ApiDb,
      $ApiKeysTableTable,
      ApiKeysTableData,
      $$ApiKeysTableTableFilterComposer,
      $$ApiKeysTableTableOrderingComposer,
      $$ApiKeysTableTableAnnotationComposer,
      $$ApiKeysTableTableCreateCompanionBuilder,
      $$ApiKeysTableTableUpdateCompanionBuilder,
      (ApiKeysTableData, $$ApiKeysTableTableReferences),
      ApiKeysTableData,
      PrefetchHooks Function({bool providerId, bool apiKeyUsagesRefs})
    >;
typedef $$ApiKeyUsagesTableCreateCompanionBuilder =
    ApiKeyUsagesCompanion Function({
      required String apiKeyId,
      required String modelId,
      Value<String?> agentId,
      required DateTime time,
      required TokenUsage usage,
      Value<int> promptTokens,
      Value<int> completionTokens,
      Value<int> totalTokens,
      Value<int> cachedTokens,
      Value<double?> cost,
      Value<String?> currency,
      Value<int> rowid,
    });
typedef $$ApiKeyUsagesTableUpdateCompanionBuilder =
    ApiKeyUsagesCompanion Function({
      Value<String> apiKeyId,
      Value<String> modelId,
      Value<String?> agentId,
      Value<DateTime> time,
      Value<TokenUsage> usage,
      Value<int> promptTokens,
      Value<int> completionTokens,
      Value<int> totalTokens,
      Value<int> cachedTokens,
      Value<double?> cost,
      Value<String?> currency,
      Value<int> rowid,
    });

final class $$ApiKeyUsagesTableReferences
    extends BaseReferences<_$_ApiDb, $ApiKeyUsagesTable, ApiKeyUsage> {
  $$ApiKeyUsagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ApiKeysTableTable _apiKeyIdTable(_$_ApiDb db) =>
      db.apiKeysTable.createAlias(
        $_aliasNameGenerator(db.apiKeyUsages.apiKeyId, db.apiKeysTable.id),
      );

  $$ApiKeysTableTableProcessedTableManager get apiKeyId {
    final $_column = $_itemColumn<String>('api_key_id')!;

    final manager = $$ApiKeysTableTableTableManager(
      $_db,
      $_db.apiKeysTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_apiKeyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ApiKeyUsagesTableFilterComposer
    extends Composer<_$_ApiDb, $ApiKeyUsagesTable> {
  $$ApiKeyUsagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentId => $composableBuilder(
    column: $table.agentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TokenUsage, TokenUsage, String> get usage =>
      $composableBuilder(
        column: $table.usage,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get promptTokens => $composableBuilder(
    column: $table.promptTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completionTokens => $composableBuilder(
    column: $table.completionTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalTokens => $composableBuilder(
    column: $table.totalTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cachedTokens => $composableBuilder(
    column: $table.cachedTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  $$ApiKeysTableTableFilterComposer get apiKeyId {
    final $$ApiKeysTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apiKeyId,
      referencedTable: $db.apiKeysTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApiKeysTableTableFilterComposer(
            $db: $db,
            $table: $db.apiKeysTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ApiKeyUsagesTableOrderingComposer
    extends Composer<_$_ApiDb, $ApiKeyUsagesTable> {
  $$ApiKeyUsagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentId => $composableBuilder(
    column: $table.agentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usage => $composableBuilder(
    column: $table.usage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get promptTokens => $composableBuilder(
    column: $table.promptTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completionTokens => $composableBuilder(
    column: $table.completionTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalTokens => $composableBuilder(
    column: $table.totalTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cachedTokens => $composableBuilder(
    column: $table.cachedTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  $$ApiKeysTableTableOrderingComposer get apiKeyId {
    final $$ApiKeysTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apiKeyId,
      referencedTable: $db.apiKeysTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApiKeysTableTableOrderingComposer(
            $db: $db,
            $table: $db.apiKeysTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ApiKeyUsagesTableAnnotationComposer
    extends Composer<_$_ApiDb, $ApiKeyUsagesTable> {
  $$ApiKeyUsagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get agentId =>
      $composableBuilder(column: $table.agentId, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TokenUsage, String> get usage =>
      $composableBuilder(column: $table.usage, builder: (column) => column);

  GeneratedColumn<int> get promptTokens => $composableBuilder(
    column: $table.promptTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completionTokens => $composableBuilder(
    column: $table.completionTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalTokens => $composableBuilder(
    column: $table.totalTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cachedTokens => $composableBuilder(
    column: $table.cachedTokens,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  $$ApiKeysTableTableAnnotationComposer get apiKeyId {
    final $$ApiKeysTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apiKeyId,
      referencedTable: $db.apiKeysTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApiKeysTableTableAnnotationComposer(
            $db: $db,
            $table: $db.apiKeysTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ApiKeyUsagesTableTableManager
    extends
        RootTableManager<
          _$_ApiDb,
          $ApiKeyUsagesTable,
          ApiKeyUsage,
          $$ApiKeyUsagesTableFilterComposer,
          $$ApiKeyUsagesTableOrderingComposer,
          $$ApiKeyUsagesTableAnnotationComposer,
          $$ApiKeyUsagesTableCreateCompanionBuilder,
          $$ApiKeyUsagesTableUpdateCompanionBuilder,
          (ApiKeyUsage, $$ApiKeyUsagesTableReferences),
          ApiKeyUsage,
          PrefetchHooks Function({bool apiKeyId})
        > {
  $$ApiKeyUsagesTableTableManager(_$_ApiDb db, $ApiKeyUsagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApiKeyUsagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApiKeyUsagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApiKeyUsagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> apiKeyId = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String?> agentId = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<TokenUsage> usage = const Value.absent(),
                Value<int> promptTokens = const Value.absent(),
                Value<int> completionTokens = const Value.absent(),
                Value<int> totalTokens = const Value.absent(),
                Value<int> cachedTokens = const Value.absent(),
                Value<double?> cost = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiKeyUsagesCompanion(
                apiKeyId: apiKeyId,
                modelId: modelId,
                agentId: agentId,
                time: time,
                usage: usage,
                promptTokens: promptTokens,
                completionTokens: completionTokens,
                totalTokens: totalTokens,
                cachedTokens: cachedTokens,
                cost: cost,
                currency: currency,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String apiKeyId,
                required String modelId,
                Value<String?> agentId = const Value.absent(),
                required DateTime time,
                required TokenUsage usage,
                Value<int> promptTokens = const Value.absent(),
                Value<int> completionTokens = const Value.absent(),
                Value<int> totalTokens = const Value.absent(),
                Value<int> cachedTokens = const Value.absent(),
                Value<double?> cost = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiKeyUsagesCompanion.insert(
                apiKeyId: apiKeyId,
                modelId: modelId,
                agentId: agentId,
                time: time,
                usage: usage,
                promptTokens: promptTokens,
                completionTokens: completionTokens,
                totalTokens: totalTokens,
                cachedTokens: cachedTokens,
                cost: cost,
                currency: currency,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ApiKeyUsagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({apiKeyId = false}) {
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
                    if (apiKeyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.apiKeyId,
                                referencedTable: $$ApiKeyUsagesTableReferences
                                    ._apiKeyIdTable(db),
                                referencedColumn: $$ApiKeyUsagesTableReferences
                                    ._apiKeyIdTable(db)
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

typedef $$ApiKeyUsagesTableProcessedTableManager =
    ProcessedTableManager<
      _$_ApiDb,
      $ApiKeyUsagesTable,
      ApiKeyUsage,
      $$ApiKeyUsagesTableFilterComposer,
      $$ApiKeyUsagesTableOrderingComposer,
      $$ApiKeyUsagesTableAnnotationComposer,
      $$ApiKeyUsagesTableCreateCompanionBuilder,
      $$ApiKeyUsagesTableUpdateCompanionBuilder,
      (ApiKeyUsage, $$ApiKeyUsagesTableReferences),
      ApiKeyUsage,
      PrefetchHooks Function({bool apiKeyId})
    >;

class $_ApiDbManager {
  final _$_ApiDb _db;
  $_ApiDbManager(this._db);
  $$ModelsTableTableManager get models =>
      $$ModelsTableTableManager(_db, _db.models);
  $$ApiProvidersTableTableManager get apiProviders =>
      $$ApiProvidersTableTableManager(_db, _db.apiProviders);
  $$ProviderModelConfigsTableTableManager get providerModelConfigs =>
      $$ProviderModelConfigsTableTableManager(_db, _db.providerModelConfigs);
  $$ProviderPresetsTableTableTableManager get providerPresetsTable =>
      $$ProviderPresetsTableTableTableManager(_db, _db.providerPresetsTable);
  $$ApiKeysTableTableTableManager get apiKeysTable =>
      $$ApiKeysTableTableTableManager(_db, _db.apiKeysTable);
  $$ApiKeyUsagesTableTableManager get apiKeyUsages =>
      $$ApiKeyUsagesTableTableManager(_db, _db.apiKeyUsages);
}
