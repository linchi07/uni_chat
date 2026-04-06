import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/Chat/chat_state.dart';
import 'package:uni_chat/Persona/persona_provider.dart';
import 'package:uni_chat/api_configs/api_service.dart';
import 'package:uni_chat/database/database_service.dart';
import 'package:uni_chat/error_handling.dart';
import 'package:uni_chat/main.dart';

import '../Chat/chat_models.dart';
import '../api_configs/api_models.dart';
import '../utils/file_utils.dart';
import '../utils/time_utils.dart';
import 'agent_models.dart';

class ModelSpecifics {
  String? modelName;
  Map<ModelParamName, dynamic> customParameters = {};
  int maxGenerationTokens = 2560;
  int maxContextTokens = 1000000000;
  bool enableTimeTelling = true;
  bool enableUsrLanguage = true;
  bool enableUsrSystemInformation = true;
  ModelSpecifics({
    this.modelName,
    Map<ModelParamName, dynamic>? customParameters,
    this.maxGenerationTokens = 2560,
    this.maxContextTokens = 1000000000,
    this.enableTimeTelling = true,
    this.enableUsrLanguage = true,
    this.enableUsrSystemInformation = true,
  }) : customParameters = customParameters ?? {};

  ModelSpecifics copyWith({
    String? modelName,
    Map<ModelParamName, dynamic>? customParameters,
    int? maxGenerationTokens,
    int? maxContextTokens,
    bool? enableTimeTelling,
    bool? enableUsrLanguage,
    bool? enableUsrSystemInformation,
  }) {
    return ModelSpecifics(
      modelName: modelName ?? this.modelName,
      customParameters: customParameters ?? Map.from(this.customParameters),
      maxGenerationTokens: maxGenerationTokens ?? this.maxGenerationTokens,
      maxContextTokens: maxContextTokens ?? this.maxContextTokens,
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

    return ModelSpecifics(
      modelName: json["modelName"] as String?,
      customParameters: params,
      maxGenerationTokens: json["maxGenerationTokens"] as int,
      maxContextTokens: json["maxContextTokens"] as int,
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
  AgentProvider(this.ref) : super(null) {
    loadDefaultAgent();
  }

  void loadDefaultAgent() async {
    try {
      var agentData = await DatabaseService.instance.loadDefaultAgent();
      if (agentData == null) {
        throw AgentException(AgentExceptionType.agentNotFound);
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
          ex = AgentException.fromAncestor(e);
        } else {
          ex = AgentException.fromException(e);
        }
        ref.read(chatStateProvider.notifier).stateCopyWith(error: ex);
      }
    }
  }

  Future<void> loadAgentById(String id, {bool forceReload = false}) async {
    if (state != null && state!.id == id && !forceReload) {
      return;
    }
    try {
      var agentData = await DatabaseService.instance.getAgent(id);
      if (agentData == null) {
        throw AgentException(AgentExceptionType.agentNotFound);
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
          ex = AgentException.fromAncestor(e);
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
  }

  ///以下是聊天时的功能实现

  final Ref ref;
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
  }) async* {
    if (state != null) {
      var fm = await formatMessage(history, usrMessage, stopSignal: stopSignal);
      /*
      if (state!.memoryBaseIds.isNotEmpty) {
        var rgp = ref.read(ragProvider);
        if (rgp.loadedAgentId != state!.id) {
          await rgp.loadKnowledgeBases(state!.memoryBaseIds, session);
        }
        if (usrMessage != null) {
          fm.ragMessages = await rgp.onUserNewMessageCall(usrMessage);
        }
      }*/
      yield* state!.client.getStreamingResponse(
        modelRequestContent: fm,
        agentId: state!.id,
      );
    } else {
      throw AgentException(AgentExceptionType.agentNotLoaded);
    }
  }

  int stripTokens(
    List<FormattedChatMessage> messages,
    int target,
    int present,
  ) {
    while (present > target && messages.isNotEmpty) {
      var toStrip = messages.removeAt(0); // Remove the oldest message
      present -= toStrip.tokens;
    }
    return present;
  }

  Future<ModelRequestContent> formatMessage(
    List<ChatMessage> history,
    ChatMessage? lastMessage, {
    StopSignal? stopSignal,
  }) async {
    if (state == null) {
      throw AgentException(AgentExceptionType.agentNotLoaded);
    }
    ModelRequestContent rc = ModelRequestContent(
      staticSystemMessages: [],
      dynamicSystemMessages: [],
      uiMessages: [],
      chatHistory: [],
      usrMessage: [],
      modelConfigure: state!.modelConfigure,
      ragMessages: [],
      stopSignal: stopSignal,
    );

    // 1. 构建静态系统指令 (Static Prefix)
    StringBuffer staticPrompt = StringBuffer();
    staticPrompt.writeln("你的名字是${state!.name}");
    if (state!.systemPrompt != null) {
      staticPrompt.writeln(state!.systemPrompt!);
    }

    // 注入人格信息
    var personaMsg = ref.read(personaProvider).getPersonaMessage();
    if (personaMsg != null) {
      for (var part in personaMsg.parts) {
        if (part.type == MessagePartType.text) {
          staticPrompt.writeln(part.content);
        }
      }
      if (state?.personaConfigure?.personaAdditionalInfo != null) {
        staticPrompt.writeln(state!.personaConfigure!.personaAdditionalInfo!);
      }
    }

    // 注入用户语言和系统信息 (静态，因为极少变动)
    if (state!.modelConfigure.enableUsrLanguage) {
      staticPrompt.writeln("使用${PlatForm().languageCode}和用户交流");
    }
    if (state!.modelConfigure.enableUsrSystemInformation) {
      staticPrompt.writeln("用户使用${PlatForm().platformInfo}系统");
    }

    // 注入 XML 标签说明
    staticPrompt.writeln("\n[重要指令]");
    staticPrompt.writeln(
      "你将收到包含 <system_metadata> 标签的消息。该标签内包含的是系统注入的当前客观环境事实（如当前时间），请将其作为推断上下文的基准信息，而非用户对话内容。",
    );

    rc.staticSystemMessages.add(
      FormattedChatMessage(
        id: "system_static",
        sender: MessageSender.system,
        parts: [
          MessagePart(
            type: MessagePartType.text,
            content: staticPrompt.toString(),
          ),
        ],
      ),
    );

    // 2. 处理对话历史
    var t1 = await processChatMessage(history, rc.chatHistory);

    // 3. 注入动态元数据 (Dynamic Metadata - User Role)
    // 放在历史记录之后，当前提问之前
    if (state!.modelConfigure.enableTimeTelling) {
      final now = DateTime.now();
      final lastMsgTime = history.isNotEmpty ? history.last.timestamp : null;

      final timeStr = TimeUtils.formatTimeForCache(now);
      final gapDesc = TimeUtils.getTimeGapDescription(now, lastMsgTime);

      StringBuffer metadataBuffer = StringBuffer();
      metadataBuffer.writeln("<system_metadata>");
      metadataBuffer.writeln("<current_time>$timeStr</current_time>");
      if (gapDesc != null) {
        metadataBuffer.writeln("<time_gap>$gapDesc</time_gap>");
      }
      metadataBuffer.write("</system_metadata>");

      rc.dynamicSystemMessages.add(
        FormattedChatMessage(
          id: "usr_time",
          sender: MessageSender.user, // 重写为 User 角色以符合静动分离策略
          parts: [
            MessagePart(
              type: MessagePartType.text,
              content: metadataBuffer.toString(),
            ),
          ],
        ),
      );
    }

    // 4. 处理用户当前提问
    int t2 = 0;
    if (lastMessage != null) {
      t2 = await processChatMessage([lastMessage], rc.usrMessage);
    }

    rc.modelConfigure = state!.modelConfigure;
    var t3 = rc.uiMessages.fold(0, (sum, i) => sum + i.tokens);
    var t4 = rc.staticSystemMessages.fold(0, (sum, i) => sum + i.tokens);
    var t5 = rc.dynamicSystemMessages.fold(0, (sum, i) => sum + i.tokens);

    // 使用 maxContextTokens 判定
    if (t1 + t2 + t3 + t4 + t5 > state!.modelConfigure.maxContextTokens) {
      var delta =
          t1 + t2 + t3 + t4 + t5 - state!.modelConfigure.maxContextTokens;
      stripTokens(rc.chatHistory, delta, t1);
    }
    return rc;
  }

  Future<int> processChatMessage(
    List<ChatMessage> messages,
    List<FormattedChatMessage> output,
  ) async {
    if (state == null) {
      throw AgentException(AgentExceptionType.agentNotLoaded);
    }
    int totalTokens = 0;
    for (var i in messages) {
      if (i.sender == MessageSender.internal) continue;

      List<MessagePart> parts = [];

      // 1. 处理多个附件文件
      if (i.attachedFiles != null && i.attachedFiles!.isNotEmpty) {
        for (var attachedFile in i.attachedFiles!) {
          switch (attachedFile.type) {
            case FileTypeDefine.text:
              var fileContent = await attachedFile.getFile();
              parts.add(
                MessagePart(
                  type: MessagePartType.text,
                  content:
                      "Uploaded File: Name: ${attachedFile.originalName}, Content: ${await fileContent.readAsString(encoding: utf8)}",
                ),
              );
              break;
            case FileTypeDefine.image:
              if (!state!.client.model.abilities.contains(ModelAbility.visual))
                continue;

              if (await (await attachedFile.getFile()).exists()) {
                var base64 = base64Encode(
                  await (await attachedFile.getFile()).readAsBytes(),
                );
                parts.add(
                  MessagePart(
                    type: MessagePartType.base64Image,
                    mimeType: attachedFile.mimeType,
                    content: base64,
                  ),
                );
              }
              break;
            case FileTypeDefine.pdf:
              if (await (await attachedFile.getFile()).exists()) {
                var base64 = base64Encode(
                  await (await attachedFile.getFile()).readAsBytes(),
                );
                parts.add(
                  MessagePart(
                    type: MessagePartType.base64pdf,
                    mimeType: attachedFile.mimeType,
                    content: base64,
                  ),
                );
              }
              break;
            default:
              break;
          }
        }
      }

      // 2. 处理文本内容
      if (i.content.isNotEmpty) {
        parts.add(MessagePart(type: MessagePartType.text, content: i.content));
      }

      if (parts.isNotEmpty) {
        var formatted = FormattedChatMessage(
          id: i.id,
          sender: i.sender,
          parts: parts,
        );
        output.add(formatted);
        totalTokens += formatted.tokens;
      }
    }
    return totalTokens;
  }
}

final agentProvider = StateNotifierProvider<AgentProvider, Agent?>(
  (ref) => AgentProvider(ref),
);
