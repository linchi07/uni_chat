import 'package:uni_chat/Execution/toolcall_parser.dart';
import 'package:uni_chat/Execution/tools_manager.dart';

enum ToolCallFormat { xml, json, glm, oss }

abstract class IntermediateTurn {}

class AssistantTurn extends IntermediateTurn {
  final String text;
  final String? reasoning;
  final List<ParsedToolCall> toolCalls;
  AssistantTurn({required this.text, this.reasoning, required this.toolCalls});
}

class ToolResultTurn extends IntermediateTurn {
  final List<ParsedToolCall> results;
  ToolResultTurn({required this.results});
}

abstract class ContentChunk {
  final int id;
  final bool isFinished;

  // 基类也建议改为命名参数，保持一致性
  ContentChunk({required this.id, required this.isFinished});
}

abstract class BaseTool {
  String get name;
  String get description;
  Map<String, dynamic> get parameters;
  Future<String> execute(Map<String, dynamic> args);

  Map<String, dynamic> toDefinition() {
    return {
      "type": "function",
      "function": {
        "name": name,
        "description": description,
        "parameters": parameters,
      }
    };
  }
}

class TextChunk extends ContentChunk {
  final String text;

  // 使用命名参数进行结构化初始化
  TextChunk({required super.id, required super.isFinished, required this.text});
}

class ReasoningChunk extends ContentChunk {
  final String text;

  // 使用命名参数进行结构化初始化
  ReasoningChunk({
    required super.id,
    required super.isFinished,
    required this.text,
  });
}

class ParsedToolCall {
  final String name;
  final Map<String, dynamic> arguments;
  final ToolCallFormat format;
  final String? callId;
  String? result;

  ParsedToolCall({
    required this.name,
    required this.arguments,
    required this.format,
    this.callId,
  });
}

class ToolCallChunk extends ContentChunk {
  final String content;
  List<ParsedToolCall>? _parsedCalls;
  Future<void>? future;

  List<ParsedToolCall> get parsedCalls {
    if (_parsedCalls == null) {
      if (isFinished) {
        _parsedCalls = ToolCallParser.parse(content);
      } else {
        return [];
      }
    }
    return _parsedCalls!;
  }

  void invoke(ToolsManager tools) {
     var calls = parsedCalls;
     future = Future.wait(calls.map((c) async {
        c.result = await tools.invokeTool(c);
     }));
  }

  Map<String, dynamic> toStructuredData() {
    return {
      "calls": parsedCalls.map((c) => {
        "name": c.name,
        "arguments": c.arguments,
        "callId": c.callId,
        "format": c.format.name,
      }).toList(),
      "results": parsedCalls.map((c) => {
        "name": c.name,
        "result": c.result,
        "callId": c.callId,
      }).toList(),
    };
  }

  // 使用命名参数进行结构化初始化
  ToolCallChunk({
    required super.id,
    required super.isFinished,
    required this.content,
  });
}

