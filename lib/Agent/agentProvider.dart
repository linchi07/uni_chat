import 'dart:convert';
import 'dart:io';

import 'package:uni_chat/Agent/agent_set_page.dart';
import 'package:uni_chat/Chat/chat_page_main.dart';
import 'package:uni_chat/llm_provider/api_service.dart';
import 'package:uni_chat/main.dart';
import 'package:uni_chat/utils/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Chat/chat_models.dart';

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
    this.ref,
    required this.id,
    required this.name,
    required this.model,
    this.systemPrompt,
    required this.modelSpecifics,
  });
  late final Ref? ref;
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
      ref: ref ?? this.ref,
      id: id ?? this.id,
      name: name ?? this.name,
      model: model ?? this.model,
      modelSpecifics: modelSpecifics ?? this.modelSpecifics,
      systemPrompt: systemPrompt ?? this.systemPrompt,
    );
  }

  Future<String?> uploadFile(File file, String mimeType) async {
    if (model.abilities.contains(ApiAbility.supportFilesApi)) {
      var r = await model.fileUpload(
        file, // 使用拷贝后的文件
        mimeType,
      );
      if (r == null) {
        return null;
      }
      return id;
    }
    return null;
  }

  Future<ModelRequestContent> formatMessage(
    List<ChatMessage> history,
    ChatMessage usrMessage,
    Map<String, ChatFile> uploadedFiles,
  ) async {
    ModelRequestContent rc = ModelRequestContent(
      staticSystemMessages: [],
      dynamicSystemMessages: [],
      uiMessages: [],
      chatHistory: [],
      usrMessage: [],
      modelSpecifics: modelSpecifics,
    );
    rc.staticSystemMessages.add(
      FormattedChatMessage(
        type: ChatMessageType.text,
        id: "systemPre",
        sender: MessageSender.system,
        content: "你的名字是$name",
      ),
    );
    if (systemPrompt != null) {
      rc.staticSystemMessages.add(
        FormattedChatMessage(
          type: ChatMessageType.text,
          id: "system",
          sender: MessageSender.system,
          content: systemPrompt!,
        ),
      );
    }
    if (modelSpecifics.enableUsrLanguage) {
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
    if (modelSpecifics.enableUsrSystemInformation) {
      rc.staticSystemMessages.add(
        FormattedChatMessage(
          type: ChatMessageType.text,
          id: "usr_system_information",
          sender: MessageSender.system,
          content: "用户系统信息为：${PlatForm().platformInfo}",
        ),
      );
    }
    if (modelSpecifics.enableTimeTelling) {
      rc.dynamicSystemMessages.add(
        FormattedChatMessage(
          type: ChatMessageType.text,
          id: "usr_time",
          sender: MessageSender.system,
          content: "当前时间为：${DateTime.now().toIso8601String()}",
        ),
      );
    }
    if (enableUIQL) {
      var ps = ref!.read(panelManager).triggerPanelSummary();
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
    rc.modelSpecifics = modelSpecifics;
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
    if (t1 + t2 + t3 + t4 + t5 > modelSpecifics.maxGenerationTokens) {
      //TODO:implement better logic
      var delta = t1 + t2 + t3 + t4 + t5 - modelSpecifics.maxGenerationTokens;
      stripTokens(rc.chatHistory, delta, t1);
    }
    return rc;
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

  Future<int> processChatMessage(
    List<ChatMessage> message,
    List<FormattedChatMessage> output,
    Map<String, ChatFile> uploadedFiles,
  ) async {
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
                          "Uploaded File： Name：${attachedFile.original_name}，fileContent：$fileContent",
                    ),
                  );
                  break;
                case FileTypeDefine.image:
                  //当模型不支持图片识别的时候直接忽略图片
                  if (!model.abilities.contains(
                    ApiAbility.visualUnderStanding,
                  )) {
                    continue;
                  }
                  if (!model.abilities.contains(ApiAbility.supportFilesApi)) {
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
                  var f = attachedFile.providerInfo[model.providerName];
                  if (f == null ||
                      !await (await attachedFile.getFile()).exists()) {
                    break;
                  }
                  late String fid;
                  if (DateTime.now().difference(f.$2) >= Duration(days: 2) ||
                      !attachedFile.providerInfo.containsKey(
                        model.providerName,
                      )) {
                    var id = await uploadFile(
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
                  if (!model.abilities.contains(ApiAbility.supportFilesApi)) {
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
                  var f = attachedFile.providerInfo[model.providerName];
                  if (f == null ||
                      !await (await attachedFile.getFile()).exists()) {
                    break;
                  }
                  late String fid;
                  if (DateTime.now().difference(f.$2) >= Duration(days: 2) ||
                      !attachedFile.providerInfo.containsKey(
                        model.providerName,
                      )) {
                    if (DateTime.now().difference(f.$2) >= Duration(days: 2) ||
                        !attachedFile.providerInfo.containsKey(
                          model.providerName,
                        )) {
                      var id = await uploadFile(
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

class AgentProvider extends StateNotifier<Agent?> {
  AgentProvider(this.ref) : super(null);
  final Ref ref;
  Future<String?> fileUpload(File file, String mime) {
    if (state != null) {
      return state!.uploadFile(file, mime);
    }
    // 处理未初始化的情况
    throw Exception("Agent not initialized");
  }

  Stream<ChatResponse> getStreamingResponse(ModelRequestContent fm) {
    if (state != null) {
      return state!.model.getStreamingResponse(fm);
    }
    // 返回空流或抛出异常
    throw Exception("Agent not initialized");
  }

  Future<ModelRequestContent> formatMessages(
    List<ChatMessage> history,
    ChatMessage usrMessage,
    Map<String, ChatFile> attachedFiles,
  ) async {
    if (state != null) {
      return await state!.formatMessage(history, usrMessage, attachedFiles);
    }
    // 处理未初始化情况的逻辑
    throw Exception("Agent not initialized");
  }

  void setAgent(Agent agent) {
    agent = agent.copyWith(ref: ref);
    state = agent;
  }
}

final agentProvider = StateNotifierProvider<AgentProvider, Agent?>(
  (ref) => AgentProvider(ref),
);
