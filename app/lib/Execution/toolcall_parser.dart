import 'dart:convert';
import 'dart:math';

import 'package:uni_chat/Execution/execution_models.dart';

abstract class ToolCallParser {
  /// 统一解析入口，采用多重匹配和 try-catch 机制提升容错率
  static List<ParsedToolCall> parse(String text) {
    var content = text.trim();
    if (content.isEmpty) return [];

    // 1. 优先尝试 JSON 解析（如果看起来像 JSON）
    if (content.startsWith('{') || content.startsWith('[')) {
      try {
        var results = _parseJson(content);
        if (results.isNotEmpty) return results;
      } catch (_) {}
    }

    // 2. 尝试正则解析各种格式
    List<ParsedToolCall> results = [];

    // XML 格式 (如 <function=name> 或 <tool_call>)
    results.addAll(_parseXml(content));
    if (results.isNotEmpty) return results;

    // GLM 格式
    results.addAll(_parseGlm(content));
    if (results.isNotEmpty) return results;

    // OSS 格式 (to=functions.xxx)
    results.addAll(_parseOss(content));
    if (results.isNotEmpty) return results;

    // 最后保底再次全量匹配一次 JSON
    if (results.isEmpty) {
      results.addAll(_parseJson(content));
    }

    return results;
  }

  static List<ParsedToolCall> _parseJson(String content) {
    try {
      // 提取可能的 JSON 块
      var jsonRegex = RegExp(r'\{.*\}|\[.*\]', dotAll: true);
      var match = jsonRegex.firstMatch(content);
      if (match == null) return [];

      var data = jsonDecode(match.group(0)!);
      if (data is List) {
        return data.map((item) => ParsedToolCall(
              name: item['name'] ?? item['function']?['name'] ?? '',
              arguments: item['arguments'] ?? item['function']?['arguments'] ?? {},
              format: ToolCallFormat.json,
              callId: item['id'] ?? item['callId'],
            )).toList();
      } else if (data is Map) {
        return [
          ParsedToolCall(
            name: data['name'] ?? data['function']?['name'] ?? '',
            arguments: data['arguments'] ?? data['function']?['arguments'] ?? {},
            format: ToolCallFormat.json,
            callId: data['id'] ?? data['callId'],
          )
        ];
      }
    } catch (_) {}
    return [];
  }

  static List<ParsedToolCall> _parseXml(String content) {
    var results = <ParsedToolCall>[];

    // 变体 A: <function=name><parameter=k>v</parameter></function>
    var qwenFullRegex = RegExp(r'<function=([^>]+)>(.*?)(?:</function>|$)', dotAll: true);
    for (var fMatch in qwenFullRegex.allMatches(content)) {
      var name = fMatch.group(1)!.trim();
      var inner = fMatch.group(2)!;
      var paramRegex = RegExp(r'<parameter=([^>]+)>(.*?)(?:</parameter>|$)', dotAll: true);
      var args = <String, dynamic>{};
      for (var pMatch in paramRegex.allMatches(inner)) {
        args[pMatch.group(1)!.trim()] = pMatch.group(2)!.trim();
      }
      results.add(ParsedToolCall(name: name, arguments: args, format: ToolCallFormat.xml));
    }

    if (results.isNotEmpty) return results;

    // 变体 B: <tool_call> {"name": "...", "arguments": {...}} </tool_call>
    var toolCallRegex = RegExp(r'<tool_call>(.*?)</tool_call>', dotAll: true);
    for (var match in toolCallRegex.allMatches(content)) {
      var jsonStr = match.group(1)!.trim();
      try {
        var data = jsonDecode(jsonStr);
        results.add(ParsedToolCall(
          name: data['name'] ?? '',
          arguments: data['arguments'] ?? {},
          format: ToolCallFormat.xml,
        ));
      } catch (_) {}
    }

    return results;
  }

  static List<ParsedToolCall> _parseGlm(String content) {
    var results = <ParsedToolCall>[];
    if (content.contains('<arg_key>')) {
      var parts = content.split('<arg_key>');
      var name = parts[0].trim();
      var args = <String, dynamic>{};
      var keyRegex = RegExp(r'<arg_key>(.*?)</arg_key>', dotAll: true);
      var valRegex = RegExp(r'<arg_value>(.*?)</arg_value>', dotAll: true);
      
      var keys = keyRegex.allMatches(content).map((e) => e.group(1)!.trim()).toList();
      var vals = valRegex.allMatches(content).map((e) => e.group(1)!.trim()).toList();

      for (var i = 0; i < min(keys.length, vals.length); i++) {
        args[keys[i]] = vals[i];
      }
      results.add(ParsedToolCall(name: name, arguments: args, format: ToolCallFormat.glm));
    }
    return results;
  }

  static List<ParsedToolCall> _parseOss(String content) {
    var results = <ParsedToolCall>[];
    if (content.contains('to=')) {
      var ossRegex = RegExp(r'to=([^\s]+)\s*(?:<\|message\|>)?\s*(\{.*?\})', dotAll: true);
      var match = ossRegex.firstMatch(content);
      if (match != null) {
        try {
          var name = match.group(1)!.replaceFirst('functions.', '').trim();
          var args = jsonDecode(match.group(2)!);
          results.add(ParsedToolCall(name: name, arguments: args, format: ToolCallFormat.oss));
        } catch (_) {}
      }
    }
    return results;
  }

  static String formatCall(List<ParsedToolCall> calls, ToolCallFormat format) {
    if (calls.isEmpty) return "";
    StringBuffer sb = StringBuffer();
    switch (format) {
      case ToolCallFormat.xml:
        for (var call in calls) {
          sb.writeln("<function=${call.name}>");
          call.arguments.forEach((k, v) => sb.writeln("  <parameter=$k>$v</parameter>"));
          sb.writeln("</function>");
        }
        break;
      case ToolCallFormat.glm:
        for (var call in calls) {
          sb.write(call.name);
          call.arguments.forEach((k, v) => sb.write("<arg_key>$k</arg_key><arg_value>$v</arg_value>"));
        }
        break;
      case ToolCallFormat.oss:
        for (var call in calls) {
          sb.writeln("to=functions.${call.name}");
          sb.writeln("<|message|>");
          sb.writeln(jsonEncode(call.arguments));
        }
        break;
      case ToolCallFormat.json:
        for (var call in calls) {
          sb.writeln(jsonEncode({"name": call.name, "arguments": call.arguments}));
        }
        break;
    }
    return sb.toString().trim();
  }

  static String formatResult(ParsedToolCall call, ToolCallFormat format) {
    var res = call.result ?? "No output";
    switch (format) {
      case ToolCallFormat.xml: return "<result>\n$res\n</result>";
      case ToolCallFormat.glm: return "<observation>\n$res\n</observation>";
      default: return res;
    }
  }

  static ToolCallFormat getFormatForFamily(String family) {
    var f = family.toLowerCase();
    if (f.contains('glm')) return ToolCallFormat.glm;
    if (f.contains('qwen-3.5')) return ToolCallFormat.xml;
    if (f.contains('qwen')) return ToolCallFormat.json;
    if (f.contains('deepseek')) return ToolCallFormat.xml;
    if (f.contains('openai') || f.contains('gpt')) return ToolCallFormat.oss;
    return ToolCallFormat.xml;
  }
}
