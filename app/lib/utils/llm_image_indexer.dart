/// 映射模型或提供商名称到对应的图片资源路径
class LLMImageIndexer {
  /// 模型/提供商标识符到图片资源路径的映射
  static final Map<String, String> modelImageMap = {
    // OpenAI / ChatGPT models
    'openai': 'resources/provider_model_icons/chatgpt.jpeg',
    'gpt': 'resources/provider_model_icons/chatgpt.jpeg',

    'google': 'resources/provider_model_icons/google.png',
    'gemini': 'resources/provider_model_icons/gemini.png',

    // Meta / Llama models
    'meta': 'resources/provider_model_icons/llama.png',
    'llama': 'resources/provider_model_icons/llama.png',
    'meta-llama': 'resources/provider_model_icons/llama.png',

    // Qwen (通义千问)
    'qwen': 'resources/provider_model_icons/qwen.png',
    '通义千问': 'resources/provider_model_icons/qwen.png',

    // DeepSeek
    'deepseek': 'resources/provider_model_icons/deepseek.png',

    // LMStudio
    'lmstudio': 'resources/provider_model_icons/lmstudio.png',

    'z-ai': 'resources/provider_model_icons/chatglm.png',

    'x-ai': 'resources/provider_model_icons/grok.png',

    'mistralai': 'resources/provider_model_icons/mixtral.png',

    'moonshotai': 'resources/provider_model_icons/moonshot.png',

    "baidu": 'resources/provider_model_icons/wenxin.png',

    "nvidia": 'resources/provider_model_icons/nvidia.png',

    "perplexity": 'resources/provider_model_icons/perplexity.png',

    "microsoft": 'resources/provider_model_icons/microsoft.png',

    'minimax': 'resources/provider_model_icons/minimax.png',

    "openrouter": 'resources/provider_model_icons/openrouter.png',

    "ollama": 'resources/provider_model_icons/ollama.png',

    "silicon": 'resources/provider_model_icons/silicon.png',
  };

  static String? tryGetImagePath(String? identifier) {
    if (identifier == null) {
      return null;
    }
    identifier = identifier.trim();
    identifier = identifier.replaceAll(" ", "");
    identifier = identifier.toLowerCase(); // 正则表达式匹配所有数字和小数点
    RegExp regex = RegExp(r'[\d.]+');

    // 使用 replaceAll 删除所有匹配的部分
    identifier = identifier.replaceAll(regex, '');
    return modelImageMap[identifier];
  }

  /// 根据模型或提供商名称获取对应的图片资源路径
  static String getImagePath(String identifier) {
    identifier = identifier.trim();
    identifier = identifier.replaceAll(" ", "");
    identifier = identifier.toLowerCase(); // 正则表达式匹配所有数字和小数点
    RegExp regex = RegExp(r'[\d.]+');

    // 使用 replaceAll 删除所有匹配的部分
    identifier = identifier.replaceAll(regex, '');
    return modelImageMap[identifier] ?? 'resources/unknown.png';
  }
}
