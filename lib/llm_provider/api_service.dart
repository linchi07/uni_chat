import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:uni_chat/llm_provider/pre_built_models.dart';

import '../Chat/chat_models.dart';

enum ApiAbility { supportsFilesApi }

// 1. Abstract Base Class (Interface)
abstract class LLMApiService {
  abstract final Set<ApiAbility> abilities;
  abstract final Set<ModelAbility> modelAbilities;
  abstract final String apiKey;
  abstract final String endPoint;
  abstract final String modelName;
  Future<String?> fileUpload(File file, String mime);
  Stream<ChatResponse> getStreamingResponse(
    ModelRequestContent modelRequestContent,
  );
  Future<String> imageCreation(String prompt, (int, int)? size);
  Future<String> image2imageGeneration(String prompt, String base64Image);
  abstract final String providerName;
}

// 2. Concrete Implementation for OpenAI
class OpenAiApiService implements LLMApiService {
  OpenAiApiService({
    required this.apiKey,
    required this.endPoint,
    required this.abilities,
    required this.modelName,
    required this.providerName,
    required this.modelAbilities,
  });
  @override
  final String apiKey;
  @override
  final String endPoint;
  @override
  final String modelName;
  @override
  final String providerName;

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
  Stream<ChatResponse> getStreamingResponse(
    ModelRequestContent modelRequestContent,
  ) async* {
    final client = http.Client();
    final request = http.Request('POST', Uri.parse('$endPoint/v1/responses'));

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    });

    // 构建输入内容
    final List<Map<String, dynamic>> contents = [];
    toContent(modelRequestContent.staticSystemMessages, contents);
    toContent(modelRequestContent.chatHistory, contents);
    toContent(modelRequestContent.dynamicSystemMessages, contents);
    toContent(modelRequestContent.uiMessages, contents);
    toContent(modelRequestContent.usrMessage, contents);

    final requestBody = {
      'model': modelName,
      'input': contents,
      'stream': true,
      'temperature': modelRequestContent.modelSpecifics.temperature,
      'top_p': modelRequestContent.modelSpecifics.topP,
      'max_output_tokens':
          modelRequestContent.modelSpecifics.maxGenerationTokens,
    };

    request.body = jsonEncode(requestBody);

    try {
      final response = await client.send(request);
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
              try {
                final outputItems = json['output'] as List;
                final List<ChatResponse> responses = [];

                for (final item in outputItems) {
                  if (item['type'] == 'message' &&
                      item['content'] != null &&
                      item['content'] is List) {
                    final contentItems = item['content'] as List;
                    for (final contentItem in contentItems) {
                      if (contentItem['type'] == 'output_text' &&
                          contentItem['text'] != null) {
                        responses.add(
                          ChatResponse(
                            type: ResponseType.text,
                            content: contentItem['text'] as String,
                          ),
                        );
                      }
                    }
                  }
                }
                return responses;
              } catch (e) {
                // 忽略解析错误
                return <ChatResponse>[];
              }
            });
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception(
          'OpenAI API Error: ${response.statusCode} - $errorBody',
        );
      }
    } finally {
      client.close();
    }
  }

  @override
  Future<String?> fileUpload(File file, String mime) async {
    final client = http.Client();
    try {
      final uri = Uri.parse('$endPoint/files');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({'Authorization': 'Bearer $apiKey'});

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

      final response = await client.send(request);
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
      client.close();
    }
  }

  @override
  Future<String> imageCreation(String prompt, (int, int)? size) async {
    final client = http.Client();
    try {
      final uri = Uri.parse('$endPoint/images/generations');
      final request = http.Request('POST', uri);

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      });

      // 将尺寸转换为OpenAI API所需的格式
      String sizeString = '1024x1024'; // 默认尺寸
      if (size != null) {
        sizeString = '${size.$1}x${size.$2}';
      }

      final requestBody = {
        'model': modelName, // 使用DALL-E 3模型，更符合实际API
        'prompt': prompt,
        'n': 1,
        'size': sizeString,
        'response_format': 'b64_json', // 返回base64编码的图像数据
      };

      request.body = jsonEncode(requestBody);

      // 注意：由于方法签名返回String，这里需要同步处理
      // 在实际应用中，可能需要修改方法签名以支持异步操作
      final response = await client.send(request);
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
      client.close();
    }
  }

  @override
  Set<ApiAbility> abilities;

  @override
  Future<String> image2imageGeneration(
    String prompt,
    String base64Image,
  ) async {
    var uri = Uri.parse("$endPoint/images/edits");

    var request = http.MultipartRequest("POST", uri)
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..fields['model'] = modelName
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
  Set<ModelAbility> modelAbilities;
}

///适用于一些老的例如LMStudio这样的服务
class OpenAiCompletionService implements LLMApiService {
  OpenAiCompletionService({
    required this.apiKey,
    required this.endPoint,
    required this.modelName,
    required this.abilities,
    required this.modelAbilities,
    required this.providerName,
  });
  @override
  final String apiKey;
  @override
  final String endPoint;
  @override
  final String modelName;
  @override
  final Set<ApiAbility> abilities;
  @override
  final Set<ModelAbility> modelAbilities;
  @override
  final String providerName;

  @override
  Future<String?> fileUpload(File file, String mime) {
    throw UnimplementedError();
  }

  String getSender(MessageSender sender) {
    switch (sender) {
      case MessageSender.user:
        return 'user';
      case MessageSender.ai:
        return 'assistant';
      case MessageSender.system:
        return 'system';
    }
  }

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
        /*
        contents.add({
          'role': getSender(message.sender),
          'type': 'input_image',
          'content': "data:${message.mimeType};base64,${message.content}",
        });*/
      }
    }
  }

  @override
  Stream<ChatResponse> getStreamingResponse(
    ModelRequestContent modelRequestContent,
  ) async* {
    final client = http.Client();
    final request = http.Request(
      'POST',
      Uri.parse('$endPoint/v1/chat/completions'),
    );

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    });

    // 构建输入内容
    final List<Map<String, dynamic>> contents = [];
    toContent(modelRequestContent.staticSystemMessages, contents);
    toContent(modelRequestContent.chatHistory, contents);
    toContent(modelRequestContent.dynamicSystemMessages, contents);
    toContent(modelRequestContent.uiMessages, contents);
    toContent(modelRequestContent.usrMessage, contents);

    final requestBody = {
      'model': modelName,
      'messages': contents,
      'stream': true,
      'frequency_penalty': modelRequestContent.modelSpecifics.frequencyPenalty,
      'presence_penalty': modelRequestContent.modelSpecifics.presencePenalty,
      'temperature': modelRequestContent.modelSpecifics.temperature,
      'top_p': modelRequestContent.modelSpecifics.topP,
    };

    request.body = jsonEncode(requestBody);

    try {
      final response = await client.send(request);
      if (response.statusCode == 200) {
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
              try {
                final outputItems = json['choices'] as List;
                final List<ChatResponse> responses = [];

                for (final item in outputItems) {
                  // 修改解析逻辑以适配官方OpenAI API格式
                  if (item['delta'] != null &&
                      item['delta']['content'] != null) {
                    // 流式响应格式
                    responses.add(
                      ChatResponse(
                        type: ResponseType.text,
                        content: item['delta']['content'] as String,
                      ),
                    );
                  }
                }
                return responses;
              } catch (e) {
                // 忽略解析错误
                return <ChatResponse>[];
              }
            });
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception(
          'OpenAI Completion API Error: ${response.statusCode} - $errorBody',
        );
      }
    } finally {
      client.close();
    }
  }

  @override
  Future<String> imageCreation(String prompt, (int, int)? size) async {
    final client = http.Client();
    try {
      final uri = Uri.parse('$endPoint/images/generations');
      final request = http.Request('POST', uri);

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      });

      // 将尺寸转换为OpenAI API所需的格式
      String sizeString = '1024x1024'; // 默认尺寸
      if (size != null) {
        sizeString = '${size.$1}x${size.$2}';
      }

      final requestBody = {
        'model': modelName, // 使用DALL-E 3模型，更符合实际API
        'prompt': prompt,
        'n': 1,
        'size': sizeString,
        'response_format': 'b64_json', // 返回base64编码的图像数据
      };

      request.body = jsonEncode(requestBody);

      // 注意：由于方法签名返回String，这里需要同步处理
      // 在实际应用中，可能需要修改方法签名以支持异步操作
      final response = await client.send(request);
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
      client.close();
    }
  }

  @override
  Future<String> image2imageGeneration(
    String prompt,
    String base64Image,
  ) async {
    var uri = Uri.parse("$endPoint/images/edits");

    var request = http.MultipartRequest("POST", uri)
      ..headers['Authorization'] = 'Bearer $apiKey'
      ..fields['model'] = modelName
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
}

// 3. Concrete Implementation for Gemini
class GeminiApiService implements LLMApiService {
  GeminiApiService({
    required this.apiKey,
    required this.endPoint,
    required this.modelName,
    required this.abilities,
    required this.modelAbilities,
    required this.providerName,
  });
  @override
  final String providerName;
  @override
  final String apiKey;
  @override
  final String endPoint;
  @override
  final String modelName;

  String get _generateEndpoint {
    return '$endPoint/v1beta/models/$modelName';
  }

  String get _uploadEndpoint {
    //但愿谷歌不会再整出个v2出来，就属它家的api变得最多
    return '$endPoint/upload/v1beta/files';
  }

  @override
  Future<String?> fileUpload(File file, String mime) async {
    final client = http.Client();
    try {
      // 1. Start resumable upload session
      final startRequest = http.Request(
        'POST',
        Uri.parse('$_uploadEndpoint?key=$apiKey'),
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

      final startResponse = await client.send(startRequest);
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

      final uploadResponse = await client.send(uploadRequest);
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
      client.close();
    }
  }

  String getRole(MessageSender sender) {
    switch (sender) {
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

  @override
  Stream<ChatResponse> getStreamingResponse(
    ModelRequestContent modelRequestContent,
  ) async* {
    final client = http.Client();
    final uri = Uri.parse('$_generateEndpoint:streamGenerateContent?alt=sse');
    final request = http.Request('POST', uri);

    request.headers.addAll({
      'Content-Type': 'application/json',
      'x-goog-api-key': apiKey,
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
        "temperature": modelRequestContent.modelSpecifics.temperature,
        "topP": modelRequestContent.modelSpecifics.topP,
        "maxOutputTokens":
            modelRequestContent.modelSpecifics.maxGenerationTokens,
        //"frequencyPenalty": modelRequestContent.modelSpecifics.frequencyPenalty,
        //google的逆天操作，2.5系列是不支持的，但是tm的Api文档上是有这个设置选择的，劳资难道给你正则匹配到2.5就禁用吗？
        //它家的api一团糟，还有各种不支持，这下知道openai 的好了。
        //所以这里直接一刀切，google的模型全部忽略这个选择（当然现在应该大家用的都是2.5，所以基本上没啥大影响（本来就禁用））
      },
    });

    try {
      final response = await client.send(request);

      if (response.statusCode == 200) {
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
              try {
                final text =
                    json['candidates'][0]['content']['parts'][0]['text']
                        as String?;
                if (text != null) {
                  print(json.toString());
                  return [ChatResponse(type: ResponseType.text, content: text)];
                }
              } catch (e) {
                // Ignore parsing errors for this chunk
              }
              return <ChatResponse>[];
            });
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception(
          'Gemini API Error: ${response.statusCode} - $errorBody',
        );
      }
    } finally {
      client.close();
    }
  }

  @override
  Future<String> imageCreation(String prompt, (int, int)? size) async {
    final client = http.Client();
    try {
      final uri = Uri.parse('$_generateEndpoint:predict?key=$apiKey');
      final request = http.Request('POST', uri);

      request.headers.addAll({'Content-Type': 'application/json'});

      // 构建请求体
      final requestBody = {
        'instances': [
          {'prompt': prompt},
        ],
        'parameters': {
          'sampleCount': 1, // 默认生成1张图片
        },
      };

      request.body = jsonEncode(requestBody);

      final response = await client.send(request);
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        // 返回第一张图片的base64编码数据
        return jsonResponse['predictions'][0]['bytesBase64Encoded'] as String;
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception(
          'Image creation failed with status: ${response.statusCode} - $errorBody',
        );
      }
    } finally {
      client.close();
    }
  }

  @override
  Set<ApiAbility> abilities;

  @override
  Future<String> image2imageGeneration(
    String prompt,
    String base64Image,
  ) async {
    final client = http.Client();
    try {
      final uri = Uri.parse('$_generateEndpoint:predict?key=$apiKey');
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

      final response = await client.send(request);
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
      client.close();
    }
  }

  @override
  Set<ModelAbility> modelAbilities;
}

class StableDiffusion implements LLMApiService {
  StableDiffusion({
    required this.apiKey,
    required this.endPoint,
    required this.modelName,
    required this.abilities,
    required this.modelAbilities,
    required this.providerName,
  });
  @override
  final String apiKey;
  @override
  final String endPoint;
  @override
  final String modelName;
  @override
  final Set<ApiAbility> abilities;
  @override
  final String providerName;

  @override
  Future<String?> fileUpload(File file, String mime) {
    throw Exception("Not supported by this Provider");
  }

  @override
  Stream<ChatResponse> getStreamingResponse(ModelRequestContent request) {
    throw Exception("Not supported by this Provider");
  }

  @override
  Future<String> imageCreation(String prompt, (int, int)? size) async {
    final client = http.Client();
    try {
      final uri = Uri.parse('$endPoint/sdapi/v1/txt2img'); // 默认本地地址
      final request = http.Request('POST', uri);

      request.headers.addAll({'Content-Type': 'application/json'});

      // 设置默认尺寸或使用传入尺寸
      int width = 512;
      int height = 512;
      if (size != null) {
        width = size.$1;
        height = size.$2;
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

      final response = await client.send(request);
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
      client.close();
    }
  }

  @override
  Future<String> image2imageGeneration(
    String prompt,
    String base64Image,
  ) async {
    final client = http.Client();
    try {
      final uri = Uri.parse('$endPoint/sdapi/v1/img2img'); // 默认本地地址
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

      final response = await client.send(request);
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
      client.close();
    }
  }

  @override
  Set<ModelAbility> modelAbilities;
}
