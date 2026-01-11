import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uni_chat/main.dart';

class _Portal {
  final OverlayPortalController controller = OverlayPortalController();
  final ValueNotifier<_PortalData?> dataNotifier = ValueNotifier(null);
  late final AnimationController animationController;

  _Portal();
}

class _PortalData {
  Widget? child;
  Offset? offset;
  bool barrierVisible;
  bool autoAvoidSoftKeyboard;
  _PortalData({
    this.child,
    this.offset,
    this.barrierVisible = true,
    this.autoAvoidSoftKeyboard = true,
  });
}

/// 全局对话框服务，用于通过 OverlayPortal 显示居中对话框。
class OverlayPortalService {
  // 1. 使用私有构造函数创建单例
  OverlayPortalService._();
  static final instance = OverlayPortalService._();

  /// 显示一个居中的对话框。
  ///
  /// [context] 是必须的，用于查找最近的 OverlayPortalScope
  /// [child] 是要显示在对话框中的 Widget。
  /// [barrierVisible] 控制遮罩是否可见，默认为 true
  /// [offset] 控制对话框相对于屏幕的位置，为 null 时居中显示
  static void show(
    BuildContext context, {
    required Widget child,
    bool barrierVisible = true,
    bool autoAvoidSoftKeyboard = true,
    Offset? offset,
  }) {
    final scopeState = context
        .findAncestorStateOfType<_OverlayPortalScopeState>();
    if (scopeState == null) {
      throw Exception('No OverlayPortalScope found in context');
    }

    final portal = scopeState._portalData;

    portal.dataNotifier.value = _PortalData(
      child: child,
      offset: offset,
      barrierVisible: barrierVisible,
      autoAvoidSoftKeyboard: autoAvoidSoftKeyboard,
    );

    // 显示 OverlayPortal
    portal.controller.show();
  }

  static void showDialog(
    BuildContext context, {
    required Widget child,
    required Color backGroundColor,
  }) {
    child = SizedBox(
      width: 300,
      height: 200,
      child: Material(
        color: backGroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
    OverlayPortalService.show(context, child: child);
  }

  /// 隐藏指定 context 下的对话框。
  static void hide(BuildContext context) {
    final scopeState = context
        .findAncestorStateOfType<_OverlayPortalScopeState>();
    if (scopeState == null) {
      throw Exception('No OverlayPortalScope found in context');
    }

    final portal = scopeState._portalData;

    // 隐藏 OverlayPortal
    portal.controller.hide();
  }
}

/// 应用的根级 OverlayPortal，用于显示由 DialogService 管理的全局对话框。
class OverlayPortalScope extends StatefulWidget {
  const OverlayPortalScope({super.key, required this.child});

  final Widget child;

  @override
  State<OverlayPortalScope> createState() => _OverlayPortalScopeState();
}

class _OverlayPortalScopeState extends State<OverlayPortalScope>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late _Portal _portalData;

  @override
  void initState() {
    super.initState();
    _portalData = _Portal();
    // 初始化动画控制器
    _portalData.animationController = AnimationController(
      lowerBound: 0.6,
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    if (PlatForm().isMobile) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  double _keyboardHeight = 0;

  @override
  void didChangeMetrics() {
    // this is for soft-keyboard avoid on mobile platforms
    super.didChangeMetrics();
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    setState(() {
      _keyboardHeight = viewInsets;
    });
  }

  @override
  void dispose() {
    // 释放动画控制器
    _portalData.animationController.dispose();
    // 释放新增的通知器
    _portalData.dataNotifier.dispose();
    if (PlatForm().isMobile) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      // 使用对应 key 的控制器
      controller: _portalData.controller,
      // 这是实际的覆盖层内容构建器
      overlayChildBuilder: (BuildContext context) {
        // 使用 ValueListenableBuilder 来监听内容变化
        return ValueListenableBuilder<_PortalData?>(
          valueListenable: _portalData.dataNotifier,
          builder: (context, data, _) {
            // 如果没有内容，则不显示任何东西
            if (data == null || data.child == null) {
              return const SizedBox.shrink();
            }
            //这里出现了一个bug或者奇葩的问题，反正就是在apikey设置页面的时候每次的焦点更改都会导致build然后就会放一次动画
            //解决方案是把动画注释掉··
            /*
            // 当portal显示时启动动画
            if (_portalData.controller.isShowing) {
              _portalData.animationController.forward(from: 0.6);
            }
            
            final fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
              CurvedAnimation(
                parent: _portalData.animationController,
                curve: Interval(0.6, 1.0, curve: Curves.easeInSine),
              ),
            );
*/
            // 监听遮罩可见性变化
            // 监听大小变化
            Widget content = data.child!;
            // 如果指定了位置，则使用 Positioned，否则使用 Center
            Widget positionedContent;
            if (data.offset != null) {
              positionedContent = AnimatedPositioned(
                left: data.offset!.dx - 20,
                top: max(
                  0,
                  data.offset!.dy -
                      ((data.autoAvoidSoftKeyboard) ? _keyboardHeight : 0),
                ),
                duration: const Duration(milliseconds: 50),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: content,
                  ),
                ),
              );
            } else {
              positionedContent = Center(
                child: AnimatedPadding(
                  padding: EdgeInsets.only(
                    bottom: (data.autoAvoidSoftKeyboard) ? _keyboardHeight : 0,
                  ),
                  duration: const Duration(milliseconds: 50),
                  child: SingleChildScrollView(
                    // enlarge the scroll area
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: content,
                    ),
                  ),
                ),
              );
            }
            return Stack(
              alignment: Alignment.center,
              children: [
                // 背景遮罩，点击时可以关闭对话框
                ModalBarrier(
                  color: (data.barrierVisible)
                      ? Colors.black.withAlpha(90)
                      : Colors.transparent,
                  dismissible: true,
                  onDismiss: () {
                    // 反向播放动画后再隐藏
                    OverlayPortalService.hide(context);
                  },
                ),
                // 将内容居中显示并添加动画效果
                positionedContent,
              ],
            );
          },
        );
      },
      // 这是你的主应用内容
      child: widget.child,
    );
  }
}

class OverlayWrapper extends StatefulWidget {
  static void removeOverlay(BuildContext context) {
    final overlayRef = OverlayReference.of(context);
    if (overlayRef != null) {
      overlayRef.overlayState.removeOverlay();
      return;
    } else {
      throw Exception('No OverlayWrapper found in context');
    }
  }

  static void showOverlay(
    BuildContext context, {
    required Widget overlayContent,
    bool barrierDismissible = true,
    Future<bool> Function()? onClose,
  }) {
    final scopeState = context.findAncestorStateOfType<OverlayWrapperState>();
    if (scopeState == null) {
      throw Exception('No OverlayWrapper found in context');
    }
    scopeState.insertOverlay(
      overlayContent: overlayContent,
      barrierDismissible: barrierDismissible,
      onClose: onClose,
    );
  }

  /// Register a onClose callback to the current displayed overlay
  /// Useful when you want to close the overlay when the user presses the back button
  static void registerOnClose(
    BuildContext context,
    Future<bool> Function()? onClose,
  ) {
    final overlayRef = OverlayReference.of(context);
    if (overlayRef != null) {
      overlayRef.overlayState.onClose = onClose;
      return;
    } else {
      throw Exception('No OverlayWrapper found in context');
    }
  }

  final Widget child;
  const OverlayWrapper({super.key, required this.child});

  @override
  State<OverlayWrapper> createState() => OverlayWrapperState();
}

class OverlayWrapperState extends State<OverlayWrapper> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    removeOverlay();
    super.dispose();
  }

  Future<bool> Function()? onClose;

  /// 插入 OverlayEntry 到 OverlayState
  void insertOverlay({
    required Widget overlayContent,
    Future<bool> Function()? onClose,
    bool barrierDismissible = true,
  }) {
    if (_overlayEntry != null) return; // 避免重复插入
    this.onClose = onClose;
    _overlayEntry = OverlayEntry(
      builder: (context) {
        // 这里的浮层内容通常需要定位 (如 Positioned, Align 或 Center)
        // 这是一个简单的居中定位示例
        return Stack(
          children: [
            ModalBarrier(
              color: Colors.black.withAlpha(90),
              dismissible: barrierDismissible,
              onDismiss: () {
                removeOverlay();
              },
            ),
            Center(
              child: OverlayReference(
                overlayState: this,
                child: OverlayWrapper(
                  child: OverlayPortalScope(child: overlayContent),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// 移除 OverlayEntry
  void removeOverlay() async {
    if (_overlayEntry == null) return;
    if (!(await onClose?.call() ?? true)) {
      return;
    }
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    // 始终返回子 Widget
    return widget.child;
  }
}

/// 由于Overlay在插入之后context内部无法获得对于源OverlayWrapper的引用，所以需要一个中间层
/// 这个InheritedWidget随着overlay一起被插入新的层，然后通过他来获得overlayState的引用
class OverlayReference extends InheritedWidget {
  final OverlayWrapperState overlayState;

  const OverlayReference({
    super.key,
    required this.overlayState,
    required super.child,
  });

  static OverlayReference? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OverlayReference>();
  }

  @override
  bool updateShouldNotify(covariant OverlayReference oldWidget) => false;
}
