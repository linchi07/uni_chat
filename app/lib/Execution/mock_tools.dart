import 'dart:math';
import 'package:uni_chat/Execution/execution_models.dart';

class MockWeatherTool extends BaseTool {
  @override
  String get name => "get_current_weather";

  @override
  String get description => "获取指定城市当前的天气情况。";

  @override
  Map<String, dynamic> get parameters => {
        "type": "object",
        "properties": {
          "location": {
            "type": "string",
            "description": "城市名称，例如：北京、上海",
          },
          "unit": {
            "type": "string",
            "enum": ["celsius", "fahrenheit"],
            "description": "温度单位",
          },
        },
        "required": ["location"],
      };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final location = args['location'];
    final unit = args['unit'] ?? 'celsius';
    
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));
    
    final temp = 15 + Random().nextInt(15);
    final conditions = ["晴朗", "多云", "小雨", "阴天"];
    final condition = conditions[Random().nextInt(conditions.length)];
    
    return "$location当前天气：$condition，温度：$temp°${unit == 'celsius' ? 'C' : 'F'}。";
  }
}

class MockCalculatorTool extends BaseTool {
  @override
  String get name => "calculator";

  @override
  String get description => "执行基本的数学运算（加、减、乘、除）。";

  @override
  Map<String, dynamic> get parameters => {
        "type": "object",
        "properties": {
          "expression": {
            "type": "string",
            "description": "数学表达式，例如：'123 + 456'，'10 * 5'，'100 / 4'",
          },
        },
        "required": ["expression"],
      };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final expression = args['expression'] as String;
    
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      // 简单实现：使用简单的字符串拆分和计算
      // 注意：这只是一个 mock 演示，实际生产中应使用 math_expressions 等库
      final parts = expression.split(RegExp(r'\s+'));
      if (parts.length != 3) {
        return "错误：不支持的表达式格式。请使用 '数字 运算符 数字'。";
      }
      
      final a = double.parse(parts[0]);
      final op = parts[1];
      final b = double.parse(parts[2]);
      
      double result;
      switch (op) {
        case '+': result = a + b; break;
        case '-': result = a - b; break;
        case '*': result = a * b; break;
        case '/': 
          if (b == 0) return "错误：除数不能为零。";
          result = a / b; 
          break;
        default: return "错误：不支持的运算符 '$op'。";
      }
      
      return "计算结果：$expression = $result";
    } catch (e) {
      return "计算错误：$e";
    }
  }
}
