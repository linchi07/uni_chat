import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uni_chat/api_configs/api_models.dart';

import '../utils/llm_icons.dart';

class ModelAbilitySetConverter
    extends TypeConverter<Set<ModelAbility>, String> {
  @override
  Set<ModelAbility> fromSql(String fromDb) =>
      XModelAlibity.fromList(fromDb.split(','));

  @override
  String toSql(Set<ModelAbility> value) => XModelAlibity.toDatabaseSet(value);
}

class ModelPricingConverter extends TypeConverter<ModelPricing, String> {
  @override
  ModelPricing fromSql(String fromDb) =>
      ModelPricing.fromMap(jsonDecode(fromDb));

  @override
  String toSql(ModelPricing value) => jsonEncode(value.toMap());
}

class ModelParamListConverter
    extends TypeConverter<List<ModelParamName>, String> {
  @override
  List<ModelParamName> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return fromDb
        .split(',')
        .map((e) => ModelParamName.values.byName(e))
        .toList();
  }

  @override
  String toSql(List<ModelParamName> value) {
    return value.map((e) => e.name).join(',');
  }
}

class ModelParamValueMapConverter
    extends TypeConverter<Map<ModelParamName, dynamic>, String> {
  @override
  Map<ModelParamName, dynamic> fromSql(String fromDb) {
    final Map<String, dynamic> decoded = jsonDecode(fromDb);
    return decoded.map(
      (key, value) => MapEntry(ModelParamName.values.byName(key), value),
    );
  }

  @override
  String toSql(Map<ModelParamName, dynamic> value) {
    return jsonEncode(value.map((key, value) => MapEntry(key.name, value)));
  }
}

class StringMapConverter extends TypeConverter<Map<String, String>, String> {
  @override
  Map<String, String> fromSql(String fromDb) =>
      Map.from(jsonDecode(fromDb) as Map<String, dynamic>);

  @override
  String toSql(Map<String, String> value) => jsonEncode(value);
}

class ProviderModelConfigListConverter
    extends TypeConverter<List<ProviderModelConfig>, String> {
  @override
  List<ProviderModelConfig> fromSql(String fromDb) {
    var s = jsonDecode(fromDb) as List<dynamic>;
    return s.map((e) => ProviderModelConfig.fromMap(e)).toList();
  }

  @override
  String toSql(List<ProviderModelConfig> value) {
    return jsonEncode(value.map((e) => e.toMap()).toList());
  }
}

class TokenUsageConverter extends TypeConverter<TokenUsage, String> {
  @override
  TokenUsage fromSql(String fromDb) => TokenUsage.fromMap(jsonDecode(fromDb));

  @override
  String toSql(TokenUsage value) => jsonEncode(value.toMap());
}
