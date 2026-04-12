import 'dart:math';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_window_utils/widgets/macos_toolbar_passthrough.dart';
import 'package:uni_chat/theme_manager.dart';
import 'package:uni_chat/utils/back_ground_task_manager.dart';

import 'package:uni_chat/l10n/generated/l10n.dart';
import 'main.dart';

class MainBanner extends ConsumerWidget {
  const MainBanner({super.key, this.bannerWidget});
  final Widget? bannerWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    var scWidth = MediaQuery.of(context).size.width;
    Widget stack;
    if (PlatForm().platform == RunningPlatform.macos) {
      var startLength = (scWidth >= 800) ? 230 : 90;
      var maxBannerWidgetWidth = (scWidth / 2 - startLength) * 2;
      var endLength = (scWidth >= 800) ? 100 : 30;
      //macOS 下，首先红绿灯在左边，ui布局需要特殊处理
      stack = Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: startLength.toDouble(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 21),
                //这里解释一下，因为macOS的标题栏有3个点，所以这里要绘制3个点，我们的那个包默认下是在窗口失去焦点的时候直接不显示红绿灯，所以这里直接画一个上去
                CustomPaint(size: Size(50, 50), painter: ThreeDotsPainter()),
                if (scWidth >= 800)
                  Padding(
                    padding: const EdgeInsets.only(left: 21),
                    child: Text(
                      S.of(context).title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            height: 50,
            left: startLength.toDouble(),
            width: maxBannerWidgetWidth,
            child: Center(child: bannerWidget ?? SizedBox()),
          ),
          Positioned(
            right: 0,
            height: 50,
            width: endLength.toDouble(),
            child: ActivityMonitor(maxWidth: endLength.toDouble()),
          ),
        ],
      );
      //需要特殊处理防止macOS的窗口缩放手势和widget的触控冲突，不过看起来好像不处理和处理了我反正没有测出区别。。
      //这里有一个scope 然后在每个独立的组件那边需要有一个 MacosToolbarPass through
      //不能放在positioned里面处理，因为positioned他的大小不是widget真实的大小而是可以最大的大小
      return MacosToolbarPassthroughScope(
        child: Container(height: 50, color: theme.zeroGradeColor, child: stack),
      );
    } else if (PlatForm().platform == RunningPlatform.windows) {
      var startLength = (scWidth >= 800) ? 230 : 100;
      var activityLength = (scWidth >= 800) ? 100 : 30;
      var endLength = activityLength + 150;
      var maxBannerWidgetWidth =
          (scWidth / 2 - max(startLength, endLength)) * 2;
      // this is essential
      // the show desktop on windows will force the window to minimize to a unacceptable size (even if min window size is set)
      // which throws constraint errors
      if (scWidth <= 200) {
        stack = SizedBox.shrink();
      } else {
        stack = Stack(
          alignment: Alignment.center,
          children: [
            //这个widget放在最下面，允许通过拖动顶部栏来移动窗口
            MoveWindow(),
            //为了允许文字也能被拖动，这里使用ignore pointer
            Positioned(
              left: 0,
              top: 0,
              height: 50,
              width: startLength.toDouble(),
              child: IgnorePointer(
                ignoring: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 21),
                    if (scWidth >= 800)
                      Text(
                        S.of(context).title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              height: 50,
              right: endLength.toDouble(),
              width: max(maxBannerWidgetWidth, 10),
              child: Center(child: bannerWidget ?? SizedBox()),
            ),
            Positioned(
              right: 0,
              height: 60,
              child: Material(
                color: Colors.transparent,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ActivityMonitor(maxWidth: activityLength.toDouble()),
                    SizedBox(
                      width: 50,
                      height: 60,
                      child: InkWell(
                        child: MinimizeIcon(color: theme.primaryColor),
                        onTap: () {
                          appWindow.minimize();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      height: 60,
                      child: InkWell(
                        child: MaximizeIcon(color: theme.primaryColor),
                        onTap: () {
                          appWindow.maximizeOrRestore();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      height: 60,
                      child: InkWell(
                        hoverColor: Colors.red,
                        child: CloseIcon(color: theme.primaryColor),
                        onTap: () {
                          appWindow.close();
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
    } else {
      var startLength = (scWidth >= 800) ? 230 : 30;
      var endLength = (scWidth >= 800) ? 100 : 30;
      var maxBannerWidgetWidth =
          (scWidth / 2 - max(startLength, endLength)) * 2;
      stack = Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            width: startLength.toDouble(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 21),
                if (scWidth >= 800)
                  Text(
                    S.of(context).title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          Positioned(
            height: 50,
            left: startLength.toDouble(),
            width: maxBannerWidgetWidth,
            child: Center(child: bannerWidget ?? SizedBox()),
          ),
          Positioned(
            right: 0,
            height: 50,
            width: endLength.toDouble(),
            child: ActivityMonitor(maxWidth: endLength.toDouble()),
          ),
        ],
      );
    }
    return Container(height: 50, color: theme.zeroGradeColor, child: stack);
  }
}

class ActivityMonitor extends ConsumerWidget {
  const ActivityMonitor({super.key, required this.maxWidth});
  final double maxWidth;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(activityProvider);
    var theme = ref.watch(themeProvider);
    if (activity.activities.isNotEmpty) {
      bool hasError = false;
      for (var activity in activity.activities.values) {
        if (activity.stateType == ActivityStateType.error) {
          hasError = true;
          break;
        }
      }
      Widget child;
      if (maxWidth >= 100) {
        child = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            (hasError)
                ? Center(child: Icon(Icons.error_outline, color: Colors.red))
                : SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      color: theme.primaryColor,
                      strokeWidth: 3,
                    ),
                  ),
            const SizedBox(width: 3),
            Text((hasError) ? "处理失败" : "处理中"),
          ],
        );
      } else {
        child = Center(
          child: (hasError)
              ? Icon(Icons.error_outline, color: Colors.red)
              : SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    color: theme.primaryColor,
                    strokeWidth: 3,
                  ),
                ),
        );
      }
      //所有的 top bar 都需要这样处理一下，而且由于大小和布局的问题，我们不能在上面的stack部分统一处理，必须单独在这里弄
      if (PlatForm().platform == RunningPlatform.macos) {
        return MacosToolbarPassthrough(child: child);
      }
      return child;
    }
    return const SizedBox.shrink();
  }
}

class ThreeDotsPainter extends CustomPainter {
  final Color dotColor;
  final double dotRadius;

  ThreeDotsPainter({this.dotColor = Colors.grey, this.dotRadius = 5.7});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor.withAlpha(200)
      ..style = PaintingStyle.fill;

    // 计算三个点的位置（水平居中排列）
    final centerX = size.width / 2;
    final centerY = size.height / 2 + 1;
    const dotSpacing = 20;

    // 绘制三个点
    canvas.drawCircle(Offset(centerX - dotSpacing, centerY), dotRadius, paint);

    canvas.drawCircle(Offset(centerX, centerY), dotRadius, paint);

    canvas.drawCircle(Offset(centerX + dotSpacing, centerY), dotRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
