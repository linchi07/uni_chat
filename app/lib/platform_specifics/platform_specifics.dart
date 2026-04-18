import 'dart:io';
import 'dart:math' as math;

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macos_window_utils/macos/ns_window_toolbar_style.dart';
import 'package:macos_window_utils/window_manipulator.dart';
import 'package:path/path.dart' as p;

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
  static bool customFontLoaded = false;
  static const String CUSTOM_FONT_FAMILY = "Noto Sans SC";

  static Future<void> setWindowStyle() async {
    appWindow.minSize = const Size(640, 480);
    appWindow.title = "UniChat";
  }

  static Future<void> loadCustomFont() async {
    if (!Platform.isWindows) return;

    try {
      final exeDir = File(Platform.resolvedExecutable).parent.path;
      final fontPath = p.join(exeDir, 'fonts', 'NotoSansSC-VF.ttf');

      if (await File(fontPath).exists()) {
        final fontData = await File(fontPath).readAsBytes();
        final fontLoader = FontLoader(CUSTOM_FONT_FAMILY);
        fontLoader.addFont(Future.value(fontData.buffer.asByteData()));
        await fontLoader.load();
        customFontLoaded = true;
        debugPrint('Custom font loaded: $CUSTOM_FONT_FAMILY');
      } else {
        debugPrint('Custom font not found: $fontPath , skipped');
      }
    } catch (e) {
      debugPrint('Failed to load custom font: $e');
    }
  }
}

class IOSScrollPhysics extends BouncingScrollPhysics {
  const IOSScrollPhysics({super.parent});
  @override
  IOSScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return IOSScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double frictionFactor(double overscrollFraction) {
    return math.pow(1 - overscrollFraction, 2) *
        switch (decelerationRate) {
          ScrollDecelerationRate.fast => 0.26,
          ScrollDecelerationRate.normal => 0.52,
        };
  }

  @override
  SpringDescription get spring {
    switch (decelerationRate) {
      case ScrollDecelerationRate.fast:
        return SpringDescription.withDampingRatio(
          mass: 0.2,
          stiffness: 120,
          ratio: 0.9,
        );
      case ScrollDecelerationRate.normal:
        return super.spring;
    }
  }

  @override
  double get maxFlingVelocity => switch (decelerationRate) {
    ScrollDecelerationRate.fast => kMaxFlingVelocity * 8.0,
    ScrollDecelerationRate.normal => super.maxFlingVelocity * 5,
  };

  @override
  double carriedMomentum(double existingVelocity) {
    return existingVelocity.sign *
        math.min(
          0.02 * math.pow(existingVelocity.abs(), 1.5).toDouble(),
          30000.0,
        );
  }

  @override
  double get minFlingVelocity => kMinFlingVelocity * 0.8;

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (velocity.abs() >= toleranceFor(position).velocity) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity,
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: toleranceFor(position),
        constantDeceleration: switch (decelerationRate) {
          ScrollDecelerationRate.fast => 1400,
          ScrollDecelerationRate.normal => 0,
        },
      );
    }
    return super.createBallisticSimulation(position, velocity);
  }
}
