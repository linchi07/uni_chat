import 'package:flutter/foundation.dart';
import 'api_database.dart';
import 'api_models.dart';
import 'api_service.dart';
import 'model_matcher.dart';

class ModelDiscoveryService {
  final BaseApiService service;
  final String endpoint;
  final ApiKey apiKey;

  ModelDiscoveryService({
    required this.service,
    required this.endpoint,
    required this.apiKey,
  });

  /// 获取远程模型列表并与本地模型库进行匹配
  Future<List<ModelMatchResult>> discoverAndMatch() async {
    // 1. 从远程获取原始字符串列表
    List<String> remoteNames = await service.fetchAvailableModels(
      endpoint,
      apiKey,
    );

    // 2. 从本地数据库获取所有权威模型库数据
    List<Model> localModels = await ApiDatabase.instance.getAllModels();

    // 3. 执行匹配算法 (使用 compute 移至独立 Isolate)
    final results = await compute(_matchModelsIsolate, {
      'providerId': apiKey.providerId,
      'remoteNames': remoteNames,
      'localModels': localModels,
    });

    return results;
  }
}

// 顶层函数供 compute 调用
List<ModelMatchResult> _matchModelsIsolate(Map<String, dynamic> params) {
  final results = ModelMatcher.matchModels(
    params['providerId'] as String,
    params['remoteNames'] as List<String>,
    params['localModels'] as List<Model>,
  );

  // 排序逻辑也放在这里执行，减轻 UI 线程负担
  results.sort((a, b) {
    if (a.category != b.category) {
      return a.category.index.compareTo(b.category.index);
    }
    return b.similarity.compareTo(a.similarity);
  });

  return results;
}
