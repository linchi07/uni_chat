import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:macos_window_utils/macos/ns_window_toolbar_style.dart';
import 'package:macos_window_utils/window_manipulator.dart';

class MacOSSpecificsSetting {
  static Future<void> setWindowStyle() async {
    await WindowManipulator.initialize();
    await WindowManipulator.hideTitle();
    await WindowManipulator.makeTitlebarTransparent();
    await WindowManipulator.addToolbar();
    await WindowManipulator.setWindowMinSize(const Size(640, 480));
    await WindowManipulator.setToolbarStyle(
      toolbarStyle: NSWindowToolbarStyle.unified,
    );
    await WindowManipulator.enableFullSizeContentView();
  }
}

class WindowsSpecificsSetting {
  static Future<void> setWindowStyle() async {
    appWindow.size = const Size(640, 480);
  }
}
