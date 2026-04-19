import 'package:flutter/material.dart';
import 'package:uni_chat/l10n/generated/l10n.dart';

import '../api_configs/api_models.dart';

/// 映射模型或提供商名称到对应的图片资源路径
class LLMImageIndexer {
  /// 模型/提供商标识符到图片资源路径的映射
  static final Map<String, String> modelImageMap = {
    // OpenAI / ChatGPT models
    'openai': 'resources/provider_model_icons/chatgpt.jpeg',
    'gpt': 'resources/provider_model_icons/chatgpt.jpeg',
    'chatgpt': 'resources/provider_model_icons/chatgpt.jpeg',

    'google': 'resources/provider_model_icons/google.png',
    'gemini': 'resources/provider_model_icons/gemini.png',
    'vertexai': 'resources/provider_model_icons/vertexai.png',

    // Meta / Llama models
    'meta': 'resources/provider_model_icons/llama.png',
    'llama': 'resources/provider_model_icons/llama.png',
    'meta-llama': 'resources/provider_model_icons/llama.png',

    // Qwen / Alibaba
    'qwen': 'resources/provider_model_icons/qwen.png',
    '通义千问': 'resources/provider_model_icons/qwen.png',
    'dashscope': 'resources/provider_model_icons/dashscope.png',
    'bailian': 'resources/provider_model_icons/bailian.png',

    // DeepSeek
    'deepseek': 'resources/provider_model_icons/deepseek.png',

    // Claude / Anthropic
    'claude': 'resources/provider_model_icons/claude.png',
    'anthropic': 'resources/provider_model_icons/claude.png',

    // Mistral / Mixtral
    'mistral': 'resources/provider_model_icons/mistral.png',
    'mixtral': 'resources/provider_model_icons/mixtral.png',
    'mistralai': 'resources/provider_model_icons/mixtral.png',

    // Grok / xAI
    'grok': 'resources/provider_model_icons/grok.png',
    'x-ai': 'resources/provider_model_icons/grok.png',
    'xai': 'resources/provider_model_icons/grok.png',
    'gitee-ai': 'resources/provider_model_icons/gitee-ai.png',
    'giteeai': 'resources/provider_model_icons/gitee-ai.png',

    // Moonshot AI
    'moonshot': 'resources/provider_model_icons/moonshot.png',
    'moonshotai': 'resources/provider_model_icons/moonshot.png',
    'kimi': 'resources/provider_model_icons/moonshot.png',

    // Zhipu / ChatGLM
    'zhipu': 'resources/provider_model_icons/zhipu.png',
    'chatglm': 'resources/provider_model_icons/chatglm.png',
    '智谱': 'resources/provider_model_icons/zhipu.png',
    'z-ai': 'resources/provider_model_icons/zhipu.png',

    // Baidu / Wenxin
    'baidu': 'resources/provider_model_icons/wenxin.png',
    'wenxin': 'resources/provider_model_icons/wenxin.png',
    'qianfan': 'resources/provider_model_icons/wenxin.png',
    'baidu-cloud': 'resources/provider_model_icons/baidu-cloud.png',

    // Tencent / Hunyuan
    'hunyuan': 'resources/provider_model_icons/tencent-cloud-ti.png',
    'tencent': 'resources/provider_model_icons/tencent-cloud-ti.png',
    'tencent-cloud-ti': 'resources/provider_model_icons/tencent-cloud-ti.png',

    // Bytedance / Doubao / Volcengine
    'doubao': 'resources/provider_model_icons/doubao.png',
    'bytedance': 'resources/provider_model_icons/bytedance.png',
    'volcengine': 'resources/provider_model_icons/volcengine.png',

    // Other Chinese Providers
    'baichuan': 'resources/provider_model_icons/baichuan.png',
    'zero-one': 'resources/provider_model_icons/zero-one.png',
    ' LingYiWanWu': 'resources/provider_model_icons/zero-one.png',
    'step': 'resources/provider_model_icons/step.png',
    'stepfun': 'resources/provider_model_icons/step.png',
    'minimax': 'resources/provider_model_icons/minimax.png',
    'infini': 'resources/provider_model_icons/infini.png',
    'xirang': 'resources/provider_model_icons/xirang.png',
    'lanyun': 'resources/provider_model_icons/lanyun.png',
    'qiniu': 'resources/provider_model_icons/qiniu.webp',

    // Middleman / Aggregators
    'openrouter': 'resources/provider_model_icons/openrouter.png',
    'silicon': 'resources/provider_model_icons/silicon.png',
    'siliconflow': 'resources/provider_model_icons/silicon.png',
    'perplexity': 'resources/provider_model_icons/perplexity.png',
    'groq': 'resources/provider_model_icons/groq.png',
    'fireworks': 'resources/provider_model_icons/fireworks.png',
    'together': 'resources/provider_model_icons/together.png',
    'tokenflux': 'resources/provider_model_icons/tokenflux.png',
    'ppio': 'resources/provider_model_icons/ppio.png',
    'burncloud': 'resources/provider_model_icons/burncloud.png',

    // Technical / Infrastructure
    'github': 'resources/provider_model_icons/github.png',
    'microsoft': 'resources/provider_model_icons/microsoft.png',
    'azure': 'resources/provider_model_icons/microsoft.png',
    'aws': 'resources/provider_model_icons/aws-bedrock.webp',
    'aws-bedrock': 'resources/provider_model_icons/aws-bedrock.webp',
    'nvidia': 'resources/provider_model_icons/nvidia.png',
    'intel': 'resources/provider_model_icons/intel.png',
    'ovms': 'resources/provider_model_icons/intel.png',
    'huggingface': 'resources/provider_model_icons/huggingface.webp',
    'model-scope': 'resources/provider_model_icons/modelscope.png',
    'model_scope': 'resources/provider_model_icons/modelscope.png',
    'modelscope': 'resources/provider_model_icons/modelscope.png',

    // Local / Self-hosted
    'ollama': 'resources/provider_model_icons/ollama.png',
    'lmstudio': 'resources/provider_model_icons/lmstudio.png',
    'gpustack': 'resources/provider_model_icons/gpustack.png',

    // Specialized / Utilities
    'cohere': 'resources/provider_model_icons/cohere.png',
    'jina': 'resources/provider_model_icons/jina.png',
    'voyage': 'resources/provider_model_icons/voyageai.png',
    'voyageai': 'resources/provider_model_icons/voyageai.png',
    'mixedbread': 'resources/provider_model_icons/mixedbread.png',
    'nomic': 'resources/provider_model_icons/nomic.png',
    'tesseract': 'resources/provider_model_icons/Tesseract.js.png',
    'mcprouter': 'resources/provider_model_icons/mcprouter.webp',
    'vercel': 'resources/provider_model_icons/vercel.png',
    'gateway': 'resources/provider_model_icons/vercel.png',

    // Misc
    'cephalon': 'resources/provider_model_icons/cephalon.jpeg',
    'cerebras': 'resources/provider_model_icons/cerebras.webp',
    'hyperbolic': 'resources/provider_model_icons/hyperbolic.png',
    'lepton': 'resources/provider_model_icons/lepton.png',
    'longcat': 'resources/provider_model_icons/longcat.png',
    'mimo': 'resources/provider_model_icons/mimo.png',
    'newapi': 'resources/provider_model_icons/newapi.png',
    'new-api': 'resources/provider_model_icons/newapi.png',
    'o': 'resources/provider_model_icons/o3.png', // o3 -> o
    'ocoolai': 'resources/provider_model_icons/ocoolai.png',
    'ph': 'resources/provider_model_icons/ph8.png', // ph8 -> ph
    'sophnet': 'resources/provider_model_icons/sophnet.png',
    'zai': 'resources/provider_model_icons/zai.png',
    'graph-rag': 'resources/provider_model_icons/graph-rag.png',
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

extension XModelAlibity on ModelAbility {
  String name(BuildContext context) {
    switch (this) {
      case ModelAbility.textGenerate:
        return S.of(context).textGenerate;
      case ModelAbility.imageGenerate:
        return S.of(context).imageGenerate;
      case ModelAbility.image2imageGenerate:
        return S.of(context).image2imageGenerate;
      case ModelAbility.visual:
        return S.of(context).visual;
      case ModelAbility.file:
        return S.of(context).file;
      case ModelAbility.embedding:
        return S.of(context).embedding;
      case ModelAbility.audio:
        return S.of(context).audio;
      case ModelAbility.video:
        return S.of(context).video;
      case ModelAbility.toolCall:
        return S.of(context).toolCall;
      case ModelAbility.thinking:
        return S.of(context).thinking;
    }
  }

  Widget abilityIconWidget(IconData iconData, Color color) {
    return Icon(iconData, color: color);
  }

  IconData get abilityIcon {
    switch (this) {
      case ModelAbility.textGenerate:
        return Icons.text_snippet_outlined;
      case ModelAbility.imageGenerate:
        return Icons.color_lens_outlined;
      case ModelAbility.image2imageGenerate:
        return Icons.imagesearch_roller_outlined;
      case ModelAbility.file:
        return Icons.file_copy_outlined;
      case ModelAbility.visual:
        return Icons.image_outlined;
      case ModelAbility.embedding:
        return Icons.search;
      case ModelAbility.audio:
        return Icons.audiotrack_outlined;
      case ModelAbility.video:
        return Icons.video_camera_back_outlined;
      case ModelAbility.toolCall:
        return Icons.build_outlined;
      case ModelAbility.thinking:
        return Icons.psychology_outlined;
    }
  }

  String get simpleString {
    switch (this) {
      case ModelAbility.textGenerate:
        return 'text';
      case ModelAbility.imageGenerate:
        return 'imageGenerate';
      case ModelAbility.image2imageGenerate:
        return 'image2imageGenerate';
      case ModelAbility.file:
        return 'file';
      case ModelAbility.visual:
        return 'visual';
      case ModelAbility.embedding:
        return 'embedding';
      case ModelAbility.audio:
        return 'audio';
      case ModelAbility.video:
        return 'video';
      case ModelAbility.toolCall:
        return 'toolCall';
      case ModelAbility.thinking:
        return 'thinking';
    }
  }

  static String toDatabaseSet(Iterable<ModelAbility> abilities) {
    return abilities.map((e) => e.simpleString).join(',');
  }

  static Set<ModelAbility> fromList(List<dynamic> list) {
    Map<String, ModelAbility> map = {
      'text': ModelAbility.textGenerate,
      'imageGenerate': ModelAbility.imageGenerate,
      'image2imageGenerate': ModelAbility.image2imageGenerate,
      'file': ModelAbility.file,
      'visual': ModelAbility.visual,
      'embedding': ModelAbility.embedding,
      'audio': ModelAbility.audio,
      'video': ModelAbility.video,
      'toolCall': ModelAbility.toolCall,
      'thinking': ModelAbility.thinking,
    };
    Set<ModelAbility> abilities = {};
    for (var ability in list) {
      if (map.containsKey(ability as String)) {
        abilities.add(map[ability]!);
      }
    }
    return abilities;
  }

  //验证互斥的能力
  Set<ModelAbility> validate(Set<ModelAbility> abilities) {
    if (abilities.contains(ModelAbility.embedding)) {
      return {ModelAbility.embedding};
    }
    return abilities;
  }

  ///在勾选能力的时候验证互斥能力
  Set<ModelAbility> checkIfValid(
    Set<ModelAbility> abilities,
    ModelAbility ability,
  ) {
    if (ability == ModelAbility.embedding) {
      return {ModelAbility.embedding};
    } else if (abilities.contains(ModelAbility.embedding)) {
      abilities.remove(ModelAbility.embedding);
    }
    abilities.add(ability);
    return abilities;
  }
}
