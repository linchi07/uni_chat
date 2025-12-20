import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uni_chat/Agent/agentProvider.dart';
import 'package:uni_chat/utils/tokenizer.dart';

class ChatSession {
  final String id;
  final String agentId; // 新增: 关联的Agent ID
  String name;
  DateTime lastMessageTime;
  final DateTime creationTime;

  ChatSession({
    required this.id,
    required this.agentId, // 新增
    required this.name,
    required this.lastMessageTime,
    required this.creationTime,
  });
}

enum MessageSender { internal, system, user, ai }

extension MessageSenderExtension on MessageSender {
  String get name {
    switch (this) {
      case MessageSender.internal:
        return 'internal';
      case MessageSender.system:
        return 'system';
      case MessageSender.user:
        return 'user';
      case MessageSender.ai:
        return 'ai';
    }
  }

  static MessageSender fromString(String name) {
    switch (name) {
      case 'internal':
        return MessageSender.internal;
      case 'system':
        return MessageSender.system;
      case 'user':
        return MessageSender.user;
      case 'ai':
        return MessageSender.ai;
      default:
        throw ArgumentError('Invalid MessageSender name: $name');
    }
  }
}

class ChatMessage {
  final String id;
  final String? messageId;
  //refers to the messageId of the database table.The ID of the "message"(not the relations)
  final String? parent;
  final List<String> childIds;
  int enabledChild; //当前启用的变体。注意：这里的是指的是children list的index
  final MessageSender sender;
  final String content; // a raw string
  final List<ChatFile>? attachedFiles; // 改为存储附件文件对象列表
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    this.messageId,
    required this.parent,
    required this.childIds,
    required this.sender,
    required this.content,
    this.attachedFiles,
    required this.timestamp,
    required this.enabledChild,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      messageId: map['message_id'],
      parent: map['parent'],
      childIds:
          (jsonDecode(map['child_ids']) as List<dynamic>?)?.cast<String>() ??
          [],
      sender: MessageSenderExtension.fromString(
        (map['sender'] as String?) ?? 'internal',
      ),
      content: map['content'] ?? '',
      attachedFiles: (map['attachedFiles'] as List<dynamic>?)
          ?.map((e) => ChatFile.fromMap(e))
          .toList(),
      timestamp: DateTime.fromMicrosecondsSinceEpoch(
        (map['timestamp'] as int?) ?? 0,
      ),
      enabledChild: map['enabled_child_index'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message_id': messageId,
      'parent': parent,
      'child_ids': jsonEncode(childIds),
      'sender': sender.toString(),
      'content': content,
      'attachedFiles': attachedFiles?.map((e) => e.toMap()).toList(),
      'timestamp': timestamp.microsecondsSinceEpoch,
      'enabledChild': enabledChild,
    };
  }
}

enum ChatMessageType { text, image, pdf, base64Image, base64pdf }

//file实际上只是pdf而已，因为所有文本类型的文件都会直接转换为提示词插入
class FormattedChatMessage {
  final String id;
  final MessageSender sender;
  final ChatMessageType type;
  final String content;
  final String? mimeType;

  FormattedChatMessage({
    required this.type,
    required this.id,
    this.mimeType,
    required this.sender,
    required this.content,
  });

  int get tokens {
    if (type == ChatMessageType.text) {
      return LLMTokenEstimator.estimateTokens(content);
    } else if (type == ChatMessageType.image) {
      return 200;
    } else if (type == ChatMessageType.pdf) {
      return 200;
    } else if (type == ChatMessageType.base64Image) {
      return 200;
    } else if (type == ChatMessageType.base64pdf) {
      return 200;
    } else {
      return 0;
    }
  }

  FormattedChatMessage copyWith({
    String? id,
    MessageSender? sender,
    ChatMessageType? type,
    String? content,
    String? mimeType,
  }) {
    return FormattedChatMessage(
      type: type ?? this.type,
      id: id ?? this.id,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  static FormattedChatMessage compressToOne(
    List<FormattedChatMessage> messages,
  ) {
    return FormattedChatMessage(
      type: ChatMessageType.text,
      id: messages[0].id,
      sender: messages[0].sender,
      content: messages.map((e) => e.content).join('\n'),
    );
  }

  static List<FormattedChatMessage> overrideIdentity(
    MessageSender sender,
    List<FormattedChatMessage> messages,
  ) {
    for (int i = 0; i < messages.length; i++) {
      messages[i] = messages[i].copyWith(sender: sender);
    }
    return messages;
  }
}

//本来我是不想要这个类的，但是，对于各家的模型，他的输入格式实在是差的太多了
//比如对于系统提示词，我个人为了最大化命中缓存，一般来讲，都是让不变的部分放最前，更改的部分放在后面（也就是仅次于用户消息的部分），这样，命中的概率很高
//但是Gemini他就必须要你只能第一个是系统提示词。所以为了针对差异化，我们只好储存更加完整的信息了
class ModelRequestContent {
  List<FormattedChatMessage> staticSystemMessages;
  List<FormattedChatMessage> dynamicSystemMessages;
  //某些模型不支持发送图片作为系统提示词，所以这时候实际上需要将其重写为用户提示词
  List<FormattedChatMessage> uiMessages;
  List<FormattedChatMessage> chatHistory;
  List<FormattedChatMessage> usrMessage;
  List<FormattedChatMessage> ragMessages;
  ModelSpecifics modelSpecifics;
  ModelRequestContent({
    required this.staticSystemMessages,
    required this.dynamicSystemMessages,
    required this.uiMessages,
    required this.chatHistory,
    required this.usrMessage,
    required this.modelSpecifics,
    required this.ragMessages,
  });
}

enum ResponseType { text, image, thinking, functionCalling, error }

class ChatResponse {
  final ResponseType type;
  final String content;
  final String? functionName;
  final String? functionArguments;
  final String? error;

  ChatResponse({
    required this.type,
    required this.content,
    this.functionName,
    this.functionArguments,
    this.error,
  });

  String toContentString() {
    switch (type) {
      case ResponseType.text:
        return content;
      case ResponseType.image:
        return '![Image]($content)';
      case ResponseType.thinking:
        return '▍';
      case ResponseType.functionCalling:
        return 'Function Calling: $functionName($functionArguments)';
      case ResponseType.error:
        return 'Error: $error';
    }
  }
}

// 文件类型枚举
enum FileTypeDefine { image, text, pdf, unknown }

class ChatFile {
  final String name;
  final String originalName;
  String get extension => p.extension(originalName);
  late final FileTypeDefine type;
  late final String mimeType;
  final DateTime uploadTime;

  ///第一个是文件ID，第二个是文件的上传时间
  late final Map<String, (String, DateTime)> providerInfo;
  File? _file;
  Future<File> getFile() async {
    if (_file != null) {
      return _file!;
    } else {
      _file = File(
        "${(await getApplicationDocumentsDirectory()).path}/chat/session_files/$name$extension",
      );
      return _file!;
    }
  }

  factory ChatFile.fromMap(Map<String, dynamic> map) {
    return ChatFile(
      name: map['name'],
      originalName: map['original_name'],
      uploadTime: DateTime.parse(map['uploadTime']),
      providerInfo: {
        for (var e in map['providerInfo'])
          e['provider']: (e['fileId'], DateTime.parse(e['uploadTime'])),
      },
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'original_name': originalName,
      'uploadTime': uploadTime.microsecondsSinceEpoch,
      'providerInfo': [
        for (var e in providerInfo.entries)
          {
            'provider': e.key,
            'fileId': e.value.$1,
            'uploadTime': e.value.$2.toIso8601String(),
          },
      ],
    };
  }

  ChatFile({
    required this.name,
    required this.originalName,
    required this.uploadTime,
    Map<String, (String, DateTime)>? providerInfo,
  }) {
    this.providerInfo = providerInfo ?? {};
    type = getFileType(extension);
    mimeType = getMimeType(extension); // 修改这里，使用专门的方法获取 MIME 类型
  }

  // 添加 copyWith 方法
  ChatFile copyWith({
    String? fileId,
    String? originalName,
    DateTime? uploadTime,
    Map<String, (String, DateTime)>? providerInfo,
    String? name,
  }) {
    return ChatFile(
      name: name ?? this.name,
      originalName: originalName ?? this.originalName,
      uploadTime: uploadTime ?? this.uploadTime,
      providerInfo: providerInfo ?? this.providerInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'originalName': originalName,
      'uploadTime': uploadTime.toIso8601String(),
      'providerInfo': [
        for (var e in providerInfo.entries)
          {
            'provider': e.key,
            'fileId': e.value.$1,
            'uploadTime': e.value.$2.toIso8601String(),
          },
      ],
    };
  }

  // 图片类型扩展名
  static const imageExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
    '.tiff',
    '.svg',
  };

  // 文本类型扩展名
  static const textExtensions = {
    '.txt',
    '.md',
    '.csv',
    '.json',
    '.xml',
    '.yaml',
    '.yml',
    '.log',
    '.html',
    '.css',
    '.js',
    '.dart',
  };

  // 根据扩展名判断文件类型的函数
  static FileTypeDefine getFileType(String? extension) {
    if (extension == null) {
      return FileTypeDefine.unknown;
    }

    if (imageExtensions.contains(extension)) {
      return FileTypeDefine.image;
    } else if (textExtensions.contains(extension)) {
      return FileTypeDefine.text;
    } else if (extension == '.pdf') {
      return FileTypeDefine.pdf;
    } else {
      return FileTypeDefine.unknown;
    }
  }

  // 新增：根据扩展名获取正确的 MIME 类型
  static String getMimeType(String? extension) {
    if (extension == null) {
      return 'application/octet-stream';
    }

    // 修复文本类型扩展名中的错误（'.css' 写成了 'css'）
    if (extension == 'css') {
      extension = '.css';
    }

    if (imageExtensions.contains(extension)) {
      // 移除扩展名前的点号
      return 'image/${extension.substring(1)}';
    } else if (textExtensions.contains(extension)) {
      if (extension == '.html') {
        return 'text/html';
      } else if (extension == '.css') {
        return 'text/css';
      } else if (extension == '.js') {
        return 'application/javascript';
      } else {
        return 'text/plain';
      }
    } else if (extension == '.pdf') {
      return 'application/pdf';
    } else {
      return 'application/octet-stream';
    }
  }
}
