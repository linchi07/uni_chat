import 'package:uni_chat/Editor/Core/block_data.dart';
import 'package:uni_chat/Editor/Core/link_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'block_hitTest_engine.dart';
import 'editor_controller.dart';

final editorControllerInstance = Provider<EditorController>((ref) {
  return EditorController(
    ref:  ref,
    transformationController: TransformationController(),
  );
});

final linkController = Provider<LinkController>((ref) {
  return LinkController(ref);
});

final blockPositionAndFocusProvider =
StateProvider.family<(Offset,bool), int>((ref, bid) => (Offset.zero,false));

final blockComponentNotifier = NotifierProvider.family<BlockComponentNotifier,BlockComponentInfo, int>(()=>BlockComponentNotifier());

final inBlockHitTestEngine = Provider<InBlockHitTestEngine>((ref) {
  return InBlockHitTestEngine(ref);
}); 

///这个只是用来通知堆叠的刷新，所以我们就拿一个bool。每次设置成 != val就好了
final stackRefreshNotifier = StateProvider<bool>((ref) => false);

final tmpLinkPainterNotifier = StateProvider<bool>((ref) => false);

final persistentLinkProvider = StateProvider<bool>((ref) => false);