import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uni_chat/api_configs/api_database.dart';

import '../l10n/generated/l10n.dart';
import '../utils/llm_icons.dart';

class ApiProvider implements Insertable<ApiProvider> {
  final String id;
  final String name;
  final ApiType type;
  final String endpoint;
  final String? preset;
  final int? order;

  ApiProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.endpoint,
    this.preset,
    this.order,
  });

  factory ApiProvider.fromMap(Map<String, dynamic> map) {
    return ApiProvider(
      id: map['id'],
      name: map['name'],
      type: XApiType.fromName(map['type']),
      endpoint: map['endpoint'],
      preset: map['preset'],
      order: map['order'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'endpoint': endpoint,
      'preset': preset,
      'order': order,
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
      order: Value(order),
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
  String? invokeData;
  bool enabled;

  ApiKey(
    this.providerId,
    this.id,
    this.key, {
    this.remark,
    this.rpm,
    this.rpd,
    this.tokenLimit,
    this.invokeData,
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
    String? invokeData,
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
      invokeData: invokeData ?? this.invokeData,
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
      'invoke_data': invokeData,
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
      invokeData: map['invoke_data'],
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
        other.invokeData == invokeData &&
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
      invokeData,
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
      invokeData: Value(invokeData),
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
  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;
  final int? cachedTokens;
  final double? cost;
  final String? currency;

  const ApiKeyUsage({
    required this.apiKeyId,
    required this.modelId,
    this.agentId,
    required this.time,
    required this.usage,
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
    this.cachedTokens,
    this.cost,
    this.currency,
  });

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return ApiKeyUsagesCompanion(
      apiKeyId: Value(apiKeyId),
      modelId: Value(modelId),
      agentId: Value(agentId),
      time: Value(time),
      usage: Value(usage),
      promptTokens: Value(promptTokens ?? usage.promptTokens),
      completionTokens: Value(completionTokens ?? usage.completionTokens),
      totalTokens: Value(totalTokens ?? usage.total),
      cachedTokens: Value(cachedTokens ?? usage.cachedTokens),
      cost: Value(cost),
      currency: Value(currency),
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
  toolCall,
  thinking,
}

class ModelPricing {
  final double prompt;
  final double completion;
  final double? cached;
  final double? image;
  final double? webSearch;
  final String currency;

  ModelPricing({
    required this.prompt,
    required this.completion,
    this.cached,
    this.image,
    this.webSearch,
    this.currency = 'USD',
  });

  factory ModelPricing.fromMap(Map<String, dynamic> map) {
    return ModelPricing(
      prompt: map['prompt'],
      completion: map['completion'],
      cached: map['cached'],
      image: map['image'],
      webSearch: map['web_search'],
      currency: map['currency'] ?? 'USD',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prompt': prompt,
      'completion': completion,
      'cached': cached,
      'image': image,
      'web_search': webSearch,
      'currency': currency,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelPricing &&
          runtimeType == other.runtimeType &&
          prompt == other.prompt &&
          completion == other.completion &&
          cached == other.cached &&
          image == other.image &&
          webSearch == other.webSearch;

  @override
  int get hashCode =>
      prompt.hashCode ^
      completion.hashCode ^
      cached.hashCode ^
      image.hashCode ^
      webSearch.hashCode ^
      currency.hashCode;
}

class Model implements Insertable<Model> {
  final String id;
  final String friendlyName;
  final String family;
  final Set<ModelAbility> abilities;
  final int? contextLength;
  final int? maxCompletionTokens;
  final List<ModelParamName>? parameters;
  final int? order;

  Model({
    required this.id,
    required this.friendlyName,
    required this.family,
    required this.abilities,
    this.contextLength,
    this.maxCompletionTokens,
    this.parameters,
    this.order,
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
      'parameters': parameters?.map((e) => e.name).toList(),
      'order': order,
    };
  }

  factory Model.fromMap(Map<String, dynamic> map) {
    List<ModelParamName>? parameters;
    var pr = map['parameters'];
    if (pr != null) {
      parameters = (pr as List)
          .map(
            (e) => ModelParamName.values.firstWhereOrNull((p) => p.name == e),
          )
          .whereType<ModelParamName>()
          .toList();
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
      parameters: parameters,
      order: map['order'],
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
      parameters: Value(parameters),
      order: Value(order),
    ).toColumns(nullToAbsent);
  }
}

class ProviderModelConfig implements Insertable<ProviderModelConfig> {
  String providerId;
  String modelId;
  String callName;
  Set<ModelAbility>? abilitiesOverride;
  ModelPricing? pricing;
  List<ModelParamName>? parametersOverride;
  ProviderModelConfig({
    required this.providerId,
    required this.modelId,
    required this.callName,
    this.abilitiesOverride,
    this.pricing,
    this.parametersOverride,
  });

  ProviderModelConfig copyWith({
    String? providerId,
    String? modelId,
    String? callName,
    Set<ModelAbility>? abilitiesOverride,
    ModelPricing? pricing,
    List<ModelParamName>? parametersOverride,
  }) {
    return ProviderModelConfig(
      providerId: providerId ?? this.providerId,
      modelId: modelId ?? this.modelId,
      callName: callName ?? this.callName,
      abilitiesOverride: abilitiesOverride ?? this.abilitiesOverride,
      pricing: pricing ?? this.pricing,
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
      'pricing': (pricing != null) ? jsonEncode(pricing!.toMap()) : null,
      'parameters_override': (parametersOverride != null)
          ? jsonEncode(parametersOverride!.map((e) => e.name).toList())
          : null,
    };
  }

  factory ProviderModelConfig.fromMap(Map<String, dynamic> map) {
    List<ModelParamName>? parameters;
    var pr = map['parameters_override'];
    if (pr != null) {
      if (pr is String) {
        pr = jsonDecode(pr);
      }
      parameters = (pr as List)
          .map((e) => ModelParamName.values.byName(e))
          .toList();
    }
    return ProviderModelConfig(
      providerId: map['provider_id'],
      modelId: map['model_id'],
      callName: map['call_name'],
      abilitiesOverride: map['abilities_override'] != null
          ? XModelAlibity.fromList(
              (jsonDecode(map['abilities_override']) as List),
            )
          : null,
      pricing: map['pricing'] != null
          ? ModelPricing.fromMap(jsonDecode(map['pricing']))
          : null,
      parametersOverride: parameters,
    );
  }

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return ProviderModelConfigsCompanion(
      providerId: Value(providerId),
      modelId: Value(modelId),
      callName: Value(callName),
      abilitiesOverride: Value(abilitiesOverride),
      pricing: Value(pricing),
      parametersOverride: Value(parametersOverride),
    ).toColumns(nullToAbsent);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderModelConfig &&
          runtimeType == other.runtimeType &&
          providerId == other.providerId &&
          modelId == other.modelId &&
          callName == other.callName &&
          const SetEquality().equals(
            abilitiesOverride,
            other.abilitiesOverride,
          ) &&
          pricing == other.pricing &&
          const ListEquality().equals(
            parametersOverride,
            other.parametersOverride,
          );

  @override
  int get hashCode =>
      providerId.hashCode ^
      modelId.hashCode ^
      callName.hashCode ^
      abilitiesOverride.hashCode ^
      pricing.hashCode ^
      parametersOverride.hashCode;
}

enum ThinkingMode { defaultMode, off, low, mid, high, xhigh }

extension XThinkingMode on ThinkingMode {
  String friendlyName(BuildContext context) {
    switch (this) {
      case ThinkingMode.defaultMode:
        return S.of(context).DEFAULT;
      case ThinkingMode.off:
        return S.of(context).thinking_mode_disabled;
      case ThinkingMode.low:
        return S.of(context).thinking_mode_low;
      case ThinkingMode.mid:
        return S.of(context).thinking_mode_medium;
      case ThinkingMode.high:
        return S.of(context).thinking_mode_high;
      case ThinkingMode.xhigh:
        return S.of(context).thinking_mode_xhigh;
    }
  }
}

enum ParamUIType {
  doubleSlider,
  intSlider,
  integerInput,
  boolean,
  stringList,
  none,
}

enum ModelParamName {
  temperature,
  topP,
  topK,
  presencePenalty,
  frequencyPenalty,
  repetitionPenalty,
  minP,
  topA,
  seed,
  maxTokens,
  stop,
  includeReasoning,
  logitBias,
  reasoning,
  responseFormat,
  structuredOutputs,
  toolChoice,
  tools,
  thinking,
  reasoningEffort,
}

extension XModelParamName on ModelParamName {
  ParamUIType get uiType {
    switch (this) {
      case ModelParamName.temperature:
      case ModelParamName.topP:
      case ModelParamName.presencePenalty:
      case ModelParamName.frequencyPenalty:
      case ModelParamName.repetitionPenalty:
      case ModelParamName.minP:
      case ModelParamName.topA:
        return ParamUIType.doubleSlider;
      case ModelParamName.topK:
      case ModelParamName.maxTokens:
        return ParamUIType.intSlider;
      case ModelParamName.seed:
        return ParamUIType.integerInput;
      case ModelParamName.includeReasoning:
        return ParamUIType.boolean;
      case ModelParamName.stop:
        return ParamUIType.stringList;
      case ModelParamName.reasoning:
      case ModelParamName.structuredOutputs:
        return ParamUIType.boolean;
      case ModelParamName.thinking:
        return ParamUIType.stringList;
      case ModelParamName.logitBias:
      case ModelParamName.responseFormat:
      case ModelParamName.toolChoice:
      case ModelParamName.tools:
        return ParamUIType.none;
      case ModelParamName.reasoningEffort:
        return ParamUIType.stringList;
    }
  }

  String get apiName {
    switch (this) {
      case ModelParamName.temperature:
        return 'temperature';
      case ModelParamName.topP:
        return 'top_p';
      case ModelParamName.topK:
        return 'top_k';
      case ModelParamName.presencePenalty:
        return 'presence_penalty';
      case ModelParamName.frequencyPenalty:
        return 'frequency_penalty';
      case ModelParamName.repetitionPenalty:
        return 'repetition_penalty';
      case ModelParamName.minP:
        return 'min_p';
      case ModelParamName.topA:
        return 'top_a';
      case ModelParamName.seed:
        return 'seed';
      case ModelParamName.maxTokens:
        return 'max_tokens';
      case ModelParamName.stop:
        return 'stop';
      case ModelParamName.includeReasoning:
        return 'include_reasoning';
      case ModelParamName.logitBias:
        return 'logit_bias';
      case ModelParamName.reasoning:
        return 'reasoning';
      case ModelParamName.responseFormat:
        return 'response_format';
      case ModelParamName.structuredOutputs:
        return 'structured_outputs';
      case ModelParamName.toolChoice:
        return 'tool_choice';
      case ModelParamName.tools:
        return 'tools';
      case ModelParamName.thinking:
        return 'thinking';
      case ModelParamName.reasoningEffort:
        return 'reasoning_effort';
    }
  }

  String get geminiName {
    switch (this) {
      case ModelParamName.temperature:
        return 'temperature';
      case ModelParamName.topP:
        return 'topP';
      case ModelParamName.topK:
        return 'topK';
      case ModelParamName.maxTokens:
        return 'maxOutputTokens';
      case ModelParamName.stop:
        return 'stopSequences';
      case ModelParamName.responseFormat:
        return 'responseFormat';
      case ModelParamName.presencePenalty:
      case ModelParamName.frequencyPenalty:
      case ModelParamName.repetitionPenalty:
      case ModelParamName.minP:
      case ModelParamName.topA:
      case ModelParamName.seed:
      case ModelParamName.includeReasoning:
      case ModelParamName.logitBias:
      case ModelParamName.reasoning:
      case ModelParamName.structuredOutputs:
      case ModelParamName.toolChoice:
      case ModelParamName.tools:
      case ModelParamName.thinking:
      case ModelParamName.reasoningEffort:
        return apiName;
    }
  }

  String friendlyName(BuildContext context) {
    switch (this) {
      case ModelParamName.temperature:
        return S.of(context).model_param_temperature;
      case ModelParamName.topP:
        return S.of(context).model_param_top_p;
      case ModelParamName.topK:
        return S.of(context).model_param_top_k;
      case ModelParamName.presencePenalty:
        return S.of(context).model_param_presence_penalty;
      case ModelParamName.frequencyPenalty:
        return S.of(context).model_param_frequency_penalty;
      case ModelParamName.repetitionPenalty:
        return S.of(context).model_param_repetition_penalty;
      case ModelParamName.minP:
        return S.of(context).model_param_min_p;
      case ModelParamName.topA:
        return S.of(context).model_param_top_a;
      case ModelParamName.seed:
        return S.of(context).model_param_seed;
      case ModelParamName.maxTokens:
        return S.of(context).model_param_max_tokens;
      case ModelParamName.stop:
        return S.of(context).model_param_stop;
      case ModelParamName.includeReasoning:
        return S.of(context).model_param_include_reasoning;
      case ModelParamName.logitBias:
        return S.of(context).model_param_logit_bias;
      case ModelParamName.reasoning:
        return S.of(context).model_param_reasoning;
      case ModelParamName.responseFormat:
        return S.of(context).model_param_response_format;
      case ModelParamName.structuredOutputs:
        return S.of(context).model_param_structured_outputs;
      case ModelParamName.toolChoice:
        return S.of(context).model_param_tool_choice;
      case ModelParamName.tools:
        return S.of(context).model_param_tools;
      case ModelParamName.thinking:
        return S.of(context).model_param_thinking;
      case ModelParamName.reasoningEffort:
        return S.of(context).model_param_thinking; // Same label for now
    }
  }

  String description(BuildContext context) {
    switch (this) {
      case ModelParamName.temperature:
        return 'Controls randomness: 0.0=deterministic, 1.0=random';
      case ModelParamName.topP:
        return 'Controls diversity via nucleus sampling';
      case ModelParamName.topK:
        return 'Limits the next token selection to the top K most likely tokens';
      case ModelParamName.presencePenalty:
        return 'Penalizes new tokens based on whether they appear in the text so far';
      case ModelParamName.frequencyPenalty:
        return 'Penalizes new tokens based on their existing frequency in the text';
      case ModelParamName.repetitionPenalty:
        return 'Penalizes repeated tokens';
      case ModelParamName.minP:
        return 'Alternative to Top P, sets a minimum probability threshold relative to the top token';
      case ModelParamName.topA:
        return 'Alternative to Top P, adaptive top-A sampling';
      case ModelParamName.seed:
        return 'Deterministic seed for generation';
      case ModelParamName.maxTokens:
        return 'Maximum number of tokens to generate';
      case ModelParamName.stop:
        return 'Strings where the model will stop generating';
      case ModelParamName.includeReasoning:
        return 'Whether to include the model\'s reasoning process';
      case ModelParamName.logitBias:
        return 'Probability adjustment for specific tokens';
      case ModelParamName.reasoning:
        return 'Controls advanced reasoning logic';
      case ModelParamName.responseFormat:
        return 'Specifies the format of the response (e.g., JSON)';
      case ModelParamName.structuredOutputs:
        return 'Enables structured matching for outputs';
      case ModelParamName.toolChoice:
        return 'Controls which tool is used by the model';
      case ModelParamName.tools:
        return 'List of tools available to the model';
      case ModelParamName.thinking:
        return 'Controls advanced thinking/reasoning effort and behavior';
      case ModelParamName.reasoningEffort:
        return 'Controls advanced thinking/reasoning effort levels';
    }
  }

  double get min {
    switch (this) {
      case ModelParamName.temperature:
      case ModelParamName.topP:
      case ModelParamName.minP:
      case ModelParamName.topA:
        return 0.0;
      case ModelParamName.presencePenalty:
      case ModelParamName.frequencyPenalty:
        return -2.0;
      case ModelParamName.repetitionPenalty:
        return 0.0;
      case ModelParamName.topK:
        return 1.0;
      case ModelParamName.maxTokens:
        return 1.0;
      case ModelParamName.thinking:
      case ModelParamName.reasoningEffort:
        return 0.0;
      default:
        return 0.0;
    }
  }

  double get max {
    switch (this) {
      case ModelParamName.temperature:
        return 2.0;
      case ModelParamName.topP:
      case ModelParamName.minP:
      case ModelParamName.topA:
        return 1.0;
      case ModelParamName.presencePenalty:
      case ModelParamName.frequencyPenalty:
        return 2.0;
      case ModelParamName.repetitionPenalty:
        return 2.0;
      case ModelParamName.topK:
        return 100.0;
      case ModelParamName.maxTokens:
        return 4096.0;
      case ModelParamName.thinking:
      case ModelParamName.reasoningEffort:
        return 1.0;
      default:
        return 1.0;
    }
  }

  dynamic get initialValue {
    switch (this) {
      case ModelParamName.temperature:
      case ModelParamName.topP:
      case ModelParamName.repetitionPenalty:
        return 1.0;
      case ModelParamName.topK:
        return 40;
      case ModelParamName.presencePenalty:
      case ModelParamName.frequencyPenalty:
      case ModelParamName.minP:
      case ModelParamName.topA:
        return 0.0;
      case ModelParamName.seed:
        return null;
      case ModelParamName.maxTokens:
        return 2048;
      case ModelParamName.stop:
        return <String>[];
      case ModelParamName.includeReasoning:
        return false;
      case ModelParamName.logitBias:
        return null;
      case ModelParamName.reasoning:
        return false;
      case ModelParamName.responseFormat:
        return null;
      case ModelParamName.structuredOutputs:
        return false;
      case ModelParamName.toolChoice:
        return null;
      case ModelParamName.tools:
        return <dynamic>[];
      case ModelParamName.thinking:
        return ThinkingMode.defaultMode.name;
      case ModelParamName.reasoningEffort:
        return 'medium';
    }
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
        return 'OpenAI Completion';
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
  int? order;
  Map<String, String>? helperUrl;

  static List<ProviderPreset> presets = [];

  Map<String, String> get i18nName => _i18nName;

  ProviderPreset({
    required this.id,
    required Map<String, String> i18nName,
    required this.type,
    this.endpoint,
    required this.apiType,
    this.models,
    this.order,
    this.helperUrl,
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
      'type': type.name,
      'endpoint': endpoint,
      'api_type': apiType.name,
      'models': (models != null) ? jsonEncode(models) : null,
      'order': order,
      'helper_url': (helperUrl != null) ? jsonEncode(helperUrl) : null,
    };
  }

  factory ProviderPreset.fromMap(Map<String, dynamic> map) {
    return ProviderPreset(
      id: map['id'],
      i18nName: (jsonDecode(map['i18n_name'] as String) as Map)
          .cast<String, String>(),
      type: ProviderPresetType.values.firstWhere((e) => e.name == map['type']),
      endpoint: map['endpoint'],
      apiType: XApiType.fromName(map['api_type'] as String),
      models: map['models'] != null
          ? (jsonDecode(map['models'] as String) as List)
                .map((e) => ProviderModelConfig.fromMap(e))
                .toList()
          : null,
      order: map['order'],
      helperUrl: map['helper_url'] != null
          ? (jsonDecode(map['helper_url'] as String) as Map)
                .cast<String, String>()
          : null,
    );
  }

  ProviderPresetsTableCompanion get companion => ProviderPresetsTableCompanion(
    id: Value(id),
    i18nName: Value(_i18nName),
    type: Value(type),
    endpoint: Value(endpoint),
    apiType: Value(apiType),
    models: Value(models),
    order: Value(order),
    helperUrl: Value(helperUrl),
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
      order: Value(order),
      helperUrl: Value(helperUrl),
    ).toColumns(nullToAbsent);
  }
}
