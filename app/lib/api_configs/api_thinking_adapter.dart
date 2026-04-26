import 'api_models.dart';

/// 针对不同模型的思考模式（ThinkingMode）参数的适配层。
class ApiThinkingAdapter {
  /// 根据模型的 Family 及 API 类型，输出对应的思考模式控制字段载入请求体中。
  static Map<String, dynamic> getThinkingParams({
    required String family,
    required ThinkingMode mode,
    required ApiType apiType,
  }) {
    if (mode == ThinkingMode.defaultMode) {
      return {};
    }

    final familyLower = family.toLowerCase();

    // 针对特定家族的定制逻辑
    if (familyLower.contains('deepseek')) {
      return _getDeepSeekParams(mode);
    } else if (familyLower.contains('qwen')) {
      return _getQwenParams(mode);
    }

    // 默认的兜底映射逻辑
    if (apiType == ApiType.openaiResponses) {
      return _getOpenAiResponsesParams(mode);
    } else {
      return _getOpenAiCompletionsDefaultParams(mode);
    }
  }

  static Map<String, dynamic> _getDeepSeekParams(ThinkingMode mode) {
    if (mode == ThinkingMode.off) {
      return {
        'thinking': {'type': 'disabled'}
      };
    }

    String effort;
    switch (mode) {
      case ThinkingMode.low:
        effort = 'low';
        break;
      case ThinkingMode.mid:
        effort = 'medium';
        break;
      case ThinkingMode.high:
        effort = 'high';
        break;
      case ThinkingMode.xhigh:
        effort = 'max';
        break;
      default:
        effort = 'high';
    }

    return {
      'reasoning_effort': effort,
      'thinking': {'type': 'enabled'}
    };
  }

  static Map<String, dynamic> _getQwenParams(ThinkingMode mode) {
    if (mode == ThinkingMode.off) {
      return {'enable_thinking': false};
    }
    return {'enable_thinking': true};
  }

  static Map<String, dynamic> _getOpenAiResponsesParams(ThinkingMode mode) {
    String effort;
    switch (mode) {
      case ThinkingMode.off:
        effort = 'none';
        break;
      case ThinkingMode.low:
        effort = 'low';
        break;
      case ThinkingMode.mid:
        effort = 'medium';
        break;
      case ThinkingMode.high:
        effort = 'high';
        break;
      case ThinkingMode.xhigh:
        effort = 'xhigh';
        break;
      default:
        effort = 'medium';
    }
    return {
      'reasoning': {
        'effort': effort
      }
    };
  }

  static Map<String, dynamic> _getOpenAiCompletionsDefaultParams(ThinkingMode mode) {
    if (mode == ThinkingMode.off) {
      return {
        'enable_thinking': false,
        'reasoning_effort': 'low',
      };
    }

    String effort;
    switch (mode) {
      case ThinkingMode.low:
        effort = 'low';
        break;
      case ThinkingMode.mid:
        effort = 'medium';
        break;
      case ThinkingMode.high:
      case ThinkingMode.xhigh:
        effort = 'high';
        break;
      default:
        effort = 'medium';
    }
    return {
      'reasoning_effort': effort
    };
  }
}
