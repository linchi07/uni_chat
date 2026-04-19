import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/Agent/agent_models.dart';
import 'package:uni_chat/Chat/chat_models.dart';
import 'package:uni_chat/Execution/execution_models.dart';
import 'package:uni_chat/Execution/toolcall_parser.dart';
import 'package:uni_chat/Persona/persona_provider.dart';
import 'package:uni_chat/api_configs/api_database.dart';
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/main.dart'; // 添加主文件引用以使用 PlatForm 类
import 'package:uni_chat/utils/time_utils.dart';

/// PromptInjector 负责将各种上下文信息（Agent 配置、人格、历史、系统元数据）
/// 转换为模型可以直接使用的格式。
const bool USE_NATIVE_TOOL_CALL = true;

class PromptInjector {
  final Ref ref;
  final AgentData agentData;
  final List<ChatMessage> history;
  final ChatMessage? lastMessage;
  final StopSignal? stopSignal;
  final List<IntermediateTurn> _intermediateTurns = [];

  PromptInjector({
    required this.ref,
    required this.agentData,
    required this.history,
    this.lastMessage,
    this.stopSignal,
  });

  /// 追加中间轮次（结构化数据）
  void appendIntermediateTurn(IntermediateTurn turn) {
    _intermediateTurns.add(turn);
  }

  /// 为了适配现有代码中的 await injector 语法（如果 injector 被当作 Future 使用）
  /// 或者可以直接调用此方法。
  Future<ModelRequestContent> inject() async {
    final model = await ApiDatabase.instance.getModelById(agentData.modelConfigure.modelId);
    
    ModelRequestContent rc = ModelRequestContent(
      staticSystemMessages: [],
      dynamicSystemMessages: [],
      uiMessages: [],
      chatHistory: [],
      usrMessage: [],
      modelConfigure: agentData.modelConfigure,
      ragMessages: [],
      stopSignal: stopSignal,
    );

    // 1. 构建静态系统指令 (Static Prefix)
    StringBuffer staticPrompt = StringBuffer();
    if (agentData.name.isNotEmpty) {
      staticPrompt.writeln("你的名字是${agentData.name}");
    }
    if (agentData.systemPrompt != null) {
      staticPrompt.writeln(agentData.systemPrompt!);
    }

    // 注入人格信息
    final personaMsg = ref.read(personaProvider).getPersonaMessage();
    if (personaMsg != null) {
      for (var part in personaMsg.parts) {
        if (part.type == MessagePartType.text) {
          staticPrompt.writeln(part.content);
        }
      }
      if (agentData.userIdentityConfigure?.personaAdditionalInfo != null) {
        staticPrompt.writeln(agentData.userIdentityConfigure!.personaAdditionalInfo!);
      }
    }

    // 注入用户语言和系统信息
    if (agentData.modelConfigure.enableUsrLanguage) {
      staticPrompt.writeln("使用${PlatForm().languageCode}和用户交流");
    }
    if (agentData.modelConfigure.enableUsrSystemInformation) {
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
    var t1 = await _processChatMessage(history, rc.chatHistory, model);

    // 追加中间轮次 (实时格式化)
    final toolFormat = model != null ? ToolCallParser.getFormatForFamily(model.family) : ToolCallFormat.xml;
    
    for (var turn in _intermediateTurns) {
      if (turn is AssistantTurn) {
        if (USE_NATIVE_TOOL_CALL && turn.toolCalls.isNotEmpty) {
           // 提取文本部分和工具调用部分
           var formatted = FormattedChatMessage(
             id: "turn_intermediate_${rc.chatHistory.length}",
             sender: MessageSender.ai,
             parts: [
               if (turn.text.isNotEmpty) MessagePart(type: MessagePartType.text, content: turn.text),
               ...turn.toolCalls.map((c) => MessagePart(
                 type: MessagePartType.toolCall, 
                 content: jsonEncode({
                   "name": c.name, 
                   "arguments": c.arguments, 
                   "callId": c.callId
                 })
               )),
             ],
           );
           rc.chatHistory.add(formatted);
           t1 += formatted.tokens;
        } else {
          var content = turn.text;
          if (turn.toolCalls.isNotEmpty) {
             var formattedCalls = ToolCallParser.formatCall(turn.toolCalls, toolFormat);
             content = "$content\n$formattedCalls".trim();
          }
          var formatted = FormattedChatMessage(
            id: "turn_intermediate_${rc.chatHistory.length}",
            sender: MessageSender.ai,
            parts: [MessagePart(type: MessagePartType.text, content: content)],
          );
          rc.chatHistory.add(formatted);
          t1 += formatted.tokens;
        }
      } else if (turn is ToolResultTurn) {
        if (USE_NATIVE_TOOL_CALL) {
          var formatted = FormattedChatMessage(
            id: "turn_intermediate_res_${rc.chatHistory.length}",
            sender: MessageSender.user,
            parts: turn.results.map((r) => MessagePart(
              type: MessagePartType.toolResult,
              content: jsonEncode({
                "name": r.name,
                "result": r.result,
                "callId": r.callId
              })
            )).toList(),
          );
          rc.chatHistory.add(formatted);
          t1 += formatted.tokens;
        } else {
          for (var resultCall in turn.results) {
            var formattedResult = ToolCallParser.formatResult(resultCall, toolFormat);
            var formatted = FormattedChatMessage(
              id: "turn_intermediate_res_${rc.chatHistory.length}",
              sender: MessageSender.user,
              parts: [MessagePart(type: MessagePartType.text, content: formattedResult)],
            );
            rc.chatHistory.add(formatted);
            t1 += formatted.tokens;
          }
        }
      }
    }

    // 3. 注入动态元数据
    if (agentData.modelConfigure.enableTimeTelling) {
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
          sender: MessageSender.user,
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
      t2 = await _processChatMessage([lastMessage!], rc.usrMessage, model);
    }

    var t3 = rc.uiMessages.fold(0, (sum, i) => sum + i.tokens);
    var t4 = rc.staticSystemMessages.fold(0, (sum, i) => sum + i.tokens);
    var t5 = rc.dynamicSystemMessages.fold(0, (sum, i) => sum + i.tokens);

    // 令牌超限处理
    if (t1 + t2 + t3 + t4 + t5 > agentData.modelConfigure.maxContextTokens) {
      var delta = t1 + t2 + t3 + t4 + t5 - agentData.modelConfigure.maxContextTokens;
      _stripTokens(rc.chatHistory, delta, t1);
    }

    return rc;
  }

  Future<int> _processChatMessage(
    List<ChatMessage> messages,
    List<FormattedChatMessage> output,
    Model? model,
  ) async {
    int totalTokens = 0;
    final bool supportsVisual = model?.abilities.contains(ModelAbility.visual) ?? false;

    for (var i in messages) {
      if (i.sender == MessageSender.internal) continue;

      List<MessagePart> parts = [];

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
              if (!supportsVisual) continue;

              final file = await attachedFile.getFile();
              if (await file.exists()) {
                var base64 = base64Encode(await file.readAsBytes());
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
              final file = await attachedFile.getFile();
              if (await file.exists()) {
                var base64 = base64Encode(await file.readAsBytes());
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

      if (i.content.isNotEmpty) {
        parts.add(MessagePart(type: MessagePartType.text, content: i.content));
      }

      // 如果有包含工具调用的结构化数据，优先使用它进行还原
      final toolFormat = model != null ? ToolCallParser.getFormatForFamily(model.family) : ToolCallFormat.xml;

      if (i.data != null && (i.data!.containsKey('structured_tool_calls') || i.data!.containsKey('tool_calls'))) {
         List<dynamic> callsData = i.data!['structured_tool_calls'] ?? i.data!['tool_calls'];
         List<ParsedToolCall> calls = callsData.map((d) => ParsedToolCall(
           name: d['name'],
           arguments: d['arguments'],
           format: toolFormat,
           callId: d['callId'],
         )).toList();
         
         if (calls.isNotEmpty) {
           if (USE_NATIVE_TOOL_CALL) {
             parts.addAll(calls.map((c) => MessagePart(
               type: MessagePartType.toolCall,
               content: jsonEncode({
                 "name": c.name,
                 "arguments": c.arguments,
                 "callId": c.callId
               })
             )));
           } else {
             parts.add(MessagePart(
               type: MessagePartType.text, 
               content: ToolCallParser.formatCall(calls, toolFormat)
             ));
           }
         }
      } else if (i.data != null && i.data!.containsKey('msg_blocks')) {
        // 回退逻辑：处理旧格式
        List<dynamic> blocks = i.data!['msg_blocks'];
        for (var b in blocks) {
          MessageBlock block = MessageBlock.fromMap(b);
          if (block.chunkType == MessageChunkType.toolCall) {
            parts.add(MessagePart(type: MessagePartType.text, content: block.content));
          }
        }
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

      // 提取被存储的工具调用返回结果
      if (i.data != null && (i.data!.containsKey('tool_results') || i.data!.containsKey('structured_tool_results'))) {
        List<dynamic> toolResults = i.data!['structured_tool_results'] ?? i.data!['tool_results'];
        
        if (USE_NATIVE_TOOL_CALL) {
          var nativeParts = toolResults.map((tr) => MessagePart(
            type: MessagePartType.toolResult,
            content: jsonEncode({
              "name": tr is Map ? tr['name'] : "unknown",
              "result": tr is Map ? tr['result'] : tr.toString(),
              "callId": tr is Map ? tr['callId'] : null,
            })
          )).toList();
          
          var resultFormatted = FormattedChatMessage(
            id: "${i.id}_tool_res_native",
            sender: MessageSender.user,
            parts: nativeParts,
          );
          output.add(resultFormatted);
          totalTokens += resultFormatted.tokens;
        } else {
          for (var idx = 0; idx < toolResults.length; idx++) {
            var tr = toolResults[idx];
            
            String content;
            if (tr is Map && tr.containsKey('name')) {
               // 结构化还原
               var dummyCall = ParsedToolCall(
                 name: tr['name'], 
                 arguments: {}, 
                 format: toolFormat,
                 callId: tr['callId'],
               )..result = tr['result'];
               content = ToolCallParser.formatResult(dummyCall, toolFormat);
            } else {
               // 旧版回退
               content = tr['result'] ?? tr.toString();
            }

            var resultFormatted = FormattedChatMessage(
              id: "${i.id}_tool_res_$idx",
              sender: MessageSender.user,
              parts: [MessagePart(type: MessagePartType.text, content: content)],
            );
            output.add(resultFormatted);
            totalTokens += resultFormatted.tokens;
          }
        }
      }
    }
    return totalTokens;
  }

  int _stripTokens(
    List<FormattedChatMessage> messages,
    int target,
    int present,
  ) {
    while (present > target && messages.isNotEmpty) {
      var stripped = messages.removeAt(0);
      present -= stripped.tokens;
    }
    return present;
  }
}
