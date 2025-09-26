import 'package:flutter/material.dart';

class _PortalData {
  final OverlayPortalController controller = OverlayPortalController();
  final ValueNotifier<Widget?> childNotifier = ValueNotifier(null);
  final ValueNotifier<bool> barrierVisibleNotifier = ValueNotifier(true);
  final ValueNotifier<Offset?> offsetNotifier = ValueNotifier(null);
  late final AnimationController animationController;

  _PortalData();
}

/// 全局对话框服务，用于通过 OverlayPortal 显示居中对话框。
class OverlayPortalService {
  // 1. 使用私有构造函数创建单例
  OverlayPortalService._();
  static final instance = OverlayPortalService._();

  // 2. 存储所有注册的 portal 控制器和内容通知器
  final Map<String, _PortalData> _portals = {};

  /// 注册一个 portal
  void _registerPortal(String key) {
    if (!_portals.containsKey(key)) {
      _portals[key] = _PortalData();
    }
  }

  /// 注销一个 portal
  void _unregisterPortal(String key) {
    final portal = _portals.remove(key);
    if (portal != null) {
      portal.childNotifier.value = null;
      portal.childNotifier.dispose();
    }
  }

  /// 获取指定 key 的 portal 数据
  _PortalData? _getPortal(String key) {
    return _portals[key];
  }

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
    Offset? offset,
  }) {
    final scopeState = context.findAncestorStateOfType<_OverlayPortalScopeState>();
    if (scopeState == null) {
      throw Exception('No OverlayPortalScope found in context');
    }

    final portal = scopeState._portalData;
    
    // 更新要显示的内容和相关参数
    portal.childNotifier.value = child;
    portal.barrierVisibleNotifier.value = barrierVisible;
    portal.offsetNotifier.value = offset;

    // 显示 OverlayPortal
    portal.controller.show();
  }

  /// 隐藏指定 context 下的对话框。
  static void hide(BuildContext context) {
    final scopeState = context.findAncestorStateOfType<_OverlayPortalScopeState>();
    if (scopeState == null) {
      throw Exception('No OverlayPortalScope found in context');
    }

    final portal = scopeState._portalData;
    
    // 隐藏 OverlayPortal
    portal.controller.hide();
    
    // 动画结束后清空内容，避免内存占用
    Future.delayed(const Duration(milliseconds: 200), () {
      portal.childNotifier.value = null;
    });
  }
}

/// 应用的根级 OverlayPortal，用于显示由 DialogService 管理的全局对话框。
/// 实际上这里是有问题的，我们必须在某个overlay下(以及root)都要放置scope并且通过key区分，否则的话层级还是存在问题
class OverlayPortalScope extends StatefulWidget {
  const OverlayPortalScope({
    super.key,
    required this.child,
  });
  
  final Widget child;

  @override
  State<OverlayPortalScope> createState() => _OverlayPortalScopeState();
}

class _OverlayPortalScopeState extends State<OverlayPortalScope>
    with TickerProviderStateMixin {
  late _PortalData _portalData;

  @override
  void initState() {
    super.initState();
    _portalData = _PortalData();
    // 初始化动画控制器
    _portalData.animationController = AnimationController(
      lowerBound: 0.6,
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    // 释放动画控制器
    _portalData.animationController.dispose();
    // 释放新增的通知器
    _portalData.barrierVisibleNotifier.dispose();
    _portalData.offsetNotifier.dispose();
    _portalData.childNotifier.dispose();

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
        return ValueListenableBuilder<Widget?>(
          valueListenable: _portalData.childNotifier,
          builder: (context, child, _) {
            // 如果没有内容，则不显示任何东西
            if (child == null) {
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
            return ValueListenableBuilder<bool>(
              valueListenable: _portalData.barrierVisibleNotifier,
              builder: (context, barrierVisible, _) {
                // 监听位置变化
                return ValueListenableBuilder<Offset?>(
                  valueListenable: _portalData.offsetNotifier,
                  builder: (context, offset, _) {
                    // 监听大小变化
                    Widget content = child;
/*
                    // 应用动画效果
                    content = FadeTransition(
                      opacity: fadeAnimation,
                      child: content,
                    );
*/
                    // 如果指定了位置，则使用 Positioned，否则使用 Center
                    Widget positionedContent;
                    if (offset != null) {
                      positionedContent = Positioned(
                        left: offset.dx,
                        top: offset.dy,
                        child: content,
                      );
                    } else {
                      positionedContent = Center(child: content);
                    }
                    return Stack(
                      children: [
                        // 背景遮罩，点击时可以关闭对话框
                        ModalBarrier(
                          color: (barrierVisible)?Colors.black.withAlpha(90):Colors.transparent,
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
            );
          },
        );
      },
      // 这是你的主应用内容
      child: widget.child,
    );
  }
}
