import 'package:flutter/material.dart';

import '../api_configs/api_models.dart';
import 'package:uni_chat/l10n/generated/l10n.dart';

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

    "model_scope": 'resources/provider_model_icons/modelscope.png',

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
