import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show ChangeNotifier, immutable;
import 'package:path/path.dart' as p;
import 'package:uni_chat/Agent/agent_models.dart';
import 'package:uni_chat/database/database_service.dart';
import 'package:uni_chat/utils/file_utils.dart';
import 'package:uni_chat/utils/tokenizer.dart';

import '../utils/paste_and_drop/src/file_semantic_map.g.dart' show EXT_INDEX;

class BranchInfoData {
  final String sessionId;
  final String messageId;

  BranchInfoData({required this.sessionId, required this.messageId});

  Map<String, dynamic> toMap() {
    return {'sessionId': sessionId, 'messageId': messageId};
  }

  factory BranchInfoData.fromMap(Map<String, dynamic> map) {
    return BranchInfoData(
      sessionId: map['sessionId'],
      messageId: map['messageId'],
    );
  }
}

class BranchInfo {
  final BranchInfoData? origin;
  final List<BranchInfoData> branches;

  BranchInfo({this.origin, List<BranchInfoData>? branches})
    : branches = branches ?? [];

  Map<String, dynamic> toMap() {
    return {
      if (origin != null) 'origin': origin!.toMap(),
      'branches': branches.map((e) => e.toMap()).toList(),
    };
  }

  factory BranchInfo.fromMap(Map<String, dynamic> map) {
    return BranchInfo(
      origin: map['origin'] != null
          ? BranchInfoData.fromMap(map['origin'])
          : null,
      branches:
          (map['branches'] as List<dynamic>?)
              ?.map((e) => BranchInfoData.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory BranchInfo.fromJsonString(String jsonStr) {
    if (jsonStr.isEmpty) return BranchInfo();
    return BranchInfo.fromMap(jsonDecode(jsonStr));
  }

  String toJsonString() {
    return jsonEncode(toMap());
  }
}

class ChatSession {
  final String id;
  final String agentId;
  final String? persona;
  String name;
  DateTime lastMessageTime;
  final DateTime creationTime;
  BranchInfo? branchInfo;
  final String? agentOverride;

  ChatSession({
    required this.id,
    required this.agentId,
    this.persona,
    required this.name,
    required this.lastMessageTime,
    required this.creationTime,
    this.branchInfo,
    this.agentOverride,
  });

  factory ChatSession.fromSessionDbModel(SessionDbModel dbModel) {
    return ChatSession(
      id: dbModel.id,
      agentId: dbModel.agentId!,
      persona: dbModel.personaId,
      name: dbModel.title,
      creationTime: dbModel.createdAt,
      lastMessageTime: dbModel.modifiedAt,
      branchInfo: dbModel.branchInfo != null
          ? BranchInfo.fromJsonString(dbModel.branchInfo!)
          : null,
      agentOverride: dbModel.agentOverride,
    );
  }
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
  final Map<String, dynamic>?
  data; // store other data from the chat (the data should be json serializable objects)
  int enabledChild; //当前启用的变体。注意：这里的是指的是children list的index
  final MessageSender sender;
  final String senderId;
  final String content; // a raw string
  final List<ChatFile>? attachedFiles; // 改为存储附件文件对象列表
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    this.messageId,
    required this.senderId,
    required this.parent,
    required this.childIds,
    required this.sender,
    required this.content,
    this.attachedFiles,
    this.data,
    required this.timestamp,
    required this.enabledChild,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    var at = map['attachments'];
    List<ChatFile>? attachments;
    if (at != null) {
      var dec = jsonDecode(at);
      if (dec.isNotEmpty) {
        attachments = [];
        for (var i in dec) {
          attachments.add(ChatFile.fromMap(i));
        }
      }
    }
    var data = map['data'];
    Map<String, dynamic>? decData;
    if (data != null) {
      decData = jsonDecode(data);
    }
    return ChatMessage(
      id: map['id'],
      messageId: map['message_id'],
      parent: map['parent_id'],
      childIds: (map['child_ids'] as String?)?.split(",") ?? [],
      sender: MessageSenderExtension.fromString(
        (map['sender'] as String?) ?? 'internal',
      ),
      data: decData,
      senderId: map['sender_id'] ?? "",
      attachedFiles: attachments,
      content: map['content'] ?? '',
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
      'child_ids': childIds.join(','),
      'sender': sender.toString(),
      'data': data,
      'sender_id': senderId,
      'content': content,
      'attachments': attachedFiles?.map((e) => e.toMap()).toList(),
      'timestamp': timestamp.microsecondsSinceEpoch,
      'enabledChild': enabledChild,
    };
  }

  /// returns a string that only presents the chat message's [sender] and [content]
  ///
  /// note that attachments will **not** be included in the string
  ///
  /// for a chat message with sender 'user' and content 'hello', the string will be
  /// ```
  /// 'user: hello'
  @override
  String toString() {
    return '$sender: $content';
  }
}

enum MessagePartType { text, image, pdf, base64Image, base64pdf, toolCall, toolResult, reasoning }

class MessagePart {
  final MessagePartType type;
  final String content;
  final String? mimeType;

  MessagePart({required this.type, required this.content, this.mimeType});

  int get tokens {
    switch (type) {
      case MessagePartType.text:
        return LLMTokenEstimator.estimateTokens(content);
      case MessagePartType.image:
      case MessagePartType.pdf:
      case MessagePartType.base64Image:
      case MessagePartType.base64pdf:
        return 200;
      case MessagePartType.toolCall:
      case MessagePartType.toolResult:
        return 50; // Estimated tokens for structured tool call/result
      case MessagePartType.reasoning:
        return LLMTokenEstimator.estimateTokens(content);
    }
  }

  Map<String, dynamic> toMap() {
    return {'type': type.index, 'content': content, 'mimeType': mimeType};
  }

  factory MessagePart.fromMap(Map<String, dynamic> map) {
    return MessagePart(
      type: MessagePartType.values[map['type']],
      content: map['content'],
      mimeType: map['mimeType'],
    );
  }
}

//file实际上只是pdf而已，因为所有文本类型的文件都会直接转换为提示词插入
class FormattedChatMessage {
  final String id;
  final MessageSender sender;
  final List<MessagePart> parts;
  final String? thoughtSignature;

  FormattedChatMessage({
    required this.id,
    required this.sender,
    required this.parts,
    this.thoughtSignature,
  });

  int get tokens {
    return parts.fold(0, (sum, part) => sum + part.tokens);
  }

  FormattedChatMessage copyWith({
    String? id,
    MessageSender? sender,
    List<MessagePart>? parts,
    String? thoughtSignature,
  }) {
    return FormattedChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      parts: parts ?? this.parts,
      thoughtSignature: thoughtSignature ?? this.thoughtSignature,
    );
  }

  static FormattedChatMessage compressToOne(
    List<FormattedChatMessage> messages,
  ) {
    return FormattedChatMessage(
      id: messages[0].id,
      sender: messages[0].sender,
      parts: [
        MessagePart(
          type: MessagePartType.text,
          content: messages
              .expand((m) => m.parts)
              .where((p) => p.type == MessagePartType.text)
              .map((p) => p.content)
              .join('\n'),
        ),
      ],
    );
  }

  static List<FormattedChatMessage> overrideIdentity(
    MessageSender sender,
    List<FormattedChatMessage> messages,
  ) {
    return messages.map((m) => m.copyWith(sender: sender)).toList();
  }
}

class StopSignal extends ChangeNotifier {
  bool _isStopped = false;
  bool get isStopped => _isStopped;
  void stop() {
    _isStopped = true;
    notifyListeners();
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
  List<Map<String, dynamic>>? tools;
  ModelConfigure modelConfigure;
  StopSignal? stopSignal;
  ModelRequestContent({
    required this.staticSystemMessages,
    required this.dynamicSystemMessages,
    required this.uiMessages,
    required this.chatHistory,
    required this.usrMessage,
    required this.modelConfigure,
    required this.ragMessages,
    this.tools,
    this.stopSignal,
  });
}

enum MessageChunkType { text, image, reasoning, error, toolCall }

extension XMessageChunkType on MessageChunkType {
  String get name {
    switch (this) {
      case MessageChunkType.text:
        return 'text';
      case MessageChunkType.image:
        return 'image';
      case MessageChunkType.reasoning:
        return 'reasoning';
      case MessageChunkType.error:
        return 'error';
      case MessageChunkType.toolCall:
        return 'toolCall';
    }
  }

  static MessageChunkType fromString(String name) {
    switch (name) {
      case 'text':
        return MessageChunkType.text;
      case 'image':
        return MessageChunkType.image;
      case 'reasoning':
        return MessageChunkType.reasoning;
      case 'toolCall':
        return MessageChunkType.toolCall;
      case 'error':
        return MessageChunkType.error;
      default:
        return MessageChunkType.text;
    }
  }
}

class ChatResponse {
  final MessageChunkType type;
  final String content;
  final String? thoughtSignature;

  ChatResponse({required this.type, required this.content, this.thoughtSignature});
}

@immutable
class MessageBlock {
  final String content;
  final int anchor;
  final MessageChunkType chunkType;
  final Map<String, dynamic>? toolData;

  const MessageBlock({
    required this.content,
    required this.anchor,
    required this.chunkType,
    this.toolData,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'anchor': anchor,
      'chunkType': chunkType.name,
      if (toolData != null) 'toolData': toolData,
    };
  }

  factory MessageBlock.fromMap(Map<String, dynamic> map) {
    return MessageBlock(
      content: map['content'] ?? "",
      anchor: map['anchor'] ?? -1,
      chunkType: XMessageChunkType.fromString(map['chunkType']),
      toolData: map['toolData'],
    );
  }

  static ({String mainContent, List<MessageBlock>? blocks}) fromChatResponse(
    List<ChatResponse> responses,
  ) {
    List<String> mainContent = [];
    var blocks = <MessageBlock>[];
    int pt = 0;
    for (var response in responses) {
      if (response.type == MessageChunkType.text) {
        mainContent.add(response.content);
        pt += response.content.length;
      } else {
        blocks.add(
          MessageBlock(
            content: response.content,
            anchor: pt,
            chunkType: response.type,
          ),
        );
      }
    }
    return (mainContent: mainContent.join(), blocks: blocks);
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
        await PathProvider.getPath("chat/session_files/$name$extension"),
      );
      return _file!;
    }
  }

  factory ChatFile.fromMap(Map<String, dynamic> map) {
    DateTime dt;
    //我自己的老文件无法解析了哈哈……
    try {
      dt = DateTime.fromMillisecondsSinceEpoch(map['uploadTime']);
    } catch (e) {
      dt = DateTime.parse(map['uploadTime']);
    }
    return ChatFile(
      name: map['name'],
      originalName: map['originalName'],
      uploadTime: dt,
      providerInfo: {
        for (var e in map['providerInfo'])
          e['provider']: (e['fileId'], DateTime.parse(e['uploadTime'])),
      },
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'originalName': originalName,
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
    extension = extension.toLowerCase();
    if (imageExtensions.contains(extension)) {
      return FileTypeDefine.image;
    } else if (extension == '.pdf') {
      return FileTypeDefine.pdf;
    } else if (textExtensions.contains(extension) ||
        EXT_INDEX.containsKey(extension.substring(1))) {
      //ignore the . of  extension
      return FileTypeDefine.text;
    } else {
      return FileTypeDefine.unknown;
    }
  }

  // 新增：根据扩展名获取正确的 MIME 类型
  static String getMimeType(String? extension) {
    if (extension == null) {
      return 'application/octet-stream';
    }

    extension = extension.toLowerCase();

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
