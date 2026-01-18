import 'dart:convert';

import 'package:flutter/widgets.dart';

class ApiProvider {
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
}

class ApiKey {
  final String providerId;
  String id;
  String key;
  String? remark;
  int? rpm;
  int? rpd;
  int? tokenLimit;
  bool isEnabled;

  ApiKey(
    this.providerId,
    this.id,
    this.key, {
    this.remark,
    this.rpm,
    this.rpd,
    this.tokenLimit,
    this.isEnabled = true,
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
      isEnabled: isEnabled ?? this.isEnabled,
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
      'is_enabled': isEnabled ? 1 : 0,
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
      isEnabled: map['is_enabled'] == 1,
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
        other.isEnabled == isEnabled;
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
      isEnabled,
    );
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
        return '文本生成';
      case ModelAbility.imageGenerate:
        return '图像生成';
      case ModelAbility.image2imageGenerate:
        return '图像到图像生成';
      case ModelAbility.visual:
        return '视觉理解';
      case ModelAbility.file:
        return 'PDF理解';
      case ModelAbility.embedding:
        return '嵌入';
      case ModelAbility.audio:
        return '音频';
      case ModelAbility.video:
        return '视频';
    }
  }

  String getSimpleString() {
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
        return 'visualUnderstanding';
      case ModelAbility.embedding:
        return 'embedding';
      case ModelAbility.audio:
        return 'audio';
      case ModelAbility.video:
        return 'video';
    }
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

class Model {
  final String id;
  final String friendlyName;
  final String family;
  final String? description;
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
    this.description,
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
        abilities.map((ability) => ability.getSimpleString()).toList(),
      ),
      'description': description,
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
      parameters = [];
      for (var i in (pr as List)) {
        var obj = ModelParameters.fromMap(i);
        if (obj != null) {
          parameters.add(obj);
        }
      }
      if (parameters.isEmpty) {
        parameters = null;
      }
    }
    return Model(
      id: map['id'],
      family: map['family'],
      friendlyName: map['friendly_name'],
      description: map['description'],
      abilities: XModelAlibity.fromList((jsonDecode(map['abilities']) as List)),
      contextLength: map['context_length'],
      maxCompletionTokens: map['max_completion_tokens'],
      pricing: map['pricing'] != null
          ? ModelPricing.fromMap(jsonDecode(map['pricing']))
          : null,
      parameters: parameters,
    );
  }
}

class ProviderModelConfig {
  String providerId;
  String modelId;
  String callName;
  Set<ModelAbility>? abilitiesOverride;
  ModelPricing? pricingOverride;
  ModelParameters? parametersOverride;
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
    ModelParameters? parametersOverride,
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
                  ?.map((ability) => ability.getSimpleString())
                  .toList(),
            )
          : null,
      'pricing_override': (pricingOverride != null)
          ? jsonEncode(pricingOverride!.toMap())
          : null,
      'parameters_override': (parametersOverride != null)
          ? jsonEncode(parametersOverride!.toMap())
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

class ProviderPreset {
  String id;
  late Map<String, String> _i18nName;
  ProviderPresetType type;
  String? endpoint;
  ApiType apiType;
  Map<String, ProviderModelConfig>? models;

  static List<ProviderPreset> presets = [
    ProviderPreset(
      id: "lmstudio",
      i18nName: {'en': "LM Studio"},
      endpoint: "http://localehost:1234",
      type: ProviderPresetType.typeSetMultiInstanceWithoutKey,
      apiType: ApiType.openaiChatCompletions,
    ),
    ProviderPreset(
      id: 'deepseek',
      i18nName: {'en': "DeepSeek", 'zh': "深度求索"},
      type: ProviderPresetType.singleInstance,
      apiType: ApiType.openaiChatCompletions,
      models: {
        '@official-464a9745-faf7-5e9c-813d-dc230998fed4': ProviderModelConfig(
          providerId: 'deepseek',
          modelId: '@official-464a9745-faf7-5e9c-813d-dc230998fed4',
          callName: 'deepseek/deepseek-r1',
        ),
        '@official-a8c6da93-45af-5030-bbbd-b415bfa11e66': ProviderModelConfig(
          providerId: 'deepseek',
          modelId: '@official-a8c6da93-45af-5030-bbbd-b415bfa11e66',
          callName: 'deepseek/deepseek-v3.2',
        ),
      },
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
      'models': (models != null)
          ? jsonEncode(
              models?.map((k, v) {
                return MapEntry(k, v.toMap());
              }),
            )
          : null,
    };
  }

  factory ProviderPreset.fromMap(Map<String, dynamic> map) {
    var m = map['models'];
    Map<String, ProviderModelConfig>? models;
    if (m != null) {
      var mp = jsonDecode(m);
      models = {};
      for (var i in mp.entries) {
        models[i.key] = ProviderModelConfig.fromMap(i.value);
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

  static ModelParameters? fromMap(Map<String, dynamic> map) {
    switch (map['name']) {
      case 'temperature':
        return Temperature.fromMap(map);
      case 'top_p':
        return TopP.fromMap(map);
      case 'presence_penalty':
        return PresencePenalty.fromMap(map);
      case 'frequency_penalty':
        return FrequencyPenalty.fromMap(map);
      default:
        return null;
    }
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
