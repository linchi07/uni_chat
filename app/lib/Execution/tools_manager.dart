import 'package:uni_chat/Execution/execution_models.dart';

class ToolsManager {
  Future<String> invokeTool(ParsedToolCall call) async {
    // TODO: 实现真正的工具分发和执行
    await Future.delayed(const Duration(seconds: 1));
    return "Execute Success";
  }
}
