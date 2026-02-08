import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:uni_chat/Agent/agentProvider.dart';
import 'package:uni_chat/Chat/chat_page.dart';
import 'package:uni_chat/Persona/persona_provider.dart';
import 'package:uni_chat/error_handling.dart';
import 'package:uni_chat/promps.dart';
import 'package:uni_chat/utils/chunked_string_buffer.dart';
import 'package:uni_chat/utils/database_service.dart';
import 'package:uuid/uuid.dart';

import '../api_configs/api_models.dart';
import 'chat_models.dart';

const _uuid = Uuid();

// --- State Definitions ---
class ChatState {
  bool isReady;
  AppException? error;
  ChatSession? session;
  final Map<String, ChatMessage> messages;
  final List<ChatMessage> messagesList;
  late Map<String, ({UploadStatus status, ChatFile file})> uploadedFilesStash;
  // 临时存储上传的文件，当用户点击发送按钮的时候会被合并到messages里面
  late final ChunkedStringBuffer newContentBuffer;
  late final ValueNotifier<bool> refreshFlag;
  final bool isLoading;
  final bool isResponding;

  ChatState({
    this.isReady = false,
    ChatSession? session,
    this.messages = const {},
    this.messagesList = const [],
    Map<String, ({UploadStatus status, ChatFile file})>? uploadedFilesStash,
    ChunkedStringBuffer? newContentBuffer,
    ValueNotifier<bool>? refreshFlag,
    this.isLoading = false,
    this.isResponding = false,
    this.error,
  }) {
    this.uploadedFilesStash = uploadedFilesStash ?? {};
    this.newContentBuffer = newContentBuffer ?? ChunkedStringBuffer();
    this.refreshFlag = refreshFlag ?? ValueNotifier(false);
    if (session != null) {
      this.session = session;
    }
  }

  ChatState copyWith({
    bool? isReady,
    ChatSession? session,
    Map<String, ChatMessage>? messages,
    List<ChatMessage>? messagesList,
    List<ChatMessage>? roots,
    Map<String, ({UploadStatus status, ChatFile file})>? uploadedFilesStash,
    ChunkedStringBuffer? newContentBuffer,
    ValueNotifier<bool>? refreshFlag,
    bool? isLoading,
    bool? isResponding,
    AppException? error,
  }) {
    return ChatState(
      isReady: isReady ?? this.isReady,
      session: session ?? this.session,
      messages: messages ?? this.messages,
      messagesList: messagesList ?? this.messagesList,
      uploadedFilesStash: uploadedFilesStash ?? this.uploadedFilesStash,
      newContentBuffer: newContentBuffer ?? this.newContentBuffer,
      refreshFlag: refreshFlag ?? this.refreshFlag,
      isLoading: isLoading ?? this.isLoading,
      isResponding: isResponding ?? this.isResponding,
      error: error ?? this.error,
    );
  }

  ChatState clearSessionCopy() {
    return ChatState(
      isReady: isReady,
      session: null,
      messages: {},
      messagesList: [],
      uploadedFilesStash: {},
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
    _ref.listen(agentProvider, (p, n) {
      if (p != n) {
        // auto refresh when the agent is ready
        checkIfReady();
      }
    });
  }

  void stateCopyWith({
    bool? isReady,
    ChatSession? session,
    Map<String, ChatMessage>? messages,
    List<ChatMessage>? messagesList,
    List<ChatMessage>? roots,
    Map<String, ({UploadStatus status, ChatFile file})>? uploadedFilesStash,
    bool? isLoading,
    AppException? error,
  }) {
    state = ChatState(
      isReady: isReady ?? state.isReady,
      session: session ?? state.session,
      messages: messages ?? state.messages,
      uploadedFilesStash: uploadedFilesStash ?? state.uploadedFilesStash,
      messagesList: messagesList ?? state.messagesList,
      isLoading: isLoading ?? state.isLoading,
      error: error ?? state.error,
    );
  }

  /// 重新执行树搜索方法来构建聊天树
  /// 在每次切换对话变体或者加载对话的时候都应该进行
  /// @param from 从哪里开始，如果是新加载，应该传入root。否则的话从更改节点来。
  List<ChatMessage> formMessageTree(
    ChatMessage from,
    Map<String, ChatMessage> messages,
  ) {
    List<ChatMessage> msg = [from];
    var current = from;
    do {
      var child = messages[current.childIds[current.enabledChild]];
      if (child == null) {
        break;
      }
      msg.add(child);
      current = child;
    } while (current.childIds.isNotEmpty);
    return msg;
  }

  Future<void> switchBranch(int startingPointIndex, int branchIndex) async {
    if (startingPointIndex >= state.messagesList.length) {
      return;
    }
    var sl = state.messagesList.sublist(0, startingPointIndex);
    var current = sl.last;
    current.enabledChild = branchIndex;
    var r = _dbService.updateActiveIndex(current.id, branchIndex);
    do {
      var child = state.messages[current.childIds[current.enabledChild]];
      if (child == null) {
        break;
      }
      sl.add(child);
      current = child;
    } while (current.childIds.isNotEmpty);
    state = state.copyWith(messagesList: sl);
    await r;
  }

  // --- Public Session Management API ---

  void clearSession() {
    state = state.clearSessionCopy();
  }

  /// check if chat session can be started
  ///
  /// when the input box is clicked or typed or the page is rebuild,this method should be called to enable the chat
  void checkIfReady() {
    if (state.isReady) return;
    if (agent != null) {
      state = state.copyWith(isReady: true, error: null);
    }
  }

  Future<void> createNewSession({String? agentId, String? title}) async {
    state = state.copyWith(isLoading: true);
    agentId ??= agent!.id;
    String? pid = _ref.read(personaProvider).id;
    if (!(pid.isNotEmpty && pid != "")) {
      pid = null;
      //如果是默认人格（id = “ ”），就不储存消息
    }
    final session = await _dbService.createSession(
      agentId: agentId,
      title: title,
      personaId: pid,
    );
    // After creating, switch to it to activate the agent and load everything
    await switchSession(session.id, fromNewSession: session);
  }

  Future<void> switchSession(
    String sessionId, {
    ChatSession? fromNewSession,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (fromNewSession != null) {
        await _ref
            .read(agentProvider.notifier)
            .loadAgentById(fromNewSession.agentId);
        //construct the root message
        var root = ChatMessage(
          id: sessionId,
          parent: null,
          childIds: [],
          sender: MessageSender.internal,
          content: '',
          timestamp: DateTime.now(),
          enabledChild: 0,
        );
        //解释一下，由于我们现在的懒加载机制，在创建new session的时候此时state里面的数据不能清空并重加载，
        // 因为比如用户可能上传了一个文件（被保存在stash中，此时new一个state的话就导致文件没了）
        state = state.copyWith(
          isReady: agent != null,
          session: fromNewSession,
          messages: {root.id: root},
          messagesList: [root],
          isLoading: false,
        );
      } else {
        // 1. Get Session
        var session = await _dbService.getSession(sessionId);
        if (session == null) {
          throw ChatException(ChatExceptionType.sessionNotFound);
        }
        //TODO: 最好让这里的逻辑都放到agent_provider里面
        await _ref.read(agentProvider.notifier).loadAgentById(session.agentId);
        final msg = await _dbService.getMessagesForSession(sessionId);
        if (msg.root == null || msg.messages.isEmpty) {
          throw ChatException(ChatExceptionType.messageNotFound);
        }
        // if the session has a persona, load it
        if (session.persona != null) {
          // if the persona is not valid(eg deleted), this function will do nothing.(with out errors or side effects)
          await _ref
              .read(personaProvider.notifier)
              .loadPersonaById(session.persona!);
        }
        var formed = formMessageTree(msg.root!, msg.messages);
        state = state.copyWith(
          isReady: agent != null,
          session: session,
          messages: msg.messages,
          messagesList: formed,
          isLoading: false,
        );
      }
      /*
      //有了新的XML layout engine 旧的就被作废了
      var layout = await _dbService.readLayout(sessionId);
      if (layout != null) {
        _ref.read(panelManager).relayoutFromJson(layout);
      } else {
        _ref.read(panelManager).clear();
      }
       */
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        isReady: false,
        error: (e is AppException) ? e : ChatException.fromException(e),
      );
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

  Future<void> triggerUploadFile(
    File file,
    String id,
    String name,
    bool isText,
  ) async {
    if (agentNotifier.state == null) {
      return;
    }
    if (isText) {
      state.uploadedFilesStash[id] = (
        file: ChatFile(
          name: id,
          originalName: name,
          uploadTime: DateTime.now(),
        ),
        status: UploadStatus.uploaded,
      );
      state = state.copyWith();
      return;
    }
    String? r;
    state.uploadedFilesStash[id] = (
      file: ChatFile(name: id, originalName: name, uploadTime: DateTime.now()),
      status: UploadStatus.uploading,
    );
    state = state.copyWith(isLoading: true);
    if (ChatFile.imageExtensions.contains(
          p.extension(file.path).toLowerCase(),
        ) &&
        agentNotifier.state!.client.model.abilities.contains(
          ModelAbility.visual,
        )) {
      if ( /*agentNotifier.state!.abilities.contains(
        ApiAbility.supportsFilesApi,
      )*/ false) {
        // 暂时关闭
        r = await agentNotifier.fileUpload(
          file, // 使用拷贝后的文件
          ChatFile.getMimeType(p.extension(file.path)),
        );
        if (r == null) {
          state.uploadedFilesStash[id] = (
            file: ChatFile(
              name: id,
              originalName: name,
              uploadTime: DateTime.now(),
            ),
            status: UploadStatus.failed,
          );
          state = state.copyWith();
          return;
        }
        state.uploadedFilesStash[id] = (
          file: ChatFile(
            name: id,
            providerInfo: {
              agentNotifier.state!.client.provider.id: (
                r,
                DateTime.now().add(const Duration(hours: 47, minutes: 58)),
              ),
            },
            originalName: name,
            uploadTime: DateTime.now(), //其实是两天，但是我怕文件上传有延迟，所以缩短一点
          ),
          status: UploadStatus.uploaded,
        );
        state = state.copyWith(isLoading: false);
      } else {
        state.uploadedFilesStash[id] = (
          file: ChatFile(
            name: id,
            originalName: name,
            uploadTime: DateTime.now(),
          ),
          status: UploadStatus.uploaded,
        );
        state = state.copyWith(isLoading: false);
        return;
      }
    }
    state.uploadedFilesStash[id] = (
      file: ChatFile(name: id, originalName: name, uploadTime: DateTime.now()),
      status: UploadStatus.failed,
    );
    state = state.copyWith(isLoading: false);
    return;
  }

  /// add a branch to the chat
  ///
  /// actually this only **creates** one branch.
  /// messages have to be added using [sendRequest] etc ,or the branch won't be saved
  void addBranch(int indexInHistory) {
    var msgList = state.messagesList;
    if (!state.isReady ||
        state.session == null ||
        msgList.isEmpty ||
        indexInHistory >= msgList.length) {
      return;
    }
    //the first message is the 1 not 0 (zero is the root message)
    var sl = msgList.sublist(0, indexInHistory);
    state = state.copyWith(messagesList: sl);
  }

  void regenerateMessage(int indexInHistory) {
    var msgList = state.messagesList;
    if (!state.isReady ||
        state.session == null ||
        msgList.isEmpty ||
        indexInHistory >= msgList.length) {
      return;
    }
    //the first message is the 1 not 0 (zero is the root message)
    var input = msgList[max(1, indexInHistory - 1)];
    var sl = msgList.sublist(0, indexInHistory);
    state = state.copyWith(messagesList: sl, isLoading: true);
    sendRequest(sl, input);
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty && state.uploadedFilesStash.isEmpty) {
      return;
    }
    if (state.session == null) {
      await createNewSession(title: 'New Chat');
    }
    var history = state.messagesList;
    var attach = <ChatFile>[];
    for (var v in state.uploadedFilesStash.values) {
      if (v.status == UploadStatus.uploaded) {
        attach.add(
          ChatFile(
            name: v.file.name,
            originalName: v.file.originalName,
            uploadTime: v.file.uploadTime,
            providerInfo: v.file.providerInfo,
          ),
        );
      }
    }
    // 2. Add user message to list
    final userMessage = ChatMessage(
      id: _uuid.v7(),
      messageId: _uuid.v7(),
      sender: MessageSender.user,
      content: text,
      attachedFiles: attach, // 转换为附件文件对象列表
      timestamp: DateTime.now(),
      parent: history.lastOrNull?.id,
      childIds: [],
      enabledChild: 0,
    );
    var hc = history.lastOrNull?.childIds;
    hc?.add(userMessage.id);
    history.lastOrNull?.enabledChild = (hc?.length != null
        ? hc!.length - 1
        : 0);
    //将树给设置好（由于dart传引用，所以我可以直接修改从map form来的history list，能同步上）
    state.messages[userMessage.id] = userMessage;
    state = state.copyWith(
      isLoading: true,
      uploadedFilesStash: {},
      error: null,
      messagesList: [...history, userMessage],
    );
    //接下来构造发送的后端消息
    // --- Database Integration ---
    try {
      if (currentSessionId == null) {
        throw ChatException(ChatExceptionType.sessionNotFound);
      }
      await _dbService.addMessage(
        currentSessionId!,
        userMessage,
        modifiedParent: history.lastOrNull,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        error: (e is AppException)
            ? e
            : ChatException(ChatExceptionType.failToSaveMessage),
      );
      // Decide if we want to stop or continue if DB save fails. For now, continue.
    }
    // --- End Database Integration ---
    sendRequest(history, userMessage);
  }

  /// request the llm to generate a response
  ///
  /// [history] is the history of messages
  ///
  /// [lastMessage] is the last (and latest) message (not in the history),on most occasions
  /// it is the user's input.Yet, it can also be a message that needs to be regenerated (eg. branch new variant)
  void sendRequest(List<ChatMessage> history, ChatMessage lastMessage) async {
    try {
      final stream = agentNotifier.getStreamingResponse(
        state.session!,
        history,
        lastMessage,
      );
      ChatMessage? finalAiMessage;
      state = state.copyWith(isResponding: true);
      await for (final chunk in stream) {
        state.newContentBuffer.write(chunk.content);
        state.refreshFlag.value = !state.refreshFlag.value;
      }
      finalAiMessage = ChatMessage(
        id: _uuid.v7(),
        messageId: _uuid.v7(),
        sender: MessageSender.ai,
        content: state.newContentBuffer.toString(),
        timestamp: DateTime.now(),
        parent: lastMessage.id,
        childIds: [],
        enabledChild: 0,
      );
      lastMessage.childIds.add(finalAiMessage.id);
      lastMessage.enabledChild = (lastMessage.childIds.length - 1);
      state.messages[finalAiMessage.id] = finalAiMessage;
      state.messagesList.add(finalAiMessage);
      state = state.copyWith(isResponding: false);
      state.newContentBuffer.clear();
      // --- Database Integration ---
      if (currentSessionId == null) {
        throw Exception('No session selected');
      }
      await _dbService.addMessage(
        currentSessionId!,
        finalAiMessage,
        modifiedParent: lastMessage,
      );
      if (state.session!.name == "New Chat") {
        generateTitle();
      }
      // --- End Database Integration ---
    } catch (e) {
      state.newContentBuffer.clear();
      state.newContentBuffer.write("<error>${e.toString()}</error>");
      print(e);
      // well I think it's ugly to leave an error message in the chat history
      // so let's not save it to the base
      /*
      var msg = ChatMessage(
        id: _uuid.v7(),
        sender: MessageSender.ai,
        content: state.newContentBuffer.toString(),
        timestamp: DateTime.now(),
      );
      state = state.copyWith(messages: [...state.messages, msgD]);
      state.refreshFlag.value = !state.refreshFlag.value;
      await _dbService.addMessage(
        currentSessionId!,
        state.messages.length - 1,
        msgD,
        state.uploadedFiles,
      );
      var l = _ref.read(panelManager).saveToJson();
      if (l != null) {
        await _dbService.writeLayout(state.session!.id, l);
      }
      */
    } finally {
      state = state.copyWith(isLoading: false, isResponding: false);
    }
  }

  Future<void> generateTitle() async {
    if (state.session == null) {
      return;
    }
    try {
      state = state.copyWith(isLoading: true, isResponding: true);
      StringBuffer sb = StringBuffer();
      // use the to string method in the chat message class to generate simple text
      for (var m in state.messagesList) {
        var s = m.toString();
        if (s.isNotEmpty && s != "") {
          sb.write(s);
          sb.write("\n");
        }
      }
      // 构造一个空的message 来临时使用即可
      ChatMessage cm = ChatMessage(
        id: "",
        messageId: "",
        sender: MessageSender.user,
        content: Prompts.generateTitle(sb.toString()),
        timestamp: DateTime.now(),
        parent: null,
        childIds: [],
        enabledChild: 0,
      );
      final stream = agentNotifier.getStreamingResponse(state.session!, [], cm);
      sb.clear();
      await for (final chunk in stream) {
        sb.write(chunk.content);
      }
      var title = jsonDecode(sb.toString())["title"];
      if (title == null) {
        return;
      }
      state.session!.name = title;
      await _dbService.updateSessionTitle(state.session!.id, title);
    } on Exception catch (e) {
      state = state.copyWith(
        error: (e is AppException)
            ? e
            : ChatException(ChatExceptionType.failToGenerateTitle),
      );
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
  return notifier;
});
