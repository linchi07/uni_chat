import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_chat/Chat/chat_state.dart';
import 'package:uni_chat/Execution/execution_loop.dart';
import 'package:uni_chat/Execution/execution_models.dart';
import 'package:uni_chat/Execution/tools_provider.dart';
import 'package:uni_chat/Persona/persona_provider.dart';
import 'package:uni_chat/api_configs/api_service.dart';
import 'package:uni_chat/database/database_service.dart';
import 'package:uni_chat/error_handling.dart';
import 'package:uni_chat/main.dart';

import '../Chat/chat_models.dart';
import '../api_configs/api_models.dart';
import '../utils/file_utils.dart';
import 'agent_models.dart';
import 'prompt_injector.dart';

class ModelSpecifics {
  String? modelName;
  Map<ModelParamName, dynamic> customParameters = {};
  int maxGenerationTokens = 1000000000;
  int maxContextTokens = 1000000000;
  ThinkingMode thinkingMode = ThinkingMode.defaultMode;
  bool enableTimeTelling = true;
  bool enableUsrLanguage = true;
  bool enableUsrSystemInformation = true;

  ModelSpecifics({
    this.modelName,
    Map<ModelParamName, dynamic>? customParameters,
    this.maxGenerationTokens = 1000000000,
    this.maxContextTokens = 1000000000,
    this.thinkingMode = ThinkingMode.defaultMode,
    this.enableTimeTelling = true,
    this.enableUsrLanguage = true,
    this.enableUsrSystemInformation = true,
  }) : customParameters = customParameters ?? {};

  ModelSpecifics copyWith({
    String? modelName,
    Map<ModelParamName, dynamic>? customParameters,
    int? maxGenerationTokens,
    int? maxContextTokens,
    ThinkingMode? thinkingMode,
    bool? enableTimeTelling,
    bool? enableUsrLanguage,
    bool? enableUsrSystemInformation,
  }) {
    return ModelSpecifics(
      modelName: modelName ?? this.modelName,
      customParameters: customParameters ?? this.customParameters,
      maxGenerationTokens: maxGenerationTokens ?? this.maxGenerationTokens,
      maxContextTokens: maxContextTokens ?? this.maxContextTokens,
      thinkingMode: thinkingMode ?? this.thinkingMode,
      enableTimeTelling: enableTimeTelling ?? this.enableTimeTelling,
      enableUsrLanguage: enableUsrLanguage ?? this.enableUsrLanguage,
      enableUsrSystemInformation:
          enableUsrSystemInformation ?? this.enableUsrSystemInformation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "modelName": modelName,
      "customParameters": customParameters.map((k, v) => MapEntry(k.name, v)),
      "maxGenerationTokens": maxGenerationTokens,
      "maxContextTokens": maxContextTokens,
      "thinkingMode": thinkingMode.name,
      "enableTimeTelling": enableTimeTelling,
      "enableUsrLanguage": enableUsrLanguage,
      "enableUsrSystemInformation": enableUsrSystemInformation,
    };
  }

  factory ModelSpecifics.fromJson(Map<String, dynamic> json) {
    Map<ModelParamName, dynamic> params = {};
    if (json.containsKey("customParameters")) {
      var cp = json["customParameters"] as Map<String, dynamic>;
      cp.forEach((key, value) {
        try {
          params[ModelParamName.values.byName(key)] = value;
        } catch (e) {
          // Ignore
        }
      });
    } else {
      // Legacy format migration
      if (json.containsKey("temperature"))
        params[ModelParamName.temperature] = json["temperature"];
      if (json.containsKey("topP")) params[ModelParamName.topP] = json["topP"];
      if (json.containsKey("frequencyPenalty"))
        params[ModelParamName.frequencyPenalty] = json["frequencyPenalty"];
      if (json.containsKey("presencePenalty"))
        params[ModelParamName.presencePenalty] = json["presencePenalty"];
    }

    ThinkingMode tMode = ThinkingMode.defaultMode;
    if (json.containsKey("thinkingMode")) {
      try {
        tMode = ThinkingMode.values.byName(json["thinkingMode"] as String);
      } catch (_) {}
    }

    return ModelSpecifics(
      modelName: json["modelName"] as String?,
      customParameters: params,
      maxGenerationTokens: json["maxGenerationTokens"] as int,
      maxContextTokens: json["maxContextTokens"] as int,
      thinkingMode: tMode,
      enableTimeTelling: json["enableTimeTelling"] as bool,
      enableUsrLanguage: json["enableUsrLanguage"] as bool,
      enableUsrSystemInformation: json["enableUsrSystemInformation"] as bool,
    );
  }
}

class Agent {
  Agent({
    required this.id,
    required this.name,
    this.systemPrompt,
    required this.modelConfigure,
    required this.memoryBaseIds,
    this.personaConfigure,
    this.openingConfigure,
    required this.client,
  });
  final String id;
  final String name;
  final bool enableUIQL = false;
  final String? systemPrompt;
  final ModelConfigure modelConfigure;
  final PersonaConfigure? personaConfigure;
  final OpeningConfigure? openingConfigure;
  final List<String> memoryBaseIds;
  ApiClient client;

  static Future<Agent> fromAgentData(AgentData agentData) async {
    var client = await ApiClient.fromFactory(
      agentData.modelConfigure.providerId,
      agentData.modelConfigure.modelId,
    );
    return Agent(
      id: agentData.id,
      name: agentData.name,
      client: client,
      personaConfigure: agentData.userIdentityConfigure,
      openingConfigure: agentData.openingConfigure,
      modelConfigure: agentData.modelConfigure,
      systemPrompt: agentData.systemPrompt,
      memoryBaseIds: [],
    );
  }

  AgentData toAgentData() {
    return AgentData(
      version: CURRENT_AGENT_DATA_VERSION,
      id: id,
      name: name,
      modelConfigure: modelConfigure,
      userIdentityConfigure: personaConfigure,
      openingConfigure: openingConfigure,
      systemPrompt: systemPrompt,
      createdAt: DateTime.now(), // Fallback
    );
  }

  Agent copyWith({
    Ref? ref,
    String? id,
    String? name,
    ApiClient? client,
    ModelConfigure? modelConfigure,
    PersonaConfigure? personaConfigure,
    OpeningConfigure? openingConfigure,
    String? systemPrompt,
    List<String>? memoryBaseIds,
  }) {
    return Agent(
      id: id ?? this.id,
      name: name ?? this.name,
      client: client ?? this.client,
      modelConfigure: modelConfigure ?? this.modelConfigure,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      personaConfigure: personaConfigure ?? this.personaConfigure,
      openingConfigure: openingConfigure ?? this.openingConfigure,
      memoryBaseIds: memoryBaseIds ?? this.memoryBaseIds,
    );
  }

  Future<File?> getAvatar() async {
    var f = await PathProvider.getPath("chat/avatars/$id");
    var f1 = File("$f.png");
    if (await f1.exists()) {
      return f1;
    } else {
      var f2 = File("$f.jpg");
      if (await f2.exists()) {
        return f2;
      }
      var f3 = File("$f.jpeg");
      if (await f3.exists()) {
        return f3;
      }
    }
    return null;
  }
}

class AgentProvider extends StateNotifier<Agent?> {
  final Ref ref;
  AgentProvider(this.ref) : super(null) {
    loadDefaultAgent();
  }

  void loadDefaultAgent({
    bool fallbackToInstant = true,
    bool setToNullWhenMissing = false,
  }) async {
    String? agentId;
    try {
      var agentData = await DatabaseService.instance.loadDefaultAgent();
      if (agentData == null) {
        if (fallbackToInstant) {
          await loadAgentById(INSTANT_AGENT_ID);
          return;
        }
        if (setToNullWhenMissing) {
          state = null;
        }
        return;
      }
      agentId = agentData.id;
      state = await Agent.fromAgentData(agentData);
      if (state?.personaConfigure != null &&
          state?.personaConfigure?.defaultPersona != null) {
        await ref
            .read(personaProvider.notifier)
            .loadPersonaById(state!.personaConfigure!.defaultPersona!);
      }
    } catch (e) {
      if (fallbackToInstant) {
        await loadAgentById(INSTANT_AGENT_ID);
        return;
      }
      if (setToNullWhenMissing) {
        state = null;
      }
      AppException ex;
      if (e is Exception) {
        if (e is AppException) {
          ex = AgentException.fromAncestor(e, errorAgentID: agentId);
        } else {
          ex = AgentException.fromException(e);
        }
        ref.read(chatStateProvider.notifier).stateCopyWith(error: ex);
      }
    }
  }

  Future<void> loadAgentById(
    String id, {
    bool forceReload = false,
    String? overrideJson,
  }) async {
    if (state != null &&
        state!.id == id &&
        !forceReload &&
        overrideJson == null) {
      return;
    }
    try {
      if (id == INSTANT_AGENT_ID) {
        final prefs = await SharedPreferences.getInstance();
        final configJson = prefs.getString("instant_agent_configure");
        ModelConfigure? modelConfig;
        if (configJson != null) {
          try {
            modelConfig = ModelConfigure.fromMap(jsonDecode(configJson));
          } catch (e) {
            // Ignore corrupted config
          }
        }

        // If no config found, fallback to default agent's model or first available
        modelConfig ??= const ModelConfigure(
          modelId: 'system',
          providerId: 'system',
        ); // to trigger an exception and force the user to select a model manualy

        AgentData agentData = AgentData(
          version: CURRENT_AGENT_DATA_VERSION,
          id: INSTANT_AGENT_ID,
          name: "",
          modelConfigure: modelConfig.copyWith(
            maxGenerationTokens: -1,
            maxContextTokens: 1000000000,
            enableTimeTelling: false,
            enableUsrLanguage: false,
            enableUsrSystemInformation: false,
          ),
          userIdentityConfigure: null,
          createdAt: DateTime.now(),
        );

        if (overrideJson != null) {
          agentData = agentData.applyOverride(overrideJson);
        }

        state = await Agent.fromAgentData(agentData);
        return;
      }

      var agentData = await DatabaseService.instance.getAgent(id);
      if (agentData == null) {
        throw AgentException(AgentExceptionType.agentNotFound);
      }

      if (overrideJson != null) {
        agentData = agentData.applyOverride(overrideJson);
      }

      state = await Agent.fromAgentData(agentData);
      if (state?.personaConfigure != null &&
          state?.personaConfigure?.defaultPersona != null) {
        await ref
            .read(personaProvider.notifier)
            .loadPersonaById(state!.personaConfigure!.defaultPersona!);
      }
    } catch (e) {
      AppException ex;
      if (e is Exception) {
        if (e is AppException) {
          ex = AgentException.fromAncestor(e, errorAgentID: id);
        } else {
          ex = AgentException.fromException(e);
        }
        ref.read(chatStateProvider.notifier).stateCopyWith(error: ex);
      }
    }
  }

  void setAgent(Agent agent) {
    agent = agent.copyWith(ref: ref);
    state = agent;

    if (agent.id == INSTANT_AGENT_ID) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString(
          "instant_agent_configure",
          jsonEncode(agent.modelConfigure.toMap()),
        );
      });
    }
  }

  Future<void> updateAgentModel(
    String agentId,
    ApiProvider provider,
    Model model,
    bool saveToSettings,
  ) async {
    var newConfig = ModelConfigure(
      modelId: model.id,
      providerId: provider.id,
      maxGenerationTokens: agentId == INSTANT_AGENT_ID ? -1 : 2560,
      maxContextTokens: agentId == INSTANT_AGENT_ID ? 1000000000 : 1000000000,
      enableTimeTelling: agentId == INSTANT_AGENT_ID ? false : true,
      enableUsrLanguage: agentId == INSTANT_AGENT_ID ? false : true,
      enableUsrSystemInformation: agentId == INSTANT_AGENT_ID ? false : true,
    );

    if (agentId == INSTANT_AGENT_ID) {
      if (saveToSettings) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          "instant_agent_configure",
          jsonEncode(newConfig.toMap()),
        );
      }
      // Reload the agent
      await loadAgentById(agentId, forceReload: true);
    } else {
      if (saveToSettings) {
        var agentData = await DatabaseService.instance.getAgent(agentId);
        if (agentData != null) {
          final updatedAgentData = AgentData(
            version: agentData.version,
            id: agentData.id,
            name: agentData.name,
            description: agentData.description,
            systemPrompt: agentData.systemPrompt,
            modelConfigure: newConfig,
            userIdentityConfigure: agentData.userIdentityConfigure,
            openingConfigure: agentData.openingConfigure,
            createdAt: agentData.createdAt,
            isDefault: agentData.isDefault,
          );
          await DatabaseService.instance.createOrUpdateAgent(updatedAgentData);
        }
      }
      // Reload the agent
      await loadAgentById(agentId, forceReload: true);
    }
  }

  ///以下是聊天时的功能实现
  Future<String?> fileUpload(File file, String mime) async {
    if (state != null) {
      if ( /*state!.client.abilities.contains(ApiAbility.supportsFilesApi)*/ false) {
        // 暂时关闭文件上传功能
        var r = await state!.client.fileUpload(file: file, mime: mime);
        if (r == null) {
          return null;
        }
        return r;
      }
      return null;
    }
    throw AgentException(AgentExceptionType.agentNotLoaded);
  }

  Stream<ChatResponse> getStreamingResponse(
    ChatSession session,
    List<ChatMessage> history,
    ChatMessage? usrMessage, {
    StopSignal? stopSignal,
    ThinkingMode? overrideThinkingMode,
  }) async* {
    if (state != null) {
      final baseAgentData = state!.toAgentData();
      final modifiedAgentData = overrideThinkingMode != null
          ? baseAgentData.copyWith(
              modelConfigure: baseAgentData.modelConfigure.copyWith(
                thinkingMode: overrideThinkingMode,
              ),
            )
          : baseAgentData;

      var fm = await PromptInjector(
        ref: ref,
        agentData: modifiedAgentData,
        history: history,
        lastMessage: usrMessage,
        stopSignal: stopSignal,
      ).inject();
      yield* state!.client.getStreamingResponse(
        modelRequestContent: fm,
        agentId: state!.id,
      );
    } else {
      throw AgentException(AgentExceptionType.agentNotLoaded);
    }
  }

  Future<({List<ContentChunk> chunks, String? thoughtSignature})> execute({
    required List<ChatMessage> history,
    required ChatMessage lastMessage,
    required ValueNotifier<List<ContentChunk>> responseNotifier,
    StopSignal? stopSignal,
  }) async {
    if (state == null) throw AgentException(AgentExceptionType.agentNotLoaded);

    final loop = ExecutionLoop(
      PromptInjector(
        ref: ref,
        agentData: state!.toAgentData(),
        history: history,
        lastMessage: lastMessage,
        stopSignal: stopSignal,
      ),
      state!.client,
      responseNotifier,
      tools: ref.read(toolsManagerProvider),
    );

    return await loop.execute();
  }
}

final agentProvider = StateNotifierProvider<AgentProvider, Agent?>(
  (ref) => AgentProvider(ref),
);
