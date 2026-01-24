import 'package:drift/drift.dart';
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/api_configs/database_converters.dart';

@UseRowClass(Model)
class Models extends Table {
  TextColumn get id => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get friendlyName => text()();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
    {friendlyName},
  ];

  TextColumn get family => text()();
  TextColumn get abilities => text().map(ModelAbilitySetConverter())();
  IntColumn get contextLength => integer().nullable()();
  IntColumn get maxCompletionTokens => integer().nullable()();
  TextColumn get pricing => text().nullable().map(ModelPricingConverter())();
  TextColumn get parameters =>
      text().nullable().map(ModelParametersConverter())();
}

@UseRowClass(ProviderModelConfig, generateInsertable: true)
class ProviderModelConfigs extends Table {
  TextColumn get providerId =>
      text().references(ApiProviders, #id, onDelete: KeyAction.cascade)();
  TextColumn get modelId =>
      text().references(Models, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {providerId, modelId};

  TextColumn get callName => text()();
  TextColumn get abilitiesOverride =>
      text().nullable().map(ModelAbilitySetConverter())();
  TextColumn get pricingOverride =>
      text().nullable().map(ModelPricingConverter())();
  TextColumn get parametersOverride =>
      text().nullable().map(ModelParametersConverter())();
}

class ProviderPresetsTable extends Table {
  @override
  String? get tableName => "provider_presets";
  TextColumn get id => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get i18nName => text().map(StringMapConverter())();
  TextColumn get type => textEnum<ProviderPresetType>()();
  TextColumn get endpoint => text().nullable()();
  TextColumn get apiType => textEnum<ApiType>()();
  TextColumn get models =>
      text().nullable().map(ProviderModelConfigListConverter())();
  BoolColumn get available => boolean().withDefault(const Constant(true))();
}

@UseRowClass(ApiProvider)
class ApiProviders extends Table {
  TextColumn get id => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get name => text()();
  TextColumn get type => textEnum<ApiType>()();
  TextColumn get endpoint => text()();

  TextColumn get preset => text().nullable()();
}

@UseRowClass(ApiKeyUsage)
@TableIndex(name: "key_usage_time_idx", columns: {#time})
class ApiKeyUsages extends Table {
  TextColumn get apiKeyId =>
      text().references(ApiKeysTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get providerId => text()();
  TextColumn get modelId => text()();
  TextColumn get agentId => text().nullable()();
  DateTimeColumn get time => dateTime()();
  TextColumn get usage => text().map(TokenUsageConverter())();
}

class ApiKeysTable extends Table {
  @override
  String? get tableName => "api_keys";

  TextColumn get id => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get providerId =>
      text().references(ApiProviders, #id, onDelete: KeyAction.cascade)();
  TextColumn get key => text()();
  TextColumn get remark => text().nullable()();
  IntColumn get rpm => integer().nullable()();
  IntColumn get rpd => integer().nullable()();
  IntColumn get tokenLimit => integer().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  // 下面是动态信息
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAvailableTime => dateTime().nullable()();
  IntColumn get lastStatusCode => integer().nullable()();

  IntColumn get todayUsedTokens => integer().withDefault(const Constant(0))();
  IntColumn get requestToday => integer().withDefault(const Constant(0))();
  DateTimeColumn get resetTime => dateTime().nullable()();
}
