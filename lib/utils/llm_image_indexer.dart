/// 映射模型或提供商名称到对应的图片资源路径
class LLMImageIndexer {
  /// 模型/提供商标识符到图片资源路径的映射
  static final Map<String, String> modelImageMap = {
    // OpenAI / ChatGPT models
    'openai': 'resources/provider_model_icons/chatgpt.jpeg',
    'gpt4': 'resources/provider_model_icons/chatgpt.jpeg',
    'gpt5': 'resources/provider_model_icons/chatgpt.jpeg',

    'google': 'resources/provider_model_icons/google.png',
    'gemini': 'resources/provider_model_icons/gemini.png',
    'gemini2.5': 'resources/provider_model_icons/gemini.png',

    // Meta / Llama models
    'meta': 'resources/provider_model_icons/llama.png',
    'llama': 'resources/provider_model_icons/llama.png',

    // Qwen (通义千问)
    'qwen': 'resources/provider_model_icons/qwen.png',
    'qwen3': 'resources/provider_model_icons/qwen.png',
    '通义千问': 'resources/provider_model_icons/qwen.png',

    // DeepSeek
    'deepseek': 'resources/provider_model_icons/deepseek.png',

    // LMStudio
    'lmstudio': 'resources/provider_model_icons/lmstudio.png',
  };

  /// 根据模型或提供商名称获取对应的图片资源路径
  static String getImagePath(String identifier) {
    identifier = identifier.trim();
    identifier = identifier.replaceAll(" ", "");
    identifier = identifier.toLowerCase();
    return modelImageMap[identifier] ?? 'resources/unknown.png';
  }
}
