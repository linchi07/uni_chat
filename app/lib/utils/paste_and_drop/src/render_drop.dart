import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:super_native_extensions/raw_clipboard.dart' as raw_clipboard;
import 'package:super_native_extensions/raw_drag_drop.dart' as raw;

import 'models.dart';
import 'resolver.dart';

// 适配器：将 FileFormat 转换为 Platform Formats
List<String> _getPlatformFormats(Set<FileFormat> formats) {
  final res = <String>{};
  for (var f in formats) {
    if (f.mimeType != null) {
      if (f.mimeType!.startsWith("text/")) {
        res.add("public.utf8-plain-text");
        res.add("text/plain");
      }
      res.add(f.mimeType!);
    }
  }
  // 总是注册基本文件类型
  res.add("public.file-url");
  return res.toList();
}

class _DropContextDelegate extends raw.DropContextDelegate {
  RenderDropRegionBox? _currentOver;

  @override
  Future<void> onDropEnded(raw.BaseDropEvent event) async {
    if (_currentOver != null) {
      _currentOver!.onNativeDropLeave
          ?.call(NativeDropLeaveEvent(sessionId: event.sessionId));
      _currentOver = null;
    }
  }

  @override
  Future<void> onDropLeave(raw.BaseDropEvent event) async {
    if (_currentOver != null) {
      _currentOver!.onNativeDropLeave
          ?.call(NativeDropLeaveEvent(sessionId: event.sessionId));
      _currentOver = null;
    }
  }

  @override
  Future<raw.DropOperation> onDropUpdate(raw.DropEvent event) async {
    // 简单的命中测试 logic
    final hitTest = HitTestResult();
    // ignore: deprecated_member_use
    GestureBinding.instance.hitTest(hitTest, event.locationInView);

    RenderDropRegionBox? newOver;
    for (final item in hitTest.path) {
      final target = item.target;
      if (target is RenderDropRegionBox) {
        newOver = target;
        break;
      }
    }

    if (_currentOver != newOver) {
      if (_currentOver != null) {
        _currentOver!.onNativeDropLeave
            ?.call(NativeDropLeaveEvent(sessionId: event.sessionId));
      }
      _currentOver = newOver;
      if (_currentOver != null) {
        _currentOver!.onNativeDropEnter?.call(NativeDropEnterEvent(
          session: NativeDropSession(
            allowedOperations: event.allowedOperations,
            items: event.items
                .map((i) => NativeDropItem(
                      formats: i.formats,
                      localData: i.localData,
                    ))
                .toList(),
          ),
        ));
      }
    }

    if (newOver != null) {
      if (newOver.onNativeDropUpdate != null) {
        final nativeEvent = NativeDropOverEvent(
          location: event.locationInView,
          session: NativeDropSession(
            allowedOperations: event.allowedOperations,
            items: event.items
                .map((i) => NativeDropItem(
                      formats: i.formats,
                      localData: i.localData,
                    ))
                .toList(),
          ),
        );
        return await newOver.onNativeDropUpdate!(nativeEvent);
      }
      return raw.DropOperation.copy;
    }
    return raw.DropOperation.none;
  }

  @override
  Future<void> onPerformDrop(raw.DropEvent event) async {
    // 转换 items
    final List<raw_clipboard.DataReaderItem> allReaderItems = [];

    for (var item in event.items) {
      final reader = item.readerItem; // Fixed: dataReader -> readerItem
      if (reader != null) {
        allReaderItems
            .add(reader); // readerItem IS DataReaderItem, no need to getItems()
      }
    }

    final resolved = await NativeTypeResolver.resolveItems(
        allReaderItems, _currentOver?._formats);
    final reader = NativeDataReader(resolved);

    // 命中测试并分发
    final hitTest = HitTestResult();
    // ignore: deprecated_member_use
    GestureBinding.instance.hitTest(hitTest, event.locationInView);

    for (final item in hitTest.path) {
      final target = item.target;
      if (target is RenderDropRegionBox) {
        await target.onNativePerformDrop?.call(reader);
        break;
      }
    }
  }

  @override
  Future<raw.ItemPreview?> onGetItemPreview(
          raw.ItemPreviewRequest request) async =>
      null;
}

class DropFormatRegistry {
  DropFormatRegistry._();

  static final _delegate = _DropContextDelegate();

  DropFormatRegistration registerFormats(Set<FileFormat> dataFormats) {
    return registerPlatformDropFormats(_getPlatformFormats(dataFormats));
  }

  DropFormatRegistration registerPlatformDropFormats(List<String> formats) {
    final registration = DropFormatRegistration._(this);
    _registeredFormats[registration] = formats;
    _updateIfNeeded();
    return registration;
  }

  void _unregister(DropFormatRegistration registration) {
    _registeredFormats.remove(registration);
    _updateIfNeeded();
  }

  void _updateIfNeeded() async {
    final nativeContext = await raw.DropContext.instance();
    if (!_initialized) {
      nativeContext.delegate = _delegate;
      _initialized = true;
    }

    final formats = <String>{};
    for (final registration in _registeredFormats.values) {
      formats.addAll(registration);
    }

    if (_lastRegisteredFormats == null ||
        !setEquals(_lastRegisteredFormats, formats.toSet())) {
      await nativeContext.registerDropFormats(formats.toList());
      _lastRegisteredFormats = formats.toSet();
    }
  }

  static DropFormatRegistry instance = DropFormatRegistry._();
  bool _initialized = false;
  final _registeredFormats = <DropFormatRegistration, List<String>>{};
  Set<String>? _lastRegisteredFormats;
}

class DropFormatRegistration {
  DropFormatRegistration._(this._registry);
  void dispose() {
    _registry._unregister(this);
  }

  final DropFormatRegistry _registry;
}

mixin RenderDropRegion on RenderObject {
  Set<FileFormat> _formats = {};
  FutureOr<void> Function(NativeDataReader reader)? onNativePerformDrop;
  void Function(NativeDropEnterEvent event)? onNativeDropEnter;
  FutureOr<raw.DropOperation> Function(NativeDropOverEvent event)?
      onNativeDropUpdate;
  void Function(NativeDropLeaveEvent event)? onNativeDropLeave;

  DropFormatRegistration? _formatRegistration;

  void updateFormats(Set<FileFormat> formats) {
    if (setEquals(_formats, formats)) return;
    _formats = formats;
    _formatRegistration?.dispose();
    _formatRegistration = DropFormatRegistry.instance.registerFormats(formats);
  }

  @override
  void dispose() {
    super.dispose();
    _formatRegistration?.dispose();
  }
}

class RenderProxyBoxWithHitTestBehavior extends RenderProxyBox {
  RenderProxyBoxWithHitTestBehavior({
    RenderBox? child,
    this.behavior = HitTestBehavior.deferToChild,
  }) : super(child);

  HitTestBehavior behavior;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    bool hitTarget = false;
    if (size.contains(position)) {
      hitTarget =
          hitTestChildren(result, position: position) || hitTestSelf(position);
      if (hitTarget || behavior == HitTestBehavior.translucent) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
    }
    return false;
  }

  @override
  bool hitTestSelf(Offset position) => behavior == HitTestBehavior.opaque;
}

class RenderDropRegionBox extends RenderProxyBoxWithHitTestBehavior
    with RenderDropRegion {
  RenderDropRegionBox({
    required Set<FileFormat> formats,
    FutureOr<void> Function(NativeDataReader reader)? onNativePerformDrop,
    void Function(NativeDropEnterEvent event)? onNativeDropEnter,
    FutureOr<raw.DropOperation> Function(NativeDropOverEvent event)?
        onNativeDropUpdate,
    void Function(NativeDropLeaveEvent event)? onNativeDropLeave,
    required HitTestBehavior behavior,
  }) : super(behavior: behavior) {
    updateFormats(formats);
    this.onNativePerformDrop = onNativePerformDrop;
    this.onNativeDropEnter = onNativeDropEnter;
    this.onNativeDropUpdate = onNativeDropUpdate;
    this.onNativeDropLeave = onNativeDropLeave;
  }
}
