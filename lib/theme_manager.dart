import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

// 定义主题数据类
class ThemeConfig {
  final Color primaryColor;
  final Color surfaceColor;
  final Color backgroundColor;
  final Color boxColor;
  final Color textColor;

  ThemeConfig({
    required this.primaryColor,
    required this.surfaceColor,
    required this.backgroundColor,
    required this.boxColor,
    required this.textColor,
  });
}

// 使用 StateNotifier 管理主题状态
class ThemeManager extends StateNotifier<ThemeConfig> {
  ThemeManager()
      : super(ThemeConfig(
    primaryColor: const Color(0xFF000000),
    surfaceColor: const Color(0xFFFFFFFF),
    backgroundColor: const Color(0xFFF2F2F2),
    boxColor: const Color(0xFFD7D7D7),
    textColor: const Color(0xFF000000),
  ));

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
      surfaceColor: surfaceColor ?? state.surfaceColor,
      backgroundColor: backgroundColor ?? state.backgroundColor,
      boxColor: boxColor ?? state.boxColor,
      textColor: textColor ?? state.textColor,
    );
  }

  // 设置预定义的主题
  void setLightTheme() {
    state = ThemeConfig(
      primaryColor: const Color(0xFF000000),
      surfaceColor: const Color(0xFFFFFFFF),
      backgroundColor: const Color(0xFFF2F2F2),
      boxColor: const Color(0xFFD7D7D7),
      textColor: const Color(0xFF000000),
    );
  }

  void setDarkTheme() {
    state = ThemeConfig(
      primaryColor: const Color(0xFFBB86FC),
      surfaceColor: const Color(0xFF121212),
      backgroundColor: const Color(0xFF1E1E1E),
      boxColor: const Color(0xFF2D2D2D),
      textColor: const Color(0xFFFFFFFF),
    );
  }
}

// 创建 StateNotifierProvider
final themeProvider =
StateNotifierProvider<ThemeManager, ThemeConfig>((ref) {
  return ThemeManager();
});