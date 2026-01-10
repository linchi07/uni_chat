import 'dart:async';

import 'package:flutter/widgets.dart';

import '../paste_and_drop.dart';
import 'models.dart';
import 'render_drop.dart';

class NativeDropRegion extends SingleChildRenderObjectWidget {
  final Set<FileFormat> supportedFormats;
  final FutureOr<void> Function(NativeDataReader reader) onPerformDrop;
  final FutureOr<DropOperation> Function(NativeDropOverEvent event)?
      onDropUpdate;
  final void Function(NativeDropEnterEvent event)? onDropEnter;
  final void Function(NativeDropLeaveEvent event)? onDropLeave;

  const NativeDropRegion({
    super.key,
    required Widget child,
    required this.supportedFormats,
    required this.onPerformDrop,
    this.onDropUpdate,
    this.onDropEnter,
    this.onDropLeave,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderDropRegionBox(
      formats: supportedFormats,
      behavior: HitTestBehavior.deferToChild,
      onNativePerformDrop: onPerformDrop,
      onNativeDropUpdate: onDropUpdate,
      onNativeDropEnter: onDropEnter,
      onNativeDropLeave: onDropLeave,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderDropRegionBox renderObject) {
    renderObject.updateFormats(supportedFormats);
    renderObject.onNativePerformDrop = onPerformDrop;
    renderObject.onNativeDropUpdate = onDropUpdate;
    renderObject.onNativeDropEnter = onDropEnter;
    renderObject.onNativeDropLeave = onDropLeave;
  }
}
