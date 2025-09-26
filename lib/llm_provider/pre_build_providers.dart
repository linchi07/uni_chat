import 'package:uni_chat/utils/api_database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

import 'api_service.dart';

class PresetProvider {
  PresetProvider({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    this.type,
    required this.models,
    this.endPoint,
    this.step1Hint,
    this.apiKeyHintWidget,
    this.step3Hint,
    this.step4Hint,
  });
  final String id;
  final String name;
  final int version;
  final String description;
  final String? type;
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
      endPoint: "https://api.openai.com/v1/chat/completions",
      step1Hint: Text("注意：此端点是官方API端点，若需要使用OpenAi兼容Api，请使用自定义端点"),
      type: "openai",
      models: [
        ModelsConfigData(
          callName: "gpt-3.5-turbo",
          friendlyName: "GPT-3.5-Turbo",
          abilities: {ApiAbility.supportFilesApi, ApiAbility.textGenerate},
        ),
      ],
    ),
    "Google": PresetProvider(
      id: "google",
      name: "Google",
      version: 1,
      description: "Google 官方 API",
      endPoint: "https://chat.googleapis.com/v1/spaces/",
      type: "google",
      step1Hint: Text("注意：此端点是官方API端点，若需要使用Google兼容Api，请使用自定义端点"),
      models: [
        ModelsConfigData(
          callName: "gemini-1.5-flash",
          friendlyName: "Gemini 1.5 flash",
          abilities: {
            ApiAbility.textGenerate,
            ApiAbility.supportFilesApi,
            ApiAbility.visualUnderStanding,
          },
        ),
      ],
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
  final Set<ApiAbility> abilities;
  ModelsConfigData({
    String? id,
    required this.callName,
    required this.friendlyName,
    required this.abilities,
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
      abilities: config.abilities,
    );
  }
}
