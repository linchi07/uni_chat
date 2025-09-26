import 'package:flutter/foundation.dart';

import '../utils/api_database_service.dart';
import 'api_service.dart';

class ApiServiceProvider {
  static final ApiServiceProvider _instance = ApiServiceProvider._internal();
  ApiServiceProvider._internal();

  static ApiServiceProvider get instance => _instance;

  /// 根据提供商-模型配置ID创建LLM API服务实例
  Future<LLMApiService?> createApiService(
    String providerModelConfigId,
  ) async {
    try {
      // 获取数据库实例
      final db = ApiDatabaseService.instance;

      // 获取提供商-模型配置信息
      final config = await db.getProviderModelConfig(providerModelConfigId);
      if (config == null || !config.isEnabled) {
        debugPrint('Config not found or disabled: $providerModelConfigId');
        return null;
      }

      // 获取提供商信息
      final provider = await db.getProvider(config.providerId);
      if (provider == null || !provider.isEnabled) {
        debugPrint('Provider not found or disabled: ${config.providerId}');
        return null;
      }

      // 获取模型信息
      final model = await db.getModel(config.modelId);
      if (model == null || !model.isEnabled) {
        debugPrint('Model not found or disabled: ${config.modelId}');
        return null;
      }

      // 获取该提供商的第一个启用的API密钥
      final apiKeys = await db.getApiKeysByProvider(provider.id);
      final enabledApiKey = apiKeys.firstWhere(
        (key) => key.isEnabled,
        orElse: () => throw Exception(
          'No enabled API key found for provider: ${provider.id}',
        ),
      );

      // 根据提供商类型创建相应的API服务实例
      switch (provider.type) {
        case 'openai':
          return OpenAiApiService(
            apiKey: enabledApiKey.keyValue,
            endPoint: provider.apiEndpoint,
            modelName: config.callName, // 使用配置中的callName
            abilities: config.abilities,
            providerName: provider.name,
          );
        case 'google':
          return GeminiApiService(
            apiKey: enabledApiKey.keyValue,
            endPoint: provider.apiEndpoint,
            modelName: config.callName, // 使用配置中的callName
            abilities: config.abilities,
            providerName: provider.name,
          );
        case 'sd': // Stable Diffusion
          return StableDiffusion(
            apiKey: enabledApiKey.keyValue,
            endPoint: provider.apiEndpoint,
            modelName: config.callName, // 使用配置中的callName
            abilities: config.abilities,
            providerName: provider.name,
          );
        default:
          debugPrint('Unsupported provider type: ${provider.type}');
          return null;
      }
    } catch (e) {
      debugPrint('Error creating API service: $e');
      return null;
    }
  }

  /// 根据模型ID获取模型信息
  Future<Model?> getModel(String modelId) async {
    final db = ApiDatabaseService.instance;
    return await db.getModel(modelId);
  }

  /// 根据提供商ID获取所有启用的模型
  Future<List<Model>> getEnabledModelsByProvider(String providerId) async {
    final db = ApiDatabaseService.instance;
    return await db.getEnabledModelsByProvider(providerId);
  }

  /// 获取所有提供商
  Future<List<ApiProvider>> getAllProviders() async {
    final db = ApiDatabaseService.instance;
    return await db.getAllProviders();
  }
}
