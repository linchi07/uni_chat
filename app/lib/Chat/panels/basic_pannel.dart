import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/Chat/chat_page_main.dart';
import 'package:uni_chat/Chat/panels/panel_data.dart';
import 'package:uni_chat/Chat/panels/panel_layout_engine.dart';
import 'package:uni_chat/utils/images.dart';

class BasicPanel extends ConsumerStatefulWidget {
  final String name;
  //这里required key纯粹是不这么做他会警告，我看的难受
  BasicPanel({required key, required this.name}) : super(key: ValueKey(name));

  (String, List<Base64Image>?) panelSummary(PanelData data) {
    throw UnimplementedError(
      "This should be implemented by subclasses like TextPanel, etc.",
    );
  }

  @override
  ConsumerState<BasicPanel> createState() => _BasicPanelState();

  Widget buildInternal(BuildContext context, WidgetRef ref, PanelData data) {
    throw UnimplementedError(
      "This should be implemented by subclasses like TextPanel, etc.",
    );
  }
}

class _BasicPanelState extends ConsumerState<BasicPanel>
    with SingleTickerProviderStateMixin {
  Timer? _relayoutTimer;
  (int, int)? _lastHoverGridPosition;

  // --- 拖拽移动状态 ---
  bool _isBeingDragged = false;
  Offset _dragStartPixelPosition = Offset.zero;
  Offset _currentDragOffset = Offset.zero;

  // --- 拖拽缩放状态 ---
  bool _isResizing = false;
  // 记录缩放开始时的网格尺寸
  (int, int) _resizeStartGridSize = (0, 0);
  (double, double) _resizePxSize = (0, 0);
  // 记录上一次提交给引擎的尺寸，防止重复调用
  (int, int) _lastCommittedGridSize = (0, 0);

  // 编辑模式相关
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // ... initState, _startShakeAnimation, dispose 方法保持不变 ...
  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    const ROTATE_RAD = 0.0261799;
    _shakeAnimation = Tween<double>(
      begin: -ROTATE_RAD,
      end: ROTATE_RAD,
    ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.linear));
  }

  late PanelData data;

  @override
  void dispose() {
    _relayoutTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  bool _isResizeHandleHover = false;
  @override
  Widget build(BuildContext context) {
    data = ref.watch(panelDataProvider(widget.name));
    var lc = ref.watch(layoutConfigProvider);
    var ple = ref.read(panelLayoutEngineProvider);
    final isEditMode = ref.watch(editModeProvider);
    //riverpod 不让在widget build外部调用listen。。。。
    ref.listen(summaryTriggerProvider, (prev, next) {
      ref
          .read(panelManager)
          .collectPanelSummary(widget.name, widget.panelSummary(data));
    });

    final cellWidth = lc.verticalAxisPixelPerUnit;
    final cellHeight = lc.horizontalAxisPixelPerUnit;
    if (isEditMode && !_shakeController.isAnimating) {
      _shakeController.repeat(reverse: true);
    } else if (!isEditMode && _shakeController.isAnimating) {
      _shakeController.stop();
    }

    // --- 定位策略逻辑 (保持不变) ---
    double currentRight;
    double currentTop;
    if (_isBeingDragged) {
      currentRight = _dragStartPixelPosition.dx - _currentDragOffset.dx;
      currentTop = _dragStartPixelPosition.dy + _currentDragOffset.dy;
    } else {
      currentRight = data.layout.x.toDouble() * cellWidth;
      currentTop = data.layout.y.toDouble() * cellHeight;
      // 当我们 resize 时，其他面板的移动也应该有动画，所以这里保持动画时长
    }

    // --- 基础面板 Widget 构建 (用于拖拽移动) ---
    Widget panelMover = GestureDetector(
      // 只有在非缩放模式下才允许拖拽移动
      onPanStart: _isResizing
          ? null
          : (details) {
              final logicalRight = data.layout.x.toDouble() * cellWidth;
              final logicalTop = data.layout.y.toDouble() * cellHeight;
              setState(() {
                _isBeingDragged = true;
                _currentDragOffset = Offset.zero;
                _dragStartPixelPosition = Offset(logicalRight, logicalTop);
              });
            },
      onPanUpdate: _isResizing
          ? null
          : (details) {
              setState(() {
                _currentDragOffset += details.delta;
              });
              final hoverPixelX =
                  _dragStartPixelPosition.dx - _currentDragOffset.dx;
              final hoverPixelY =
                  _dragStartPixelPosition.dy + _currentDragOffset.dy;
              int hoverGridX = (hoverPixelX / cellWidth).round().clamp(
                0,
                math.max(lc.verticalAxisCount - data.layout.width, 0),
              );
              int hoverGridY = (hoverPixelY / cellHeight).round().clamp(
                0,
                math.max(lc.horizontalAxisCount - data.layout.height, 0),
              );
              if (_lastHoverGridPosition != null &&
                  _lastHoverGridPosition!.$1 == hoverGridX &&
                  _lastHoverGridPosition!.$2 == hoverGridY) {
                return;
              }
              _lastHoverGridPosition = (hoverGridX, hoverGridY);
              _relayoutTimer?.cancel();
              _relayoutTimer = Timer(const Duration(milliseconds: 200), () {
                ple.movePanel(data.layout.id, hoverGridX, hoverGridY);
              });
            },
      onPanEnd: _isResizing
          ? null
          : (details) {
              _relayoutTimer?.cancel();
              _lastHoverGridPosition = null;
              final finalPixelX =
                  _dragStartPixelPosition.dx - _currentDragOffset.dx;
              final finalPixelY =
                  _dragStartPixelPosition.dy + _currentDragOffset.dy;
              int finalGridX = (finalPixelX / cellWidth).round().clamp(
                0,
                math.max(lc.verticalAxisCount - data.layout.width, 0),
              );
              int finalGridY = (finalPixelY / cellHeight).round().clamp(
                0,
                math.max(lc.horizontalAxisCount - data.layout.height, 0),
              );
              ple.movePanel(data.layout.id, finalGridX, finalGridY);
              setState(() {
                _isBeingDragged = false;
              });
            },
      onLongPress: () {
        if (!isEditMode) {
          ref.read(editModeProvider.notifier).state = true;
        }
      },
      child: Container(
        /* ... 你的 Container 样式 ... */
        margin: const EdgeInsets.all(8.0),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              spreadRadius: 2,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: widget.buildInternal(context, ref, data),
      ),
    );

    // --- 将基础面板包装在 Stack 中，以便添加编辑模式的 UI ---
    Widget panelWidget = Stack(
      clipBehavior: Clip.none, // 允许 handle 显示在 panel 外部
      fit: StackFit.expand,
      children: [
        // 抖动动画
        if (isEditMode)
          AnimatedBuilder(
            animation: _shakeAnimation,
            child: panelMover,
            builder: (context, child) =>
                Transform.rotate(angle: _shakeAnimation.value, child: child),
          )
        else
          panelMover,

        // 删除按钮
        if (isEditMode)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => ref.read(panelManager).drop([widget.name]),
              child: Container(
                /* ... 删除按钮样式 ... */
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '-',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        // --- 新增：缩放 Handle ---
        if (isEditMode)
          Positioned(
            bottom: 6,
            left: -30,
            width: 50,
            height: 50,
            child: CustomPaint(
              painter: DragHandlePainter(isHover: _isResizeHandleHover),
            ),
          ),
        if (isEditMode)
          Positioned(
            bottom: 0,
            left: 0,
            width: 20,
            height: 20,
            child: MouseRegion(
              onEnter: (details) {
                setState(() {
                  _isResizeHandleHover = true;
                });
              },
              onExit: (details) {
                setState(() {
                  _isResizeHandleHover = false;
                });
              },
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _isResizing = true;
                    // 记录开始时的网格尺寸
                    _resizeStartGridSize = (
                      data.layout.width,
                      data.layout.height,
                    );
                    _resizePxSize = (
                      data.layout.width.toDouble() * cellWidth,
                      data.layout.height.toDouble() * cellHeight,
                    );
                    _lastCommittedGridSize = _resizeStartGridSize;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _resizePxSize = (
                      _resizePxSize.$1 - details.delta.dx,
                      _resizePxSize.$2 + details.delta.dy,
                    );
                  });
                  // 1. 计算像素拖拽距离
                  final pixelDelta = details.localPosition;

                  // 2. 转换为网格单位的变化量，并进行吸附
                  //由于是从左边到右边，所以是负数
                  final gridDeltaWidth = (-pixelDelta.dx / cellWidth).round();
                  final gridDeltaHeight = (pixelDelta.dy / cellHeight).round();

                  // 3. 计算新的目标网格尺寸
                  int newWidth = _resizeStartGridSize.$1 + gridDeltaWidth;
                  int newHeight = _resizeStartGridSize.$2 + gridDeltaHeight;

                  // 4. 限制最小尺寸
                  newWidth = newWidth.clamp(1, ple.maxVerticalAxisCount);
                  newHeight = newHeight.clamp(
                    1,
                    math.max(ple.horizontalAxisCount, 1).toInt(),
                  );

                  // 5. 预览即结果：如果计算出的网格尺寸发生变化，立即调用引擎
                  if (_lastCommittedGridSize.$1 != newWidth ||
                      _lastCommittedGridSize.$2 != newHeight) {
                    ple.resizePanel(data.layout.id, newWidth, newHeight);
                    // 更新记录，防止在同一格内重复调用
                    _lastCommittedGridSize = (newWidth, newHeight);
                  }
                },
                onPanEnd: (details) {
                  setState(() {
                    _isResizeHandleHover = false;
                    _isResizing = false;
                  });
                  // 1. 计算像素拖拽距离
                  final pixelDelta = details.localPosition;

                  // 2. 转换为网格单位的变化量，并进行吸附
                  //由于是从左边到右边，所以是负数
                  final gridDeltaWidth = (-pixelDelta.dx / cellWidth).round();
                  final gridDeltaHeight = (pixelDelta.dy / cellHeight).round();

                  // 3. 计算新的目标网格尺寸
                  int newWidth = _resizeStartGridSize.$1 + gridDeltaWidth;
                  int newHeight = _resizeStartGridSize.$2 + gridDeltaHeight;

                  newWidth = newWidth.clamp(
                    1,
                    math
                        .max(ple.maxVerticalAxisCount - data.layout.x, 1)
                        .toInt(),
                  );
                  newHeight = newHeight.clamp(
                    1,
                    math
                        .max(ple.horizontalAxisCount - data.layout.y, 1)
                        .toInt(),
                  );

                  // 5. 预览即结果：如果计算出的网格尺寸发生变化，立即调用引擎
                  if (_lastCommittedGridSize.$1 != newWidth ||
                      _lastCommittedGridSize.$2 != newHeight) {
                    ple.resizePanel(data.layout.id, newWidth, newHeight);
                    // 更新记录，防止在同一格内重复调用
                    _lastCommittedGridSize = (newWidth, newHeight);
                  }
                },
              ),
            ),
          ),
      ],
    );
    return AnimatedPositioned(
      duration: _isResizing || _isBeingDragged
          ? Duration.zero
          : Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      right: currentRight,
      top: currentTop,
      height: _isResizing
          ? _resizePxSize.$2
          : data.layout.height.toDouble() * cellHeight,
      width: _isResizing
          ? _resizePxSize.$1
          : data.layout.width.toDouble() * cellWidth,
      child: panelWidget,
    );
  }
}

class DragHandlePainter extends CustomPainter {
  DragHandlePainter({required this.isHover});
  final bool isHover;
  @override
  void paint(Canvas canvas, Size size) {
    // 绘制白色拖拽手柄弧线
    final whiteHandlePaint = Paint()
      ..color = isHover ? Colors.grey[700]! : Colors.grey[500]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHover
          ? 8.0
          : 5.0 // 调整线条粗细
      ..strokeCap = StrokeCap.round;

    // 绘迹黑色阴影效果
    final shadowPaint = Paint()
      ..color = isHover
          ? Colors.black.withAlpha(60)
          : Colors.black.withAlpha(20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHover ? 12.0 : 10.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        isHover ? 4.0 : 2.0,
      ); // 添加模糊效果

    final Path handlePath = Path();
    // 弧线起始点和控制点需要仔细调整，以达到图片中的效果
    const double arcRadius = 10.0;
    const double padding = 6.0; // 离右下角的内边距

    handlePath.moveTo(size.width - padding - arcRadius, size.height - padding);
    handlePath.arcToPoint(
      Offset(size.width - padding, size.height - padding + arcRadius),
      radius: const Radius.circular(arcRadius),
      clockwise: false,
    );
    const double shadowOffset = -0.12;
    final Path shadowPath = Path();
    shadowPath.moveTo(
      size.width - padding - arcRadius + shadowOffset,
      size.height - padding + shadowOffset,
    );
    shadowPath.arcToPoint(
      Offset(
        size.width - padding + shadowOffset,
        size.height - padding + arcRadius + shadowOffset,
      ),
      radius: const Radius.circular(arcRadius),
      clockwise: false,
    );

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(handlePath, whiteHandlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
