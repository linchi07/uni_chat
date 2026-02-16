import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SplitViewController {
  SplitViewController({this.onPop, this.defaultRight, this.onStatusChange});
  final VoidCallback? onPop;
  SplitViewStatus _shouldStatus = SplitViewStatus.expanded;
  SplitViewStatus get shouldStatus => _shouldStatus;
  set shouldStatus(SplitViewStatus s) {
    if (s != _shouldStatus) {
      var prev = _shouldStatus;
      if (prev == SplitViewStatus.collapsedWithLeft &&
          s == SplitViewStatus.expanded) {
        _right = null;
      }
      _shouldStatus = s;
      onStatusChange?.call(prev, s);
    }
  }

  final void Function(SplitViewStatus prev, SplitViewStatus curr)?
  onStatusChange;
  Widget? defaultRight;
  bool get isExpanded => shouldStatus == SplitViewStatus.expanded;
  ValueNotifier<bool> refreshFlag = ValueNotifier(false);
  Widget? _right;
  Widget? topBar;

  Widget get right => _right ?? defaultRight ?? SizedBox();

  Future<void> push(Widget right, {Widget? topBar}) async {
    _right = right;
    this.topBar = topBar;
    if (shouldStatus == SplitViewStatus.collapsedWithLeft) {
      shouldStatus = SplitViewStatus.collapsedWithRight;
    }
    refreshFlag.value = !refreshFlag.value;
  }

  Future<void> pop() async {
    if (shouldStatus == SplitViewStatus.collapsedWithRight) {
      shouldStatus = SplitViewStatus.collapsedWithLeft;
      onPop?.call();
    }
    refreshFlag.value = !refreshFlag.value;
  }
}

class SplitView extends StatefulWidget {
  const SplitView({
    super.key,
    required this.left,
    required this.controller,
    this.leftPercent = 0.5,
    this.maxLeftWidth,
    this.centralPadding,
    this.minExpandedWidth = 600,
    this.onLayout,
    this.topbarHeight = 35,
  });
  final double minExpandedWidth;
  final double? centralPadding;
  final Widget left;
  final double? maxLeftWidth;
  final double leftPercent;
  final SplitViewController controller;
  final double topbarHeight;
  final void Function(
    SplitViewStatus prev,
    SplitViewStatus state,
    bool isFirst,
  )?
  onLayout;
  @override
  State<SplitView> createState() => _SplitViewState();
}

enum SplitViewStatus { expanded, collapsedWithLeft, collapsedWithRight }

class _SplitViewState extends State<SplitView>
    with SingleTickerProviderStateMixin {
  SplitViewStatus get shouldStatus => controller.shouldStatus;
  set shouldStatus(SplitViewStatus s) => controller.shouldStatus = s;
  SplitViewController get controller => widget.controller;
  late String vid;
  bool isFirst = true;

  @override
  void initState() {
    super.initState();
    vid = Uuid().v4();
  }

  Widget buildDenseRight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      key: ValueKey("${vid}rc"),
      children: [
        if (controller.topBar != null)
          SizedBox(height: widget.topbarHeight, child: controller.topBar),
        Expanded(
          child: KeyedSubtree(
            key: ValueKey("${vid}rW"),
            child: controller.right,
          ),
        ),
      ],
    );
  }

  List<_SplitViewData> calculateShouldLayout(double maxWidth) {
    switch (shouldStatus) {
      case SplitViewStatus.expanded:
        return [
          _SplitViewData(
            0,
            maxWidth -
                min(
                  maxWidth * widget.leftPercent,
                  widget.maxLeftWidth ?? double.maxFinite,
                ) +
                (widget.centralPadding ?? 0) / 2,
          ),
          _SplitViewData(
            min(
                  maxWidth * widget.leftPercent,
                  widget.maxLeftWidth ?? double.maxFinite,
                ) +
                (widget.centralPadding ?? 0) / 2,
            0,
          ),
        ];
      case SplitViewStatus.collapsedWithLeft:
        return [_SplitViewData(0, 0), _SplitViewData(maxWidth, -maxWidth)];
      case SplitViewStatus.collapsedWithRight:
        return [_SplitViewData(0, 0), _SplitViewData(0, 0)];
    }
  }

  bool isPanning = false;
  Offset? firstPanLoc;
  bool isResize = true;
  bool shouldPan = false;
  static const Duration duration = Duration(milliseconds: 200);
  double lastWidth = 0;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        var maxWidth = c.maxWidth;
        var prev = shouldStatus;
        if (lastWidth != maxWidth) {
          if (maxWidth < widget.minExpandedWidth) {
            if (shouldStatus == SplitViewStatus.expanded) {
              if (controller._right != null) {
                shouldStatus = SplitViewStatus.collapsedWithRight;
              } else {
                shouldStatus = SplitViewStatus.collapsedWithLeft;
              }
            }
          } else {
            shouldStatus = SplitViewStatus.expanded;
          }
          isResize = true;
          lastWidth = maxWidth;
        }
        widget.onLayout?.call(prev, shouldStatus, isFirst);
        isFirst = false;
        return ValueListenableBuilder<bool>(
          valueListenable: controller.refreshFlag,
          builder: (context, value, child) {
            var r = calculateShouldLayout(maxWidth);
            return StatefulBuilder(
              builder: (context, setState) {
                var d = (isResize || isPanning) ? Duration.zero : duration;
                isResize = false;
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanStart: (details) {
                    if (shouldStatus == SplitViewStatus.collapsedWithRight) {
                      shouldPan = details.localPosition.dx <= maxWidth * 0.6;
                    } else {
                      shouldPan = false;
                    }
                  },
                  onPanUpdate: (details) {
                    if (shouldPan) {
                      setState(() {
                        isPanning = true;
                        r[1] = _SplitViewData(
                          (r[1].left + details.delta.dx).clamp(0, maxWidth),
                          (r[1].right - details.delta.dx).clamp(-maxWidth, 0),
                        );
                      });
                    }
                  },
                  onPanCancel: () {
                    if (shouldStatus == SplitViewStatus.collapsedWithRight &&
                        r[1].left > maxWidth * 0.3) {
                      shouldStatus = SplitViewStatus.collapsedWithLeft;
                      controller.onPop?.call();
                    }
                    r = calculateShouldLayout(maxWidth);
                    isPanning = false;
                    setState(() {});
                  },
                  onPanEnd: (_) {
                    if (shouldStatus == SplitViewStatus.collapsedWithRight &&
                        r[1].left > maxWidth * 0.3) {
                      shouldStatus = SplitViewStatus.collapsedWithLeft;
                      controller.onPop?.call();
                    }
                    r = calculateShouldLayout(maxWidth);
                    isPanning = false;
                    setState(() {});
                  },
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: d,
                        key: ValueKey("${vid}l"),
                        top: 0,
                        bottom: 0,
                        left: r[0].left,
                        right: r[0].right,
                        curve: Curves.easeInOut,
                        child: widget.left,
                      ),
                      // 中间层：动态阴影遮罩 (只有在非 Expanded 状态下有意义)
                      AnimatedPositioned(
                        duration: d,
                        key: ValueKey("${vid}r"),
                        top: 0,
                        bottom: 0,
                        left: r[1].left,
                        right: r[1].right,
                        curve: Curves.easeInOut,
                        child: (shouldStatus == SplitViewStatus.expanded)
                            ? KeyedSubtree(
                                key: ValueKey("${vid}rW"),
                                child: controller.right,
                              )
                            : buildDenseRight(),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class MirrorSplitView extends StatefulWidget {
  // 爆赞gemini，我叫他完全按照左侧版本来写右侧，即使enum 在这里是反的。
  // 然后他完美理解了我的意思，然后一把实现！太厉害了！而且这只是flash模型。 以后就用ai偷懒了
  const MirrorSplitView({
    super.key,
    required this.left,
    required this.controller,
    this.leftPercent = 0.5,
    this.maxLeftWidth,
    this.centralPadding,
    this.minExpandedWidth = 600,
    this.onLayout,
    this.topbarHeight = 35,
  });
  final double minExpandedWidth;
  final double? centralPadding;
  final Widget left;
  final double? maxLeftWidth;
  final double leftPercent;
  final SplitViewController controller;
  final double topbarHeight;
  final void Function(
    SplitViewStatus prev,
    SplitViewStatus state,
    bool isFirst,
  )?
  onLayout;

  @override
  State<MirrorSplitView> createState() => _MirrorSplitViewState();
}

class _MirrorSplitViewState extends State<MirrorSplitView> {
  SplitViewStatus get shouldStatus => controller.shouldStatus;
  set shouldStatus(SplitViewStatus s) => controller.shouldStatus = s;
  SplitViewController get controller => widget.controller;
  late String vid;
  bool isFirst = true;

  @override
  void initState() {
    super.initState();
    vid = const Uuid().v4();
  }

  Widget buildDenseRight() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      key: ValueKey("${vid}rc"),
      children: [
        if (controller.topBar != null)
          SizedBox(height: widget.topbarHeight, child: controller.topBar),
        Expanded(
          child: KeyedSubtree(
            key: ValueKey("${vid}rW"),
            child: controller.right,
          ),
        ),
      ],
    );
  }

  // 核心逻辑：计算镜像位置
  List<_SplitViewData> calculateShouldLayout(double maxWidth) {
    // 计算 left 宽度
    double leftWidth = min(
      maxWidth * widget.leftPercent,
      widget.maxLeftWidth ?? double.maxFinite,
    );
    double padding = (widget.centralPadding ?? 0) / 2;

    switch (shouldStatus) {
      case SplitViewStatus.expanded:
        // Index 0 为原 left 组件 -> 现置于右侧
        // Index 1 为原 right 组件 -> 现置于左侧
        return [
          _SplitViewData(
            maxWidth - leftWidth + padding,
            0,
          ), // left widget (Right Side)
          _SplitViewData(0, leftWidth + padding), // right widget (Left Side)
        ];
      case SplitViewStatus.collapsedWithLeft:
        // 对应原版：左侧铺满。镜像版：右侧铺满。
        return [_SplitViewData(0, 0), _SplitViewData(-maxWidth, maxWidth)];
      case SplitViewStatus.collapsedWithRight:
        // 对应原版：右侧铺满。镜像版：左侧铺满。
        return [_SplitViewData(0, 0), _SplitViewData(0, 0)];
    }
  }

  bool isPanning = false;
  bool isResize = true;
  bool shouldPan = false;
  static const Duration duration = Duration(milliseconds: 200);
  double lastWidth = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        var maxWidth = c.maxWidth;
        var prev = shouldStatus;
        if (lastWidth != maxWidth) {
          if (maxWidth < widget.minExpandedWidth) {
            if (shouldStatus == SplitViewStatus.expanded) {
              shouldStatus = (controller._right != null)
                  ? SplitViewStatus.collapsedWithRight
                  : SplitViewStatus.collapsedWithLeft;
            }
          } else {
            shouldStatus = SplitViewStatus.expanded;
          }
          isResize = true;
          lastWidth = maxWidth;
        }
        widget.onLayout?.call(prev, shouldStatus, isFirst);
        isFirst = false;

        return ValueListenableBuilder<bool>(
          valueListenable: controller.refreshFlag,
          builder: (context, value, child) {
            var r = calculateShouldLayout(maxWidth);
            return StatefulBuilder(
              builder: (context, setState) {
                var d = (isResize || isPanning) ? Duration.zero : duration;
                isResize = false;

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanStart: (details) {
                    if (shouldStatus == SplitViewStatus.collapsedWithRight) {
                      shouldPan = details.localPosition.dx >= maxWidth * 0.4;
                    } else {
                      shouldPan = false;
                    }
                  },
                  onPanUpdate: (details) {
                    if (shouldPan) {
                      setState(() {
                        isPanning = true;
                        // 镜像滑动逻辑：向左滑 delta 为负，r[1].right 增加，r[1].left 减少
                        r[1] = _SplitViewData(
                          (r[1].left + details.delta.dx).clamp(-maxWidth, 0),
                          (r[1].right - details.delta.dx).clamp(0, maxWidth),
                        );
                      });
                    }
                  },
                  onPanCancel: () => _handlePanEnd(maxWidth, r, setState),
                  onPanEnd: (_) => _handlePanEnd(maxWidth, r, setState),
                  child: Stack(
                    children: [
                      // left widget (现在逻辑位置在右)
                      AnimatedPositioned(
                        duration: d,
                        key: ValueKey("${vid}l"),
                        top: 0,
                        bottom: 0,
                        left: r[0].left,
                        right: r[0].right,
                        curve: Curves.easeInOut,
                        child: widget.left,
                      ),
                      // right widget (现在逻辑位置在左)
                      AnimatedPositioned(
                        duration: d,
                        key: ValueKey("${vid}r"),
                        top: 0,
                        bottom: 0,
                        left: r[1].left,
                        right: r[1].right,
                        curve: Curves.easeInOut,
                        child: (shouldStatus == SplitViewStatus.expanded)
                            ? KeyedSubtree(
                                key: ValueKey("${vid}rW"),
                                child: controller.right,
                              )
                            : buildDenseRight(),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _handlePanEnd(
    double maxWidth,
    List<_SplitViewData> r,
    StateSetter setState,
  ) {
    // 镜像逻辑：向左滑过 30% 则视为 pop
    if (shouldStatus == SplitViewStatus.collapsedWithRight &&
        r[1].right > maxWidth * 0.3) {
      shouldStatus = SplitViewStatus.collapsedWithLeft;
      controller.onPop?.call();
    }
    isPanning = false;
    setState(() {});
  }
}

class _SplitViewData {
  final double left;
  final double right;
  _SplitViewData(this.left, this.right);

  @override
  String toString() {
    return "left: $left, right: $right";
  }
}
