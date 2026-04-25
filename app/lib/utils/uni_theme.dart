import 'package:flutter/material.dart';

/// 主题配置数据类，存放所有的样式和颜色
class UniThemeData {
  final Color primaryColor;
  final Color zeroGradeColor;
  final Color secondGradeColor;
  final Color thirdGradeColor;
  final Color okColor;
  final Color warningColor;
  final Color errorColor;
  final Color brightTextColor;
  final Color darkTextColor;

  UniThemeData({
    required this.primaryColor,
    required this.zeroGradeColor,
    required this.secondGradeColor,
    required this.thirdGradeColor,
    required this.brightTextColor,
    required this.darkTextColor,
    required this.okColor,
    required this.warningColor,
    required this.errorColor,
  });

  TextStyle get bodyTextStyle {
    return TextStyle(fontSize: 16, color: textColor);
  }

  bool get isDark => primaryColor == Colors.white;

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

  UniThemeData copyWith({
    Color? primaryColor,
    Color? zeroGradeColor,
    Color? secondGradeColor,
    Color? thirdGradeColor,
    Color? brightTextColor,
    Color? darkTextColor,
    Color? okColor,
    Color? warningColor,
    Color? errorColor,
  }) {
    return UniThemeData(
      primaryColor: primaryColor ?? this.primaryColor,
      zeroGradeColor: zeroGradeColor ?? this.zeroGradeColor,
      secondGradeColor: secondGradeColor ?? this.secondGradeColor,
      thirdGradeColor: thirdGradeColor ?? this.thirdGradeColor,
      brightTextColor: brightTextColor ?? this.brightTextColor,
      darkTextColor: darkTextColor ?? this.darkTextColor,
      okColor: okColor ?? this.okColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
    );
  }
}

/// 预设的主题配置方案
class ThemePresets {
  static final UniThemeData LIGHT = UniThemeData(
    primaryColor: const Color(0xFF000000),
    zeroGradeColor: const Color(0xFFFFFFFF),
    secondGradeColor: const Color(0xFFF2F2F2),
    thirdGradeColor: const Color(0xFFD7D7D7),
    darkTextColor: const Color(0xFF000000),
    brightTextColor: const Color(0xFFFFFFFF),
    okColor: const Color(0xFF00D200),
    warningColor: const Color(0xFFEAB200),
    errorColor: const Color(0xFFFF0000),
  );

  static final UniThemeData DARK = UniThemeData(
    primaryColor: const Color(0xFFFFFFFF),
    zeroGradeColor: const Color(0xFF282828),
    secondGradeColor: const Color(0xFF000000),
    thirdGradeColor: const Color(0xFF7A7979),
    darkTextColor: const Color(0xFFFFFFFF),
    brightTextColor: const Color(0xFF000000),
    okColor: const Color(0xFF029402),
    warningColor: const Color(0xFFA47E00),
    errorColor: const Color(0xFFB60000),
  );

  static final UniThemeData SOLARIZED = UniThemeData(
    primaryColor: const Color(0xff6e8082),
    zeroGradeColor: const Color(0xfffdf6e3),
    secondGradeColor: const Color(0xfff0ebda),
    thirdGradeColor: const Color(0xffcfcab9),
    darkTextColor: const Color(0xff000000),
    brightTextColor: const Color(0xFFFFFFFF),
    okColor: const Color(0xff4fc039),
    warningColor: const Color(0xffc0804b),
    errorColor: const Color(0xffe3674b),
  );
}

/// 主题状态管理器，通过 ChangeNotifier 管理更新
class UniThemeNotifier extends ChangeNotifier {
  UniThemeData _currentTheme;
  String _themeName;

  UniThemeNotifier({UniThemeData? initialTheme, String initialName = 'light'})
    : _currentTheme = initialTheme ?? ThemePresets.LIGHT,
      _themeName = initialName;

  UniThemeData get data => _currentTheme;
  String get themeName => _themeName;

  void updateTheme(String name) {
    if (name == 'light') {
      _currentTheme = ThemePresets.LIGHT;
      _themeName = 'light';
    } else if (name == 'dark') {
      _currentTheme = ThemePresets.DARK;
      _themeName = 'dark';
    } else if (name == 'solarized') {
      _currentTheme = ThemePresets.SOLARIZED;
      _themeName = 'solarized';
    }
    notifyListeners();
  }
}

/// 跨组件访问机制，采用原生的 InheritedNotifier
class UniTheme extends InheritedNotifier<UniThemeNotifier> {
  const UniTheme({
    super.key,
    required UniThemeNotifier super.notifier,
    required super.child,
  });

  static UniThemeData of(BuildContext context) {
    final UniTheme? inherited = context
        .dependOnInheritedWidgetOfExactType<UniTheme>();
    if (inherited == null || inherited.notifier == null) {
      return ThemePresets.LIGHT;
    }
    return inherited.notifier!.data;
  }

  static UniThemeNotifier getController(BuildContext context) {
    final UniTheme? inherited = context
        .dependOnInheritedWidgetOfExactType<UniTheme>();
    if (inherited == null || inherited.notifier == null) {
      // 如果实在拿不到，降级创建（防止报错）
      return UniThemeNotifier();
    }
    return inherited.notifier!;
  }
}

/// 拓展方法，提高获取便利性
extension UniThemeContext on BuildContext {
  UniThemeData get uniTheme => UniTheme.of(this);
  UniThemeNotifier get uniThemeNotifier => UniTheme.getController(this);
}
