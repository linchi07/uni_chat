import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:uni_chat/Agent/agentProvider.dart';
import 'package:uni_chat/Chat/chat_page_main.dart';
import 'package:uni_chat/Chat/inline_dynamic_fc_parser.dart';
import 'package:uni_chat/llm_provider/api_service.dart';
import 'package:uni_chat/utils/chunked_string_buffer.dart';
import 'package:uni_chat/utils/database_service.dart';
import 'package:uuid/uuid.dart';

import 'chat_models.dart';

const _uuid = Uuid();

// Enum to select the provider
enum ApiProvider { openai, gemini }

// --- State Definitions ---
class ChatState {
  ChatSession? session;
  final List<ChatMessage> messages;
  final Map<String, ChatFile> uploadedFiles;
  late final ChunkedStringBuffer newContentBuffer;
  late final ValueNotifier<bool> refreshFlag;
  final bool isLoading;
  final bool isResponding;
  final String? error;

  ChatState({
    ChatSession? session,
    this.uploadedFiles = const {},
    this.messages = const [],
    ChunkedStringBuffer? newContentBuffer,
    ValueNotifier<bool>? refreshFlag,
    this.isLoading = false,
    this.isResponding = false,
    this.error,
  }) {
    this.newContentBuffer = newContentBuffer ?? ChunkedStringBuffer();
    this.refreshFlag = refreshFlag ?? ValueNotifier(false);
    if (session != null) {
      this.session = session;
    }
  }

  ChatState copyWith({
    ChatSession? session,
    List<ChatMessage>? messages,
    Map<String, ChatFile>? uploadedFiles,
    ChunkedStringBuffer? newContentBuffer,
    ValueNotifier<bool>? refreshFlag,
    bool? isLoading,
    bool? isResponding,
    String? error,
  }) {
    return ChatState(
      session: session ?? this.session,
      messages: messages ?? this.messages,
      newContentBuffer: newContentBuffer ?? this.newContentBuffer,
      refreshFlag: refreshFlag ?? this.refreshFlag,
      uploadedFiles: uploadedFiles ?? this.uploadedFiles,
      isLoading: isLoading ?? this.isLoading,
      isResponding: isResponding ?? this.isResponding,
      error: error ?? this.error,
    );
  }

  ChatState clearSessionCopy() {
    return ChatState(
      session: null,
      messages: [],
      uploadedFiles: {},
      isLoading: false,
      error: null,
    );
  }
}

// --- State Notifier ---
class ChatStateNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  late AgentProvider agentNotifier;
  Agent? get agent => agentNotifier.state;

  // --- Database Integration ---
  final DatabaseService _dbService = DatabaseService.instance;
  String? get currentSessionId => state.session?.id;
  // --- End Database Integration ---

  ChatStateNotifier(this._ref) : super(ChatState(session: null)) {
    agentNotifier = _ref.read(agentProvider.notifier);
  }

  void stateCopyWith({
    ChatSession? session,
    List<ChatMessage>? messages,
    Map<String, ChatFile>? uploadedFiles,
    bool? isLoading,
    String? error,
  }) {
    state = ChatState(
      session: session ?? state.session,
      messages: messages ?? state.messages,
      uploadedFiles: uploadedFiles ?? state.uploadedFiles,
      isLoading: isLoading ?? state.isLoading,
      error: error ?? state.error,
    );
  }

  // --- Database Integration ---
  Future<void> init() async {
    /*
    var m = await ApiServiceProvider.instance.createApiService("0", "1");
    if (m == null) {
      throw Exception('No model found');
    }
    _ref.read(agentProvider.notifier).setAgent(Agent(id: "1", name: "asdf", model: m));*/
  }
  // --- End Database Integration ---

  // --- Public Session Management API ---

  void clearSession() {
    state = state.clearSessionCopy();
  }

  Future<void> createNewSession({String? agentId, String? title}) async {
    state = state.copyWith(isLoading: true);
    agentId ??= agent!.id;
    final session = await _dbService.createSession(
      agentId: agentId,
      title: title,
    );
    // After creating, switch to it to activate the agent and load everything
    await switchSession(session.id, fromNewSession: true);
  }

  Future<void> switchSession(
    String sessionId, {
    bool fromNewSession = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Get Session
      var session = await _dbService.getSession(sessionId);
      if (session == null) {
        throw Exception('Session not found');
      }

      await _ref.read(agentProvider.notifier).loadAgentById(session.agentId);

      // 6. Load messages and layout (existing logic)
      final (messages, files) = await _dbService.getMessagesForSession(
        sessionId,
      );
      if (fromNewSession) {
        //解释一下，由于我们现在的懒加载机制，在创建new session的时候此时state里面的数据不能清空并重加载，
        // 因为比如用户可能上传了一个文件（被保存在session中，此时清空session的话就导致文件没了）
        state = state.copyWith(session: session, isLoading: false);
      } else {
        state = state.copyWith(
          session: session,
          messages: messages,
          uploadedFiles: files,
          isLoading: false,
        );
      }
      var layout = await _dbService.readLayout(sessionId);
      if (layout != null) {
        _ref.read(panelManager).relayoutFromJson(layout);
      } else {
        _ref.read(panelManager).clear();
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteSession(String sessionId) async {
    await _dbService.deleteSession(sessionId);
    if (currentSessionId == sessionId) {
      clearSession();
    } else {
      state = state.copyWith();
    }
  }
  // --- End Public Session Management API ---

  Future<String?> triggerUploadFile(File file, String id, String name) async {
    if (agentNotifier.state == null) {
      return null;
    }
    // 获取文档目录并创建chat/session_files子目录
    if (ChatFile.textExtensions.contains(p.extension(file.path))) {
      state = state.copyWith(
        uploadedFiles: {
          ...state.uploadedFiles,
          id: ChatFile(
            name: id,
            original_name: name,
            uploadTime: DateTime.now(),
          ),
        },
      );
      return id;
    }
    String? r;
    if (ChatFile.imageExtensions.contains(p.extension(file.path)) &&
        agentNotifier.state!.abilities.contains(
          ApiAbility.visualUnderStanding,
        )) {
      if (agentNotifier.state!.abilities.contains(ApiAbility.supportFilesApi)) {
        r = await agentNotifier.fileUpload(
          file, // 使用拷贝后的文件
          ChatFile.getMimeType(p.extension(file.path)),
        );
        if (r == null) {
          return null;
        }
        state = state.copyWith(
          uploadedFiles: {
            ...state.uploadedFiles,
            id: ChatFile(
              name: id,
              providerInfo: {
                agentNotifier.state!.model.providerName: (
                  r,
                  DateTime.now().add(const Duration(hours: 47, minutes: 58)),
                ),
              },
              original_name: name,
              uploadTime: DateTime.now(), //其实是两天，但是我怕文件上传有延迟，所以缩短一点
            ),
          },
        );
      } else {
        state = state.copyWith(
          uploadedFiles: {
            ...state.uploadedFiles,
            id: ChatFile(
              name: id,
              original_name: name,
              uploadTime: DateTime.now(),
            ),
          },
        );
      }
    }
    return id;
  }

  Future<void> sendMessage(String text, {List<String>? attachedFiles}) async {
    if (state.session == null) {
      await createNewSession();
    }
    if (text.isEmpty && (attachedFiles == null || attachedFiles.isEmpty)) {
      return;
    }
    var history = state.messages;
    // 2. Add user message to list
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      sender: MessageSender.user,
      content: text,
      attachedFiles: attachedFiles, // 转换为附件文件对象列表
      timestamp: DateTime.now(),
    );
    // 3. Add placeholder for AI response
    state = state.copyWith(
      isLoading: true,
      error: null,
      messages: [...state.messages, userMessage],
    );
    //接下来构造发送的后端消息
    // --- Database Integration ---
    try {
      if (currentSessionId == null) {
        throw Exception('No session selected');
      }
      await _dbService.addMessage(
        currentSessionId!,
        userMessage,
        state.uploadedFiles,
      );
      var l = _ref.read(panelManager).saveToJson();
      if (l != null) {
        await _dbService.writeLayout(state.session!.id, l);
      }
    } catch (e) {
      print("Error saving user message to DB: $e");
      // Decide if we want to stop or continue if DB save fails. For now, continue.
    }
    // --- End Database Integration ---
    sendRequest(history, userMessage);
  }

  void sendRequest(List<ChatMessage> history, ChatMessage userMessage) async {
    // 4. Call the API and handle the stream
    try {
      var pm = _ref.read(panelManager);
      var dynamicUIQLParser = InlineDynamicParser(
        create: pm.create,
        update: pm.update,
        drop: pm.drop,
        bind: pm.bind,
        clear: pm.clear,
        select: pm.select,
      );
      final stream = agentNotifier.getStreamingResponse(
        history,
        userMessage,
        state.uploadedFiles,
      );
      ChatMessage? finalAiMessage;
      state = state.copyWith(isResponding: true);
      await for (final chunk in stream) {
        try {
          dynamicUIQLParser.parse(chunk.content);
        } catch (e) {
          dynamicUIQLParser.clear();
          print("p $e");
        }
        state.newContentBuffer.write(chunk.content);
        state.refreshFlag.value = !state.refreshFlag.value;
      }
      finalAiMessage = ChatMessage(
        id: Uuid().v4(),
        sender: MessageSender.ai,
        content: state.newContentBuffer.toString(),
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        isResponding: false,
        messages: [...state.messages, finalAiMessage],
      );
      state.newContentBuffer.clear();
      // --- Database Integration ---
      if (currentSessionId == null) {
        throw Exception('No session selected');
      }
      await _dbService.addMessage(
        currentSessionId!,
        finalAiMessage,
        state.uploadedFiles,
      );
      var l = _ref.read(panelManager).saveToJson();
      if (l != null) {
        await _dbService.writeLayout(state.session!.id, l);
      }
      // --- End Database Integration ---
    } catch (e) {
      state.newContentBuffer.write("<error>${e.toString()}</error>");
      state.refreshFlag.value = !state.refreshFlag.value;
    } finally {
      state = state.copyWith(isLoading: false, isResponding: false);
    }
  }
}

// The main StateNotifier provider
final chatStateProvider = StateNotifierProvider<ChatStateNotifier, ChatState>((
  ref,
) {
  final notifier = ChatStateNotifier(ref);
  // Initialize the session when the provider is first created
  notifier.init();
  return notifier;
});
