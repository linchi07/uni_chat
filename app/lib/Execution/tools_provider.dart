import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/Execution/tools_manager.dart';

/// 提供全局唯一的 ToolsManager 实例
final toolsManagerProvider = Provider<ToolsManager>((ref) {
  final manager = ToolsManager();
  /* 注册 Mock 工具用于测试
  manager.registerTool(MockWeatherTool());
  manager.registerTool(MockCalculatorTool());
  
   */
  return manager;
});
