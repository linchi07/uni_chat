import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:uni_chat/Chat/chat_models.dart';
import 'package:uni_chat/Chat/chat_state.dart';
import 'package:uni_chat/main.dart';

import '../theme_manager.dart';

const double GAP = 10; // gap between lines
const double LENGTH = 10; // line length
const double DENSE_LINE_LENGTH = 5;
const double MAX_INTERVAL_LENGTH = 25; // max interval line length
const double MAX_DENSE_INTERVAL_LENGTH = 11;
const double HIGHLIGHT_LENGTH = 35; // highlight line length
const double MAX_DENSE_HIGHLIGHT_LENGTH = 15;
const double DELTA =
    (MAX_INTERVAL_LENGTH - LENGTH) /
    INTERVAL_ITEM_COUNT; // the change of line length in interval
const double DENSE_DELTA =
    (MAX_DENSE_INTERVAL_LENGTH - DENSE_LINE_LENGTH) / INTERVAL_ITEM_COUNT;
const double INTERVAL_ITEM_COUNT = 4; // number of lines to show in interval
const int ANIM_SPEED = 10; // animation speed

class ChatSidebar extends ConsumerStatefulWidget {
  const ChatSidebar({
    super.key,
    required this.currentActiveIndex,
    required this.msgListener,
    required this.selectedIndex,
    this.isDense = false,
  });
  final bool isDense;
  final ValueNotifier<int> currentActiveIndex;
  final ValueNotifier<({ChatMessage? message, Offset? pointerLoc})> msgListener;
  final ValueNotifier<int?> selectedIndex;

  /// get the full height of the sidebar (elements outside the viewport of the scroll is included)
  static double getHeight(int itemCount) {
    return itemCount * GAP;
  }

  /// return the width of the sidebar
  static double get actualWidth => HIGHLIGHT_LENGTH;

  @override
  ConsumerState<ChatSidebar> createState() => _ChatSidebarState();
}

class _ChatSidebarState extends ConsumerState<ChatSidebar>
    with SingleTickerProviderStateMixin {
  ///this is actually a state machine
  /// [targetLineLength] is the length of lines should be
  /// [currentLineLength] is the actual length of lines
  /// what we do is to change [currentLineLength] gradually until it matches [targetLineLength]
  /// and that forms an amazing  animation :D
  /// to avoid the costs of set state we use a [repaint] to notify the custom paint directly
  // PS：实际上这个状态机的灵感来源于Kubernetes的面向终态的设计->我们只关心如何把list变成我们想要的样子，而不是去管他应该如何变
  //TODO: optimize the list regeneration process (currently it recalculates the whole list every time)
  final ScrollController controller = ScrollController();
  late List<double> currentLineLength = [];
  late List<double> targetLineLength;
  late final Ticker _ticker;

  double get delta => (widget.isDense) ? DENSE_DELTA : DELTA;
  double get maxLength =>
      (widget.isDense) ? MAX_DENSE_INTERVAL_LENGTH : MAX_INTERVAL_LENGTH;
  double get length => (widget.isDense) ? DENSE_LINE_LENGTH : LENGTH;
  double get highlightLength =>
      (widget.isDense) ? MAX_DENSE_HIGHLIGHT_LENGTH : HIGHLIGHT_LENGTH;
  double get maxIntervalLength =>
      (widget.isDense) ? MAX_DENSE_INTERVAL_LENGTH : MAX_INTERVAL_LENGTH;
  ValueNotifier<({bool trigger, int? highlightIndex, int activeIndex})>
  repaint = ValueNotifier((
    trigger: false,
    highlightIndex: null,
    activeIndex: 0,
  ));

  void calcTargetLineLength(int activeIndex) {
    var startIdx = max(0, activeIndex - INTERVAL_ITEM_COUNT);
    var endIdx = min(
      targetLineLength.length - 1,
      activeIndex + INTERVAL_ITEM_COUNT,
    );
    var lastLength = length;
    for (int i = 0; i < targetLineLength.length; i++) {
      if (i >= startIdx && i <= endIdx) {
        if (i == activeIndex) {
          targetLineLength[i] = highlightLength;
          lastLength = maxIntervalLength;
          continue;
        }
        if (i > activeIndex && i < endIdx) {
          lastLength = max(lastLength - delta, length);
          targetLineLength[i] = lastLength;
          continue;
        }
        if (i > startIdx && i < activeIndex) {
          lastLength = min(lastLength + delta, maxIntervalLength);
          targetLineLength[i] = lastLength;
          continue;
        }
      }
      targetLineLength[i] = length;
    }
  }

  late bool enableHaptic;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    activeIndex = widget.currentActiveIndex.value;
    widget.currentActiveIndex.addListener(() async {
      if (activeIndex == widget.currentActiveIndex.value) {
        return;
      }
      activeIndex = widget.currentActiveIndex.value;
      //we run the tick only if the index stays the same in 100ms, in order to avoid jitter and flash
      await Future.delayed(const Duration(milliseconds: 100));
      if (activeIndex == widget.currentActiveIndex.value) {
        calcTargetLineLength(activeIndex);
        if (!_ticker.isActive) _ticker.start();
      }
    });
    var l = ref.read(chatStateProvider).messagesList.length - 1;
    targetLineLength = List.generate(l, (index) => length);
    currentLineLength = List.generate(l, (index) => length);
    enableHaptic = PlatForm().enableHaptic;
  }

  Duration? _last;

  void _onTick(Duration elapsed) {
    final dt = _last == null ? 0.0 : (elapsed - _last!).inMicroseconds / 1e6;
    _last = elapsed;
    var r = closeInOnTarget(dt);
    if (r) {
      _ticker.stop();
    }
    repaint.value = (
      trigger: !repaint.value.trigger,
      highlightIndex: highlightIndex,
      activeIndex: activeIndex,
    );
  }

  int? highlightIndex;
  @override
  void didUpdateWidget(covariant ChatSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDense != oldWidget.isDense) {
      //auto change the density
      calcTargetLineLength(widget.currentActiveIndex.value);
      if (!_ticker.isActive) _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  bool closeInOnTarget(double dt) {
    bool flag = true;
    if (currentLineLength.length > targetLineLength.length) {
      currentLineLength = currentLineLength.sublist(0, targetLineLength.length);
      flag = false;
    }
    if (currentLineLength.length < targetLineLength.length) {
      currentLineLength.addAll(
        List.generate(
          targetLineLength.length - currentLineLength.length,
          (index) => length,
        ),
      );
      flag = false;
    }
    for (int i = 0; i < targetLineLength.length; i++) {
      if (currentLineLength[i] != targetLineLength[i]) {
        var delta = targetLineLength[i] - currentLineLength[i];
        if (delta.abs() < 0.05) {
          currentLineLength[i] = targetLineLength[i];
          continue;
        }
        currentLineLength[i] += (delta * ANIM_SPEED) * dt;
        currentLineLength[i] = currentLineLength[i].clamp(
          length,
          highlightLength,
        );
        flag = false;
      }
    }
    return flag;
  }

  late int activeIndex;

  Offset? _pointerPos;

  int? oldIndex;
  // identify if index changes

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    ref.listen(chatStateProvider, (prev, next) {
      if (next.messagesList.length != targetLineLength.length) {
        targetLineLength = List.generate(
          max(
            0,
            next.messagesList.length - 1,
          ), // sometimes the list will give a -1 ,so we need to avoid it
          (index) => length,
        );
        calcTargetLineLength(activeIndex);
        if (!_ticker.isActive) _ticker.start();
      }
    });
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent, // 顶部起始点透明
            Colors.black, // 很快变为不透明
            Colors.black, // 中间保持不透明
            Colors.transparent, // 底部结束点透明
          ],
          stops: [0.0, 0.05, 0.95, 1.0], // 控制淡出的范围（5% 的边缘）
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: GestureDetector(
        onTapDown: (details) {
          _pointerPos = details.localPosition;
        },
        onTap: () {
          if (_pointerPos != null) {
            var index = ((_pointerPos!.dy + controller.offset - 20) / (GAP))
                .floor();
            if (index >= 0) {
              widget.selectedIndex.value = index + 1;
            }
          }
          _pointerPos = null;
        },
        onPanUpdate: (details) {
          var index =
              ((details.localPosition.dy + controller.offset - 20) / (GAP))
                  .floor();
          if (index >= 0) {
            widget.selectedIndex.value = index + 1;
          }
        },
        child: MouseRegion(
          onHover: (event) {
            var index =
                ((event.localPosition.dy + controller.offset - 20) / (GAP))
                    .floor();
            if (index >= 0) {
              calcTargetLineLength(index);
              highlightIndex = index;
              var ml = ref.read(chatStateProvider).messagesList;
              widget.msgListener.value = (
                message:
                    ml[(index + 1).clamp(
                      1,
                      ml.length - 1,
                    )], //the 0 index is the root message which is hidden
                pointerLoc: event.position,
              );
              if (!_ticker.isActive) _ticker.start();
            }
          },
          onExit: (event) {
            calcTargetLineLength(activeIndex);
            highlightIndex = null;
            widget.msgListener.value = (message: null, pointerLoc: null);
            if (!_ticker.isActive) _ticker.start();
          },
          child: SingleChildScrollView(
            controller: controller,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CustomPaint(
                size: Size(40, ChatSidebar.getHeight(currentLineLength.length)),
                painter: SidebarPainter(
                  repaint: repaint,
                  lines: currentLineLength,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SidebarPainter extends CustomPainter {
  final List<double> lines;
  final ValueNotifier<({bool trigger, int? highlightIndex, int activeIndex})>
  repaint;
  final Color color;

  SidebarPainter({
    required this.lines,
    required this.color,
    required this.repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0
      ..color = color;
    final activePaint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;
    var Xstart = size.width - 5;
    for (int i = 0; i < lines.length; i++) {
      final lineLength = lines[i];
      final lineStart = Offset(Xstart, i * GAP);
      final lineEnd = Offset(Xstart - lineLength, i * GAP);
      canvas.drawLine(
        lineStart,
        lineEnd,
        (i == repaint.value.activeIndex || i == repaint.value.highlightIndex)
            ? activePaint
            : paint,
      );
    }
  }

  @override
  bool shouldRepaint(SidebarPainter old) => true;
}

class BarChatMessagePreview extends StatefulWidget {
  const BarChatMessagePreview({
    super.key,
    required this.messageInfo,
    required this.theme,
  });
  final ValueNotifier<({ChatMessage? message, Offset? pointerLoc})> messageInfo;
  final ThemeConfig theme;

  @override
  State<BarChatMessagePreview> createState() => _BarChatMessagePreviewState();
}

class _BarChatMessagePreviewState extends State<BarChatMessagePreview> {
  @override
  void initState() {
    super.initState();
    widget.messageInfo.addListener(() {
      var val = widget.messageInfo.value;
      if (val.message == null && message != null) {
        if (isMouseIn) {
          return;
        }
        message = null;
        setState(() {});
      }
      if (val.message == message || val.pointerLoc == null) return;
      message = val.message;
      calcDisplayLoc(val.pointerLoc!);
      setState(() {});
    });
  }

  static TextStyle textStyle = TextStyle(color: Colors.black);

  void calcDisplayLoc(Offset pointerLoc) {
    var rb = context.findRenderObject() as RenderBox;
    var pointerY = rb.globalToLocal(pointerLoc).dy;
    var tp = TextPainter(
      text: TextSpan(text: message?.content, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    tp.layout(maxWidth: 300 - 20);
    var height = tp.height + 50;
    var leftSpace = (rb.size.height - pointerY) - height / 2;
    if (leftSpace >= 0) {
      displayLocYOffset = pointerY - height / 2;
      boxHeight = height;
    } else if (leftSpace < 0) {
      displayLocYOffset = 0;
      boxHeight = null;
    }
  }

  bool isMouseIn = false;
  double? displayLocYOffset;
  double? boxHeight;
  ChatMessage? message;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      bottom: 10,
      right: ChatSidebar.actualWidth - 5,
      width: 320,
      child: (message != null)
          ? Align(
              alignment: Alignment.topCenter,
              child: Transform.translate(
                offset: Offset(0, displayLocYOffset ?? 0),
                child: SizedBox(
                  height: boxHeight,
                  width: 320,
                  child: MouseRegion(
                    onHover: (event) {
                      isMouseIn = true;
                    },
                    onExit: (event) {
                      isMouseIn = false;
                      if (widget.messageInfo.value.message == null) {
                        setState(() {
                          message = null;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: Material(
                        color: widget.theme.zeroGradeColor,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 25,
                            horizontal: 10,
                          ),
                          child: SingleChildScrollView(
                            child: GptMarkdown(
                              message!.content,
                              style: textStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : SizedBox.shrink(),
    );
  }
}
