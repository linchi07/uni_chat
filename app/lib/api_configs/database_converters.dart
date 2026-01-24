import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uni_chat/api_configs/api_models.dart';

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

class ModelParametersConverter
    extends TypeConverter<List<ModelParameters>, String> {
  @override
  List<ModelParameters> fromSql(String fromDb) {
    var s = jsonDecode(fromDb);
    return s.map((e) => ModelParameters.fromMap(e)).toList();
  }

  @override
  String toSql(List<ModelParameters> value) {
    return jsonEncode(value.map((e) => e.toMap()).toList());
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
