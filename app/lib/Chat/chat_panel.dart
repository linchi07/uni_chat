import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:uni_chat/Agent/agentProvider.dart';
import 'package:uni_chat/Chat/chat_sidebar.dart';
import 'package:uni_chat/Persona/persona_provider.dart';
import 'package:uni_chat/utils/database_service.dart';
import 'package:uni_chat/utils/file_utils.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:uuid/uuid.dart';

import '../generated/l10n.dart';
import '../theme_manager.dart';
import '../utils/overlays.dart';
import 'chat_message_bubble.dart';
import 'chat_models.dart';
import 'chat_state.dart';

class _AgentDropDown extends ConsumerStatefulWidget {
  const _AgentDropDown({super.key});
  @override
  ConsumerState<_AgentDropDown> createState() => _AgentDropDownState();
}

class _AgentDropDownState extends ConsumerState<_AgentDropDown>
    with SingleTickerProviderStateMixin {
  (String, String)? selectedIndex;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.7, curve: Curves.easeInOut), // 前半段时间执行
      ),
    );
    var agent = ref.read(agentProvider);
    if (agent != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedIndex = (agent.id, agent.name);
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<(List<AgentData>, List<File?>, File?)> getAgentAndAvatars() async {
    var agents = await DatabaseService.instance.getAllAgents();
    var avatars = <File?>[];
    File? selectedAvatar;
    for (var agent in agents) {
      var avatar = await agent.getAvatar();
      if (agent.id == selectedIndex?.$1) {
        selectedAvatar = avatar;
      }
      avatars.add(avatar);
    }
    return (agents, avatars, selectedAvatar);
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    var agent = ref.watch(agentProvider);
    if (agent?.id != selectedIndex?.$1 && agent != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedIndex = (agent.id, agent.name);
        });
      });
    }
    return SizedBox(
      height: 40,
      width: 180,
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: theme.zeroGradeColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: () {
            var rb = context.findRenderObject() as RenderBox;
            OverlayPortalService.show(
              context,
              barrierVisible: false,
              offset: rb.localToGlobal(Offset.zero),
              // 这是你要求修改的部分
              child: SizeTransition(
                sizeFactor: _scaleAnimation,
                child: SizedBox(
                  width: rb.size.width + 4,
                  height: rb.size.height * 5 + 3,
                  child: Material(
                    elevation: 4,
                    color: theme.zeroGradeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FutureBuilder(
                      future: getAgentAndAvatars(),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (asyncSnapshot.data == null) {
                          return Center(
                            child: Text(S.of(context).error_occurred),
                          );
                        }
                        return Column(
                          children: [
                            // 这个三元运算符可以简化
                            if (selectedIndex != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 16.0),
                                    StdAvatar(file: asyncSnapshot.data!.$3),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        selectedIndex!.$2,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: theme.textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Divider(),
                            if (asyncSnapshot.data!.$1.isEmpty)
                              Center(child: Text(S.of(context).no_agent)),
                            Expanded(
                              child: (_scaleAnimation.isCompleted)
                                  ? SizedBox()
                                  : ListView.builder(
                                      itemCount: asyncSnapshot.data!.$1.length,
                                      itemBuilder: (context, index) {
                                        return StdListTile(
                                          onTap: () async {
                                            OverlayPortalService.hide(context);
                                            await ref
                                                .read(agentProvider.notifier)
                                                .loadAgentById(
                                                  asyncSnapshot
                                                      .data!
                                                      .$1[index]
                                                      .id,
                                                );
                                          },
                                          title: Text(
                                            asyncSnapshot.data!.$1[index].name,
                                          ),
                                          leading: StdAvatar(
                                            file: asyncSnapshot.data!.$2[index],
                                            length: 25,
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
            // 启动动画 (这个是必须的)
            _controller.forward(from: 0.0);
          },
          child: (selectedIndex == null)
              ? Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        S.of(context).plz_select_agent,
                        style: TextStyle(fontSize: 16, color: theme.textColor),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: theme.textColor),
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16),
                    FutureBuilder(
                      future: agent?.getAvatar(),
                      builder: (context, asyncSnapshot) {
                        return StdAvatar(file: asyncSnapshot.data, length: 28);
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedIndex!.$2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, color: theme.textColor),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: theme.textColor),
                    const SizedBox(width: 16),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PersonaDropDown extends ConsumerStatefulWidget {
  const _PersonaDropDown({super.key});
  @override
  ConsumerState<_PersonaDropDown> createState() => _PersonaDropDownState();
}

class _PersonaDropDownState extends ConsumerState<_PersonaDropDown>
    with SingleTickerProviderStateMixin {
  (String, String)? selectedIndex;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.7, curve: Curves.easeInOut), // 前半段时间执行
      ),
    );
    var persona = ref.read(personaProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedIndex = (persona.id, persona.name);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<(List<Persona>, List<File?>, File?)> getPersonaAndAvatar() async {
    var ps = await DatabaseService.instance.getAllPersonas();
    File? selectedAvatar;
    List<File?> avatars = [];
    for (var p in ps) {
      var avatar = await p.getAvatar();
      avatars.add(avatar);
      if (p.id == selectedIndex?.$1) {
        selectedAvatar = avatar;
      }
    }
    return (ps, avatars, selectedAvatar);
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    var persona = ref.watch(personaProvider);
    if (persona.id != selectedIndex?.$1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedIndex = (persona.id, persona.name);
        });
      });
    }
    return SizedBox(
      height: 40,
      width: 180,
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: theme.zeroGradeColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: () {
            var rb = context.findRenderObject() as RenderBox;
            OverlayPortalService.show(
              context,
              barrierVisible: false,
              offset: rb.localToGlobal(Offset.zero),
              // 这是你要求修改的部分
              child: SizeTransition(
                sizeFactor: _scaleAnimation,
                child: SizedBox(
                  width: rb.size.width + 4,
                  height: rb.size.height * 5 + 3,
                  child: Material(
                    elevation: 4,
                    color: theme.zeroGradeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FutureBuilder(
                      future: getPersonaAndAvatar(),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (asyncSnapshot.data == null) {
                          return Center(
                            child: Text(S.of(context).error_occurred),
                          );
                        }
                        return Column(
                          children: [
                            // 这个三元运算符可以简化
                            if (selectedIndex != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 16.0),
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: StdAvatar(
                                        file: asyncSnapshot.data!.$3,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        selectedIndex!.$2,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: theme.textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Divider(),
                            if (asyncSnapshot.data!.$1.isEmpty)
                              Center(child: Text(S.of(context).no_persona)),
                            Expanded(
                              child: (_scaleAnimation.isCompleted)
                                  ? SizedBox()
                                  : ListView.builder(
                                      itemCount: asyncSnapshot.data!.$1.length,
                                      itemBuilder: (context, index) {
                                        return StdListTile(
                                          onTap: () async {
                                            OverlayPortalService.hide(context);
                                            await ref
                                                .read(personaProvider.notifier)
                                                .loadPersonaById(
                                                  asyncSnapshot
                                                      .data!
                                                      .$1[index]
                                                      .id,
                                                );
                                          },
                                          title: Text(
                                            asyncSnapshot.data!.$1[index].name,
                                          ),
                                          leading: StdAvatar(
                                            length: 20,
                                            file: asyncSnapshot.data!.$2[index],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
            // 启动动画 (这个是必须的)
            _controller.forward(from: 0.0);
          },
          child: (selectedIndex == null)
              ? Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        S.of(context).plz_select_persona,
                        style: TextStyle(fontSize: 16, color: theme.textColor),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: theme.textColor),
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16),
                    FutureBuilder(
                      future: persona.getAvatar(),
                      builder: (context, asyncSnapshot) {
                        return StdAvatar(length: 24, file: asyncSnapshot.data);
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedIndex!.$2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16, color: theme.textColor),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: theme.textColor),
                    const SizedBox(width: 16),
                  ],
                ),
        ),
      ),
    );
  }
}

class ChatPanelWhenNoSession extends ConsumerWidget {
  const ChatPanelWhenNoSession({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: theme.secondGradeColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "一起集思广益！",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).choose_agent_and_chat_hint,
              style: TextStyle(fontSize: 16, color: theme.thirdGradeColor),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context).front_page_hintLine_char1,
                  style: TextStyle(fontSize: 18),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _PersonaDropDown(),
                ),
                Text(
                  S.of(context).front_page_hintLine_char2,
                  style: TextStyle(fontSize: 18),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _AgentDropDown(),
                ),
                Text(
                  S.of(context).front_page_hintLine_char3,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width.clamp(0, 800),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ChatPanelInputBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPanel extends ConsumerStatefulWidget {
  const ChatPanel({super.key});

  @override
  ConsumerState<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends ConsumerState<ChatPanel> {
  late ScrollController _scrollController;
  late final ListObserverController _listObserverController =
      ListObserverController();
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    chatState = ref.read(chatStateProvider);
    chatState.refreshFlag.addListener(() {
      print(
        (_scrollController.offset - _scrollController.position.maxScrollExtent)
            .abs(),
      );
      if ((_scrollController.offset -
                  _scrollController.position.maxScrollExtent)
              .abs() <
          20) {
        _scrollController.position.moveTo(
          (_scrollController.position.maxScrollExtent),
        );
      }
    });
    _listObserverController.controller = _scrollController;
    indexChangeEvent.addListener(() {
      if (indexChangeEvent.value != null) {
        if (indexChangeEvent.value == chatState.messagesList.length - 1) {
          // the indexed based scroll is faulty when scrolling to the bottom , so we manually handle this
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          return;
        }
        _listObserverController.jumpTo(index: indexChangeEvent.value!);
        indexChangeEvent.value = null;
      }
    });
  }

  late ChatState chatState;
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.position.moveTo(
        (_scrollController.position.maxScrollExtent),
      );
    });
  }

  ChatSession? session;

  ValueNotifier<int> currentActiveIndex = ValueNotifier(0);
  ValueNotifier<({ChatMessage? message, Offset? pointerLoc})> messageInfo =
      ValueNotifier((message: null, pointerLoc: null));
  // acts as a bridge to connect sidebar and bar display to display previews
  ValueNotifier<int?> indexChangeEvent = ValueNotifier(null);
  @override
  Widget build(BuildContext context) {
    chatState = ref.watch(chatStateProvider);
    // jump to bottom when session changes
    if (session != chatState.session) {
      jumpToBottom();
      session = chatState.session;
    }
    var theme = ref.watch(themeProvider);
    if (!chatState.isReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatStateProvider.notifier).checkIfReady();
      });
    }
    var itemCount = chatState.isResponding
        ? chatState.messages.length + 1
        : chatState.messages.length;
    return Scaffold(
      backgroundColor: theme.secondGradeColor,
      //add the scrollbar outside the container
      body: Scrollbar(
        controller: _scrollController,
        child: ScrollConfiguration(
          //and disable the default scrollbar
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: LayoutBuilder(
            builder: (context, constraints) {
              var height = constraints.maxHeight;
              var width = constraints.maxWidth;
              var isDense = width < 1000;
              return Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  Positioned(
                    width: (!isDense) ? 1000 : null,
                    left: (isDense) ? 0 : null,
                    right: (isDense) ? 20 : null,
                    top: 0,
                    bottom: 0,
                    child: Column(
                      children: [
                        Expanded(
                          child: SelectionArea(
                            //还是国人做的包好用。。
                            child: ListViewObserver(
                              controller: _listObserverController,
                              // watch the index changes and update the value listener (watched by the sidebar to update the active index)
                              onObserve: (result) {
                                currentActiveIndex.value = max(
                                  0,
                                  (result.firstChild?.index ?? 0) - 1,
                                );
                              },
                              child: ListView.builder(
                                cacheExtent: 5000,
                                controller: _scrollController,
                                itemCount: itemCount,
                                itemBuilder: (context, index) {
                                  if (index >= 1 &&
                                      index <=
                                          chatState.messagesList.length - 1) {
                                    var message = chatState.messagesList[index];
                                    return PersistChatMessage(
                                      key: ValueKey(message.id),
                                      index: index,
                                      prevMessage:
                                          chatState.messagesList[index - 1],
                                      message: message,
                                      theme: theme,
                                    );
                                  }
                                  if (index == 0) {
                                    // 第0个消息是root消息，不应该被展示或者使用
                                    return const SizedBox.shrink();
                                  }
                                  if (chatState.isResponding &&
                                      index == itemCount - 1) {
                                    return ChatMessageDynamicStream(
                                      contentBuffer: chatState.newContentBuffer,
                                      refreshFlag: chatState.refreshFlag,
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: ChatPanelInputBox(
                            afterSubmit: () {
                              if (_scrollController.offset <
                                  _scrollController.position.maxScrollExtent) {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInSine,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    height: min(
                      min(
                            ChatSidebar.getHeight(
                              chatState.messagesList.length,
                            ),
                            800,
                          ) +
                          50,
                      height * 0.7,
                    ),
                    right: 8,
                    width: 40,
                    child: ChatSidebar(
                      isDense:
                          (width <
                          1060), //this needs more space , so var isDense doesn't work here
                      selectedIndex: indexChangeEvent,
                      currentActiveIndex: currentActiveIndex,
                      msgListener: messageInfo,
                    ),
                  ),
                  BarChatMessagePreview(theme: theme, messageInfo: messageInfo),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

///[textInject]: inject text to the input box before it is build
///
/// [beforeSubmit]:called before submitting to chatState,which enables you to do some things before start the text generation (eg. switch branch)
///
/// [afterSubmit]:called after submitting to chatState,which enables you to do some things after the request is send (eg. close the box)
///
/// [cancelCallback]:when provided,a cancel button will be shown eg. use it to close the window
///
/// *yet all these stupid functions are simple added to reuse this box in message bubble's modified input*
class ChatPanelInputBox extends ConsumerStatefulWidget {
  const ChatPanelInputBox({
    super.key,
    this.textInject,
    this.beforeSubmit,
    this.afterSubmit,
    this.cancelCallback,
  });
  final void Function(TextEditingController)? textInject;
  final void Function()? beforeSubmit;
  final void Function()? afterSubmit;
  final void Function()? cancelCallback;

  @override
  ConsumerState<ChatPanelInputBox> createState() => _ChatPanelInputBoxState();
}

enum UploadStatus { notUploaded, uploading, uploaded, failed }

class _ChatPanelInputBoxState extends ConsumerState<ChatPanelInputBox> {
  final _textController = TextEditingController();
  bool isDroppingFiles = false;
  late ThemeConfig theme;
  @override
  initState() {
    super.initState();
    chatState = ref.read(chatStateProvider);
    widget.textInject?.call(_textController);
  }

  late ChatState chatState;
  final Uuid _uuid = const Uuid();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true, // 允许选择多个文件
    );

    if (result != null) {
      for (var file in result.files) {
        if (file.path != null) {
          final actualFile = File(file.path!);
          final previewId = _uuid.v7();
          // 添加预览ID到附件列表
          final appDocDir = await getApplicationDocumentsDirectory();
          final sessionFilesDir = Directory(
            '${appDocDir.path}/chat/session_files',
          );
          if (!await sessionFilesDir.exists()) {
            await sessionFilesDir.create(recursive: true);
          }

          // 使用UUID生成新的文件名
          final newFileName = previewId + p.extension(actualFile.path);
          final newFilePath = '${sessionFilesDir.path}/$newFileName';
          // 拷贝文件到新位置
          final copiedFile = await actualFile.copy(newFilePath);
          // Trigger the upload via the notifier
          await ref
              .read(chatStateProvider.notifier)
              .triggerUploadFile(
                copiedFile,
                previewId,
                p.basename(actualFile.path),
              );
        }
      }
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    widget.beforeSubmit?.call();
    ref.read(chatStateProvider.notifier).sendMessage(text);
    _textController.clear();
    // wait for the state to update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.afterSubmit?.call();
    });
  }

  Future<void> _readAndAttachFile(dynamic f, String fileExtension) async {
    var previewId = _uuid.v7();
    var fname = f.fileName ?? DateTime.now().toIso8601String() + fileExtension;
    var path = await PathProvider.getPath(
      "chat/session_files/$previewId$fileExtension",
    );
    final file = File(path);
    final sink = file.openWrite();
    await f.getStream().forEach(sink.add);
    await sink.close();
    await ref
        .read(chatStateProvider.notifier)
        .triggerUploadFile(file, previewId, fname);
  }

  int _checkedTimes = 0;
  @override
  Widget build(BuildContext context) {
    chatState = ref.watch(chatStateProvider);
    final globalLoading = chatState.isLoading;
    if (!chatState.isReady && _checkedTimes < 5) {
      // wait some time before checking if ready (give the state sometime to prepare etc. load model), only check once
      // after testing , 70ms seems to be enough (M4 MBP)
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 70), () async {
          if (!mounted) return;
          ref.read(chatStateProvider.notifier).checkIfReady();
          _checkedTimes++;
        });
      });
    }
    theme = ref.watch(themeProvider);
    final isSendButtonLoading = (globalLoading);
    late Widget childPanel;
    if (isDroppingFiles) {
      childPanel = Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
        color: Colors.white.withAlpha(180),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AbsorbPointer(child: _buildChatPanel(isSendButtonLoading)),
            Text(
              S.of(context).drop_files_hint,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      );
    } else {
      childPanel = Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
        child: _buildChatPanel(isSendButtonLoading),
      );
    }
    if (chatState.error?.isNotEmpty ?? false) {
      childPanel = Column(
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            width: double.infinity,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                chatState.error!,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          childPanel,
        ],
      );
    }
    return DropRegion(
      formats: Formats.standardFormats,
      onDropOver: (d) {
        if (d.session.allowedOperations.contains(DropOperation.copy)) {
          setState(() {
            isDroppingFiles = true;
          });
          return DropOperation.copy;
        }
        return DropOperation.none;
      },
      onPerformDrop: (e) async {
        var item = e.session.items.first;
        if (item.dataReader == null) {
          return;
        }
        //啊没错，这个包就不能提供一个获取拓展名的方法，非要这样搞
        //而且他就不能提供一个file的类型的返回值，非要我一个个去读取。。。。
        if (item.canProvide(Formats.jpeg)) {
          item.dataReader?.getFile(
            Formats.jpeg,
            (f) async {
              await _readAndAttachFile(f, ".jpeg");
            },
            onError: (error) {
              return;
            },
          );
        } else if (item.canProvide(Formats.png)) {
          item.dataReader?.getFile(
            Formats.png,
            (f) async {
              await _readAndAttachFile(f, ".png");
            },
            onError: (error) {
              return;
            },
          );
        } else if (item.canProvide(Formats.pdf)) {
          item.dataReader?.getFile(
            Formats.pdf,
            (f) async {
              await _readAndAttachFile(f, ".pdf");
            },
            onError: (error) {
              return;
            },
          );
        } else if (item.canProvide(Formats.json)) {
          item.dataReader?.getFile(
            Formats.json,
            (f) async {
              await _readAndAttachFile(f, ".json");
            },
            onError: (error) {
              return;
            },
          );
        } else if (item.canProvide(Formats.csv)) {
          item.dataReader?.getFile(
            Formats.csv,
            (f) async {
              await _readAndAttachFile(f, ".csv");
            },
            onError: (error) {
              return;
            },
          );
        }
        if (item.canProvide(Formats.htmlFile)) {
          item.dataReader?.getFile(
            Formats.htmlFile,
            (f) async {
              await _readAndAttachFile(f, ".html");
            },
            onError: (error) {
              return;
            },
          );
        } else if (item.canProvide(Formats.md)) {
          item.dataReader?.getFile(
            Formats.md,
            (f) async {
              await _readAndAttachFile(f, ".md");
            },
            onError: (error) {
              return;
            },
          );
        } else
        //但愿他的意思是typescript，不是什么奇葩
        if (item.canProvide(Formats.ts)) {
          item.dataReader?.getFile(
            Formats.ts,
            (f) async {
              await _readAndAttachFile(f, ".ts");
            },
            onError: (error) {
              return;
            },
          );
        } else if (item.canProvide(Formats.plainText)) {
          item.dataReader?.getValue<String>(
            Formats.plainText,
            (value) {
              if (value != null) {
                _textController.text += value;
              }
            },
            onError: (error) {
              return;
            },
          );
        } else if (item.canProvide(Formats.plainTextFile)) {
          item.dataReader?.getFile(
            Formats.plainTextFile,
            (f) async {
              await _readAndAttachFile(f, p.extension(f.fileName ?? ".txt"));
            },
            onError: (error) {
              return;
            },
          );
        }
      },
      onDropLeave: (e) {
        setState(() {
          isDroppingFiles = false;
        });
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: theme.zeroGradeColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: childPanel,
      ),
    );
  }

  Future<void> readClipboard(SystemClipboard clipboard) async {
    final reader = await clipboard.read();
    //TMD 这个包真的逆天了，他的drop reader和clipboard reader 明明底层是一个东西，但是我需要写两遍愚蠢的代码！
    //啊没错，这个包就不能提供一个获取拓展名的方法，非要这样搞
    //而且他就不能提供一个file的类型的返回值，非要我一个个去读取。。。。
    //TODO：把这个傻逼包给换掉->这玩意tm无法区分纯文本文件（txt）和文本，不论如何设置，要不然会把txt粘贴成纯文本，要不然就会把纯文本粘贴成文件。**垃圾！**
    if (reader.canProvide(Formats.jpeg)) {
      reader.getFile(
        Formats.jpeg,
        (f) async {
          await _readAndAttachFile(f, ".jpeg");
          return;
        },
        onError: (error) {
          return;
        },
      );
      return;
    } else if (reader.canProvide(Formats.png)) {
      reader.getFile(
        Formats.png,
        (f) async {
          await _readAndAttachFile(f, ".png");
          return;
        },
        onError: (error) {
          return;
        },
      );
      return;
    } else if (reader.canProvide(Formats.pdf)) {
      reader.getFile(
        Formats.pdf,
        (f) async {
          await _readAndAttachFile(f, ".pdf");
          return;
        },
        onError: (error) {
          return;
        },
      );
      return;
    } else if (reader.canProvide(Formats.json)) {
      reader.getFile(
        Formats.json,
        (f) async {
          await _readAndAttachFile(f, ".json");
          return;
        },
        onError: (error) {
          return;
        },
      );
      return;
    } else if (reader.canProvide(Formats.csv)) {
      reader.getFile(
        Formats.csv,
        (f) async {
          await _readAndAttachFile(f, ".csv");
          return;
        },
        onError: (error) {
          return;
        },
      );
      return;
    } else if (reader.canProvide(Formats.htmlFile)) {
      reader.getFile(
        Formats.htmlFile,
        (f) async {
          await _readAndAttachFile(f, ".html");
          return;
        },
        onError: (error) {
          return;
        },
      );
      return;
    } else if (reader.canProvide(Formats.md)) {
      reader.getFile(
        Formats.md,
        (f) async {
          await _readAndAttachFile(f, ".md");
          return;
        },
        onError: (error) {
          return;
        },
      );
      return;
    } else
    //但愿他的意思是typescript，不是什么奇葩
    if (reader.canProvide(Formats.ts)) {
      reader.getFile(
        Formats.ts,
        (f) async {
          await _readAndAttachFile(f, ".ts");
          return;
        },
        onError: (error) {
          return;
        },
      );
      return;
    } else if (reader.canProvide(Formats.plainText)) {
      reader.getValue<String>(
        Formats.plainText,
        (value) {
          if (value != null) {
            _textController.text += value;
          }
          return;
        },
        onError: (error) {
          return;
        },
      );
      return;
    } else if (reader.canProvide(Formats.plainTextFile)) {
      reader.getFile(
        Formats.plainTextFile,
        (f) async {
          await _readAndAttachFile(f, p.extension(f.fileName ?? ".txt"));
          return;
        },
        onError: (error) {
          return;
        },
      );
      return;
    }
  }

  late final _focusNode = FocusNode(
    onKeyEvent: (FocusNode node, KeyEvent evt) {
      /*
      if (HardwareKeyboard.instance.isMetaPressed && evt.character == 'v') {
        if (evt is KeyDownEvent) {
          final clipboard = SystemClipboard.instance;
          if (clipboard == null) {
            return KeyEventResult
                .ignored; // Clipboard API is not supported on this platform.
          }
          readClipboard(clipboard);
          // this is a synchronous operation, no await future
          return KeyEventResult.handled;
        }
      }
      */
      if (HardwareKeyboard.instance.isShiftPressed &&
          evt.logicalKey == LogicalKeyboardKey.enter) {
        if (evt is KeyDownEvent) {
          final value = _textController.value;
          final selection = value.selection;

          // 2. 在光标位置插入换行符
          final newText = value.text.replaceRange(
            selection.start,
            selection.end,
            '\n',
          );
          var ns = TextSelection.collapsed(offset: selection.start + 1);
          // 3. 更新 Controller 并将光标移至换行符后
          _textController.value = TextEditingValue(
            text: newText,
            selection: ns,
            composing: TextRange.collapsed(selection.start + 1),
          );

          var boxSize =
              ((context.findRenderObject() as RenderBox).size -
                      Offset(4, 12)) // minus the padding
                  as Size;
          // we have to control the scroll by ourselves
          // damn flutter wont expose the base of editable text (///▽///)
          // 我tm花了整整6个小时尝试去调用editable text的内置方法，最后发现还是得自己算最方便
          // 搞到凌晨1点，然后老子后天要春考了！我ctmd。
          // 主要是给我调红温了
          var tp = TextPainter(
            text: TextSpan(
              text: _textController.text.substring(0, selection.end + 1),
              style: Theme.of(context).primaryTextTheme.bodyLarge,
            ),
            textDirection: TextDirection.ltr,
            maxLines: null,
          );
          tp.layout(maxWidth: boxSize.width);
          var current = _inputScrollController.offset;
          var delta = (tp.size.height - current);
          if (delta < 0) {
            // this height is calculated according to the top of the cursor
            // 20 is the height of the cursor
            // so we need to add a fix height
            _inputScrollController.jumpTo(current + delta - 20);
          } else if (delta - boxSize.height + 40 > 0) {
            // the same (40 is 2x height of cursor)
            _inputScrollController.jumpTo(
              min(
                current + delta - boxSize.height + 40 + 6,
                _inputScrollController.position.maxScrollExtent,
              ),
            ); //6 is a magic number……
          }
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    },
  );
  final ScrollController _inputScrollController = ScrollController();
  Widget _buildChatPanel(bool isSendButtonLoading) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chatState.uploadedFilesStash.isNotEmpty) _buildAttachmentPreview(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2),
          child: TextField(
            autofocus: true,
            focusNode: _focusNode,
            onTap: () {
              if (!chatState.isReady) {
                ref.read(chatStateProvider.notifier).checkIfReady();
              }
            },
            textInputAction: TextInputAction.send,
            maxLines: 8,
            minLines: 2,
            onSubmitted: (text) {
              if (text.isEmpty || isSendButtonLoading || !chatState.isReady) {
                return;
              }
              _sendMessage();
            },
            scrollController: _inputScrollController,
            controller: _textController,
            decoration: InputDecoration.collapsed(
              hintText: S.of(context).send_a_message_hint,
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _pickFile,
              tooltip: 'Attach File',
            ),
            const Spacer(),
            if (widget.cancelCallback != null)
              Container(
                height: 35,
                width: 35,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  clipBehavior: Clip.hardEdge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  color: theme.thirdGradeColor,
                  child: InkWell(
                    splashColor: Colors.grey,
                    onTap: widget.cancelCallback,
                    child: Icon(
                      Icons.close,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: 35,
              width: 35,
              child: Material(
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: (isSendButtonLoading || !chatState.isReady)
                    ? Colors.grey[600]
                    : theme.primaryColor,
                child: InkWell(
                  splashColor: Colors.grey,
                  onTap: (isSendButtonLoading || !chatState.isReady)
                      ? null
                      : _sendMessage,
                  child: isSendButtonLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(7.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                        )
                      : (chatState.isReady)
                      ? const Icon(
                          Icons.arrow_forward_sharp,
                          color: Colors.white,
                          size: 20,
                        )
                      : const Icon(
                          Icons.do_not_disturb_alt_sharp,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttachmentPreview() {
    var val = chatState.uploadedFilesStash.values.toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 10, right: 10),
      child: SizedBox(
        height: 60,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: val.length,
          itemBuilder: (context, index) {
            return _buildAttachmentPreviewItem(
              val[index].file,
              val[index].status,
              index,
            );
          },
        ),
      ),
    );
  }

  Widget _buildAttachmentPreviewItem(
    ChatFile? chatFile,
    UploadStatus status,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 基础预览内容
          Builder(
            builder: (context) {
              if (status == UploadStatus.uploaded && chatFile != null) {
                if (chatFile.type == FileTypeDefine.image) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: FutureBuilder<File>(
                      future: chatFile.getFile(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Image.file(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          );
                        } else if (snapshot.hasError) {
                          return Icon(Icons.error, size: 24);
                        } else {
                          return Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                      },
                    ),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    height: 50,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.description_outlined, size: 24),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              chatFile.originalName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                // 默认文件图标（上传中或失败状态）
                return Container(
                  padding: const EdgeInsets.all(8),
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.insert_drive_file, size: 24),
                );
              }
            },
          ),

          // 状态覆盖层
          if (status == UploadStatus.uploading)
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else if (status == UploadStatus.failed ||
              (status == UploadStatus.uploaded && chatFile == null))
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(125),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(Icons.error_outline, color: Colors.red),
                ),
              ),
            ),

          // 关闭按钮
          Positioned(
            top: 0,
            right: -6,
            child: GestureDetector(
              child: const Icon(Icons.cancel, color: Colors.black54, size: 16),
              onTap: () {
                setState(() {
                  if (chatFile != null) {
                    ref
                        .read(chatStateProvider)
                        .uploadedFilesStash
                        .remove(chatFile.name);
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
