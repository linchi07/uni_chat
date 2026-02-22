import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:uni_chat/api_configs/api_database.dart';

import '../generated/l10n.dart' show S;

class ApiProvider implements Insertable<ApiProvider> {
  final String id;
  final String name;
  final ApiType type;
  final String endpoint;
  final String? preset;

  ApiProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.endpoint,
    this.preset,
  });

  factory ApiProvider.fromMap(Map<String, dynamic> map) {
    return ApiProvider(
      id: map['id'],
      name: map['name'],
      type: XApiType.fromName(map['type']),
      endpoint: map['endpoint'],
      preset: map['preset'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'endpoint': endpoint,
      'preset': preset,
    };
  }

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return ApiProvidersCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      endpoint: Value(endpoint),
      preset: Value(preset),
    ).toColumns(nullToAbsent);
  }
}

class ApiKey implements Insertable<ApiKeysTableData> {
  final String providerId;
  String id;
  String key;
  String? remark;
  int? rpm;
  int? rpd;
  int? tokenLimit;
  bool enabled;

  ApiKey(
    this.providerId,
    this.id,
    this.key, {
    this.remark,
    this.rpm,
    this.rpd,
    this.tokenLimit,
    this.enabled = true,
  });

  bool enableAdvanced() {
    return rpm != null || rpd != null || tokenLimit != null;
  }

  ApiKey copyWith({
    String? providerId,
    String? id,
    String? key,
    String? remark,
    int? priority,
    int? rpm,
    int? rpd,
    int? tokenLimit,
    bool? isEnabled,
  }) {
    return ApiKey(
      providerId ?? this.providerId,
      id ?? this.id,
      key ?? this.key,
      remark: remark ?? this.remark,
      rpm: rpm ?? this.rpm,
      rpd: rpd ?? this.rpd,
      tokenLimit: tokenLimit ?? this.tokenLimit,
      enabled: isEnabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'provider_id': providerId,
      'id': id,
      'key': key,
      'remark': remark,
      'rpm': rpm,
      'rpd': rpd,
      'token_limit': tokenLimit,
      'is_enabled': enabled ? 1 : 0,
    };
  }

  factory ApiKey.fromMap(Map<String, dynamic> map) {
    return ApiKey(
      map['provider_id'],
      map['id'],
      map['key'],
      remark: map['remark'],
      rpm: map['rpm'],
      rpd: map['rpd'],
      tokenLimit: map['token_limit'],
      enabled: map['is_enabled'] == 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiKey &&
        other.providerId == providerId &&
        other.id == id &&
        other.key == key &&
        other.remark == remark &&
        other.rpm == rpm &&
        other.rpd == rpd &&
        other.tokenLimit == tokenLimit &&
        other.enabled == enabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      providerId,
      id,
      key,
      remark,
      rpm,
      rpd,
      tokenLimit,
      enabled,
    );
  }

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return ApiKeysTableCompanion(
      providerId: Value(providerId),
      id: Value(id),
      key: Value(key),
      remark: Value(remark),
      rpm: Value(rpm),
      rpd: Value(rpd),
      tokenLimit: Value(tokenLimit),
      enabled: Value(enabled),
    ).toColumns(nullToAbsent);
  }
}

@immutable
class TokenUsage {
  final int promptTokens;
  final int completionTokens;
  final int cachedTokens;
  final int cotTokens;
  final int otherTokens;
  int get total =>
      promptTokens + completionTokens + cachedTokens + cotTokens + otherTokens;

  const TokenUsage({
    required this.promptTokens,
    required this.completionTokens,
    this.cachedTokens = 0,
    this.cotTokens = 0,
    this.otherTokens = 0,
  });

  factory TokenUsage.fromMap(Map<String, dynamic> map) {
    return TokenUsage(
      promptTokens: map['promptTokens'],
      completionTokens: map['completionTokens'],
      cachedTokens: map['cachedTokens'],
      cotTokens: map['cotTokens'],
      otherTokens: map['otherTokens'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'promptTokens': promptTokens,
      'completionTokens': completionTokens,
      'cachedTokens': cachedTokens,
      'cotTokens': cotTokens,
      'otherTokens': otherTokens,
    };
  }
}

@immutable
class ApiKeyUsage implements Insertable<ApiKeyUsage> {
  final String apiKeyId;
  final String modelId;
  final String? agentId;
  final DateTime time;
  final TokenUsage usage;

  const ApiKeyUsage({
    required this.apiKeyId,
    required this.modelId,
    this.agentId,
    required this.time,
    required this.usage,
  });

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return ApiKeyUsagesCompanion(
      apiKeyId: Value(apiKeyId),
      modelId: Value(modelId),
      agentId: Value(agentId),
      time: Value(time),
      usage: Value(usage),
    ).toColumns(nullToAbsent);
  }
}

enum ModelAbility {
  textGenerate,
  imageGenerate,
  image2imageGenerate,
  file,
  visual,
  embedding,
  audio,
  video,
}

extension XModelAlibity on ModelAbility {
  String name(BuildContext context) {
    switch (this) {
      case ModelAbility.textGenerate:
        return S.of(context).textGenerate;
      case ModelAbility.imageGenerate:
        return S.of(context).imageGenerate;
      case ModelAbility.image2imageGenerate:
        return S.of(context).image2imageGenerate;
      case ModelAbility.visual:
        return S.of(context).visual;
      case ModelAbility.file:
        return S.of(context).file;
      case ModelAbility.embedding:
        return S.of(context).embedding;
      case ModelAbility.audio:
        return S.of(context).audio;
      case ModelAbility.video:
        return S.of(context).video;
    }
  }

  String get simpleString {
    switch (this) {
      case ModelAbility.textGenerate:
        return 'textGenerate';
      case ModelAbility.imageGenerate:
        return 'imageGenerate';
      case ModelAbility.image2imageGenerate:
        return 'image2imageGenerate';
      case ModelAbility.file:
        return 'pdfUnderstanding';
      case ModelAbility.visual:
        return 'visual';
      case ModelAbility.embedding:
        return 'embedding';
      case ModelAbility.audio:
        return 'audio';
      case ModelAbility.video:
        return 'video';
    }
  }

  static String toDatabaseSet(Iterable<ModelAbility> abilities) {
    return abilities.map((e) => e.simpleString).join(',');
  }

  static Set<ModelAbility> fromList(List<dynamic> list) {
    Map<String, ModelAbility> map = {
      'textGenerate': ModelAbility.textGenerate,
      'imageGenerate': ModelAbility.imageGenerate,
      'image2imageGenerate': ModelAbility.image2imageGenerate,
      'pdfUnderstanding': ModelAbility.file,
      'visualUnderstanding': ModelAbility.visual,
      'embedding': ModelAbility.embedding,
      'audio': ModelAbility.audio,
      'video': ModelAbility.video,
    };
    Set<ModelAbility> abilities = {};
    for (var ability in list) {
      if (map.containsKey(ability as String)) {
        abilities.add(map[ability]!);
      }
    }
    return abilities;
  }

  //验证互斥的能力
  Set<ModelAbility> validate(Set<ModelAbility> abilities) {
    if (abilities.contains(ModelAbility.embedding)) {
      return {ModelAbility.embedding};
    }
    return abilities;
  }

  ///在勾选能力的时候验证互斥能力
  Set<ModelAbility> checkIfValid(
    Set<ModelAbility> abilities,
    ModelAbility ability,
  ) {
    if (ability == ModelAbility.embedding) {
      return {ModelAbility.embedding};
    } else if (abilities.contains(ModelAbility.embedding)) {
      abilities.remove(ModelAbility.embedding);
    }
    abilities.add(ability);
    return abilities;
  }
}

class ModelPricing {
  final double prompt;
  final double completion;
  final double? image;
  final double? webSearch;

  ModelPricing({
    required this.prompt,
    required this.completion,
    required this.image,
    required this.webSearch,
  });

  factory ModelPricing.fromMap(Map<String, dynamic> map) {
    return ModelPricing(
      prompt: map['prompt'],
      completion: map['completion'],
      image: map['image'],
      webSearch: map['web_search'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prompt': prompt,
      'completion': completion,
      'image': image,
      'web_search': webSearch,
    };
  }
}

class Model implements Insertable<Model> {
  final String id;
  final String friendlyName;
  final String family;
  final Set<ModelAbility> abilities;
  final int? contextLength;
  final int? maxCompletionTokens;
  final ModelPricing? pricing;
  final List<ModelParameters>? parameters;

  Model({
    required this.id,
    required this.friendlyName,
    required this.family,
    required this.abilities,
    this.contextLength,
    this.maxCompletionTokens,
    this.pricing,
    this.parameters,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'friendly_name': friendlyName,
      'family': family,
      'abilities': jsonEncode(
        abilities.map((ability) => ability.simpleString).toList(),
      ),
      'context_length': contextLength,
      'max_completion_tokens': maxCompletionTokens,
      'pricing': jsonEncode(pricing?.toMap()),
      'parameters': parameters?.map((parameter) => parameter.toMap()).toList(),
    };
  }

  factory Model.fromMap(Map<String, dynamic> map) {
    List<ModelParameters>? parameters;
    var pr = map['parameters'];
    if (pr != null) {
      parameters = ModelParameters.fromMap(pr);
      if (parameters.isEmpty) {
        parameters = null;
      }
    }
    return Model(
      id: map['id'],
      family: map['family'],
      friendlyName: map['friendly_name'],
      abilities: XModelAlibity.fromList((jsonDecode(map['abilities']) as List)),
      contextLength: map['context_length'],
      maxCompletionTokens: map['max_completion_tokens'],
      pricing: map['pricing'] != null
          ? ModelPricing.fromMap(jsonDecode(map['pricing']))
          : null,
      parameters: parameters,
    );
  }

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return ModelsCompanion(
      id: Value(id),
      friendlyName: Value(friendlyName),
      family: Value(family),
      abilities: Value(abilities),
      contextLength: Value(contextLength),
      maxCompletionTokens: Value(maxCompletionTokens),
      pricing: Value(pricing),
      parameters: Value(parameters),
    ).toColumns(nullToAbsent);
  }
}

class ProviderModelConfig implements Insertable<ProviderModelConfig> {
  String providerId;
  String modelId;
  String callName;
  Set<ModelAbility>? abilitiesOverride;
  ModelPricing? pricingOverride;
  List<ModelParameters>? parametersOverride;
  ProviderModelConfig({
    required this.providerId,
    required this.modelId,
    required this.callName,
    this.abilitiesOverride,
    this.pricingOverride,
    this.parametersOverride,
  });

  ProviderModelConfig copyWith({
    String? providerId,
    String? modelId,
    String? callName,
    Set<ModelAbility>? abilitiesOverride,
    ModelPricing? pricingOverride,
    List<ModelParameters>? parametersOverride,
  }) {
    return ProviderModelConfig(
      providerId: providerId ?? this.providerId,
      modelId: modelId ?? this.modelId,
      callName: callName ?? this.callName,
      abilitiesOverride: abilitiesOverride ?? this.abilitiesOverride,
      pricingOverride: pricingOverride ?? this.pricingOverride,
      parametersOverride: parametersOverride ?? this.parametersOverride,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'provider_id': providerId,
      'model_id': modelId,
      'call_name': callName,
      'abilities_override': (abilitiesOverride != null)
          ? jsonEncode(
              abilitiesOverride
                  ?.map((ability) => ability.simpleString)
                  .toList(),
            )
          : null,
      'pricing_override': (pricingOverride != null)
          ? jsonEncode(pricingOverride!.toMap())
          : null,
      'parameters_override': (parametersOverride != null)
          ? jsonEncode(parametersOverride!)
          : null,
    };
  }

  factory ProviderModelConfig.fromMap(Map<String, dynamic> map) {
    return ProviderModelConfig(
      providerId: map['provider_id'],
      modelId: map['model_id'],
      callName: map['call_name'],
      abilitiesOverride: map['abilities_override'] != null
          ? XModelAlibity.fromList(
              (jsonDecode(map['abilities_override']) as List),
            )
          : null,
      pricingOverride: map['pricing_override'] != null
          ? ModelPricing.fromMap(jsonDecode(map['pricing_override']))
          : null,
      parametersOverride: map['parameters_override'] != null
          ? ModelParameters.fromMap(jsonDecode(map['parameters_override']))
          : null,
    );
  }

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return ProviderModelConfigsCompanion(
      providerId: Value(providerId),
      modelId: Value(modelId),
      callName: Value(callName),
      abilitiesOverride: Value(abilitiesOverride),
      pricingOverride: Value(pricingOverride),
      parametersOverride: Value(parametersOverride),
    ).toColumns(nullToAbsent);
  }
}

enum ApiType { openaiResponses, openaiChatCompletions, google }

extension XApiType on ApiType {
  String get name {
    switch (this) {
      case ApiType.openaiResponses:
        return "openai_responses";
      case ApiType.openaiChatCompletions:
        return "openai_chat_completions";
      case ApiType.google:
        return "google";
    }
  }

  static ApiType fromName(String name) {
    switch (name) {
      case "openai_responses":
        return ApiType.openaiResponses;
      case "openai_chat_completions":
        return ApiType.openaiChatCompletions;
      case "google":
        return ApiType.google;
    }
    throw Exception("Invalid ApiType name: $name");
  }

  String getFriendlyName() {
    switch (this) {
      case ApiType.openaiResponses:
        return 'OpenAI Response';
      case ApiType.openaiChatCompletions:
        return 'OpenAI Completion (Legacy)';
      case ApiType.google:
        return 'Google';
    }
  }

  String get vFlag {
    switch (this) {
      case ApiType.openaiResponses:
        return "/v1";
      case ApiType.openaiChatCompletions:
        return "/v1";
      case ApiType.google:
        return "/v1beta";
    }
  }

  List<Widget> getEndPointInfo(String? endPointBase, {TextStyle? style}) {
    switch (this) {
      case ApiType.openaiResponses:
        endPointBase ??= "https://api.openai.com";
        return <Widget>[
          Text("$endPointBase/models", style: style),
          const SizedBox(height: 10),
          Text("$endPointBase/responses", style: style),
          const SizedBox(height: 10),
          Text("$endPointBase/files", style: style),
          const SizedBox(height: 10),
          Text("$endPointBase/embeddings", style: style),
        ];
      case ApiType.openaiChatCompletions:
        endPointBase ??= "https://api.openai.com";
        return <Widget>[
          Text("$endPointBase/models", style: style),
          const SizedBox(height: 10),
          Text("$endPointBase/chat/completions", style: style),
          const SizedBox(height: 10),
          Text("$endPointBase/files", style: style),
          const SizedBox(height: 10),
          Text("$endPointBase/embeddings", style: style),
        ];
      case ApiType.google:
        endPointBase ??= "https://generativelanguage.googleapis.com";
        return <Widget>[
          Text("$endPointBase/models", style: style),
          const SizedBox(height: 10),
          Text("$endPointBase/{model}:streamGenerateContent", style: style),
          const SizedBox(height: 10),
          Text("$endPointBase/files", style: style),
          const SizedBox(height: 10),
          Text("$endPointBase/{model}:embedText", style: style),
        ];
    }
  }
}

enum ProviderPresetType {
  singleInstance, //只允许存在一个，且会被自动更新（id所有客户端唯一），例如 Openai官方 和 谷歌官方这种没有其他可能的 ，用户只需要配置 Apikey 就好了
  typeSetMultiInstance, // 允许多个实例，只给你设置api类型的，例如 Lm Studio 或者 ollama 这种可以在好多不同电脑上起不同实例的
  typeSetMultiInstanceWithoutKey,
  fullyCustomize,
}

class ProviderPreset implements Insertable<ProviderPresetsTableData> {
  String id;
  late Map<String, String> _i18nName;
  ProviderPresetType type;
  String? endpoint;
  ApiType apiType;
  List<ProviderModelConfig>? models;

  static List<ProviderPreset> presets = [
    ProviderPreset(
      id: "lmstudio",
      i18nName: {'en': "LM Studio"},
      endpoint: "http://localhost:1234",
      type: ProviderPresetType.typeSetMultiInstanceWithoutKey,
      apiType: ApiType.openaiChatCompletions,
    ),
    ProviderPreset(
      id: 'deepseek',
      i18nName: {'en': "DeepSeek", 'zh': "深度求索"},
      endpoint: "https://api.deepseek.com",
      type: ProviderPresetType.singleInstance,
      apiType: ApiType.openaiChatCompletions,
      models: [
        ProviderModelConfig(
          providerId: 'deepseek',
          modelId: '@official-464a9745-faf7-5e9c-813d-dc230998fed4',
          callName: 'deepseek-reasoner',
        ),
        ProviderModelConfig(
          providerId: 'deepseek',
          modelId: '@official-a8c6da93-45af-5030-bbbd-b415bfa11e66',
          callName: 'deepseek-chat',
        ),
      ],
    ),
    ProviderPreset(
      id: 'model_scope',
      i18nName: {'en': "Model Scope", 'zh': "魔搭"},
      endpoint: "https://api-inference.modelscope.cn/v1",
      type: ProviderPresetType.singleInstance,
      apiType: ApiType.openaiChatCompletions,
      models: [
        ProviderModelConfig(
          providerId: 'model_scope',
          modelId: '@official-464a9745-faf7-5e9c-813d-dc230998fed4',
          callName: 'deepseek-ai/DeepSeek-R1',
        ),
        ProviderModelConfig(
          providerId: 'model_scope',
          modelId: '@official-a8c6da93-45af-5030-bbbd-b415bfa11e66',
          callName: 'deepseek-ai/DeepSeek-V3.2',
        ),
        ProviderModelConfig(
          providerId: 'model_scope',
          modelId: '@official-0183feea-f111-5cf9-92e3-54cd841fc327',
          callName: 'Qwen/Qwen3-235B-A22B',
        ),
        ProviderModelConfig(
          providerId: 'model_scope',
          modelId: '@official-2072efd3-d486-55de-ba05-b9679d3ef907',
          callName: 'Qwen/Qwen3-Coder-480B-A35B-Instruct',
        ),
        ProviderModelConfig(
          providerId: 'model_scope',
          modelId: '@official-e9e2fac4-7690-5a57-b663-7fa104870b06',
          callName: 'Qwen/QwQ-32B',
        ),
        ProviderModelConfig(
          providerId: 'model_scope',
          modelId: '@official-c5c0d0c5-b0a7-5c0c-b0a7-c5c0d0c5b0a7',
          callName: 'Qwen/Qwen3-Coder-7B-A35B',
        ),
      ],
    ),
    ProviderPreset(
      id: 'google',
      endpoint: "https://generativelanguage.googleapis.com/v1beta",
      i18nName: {'en': "Google", 'zh': "谷歌"},
      type: ProviderPresetType.singleInstance,
      apiType: ApiType.google,
      models: [
        ProviderModelConfig(
          providerId: 'google',
          modelId: '@official-823a8f64-0788-52d9-bf53-2f502472b5c5',
          callName: 'gemini-3-flash-preview',
        ),
        ProviderModelConfig(
          providerId: 'google',
          modelId: '@official-86eda6c0-ff35-5820-a46c-c73e2d037ded',
          callName: 'gemini-3-pro-preview',
        ),
      ],
    ),
  ];

  ProviderPreset({
    required this.id,
    required Map<String, String> i18nName,
    required this.type,
    this.endpoint,
    required this.apiType,
    this.models,
  }) {
    _i18nName = i18nName;
  }

  String getName(String? langCode) {
    return _i18nName[langCode] ?? _i18nName['en']!;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'i18n_name': jsonEncode(_i18nName),
      'type': type.toString(),
      'endpoint': endpoint,
      'api_type': apiType.toString(),
      'models': (models != null) ? jsonEncode(models) : null,
    };
  }

  factory ProviderPreset.fromMap(Map<String, dynamic> map) {
    var m = map['models'];
    List<ProviderModelConfig>? models;
    if (m != null) {
      var mp = jsonDecode(m);
      models = [];
      for (var i in mp) {
        models.add(ProviderModelConfig.fromMap(i.value));
      }
    }
    return ProviderPreset(
      id: map['id'],
      i18nName: jsonDecode(map['i18n_name']).cast<String, String>(),
      type: ProviderPresetType.values.firstWhere(
        (element) => element.toString() == map['type'],
      ),
      endpoint: map['endpoint'],
      apiType: ApiType.values.firstWhere(
        (element) => element.toString() == map['api_type'],
      ),
      models: models,
    );
  }

  ProviderPresetsTableCompanion get companion => ProviderPresetsTableCompanion(
    id: Value(id),
    i18nName: Value(_i18nName),
    type: Value(type),
    endpoint: Value(endpoint),
    apiType: Value(apiType),
    models: Value(models),
  );

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return ProviderPresetsTableCompanion(
      id: Value(id),
      i18nName: Value(_i18nName),
      type: Value(type),
      endpoint: Value(endpoint),
      apiType: Value(apiType),
      models: Value(models),
    ).toColumns(nullToAbsent);
  }
}

abstract class ModelParameters {
  ModelParameters({this.value, double? defaultValue}) {
    _defaultValue = defaultValue;
  }

  late final double? _defaultValue;
  double? get defaultValue => _defaultValue;
  double? value;
  String get name;
  String getFriendlyName();
  String getDescription();

  Map<String, dynamic> toMap();

  static List<ModelParameters> fromMap(List<dynamic> maps) {
    if (maps.isEmpty) {
      return [];
    }
    var list = <ModelParameters>[];
    for (var map in maps) {
      switch (map['name']) {
        case 'temperature':
          list.add(Temperature.fromMap(map));
          continue;
        case 'top_p':
          list.add(TopP.fromMap(map));
          continue;
        case 'presence_penalty':
          list.add(PresencePenalty.fromMap(map));
          continue;
        case 'frequency_penalty':
          list.add(FrequencyPenalty.fromMap(map));
          continue;
        default:
          continue;
      }
    }
    return list;
  }
}

class Temperature extends ModelParameters {
  Temperature({super.value, super.defaultValue});

  @override
  String get name => 'temperature';

  @override
  String getFriendlyName() {
    return 'Temperature';
  }

  @override
  String getDescription() {
    return 'Controls randomness: 0.0=deterministic, 1.0=random';
  }

  @override
  Map<String, dynamic> toMap() {
    return {'name': name, 'value': value, 'default_value': defaultValue};
  }

  factory Temperature.fromMap(Map<String, dynamic> map) {
    return Temperature(value: map['value'], defaultValue: map['default_value']);
  }
}

class TopP extends ModelParameters {
  TopP({super.value, super.defaultValue});

  @override
  String get name => 'top_p';

  @override
  String getFriendlyName() {
    return 'Top P';
  }

  @override
  String getDescription() {
    return 'Controls diversity via nucleus sampling: 0.0=deterministic, 1.0=maximum diversity';
  }

  @override
  Map<String, dynamic> toMap() {
    return {'name': name, 'value': value, 'default_value': defaultValue};
  }

  factory TopP.fromMap(Map<String, dynamic> map) {
    return TopP(value: map['value'], defaultValue: map['default_value']);
  }
}

class TopK extends ModelParameters {
  TopK({super.value, super.defaultValue});

  @override
  String get name => 'top_k';

  @override
  String getFriendlyName() {
    return 'Top K';
  }

  @override
  String getDescription() {
    return 'Controls diversity via nucleus sampling: 0.0=deterministic, 1.0=maximum diversity';
  }

  @override
  Map<String, dynamic> toMap() {
    return {'name': name, 'value': value, 'default_value': defaultValue};
  }

  factory TopK.fromMap(Map<String, dynamic> map) {
    return TopK(value: map['value'], defaultValue: map['default_value']);
  }
}

class PresencePenalty extends ModelParameters {
  PresencePenalty({super.value, super.defaultValue});

  @override
  String get name => 'presence_penalty';

  @override
  String getFriendlyName() {
    return 'Presence Penalty';
  }

  @override
  String getDescription() {
    return 'Penalizes new tokens based on whether they appear in the text so far';
  }

  @override
  Map<String, dynamic> toMap() {
    return {'name': name, 'value': value, 'default_value': defaultValue};
  }

  factory PresencePenalty.fromMap(Map<String, dynamic> map) {
    return PresencePenalty(
      value: map['value'],
      defaultValue: map['default_value'],
    );
  }
}

class FrequencyPenalty extends ModelParameters {
  FrequencyPenalty({super.value, super.defaultValue});

  @override
  String get name => 'frequency_penalty';

  @override
  String getFriendlyName() {
    return 'Frequency Penalty';
  }

  @override
  String getDescription() {
    return 'Penalizes new tokens based on their existing frequency in the text so far';
  }

  @override
  Map<String, dynamic> toMap() {
    return {'name': name, 'value': value, 'default_value': defaultValue};
  }

  factory FrequencyPenalty.fromMap(Map<String, dynamic> map) {
    return FrequencyPenalty(
      value: map['value'],
      defaultValue: map['default_value'],
    );
  }
}
