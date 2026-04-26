import 'package:uni_chat/Execution/execution_models.dart';

class ToolsManager {
  final Map<String, BaseTool> _tools = {};

  void registerTool(BaseTool tool) {
    _tools[tool.name] = tool;
  }

  List<Map<String, dynamic>> getToolDefinitions() {
    return _tools.values.map((t) => t.toDefinition()).toList();
  }

  Future<String> invokeTool(ParsedToolCall call) async {
    final tool = _tools[call.name];
    if (tool != null) {
      try {
        return await tool.execute(call.arguments);
      } catch (e) {
        return "Error executing tool: $e";
      }
    }
    return "Error: Tool ${call.name} not found";
  }
}
