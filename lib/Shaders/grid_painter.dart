// CustomPainter 类，用于绘制网格
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final ui.FragmentShader shader;

  GridPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()..shader = shader;

    // 直接在整个画布上绘制
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    // 如果shader有动画效果，这里返回true
    return oldDelegate.shader != shader;
  }
}