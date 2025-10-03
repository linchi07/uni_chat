import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/Chat/chat_models.dart';
import 'package:uni_chat/Chat/panels/constant_value_indexer.dart';
import 'package:uni_chat/utils/dialog.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';

import '../Agent/agentProvider.dart';
import '../generated/l10n.dart';
import '../theme_manager.dart';
import '../utils/database_service.dart';
import 'chat_message_bubble.dart';
import 'chat_state.dart';

class ChatBannerWidget extends ConsumerStatefulWidget {
  const ChatBannerWidget({super.key});

  @override
  ConsumerState<ChatBannerWidget> createState() => _ChatBannerWidgetState();
}

class _ChatBannerWidgetState extends ConsumerState<ChatBannerWidget> {
  OverlayEntry? _overlayEntry;
  final GlobalKey<_SessionSelectorOverlayState> _overlayKey = GlobalKey();

  void showSessionSelector() {
    final overlay = Overlay.of(context);
    final rb = context.findRenderObject() as RenderBox;
    final pos = rb.localToGlobal(Offset.zero);
    final size = rb.size;
    final screenSize = MediaQuery.of(context).size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          ModalBarrier(color: Colors.transparent, onDismiss: _hide),
          // **修改点**: 不再使用 Positioned 包装，直接放置 Overlay 组件
          // 它将自己负责自己的定位
          SessionSelectorOverlayContainer(
            key: _overlayKey,
            initialSize: size,
            initialPosition: pos,
            initialScreenSize: screenSize,
            onClose: _hide,
          ),
        ],
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _hide() {
    _overlayKey.currentState?.reverseAnimation().then((_) {
      if (_overlayEntry != null) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    var state = ref.watch(chatStateProvider);
    var agent = ref.watch(agentProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StdButton(
          onPressed: () {
            if (_overlayEntry == null) {
              showSessionSelector();
            } else {
              _hide();
            }
          },
          padding: const EdgeInsets.all(6),
          color: theme.secondGradeColor,
          child: Icon(Icons.search, size: 20),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 500,
          child: Material(
            color: theme.secondGradeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {
                if (_overlayEntry == null) {
                  showSessionSelector();
                } else {
                  _hide();
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    Container(width: 1.5, color: Colors.grey[300], height: 20),
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
        curve: Interval(0.6, 1.0, curve: Curves.easeIn),
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
            child: child,
          ),
        );
      },
      child: Material(
        elevation: 4.0,
        color: theme.secondGradeColor,
        borderRadius: BorderRadius.circular(8),
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: OverlayPortalScope(
              child: SessionSelector(onClose: widget.onClose),
            ),
          ),
        ),
      ),
    );
  }
}

class SessionSelector extends ConsumerStatefulWidget {
  const SessionSelector({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  ConsumerState<SessionSelector> createState() => _SessionSelectorState();
}

class _SessionSelectorState extends ConsumerState<SessionSelector> {
  final ScrollController _sessionScrollController = ScrollController();
  final ScrollController _agentScrollController = ScrollController();
  Timer? _hoverTimer;
  (List<ChatMessage>, Map<String, ChatFile>)? _previewedSession;
  bool isSessionScrolled = false;
  late ThemeConfig theme;
  void startHoverTimer(String sid) {
    _hoverTimer = Timer(Duration(milliseconds: 250), () {
      // 在这里实现你想要触发的动作
      _onHoverTimeout(sid);
    });
  }

  void cancelHoverTimer() {
    _hoverTimer?.cancel();
    _hoverTimer = null;
  }

  void _onHoverTimeout(String sid) async {
    var ps = await DatabaseService.instance.getMessagesForSession(sid);
    internalSetState(() {
      _previewedSession = ps;
    });
  }

  void switchSession(String sid) {
    ref.read(chatStateProvider.notifier).switchSession(sid);
  }

  void scrollToSelectedSession(int index) {
    if (!isSessionScrolled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_sessionScrollController.hasClients) {
          return;
        }
        _sessionScrollController.jumpTo(
          (64 * index.toDouble() - 128.0).clamp(0, double.maxFinite),
        );
        //让选中的不在最上面
        isSessionScrolled = true;
      });
    }
  }

  bool isAgentScrolled = false;

  void scrollToSelectedAgent(int index) {
    if (!isSessionScrolled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_agentScrollController.hasClients) {
          return;
        }
        _agentScrollController.jumpTo(
          (48 * index.toDouble() - 96.0).clamp(0, double.maxFinite),
        );
        //让选中的不在最上面
        isAgentScrolled = true;
      });
    }
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Widget _toolbarExpand() {
    return Row(
      children: [
        Expanded(
          child: TextField(
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

  @override
  void initState() {
    super.initState();
    selectedAgentId = ref.read(agentProvider)?.id;
  }

  String? selectedAgentId;

  Future<(List<AgentData>, List<File?>)> getAgentAndAvatars() async {
    var agents = await DatabaseService.instance.getAllAgents();
    var avatars = <File?>[];
    for (int i = 0; i < agents.length; i++) {
      var agent = agents[i];
      var avatar = await agent.getAvatar();
      if (agent.id == selectedAgentId) {
        scrollToSelectedAgent(i);
      }
      avatars.add(avatar);
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
                  flex: 4,
                  //此处是为了防止list tile的背景色溢出
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FutureBuilder(
                      future: getAgentAndAvatars(),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.data == null) {
                          return CircularProgressIndicator();
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
                  flex: 15,
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
                                      future: DatabaseService.instance
                                          .getAllSessionsByAgent(
                                            selectedAgentId!,
                                          ),
                                      builder: (context, asyncSnapshot) {
                                        if (asyncSnapshot.data == null) {
                                          return CircularProgressIndicator();
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
                                              session?.id) {
                                            scrollToSelectedSession(i);
                                          }
                                        }
                                        return ListView.builder(
                                          controller: _sessionScrollController,
                                          itemCount: asyncSnapshot.data!.length,
                                          itemBuilder: (context, index) {
                                            return _SessionTile(
                                              onClose: widget.onClose,
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
                          Expanded(
                            flex: 8,
                            child: _previewedSession == null
                                ? Center(
                                    child: Text(
                                      S.of(context).hover_to_see_session,
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
                                    child: (_previewedSession?.$1.length == 0)
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
                                                  _previewedSession?.$1.length,
                                              itemBuilder: (context, index) {
                                                final message =
                                                    _previewedSession!
                                                        .$1[_previewedSession!
                                                            .$1
                                                            .length -
                                                        1 -
                                                        index];
                                                return PersistChatMessage(
                                                  message: message,
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
    required this.onClose,
  });
  final VoidCallback onClose;
  final ChatSession session;
  final bool isSelected;
  final ThemeConfig theme;
  final dynamic startHoverTimer;
  final dynamic cancelHoverTimer;
  final dynamic switchSession;
  @override
  State<_SessionTile> createState() => _SessionTileState();
}

class _SessionTileState extends State<_SessionTile> {
  bool displayOptions = false;
  bool displayOverlay = false;
  // 1. Controller to show/hide the custom popup menu.
  final _overlayPortalController = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
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
      child: ListTile(
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
                  //gemini 发癫，给劳资整成英文了，但是无所谓了
                  // 2. The OverlayPortal widget. It doesn't display anything on its own.
                  // Its 'child' is the anchor, and its 'overlayChildBuilder' is what's shown.
                  return OverlayPortal(
                    controller: _overlayPortalController,
                    // 3. This builds the actual popup menu when shown.
                    overlayChildBuilder: (BuildContext context) {
                      // We need to calculate the position of the button to place the menu correctly.
                      final RenderBox button =
                          buttonContext.findRenderObject() as RenderBox;
                      final RenderBox overlay =
                          Overlay.of(context).context.findRenderObject()
                              as RenderBox;
                      final Offset position = button.localToGlobal(
                        Offset(0, button.size.height),
                        ancestor: overlay,
                      );

                      return Stack(
                        children: [
                          ModalBarrier(
                            color: Colors.transparent,
                            dismissible: true,
                            onDismiss: () {
                              _hideOverlay();
                            },
                          ),
                          // Background GestureDetector to dismiss the menu when tapping outside.
                          // Position the menu right below the button.
                          Positioned(
                            top: position.dy,
                            // Adjust left/right positioning as needed.
                            // Here, we align the right edge of the menu with the right edge of the tile.
                            right:
                                MediaQuery.of(context).size.width -
                                button
                                    .localToGlobal(
                                      button.size.bottomRight(Offset.zero),
                                      ancestor: overlay,
                                    )
                                    .dx,
                            child: _buildPopupMenu(widget.session.id),
                          ),
                        ],
                      );
                    },
                    // 4. This is the anchor widget, our IconButton.
                    child: IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {
                        // Toggle the visibility of the overlay child.
                        _overlayPortalController.toggle();
                      },
                    ),
                  );
                },
              )
            : null,
        selected: widget.isSelected,
      ),
    );
  }

  void _hideOverlay() {
    displayOptions = false;
    if (displayOverlay) _overlayPortalController.hide();
    displayOverlay = false;
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
        width: 120, // Set a reasonable width for the menu
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              leading: Icon(Icons.edit),
              title: Text(S.of(context).rename),
              onTap: () {
                _hideOverlay();
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
                _hideOverlay();
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

  late ThemeConfig theme;

  Widget _confirmDeleteDialog(BuildContext context, String sessionId) {
    return SizedBox(
      width: 300,
      height: 200,
      child: Consumer(
        builder: (context, ref, child) {
          theme = ref.watch(themeProvider);
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

  Widget _renameDialog(BuildContext context, String sessionId) {
    var controller = TextEditingController();
    return SizedBox(
      width: 300,
      height: 200,
      child: Consumer(
        builder: (context, ref, child) {
          theme = ref.watch(themeProvider);
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
