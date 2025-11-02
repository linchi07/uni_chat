import 'dart:math';

import 'package:uni_chat/Editor/BlockComponents/components_layout_engine.dart';
import 'package:uni_chat/Editor/Core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///链接\n
class Link {
  int linkId;
  Port inPort;
  Offset startPos;
  Port outPort;
  Offset endPos;
  Color color;
  PortShape type;
  Path? bezierPath;
  double minX = 0, minY = 0, maxX = 0, maxY = 0;
  List<Offset>? cachedPoints;
  Link({
    required this.linkId,
    required this.inPort,
    required this.startPos,
    required this.outPort,
    required this.endPos,
    required this.color,
    required this.type,
  });

  //这个贝塞尔曲线函数是直接从flNodes这个仓库中拷贝过来的，而后半部分是我们的gemini改动的
  ///计算贝塞尔曲线，同时算出aabb和采样点，方便后续的hitTest快速计算
  void computeBezierLinkPath() 
  {
    final Path path = Path()..moveTo(startPos.dx, startPos.dy);

    const double defaultOffset = 400.0;
    final dx = (endPos.dx - startPos.dx).abs();
    final controlOffset = dx < defaultOffset * 2 ? dx / 2 : defaultOffset;
    final cp1 = Offset(startPos.dx + controlOffset, startPos.dy);
    final cp2 = Offset(endPos.dx - controlOffset, endPos.dy);

    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, endPos.dx, endPos.dy);

    // 缓存路径
    bezierPath = path;

    // --- 缓存HitTest数据 ---

    // 1. 缓存AABB
    final bounds = path.getBounds();
    minX = bounds.left;
    minY = bounds.top;
    maxX = bounds.right;
    maxY = bounds.bottom;
    double distance = (startPos - endPos).distance;
    int samplingRate = (distance / 40).ceil();
    // 2. 缓存离散点 (使用PathMetric)
    cachedPoints = [];
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final double length = metric.length;
      final double step = length / samplingRate; // 采样率越高，越精确
      for (double d = 0; d < length; d += step) {
        final tangent = metric.getTangentForOffset(d)!;
        cachedPoints!.add(tangent.position);
      }
      // 确保最后一个点也被加入
      cachedPoints!.add(metric.getTangentForOffset(length)!.position);
    }}
}

class Zelda {}

class TmpLinkPainter extends CustomPainter {
  final List<Link> links;
  final Link? highlightLink;
  final Port? highlightPort;
  TmpLinkPainter({required this.links, this.highlightPort, this.highlightLink});

  @override
  void paint(Canvas canvas, Size size) {
    for (var link in links) {
      final paint = Paint()
        ..color = link.color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      if (link.bezierPath != null) {
        final path = link.bezierPath!;
        canvas.drawPath(path, paint);
      }
      _drawArrow(canvas, paint, link.endPos);
      paint.style = PaintingStyle.fill;
      switch (link.type) {
        case PortShape.circle:
          canvas.drawCircle(link.startPos, 5, paint);
          break;
        case PortShape.rhombus:
          _drawRhombusPort(canvas, link.startPos, 5, paint);
      }
    }
    if (highlightPort != null) {
      final Paint paint = Paint()
        ..color = highlightPort!.color
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke;
      switch (highlightPort!.shape) {
        case PortShape.circle:
          canvas.drawCircle(highlightPort!.globalPosition, 7, paint);
          break;
        case PortShape.rhombus:
          _drawRhombusPort(canvas, highlightPort!.globalPosition, 7, paint);
          break;
      }
    }
    if(highlightLink != null&&highlightLink!.bezierPath != null){
      final Paint paint = Paint()
          ..color = highlightLink!.color
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke;
      canvas.drawPath(highlightLink!.bezierPath!,paint);
    }
  }

  void _drawArrow(Canvas canvas, Paint paint, Offset point) {
    const LENTH = 7.5;
    const HEIGHT = 5;
    final path = Path();
    path.moveTo(point.dx - LENTH, point.dy + HEIGHT);
    path.lineTo(point.dx, point.dy);
    path.lineTo(point.dx - LENTH, point.dy - HEIGHT);
    canvas.drawPath(path, paint);
  }

  void _drawRhombusPort(
    Canvas canvas,
    Offset center,
    double portRadius,
    Paint paint,
  ) {
    // 菱形的四个顶点
    final Path rhombusPath = Path()
      ..moveTo(center.dx - portRadius, center.dy)
      ..lineTo(center.dx, center.dy - portRadius)
      ..lineTo(center.dx + portRadius, center.dy)
      ..lineTo(center.dx, center.dy + portRadius)
      ..close();
    canvas.drawPath(rhombusPath, paint);
  }

  @override
  bool shouldRepaint(covariant TmpLinkPainter oldDelegate) {
    // 当点位发生变化时，需要重新绘制
    return oldDelegate.links != links;
  }
}

class PerLinkPainter extends CustomPainter {
  final List<Link> links;
  PerLinkPainter({required this.links});

  @override
  void paint(Canvas canvas, Size size) {
    for (var link in links) {
      final paint = Paint()
        ..color = link.color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      if (link.bezierPath != null) {
        final path = link.bezierPath!;
        canvas.drawPath(path, paint);
      }
      paint.style = PaintingStyle.fill;
      switch (link.type) {
        case PortShape.circle:
          canvas.drawCircle(link.startPos, 5, paint);
          canvas.drawCircle(link.endPos, 5, paint);
          break;
        case PortShape.rhombus:
          _drawRhombusPort(canvas, link.endPos, 5, paint);
          _drawRhombusPort(canvas, link.startPos, 5, paint);
      }
    }
  }

  void _drawRhombusPort(
    Canvas canvas,
    Offset center,
    double portRadius,
    Paint paint,
  ) {
    // 菱形的四个顶点
    final Path rhombusPath = Path()
      ..moveTo(center.dx - portRadius, center.dy)
      ..lineTo(center.dx, center.dy - portRadius)
      ..lineTo(center.dx + portRadius, center.dy)
      ..lineTo(center.dx, center.dy + portRadius)
      ..close();
    canvas.drawPath(rhombusPath, paint);
  }

  @override
  bool shouldRepaint(covariant PerLinkPainter oldDelegate) {
    // 当点位发生变化时，需要重新绘制
    return oldDelegate.links != links;
  }
}

class TmpLinkPainterWidget extends ConsumerWidget {
  const TmpLinkPainterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tmpLinkPainterNotifier);
    var lc = ref.read(linkController);
    return CustomPaint(
      painter: TmpLinkPainter(links: lc.tmpLinks, highlightPort: lc.highlightPort, highlightLink: lc.highlightLink),
    );
  }
}

class PersistentLinkPainter extends ConsumerWidget {
  const PersistentLinkPainter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(persistentLinkProvider);
    var pl = ref.read(linkController).persistLinks;
    return CustomPaint(painter: PerLinkPainter(links: pl));
  }
}
