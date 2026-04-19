import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_chat/Agent/agent_models.dart';
import 'package:uni_chat/Agent/prompt_injector.dart';
import 'package:uni_chat/Chat/chat_models.dart';
import 'package:uni_chat/Execution/execution_loop.dart';
import 'package:uni_chat/Execution/execution_models.dart';
import 'package:uni_chat/Execution/tools_manager.dart';
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/api_configs/api_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

// --- Mocks ---

class MockRef extends Fake implements Ref<Object?> {}
class MockAgentData extends Mock implements AgentData {}

class MockToolsManager extends ToolsManager {
  MockToolsManager();

  Map<String, dynamic> results = {};

  @override
  Future<String> invokeTool(ParsedToolCall call) async {
    final res = results[call.name] ?? 'default_result';
    return res.toString();
  }
}

class MockPromptInjector extends PromptInjector {
  MockPromptInjector() : super(
    ref: MockRef(), 
    agentData: AgentData(
      version: 1,
      id: 'test', 
      name: 'test', 
      modelConfigure: const ModelConfigure(modelId: 'test', providerId: 'test'),
      userIdentityConfigure: const PersonaConfigure(),
      createdAt: DateTime.now(),
    ), 
    history: []
  );

  int injectCount = 0;
  List<IntermediateTurn> capturedTurns = [];
  ModelRequestContent? nextRequest;

  @override
  Future<ModelRequestContent> inject() async {
    injectCount++;
    return nextRequest ?? ModelRequestContent(
      staticSystemMessages: [],
      dynamicSystemMessages: [],
      uiMessages: [],
      chatHistory: [],
      usrMessage: [],
      modelConfigure: const ModelConfigure(modelId: 'test', providerId: 'test'),
      ragMessages: [],
    );
  }

  @override
  void appendIntermediateTurn(IntermediateTurn turn) {
    capturedTurns.add(turn);
  }
}

class MockApiClient extends ApiClient {
  MockApiClient() : super(
    providerConfig: ProviderModelConfig(modelId: 'test', providerId: 'test', callName: 'test'),
    model: Model(id: 'test', family: "openai", friendlyName: 'test', abilities: {}, contextLength: 4096),
    provider: ApiProvider(id: 'test', name: 'test', type: ApiType.openaiChatCompletions, endpoint: 'test'),
  );

  List<Stream<ChatResponse>> responses = [];
  int callIndex = 0;

  @override
  Stream<ChatResponse> getStreamingResponse({
    required ModelRequestContent modelRequestContent,
    String? agentId,
  }) {
    if (callIndex < responses.length) {
      return responses[callIndex++];
    }
    return Stream.empty();
  }
}

void main() {
  group('ExecutionLoop Integration Tests', () {
    late MockPromptInjector injector;
    late MockApiClient client;
    late MockToolsManager tools;
    late ValueNotifier<List<ContentChunk>> output;

    setUp(() {
      injector = MockPromptInjector();
      client = MockApiClient();
      tools = MockToolsManager();
      output = ValueNotifier([]);
    });

    test('Single turn text response', () async {
      client.responses = [
        Stream.fromIterable([
          ChatResponse(type: MessageChunkType.text, content: 'Hello'),
          ChatResponse(type: MessageChunkType.text, content: ' world'),
        ]),
      ];

      final loop = ExecutionLoop(injector, client, output, tools: tools);
      final finalOutput = await loop.execute();

      expect(finalOutput.length, 1);
      expect(finalOutput[0], isA<TextChunk>());
      expect((finalOutput[0] as TextChunk).text, 'Hello world');
      expect(injector.injectCount, 1);
    });

    test('Two-turn tool call response', () async {
      // Turn 1: AI calls tool (Wrapped in <tool_call> for InputParser recognition)
      client.responses = [
        Stream.fromIterable([
          ChatResponse(type: MessageChunkType.text, content: 'Testing tool: <tool_call><function=get_val><parameter=key>test</parameter></function></tool_call>'),
        ]),
        // Turn 2: AI answers based on result
        Stream.fromIterable([
          ChatResponse(type: MessageChunkType.text, content: 'The value is 42'),
        ]),
      ];

      tools.results = {'get_val': 42};

      final loop = ExecutionLoop(injector, client, output, tools: tools);
      final finalOutput = await loop.execute();

      // Verify Turn 1 intermediate turns
      expect(injector.capturedTurns.length, 2);
      expect(injector.capturedTurns[0], isA<AssistantTurn>());
      expect((injector.capturedTurns[0] as AssistantTurn).toolCalls.length, 1);
      expect((injector.capturedTurns[0] as AssistantTurn).toolCalls[0].name, 'get_val');
      
      expect(injector.capturedTurns[1], isA<ToolResultTurn>());
      expect((injector.capturedTurns[1] as ToolResultTurn).results.length, 1);
      expect((injector.capturedTurns[1] as ToolResultTurn).results[0].result, '42');

      // Verify final output
      expect(finalOutput.any((c) => c is TextChunk && c.text.contains('The value is 42')), true);
      expect(injector.injectCount, 2);
    });

    test('Native Tool Call handling', () async {
       client.responses = [
        Stream.fromIterable([
          ChatResponse(
            type: MessageChunkType.toolCall, 
            content: '{"name": "native_tool", "arguments": {"x": 1}, "callId": "n1"}'
          ),
        ]),
        Stream.fromIterable([
          ChatResponse(type: MessageChunkType.text, content: 'OK'),
        ]),
      ];

      tools.results = {'native_tool': 'done'};

      final loop = ExecutionLoop(injector, client, output, tools: tools);
      await loop.execute();

      expect(injector.capturedTurns[0], isA<AssistantTurn>());
      final calls = (injector.capturedTurns[0] as AssistantTurn).toolCalls;
      expect(calls.length, 1);
      expect(calls[0].name, 'native_tool');
      expect(calls[0].callId, 'n1');
    });
  });
}
