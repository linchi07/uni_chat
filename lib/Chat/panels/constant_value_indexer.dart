
import 'package:flutter/material.dart';

class ColorParser {
  static Color? parseColor(String? color) {
  if (color == null) {
    return null;
  }
  color = color.trim();
  try {
    if (color.startsWith('#')) {
      return Color(int.parse(color.substring(1), radix: 16) | 0xFF000000);
    } else if (color.startsWith('0x') || color.startsWith('0X')) {
      return Color(int.parse(color.substring(2), radix: 16) | 0xFF000000);
    } else {
      return Color(int.parse(color, radix: 16) | 0xFF000000);
    }
  } catch (e) {
    return null;
  }
}

  static Color textColor(Color bkGroundColor) {
    if (bkGroundColor.computeLuminance() > 0.5) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }
}
