import 'dart:math';

import 'package:uni_chat/Editor/BlockComponents/components.dart';
import 'package:uni_chat/Editor/Core/block_data.dart';
import 'package:uni_chat/Editor/Core/canvas.dart';
import 'package:uni_chat/Editor/Core/persistent_data_recorder.dart';
import 'package:uni_chat/Editor/Core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../BlockComponents/components_layout_engine.dart';

class MovableBlock extends ConsumerStatefulWidget {
  final BlockData block;
  const MovableBlock({required this.block, required ValueKey valKey})
    : super(key: valKey);

  @override
  ConsumerState<MovableBlock> createState() => _MovableBlockState();
}

class _MovableBlockState extends ConsumerState<MovableBlock> {
  @override
  Widget build(BuildContext context) {
    // 使用 Consumer 来监听位置信息
    return Consumer(
      builder: (context, ref, child) {
        // ref.watch只在这里被调用，只影响 Positioned 的父级
        var posAndFoc = ref.watch(
          blockPositionAndFocusProvider(widget.block.bid),
        );
        final clampedOffset = Offset(
          posAndFoc.$1.dx.clamp(0, 7000),
          posAndFoc.$1.dy.clamp(0, 4000),
        );
        widget.block.position = clampedOffset;
        return Positioned(
          left: clampedOffset.dx,
          top: clampedOffset.dy,
          // 将 Block 组件作为 Consumer 的 child 传递
          // 这样即使 Consumer 的 builder 重建，child 也不会重建
          child: Container( decoration: BoxDecoration(
            color: posAndFoc.$2?Colors.white:Colors.white.withAlpha(220),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                spreadRadius: posAndFoc.$2?4:2,
                blurRadius: posAndFoc.$2?4:6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
              width: 300,child: child!),
        );
      },
      // 将 Block 组件作为 child 参数传递给 Consumer
      // 它只会在 MovableBlock 第一次构建时创建
      child: Block(block: widget.block),
    );
  }
}

class Block extends StatelessWidget {
  const Block({super.key, required this.block});

  final BlockData block;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            gradient: LinearGradient(
              colors: [block.config.type.color.withAlpha(200), Colors.white],
            ),
          ),
          height: 60,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          child: Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: block.config.type.color,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(60),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                child: Icon(block.config.icon, color: Colors.white, size: 27),
              ),
              const SizedBox(width: 20),
              Expanded(child: BannerTitle(block: block)),
            ],
          ),
        ),
        BlockMainContent(block: block),
      ],
    );
  }
}

class BannerTitle extends ConsumerWidget {
  BannerTitle({super.key, required this.block});

  final BlockData block;
  OverlayEntry? _overlayEntry;
  WidgetRef? _ref;

  void _showOverLay(BuildContext context) {
    var renderBox = context.findRenderObject() as RenderBox;
    var eci = _ref!.read(editorControllerInstance);
    var size = renderBox.size * eci.zoom;
    eci.receiveInput = false;
    var offset = renderBox.localToGlobal(Offset.zero);
    offset = offset.translate(0, -11 * eci.zoom);
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (_overlayEntry != null) {
                  _overlayEntry!.remove();
                  _overlayEntry = null;
                  _ref!.read(editorControllerInstance).receiveInput = true;
                }
              },
              onPanStart: (details) {
                //在用户尝试拖画布的时候也关掉
                if (_overlayEntry != null) {
                  _overlayEntry!.remove();
                  _overlayEntry = null;
                  _ref!.read(editorControllerInstance).receiveInput = true;
                }
              },
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy,
              child: SizedBox(
                height: size.height,
                width: size.width,
                child: OverlayTextField(
                  componentId: (block.bid,0),
                  overlayEntry: _overlayEntry,
                  zoom: eci.zoom,
                  textAlign: TextAlign.start,
                  padding: EdgeInsets.only(left: 1),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _ref = ref;
    ref.listen(
      //他的id固定是0
      blockComponentNotifier(block.bid).select((state) => state.hitComponent[0]),
      (previousValue, nextValue) {
        // 当状态从 true 变为 false 时，执行一次性逻辑
        if (nextValue!.$1 == true) {
          var bcn = ref.read(blockComponentNotifier(block.bid).notifier);
          bcn.rogerHit(0);
          bcn.updateComponentInfo(0, DynamicWithType("", RecordDataType.string));
          _showOverLay(context);
        }
      },
    );
    var nickName = ref.watch(blockComponentNotifier(block.bid).select((s)=>s.componentsInfo[0]));
    if (nickName == null||nickName.type != RecordDataType.string) {
      return Text(
        block.config.name,
        style: TextStyle(
          fontSize: 22,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          nickName.value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Text(
          block.config.name,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[300],
            fontWeight: FontWeight.w300,
          ),
          maxLines: 1,
        ),
      ],
    );
  }
}
