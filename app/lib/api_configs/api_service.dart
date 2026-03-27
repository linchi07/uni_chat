import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show immutable;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:uni_chat/api_configs/api_database.dart';
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/error_handling.dart';

import '../Chat/chat_models.dart';
import '../utils/tokenizer.dart';
import 'api_key_resolver.dart';

class _ApiResponse {
  final ChatResponse? response;
  final InvokeResult? invokeResult;
  _ApiResponse({this.response, this.invokeResult});
}

@immutable
class InvokeResult {
  final int statusCode;
  final String? error;
  final TokenUsage? usage;

  const InvokeResult({required this.statusCode, this.error, this.usage});
}

typedef KeyInfo = ({GeneralApiKeyInvokeData invokeData, ApiKey key});

class ApiClient {
  late final BaseApiService service;
  final Model model;
  final ProviderModelConfig providerConfig;
  final ApiProvider provider;
  ApiClient({
    required this.providerConfig,
    required this.model,
    required this.provider,
  }) {
    switch (provider.type) {
      case ApiType.openaiResponses:
        service = OpenAiApiService();
        break;
      case ApiType.openaiChatCompletions:
        service = OpenAiCompletionService();
        break;
      case ApiType.google:
        service = GeminiApiService();
        break;
    }
  }

  static Future<ApiClient> fromProviderAndModel(
    ApiProvider provider,
    Model model,
  ) async {
    var pmc = await ApiDatabase.instance.getProviderModelConfig(
      provider.id,
      model.id,
    );
    if (pmc == null) {
      throw "The provider doesn't provide this model";
    }
    return ApiClient(providerConfig: pmc, model: model, provider: provider);
  }

  static Future<ApiClient> fromFactory(
    String providerId,
    String modelId,
  ) async {
    var provider = await ApiDatabase.instance.getProviderById(providerId);
    var model = await ApiDatabase.instance.getModelById(modelId);
    var providerConfig = await ApiDatabase.instance.getProviderModelConfig(
      providerId,
      modelId,
    );
    if (provider == null) {
      throw ApiException(ApiExceptionType.providerNotFound);
    }
    if (model == null) {
      throw ApiException(ApiExceptionType.modelNotFound);
    }
    if (providerConfig == null) {
      throw ApiException(ApiExceptionType.modelNotAvailableForProvider);
    }
    return ApiClient(
      providerConfig: providerConfig,
      model: model,
      provider: provider,
    );
  }

  Stream<ChatResponse> getStreamingResponse({
    required ModelRequestContent modelRequestContent,
    String? agentId,
  }) async* {
    while (true) {
      if (modelRequestContent.stopSignal?.isStopped ?? false) break;
      var keysCandidate = ApiDatabase.instance.getAvailableApiKeys(provider.id);
      var resolver = await BaseApiKeyResolver.getInstance(
        keysCandidate,
        apiProvider: provider,
      );
      if (modelRequestContent.stopSignal?.isStopped ?? false) break;
      var keyInfo = await resolver.resolveKey(model);
      if (modelRequestContent.stopSignal?.isStopped ?? false) break;
      var s = service.getStreamingResponse(
        this,
        keyInfo,
        modelRequestContent: modelRequestContent,
      );
      InvokeResult? invokeResult;
      StringBuffer fullResponse = StringBuffer();
      await for (final response in s) {
        if (response.response != null) {
          if (response.response!.type == MessageChunkType.text ||
              response.response!.type == MessageChunkType.reasoning) {
            fullResponse.write(response.response!.content);
          }
          yield response.response!;
        }
        invokeResult = response.invokeResult;
      }
      if (invokeResult != null) {
        // Calculate fallback usage if needed
        TokenUsage? fallback;
        if (invokeResult.usage == null && invokeResult.statusCode == 200) {
          int promptTokens = 0;
          // Estimate from all content types in modelRequestContent
          for (var m in modelRequestContent.staticSystemMessages) {
            promptTokens += m.tokens;
          }
          for (var m in modelRequestContent.dynamicSystemMessages) {
            promptTokens += m.tokens;
          }
          for (var m in modelRequestContent.uiMessages) {
            promptTokens += m.tokens;
          }
          for (var m in modelRequestContent.chatHistory) {
            promptTokens += m.tokens;
          }
          for (var m in modelRequestContent.ragMessages) {
            promptTokens += m.tokens;
          }
          for (var m in modelRequestContent.usrMessage) {
            promptTokens += m.tokens;
          }

          int completionTokens = LLMTokenEstimator.estimateTokens(
            fullResponse.toString(),
          );
          fallback = TokenUsage(
            promptTokens: promptTokens,
            completionTokens: completionTokens,
          );
        }

        await resolver.updateData(
          invokeResult,
          modelId: model.id,
          agentId: agentId,
          fallbackUsage: fallback,
        );
        if (invokeResult.statusCode == 200) break;
      } else {
        throw ApiException(ApiExceptionType.request_emptyBody);
      }
    }
  }

  Future<List<List<double>>> embedding({
    required List<String> input,
    required int dims,
  }) async {
    var key = await ApiDatabase.instance.getApiKeys("1");
    var s = service.embedding(this, key.first, input: input, dims: dims);
    return s;
  }

  Future<String> imageCreation({
    required String prompt,
    ({int width, int height})? size,
  }) async {
    var key = await ApiDatabase.instance.getApiKeys("1");
    return service.imageCreation(this, key.first, prompt: prompt, size: size);
  }

  Future<String> image2imageGeneration({
    required String prompt,
    required String base64Image,
  }) async {
    var key = await ApiDatabase.instance.getApiKeys("1");
    return service.image2imageGeneration(
      this,
      key.first,
      prompt: prompt,
      base64Image: base64Image,
    );
  }

  Future<String?> fileUpload({required File file, required String mime}) async {
    var key = await ApiDatabase.instance.getApiKeys("1");
    return service.fileUpload(this, key.first, file: file, mime: mime);
  }
}

abstract class BaseApiService {
  Future<String?> fileUpload(
    ApiClient client,
    ApiKey apiKey, {
    required File file,
    required String mime,
  }) => throw UnimplementedError();
  Stream<_ApiResponse> getStreamingResponse(
    ApiClient client,
    ApiKey apiKey, {
    required ModelRequestContent modelRequestContent,
  }) => throw UnimplementedError();
  Future<List<List<double>>> embedding(
    ApiClient client,
    ApiKey apiKey, {
    required List<String> input,
    required int dims,
  }) => throw UnimplementedError();
  Future<String> imageCreation(
    ApiClient client,
    ApiKey apiKey, {
    required String prompt,
    ({int width, int height})? size,
  }) => throw UnimplementedError();
  Future<String> image2imageGeneration(
    ApiClient client,
    ApiKey apiKey, {
    required String prompt,
    required String base64Image,
  }) => throw UnimplementedError();
}

class OpenAiApiService extends BaseApiService {
  void toContent(
    List<FormattedChatMessage> i,
    List<Map<String, dynamic>> contents,
  ) {
    for (final message in i) {
      if (message.type == ChatMessageType.text) {
        contents.add({'type': 'text', 'text': message.content});
      } else if (message.type == ChatMessageType.image) {
        contents.add({'type': 'input_image', 'file_id': message.content});
      } else if (message.type == ChatMessageType.pdf) {
        contents.add({'type': 'input_file', 'file_id': message.content});
      } else if (message.type == ChatMessageType.base64Image) {
        contents.add({
          'type': 'input_image',
          'image_url': "data:${message.mimeType};base64,${message.content}",
        });
      }
    }
  }

  @override
  Stream<_ApiResponse> getStreamingResponse(
    ApiClient client,
    ApiKey apiKey, {
    required ModelRequestContent modelRequestContent,
  }) async* {
    final httpClient = http.Client();
    final request = http.Request(
      'POST',
      Uri.parse('${client.provider.endpoint}/responses'),
    );

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${apiKey.key}',
    });

    // 构建输入内容
    final List<Map<String, dynamic>> contents = [];
    toContent(modelRequestContent.staticSystemMessages, contents);
    toContent(modelRequestContent.chatHistory, contents);
    toContent(modelRequestContent.dynamicSystemMessages, contents);
    toContent(modelRequestContent.uiMessages, contents);
    toContent(modelRequestContent.ragMessages, contents);
    toContent(modelRequestContent.usrMessage, contents);

    final requestBody = {
      'model': client.providerConfig.callName,
      'input': contents,
      'stream': true,
      //'temperature': modelRequestContent.modelConfigure.temperature,
      //'top_p': modelRequestContent.modelConfigure.topP,
      'max_output_tokens':
          modelRequestContent.modelConfigure.maxGenerationTokens,
    };

    request.body = jsonEncode(requestBody);

    if (modelRequestContent.stopSignal?.isStopped ?? false) {
      httpClient.close();
      return;
    }
    void onStop() {
      httpClient.close();
    }

    modelRequestContent.stopSignal?.addListener(onStop);

    try {
      final response = await httpClient.send(request);
      TokenUsage? usg;
      if (response.statusCode == 200) {
        yield* response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .where((line) => line.startsWith('data: '))
            .map((line) => line.substring(6))
            .where((data) => data != '[DONE]')
            .map((data) => jsonDecode(data))
            .where(
              (json) => json['output'] != null && json['output'].isNotEmpty,
            )
            .expand((json) {
              final List<_ApiResponse> responses = [];
              try {
                final outputItems = json['output'] as List;

                for (final item in outputItems) {
                  if (item['type'] == 'message' &&
                      item['content'] != null &&
                      item['content'] is List) {
                    final contentItems = item['content'] as List;
                    for (final contentItem in contentItems) {
                      if (contentItem['type'] == 'output_text' &&
                          contentItem['text'] != null) {
                        responses.add(
                          _ApiResponse(
                            response: ChatResponse(
                              type: MessageChunkType.text,
                              content: contentItem['text'] as String,
                            ),
                          ),
                        );
                      }
                    }
                  }
                }
                final usage = json['usage'] as Map<String, dynamic>?;
                if (usage != null) {
                  usg = TokenUsage(
                    promptTokens: usage['input_tokens'] as int? ?? 0,
                    cachedTokens:
                        usage['input_tokens_details']['cached_tokens']
                            as int? ??
                        0,
                    completionTokens: usage['output_tokens'] as int? ?? 0,
                    cotTokens:
                        usage['output_tokens_details']['reasoning_tokens']
                            as int? ??
                        0,
                  );
                }
              } catch (e) {
                print(e);
              }
              return responses;
            });
        yield _ApiResponse(
          invokeResult: InvokeResult(
            statusCode: response.statusCode,
            usage: usg,
          ),
        );
      } else {
        final errorBody = await response.stream.bytesToString();
        yield _ApiResponse(
          invokeResult: InvokeResult(
            statusCode: response.statusCode,
            error: errorBody,
          ),
        );
      }
    } finally {
      modelRequestContent.stopSignal?.removeListener(onStop);
      httpClient.close();
    }
  }

  @override
  Future<String?> fileUpload(
    ApiClient client,
    ApiKey apiKey, {
    required File file,
    required String mime,
  }) async {
    final httpClient = http.Client();
    try {
      final uri = Uri.parse('${client.provider.endpoint}/files');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({'Authorization': 'Bearer ${apiKey.key}'});

      // 添加文件
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
      );

      request.files.add(multipartFile);

      // 添加purpose字段
      request.fields['purpose'] = 'user_data';

      // 添加过期时间设置（48小时 = 172800秒）
      request.fields['expires_after'] = jsonEncode({
        'anchor': 'created_at',
        'seconds': 172800,
      });

      final response = await httpClient.send(request);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        return jsonResponse['id'] as String?;
      } else {
        // 上传失败，返回null
        return null;
      }
    } catch (e) {
      // 发生异常，返回null
      return null;
    } finally {
      httpClient.close();
    }
  }

  @override
  Future<String> imageCreation(
    ApiClient client,
    ApiKey apiKey, {
    required String prompt,
    ({int width, int height})? size,
  }) async {
    final httpClient = http.Client();
    try {
      final uri = Uri.parse('${client.provider.endpoint}/images/generations');
      final request = http.Request('POST', uri);

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${apiKey.key}',
      });

      // 将尺寸转换为OpenAI API所需的格式
      String sizeString = '1024x1024'; // 默认尺寸
      if (size != null) {
        sizeString = '${size.width}x${size.height}';
      }

      final requestBody = {
        'model': client.providerConfig.callName,
        'prompt': prompt,
        'n': 1,
        'size': sizeString,
        'response_format': 'b64_json', // 返回base64编码的图像数据
      };

      request.body = jsonEncode(requestBody);

      // 注意：由于方法签名返回String，这里需要同步处理
      // 在实际应用中，可能需要修改方法签名以支持异步操作
      final response = await httpClient.send(request);
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        // 返回base64编码的图像数据
        return jsonResponse['data'][0]['b64_json'] as String;
      } else {
        throw Exception(
          'Image creation failed with status: ${response.statusCode}',
        );
      }
    } finally {
      httpClient.close();
    }
  }

  @override
  Future<String> image2imageGeneration(
    ApiClient client,
    ApiKey apiKey, {
    required String prompt,
    required String base64Image,
  }) async {
    var uri = Uri.parse("${client.provider.endpoint}/images/edits");

    var request = http.MultipartRequest("POST", uri)
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..fields['model'] = client.providerConfig.callName
      ..fields['prompt'] = prompt;

    // 把每张 base64 图片转成 MultipartFile
    Uint8List bytes = base64Decode(base64Image);
    request.files.add(
      http.MultipartFile.fromBytes(
        'image[]', // 注意这里字段名必须是 image[]
        bytes,
        filename: 'image.png',
      ),
    );

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(responseBody);
      String b64Json = jsonResponse['data'][0]['b64_json'];
      return b64Json; // 返回 base64 图片字符串（调用方可 decode 保存为文件）
    } else {
      throw Exception("Failed: ${response.statusCode}, body: $responseBody");
    }
  }

  @override
  Future<List<List<double>>> embedding(
    ApiClient client,
    ApiKey apiKey, {
    required List<String> input,
    required int dims,
  }) async {
    final httpClient = http.Client();
    try {
      final uri = Uri.parse('${client.provider.endpoint}/v1/embeddings');
      final request = http.Request('POST', uri);

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      });

      final requestBody = {
        'model': client.providerConfig.callName,
        'input': input,
        'encoding_format': 'float',
        'dimensions': dims,
      };

      request.body = jsonEncode(requestBody);

      final response = await httpClient.send(request);
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        final List<List<double>> embeddings = [];
        final dataList = jsonResponse['data'] as List;

        for (var item in dataList) {
          final embedding = (item['embedding'] as List)
              .map((e) => (e as num).toDouble())
              .toList();
          embeddings.add(embedding);
        }

        return embeddings;
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception(
          'Embedding API Error: ${response.statusCode} - $errorBody',
        );
      }
    } finally {
      httpClient.close();
    }
  }
}

class OpenAiCompletionService extends OpenAiApiService {
  @override
  Future<String?> fileUpload(
    ApiClient client,
    ApiKey apiKey, {
    required File file,
    required String mime,
  }) {
    throw UnimplementedError();
  }

  String getSender(MessageSender sender) {
    switch (sender) {
      case MessageSender.internal:
        return 'internal';
      case MessageSender.user:
        return 'user';
      case MessageSender.ai:
        return 'assistant';
      case MessageSender.system:
        return 'system';
    }
  }

  @override
  void toContent(
    List<FormattedChatMessage> i,
    List<Map<String, dynamic>> contents,
  ) {
    for (final message in i) {
      if (message.type == ChatMessageType.text) {
        contents.add({
          'role': getSender(message.sender),
          'content': message.content,
        });
      } else if (message.type == ChatMessageType.image) {
        /*
        contents.add({
          'role': getSender(message.sender),
          'type': 'input_image',
          'content': message.content,
        });*/
        //这里我也不清楚，但是根据文档没有说可以上传图片
      } else if (message.type == ChatMessageType.pdf) {
        /*
        contents.add({
          'role': getSender(message.sender),
          'type': 'input_file',
          'content': message.content,
        });*/
      } else if (message.type == ChatMessageType.base64Image) {
        contents.add({
          'role': getSender(message.sender),
          'content': [
            {
              "type": "image_url",
              "image_url": {
                "url": "data:${message.mimeType};base64,${message.content}",
              },
            },
          ],
        });
      }
    }
  }

  @override
  Stream<_ApiResponse> getStreamingResponse(
    ApiClient client,
    ApiKey apiKey, {
    required ModelRequestContent modelRequestContent,
  }) async* {
    final httpClient = http.Client();
    final request = http.Request(
      'POST',
      Uri.parse('${client.provider.endpoint}/chat/completions'),
    );

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${apiKey.key}',
    });

    // 构建输入内容
    final List<Map<String, dynamic>> contents = [];
    toContent(modelRequestContent.staticSystemMessages, contents);
    toContent(modelRequestContent.chatHistory, contents);
    toContent(modelRequestContent.dynamicSystemMessages, contents);
    toContent(modelRequestContent.uiMessages, contents);
    toContent(modelRequestContent.ragMessages, contents);
    toContent(modelRequestContent.usrMessage, contents);

    final requestBody = {
      'model': client.providerConfig.callName,
      'messages': contents,
      'stream': true,
      //'frequency_penalty': modelRequestContent.modelConfigure.frequencyPenalty,
      //'presence_penalty': modelRequestContent.modelConfigure.presencePenalty,
      //'temperature': modelRequestContent.modelConfigure.temperature,
      //'top_p': modelRequestContent.modelConfigure.topP,
    };

    request.body = jsonEncode(requestBody);

    if (modelRequestContent.stopSignal?.isStopped ?? false) {
      httpClient.close();
      return;
    }
    void onStop() {
      httpClient.close();
    }

    modelRequestContent.stopSignal?.addListener(onStop);

    try {
      final response = await httpClient.send(request);
      if (response.statusCode == 200) {
        TokenUsage? usg;
        yield* response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .where((line) => line.startsWith('data: '))
            .map((line) => line.substring(6))
            .where((data) => data != '[DONE]')
            .map((data) => jsonDecode(data))
            .where(
              (json) => json['choices'] != null && json['choices'].isNotEmpty,
            )
            .expand((json) {
              final List<_ApiResponse> responses = [];
              try {
                final outputItems = json['choices'] as List;

                for (final item in outputItems) {
                  if (item['delta'] != null) {
                    if (item['delta']['reasoning_content'] != null) {
                      // 流式响应格式
                      responses.add(
                        _ApiResponse(
                          response: ChatResponse(
                            type: MessageChunkType.reasoning,
                            content:
                                item['delta']['reasoning_content'] as String,
                          ),
                        ),
                      );
                      print(item['delta']['reasoning_content']);
                    }
                    if (item['delta']['content'] != null) {
                      // 流式响应格式
                      responses.add(
                        _ApiResponse(
                          response: ChatResponse(
                            type: MessageChunkType.text,
                            content: item['delta']['content'] as String,
                          ),
                        ),
                      );
                    }
                  }
                }
                final usage = json['usage'] as Map<String, dynamic>?;
                if (usage != null) {
                  usg = TokenUsage(
                    promptTokens: usage['prompt_tokens'] as int? ?? 0,
                    completionTokens: usage['completion_tokens'] as int? ?? 0,
                    cachedTokens:
                        (usage['prompt_tokens_details']['cached_tokens']
                            as int?) ??
                        0,
                    cotTokens:
                        usage['completion_tokens_details']['reasoning_tokens']
                            as int? ??
                        0,
                  );
                }
              } catch (e) {
                print(e);
              }
              return responses;
            });
        yield _ApiResponse(
          invokeResult: InvokeResult(
            statusCode: response.statusCode,
            usage: usg,
          ),
        );
      } else {
        final errorBody = await response.stream.bytesToString();
        yield _ApiResponse(
          invokeResult: InvokeResult(
            statusCode: response.statusCode,
            error: errorBody,
          ),
        );
      }
    } finally {
      modelRequestContent.stopSignal?.removeListener(onStop);
      httpClient.close();
    }
  }
}

class GeminiApiService extends BaseApiService {
  @override
  Future<String?> fileUpload(
    ApiClient client,
    ApiKey apiKey, {
    required File file,
    required String mime,
  }) async {
    final httpClient = http.Client();
    try {
      // 1. Start resumable upload session
      final startRequest = http.Request(
        'POST',
        Uri.parse(
          '${client.provider.endpoint}/upload/v1beta.files?key=${apiKey.key}',
        ),
      );
      startRequest.headers.addAll({
        'X-Goog-Upload-Protocol': 'resumable',
        'X-Goog-Upload-Command': 'start',
        'X-Goog-Upload-Header-Content-Length': (await file.length()).toString(),
        'X-Goog-Upload-Header-Content-Type': mime,
        'Content-Type': 'application/json',
      });
      startRequest.body = jsonEncode({
        'file': {'display_name': p.basename(file.path)},
      });

      final startResponse = await httpClient.send(startRequest);
      final uploadUrl = startResponse.headers['x-goog-upload-url'];

      if (uploadUrl == null) {
        throw Exception(startResponse.toString()); // 上传URL获取失败，返回null
      }

      // 2. Upload the file bytes
      final uploadRequest = http.Request('PUT', Uri.parse(uploadUrl));
      uploadRequest.headers.addAll({
        'Content-Length': (await file.length()).toString(),
        'X-Goog-Upload-Offset': '0',
        'X-Goog-Upload-Command': 'upload, finalize',
      });
      uploadRequest.bodyBytes = await file.readAsBytes();

      final uploadResponse = await httpClient.send(uploadRequest);
      if (uploadResponse.statusCode != 200) {
        return null; // 上传失败，返回null
      }

      final responseString = await uploadResponse.stream.bytesToString();
      final jsonResponse = jsonDecode(responseString);
      final fileUri = jsonResponse['file']?['uri'];

      return fileUri; // 成功则返回fileUri，失败返回null
    } catch (e) {
      // 捕获异常并返回null
      return null;
    } finally {
      httpClient.close();
    }
  }

  String getRole(MessageSender sender) {
    switch (sender) {
      case MessageSender.internal:
        return 'internal';
      case MessageSender.user:
        return 'user';
      case MessageSender.ai:
        return 'model';
      case MessageSender.system:
        return 'system';
    }
  }

  void buildRequestBody(
    List<FormattedChatMessage> prompt,
    List<Map<String, dynamic>> contents,
  ) {
    for (final message in prompt) {
      if (message.type == ChatMessageType.text) {
        contents.add({
          'role': getRole(message.sender),
          'parts': [
            {'text': message.content},
          ],
        });
      } else if (message.type == ChatMessageType.image) {
        contents.add({
          'role': getRole(message.sender),
          'parts': [
            {
              'file_data': {
                'mime_type': message.mimeType!,
                "file_uri": message.content,
              },
            },
          ],
        });
      } else if (message.type == ChatMessageType.pdf) {
        contents.add({
          'role': getRole(message.sender),
          'parts': [
            {
              'file_data': {
                'mime_type': message.mimeType!,
                "file_uri": message.content,
              },
            },
          ],
        });
      } else if (message.type == ChatMessageType.base64Image) {
        contents.add({
          'role': getRole(message.sender),
          'parts': [
            {
              'inline_data': {
                'mime_type': message.mimeType!,
                "data": message.content,
              },
            },
          ],
        });
      }
    }
  }

  String getGenerateEndpoint(ApiClient client) {
    return '${client.provider.endpoint}/models/${client.providerConfig.callName}';
  }

  @override
  Stream<_ApiResponse> getStreamingResponse(
    ApiClient client,
    ApiKey apiKey, {
    required ModelRequestContent modelRequestContent,
  }) async* {
    final httpClient = http.Client();
    final uri = Uri.parse(
      '${getGenerateEndpoint(client)}:streamGenerateContent?alt=sse',
    );
    final request = http.Request('POST', uri);

    request.headers.addAll({
      'Content-Type': 'application/json',
      'x-goog-api-key': apiKey.key,
    });

    // 构建消息历史
    final List<Map<String, dynamic>> contents = [];
    buildRequestBody(modelRequestContent.chatHistory, contents);
    buildRequestBody(
      FormattedChatMessage.overrideIdentity(
        MessageSender.user,
        modelRequestContent.uiMessages,
      ),
      contents,
    );
    buildRequestBody(
      FormattedChatMessage.overrideIdentity(
        MessageSender.user,
        modelRequestContent.ragMessages,
      ),
      contents,
    );
    buildRequestBody(modelRequestContent.usrMessage, contents);

    final List<Map<String, dynamic>> sysMsg = [];
    List<FormattedChatMessage> formattedSysMsg = [
      ...modelRequestContent.staticSystemMessages,
      ...modelRequestContent.dynamicSystemMessages,
    ];

    for (final message in formattedSysMsg) {
      sysMsg.add({'text': message.content});
    }

    request.body = jsonEncode({
      'contents': contents,
      //Gemini的系统指令是独立的，而且必须在开头，可恶的谷歌这样做就是不让我命中cache是吧。
      "systemInstruction": {
        'role': "咕噜咕噜",
        'parts': sysMsg,
      }, //根据api文档，role这里填什么都行
      "generationConfig": {
        //"temperature": modelRequestContent.modelConfigure.temperature,
        //"topP": modelRequestContent.modelConfigure.topP,
        "maxOutputTokens":
            modelRequestContent.modelConfigure.maxGenerationTokens,
        //"frequencyPenalty": modelRequestContent.modelSpecifics.frequencyPenalty,
        //google的逆天操作，2.5系列是不支持的，但是tm的Api文档上是有这个设置选择的，劳资难道给你正则匹配到2.5就禁用吗？
        //它家的api一团糟，还有各种不支持，这下知道openai 的好了。
        //所以这里直接一刀切，google的模型全部忽略这个选择（当然现在应该大家用的都是2.5，所以基本上没啥大影响（本来就禁用））
      },
    });

    if (modelRequestContent.stopSignal?.isStopped ?? false) {
      httpClient.close();
      return;
    }
    void onStop() {
      httpClient.close();
    }

    modelRequestContent.stopSignal?.addListener(onStop);

    try {
      final response = await httpClient.send(request);

      if (response.statusCode == 200) {
        TokenUsage? usg;
        yield* response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .where((line) => line.startsWith('data: '))
            .map((line) => line.substring(6))
            .map((data) => jsonDecode(data))
            .where(
              (json) =>
                  json['candidates'] != null && json['candidates'].isNotEmpty,
            )
            .expand((json) {
              var r = <_ApiResponse>[];
              try {
                final text =
                    json['candidates'][0]['content']['parts'][0]['text']
                        as String?;
                if (text != null) {
                  r.add(
                    _ApiResponse(
                      response: ChatResponse(
                        type: MessageChunkType.text,
                        content: text,
                      ),
                    ),
                  );
                }
                final usage = json['usageMetadata'] as Map<String, dynamic>?;
                if (usage != null) {
                  usg = TokenUsage(
                    promptTokens: usage['promptTokenCount'] as int? ?? 0,
                    completionTokens: usage['candidateTokenCount'] as int? ?? 0,
                    cachedTokens: usage['cachedTokenCount'] as int? ?? 0,
                    cotTokens: usage['thoughtsTokenCount'] as int? ?? 0,
                    otherTokens: usage['toolUsePromptTokenCount'] as int? ?? 0,
                  );
                }
              } catch (e) {
                print(e);
              }
              return r;
            });
        yield _ApiResponse(
          invokeResult: InvokeResult(
            statusCode: response.statusCode,
            usage: usg,
          ),
        );
      } else {
        final errorBody = await response.stream.bytesToString();
        yield _ApiResponse(
          invokeResult: InvokeResult(
            statusCode: response.statusCode,
            error: errorBody,
          ),
        );
      }
    } finally {
      modelRequestContent.stopSignal?.removeListener(onStop);
      httpClient.close();
    }
  }

  @override
  Future<String> image2imageGeneration(
    ApiClient client,
    ApiKey apiKey, {
    required String prompt,
    required String base64Image,
  }) async {
    final httpClient = http.Client();
    try {
      final uri = Uri.parse(
        '${getGenerateEndpoint(client)}:predict?key=${apiKey.key}',
      );
      final request = http.Request('POST', uri);

      request.headers.addAll({'Content-Type': 'application/json'});

      // 构建请求体
      final requestBody = {
        'instances': [
          {
            'prompt': prompt,
            'image': {'bytesBase64Encoded': base64Image},
          },
        ],
        'parameters': {
          'sampleCount': 1, // 默认生成1张图片
        },
      };

      request.body = jsonEncode(requestBody);

      final response = await httpClient.send(request);
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        // 返回第一张图片的base64编码数据
        return jsonResponse['predictions'][0]['bytesBase64Encoded'] as String;
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception(
          'Image2Image creation failed with status: ${response.statusCode} - $errorBody',
        );
      }
    } finally {
      httpClient.close();
    }
  }

  @override
  Future<List<List<double>>> embedding(
    ApiClient client,
    ApiKey apiKey, {
    required List<String> input,
    required int dims,
  }) async {
    final httpClient = http.Client();
    try {
      // 如果只有一个输入，使用 embedContent 端点；如果有多个输入，使用 batchEmbedContents 端点
      final uri = input.length == 1
          ? Uri.parse(
              '${getGenerateEndpoint(client)}:embedContent?key=${apiKey.key}',
            )
          : Uri.parse(
              '${getGenerateEndpoint(client)}:batchEmbedContents?key=${apiKey.key}',
            );

      final request = http.Request('POST', uri);

      request.headers.addAll({
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey.key,
      });

      late final Map<String, dynamic> requestBody;

      if (input.length == 1) {
        // 单个文本嵌入
        requestBody = {
          'model': 'models/${client.providerConfig.callName}',
          "output_dimensionality": dims,
          'content': {
            'parts': [
              {'text': input[0]},
            ],
          },
        };
      } else {
        // 批量文本嵌入
        final requests = input.map((text) {
          return {
            'model': 'models/${client.providerConfig.callName}',
            "output_dimensionality": dims,
            'content': {
              'parts': [
                {'text': text},
              ],
            },
          };
        }).toList();

        requestBody = {'requests': requests};
      }

      request.body = jsonEncode(requestBody);

      final response = await httpClient.send(request);
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        final List<List<double>> embeddings = [];

        if (input.length == 1) {
          // 处理单个嵌入响应
          final embeddingValues = jsonResponse['embedding']['values'] as List;
          final embedding = embeddingValues
              .map((e) => (e as num).toDouble())
              .toList();
          embeddings.add(embedding);
        } else {
          // 处理批量嵌入响应
          final embeddingsData = jsonResponse['embeddings'] as List;
          for (var embeddingData in embeddingsData) {
            final embeddingValues = embeddingData['values'] as List;
            final embedding = embeddingValues
                .map((e) => (e as num).toDouble())
                .toList();
            embeddings.add(embedding);
          }
        }

        return embeddings;
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception(
          'Gemini Embedding API Error: ${response.statusCode} - $errorBody',
        );
      }
    } finally {
      httpClient.close();
    }
  }
}

class StableDiffusionApi extends BaseApiService {
  @override
  Future<String> imageCreation(
    ApiClient client,
    ApiKey apiKey, {
    required String prompt,
    ({int width, int height})? size,
  }) async {
    final httpClient = http.Client();
    try {
      final uri = Uri.parse(
        '${client.provider.endpoint}/sdapi/v1/txt2img',
      ); // 默认本地地址
      final request = http.Request('POST', uri);

      request.headers.addAll({'Content-Type': 'application/json'});

      // 设置默认尺寸或使用传入尺寸
      int width = 512;
      int height = 512;
      if (size != null) {
        width = size.width;
        height = size.height;
      }

      // 构建请求体，使用你提供的API参数结构
      final requestBody = {
        'prompt': prompt,
        'sampler_name': 'Euler a', // 使用一个常用的采样器
        'scheduler': 'normal',
        'batch_size': 1,
        'steps': 20, // 减少步数以提高速度
        'cfg_scale': 7,
        'width': width,
        'height': height,
      };

      request.body = jsonEncode(requestBody);

      final response = await httpClient.send(request);
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        // 返回第一张图片的base64编码数据
        final images = jsonResponse['images'] as List;
        if (images.isNotEmpty) {
          return images[0] as String;
        } else {
          throw Exception('No images returned from Stable Diffusion API');
        }
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception(
          'Image creation failed with status: ${response.statusCode} - $errorBody',
        );
      }
    } finally {
      httpClient.close();
    }
  }

  @override
  Future<String> image2imageGeneration(
    ApiClient client,
    ApiKey apiKey, {
    required String prompt,
    required String base64Image,
  }) async {
    final httpClient = http.Client();
    try {
      final uri = Uri.parse(
        '${client.provider.endpoint}/sdapi/v1/img2img',
      ); // 默认本地地址
      final request = http.Request('POST', uri);

      request.headers.addAll({'Content-Type': 'application/json'});

      // 构建请求体，使用你提供的API参数结构
      final requestBody = {
        'init_images': [base64Image],
        'prompt': prompt,
        'sampler_name': 'Euler a', // 使用一个常用的采样器
        'scheduler': 'normal',
        'batch_size': 1,
        'steps': 20, // 减少步数以提高速度
        'cfg_scale': 7,
      };

      request.body = jsonEncode(requestBody);

      final response = await httpClient.send(request);
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        // 返回第一张图片的base64编码数据
        final images = jsonResponse['images'] as List;
        if (images.isNotEmpty) {
          return images[0] as String;
        } else {
          throw Exception('No images returned from Stable Diffusion API');
        }
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception(
          'Image creation failed with status: ${response.statusCode} - $errorBody',
        );
      }
    } finally {
      httpClient.close();
    }
  }
}
