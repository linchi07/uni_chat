import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

// 定义主题数据类
class ThemeConfig {
  final Color primaryColor;
  final Color zeroGradeColor;
  final Color secondGradeColor;
  final Color thirdGradeColor;
  final Color textColor;

  ThemeConfig({
    required this.primaryColor,
    required this.zeroGradeColor,
    required this.secondGradeColor,
    required this.thirdGradeColor,
    required this.textColor,
  });

  ThemeConfig copyWith({
    Color? primaryColor,
    Color? zeroGradeColor,
    Color? secondGradeColor,
    Color? thirdGradeColor,
    Color? textColor,
  }) {
    return ThemeConfig(
      primaryColor: primaryColor ?? this.primaryColor,
      zeroGradeColor: zeroGradeColor ?? this.zeroGradeColor,
      secondGradeColor: secondGradeColor ?? this.secondGradeColor,
      thirdGradeColor: thirdGradeColor ?? this.thirdGradeColor,
      textColor: textColor ?? this.textColor,
    );
  }
}

// 使用 StateNotifier 管理主题状态
class ThemeManager extends StateNotifier<ThemeConfig> {
  ThemeManager()
    : super(
        ThemeConfig(
          primaryColor: const Color(0xFF000000),
          zeroGradeColor: const Color(0xFFFFFFFF),
          secondGradeColor: const Color(0xFFF2F2F2),
          thirdGradeColor: const Color(0xFFD7D7D7),
          textColor: const Color(0xFF000000),
        ),
      );

  // 更新主题颜色的方法
  void updateTheme({
    Color? primaryColor,
    Color? surfaceColor,
    Color? backgroundColor,
    Color? boxColor,
    Color? textColor,
  }) {
    state = ThemeConfig(
      primaryColor: primaryColor ?? state.primaryColor,
      zeroGradeColor: surfaceColor ?? state.zeroGradeColor,
      secondGradeColor: backgroundColor ?? state.secondGradeColor,
      thirdGradeColor: boxColor ?? state.thirdGradeColor,
      textColor: textColor ?? state.textColor,
    );
  }

  // 设置预定义的主题
  void setLightTheme() {
    state = ThemeConfig(
      primaryColor: const Color(0xFF000000),
      zeroGradeColor: const Color(0xFFFFFFFF),
      secondGradeColor: const Color(0xFFF2F2F2),
      thirdGradeColor: const Color(0xFFD7D7D7),
      textColor: const Color(0xFF000000),
    );
  }

  void setDarkTheme() {
    state = ThemeConfig(
      primaryColor: const Color(0xFFBB86FC),
      zeroGradeColor: const Color(0xFF121212),
      secondGradeColor: const Color(0xFF1E1E1E),
      thirdGradeColor: const Color(0xFF2D2D2D),
      textColor: const Color(0xFFFFFFFF),
    );
  }
}

// 创建 StateNotifierProvider
final themeProvider = StateNotifierProvider<ThemeManager, ThemeConfig>((ref) {
  return ThemeManager();
});
