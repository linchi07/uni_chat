import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/Chat/chat_page_main.dart';
import 'package:uni_chat/Persona/persona_provider.dart';
import 'package:uni_chat/llm_provider/api_service.dart';
import 'package:uni_chat/main.dart';
import 'package:uni_chat/utils/database_service.dart';

import '../Chat/chat_models.dart';
import '../llm_provider/api_service_provider.dart';

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
    required this.model,
    this.systemPrompt,
    required this.modelSpecifics,
  });
  final String id;
  final String name;
  final bool enableUIQL = false;
  final String? systemPrompt;
  final ModelSpecifics modelSpecifics;
  Set<ApiAbility> get abilities => model.abilities;
  LLMApiService model;

  factory Agent.fromAgentData(AgentData agentData, LLMApiService model) {
    return Agent(
      id: agentData.id,
      name: agentData.name,
      model: model,
      modelSpecifics: agentData.modelSpecifics,
      systemPrompt: agentData.systemPrompt,
    );
  }

  Agent copyWith({
    Ref? ref,
    String? id,
    String? name,
    LLMApiService? model,
    ModelSpecifics? modelSpecifics,
    String? systemPrompt,
  }) {
    return Agent(
      id: id ?? this.id,
      name: name ?? this.name,
      model: model ?? this.model,
      modelSpecifics: modelSpecifics ?? this.modelSpecifics,
      systemPrompt: systemPrompt ?? this.systemPrompt,
    );
  }
}

class AgentProvider extends StateNotifier<Agent?> {
  AgentProvider(this.ref) : super(null) {
    loadDefaultAgent();
  }

  void loadDefaultAgent() async {
    var agentData = await DatabaseService.instance.loadDefaultAgent();
    if (agentData != null) {
      // 4. Create the API service
      final modelService = await ApiServiceProvider.instance.createApiService(
        agentData.modelProviderConfigureId,
      );
      if (modelService == null) {
        //TODO: implement better error handling
        throw Exception('Failed to create API service for the agent.');
      }
      state = Agent.fromAgentData(agentData, modelService);
    }
  }

  Future<void> loadAgentById(String id) async {
    if (state != null && state!.id == id) {
      return;
    }
    var agentData = await DatabaseService.instance.getAgent(id);
    if (agentData != null) {
      // 4. Create the API service
      final modelService = await ApiServiceProvider.instance.createApiService(
        agentData.modelProviderConfigureId,
      );
      if (modelService == null) {
        //TODO: implement better error handling
        throw Exception('Failed to create API service for the agent.');
      }
      state = Agent.fromAgentData(agentData, modelService);
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
      if (state!.model.abilities.contains(ApiAbility.supportFilesApi)) {
        var r = await state!.model.fileUpload(
          file, // 使用拷贝后的文件
          mime,
        );
        if (r == null) {
          return null;
        }
        return r;
      }
      return null;
    }
    // 处理未初始化的情况
    throw Exception("Agent not initialized");
  }

  Stream<ChatResponse> getStreamingResponse(
    List<ChatMessage> history,
    ChatMessage usrMessage,
    Map<String, ChatFile> uploadedFiles,
  ) async* {
    if (state != null) {
      var fm = await formatMessage(history, usrMessage, uploadedFiles);
      yield* state!.model.getStreamingResponse(fm);
    } else {
      throw Exception("Agent not initialized");
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
    ChatMessage usrMessage,
    Map<String, ChatFile> uploadedFiles,
  ) async {
    if (state == null) {
      throw Exception("Agent not initialized");
    }
    ModelRequestContent rc = ModelRequestContent(
      staticSystemMessages: [],
      dynamicSystemMessages: [],
      uiMessages: [],
      chatHistory: [],
      usrMessage: [],
      modelSpecifics: state!.modelSpecifics,
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
    rc.staticSystemMessages.add(ref.read(personaProvider).getPersonaMessage());
    if (state!.modelSpecifics.enableUsrLanguage) {
      //TODO: 获取用户语言
      rc.staticSystemMessages.add(
        FormattedChatMessage(
          type: ChatMessageType.text,
          id: "usr_language",
          sender: MessageSender.system,
          content: "用户语言为：简体中文,用户的地区为：中国",
        ),
      );
    }
    if (state!.modelSpecifics.enableUsrSystemInformation) {
      rc.staticSystemMessages.add(
        FormattedChatMessage(
          type: ChatMessageType.text,
          id: "usr_system_information",
          sender: MessageSender.system,
          content: "用户系统信息为：${PlatForm().platformInfo}",
        ),
      );
    }
    if (state!.modelSpecifics.enableTimeTelling) {
      rc.dynamicSystemMessages.add(
        FormattedChatMessage(
          type: ChatMessageType.text,
          id: "usr_time",
          sender: MessageSender.system,
          content: "当前时间为：${DateTime.now().toIso8601String()}",
        ),
      );
    }
    if (state!.enableUIQL) {
      var ps = ref.read(panelManager).triggerPanelSummary();
      rc.staticSystemMessages.add(
        FormattedChatMessage(
          type: ChatMessageType.text,
          id: "usr_uiql",
          sender: MessageSender.system,
          content: "当前UIQL版本为：1.0.0",
        ),
      );
      if (ps != null) {
        rc.uiMessages = ps;
      }
    }
    var t1 = await processChatMessage(history, rc.chatHistory, uploadedFiles);
    var t2 = await processChatMessage(
      [usrMessage],
      rc.usrMessage,
      uploadedFiles,
    );
    rc.modelSpecifics = state!.modelSpecifics;
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
    if (t1 + t2 + t3 + t4 + t5 > state!.modelSpecifics.maxGenerationTokens) {
      //TODO:implement better logic
      var delta =
          t1 + t2 + t3 + t4 + t5 - state!.modelSpecifics.maxGenerationTokens;
      stripTokens(rc.chatHistory, delta, t1);
    }
    return rc;
  }

  Future<int> processChatMessage(
    List<ChatMessage> message,
    List<FormattedChatMessage> output,
    Map<String, ChatFile> uploadedFiles,
  ) async {
    if (state == null) {
      //TODO: 添加错误处理
      throw Exception("Agent not initialized");
    }
    int totalTokens = 0;
    for (var i in message) {
      switch (i.sender) {
        case MessageSender.user:
          // 处理多个附件文件
          if (i.attachedFiles != null && i.attachedFiles!.isNotEmpty) {
            for (var at in i.attachedFiles!) {
              var attachedFile = uploadedFiles[at];
              if (attachedFile == null) {
                continue;
              }
              switch (attachedFile.type) {
                case FileTypeDefine.text:
                  var fileContent = await attachedFile.getFile();
                  output.add(
                    FormattedChatMessage(
                      type: ChatMessageType.text,
                      id: i.id,
                      sender: MessageSender.user,
                      content:
                          "Uploaded File： Name：${attachedFile.original_name}，fileContent：${await fileContent.readAsBytes()}",
                    ),
                  );
                  break;
                case FileTypeDefine.image:
                  //当模型不支持图片识别的时候直接忽略图片
                  if (!state!.model.abilities.contains(
                    ApiAbility.visualUnderStanding,
                  )) {
                    continue;
                  }
                  if (!state!.model.abilities.contains(
                    ApiAbility.supportFilesApi,
                  )) {
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
                  var f = attachedFile.providerInfo[state!.model.providerName];
                  if (f == null ||
                      !await (await attachedFile.getFile()).exists()) {
                    break;
                  }
                  late String fid;
                  if (DateTime.now().difference(f.$2) >= Duration(days: 2) ||
                      !attachedFile.providerInfo.containsKey(
                        state!.model.providerName,
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
                  if (!state!.model.abilities.contains(
                    ApiAbility.supportFilesApi,
                  )) {
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
                  var f = attachedFile.providerInfo[state!.model.providerName];
                  if (f == null ||
                      !await (await attachedFile.getFile()).exists()) {
                    break;
                  }
                  late String fid;
                  if (DateTime.now().difference(f.$2) >= Duration(days: 2) ||
                      !attachedFile.providerInfo.containsKey(
                        state!.model.providerName,
                      )) {
                    if (DateTime.now().difference(f.$2) >= Duration(days: 2) ||
                        !attachedFile.providerInfo.containsKey(
                          state!.model.providerName,
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
            totalTokens += output.last.tokens;
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
