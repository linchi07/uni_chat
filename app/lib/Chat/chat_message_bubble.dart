import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:uni_chat/Chat/chat_page.dart';
import 'package:uni_chat/Chat/chat_state.dart';
import 'package:uni_chat/error_handling.dart';
import 'package:uni_chat/utils/overlays.dart';
import 'package:uni_chat/utils/paste_and_drop/paste_and_drop.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';

import '../generated/l10n.dart';
import '../theme_manager.dart';
import 'chat_models.dart';

/// A widget that displays a chat message.
/// [prevMessage] is the previous message, used to show variants. **When null,the toolbar will be automatically hidden**
class PersistChatMessage extends ConsumerStatefulWidget {
  const PersistChatMessage({
    super.key,
    required this.message,
    this.prevMessage,
    required this.theme,
    required this.index,
    this.fromBranchData,
    this.toBranchData,
  });
  final int index; //the index in the message list
  final ChatMessage? prevMessage; //the previous message ,used to show variants
  final ChatMessage message;
  final ThemeConfig theme;
  final ({String title, String sessionId})? fromBranchData;
  final List<({String title, String sessionId})>? toBranchData;

  @override
  ConsumerState<PersistChatMessage> createState() => _PersistChatMessageState();
}

class _PersistChatMessageState extends ConsumerState<PersistChatMessage> {
  ChatMessage get message => widget.message;
  ChatMessage? get prevMessage => widget.prevMessage;
  int get index => widget.index;
  ThemeConfig get theme => widget.theme;

  bool isEditMode = false;
  bool get isUserMessage => message.sender == MessageSender.user;

  @override
  Widget build(BuildContext context) {
    final isUserMessage = message.sender == MessageSender.user;
    List<ChatFile> files = message.attachedFiles ?? [];

    List<Widget> branchIndicators = [];
    if (widget.fromBranchData != null) {
      branchIndicators.add(
        _buildBranchIndicator(
          context,
          Icons.source_rounded,
          S.of(context).branched_from(widget.fromBranchData!.title),
          widget.fromBranchData!.sessionId,
        ),
      );
    }
    if (widget.toBranchData != null && widget.toBranchData!.isNotEmpty) {
      for (var branch in widget.toBranchData!) {
        branchIndicators.add(
          _buildBranchIndicator(
            context,
            Icons.call_split_rounded,
            S.of(context).branches(branch.title),
            branch.sessionId,
          ),
        );
      }
    }

    Widget content;
    if (isUserMessage) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (branchIndicators.isNotEmpty) ...branchIndicators,
          if (files.isNotEmpty && !isEditMode) ...[
            Wrap(
              children: [
                for (var file in files)
                  _buildAttachmentView(context, file, widget.theme),
              ],
            ),
          ],
          GptMarkdown(
            message.content,
            useDollarSignsForLatex: true,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ],
      );
      if (isEditMode) {
        /*
        var inputBox = ChatPanelInputBox(
          textInject: (con) {
            con.text = message.content;
          },
          beforeSubmit: () {
            ref.read(chatStateProvider.notifier).addBranch(index);
          },
          afterSubmit: () {

          }
          cancelCallback: () {
            setState(() {
              isEditMode = false;
            });
          },
        );
        */
        //and this must be the stupidest thing i've ever done
        //the binding λ functions requires some objs in this widget to work
        //however, the animation controller's reverse method should be called on cancel callback
        //and it's too inefficient to inject a provider
        //so I just pack them into a obj and pass it to the animation widget
        var functionPT = (
          (con) {
            con.text = message.content;
            if (message.attachedFiles != null &&
                message.attachedFiles!.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(chatStateProvider.notifier)
                    .stateCopyWith(
                      uploadedFilesStash: {
                        for (var file in message.attachedFiles!)
                          file.name: (
                            file: file,
                            status: UploadStatus.uploaded,
                          ),
                      },
                    );
              });
            }
          },
          () {
            ref.read(chatStateProvider.notifier).addBranch(index);
          },
          () async {
            // wait for the next frame (next state)
            await Future.delayed(const Duration(milliseconds: 200));
            var cps = chatPanel.currentState;
            if (cps != null) {
              cps.autoScroll = true;
              cps.autoScrollFunc();
            }
          },
          () {
            var cs = chatPanel.currentState;
            if (cs != null && !cs.showInputBox) {
              cs.showInputBox = true;
              cs.setState(() {});
            }
            setState(() {
              isEditMode = false;
            });
            if (message.attachedFiles != null &&
                message.attachedFiles!.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref
                    .read(chatStateProvider.notifier)
                    .stateCopyWith(uploadedFilesStash: {});
              });
            }
          },
        );
        var box = Align(
          alignment: Alignment.centerRight,
          child: _InputExpandAnimation(
            originContentText: message.content,
            registeredFunctions: functionPT,
            theme: theme,
            originContent: content,
          ),
        );
        return box;
      }
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (branchIndicators.isNotEmpty) ...branchIndicators,
          if (widget.prevMessage != null) _toolbar(),
          if (files.isNotEmpty) ...[
            Wrap(
              children: [
                for (var file in files)
                  _buildAttachmentView(context, file, widget.theme),
              ],
            ),
          ],
          if (widget.message.content.isEmpty)
            Text(
              S.of(context).message_no_content,
              style: TextStyle(
                color: theme.warningColor.withAlpha(180),
                fontSize: 16,
              ),
            ),
          ..._buildMessageBody(),
        ],
      );
    }
    var box = Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: isUserMessage
            ? BoxConstraints(
                maxWidth: min(
                  MediaQuery.of(context).size.width * 0.8,
                  1000 * 0.9,
                ),
              )
            : null,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUserMessage ? widget.theme.thirdGradeColor : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: content,
      ),
    );
    if (isUserMessage && widget.prevMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          box,
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _toolbar(),
          ),
        ],
      );
    }
    return box;
  }

  Widget _buildBranchIndicator(
    BuildContext context,
    IconData icon,
    String text,
    String sessionId,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: widget.theme.primaryColor.withAlpha(200)),
          const SizedBox(width: 4),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              ref.read(chatStateProvider.notifier).switchSession(sessionId);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.theme.primaryColor.withAlpha(200),
                  fontStyle: FontStyle.italic,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget typeMatch(MessageBlock block) {
    switch (block.chunkType) {
      case MessageChunkType.text:
        return _TextBlock(
          color: widget.theme.darkTextColor,
          content: block.content,
        );
      case MessageChunkType.image:
        throw UnimplementedError();
      case MessageChunkType.reasoning:
        return _ReasonBlock(content: block.content, isComplete: true);
      case MessageChunkType.functionCalling:
        throw UnimplementedError();
      case MessageChunkType.error:
        return _ErrorBlock(theme: widget.theme, content: block.content);
    }
  }

  List<Widget> _buildMessageBody() {
    var wm = widget.message;
    if (wm.data?.containsKey("msg_blocks") ?? false) {
      var w = <Widget>[];
      try {
        List<MessageBlock> d = ((wm.data!["msg_blocks"])
            .map<MessageBlock>((e) => MessageBlock.fromMap(e))
            .toList());
        int pt = 0;
        for (var i in d) {
          var s = wm.content.substring(pt, i.anchor);
          if (s.isNotEmpty) {
            w.add(_TextBlock(content: s, color: theme.darkTextColor));
          }
          w.add(typeMatch(i));
          pt = i.anchor;
        }
        if (pt < wm.content.length) {
          w.add(
            _TextBlock(
              content: wm.content.substring(pt),
              color: theme.darkTextColor,
            ),
          );
        }
      } on Exception catch (e) {
        w.add(
          _ErrorBlock(
            content: (e is AppException)
                ? e.unwrapAndGetMessage(context)
                : ChatException(
                    ChatExceptionType.failParsingMessage,
                  ).unwrapAndGetMessage(context),
            theme: theme,
          ),
        );
      }
      return w;
    } else {
      return [_TextBlock(content: wm.content, color: theme.darkTextColor)];
    }
  }

  bool isCopied = false;
  Widget _toolbar() {
    return SizedBox(
      height: 30,
      child: Material(
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUserMessage)
              SizedBox(
                height: 30,
                width: 24,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    if (MediaQuery.of(context).size.height <= 700) {
                      var cs = chatPanel.currentState;
                      cs?.showInputBox = false;
                      cs?.setState(() {});
                    }
                    setState(() {
                      isEditMode = true;
                    });
                  },
                  child: Icon(Icons.edit_outlined, size: 20),
                ),
              ),
            SizedBox(
              height: 30,
              width: 24,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  _showBranchDialog(context);
                },
                child: Icon(Icons.fork_right_rounded, size: 20),
              ),
            ),
            SizedBox(
              height: 30,
              width: 24,
              child: StatefulBuilder(
                builder: (context, setState) {
                  if (isCopied) {
                    Timer(Duration(seconds: 1), () {
                      if (context.mounted) {
                        setState(() {
                          isCopied = false;
                        });
                      }
                    });
                  }
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      var d = [
                        NativeDataWriterItem()..addText(message.content),
                      ];
                      await NativeClipboard.write(d);
                      setState(() {
                        isCopied = true;
                      });
                    },
                    child: isCopied
                        ? Icon(Icons.check, size: 20)
                        : Icon(Icons.copy_rounded, size: 20),
                  );
                },
              ),
            ),
            if (message.sender ==
                MessageSender.ai) //we can only regenerate ai message
              SizedBox(
                height: 30,
                width: 24,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    ref
                        .read(chatStateProvider.notifier)
                        .regenerateMessage(index);
                    // wait for the next frame
                    await Future.delayed(const Duration(milliseconds: 200));
                    var cps = chatPanel.currentState;
                    if (cps != null) {
                      cps.autoScroll = true;
                      cps.autoScrollFunc();
                    }
                  },
                  child: Icon(Icons.refresh, size: 20),
                ),
              ),
            if (prevMessage!.childIds.length > 1) ...variantSelector(),
          ],
        ),
      ),
    );
  }

  List<Widget> variantSelector() {
    var prevMessage = this.prevMessage!;
    return [
      SizedBox(
        height: 30,
        width: 24,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: (prevMessage.enabledChild != 0)
              ? () {
                  ref
                      .read(chatStateProvider.notifier)
                      .switchBranch(index, prevMessage.enabledChild - 1);
                }
              : null,
          //the arrows are smaller than the other buttons
          // however only when they're smaller that they visually align with the buttons:(
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: (prevMessage.enabledChild != 0)
                ? theme.primaryColor
                : theme.thirdGradeColor,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        child: SelectionContainer.disabled(
          // this is to prevent the text from being selectable
          child: Text(
            ///actually , since this is actually a tree.
            ///we switch the child of child ids list in the prev message,not the current message.
            '${prevMessage.enabledChild + 1} / ${prevMessage.childIds.length}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      SizedBox(
        height: 30,
        width: 24,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: (prevMessage.enabledChild != prevMessage.childIds.length - 1)
              ? () {
                  ref
                      .read(chatStateProvider.notifier)
                      .switchBranch(index, prevMessage.enabledChild + 1);
                }
              : null,
          child: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: (prevMessage.enabledChild != prevMessage.childIds.length - 1)
                ? theme.primaryColor
                : theme.thirdGradeColor,
          ),
        ),
      ),
    ];
  }

  void _showBranchDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: '${ref.read(chatStateProvider).session?.name ?? 'Chat'} - Branch',
    );
    OverlayPortalService.showDialog(
      width: 400,
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(S.of(context).branch_from_here, style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          StdTextFieldOutlined(controller: controller, maxLines: 2),
        ],
      ),
      actions: [
        StdButton(
          onPressed: () => OverlayPortalService.hide(context),
          child: Text(S.of(context).cancel),
        ),
        const SizedBox(width: 8),
        StdButton(
          onPressed: () async {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              await OverlayPortalService.hide(context);
              ref
                  .read(chatStateProvider.notifier)
                  .branchSession(message.messageId ?? "", name);
            }
          },
          child: Text(S.of(context).branch_confirm),
        ),
      ],
      backGroundColor: theme.zeroGradeColor,
    );
  }

  Widget _buildAttachmentView(
    BuildContext context,
    ChatFile file,
    ThemeConfig theme,
  ) {
    final isImage = file.type == FileTypeDefine.image;

    return Padding(
      padding: (isImage)
          ? const EdgeInsets.fromLTRB(8, 0, 8, 8)
          : const EdgeInsets.only(bottom: 8.0),
      child: isImage
          ? Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              height: 100,
              child: FutureBuilder<File>(
                future: file.getFile(), // 假设这是您的异步方法
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return Image.file(snapshot.data!, fit: BoxFit.cover);
                  } else if (snapshot.hasError) {
                    return Icon(Icons.error_outline, color: theme.errorColor);
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            )
          : Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              height: 50,
              width: 130,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FileIcon(
                    color:
                        Language.getLanguage(file.extension)?.color ??
                        theme.brightTextColor,
                    extension: file.extension,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        file.originalName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.brightTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _InputExpandAnimation extends StatefulWidget {
  const _InputExpandAnimation({
    super.key,
    required this.registeredFunctions,
    required this.theme,
    required this.originContent,
    required this.originContentText,
  });
  final dynamic registeredFunctions;
  final ThemeConfig theme;
  final Widget originContent;
  final String originContentText;

  @override
  State<_InputExpandAnimation> createState() => _InputExpandAnimationState();
}

class _InputExpandAnimationState extends State<_InputExpandAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> shadowTween;
  late Animation<double> sizeTween;
  late Animation<double> colorTween;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );
    shadowTween = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 1.0, curve: Curves.linear),
      ),
    );
    colorTween = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.7, curve: Curves.easeIn),
      ),
    );
    sizeTween = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
        reverseCurve: const Interval(0.0, 0.8, curve: Curves.linear),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const double INPUT_BOX_EXPANDED_HEIGHT = 283;
  static const double INPUT_BOX_COLLAPSED_HEIGHT = 120;
  (double?, double?) lerpSize(double t) {
    if (_startSize != null) {
      return (
        lerpDouble(_startSize!.width, targetW, t),
        lerpDouble(_startSize!.height, targetH, t),
      );
    }
    return (null, null);
  }

  late double targetW;
  late double targetH;
  Size? _startSize;
  @override
  Widget build(BuildContext context) {
    targetW = min(MediaQuery.of(context).size.width * 0.8, 1000 * 0.9);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_startSize == null) {
        final renderBox = context.findRenderObject() as RenderBox;
        // calc the text size in the input box
        var tp = TextPainter(
          text: TextSpan(
            text: widget.originContentText,
            style: Theme.of(context).primaryTextTheme.bodyLarge,
          ),
          textDirection: TextDirection.ltr,
          maxLines: null,
        );
        tp.layout(
          maxWidth: renderBox.size.width - 18,
        ); // minus left and right padding
        targetH = (tp.height + 70).clamp(
          //36 is the toolbar height
          INPUT_BOX_COLLAPSED_HEIGHT,
          INPUT_BOX_EXPANDED_HEIGHT - 18,
        );
        // 70 and 18 are just magic numbers that makes the animation smooth
        // I have no idea why it works
        _startSize = renderBox.size;
        _controller.forward();
      }
    });
    var w = MediaQuery.of(context).size.width * 0.8;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double t = _controller.value; // 0.0 -> 1.0

        // 1. 阴影插值 (从无到有，实现浮起感)
        final shadow = BoxShadow.lerp(
          const BoxShadow(
            color: Colors.transparent,
            blurRadius: 0,
            offset: Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(80),
            spreadRadius: 5,
            blurRadius: 8,
            offset: const Offset(3, 6),
          ),
          shadowTween.value,
        );
        var s = lerpSize(sizeTween.value);
        var vertical = max(lerpDouble(5, 0, sizeTween.value)!, 0).toDouble();
        var left = max(lerpDouble(5, 0, sizeTween.value)!, 0).toDouble();
        var right = max(lerpDouble(8, 14, sizeTween.value)!, 0).toDouble();
        var paddingOther = max(
          lerpDouble(12, 16, sizeTween.value)!, // 12 -> 12 + 4
          0,
        ).toDouble();
        var paddingBottom = max(
          lerpDouble(12, 38, sizeTween.value)!, // 36 is 12 + bottom toolbar
          0,
        ).toDouble();
        return Container(
          width: s.$1,
          height: (t >= 0.8) ? null : s.$2,
          margin: EdgeInsets.fromLTRB(left, vertical, right, vertical),
          padding: (t >= 0.8)
              ? const EdgeInsets.all(4)
              : EdgeInsets.fromLTRB(
                  paddingOther,
                  paddingOther,
                  paddingOther,
                  paddingBottom,
                ),
          constraints: (t >= 0.8)
              ? BoxConstraints.loose(Size(targetW, INPUT_BOX_EXPANDED_HEIGHT))
              : (t == 0)
              ? BoxConstraints(maxWidth: min(w, 1000 * 0.9))
              : null,
          decoration: BoxDecoration(
            color: Color.lerp(
              widget.theme.thirdGradeColor,
              widget.theme.zeroGradeColor,
              colorTween.value,
            ),
            boxShadow: [?shadow],
            borderRadius: BorderRadius.circular(8),
          ),
          child: (t >= 0.8)
              ? ChatPanelInputBox(
                  textInject: widget.registeredFunctions.$1,
                  beforeSubmit: widget.registeredFunctions.$2,
                  afterSubmit: widget.registeredFunctions.$3,
                  cancelCallback: () async {
                    await _controller.reverse();
                    widget.registeredFunctions.$4.call();
                  },
                )
              : ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  child: widget.originContent,
                ),
        );
      },
    );
  }
}

class ChatMessageDynamicStream extends StatefulWidget {
  const ChatMessageDynamicStream({
    super.key,
    required this.responses,
    required this.theme,
  });
  final ValueListenable<List<ChatResponse>?> responses;
  final ThemeConfig theme;
  @override
  State<ChatMessageDynamicStream> createState() =>
      _ChatMessageDynamicStreamState();
}

class _ChatMessageDynamicStreamState extends State<ChatMessageDynamicStream> {
  Timer? _timer; // 添加定时器
  bool _isAnimating = false; // 添加动画状态标志
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel(); // 清理定时器
    super.dispose();
  }

  int displayedLength = 0;
  int currentlyAnimating = 0;
  int charDisplayed = 0;

  void updateDisplayed(List<ChatResponse> r) {
    MessageChunkType? lastType;
    for (var i = r.length - 1; i > currentlyAnimating; i--) {
      if (lastType != r[i].type ||
          !(r[i].type == MessageChunkType.text ||
              r[i].type == MessageChunkType.reasoning)) {
        if (i + 1 < r.length) {
          displayedLength = i + 1;
          currentlyAnimating = i + 1;
          charDisplayed = 0;
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: ValueListenableBuilder(
          valueListenable: widget.responses,
          builder: (context, value, child) {
            if (value == null || value.isEmpty) {
              return _Loading(color: widget.theme.primaryColor);
            }
            updateDisplayed(value);
            var l = value.sublist(0, displayedLength);
            List<Widget> blocksDisplayed = [];
            for (int i = 0; i < l.length; i++) {
              blocksDisplayed.add(typeMatch(l[i], i));
            }
            return StatefulBuilder(
              builder: (context, setState) {
                if (!_isAnimating &&
                    (value.length >= currentlyAnimating ||
                        value[currentlyAnimating].content.length >
                            charDisplayed)) {
                  //此处的set state只会激活 StatefulBuilder中的setState
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    enableAnimation(setState);
                  });
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [...blocksDisplayed, ...blocksToDisplay],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget typeMatch(ChatResponse response, int order) {
    switch (response.type) {
      case MessageChunkType.text:
        return _TextBlock(
          key: ValueKey(order),
          color: widget.theme.darkTextColor,
          content: response.content,
        );
      case MessageChunkType.image:
        throw UnimplementedError();
      case MessageChunkType.reasoning:
        return _ReasonBlock(
          key: ValueKey(order),
          content: response.content,
          isComplete: true,
        );
      case MessageChunkType.functionCalling:
        throw UnimplementedError();
      case MessageChunkType.error:
        return _ErrorBlock(
          key: ValueKey(order),
          theme: widget.theme,
          content: response.content,
        );
    }
  }

  List<Widget> blocksDisplayed = [];
  List<Widget> blocksToDisplay = [];

  void enableAnimation(dynamic setState) {
    const charactersPerSecond = 80; // 每秒字符数
    _isAnimating = true;
    // 每秒刷新 charactersPerSecond 次，每次只添加一个字符
    const interval = Duration(milliseconds: 1000 ~/ charactersPerSecond);
    _timer = Timer.periodic(interval, (timer) {
      blocksToDisplay.clear();
      setState(() {
        var rv = widget.responses.value!;
        if (currentlyAnimating >= rv.length) {
          // 显示完成，停止定时器
          _timer?.cancel();
          _isAnimating = false;
          return;
        }
        var cr = rv[currentlyAnimating];
        if (charDisplayed < cr.content.length) {
          if (cr.type == MessageChunkType.text) {
            blocksToDisplay.add(
              _TextBlock(
                key: ValueKey(currentlyAnimating),
                color: widget.theme.darkTextColor,
                content: "${cr.content.substring(0, charDisplayed)}▍",
              ),
            );
          } else if (cr.type == MessageChunkType.reasoning) {
            blocksToDisplay.add(
              _ReasonBlock(
                key: ValueKey(currentlyAnimating),
                content: "${cr.content.substring(0, charDisplayed)}▍",
                isComplete: false,
              ),
            );
          }
          charDisplayed++;
        } else if (currentlyAnimating == rv.length - 1) {
          if (cr.type == MessageChunkType.text) {
            blocksToDisplay.add(
              _TextBlock(
                color: widget.theme.darkTextColor,
                content: "${cr.content.substring(0, charDisplayed)}▍",
              ),
            );
          } else if (cr.type == MessageChunkType.reasoning) {
            blocksToDisplay.add(
              _ReasonBlock(
                key: ValueKey(currentlyAnimating),
                content: "${cr.content.substring(0, charDisplayed)}▍",
                isComplete: false,
              ),
            );
          }
        } else if (currentlyAnimating < rv.length - 1) {
          displayedLength++;
          charDisplayed = 0;
          currentlyAnimating++;
        }
      });
    });
  }
}

class _Loading extends StatelessWidget {
  const _Loading({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(color: color),
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({super.key, required this.content, required this.color});
  final String content;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return GptMarkdown(
      content,
      useDollarSignsForLatex: true,
      style: const TextStyle(color: Colors.black, fontSize: 16),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({super.key, required this.content, required this.theme});
  final String content;
  final ThemeConfig theme;
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: theme.errorColor.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: theme.errorColor),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              S.of(context).error_occurred_with_error(content),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonBlock extends ConsumerStatefulWidget {
  const _ReasonBlock({super.key, required this.isComplete, this.content});
  final bool isComplete;
  final String? content;

  @override
  ConsumerState<_ReasonBlock> createState() => _ReasonBlockState();
}

class _ReasonBlockState extends ConsumerState<_ReasonBlock>
    with SingleTickerProviderStateMixin {
  bool isTimerSet = false;
  bool isShowing = false;
  bool isDisposed = false;
  bool animatedDirection = true;
  late AnimationController _animationController;
  late Animation<double> _opacity;
  dynamic listener;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    listener = (status) {
      if (widget.isComplete && !isDisposed && animatedDirection) {
        _animationController.removeStatusListener(listener);
      }
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!isDisposed) {
            if (animatedDirection) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
            animatedDirection = !animatedDirection;
          }
        });
      }
    };
    _animationController.addStatusListener(listener);
    _animationController.forward();
  }

  @override
  void dispose() {
    isDisposed = true;
    _animationController.removeStatusListener(listener);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    final card = Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            spreadRadius: 2,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
        color: theme.zeroGradeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Shimmer(
        enabled: !widget.isComplete,
        duration: const Duration(seconds: 3),
        interval: const Duration(seconds: 0),
        colorOpacity: 0.8,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _opacity,
                builder: (context, child) {
                  return Opacity(opacity: _opacity.value, child: child!);
                },
                child: Icon(
                  widget.isComplete
                      ? Icons.check_circle
                      : Icons.lightbulb_outline,
                  color: widget.isComplete ? Colors.green : theme.darkTextColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.isComplete
                    ? S.of(context).reasoned
                    : S.of(context).reasoning,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.darkTextColor,
                ),
              ),
              const SizedBox(width: 10),
              if (widget.isComplete)
                TextButton(
                  onPressed: () {
                    setState(() {
                      isShowing = !isShowing;
                    });
                  },
                  child: Text(
                    isShowing ? S.of(context).hide_cot : S.of(context).show_cot,
                  ),
                ),
              if (!widget.isComplete) const SizedBox(width: 12),
              if (!widget.isComplete)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        card,
        if (isShowing && widget.isComplete) ...[
          const SizedBox(height: 8),
          _buildSourceCodeView(widget.content),
        ],
      ],
    );
  }

  Widget _buildSourceCodeView(String? source) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: GptMarkdown(
        source ?? '',
        style: const TextStyle(color: Colors.black, fontSize: 14),
      ),
    );
  }
}

class _RagBlock extends StatefulWidget {
  const _RagBlock({super.key, required this.isComplete, this.content});
  final bool isComplete;
  final String? content;
  @override
  State<_RagBlock> createState() => _RagBlockState();
}

class _RagBlockState extends State<_RagBlock>
    with SingleTickerProviderStateMixin {
  bool animatedDirection = true;
  bool isShowing = false;
  late AnimationController _animationController;
  late Animation<double> _opacity;
  dynamic listener;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    listener = (status) {
      if (widget.isComplete && animatedDirection) {
        _animationController.removeStatusListener(listener);
      }
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        if (animatedDirection) {
          Future.delayed(
            const Duration(milliseconds: 500),
            () => _animationController.reverse(),
          );
          animatedDirection = !animatedDirection;
        } else {
          Future.delayed(
            const Duration(milliseconds: 500),
            () => _animationController.forward(),
          );
          animatedDirection = !animatedDirection;
        }
      }
    };
    _animationController.addStatusListener(listener);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(listener);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Shimmer(
        enabled: !widget.isComplete,
        duration: const Duration(seconds: 3),
        interval: const Duration(seconds: 0),
        colorOpacity: 0.8,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _opacity,
                builder: (context, child) {
                  return Opacity(opacity: _opacity.value, child: child!);
                },
                child: Icon(
                  widget.isComplete ? Icons.check_circle : Icons.search,
                  color: widget.isComplete
                      ? Colors.green
                      : Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  widget.isComplete
                      ? S.of(context).searched_knowledge_base
                      : S.of(context).searching_knowledge_base,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (widget.isComplete)
                TextButton(
                  onPressed: () {
                    setState(() {
                      isShowing = !isShowing;
                    });
                  },
                  child: Text(
                    isShowing
                        ? S.of(context).hide_knowledge_base_results
                        : S.of(context).show_knowledge_base_results,
                  ),
                ),
              if (!widget.isComplete) const SizedBox(width: 12),
              if (!widget.isComplete)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        card,
        if (isShowing && widget.isComplete) ...[
          const SizedBox(height: 8),
          _buildSourceCodeView(widget.content),
        ],
      ],
    );
  }

  Widget _buildSourceCodeView(String? source) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: GptMarkdown(
        source ?? '',
        style: const TextStyle(color: Colors.black, fontSize: 14),
      ),
    );
  }
}
