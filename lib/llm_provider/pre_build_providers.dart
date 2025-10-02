import 'package:flutter/cupertino.dart';
import 'package:uni_chat/llm_provider/api_service.dart';
import 'package:uni_chat/llm_provider/pre_built_models.dart';
import 'package:uni_chat/utils/api_database_service.dart';
import 'package:uuid/uuid.dart';

class PresetProvider {
  PresetProvider({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    Set<ApiAbility>? abilities,
    this.type,
    required this.models,
    this.endPoint,
    this.step1Hint,
    this.apiKeyHintWidget,
    this.step3Hint,
    this.step4Hint,
  }) {
    this.abilities = abilities ?? {};
  }
  final String id;
  final String name;
  final int version;
  final String description;
  final String? type;
  late final Set<ApiAbility> abilities;
  final String? endPoint;
  final Widget? step1Hint;
  final Widget? apiKeyHintWidget;
  final Widget? step3Hint;
  final Widget? step4Hint;
  final List<ModelsConfigData> models;

  static Map<String, PresetProvider> providers = {
    "OpenAI": PresetProvider(
      id: "openai",
      name: "OpenAI",
      version: 1,
      description: "OpenAI 官方 API",
      abilities: {ApiAbility.supportsFilesApi},
      endPoint: "https://api.openai.com",
      step1Hint: Text("注意：此端点是官方API端点，若需要使用OpenAi兼容Api，请使用自定义端点"),
      type: "openai",
      models: [
        ?PreBuiltModels.models["gpt-4o"],
        ?PreBuiltModels.models["gpt-5"],
      ],
    ),
    "Google": PresetProvider(
      id: "google",
      name: "Google",
      version: 1,
      description: "Google 官方 API",
      abilities: {ApiAbility.supportsFilesApi},
      endPoint: "https://generativelanguage.googleapis.com",
      type: "google",
      step1Hint: Text("注意：此端点是官方API端点，若需要使用Google兼容Api，请使用自定义端点"),
      models: [
        ?PreBuiltModels.models["gemini-2.5-flash"],
        ?PreBuiltModels.models["gemini-2.5-pro"],
      ],
    ),
    "LmStudio": PresetProvider(
      id: "lmstudio",
      name: "LmStudio",
      version: 1,
      description: "LmStudio",
      type: "openaiCompletion",
      models: [],
    ),
    "custom": PresetProvider(
      id: "custom",
      name: "自定义",
      version: 1,
      description: "自定义 API",
      models: [],
    ),
  };
}

class ModelsConfigData {
  late final String id;
  final String callName;
  final String friendlyName;
  final String? family;
  final Set<ModelAbility> abilities;
  ModelsConfigData({
    String? id,
    required this.callName,
    required this.friendlyName,
    required this.abilities,
    this.family,
  }) {
    this.id = id ?? const Uuid().v4();
  }

  factory ModelsConfigData.fromProviderModelConfig(
    ProviderModelConfig config,
    String friendlyName,
  ) {
    return ModelsConfigData(
      id: config.id,
      callName: config.callName,
      friendlyName: friendlyName,
      abilities: {},
    );
  }
}
