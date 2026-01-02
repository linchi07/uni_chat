import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

// 定义主题数据类
class ThemeConfig {
  final Color primaryColor;
  final Color zeroGradeColor;
  final Color secondGradeColor;
  final Color thirdGradeColor;
  late final Color brightTextColor;
  late final Color darkTextColor;

  ThemeConfig({
    required this.primaryColor,
    required this.zeroGradeColor,
    required this.secondGradeColor,
    required this.thirdGradeColor,
    required Color brightTextColor,
    required Color darkTextColor,
  }) {
    this.brightTextColor = brightTextColor ?? Colors.black;
    this.darkTextColor = darkTextColor ?? Colors.white;
  }

  Color get textColor {
    if (secondGradeColor.computeLuminance() > 0.5) {
      return darkTextColor;
    } else {
      return brightTextColor;
    }
  }

  Color getTextColor(Color backgroundColor) {
    if (backgroundColor.computeLuminance() > 0.5) {
      return darkTextColor;
    } else {
      return brightTextColor;
    }
  }

  ThemeConfig copyWith({
    Color? primaryColor,
    Color? zeroGradeColor,
    Color? secondGradeColor,
    Color? thirdGradeColor,
    Color? brightTextColor,
    Color? darkTextColor,
  }) {
    return ThemeConfig(
      primaryColor: primaryColor ?? this.primaryColor,
      zeroGradeColor: zeroGradeColor ?? this.zeroGradeColor,
      secondGradeColor: secondGradeColor ?? this.secondGradeColor,
      thirdGradeColor: thirdGradeColor ?? this.thirdGradeColor,
      brightTextColor: brightTextColor ?? this.brightTextColor,
      darkTextColor: darkTextColor ?? this.darkTextColor,
    );
  }
}

// 使用 StateNotifier 管理主题状态
class ThemeManager extends StateNotifier<ThemeConfig> {
  ThemeManager() : super(solarized);

  static ThemeConfig light = ThemeConfig(
    primaryColor: const Color(0xFF000000),
    zeroGradeColor: const Color(0xFFFFFFFF),
    secondGradeColor: const Color(0xFFF2F2F2),
    thirdGradeColor: const Color(0xFFD7D7D7),
    darkTextColor: const Color(0xFF000000),
    brightTextColor: const Color(0xFFFFFFFF),
  );

  static ThemeConfig dark = ThemeConfig(
    primaryColor: const Color(0xFFFFFFFF),
    zeroGradeColor: const Color(0xFF000000),
    secondGradeColor: const Color(0xFF282828),
    thirdGradeColor: const Color(0xFF7A7979),
    darkTextColor: const Color(0xFFFFFFFF),
    brightTextColor: const Color(0xFF000000),
  );

  static ThemeConfig solarized = ThemeConfig(
    primaryColor: const Color(0xff6e8082),
    zeroGradeColor: const Color(0xfffdf6e3),
    secondGradeColor: const Color(0xfff0ebda),
    thirdGradeColor: const Color(0xffcfcab9),
    darkTextColor: const Color(0xff000000),
    brightTextColor: const Color(0xff788191),
  );
  // 更新主题颜色的方法
  void updateTheme({
    Color? primaryColor,
    Color? surfaceColor,
    Color? backgroundColor,
    Color? boxColor,
    Color? darkTextColor,
    Color? brightTextColor,
  }) {
    state = state.copyWith(
      primaryColor: primaryColor,
      zeroGradeColor: surfaceColor,
      secondGradeColor: backgroundColor,
      thirdGradeColor: boxColor,
      darkTextColor: darkTextColor,
      brightTextColor: brightTextColor,
    );
  }
}

// 创建 StateNotifierProvider
final themeProvider = StateNotifierProvider<ThemeManager, ThemeConfig>((ref) {
  return ThemeManager();
});
