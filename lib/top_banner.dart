import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/theme_manager.dart';

import 'generated/l10n.dart';
import 'main.dart';

class MainBanner extends ConsumerWidget {
  const MainBanner({super.key, this.bannerWidget});
  final Widget? bannerWidget;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    var scWidth = MediaQuery.of(context).size.width;
    var startLength = (scWidth >= 700) ? 230 : 100;
    var maxBannerWidgetWidth = (scWidth / 2 - startLength) * 2;
    var endLength = (scWidth >= 700) ? 100 : 30;
    return Container(
      height: 50,
      color: theme.zeroGradeColor,
      child: Stack(
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
                if (PlatForm().platform == Platform.macos)
                  //这里解释一下，因为macOS的标题栏有3个点，所以这里要绘制3个点，我们的那个包默认下是在窗口失去焦点的时候直接不显示红绿灯，所以这里直接画一个上去
                  CustomPaint(size: Size(50, 50), painter: ThreeDotsPainter()),
                if (PlatForm().platform != Platform.macos)
                  const SizedBox(width: 50),
                const SizedBox(width: 21),
                if (scWidth >= 700)
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
      ),
    );
  }
}

class ActivityState {
  String name;
  String hint;
  String? error;
  ActivityState({required this.name, required this.hint, this.error});
}

final activityProvider = StateProvider<ActivityState?>((ref) => null);

class ActivityMonitor extends ConsumerWidget {
  const ActivityMonitor({super.key, required this.maxWidth});
  final double maxWidth;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(activityProvider);
    var theme = ref.watch(themeProvider);
    if (activity != null) {
      Widget child;
      if (maxWidth >= 100) {
        child = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                color: theme.primaryColor,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(width: 10),
            Text(activity.name),
          ],
        );
      } else {
        child = Center(
          child: SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              color: theme.primaryColor,
              strokeWidth: 3,
            ),
          ),
        );
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
