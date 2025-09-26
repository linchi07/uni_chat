import 'dart:ui' as ui;

import 'package:uni_chat/Editor/Core/block_transform.dart';
import 'package:uni_chat/Editor/Core/editor_controller.dart';
import 'package:uni_chat/Editor/Core/input_controller.dart';
import 'package:uni_chat/Editor/Core/link_painter.dart';
import 'package:uni_chat/Editor/Core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Shaders/grid_painter.dart';

final canvasOverlay = GlobalKey();

class EditorCanvas extends ConsumerStatefulWidget {
  const EditorCanvas({super.key});

  @override
  ConsumerState<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends ConsumerState<EditorCanvas> {
  late Future<ui.FragmentProgram> _programFuture;
  ui.FragmentShader? _shader;
  
  @override
  void initState() {
    super.initState();
    _programFuture = ui.FragmentProgram.fromAsset('lib/Shaders/grid.frag');
    _programFuture.then((program) {
      setState(() {
        _shader = program.fragmentShader();
      });
    });
    createNode();
  }
  
  void createNode(){
    WidgetsBinding.instance.addPostFrameCallback((_){
      for(var i = 0; i < 0; i++) {
        ref.read(editorControllerInstance).createNewBlock();
      }
    });
  }
  

  @override
  Widget build(BuildContext context) {
    if (_shader == null) {
      return const Center(child: CircularProgressIndicator());
    }
    var editorController = ref.read(editorControllerInstance);
    return InputDetector(
      inputController: editorController.inputController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          editorController.viewportSize = constraints;
          return InteractiveViewer(
            key: canvasOverlay,
            panEnabled: false,
            scaleEnabled: false,
            transformationController: editorController.transformationController,
            child: UnconstrainedBox(
              child: SizedBox(
                width: 7000,
                height: 4000,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: GridPainter(_shader!),
                      size: Size.infinite, // 让 CustomPaint 尽可能大
                    ),
                    PersistentLinkPainter(key: ValueKey(-1),),
                    BlockStack(key: ValueKey(0),),
                    TmpLinkPainterWidget(key: ValueKey(-2),),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BlockStack extends ConsumerWidget {
  const BlockStack({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(stackRefreshNotifier);
    return Stack(
      alignment: Alignment.center,
      children:
      ref.read(editorControllerInstance.select((bl)=>bl.buildBlocks)),
    );
  }
}


///由于我们的输入检测比较复杂，我们索性拦截所有输入事件然后手工处理
class InputDetector extends StatelessWidget {
  final Widget child;
  final InputController inputController;
  const InputDetector({super.key, required this.child, required this.inputController});
  
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: inputController.pointerDown,
      onPointerMove: inputController.pointerMove,
      onPointerUp: inputController.pointerUp,
      onPointerHover: inputController.pointerHover,
      onPointerSignal: inputController.pointerSignal,
      onPointerPanZoomStart: inputController.pointerPanZoomStart,
      onPointerPanZoomUpdate: inputController.pointerPanZoomUpdate,
      onPointerPanZoomEnd: inputController.pointerPanZoomEnd,
      child: AbsorbPointer(
        child: child,
      ),
    );
  }
}

