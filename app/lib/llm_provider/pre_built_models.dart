import 'package:flutter/material.dart';
import 'package:uni_chat/llm_provider/pre_build_providers.dart';

class PreBuiltModels {
  static Map<String, ModelsConfigData> models = {
    'gemini-2.5-flash': ModelsConfigData(
      callName: "gemini-2.5-flash",
      friendlyName: "Gemini 2.5 Flash",
      family: "gemini 2.5",
      abilities: {
        ModelAbility.textGenerate,
        ModelAbility.visualUnderStanding,
        ModelAbility.pdfUnderstanding,
      },
    ),
    'gemini-2.5-pro': ModelsConfigData(
      callName: "gemini-2.5-pro",
      friendlyName: "Gemini 2.5 Pro",
      family: "gemini 2.5",
      abilities: {
        ModelAbility.textGenerate,
        ModelAbility.visualUnderStanding,
        ModelAbility.pdfUnderstanding,
      },
    ),
    'gpt-4o': ModelsConfigData(
      callName: "gpt-4o",
      friendlyName: "GPT-4o",
      family: "gpt4",
      abilities: {
        ModelAbility.textGenerate,
        ModelAbility.visualUnderStanding,
        ModelAbility.pdfUnderstanding,
      },
    ),
    'gpt-5': ModelsConfigData(
      callName: "gpt-5",
      friendlyName: "GPT-5",
      family: "gpt5",
      abilities: {
        ModelAbility.textGenerate,
        ModelAbility.visualUnderStanding,
        ModelAbility.pdfUnderstanding,
      },
    ),
    'gpt-oss': ModelsConfigData(
      callName: "gpt-oss",
      friendlyName: "GPT-OSS",
      family: "gpt5",
      abilities: {
        ModelAbility.textGenerate,
        ModelAbility.visualUnderStanding,
        ModelAbility.pdfUnderstanding,
      },
    ),
    'deepseekR1': ModelsConfigData(
      callName: "deepseekR1",
      friendlyName: "DeepSeek R1",
      family: "deepseek",
      abilities: {ModelAbility.textGenerate},
    ),
    'deepseekV3': ModelsConfigData(
      callName: "deepseekV3",
      friendlyName: "DeepSeek V3",
      family: "deepseek",
      abilities: {ModelAbility.textGenerate},
    ),
    'deepseekV3.2': ModelsConfigData(
      callName: "deepseekV3.2",
      friendlyName: "DeepSeek V3.2",
      family: "deepseek",
      abilities: {ModelAbility.textGenerate},
    ),
    'qwen/qwen3-30b-a3b': ModelsConfigData(
      callName: "qwen/qwen3-30b-a3b",
      friendlyName: "Qwen33 30bB A3B",
      family: "qwen3",
      abilities: {ModelAbility.textGenerate, ModelAbility.visualUnderStanding},
    ),
    'qwen/qwen3-235b-a22b': ModelsConfigData(
      callName: "qwen/qwen3-235b-a22b-2507",
      friendlyName: "Qwen3 235B A22B",
      family: "qwen3",
      abilities: {ModelAbility.textGenerate, ModelAbility.visualUnderStanding},
    ),
    'qwen/qwen3-32b': ModelsConfigData(
      callName: "qwen/qwen3-32b",
      friendlyName: "Qwen3 32B",
      family: "qwen3",
      abilities: {ModelAbility.textGenerate},
    ),
    'qwen/qwen3-14b': ModelsConfigData(
      callName: "qwen/qwen3-14b",
      friendlyName: "Qwen3 14B",
      family: "qwen3",
      abilities: {ModelAbility.textGenerate},
    ),
    'qwen/qwen3-7b': ModelsConfigData(
      callName: "qwen/qwen3-7b",
      friendlyName: "Qwen3 7B",
      family: "qwen3",
      abilities: {ModelAbility.textGenerate},
    ),
    'text-embedding-qwen3-embedding-4b': ModelsConfigData(
      callName: "text-embedding-qwen3-embedding-4b",
      friendlyName: "Qwen3 4B Embedding",
      family: "qwen3",
      abilities: {ModelAbility.embedding},
    ),
    'gemini-embedding-001': ModelsConfigData(
      callName: "gemini-embedding-001",
      friendlyName: "Gemini Embedding 001",
      family: "gemini",
      abilities: {ModelAbility.embedding},
    ),
    'text-embedding-ada-002': ModelsConfigData(
      callName: "text-embedding-ada-002",
      friendlyName: "OpenAI Text Embedding Ada 002",
      family: "ada",
      abilities: {ModelAbility.embedding},
    ),
  };
}

enum ModelAbility {
  textGenerate,
  imageGenerate,
  image2imageGenerate,
  pdfUnderstanding,
  visualUnderStanding,
  embedding,
}

extension ApiAbilityExtension on ModelAbility {
  String get name {
    switch (this) {
      case ModelAbility.textGenerate:
        return '文本生成';
      case ModelAbility.imageGenerate:
        return '图像生成';
      case ModelAbility.image2imageGenerate:
        return '图像到图像生成';
      case ModelAbility.visualUnderStanding:
        return '视觉理解';
      case ModelAbility.pdfUnderstanding:
        return 'PDF理解';
      case ModelAbility.embedding:
        return '嵌入';
    }
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

  Widget get widget {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(name, style: TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
