import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:uni_chat/Agent/agentProvider.dart';
import 'package:uni_chat/Chat/chat_page.dart';
import 'package:uni_chat/Execution/execution_models.dart';
import 'package:uni_chat/Persona/persona_provider.dart';
import 'package:uni_chat/database/database_service.dart';
import 'package:uni_chat/error_handling.dart';
import 'package:uni_chat/promps.dart';
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
  final Map<String, List<({String sessionId, String title})>> branchNames;
  late Map<String, ({UploadStatus status, ChatFile file})> uploadedFilesStash;
  // 临时存储上传的文件，当用户点击发送按钮的时候会被合并到messages里面
  final bool isLoading;
  final bool isResponding;
  final bool isStreamingStarted;
  final bool isGeneratingTitle;
  final StopSignal? stopSignal;
  final StopSignal? titleStopSignal;
  late final ValueNotifier<List<ContentChunk>> responses;

  ChatState({
    this.isReady = false,
    ChatSession? session,
    this.messages = const {},
    this.messagesList = const [],
    this.branchNames = const {},
    Map<String, ({UploadStatus status, ChatFile file})>? uploadedFilesStash,
    ValueNotifier<List<ContentChunk>>? responses,
    this.isLoading = false,
    this.isResponding = false,
    this.isStreamingStarted = false,
    this.isGeneratingTitle = false,
    this.stopSignal,
    this.titleStopSignal,
    this.error,
  }) {
    this.responses = responses ?? ValueNotifier([]);
    this.uploadedFilesStash = uploadedFilesStash ?? {};
    if (session != null) {
      this.session = session;
    }
  }

  ChatState copyWith({
    bool? isReady,
    ChatSession? session,
    Map<String, ChatMessage>? messages,
    List<ChatMessage>? messagesList,
    Map<String, List<({String sessionId, String title})>>? branchNames,
    Map<String, ({UploadStatus status, ChatFile file})>? uploadedFilesStash,
    bool? isLoading,
    bool? isResponding,
    bool? isStreamingStarted,
    bool? isGeneratingTitle,
    StopSignal? stopSignal,
    StopSignal? titleStopSignal,
    AppException? error,
    ValueNotifier<List<ContentChunk>>? responses,
  }) {
    return ChatState(
      responses: responses ?? this.responses,
      isReady: isReady ?? this.isReady,
      session: session ?? this.session,
      messages: messages ?? this.messages,
      messagesList: messagesList ?? this.messagesList,
      branchNames: branchNames ?? this.branchNames,
      uploadedFilesStash: uploadedFilesStash ?? this.uploadedFilesStash,
      isLoading: isLoading ?? this.isLoading,
      isResponding: isResponding ?? this.isResponding,
      isStreamingStarted: isStreamingStarted ?? this.isStreamingStarted,
      isGeneratingTitle: isGeneratingTitle ?? this.isGeneratingTitle,
      stopSignal: stopSignal ?? this.stopSignal,
      titleStopSignal: titleStopSignal ?? this.titleStopSignal,
      error: error ?? this.error,
    );
  }

  ChatState clearSessionCopy() {
    return ChatState(
      isReady: isReady,
      session: null,
      messages: {},
      messagesList: [],
      branchNames: {},
      uploadedFilesStash: {},
      isLoading: false,
      isGeneratingTitle: false,
      error: null,
      responses: ValueNotifier([]),
    );
  }
}

// --- State Notifier ---
class ChatStateNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  late AgentProvider agentNotifier;
  Agent? get agent => agentNotifier.state;
  Persona? get persona => _ref.read(personaProvider);
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
    Map<String, ({UploadStatus status, ChatFile file})>? uploadedFilesStash,
    bool? isLoading,
    bool? isResponding,
    bool? isStreamingStarted,
    bool? isGeneratingTitle,
    StopSignal? stopSignal,
    StopSignal? titleStopSignal,
    AppException? error,
  }) {
    state = state.copyWith(
      isReady: isReady,
      session: session,
      messages: messages,
      uploadedFilesStash: uploadedFilesStash,
      messagesList: messagesList,
      isLoading: isLoading,
      isResponding: isResponding,
      isStreamingStarted: isStreamingStarted,
      isGeneratingTitle: isGeneratingTitle,
      stopSignal: stopSignal,
      titleStopSignal: titleStopSignal,
      error: error,
    );
  }

  void clearError() {
    state = ChatState(
      isReady: state.isReady,
      session: state.session,
      messages: state.messages,
      messagesList: state.messagesList,
      branchNames: state.branchNames,
      uploadedFilesStash: state.uploadedFilesStash,
      responses: state.responses,
      isLoading: state.isLoading,
      isResponding: state.isResponding,
      isStreamingStarted: state.isStreamingStarted,
      isGeneratingTitle: state.isGeneratingTitle,
      stopSignal: state.stopSignal,
      titleStopSignal: state.titleStopSignal,
      error: null,
    );
  }

  void removeFromStash(String fileName) {
    state.uploadedFilesStash.remove(fileName);
    stateCopyWith();
  }

  void resetGenerationState() {
    state.responses.value = [];
    state = ChatState(
      isReady: state.isReady,
      session: state.session,
      messages: state.messages,
      messagesList: state.messagesList,
      branchNames: state.branchNames,
      uploadedFilesStash: state.uploadedFilesStash,
      responses: state.responses,
      isLoading: false,
      isResponding: false,
      isStreamingStarted: false,
      isGeneratingTitle: false,
      stopSignal: null,
      titleStopSignal: null,
      error: state.error,
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

  Future<void> createNewSession({String? title}) async {
    state = state.copyWith(isLoading: true, error: null);
    String? pid = _ref.read(personaProvider).id;
    if (!(pid.isNotEmpty && pid != "")) {
      pid = null;
      //如果是默认人格（id = “ ”），就不储存消息
    }
    final now = DateTime.now();
    final newSession = ChatSession(
      id: _uuid.v7(),
      agentId: agent!.id,
      persona: pid,
      name: title ?? 'New Chat - ${now.toIso8601String()}',
      creationTime: now,
      lastMessageTime: now,
      branchInfo: null,
    );
    //construct the root message
    var root = ChatMessage(
      id: newSession.id,
      parent: null,
      childIds: [],
      sender: MessageSender.internal,
      senderId: "internal",
      content: '',
      timestamp: now,
      enabledChild: 0,
    );
    var history = [root];
    var messages = {root.id: root};
    ChatMessage? opening;
    // Check if we should insert opening message
    if (agent?.openingConfigure?.firstMessage != null &&
        agent!.openingConfigure!.firstMessage!.isNotEmpty) {
      opening = ChatMessage(
        id: _uuid.v7(),
        messageId: _uuid.v7(),
        sender: MessageSender.ai,
        senderId: agent!.id,
        content: agent!.openingConfigure!.firstMessage!,
        timestamp: DateTime.now(),
        parent: root.id,
        childIds: [],
        enabledChild: 0,
      );
      root.childIds.add(opening.id);
      root.enabledChild = root.childIds.length - 1;
      // Update local state
      messages[opening.id] = opening;
      history.add(opening);
    }
    await _dbService.createSession(
      newSession: newSession,
      root: root,
      opening: opening,
    );
    //解释一下，由于我们现在的懒加载机制，在创建new session的时候此时state里面的数据不能清空并重加载，
    // 因为比如用户可能上传了一个文件（被保存在stash中，此时new一个state的话就导致文件没了）
    state = state.copyWith(
      isReady: agent != null,
      session: newSession,
      messages: messages,
      messagesList: history,
      branchNames: {},
      isLoading: false,
    );
  }

  Future<void> switchSession(
    String sessionId, {
    ChatSession? fromNewSession,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (fromNewSession != null) {
      } else {
        // 1. Get Session
        var session = await _dbService.getSession(sessionId);
        if (session == null) {
          throw ChatException(ChatExceptionType.sessionNotFound);
        }
        //TODO: 最好让这里的逻辑都放到agent_provider里面
        await _ref
            .read(agentProvider.notifier)
            .loadAgentById(
              session.agentId,
              overrideJson: session.agentOverride,
            );
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

        // 3. Load Branch Names
        Map<String, List<({String sessionId, String title})>>? branchNames;
        if (session.branchInfo != null) {
          branchNames = {};
          Map<String, List<String>> relatedSessionIds = {};
          if (session.branchInfo!.origin != null) {
            var so = session.branchInfo!.origin!;
            relatedSessionIds[so.messageId] = [so.sessionId];
          }
          for (var branch in session.branchInfo!.branches) {
            if (relatedSessionIds.containsKey(branch.messageId)) {
              relatedSessionIds[branch.messageId]!.add(branch.sessionId);
            } else {
              relatedSessionIds[branch.messageId] = [branch.sessionId];
            }
          }

          if (relatedSessionIds.isNotEmpty) {
            final allSessionIds = relatedSessionIds.values
                .expand((e) => e)
                .toList();
            var r = await _dbService.getSessionTitles(allSessionIds);

            // Create a lookup map for titles
            final titleMap = {for (var e in r) e.id: e.title};

            relatedSessionIds.forEach((messageId, sessionIds) {
              branchNames![messageId] = sessionIds
                  .map((sid) => (sessionId: sid, title: titleMap[sid] ?? ""))
                  .toList();
            });
          }
        }

        state = state.copyWith(
          isReady: agent != null,
          session: session,
          messages: msg.messages,
          messagesList: formed,
          branchNames: branchNames,
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

  Future<void> branchSession(String messageId, String newTitle) async {
    if (state.session == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final newSession = await _dbService.branchSessionFromMessage(
        state.session!.id,
        messageId,
        newTitle,
      );
      if (newSession != null) {
        await switchSession(newSession.id);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: ChatException(ChatExceptionType.branchSessionFailed),
        );
      }
    } on Exception {
      state = state.copyWith(
        isLoading: false,
        error: ChatException(ChatExceptionType.branchSessionFailed),
      );
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
    )) {
      if (!agentNotifier.state!.client.model.abilities.contains(
        ModelAbility.visual,
      )) {
        state.uploadedFilesStash[id] = (
          file: ChatFile(
            name: id,
            originalName: name,
            uploadTime: DateTime.now(),
          ),
          status: UploadStatus.failed,
        );
        state = state.copyWith(
          isLoading: false,
          error: ChatException(ChatExceptionType.modelNotSupportFileType),
        );
        return;
      }
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
    //接下来构造发送的后端消息
    // --- Database Integration ---
    try {
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
        senderId: persona?.id ?? 'user',
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
      if (currentSessionId == null) {
        throw ChatException(ChatExceptionType.sessionNotFound);
      }
      await _dbService.addMessage(
        currentSessionId!,
        userMessage,
        modifiedParent: history.lastOrNull,
      );
      sendRequest(history, userMessage);
    } on Exception catch (e) {
      state = state.copyWith(
        error: (e is AppException)
            ? e
            : ChatException(ChatExceptionType.failToSaveMessage),
      );
      // Decide if we want to stop or continue if DB save fails. For now, continue.
    }
    // --- End Database Integration ---
  }

  /// request the llm to generate a response
  ///
  /// [history] is the history of messages
  ///
  /// [lastMessage] is the last (and latest) message (not in the history),on most occasions
  /// it is the user's input.Yet, it can also be a message that needs to be regenerated (eg. branch new variant)
  void sendRequest(List<ChatMessage> history, ChatMessage lastMessage) async {
    try {
      final stopSignal = StopSignal();
      state = state.copyWith(stopSignal: stopSignal, isResponding: true);

      state.responses.value = [];
      List<ContentChunk> finalChunks = [];

      try {
        finalChunks = await agentNotifier.execute(
          history: history,
          lastMessage: lastMessage,
          responseNotifier: state.responses,
          stopSignal: stopSignal,
        );
      } on Exception catch (e) {
        if (state.stopSignal?.isStopped != true) {
          state = state.copyWith(
            error: (e is AppException) ? e : ChatException.fromException(e),
          );
        }
      }

      if (finalChunks.isNotEmpty) {
        // 1. 确保顺序严格按照 ID
        final sortedChunks = finalChunks.toList()
          ..sort((a, b) => a.id.compareTo(b.id));

        // 2. 合并文本内容作为主内容（按 ID 顺序）
        String mainContent = sortedChunks
            .whereType<TextChunk>()
            .map((e) => e.text)
            .join();

        // 3. 提取其他块（思考过程、工具调用），计算准确偏移
        List<Map<String, dynamic>> blocks = [];
        int currentAnchor = 0;
        for (var chunk in sortedChunks) {
          if (chunk is TextChunk) {
            currentAnchor += chunk.text.length;
          } else if (chunk is ReasoningChunk) {
            blocks.add(
              MessageBlock(
                content: chunk.text,
                anchor: currentAnchor,
                chunkType: MessageChunkType.reasoning,
              ).toMap(),
            );
          } else if (chunk is ToolCallChunk) {
            blocks.add(
              MessageBlock(
                content: chunk.content,
                anchor: currentAnchor,
                chunkType: MessageChunkType.toolCall,
                toolData: chunk.toStructuredData(),
              ).toMap(),
            );
          }
        }

        final finalAiMessage = ChatMessage(
          id: _uuid.v7(),
          messageId: _uuid.v7(),
          sender: MessageSender.ai,
          senderId: agent!.client.model.id,
          content: mainContent,
          data: blocks.isNotEmpty ? {"msg_blocks": blocks} : null,
          timestamp: DateTime.now(),
          parent: lastMessage.id,
          childIds: [],
          enabledChild: 0,
        );

        // 更新消息树关联
        lastMessage.childIds.add(finalAiMessage.id);
        lastMessage.enabledChild = (lastMessage.childIds.length - 1);
        state.messages[finalAiMessage.id] = finalAiMessage;

        // 将消息添加和状态重置合并为一次原子更新
        state = state.copyWith(
          messagesList: [...state.messagesList, finalAiMessage],
          isResponding: false,
          isLoading: false,
        );

        if (currentSessionId == null) {
          throw Exception('No session selected');
        }
        await _dbService.addMessage(
          currentSessionId!,
          finalAiMessage,
          modifiedParent: lastMessage,
        );
      }
    } on Exception catch (e) {
      state = state.copyWith(
        error: (e is AppException) ? e : ChatException.fromException(e),
      );
    } finally {
      resetGenerationState();
    }
    // title generation has to be done after the finally
    // or the wrong stop signal will be disposed and causes crashes (generateTitle it self will add a new stop signal)
    if (state.session!.name == "New Chat" && !state.isGeneratingTitle) {
      generateTitle();
    }
  }

  void stopGeneration() {
    state.stopSignal?.stop();
  }

  void stopTitleGeneration() {
    state.titleStopSignal?.stop();
    state = state.copyWith(isGeneratingTitle: false, titleStopSignal: null);
  }

  Future<void> generateTitle() async {
    if (state.session == null) {
      return;
    }
    try {
      final stopSignal = StopSignal();
      state = state.copyWith(
        isGeneratingTitle: true,
        titleStopSignal: stopSignal,
      );
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
        senderId: "nan",
        childIds: [],
        enabledChild: 0,
      );
      final stream = agentNotifier.getStreamingResponse(
        state.session!,
        [],
        cm,
        stopSignal: stopSignal,
      );
      sb.clear();
      await for (final chunk in stream) {
        sb.write(chunk.content);
      }
      String? title;
      try {
        title = jsonDecode(sb.toString())["title"];
      } catch (e) {
        if (e is FormatException) {
          var s = sb.toString();
          // remove <think> tags
          // or the thought of cot models will break the json decode
          s = s.replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '');
          s.trim();
          title = jsonDecode(s)["title"];
        }
      }
      if (title == null) {
        return;
      }
      state.session!.name = title;
      await _dbService.updateSessionTitle(state.session!.id, title);
    } on Exception catch (e) {
      if (state.titleStopSignal?.isStopped == true) {
        return;
      }
      state = state.copyWith(
        error: (e is AppException)
            ? e
            : ChatException(ChatExceptionType.failToGenerateTitle),
      );
    } finally {
      resetGenerationState();
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
