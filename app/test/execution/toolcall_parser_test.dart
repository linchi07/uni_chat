import 'package:flutter_test/flutter_test.dart';
import 'package:uni_chat/Execution/execution_models.dart';
import 'package:uni_chat/Execution/toolcall_parser.dart';

void main() {
  group('ToolCallParser Unit Tests', () {
    test('Parse standard JSON tool call', () {
      const content = '{"name": "get_weather", "arguments": {"location": "London"}, "id": "call_123"}';
      final results = ToolCallParser.parse(content);
      
      expect(results.length, 1);
      expect(results[0].name, 'get_weather');
      expect(results[0].arguments['location'], 'London');
      expect(results[0].callId, 'call_123');
      expect(results[0].format, ToolCallFormat.json);
    });

    test('Parse JSON array of tool calls', () {
      const content = '[{"name": "tool1", "arguments": {}}, {"name": "tool2", "arguments": {"a": 1}}]';
      final results = ToolCallParser.parse(content);
      
      expect(results.length, 2);
      expect(results[0].name, 'tool1');
      expect(results[1].name, 'tool2');
      expect(results[1].arguments['a'], 1);
    });

    test('Parse Qwen-style XML tool call', () {
      const content = '<function=get_weather><parameter=location>London</parameter></function>';
      final results = ToolCallParser.parse(content);
      
      expect(results.length, 1);
      expect(results[0].name, 'get_weather');
      expect(results[0].arguments['location'], 'London');
      expect(results[0].format, ToolCallFormat.xml);
    });

    test('Parse mixed content with JSON', () {
      const content = 'Here is the tool call: {"name": "test", "arguments": {"x": true}} and some trailing text.';
      final results = ToolCallParser.parse(content);
      
      expect(results.length, 1);
      expect(results[0].name, 'test');
      expect(results[0].arguments['x'], true);
    });

    test('Parse GLM style tool call', () {
      const content = 'search_tool<arg_key>query</arg_key><arg_value>flutter tips</arg_value>';
      final results = ToolCallParser.parse(content);
      
      expect(results.length, 1);
      expect(results[0].name, 'search_tool');
      expect(results[0].arguments['query'], 'flutter tips');
      expect(results[0].format, ToolCallFormat.glm);
    });

    test('Handle broken tags or invalid JSON gracefully', () {
      const content = '<function=bad>...'; // Missing closing tags
      final results = ToolCallParser.parse(content);
      
      // Even if broken, our parser should try to recover the name if possible, 
      // or return empty if it's too broken.
      // Based on our implementation, results should be non-empty because of dotAll and optional closing.
      expect(results.isNotEmpty, true);
      expect(results[0].name, 'bad');
    });

    test('Parse OSS style (to=functions.xxx)', () {
      const content = 'to=functions.search_api\n<|message|>\n{"q": "uni_chat"}';
      final results = ToolCallParser.parse(content);
      
      expect(results.length, 1);
      expect(results[0].name, 'search_api');
      expect(results[0].arguments['q'], 'uni_chat');
      expect(results[0].format, ToolCallFormat.oss);
    });
  });
}
