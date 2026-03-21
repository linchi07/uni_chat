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
import 'agent_models.dart';

class ModelSpecifics {
  String? modelName;
  double temperature = 0.8;
  double topP = 0.5;
  double frequencyPenalty = 0.5;
  double presencePenalty = 0.5;
  int maxGenerationTokens = 2560;
  int maxContextTokens = 4096;
  bool enableTimeTelling = true;
  bool enableUsrLanguage = true;
  bool enableUsrSystemInformation = true;
  ModelSpecifics({
    this.modelName,
    this.temperature = 0.8,
    this.topP = 0.5,
    this.frequencyPenalty = 0.5,
    this.presencePenalty = 0.5,
    this.maxGenerationTokens = 2560,
    this.maxContextTokens = 4096,
    this.enableTimeTelling = true,
    this.enableUsrLanguage = true,
    this.enableUsrSystemInformation = true,
  });

  ModelSpecifics copyWith({
    String? modelName,
    double? temperature,
    double? topP,
    double? frequencyPenalty,
    double? presencePenalty,
    int? maxGenerationTokens,
    int? maxContextTokens,
    bool? enableTimeTelling,
    bool? enableUsrLanguage,
    bool? enableUsrSystemInformation,
  }) {
    return ModelSpecifics(
      modelName: modelName ?? this.modelName,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
      presencePenalty: presencePenalty ?? this.presencePenalty,
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
      "temperature": temperature,
      "topP": topP,
      "frequencyPenalty": frequencyPenalty,
      "presencePenalty": presencePenalty,
      "maxGenerationTokens": maxGenerationTokens,
      "maxContextTokens": maxContextTokens,
      "enableTimeTelling": enableTimeTelling,
      "enableUsrLanguage": enableUsrLanguage,
      "enableUsrSystemInformation": enableUsrSystemInformation,
    };
  }

  factory ModelSpecifics.fromJson(Map<String, dynamic> json) {
    return ModelSpecifics(
      modelName: json["modelName"] as String?,
      temperature: json["temperature"] as double,
      topP: json["topP"] as double,
      frequencyPenalty: json["frequencyPenalty"] as double,
      presencePenalty: json["presencePenalty"] as double,
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
      var toStrip = messages.removeLast();
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
    rc.staticSystemMessages.add(
      FormattedChatMessage(
        type: ChatMessageType.text,
        id: "systemPre",
        sender: MessageSender.system,
        content: "你的名字是${state!.name}",
      ),
    );
    if (state!.systemPrompt != null) {
      rc.staticSystemMessages.add(
        FormattedChatMessage(
          type: ChatMessageType.text,
          id: "system",
          sender: MessageSender.system,
          content: state!.systemPrompt!,
        ),
      );
    }
    var personaMsg = ref.read(personaProvider).getPersonaMessage();
    if (personaMsg != null) {
      rc.staticSystemMessages.add(
        personaMsg.copyWith(
          content:
              personaMsg.content +
              (state?.personaConfigure?.personaAdditionalInfo ?? ""),
        ),
      );
    }
    if (state!.modelConfigure.enableUsrLanguage) {
      //TODO: 获取用户语言
      rc.staticSystemMessages.add(
        FormattedChatMessage(
          type: ChatMessageType.text,
          id: "usr_language",
          sender: MessageSender.system,
          content: "用户语言为 ${PlatForm().languageCode}",
        ),
      );
    }
    if (state!.modelConfigure.enableUsrSystemInformation) {
      rc.staticSystemMessages.add(
        FormattedChatMessage(
          type: ChatMessageType.text,
          id: "usr_system_information",
          sender: MessageSender.system,
          content: "用户系统信息为：${PlatForm().platformInfo}",
        ),
      );
    }
    if (state!.modelConfigure.enableTimeTelling) {
      rc.dynamicSystemMessages.add(
        FormattedChatMessage(
          type: ChatMessageType.text,
          id: "usr_time",
          sender: MessageSender.system,
          content: "当前时间为：${DateTime.now().toIso8601String()}",
        ),
      );
    }
    var t1 = await processChatMessage(history, rc.chatHistory);
    int t2 = 0;
    if (lastMessage != null) {
      t2 = await processChatMessage([lastMessage], rc.usrMessage);
    }
    rc.modelConfigure = state!.modelConfigure;
    var t3 = 0;
    for (var i in rc.uiMessages) {
      t3 += i.tokens;
    }
    var t4 = 0;
    for (var i in rc.staticSystemMessages) {
      t4 += i.tokens;
    }
    var t5 = 0;
    for (var i in rc.dynamicSystemMessages) {
      t5 += i.tokens;
    }
    if (t1 + t2 + t3 + t4 + t5 > state!.modelConfigure.maxGenerationTokens) {
      //TODO:implement better logic
      var delta =
          t1 + t2 + t3 + t4 + t5 - state!.modelConfigure.maxGenerationTokens;
      stripTokens(rc.chatHistory, delta, t1);
    }
    return rc;
  }

  Future<int> processChatMessage(
    List<ChatMessage> message,
    List<FormattedChatMessage> output,
  ) async {
    if (state == null) {
      throw AgentException(AgentExceptionType.agentNotLoaded);
    }
    int totalTokens = 0;
    for (var i in message) {
      switch (i.sender) {
        case MessageSender.internal:
          continue; //skip the internal messages ,mostly message root
        case MessageSender.user:
          // 处理多个附件文件
          if (i.attachedFiles != null && i.attachedFiles!.isNotEmpty) {
            for (var at in i.attachedFiles!) {
              var attachedFile = at;
              switch (attachedFile.type) {
                case FileTypeDefine.text:
                  var fileContent = await attachedFile.getFile();
                  output.add(
                    FormattedChatMessage(
                      type: ChatMessageType.text,
                      id: i.id,
                      sender: MessageSender.user,
                      content:
                          "Uploaded File： Name：${attachedFile.originalName}，fileContent：${await fileContent.readAsString(encoding: utf8)}",
                    ),
                  );
                  break;
                case FileTypeDefine.image:
                  //当模型不支持图片识别的时候直接忽略图片
                  if (!state!.client.model.abilities.contains(
                    ModelAbility.visual,
                  )) {
                    continue;
                  }
                  if ( /*!state!.client.abilities.contains(
                    ApiAbility.supportsFilesApi,
                  )*/ true) {
                    // 暂时fallback
                    //当不支持文件API的时候我们必须一个个上传
                    if (await (await attachedFile.getFile()).exists()) {
                      var base64 = base64Encode(
                        await (await attachedFile.getFile()).readAsBytes(),
                      );
                      output.add(
                        FormattedChatMessage(
                          type: ChatMessageType.base64Image,
                          mimeType: attachedFile.mimeType,
                          id: i.id,
                          sender: MessageSender.user,
                          content: base64,
                        ),
                      );
                    }
                    break;
                  }
                  var f =
                      attachedFile.providerInfo[state!.client.provider.name];
                  if (f == null ||
                      !await (await attachedFile.getFile()).exists()) {
                    break;
                  }
                  late String fid;
                  if (DateTime.now().difference(f.$2) >= Duration(days: 2) ||
                      !attachedFile.providerInfo.containsKey(
                        state!.client.provider.id,
                      )) {
                    var id = await fileUpload(
                      await attachedFile.getFile(),
                      attachedFile.mimeType,
                    );

                    if (id == null) {
                      throw Exception("上传失败");
                    }
                    fid = id;
                  } else {
                    fid = f.$1;
                  }
                  output.add(
                    FormattedChatMessage(
                      type: ChatMessageType.image,
                      mimeType: attachedFile.mimeType,
                      id: i.id,
                      sender: MessageSender.user,
                      content: fid,
                    ),
                  );
                  break;
                case FileTypeDefine.pdf:
                  if ( /*!state!.model.abilities.contains(
                    ApiAbility.supportsFilesApi,
                  )*/ true) {
                    // 暂时fallback
                    //当不支持文件API的时候我们必须一个个上传
                    if (await (await attachedFile.getFile()).exists()) {
                      var base64 = base64Encode(
                        await (await attachedFile.getFile()).readAsBytes(),
                      );
                      output.add(
                        FormattedChatMessage(
                          id: i.id,
                          type: ChatMessageType.base64pdf,
                          mimeType: attachedFile.mimeType,
                          content: base64,
                          sender: MessageSender.user,
                        ),
                      );
                    }
                    break;
                  }
                  var f = attachedFile.providerInfo[state!.client.provider.id];
                  if (f == null ||
                      !await (await attachedFile.getFile()).exists()) {
                    break;
                  }
                  late String fid;
                  if (DateTime.now().difference(f.$2) >= Duration(days: 2) ||
                      !attachedFile.providerInfo.containsKey(
                        state!.client.provider.id,
                      )) {
                    if (DateTime.now().difference(f.$2) >= Duration(days: 2) ||
                        !attachedFile.providerInfo.containsKey(
                          state!.client.provider.id,
                        )) {
                      var id = await fileUpload(
                        await attachedFile.getFile(),
                        attachedFile.mimeType,
                      );

                      if (id == null) {
                        throw Exception("上传失败");
                      }
                      fid = id;
                    } else {
                      fid = f.$1;
                    }
                  } else {
                    fid = f.$1;
                  }
                  output.add(
                    FormattedChatMessage(
                      mimeType: attachedFile.mimeType,
                      type: ChatMessageType.pdf,
                      id: i.id,
                      sender: MessageSender.user,
                      content: fid,
                    ),
                  );
                  break;
                default:
                  break;
              }
            }
          }
          if (i.content.isNotEmpty) {
            output.add(
              FormattedChatMessage(
                type: ChatMessageType.text,
                id: i.id,
                sender: MessageSender.user,
                content: i.content,
              ),
            );
          }
          totalTokens += output.last.tokens;
          break;
        case MessageSender.ai:
          output.add(
            FormattedChatMessage(
              type: ChatMessageType.text,
              id: i.id,
              sender: MessageSender.ai,
              content: i.content,
            ),
          );
          totalTokens += output.last.tokens;
          break;
        /*
          这里我们已经采用了全新的agent框架，不会在history中涉及system 消息了
        case MessageSender.system:
          output.add(
            FormattedChatMessage(
              type: ChatMessageType.text,
              id: i.id,
              sender: MessageSender.system,
              content: i.content,
            ),
          );
          break;*/
        default:
          break;
      }
    }
    return totalTokens;
  }
}

final agentProvider = StateNotifierProvider<AgentProvider, Agent?>(
  (ref) => AgentProvider(ref),
);
