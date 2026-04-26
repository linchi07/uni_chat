import 'package:flutter/widgets.dart';
import 'package:uni_chat/Agent/prompt_injector.dart';
import 'package:uni_chat/Chat/chat_models.dart';
import 'package:uni_chat/Execution/execution_models.dart';
import 'package:uni_chat/Execution/tools_manager.dart';
import 'package:uni_chat/Execution/xml_dynamic_parser.dart';
import 'package:uni_chat/api_configs/api_service.dart';
import 'package:uni_chat/utils/chunked_string_buffer.dart';

class Id {
  int _id = 0;
  int get id => _id++;
}

class ExecutionLoop {
  final ToolsManager tools;
  final PromptInjector injector;
  final ApiClient client;
  final ValueNotifier<List<ContentChunk>> output;
  List<ToolCallChunk> runningToolCalls = [];
  ExecutionLoop(this.injector, this.client, this.output, {required this.tools});
  Id id = Id(); // 在一轮对话中生成唯一自增ID，而且整个while循环中不得有任何Id的重复
  Future<({List<ContentChunk> chunks, String? thoughtSignature})> execute() async {
    List<ContentChunk> accumulatedOutput = [];
    String? thoughtSignature;

    while (true) {
      // 1. 获取或更新提示词
      var p = await injector.inject();
      // 2. 获取模型流式输出
      var stream = client.getStreamingResponse(modelRequestContent: p);

      var buffer = ChunkedStringBuffer();
      var parser = InputParser(buffer, id);
      var reasoningBuffer = ChunkedStringBuffer();
      var reasoningParser = InputParser(reasoningBuffer, id, defaultChunkType: MessageChunkType.reasoning);
      List<ToolCallChunk> nativeToolCalls = [];

      void formatOutput() {
        List<ContentChunk> newOutput = List.from(accumulatedOutput);

        List<ContentChunk> currentOutput = [];
        currentOutput.addAll(parser.blocksCached);
        currentOutput.addAll(parser.unfinishedBlocks);

        currentOutput.addAll(reasoningParser.blocksCached);
        currentOutput.addAll(reasoningParser.unfinishedBlocks);

        currentOutput.addAll(nativeToolCalls);

        currentOutput.sort((a, b) => a.id.compareTo(b.id));

        newOutput.addAll(currentOutput);
        this.output.value = newOutput;
      }

      await for (var chunk in stream) {
        if (chunk.thoughtSignature != null) {
          thoughtSignature = chunk.thoughtSignature;
        }
        //将api处已经分类解析完成的chunk放到应该去的列表
        switch (chunk.type) {
          case MessageChunkType.text:
            //部分模型会在文字输出中直接输出think或者工具调用，需要额外解析
            buffer.write(chunk.content);
            parser.parseDynamicBlock();
            break;
          case MessageChunkType.image:
            // TODO: Handle this case.
            throw UnimplementedError();
          case MessageChunkType.reasoning:
            //据说DeepSeek会在思考的时候直接调用工具，保险起见，进行xml的解析。
            reasoningBuffer.write(chunk.content);
            reasoningParser.parseDynamicBlock();
            break;
          case MessageChunkType.error:
            // TODO: Handle this case.
            throw UnimplementedError();
          case MessageChunkType.toolCall:
            //如果是前端来的工具调用，则直接加入工具调用列表
            nativeToolCalls.add(
              ToolCallChunk(
                id: id.id,
                isFinished: true,
                content: chunk.content,
              ),
            );
            break;
        }
        formatOutput();
      }

      // 本轮流式输出结束，将本轮的确定性分块合并到 accumulatedOutput
      List<ContentChunk> finalCurrentTurnChunks = [];
      finalCurrentTurnChunks.addAll(parser.blocksCached);
      finalCurrentTurnChunks.addAll(reasoningParser.blocksCached);
      // 注意：toolCalls 在 API原生类型中会加入到其中，但原生的如果已经在 output.value 需要怎么拿？
      // 因为我们是在 stream 里局部给 toolCalls.clear() 的，所以最后 toolCalls 可能是空的
      // 为了拿到本轮所有的工具调用（包括 xml 提取出来的），我们应该从 parser.blocksCached 中获取 ToolCallChunk。
      // 以及，对于原生的 MessageChunkType.toolCall，前面我们把它加到了 toolCalls 中，但是由于每次循环都会 clear()
      // 等等，我们在前面有一个 bug：`toolCalls.clear()` 会清空前端原生传来的工具调用。
      // 我们应该把他们保存下来，所以在 formatOutput 时可以用到一个持久化的 turnToolCalls 列表。

      var currentTurnAllChunks = output.value.sublist(accumulatedOutput.length);
      accumulatedOutput.addAll(currentTurnAllChunks);

      // 检查并在 stream 结束后触发全部 tool call
      List<ToolCallChunk> finalToolCalls = currentTurnAllChunks
          .whereType<ToolCallChunk>()
          .toList();
      for (var call in finalToolCalls) {
        if (call.future == null) {
          call.invoke(tools);
        }
      }

      // 等待所有工具调用执行完毕
      await Future.wait(finalToolCalls.map((c) => c.future!).toList());

      if (finalToolCalls.isEmpty) {
        // 如果本轮没有任何工具被调用，那么直接视为推理和回答完毕，跳出事件循环
        break;
      }

      // 注入本轮的结构化辅助响应
      var textBuffer = StringBuffer();
      var reasoningBufferResult = StringBuffer();
      List<ParsedToolCall> allParsedCalls = [];
      for (var chunk in currentTurnAllChunks) {
        if (chunk is TextChunk) {
          textBuffer.write(chunk.text);
        } else if (chunk is ReasoningChunk) {
          reasoningBufferResult.write(chunk.text);
        } else if (chunk is ToolCallChunk) {
          allParsedCalls.addAll(chunk.parsedCalls);
        }
      }
      injector.appendIntermediateTurn(
        AssistantTurn(
          text: textBuffer.toString(),
          reasoning: reasoningBufferResult.isNotEmpty
              ? reasoningBufferResult.toString()
              : null,
          toolCalls: allParsedCalls,
        ),
      );

      // 注入本轮的结构化工具执行结果
      injector.appendIntermediateTurn(
        ToolResultTurn(
          results: finalToolCalls.expand((c) => c.parsedCalls).toList(),
        ),
      );
    }

    return (chunks: accumulatedOutput, thoughtSignature: thoughtSignature);
  }
}
