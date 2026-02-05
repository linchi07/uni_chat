import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:macos_window_utils/widgets/macos_toolbar_passthrough.dart';
import 'package:uni_chat/Chat/chat_models.dart';
import 'package:uni_chat/Chat/panels/constant_value_indexer.dart';
import 'package:uni_chat/main.dart';
import 'package:uni_chat/utils/overlays.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';

import '../Agent/agentProvider.dart';
import '../Agent/agent_models.dart';
import '../generated/l10n.dart';
import '../theme_manager.dart';
import '../utils/database_service.dart';
import 'chat_message_bubble.dart';
import 'chat_state.dart';

class ChatBannerWidget extends ConsumerStatefulWidget {
  const ChatBannerWidget({super.key});

  @override
  ConsumerState<ChatBannerWidget> createState() => ChatBannerWidgetState();
}

final GlobalKey<ChatBannerWidgetState> chatBannerKey = GlobalKey();
//to toggle the overlay at any times

class ChatBannerWidgetState extends ConsumerState<ChatBannerWidget> {
  OverlayEntry? overlayEntry;
  final GlobalKey<_SessionSelectorOverlayState> _overlayKey = GlobalKey();

  void showSessionSelector() {
    final overlay = Overlay.of(context);
    var rb = context.findRenderObject() as RenderBox;
    final pos = rb.localToGlobal(Offset.zero);
    final size = rb.size;
    final screenSize = MediaQuery.of(context).size;

    overlayEntry = OverlayEntry(
      builder: (context) => RepaintBoundary(
        child: Stack(
          children: [
            ModalBarrier(color: Colors.transparent, onDismiss: hide),
            SessionSelectorOverlayContainer(
              key: _overlayKey,
              initialSize: size,
              initialPosition: pos,
              initialScreenSize: screenSize,
              onClose: hide,
            ),
          ],
        ),
      ),
    );
    overlay.insert(overlayEntry!);
  }

  void hide() {
    _overlayKey.currentState?.reverseAnimation().then((_) {
      if (overlayEntry != null) {
        overlayEntry?.remove();
        overlayEntry = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    var state = ref.watch(chatStateProvider);
    var agent = ref.watch(agentProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        var child = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            StdButton(
              onPressed: () {
                if (overlayEntry == null) {
                  showSessionSelector();
                } else {
                  hide();
                }
              },
              padding: const EdgeInsets.all(6),
              color: theme.secondGradeColor,
              child: Icon(Icons.search, size: 20),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: min(
                500,
                constraints.maxWidth - 80,
              ), //这里的80是两个按钮各32 + 16的spacing
              child: Material(
                color: theme.secondGradeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: () {
                    if (overlayEntry == null) {
                      showSessionSelector();
                    } else {
                      hide();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        FutureBuilder(
                          future: agent?.getAvatar(),
                          builder: (context, snapshot) {
                            return StdAvatar(file: snapshot.data, length: 23);
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            agent?.name ?? "Agent",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 1.5,
                          color: theme.thirdGradeColor,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            state.session?.name ?? "UNIChat",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(Icons.expand_more),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            StdButton(
              onPressed: () {
                ref.read(chatStateProvider.notifier).clearSession();
              },
              padding: const EdgeInsets.all(6),
              color: theme.secondGradeColor,
              child: Icon(Icons.add_comment_outlined, size: 20),
            ),
          ],
        );
        if (PlatForm().platform == RunningPlatform.macos) {
          //macos 的菜单栏需要处理一下,见top banner里面的注释
          return MacosToolbarPassthrough(child: child);
        }
        return child;
      },
    );
  }
}

class SessionSelectorOverlayContainer extends ConsumerStatefulWidget {
  const SessionSelectorOverlayContainer({
    super.key,
    required this.initialSize,
    required this.initialPosition, // 新增：初始位置
    required this.initialScreenSize,
    required this.onClose,
  });
  final Size initialSize;
  final Offset initialPosition; // 新增
  final Size initialScreenSize;
  final VoidCallback onClose;

  @override
  ConsumerState<SessionSelectorOverlayContainer> createState() =>
      _SessionSelectorOverlayState();
}

class _SessionSelectorOverlayState
    extends ConsumerState<SessionSelectorOverlayContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _widthAnimation;
  late final Animation<double> _heightAnimation;
  late final Animation<double> _leftAnimation; // **新增**: left 坐标的动画
  late final Animation<double> _opacityAnimation;
  late final Size _finalSize;

  @override
  void initState() {
    super.initState();
    _finalSize = Size(
      min(900, widget.initialScreenSize.width * 0.8),
      min(500, widget.initialScreenSize.height * 0.8),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // **新增**: 计算 left 动画的起始和结束值
    final double finalLeft =
        widget.initialPosition.dx -
        (_finalSize.width - widget.initialSize.width) / 2;

    _leftAnimation =
        Tween<double>(begin: widget.initialPosition.dx, end: finalLeft).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.0, 0.7, curve: Curves.easeOutSine),
          ),
        );

    _widthAnimation =
        Tween<double>(
          begin: widget.initialSize.width,
          end: _finalSize.width,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.0, 0.7, curve: Curves.easeOutSine),
          ),
        );

    _heightAnimation =
        Tween<double>(
          begin: widget.initialSize.height,
          end: _finalSize.height,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.3, 1.0, curve: Curves.easeOutSine),
          ),
        );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  Future<void> reverseAnimation() async {
    await _animationController.reverse();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          top: widget.initialPosition.dy,
          left: _leftAnimation.value, // 使用 left 动画
          child: SizedBox(
            width: _widthAnimation.value,
            height: _heightAnimation.value,
            child: Material(
              elevation: 4.0,
              color: theme.secondGradeColor,
              borderRadius: BorderRadius.circular(8),
              child: (_animationController.value >= 0.9) ? child : null,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: OverlayPortalScope(
          child: SessionSelector(
            onClose: widget.onClose,
            width: _finalSize.width,
          ),
        ),
      ),
    );
  }
}

class SessionSelector extends ConsumerStatefulWidget {
  const SessionSelector({
    super.key,
    required this.onClose,
    required this.width,
  });
  final VoidCallback onClose;
  final double width;

  @override
  ConsumerState<SessionSelector> createState() => _SessionSelectorState();
}

class _SessionSelectorState extends ConsumerState<SessionSelector> {
  late final ScrollController _sessionScrollController;
  late final ScrollController _agentScrollController;
  Timer? _hoverTimer;
  List<ChatMessage>? _previewedSession;
  late ThemeConfig theme;
  double lastScrollOffset = 0;

  late final FocusNode
  _inputBoxFocusNode; // for auto dismiss on escape key pressed
  @override
  void initState() {
    super.initState();
    selectedAgentId = ref.read(agentProvider)?.id;
    theme = ref.read(themeProvider);
    _inputBoxFocusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          node.unfocus();
          widget.onClose();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
    );
    if (!PlatForm().isMobile) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _inputBoxFocusNode.requestFocus();
        //auto  focus on menu open
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    cancelHoverTimer();
    if (isSessionScrollInited) {
      _sessionScrollController.dispose();
    }
    if (isAgentScrollInited) {
      _agentScrollController.dispose();
    }
  }

  void startHoverTimer(String sid) {
    // 在这里实现你想要触发的动作
    if (_sessionScrollController.offset == lastScrollOffset) {
      _hoverTimer = Timer(Duration(milliseconds: 250), () {
        if (_sessionScrollController.offset == lastScrollOffset) {
          setPreviewSession(sid);
        }
      });
    }
  }

  void cancelHoverTimer() {
    _hoverTimer?.cancel();
    _hoverTimer = null;
  }

  void setPreviewSession(String sid) async {
    var ps = await DatabaseService.instance.getMessageListForSession(sid);
    if (mounted) {
      internalSetState(() {
        _previewedSession = ps;
      });
    }
  }

  void switchSession(String sid) {
    ref.read(chatStateProvider.notifier).switchSession(sid);
  }

  bool isSessionScrollInited = false;
  bool isAgentScrollInited = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Widget _toolbarExpand() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            focusNode: _inputBoxFocusNode,
            controller: _searchController,
            decoration: InputDecoration(
              hintText: S.of(context).search_any_chat_message,
              prefixIcon: Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              fillColor: theme.zeroGradeColor,
            ),
            onChanged: (value) {
              _searchQuery = value;
            },
          ),
        ),
        if (selectedAgentId != null)
          StdButton(
            text: S.of(context).start_conversation_with_selected_agent,
            onPressed: () async {
              ref.read(chatStateProvider.notifier).clearSession();
              widget.onClose();
              await ref
                  .read(agentProvider.notifier)
                  .loadAgentById(selectedAgentId!);
            },
          ),
        IconButton(
          onPressed: () {
            widget.onClose();
          },
          icon: Icon(Icons.expand_less),
        ),
      ],
    );
  }

  String? selectedAgentId;

  Future<(List<AgentData>, List<File?>)> getAgentAndAvatars() async {
    // wait after the anim is done
    await Future.delayed(const Duration(milliseconds: 50));
    var agents = await DatabaseService.instance.getAllAgents();
    var avatars = <File?>[];
    for (int i = 0; i < agents.length; i++) {
      var agent = agents[i];
      var avatar = await agent.getAvatar();
      if (agent.id == selectedAgentId && !isAgentScrollInited) {
        _agentScrollController = ScrollController(
          initialScrollOffset: ((48 * i.toDouble() - 96.0).clamp(
            0,
            double.maxFinite,
          )),
        );
        isAgentScrollInited = true;
      }
      avatars.add(avatar);
    }
    if (!isAgentScrollInited) {
      _agentScrollController = ScrollController();
      isAgentScrollInited = true;
    }
    return (agents, avatars);
  }

  dynamic internalSetState;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(chatStateProvider).session;
    theme = ref.watch(themeProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _toolbarExpand(),
        ),
        Expanded(
          //此处只是防止list tile的背景色溢出
          child: Material(
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  flex: (widget.width >= 600) ? 4 : 3,
                  //此处是为了防止list tile的背景色溢出
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder(
                      future: getAgentAndAvatars(),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.data == null) {
                          return const SizedBox();
                        }
                        if (asyncSnapshot.data!.$1.isEmpty) {
                          return Center(
                            child: Text(
                              S.of(context).no_agent,
                              style: TextStyle(color: theme.thirdGradeColor),
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: _agentScrollController,
                          itemCount: asyncSnapshot.data!.$1.length,
                          itemBuilder: (context, index) {
                            var isSelected =
                                asyncSnapshot.data!.$1[index].id ==
                                selectedAgentId;
                            return StdListTile(
                              title: Text(asyncSnapshot.data!.$1[index].name),
                              leading: StdAvatar(
                                file: asyncSnapshot.data!.$2[index],
                                length: 30,
                                backgroundColor: isSelected
                                    ? theme.zeroGradeColor
                                    : null,
                              ),
                              isSelected: isSelected,
                              onTap: () {
                                if (asyncSnapshot.data!.$1[index].id !=
                                    selectedAgentId) {
                                  setState(() {
                                    selectedAgentId =
                                        asyncSnapshot.data!.$1[index].id;
                                  });
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: (widget.width >= 600) ? 15 : 7,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      internalSetState = setState;
                      return Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: (selectedAgentId == null)
                                  ? Center(
                                      child: Text(
                                        S.of(context).no_history,
                                        style: TextStyle(
                                          color: theme.thirdGradeColor,
                                        ),
                                      ),
                                    )
                                  : FutureBuilder(
                                      future: () async {
                                        // wait after the anim is done
                                        await Future.delayed(
                                          const Duration(milliseconds: 50),
                                        );
                                        return DatabaseService.instance
                                            .getAllSessionsByAgent(
                                              selectedAgentId!,
                                            );
                                      }.call(),
                                      builder: (context, asyncSnapshot) {
                                        if (asyncSnapshot.data == null) {
                                          return const SizedBox();
                                        }
                                        if (asyncSnapshot.data!.isEmpty) {
                                          return Center(
                                            child: Text(
                                              S.of(context).no_history,
                                              style: TextStyle(
                                                color: theme.thirdGradeColor,
                                              ),
                                            ),
                                          );
                                        }
                                        for (
                                          int i = 0;
                                          i < asyncSnapshot.data!.length;
                                          i++
                                        ) {
                                          //这里必须手动循环，因为listview有懒加载机制
                                          if (asyncSnapshot.data![i].id ==
                                                  session?.id &&
                                              !isSessionScrollInited) {
                                            _sessionScrollController =
                                                ScrollController(
                                                  initialScrollOffset:
                                                      (64 * i.toDouble() -
                                                              128.0)
                                                          .clamp(
                                                            0,
                                                            double.maxFinite,
                                                          ),
                                                );
                                            // 监听滚动状态变化
                                            _sessionScrollController
                                                .addListener(() {
                                                  if (_sessionScrollController
                                                      .position
                                                      .isScrollingNotifier
                                                      .value) {
                                                    lastScrollOffset =
                                                        _sessionScrollController
                                                            .offset;
                                                  }
                                                });
                                            isSessionScrollInited = true;
                                          }
                                        }
                                        if (!isSessionScrollInited) {
                                          _sessionScrollController =
                                              ScrollController();
                                          _sessionScrollController.addListener(
                                            () {
                                              if (_sessionScrollController
                                                  .position
                                                  .isScrollingNotifier
                                                  .value) {
                                                lastScrollOffset =
                                                    _sessionScrollController
                                                        .offset;
                                              }
                                            },
                                          );
                                          isSessionScrollInited = true;
                                        }
                                        return ListView.builder(
                                          controller: _sessionScrollController,
                                          itemCount: asyncSnapshot.data!.length,
                                          prototypeItem: _SessionTile(
                                            onClose: widget.onClose,
                                            setPreview: setPreviewSession,
                                            session: ChatSession(
                                              id: "",
                                              agentId: "",
                                              name: "112414",
                                              lastMessageTime:
                                                  DateTime.fromMicrosecondsSinceEpoch(
                                                    0,
                                                  ),
                                              creationTime:
                                                  DateTime.fromMicrosecondsSinceEpoch(
                                                    0,
                                                  ),
                                            ),
                                            theme: theme,
                                            startHoverTimer: startHoverTimer,
                                            cancelHoverTimer: cancelHoverTimer,
                                            switchSession: switchSession,
                                            isSelected: false,
                                          ),
                                          itemBuilder: (context, index) {
                                            return _SessionTile(
                                              onClose: widget.onClose,
                                              setPreview: setPreviewSession,
                                              session:
                                                  asyncSnapshot.data![index],
                                              theme: theme,
                                              startHoverTimer: startHoverTimer,
                                              cancelHoverTimer:
                                                  cancelHoverTimer,
                                              switchSession: switchSession,
                                              isSelected:
                                                  asyncSnapshot
                                                      .data![index]
                                                      .id ==
                                                  session?.id,
                                            );
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ),
                          if (widget.width >= 600)
                            Expanded(
                              flex: 8,
                              child: _previewedSession == null
                                  ? Center(
                                      child: Text(
                                        (PlatForm().isMobile)
                                            ? S
                                                  .of(context)
                                                  .swipe_right_to_see_session
                                            : S
                                                  .of(context)
                                                  .hover_to_see_session,
                                        style: TextStyle(
                                          color: theme.thirdGradeColor,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.zeroGradeColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      // ignore: prefer_is_empty
                                      child: (_previewedSession?.length == 0)
                                          ? Center(
                                              child: Text(
                                                S.of(context).no_message,
                                                style: TextStyle(
                                                  color: theme.thirdGradeColor,
                                                ),
                                              ),
                                            )
                                          : SelectionArea(
                                              selectionControls:
                                                  MaterialTextSelectionControls(),
                                              child: ListView.builder(
                                                reverse: true,
                                                itemCount:
                                                    _previewedSession?.length,
                                                itemBuilder: (context, index) {
                                                  final message =
                                                      _previewedSession![index];
                                                  return PersistChatMessage(
                                                    key: ValueKey(message.id),
                                                    message: message,
                                                    theme: theme,
                                                    index: index,
                                                  );
                                                },
                                              ),
                                            ),
                                    ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SessionTile extends StatefulWidget {
  const _SessionTile({
    required this.session,
    required this.theme,
    required this.startHoverTimer,
    required this.cancelHoverTimer,
    required this.switchSession,
    required this.isSelected,
    required this.setPreview,
    required this.onClose,
  });
  final VoidCallback onClose;
  final ChatSession session;
  final bool isSelected;
  final ThemeConfig theme;
  final dynamic startHoverTimer;
  final dynamic cancelHoverTimer;
  final dynamic setPreview;
  final dynamic switchSession;
  @override
  State<_SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends State<_SessionTile> {
  bool displayOptions = false;
  bool displayOverlay = false;

  ThemeConfig get theme => widget.theme;

  @override
  void initState() {
    super.initState();
    if (PlatForm().isMobile) {
      displayOptions = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var listTile = ListTile(
      contentPadding: displayOptions
          ? EdgeInsets.fromLTRB(10, 0, 5, 0)
          : EdgeInsets.fromLTRB(10, 0, 10, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        widget.switchSession(widget.session.id);
        widget.onClose();
      },
      selectedTileColor: widget.theme.primaryColor,
      selectedColor: ColorParser.textColor(
        widget.isSelected
            ? widget.theme.primaryColor
            : widget.theme.secondGradeColor,
      ),
      title: Text(
        widget.session.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        widget.session.creationTime.toString(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: displayOptions
          ? Builder(
              builder: (buttonContext) {
                return IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    final RenderBox button =
                        buttonContext.findRenderObject() as RenderBox;
                    final Offset position = button.localToGlobal(Offset.zero);
                    OverlayPortalService.show(
                      barrierVisible: false,
                      context,
                      autoAvoidSoftKeyboard: false,
                      offset: Offset(
                        MediaQuery.of(context).size.width -
                            button
                                .localToGlobal(
                                  button.size.bottomRight(Offset.zero),
                                )
                                .dx,
                        position.dy + button.size.height,
                      ),
                      child: _buildPopupMenu(widget.session.id),
                    );
                  },
                );
              },
            )
          : null,
      selected: widget.isSelected,
    );

    if (PlatForm().isMobile) {
      return SwipeActionCell(
        backgroundColor: Colors.transparent,
        key: ValueKey(widget.session.id),
        leadingActions: [
          SwipeAction(
            widthSpace: 100,
            performsFirstActionWithFullSwipe: true,
            color: theme.secondGradeColor,
            onTap: (handler) {
              widget.setPreview(widget.session.id);
              handler(false);
            },
            content: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  S.of(context).preview_session,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
        // this material is essential
        // the list tile paints it's bk ground color on it's nearest ancestor material widget in the tree
        // this swipe will transform the location of the list tile , however the bk ground color will not (since the material widget doesn't move)
        // so we need this one here which will move with the list tile instead of a single one under the background
        child: Material(color: Colors.transparent, child: listTile),
      );
    }
    return MouseRegion(
      onEnter: (event) {
        widget.startHoverTimer(widget.session.id);
        if (!displayOptions) {
          setState(() {
            displayOptions = true;
          });
        }
      },
      onExit: (event) {
        if (displayOverlay) {
          return;
        }
        widget.cancelHoverTimer();
        if (displayOptions) {
          setState(() {
            displayOptions = false;
          });
        }
      },
      child: listTile,
    );
  }

  // 5. A helper method to build the content of our custom menu.
  Widget _buildPopupMenu(String sessionId) {
    displayOverlay = true;
    return Material(
      elevation: 4.0,
      color: widget.theme.zeroGradeColor,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: 200, // Set a reasonable width for the menu
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              leading: Icon(Icons.auto_awesome),
              title: Text(S.of(context).generate_title),
              onTap: () {
                OverlayPortalService.hide(context);
                //TODO: rewrite this in order to generate title without leaving the session selector or switching current session
                OverlayPortalService.show(
                  context,
                  child: _confirmAutoGenerateDialog(context, sessionId),
                );
              },
            ),
            ListTile(
              dense: true,
              leading: Icon(Icons.edit),
              title: Text(S.of(context).rename),
              onTap: () {
                OverlayPortalService.hide(context);
                OverlayPortalService.show(
                  context,
                  child: _renameDialog(context, sessionId),
                );
              },
            ),
            ListTile(
              dense: true,
              iconColor: Colors.red,
              textColor: Colors.red,
              leading: Icon(Icons.delete),
              title: Text(S.of(context).delete),
              onTap: () {
                OverlayPortalService.hide(context);
                OverlayPortalService.show(
                  context,
                  child: _confirmDeleteDialog(context, sessionId),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmDeleteDialog(BuildContext context, String sessionId) {
    return SizedBox(
      width: 300,
      height: 200,
      child: Consumer(
        builder: (context, ref, child) {
          return Material(
            color: theme.zeroGradeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        S.of(context).confirm_delete_session,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      StdButton(
                        color: theme.thirdGradeColor,
                        onPressed: () {
                          OverlayPortalService.hide(context);
                        },
                        text: S.of(context).cancel,
                      ),
                      const SizedBox(width: 16),
                      StdButton(
                        color: Colors.red,
                        onLongPress: () {
                          ref
                              .read(chatStateProvider.notifier)
                              .deleteSession(sessionId);
                          OverlayPortalService.hide(context);
                          setState(() {});
                        },
                        text: S.of(context).confirm_long_press,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _confirmAutoGenerateDialog(BuildContext context, String sessionId) {
    return SizedBox(
      width: 300,
      height: 200,
      child: Consumer(
        builder: (context, ref, child) {
          return Material(
            color: theme.zeroGradeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        S.of(context).generate_title_hint,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      StdButton(
                        color: theme.thirdGradeColor,
                        onPressed: () {
                          OverlayPortalService.hide(context);
                        },
                        text: S.of(context).cancel,
                      ),
                      const SizedBox(width: 16),
                      StdButton(
                        color: Colors.red,
                        onLongPress: () async {
                          var n = ref.read(chatStateProvider.notifier);
                          OverlayPortalService.hide(context);
                          await n.switchSession(sessionId);
                          n.generateTitle();
                          setState(() {});
                        },
                        text: S.of(context).confirm_long_press,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _renameDialog(BuildContext context, String sessionId) {
    var controller = TextEditingController();
    return SizedBox(
      width: 300,
      height: 200,
      child: Consumer(
        builder: (context, ref, child) {
          return Material(
            color: theme.zeroGradeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    S.of(context).modify_session_name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  StdTextField(
                    controller: controller,
                    hintText: S.of(context).enter_session_name,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      StdButton(
                        color: theme.thirdGradeColor,
                        onPressed: () {
                          OverlayPortalService.hide(context);
                        },
                        text: S.of(context).cancel,
                      ),
                      const SizedBox(width: 16),
                      StdButton(
                        onPressed: () async {
                          if (controller.text.isNotEmpty) {
                            await DatabaseService.instance.updateSessionTitle(
                              sessionId,
                              controller.text,
                            );
                            if (ref.read(chatStateProvider).session?.id ==
                                sessionId) {
                              ref
                                  .read(chatStateProvider.notifier)
                                  .switchSession(sessionId);
                            } else {
                              ref
                                  .read(chatStateProvider.notifier)
                                  .stateCopyWith();
                            }
                          }
                          if (context.mounted) {
                            OverlayPortalService.hide(context);
                          }
                          setState(() {});
                        },
                        text: S.of(context).confirm,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
