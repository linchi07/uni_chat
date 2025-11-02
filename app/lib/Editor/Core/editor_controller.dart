import 'dart:math';
import 'package:uni_chat/Editor/Core/block_transform.dart';
import 'package:uni_chat/Editor/Core/canvas.dart';
import 'package:uni_chat/Editor/Core/input_controller.dart';
import 'package:uni_chat/Editor/Core/providers.dart';
import 'package:uni_chat/Editor/menus&overlays/popup_menus.dart';
import 'package:uni_chat/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'block_data.dart';

const CONTENT_HALF_WIDTH = 3500;
const CONTENT_HALF_HEIGHT = 2000;

enum HitTestResultType { none, block, port, link }

class HitTestResult {
  HitTestResultType _type = HitTestResultType.none;
  set type(HitTestResultType value) {
    if (_type != value &&
        (_type == HitTestResultType.port || _type == HitTestResultType.link)) {
      //这里是关闭高亮
      resetHlCallback(_type);
    }
    _type = value;
  }

  HitTestResultType get type => _type;
  void Function(HitTestResultType) resetHlCallback;
  Offset? position; //转换为画布上的坐标了
  int? id; //可以是任何东西的id，这取决于typeEnum的值
  HitTestResult({
    required HitTestResultType type,
    this.position,
    this.id,
    required this.resetHlCallback,
  }) {
    _type = type;
  }
}

class EditorController {
  final Ref ref;
  final TransformationController transformationController;
  double get zoom => transformationController.value[0];
  bool receiveInput = true;
  late final InputController inputController;
  int nextBlockId = 0;
  Map<int, ValueKey> _blockKeys = {};
  List<Widget> buildBlocks = []; //这个是按照层级顺序排序的，给stack用

  int? currentFocusedBlockId;

  EditorController({
    required this.transformationController,
    required this.ref,
  }) {
    inputController = InputController(
      notifyInput: onInputUpdate,
      notifyHover: onPointerHover,
    );
    _numBuckets = (CANVAS_WIDTH / BUCKET_WIDTH).ceil();
    _buckets = List.generate(_numBuckets, (_) => []);
    hitTestResult = HitTestResult(
      type: HitTestResultType.none,
      resetHlCallback: resetHitTestHl,
    );
  }
  Offset _viewportHalfSize = Offset.zero;
  //指针的内容坐标，不是屏幕坐标！
  Offset pointerHoverRawLoc = Offset.zero;
  set viewportSize(BoxConstraints value) {
    var biggsetC = value.biggest;
    _viewportHalfSize = Offset(biggsetC.width / 2, biggsetC.height / 2);
  }

  Map<int, BlockData> blocks = {};

  void createNewBlock({Offset? pos}) {
    if (pos == null && hitTestResult.position != null) {
      pos = hitTestResult.position!;
    } else {
      pos = Offset(3500, 2000); //这是画布的中心
    }
    var bd = BlockData(
      bid: nextBlockId,
      layer: _nextLayerIndex++,
      position: pos,
    );
    addBlock(bd);
    var key = ValueKey(nextBlockId);
    _blockKeys[nextBlockId] = key;
    blocks[nextBlockId] = bd;
    buildBlocks.add(MovableBlock(block: bd, valKey: key));
    ref.read(blockPositionAndFocusProvider(nextBlockId).notifier).state = (
      bd.position,
      true,
    );
    currentFocusedBlockId = nextBlockId;
    ref.read(blockComponentNotifier(nextBlockId++));
    promoteBlock(bd.bid);
  }

  void deleteBlock(int bid) {
    var b = blocks[bid];
    if (b == null) {
      return;
    }
    ref.read(linkController).deleteBlockLinks(bid);
    removeBlockFromBuckets(bid);
    buildBlocks.remove(MovableBlock(block: b, valKey: _blockKeys[bid]!));
    ref.read(stackRefreshNotifier.notifier).state ^= true;
    ref.invalidate(blockComponentNotifier(bid));
    ref.invalidate(blockPositionAndFocusProvider(bid));
    blocks.remove(bid);
    _blockKeys.remove(bid);
  }

  void onPointerHover(Offset locPos) {
    if (!receiveInput) {
      hitTestResult.type = HitTestResultType.none;
      return;
    }
    pointerHoverRawLoc = transformationController.toScene(locPos);
    pointerCurrentRawLoc = pointerHoverRawLoc;
    hitTest(screenToScene(locPos));
  }

  ///！注意！这是原始的位置他的坐标原点不是画布的左上角，由于flutter的特性，是画布缩放为0时的左上角，只用来做缩放，如果要计算画布坐标，务必换算
  Offset pointerCurrentRawLoc = Offset.zero;
  Offset screenToScene(Offset locPos) {
    //由于flutter过于逆天的坐标，我们这里还需要加上画布和屏幕视口的值来修正，和下面的drag的边界限制是一个原理
    var raw = transformationController.toScene(locPos);
    raw += Offset(
      CONTENT_HALF_WIDTH - _viewportHalfSize.dx,
      CONTENT_HALF_HEIGHT - _viewportHalfSize.dy,
    );
    return raw;
  }

  void onInputUpdate(ControllerInput input) {
    switch (input.behaviour) {
      case InputBehaviour.draggingCanvas:
        if (!receiveInput) {
          return;
        }
        moveCanvas(input.delta!);
        break;
      case InputBehaviour.zooming:
        if (!receiveInput) {
          return;
        }
        zoomCanvas(input.zoomDelta!);
        break;
      case InputBehaviour.leftButtonDown:
        if (!receiveInput) {
          hitTestResult.type = HitTestResultType.none;
          return;
        }
        //必须先hitTest一遍，否则在失去的焦点的窗口直接drag的话会沿用旧的结果（至少我测试出来应该是类似的原因，这种只是我的猜测）
        var canvasPosition = screenToScene(input.localPosition!);
        hitTest(canvasPosition);
        if (hitTestResult.type == HitTestResultType.block) {
          promoteBlock(hitTestResult.id!);
          var blockLocPos =
              canvasPosition - blocks[hitTestResult.id!]!.position;
          ref
              .read(inBlockHitTestEngine)
              .doInBlockHitTest(hitTestResult.id!, blockLocPos);
        } else if (isLinking && hitTestResult.type != HitTestResultType.port) {
          isLinking = false;
        }
        break;
      case InputBehaviour.leftButtonUp:
        if (!receiveInput) {
          return;
        }
        eraseHitTestResult(input.localPosition!);
        if (isLinking) {
          isLinking = false;
          //还需要再次刷新一次，否则的话在快速移动的时候会出现port没跟上的情况
          notifyLinkController(input.localPosition!);
          ref.read(linkController).endLink();
        }
        break;
      case InputBehaviour.dragging:
        if (!receiveInput) {
          return;
        }
        pointerCurrentRawLoc = transformationController.toScene(
          input.localPosition!,
        );
        if (isLinking) {
          if (hitTestResult.type == HitTestResultType.port) {
            notifyLinkController(input.localPosition!);
          } else {
            isLinking = false;
          }
        } else {
          moveBlock(screenToScene(input.localPosition!));
        }
        break;
      case InputBehaviour.rightButtonClicking:
        hitTestResult.position = screenToScene(input.localPosition!);
        showRightButtonOverlay(input.globalPosition!, hitTestResult);
      case InputBehaviour.doubleClicking:
        var canvasPos = screenToScene(input.localPosition!);
        hitTest(canvasPos);
        if (hitTestResult.type == HitTestResultType.block) {
          var blockLocPos = canvasPos - blocks[hitTestResult.id!]!.position;
          ref
              .read(inBlockHitTestEngine)
              .doInBlockHitTest(
                hitTestResult.id!,
                blockLocPos,
                inputBehaviour: InputBehaviour.doubleClicking,
              );
        }
      default:
        break;
    }
  }

  ///hitTest实现，让gemini开始他的表演
  static const double CANVAS_WIDTH = 7000;
  static const double BUCKET_WIDTH = 350;
  // 空间哈希桶，O(1)定位
  late final List<List<int>> _buckets;
  late final int _numBuckets;
  // 全局层级计数器
  int _nextLayerIndex = 1;

  /// 辅助函数：计算一个Block占用的桶的索引范围
  ({int start, int end}) _getBucketIndices(BlockData block) {
    final startIdx = (block.position.dx / BUCKET_WIDTH).floor();
    final endIdx = ((block.position.dx + BlockData.width) / BUCKET_WIDTH)
        .floor();

    // 确保索引在有效范围内
    return (
      start: startIdx.clamp(0, _numBuckets - 1),
      end: endIdx.clamp(0, _numBuckets - 1),
    );
  }

  /// 当选中一个节点时，提升其层级
  void promoteBlock(int bid) {
    if (blocks.containsKey(bid)) {
      blocks[bid]!.layer = _nextLayerIndex++;
      var key = _blockKeys[bid]!;
      for (var i = 0; i < buildBlocks.length; i++) {
        if (buildBlocks[i].key == key) {
          var tmp = buildBlocks[i];
          buildBlocks.removeAt(i);
          buildBlocks.add(tmp);
          break;
        }
      }
      if (currentFocusedBlockId != null && currentFocusedBlockId != bid) {
        var cfbp = ref.read(
          blockPositionAndFocusProvider(currentFocusedBlockId!).notifier,
        );
        cfbp.state = (cfbp.state.$1, false);
      }
      currentFocusedBlockId = bid;
      var bp = ref.read(blockPositionAndFocusProvider(bid).notifier);
      bp.state = (bp.state.$1, true);
      ref.read(stackRefreshNotifier.notifier).state ^= true;
      //改一下flag，true false都可以，只是通知刷新
    }
  }

  /// 添加一个新Block，或在拖拽结束后重新插入一个Block
  void addBlock(BlockData block) {
    final indices = _getBucketIndices(block);
    for (int i = indices.start; i <= indices.end; i++) {
      // 避免重复添加
      if (!_buckets[i].contains(block.bid)) {
        _buckets[i].add(block.bid);
      }
    }
  }

  /// 仅从桶中移除，用于拖拽开始
  void removeBlockFromBuckets(int bid) {
    if (!blocks.containsKey(bid)) return;

    final block = blocks[bid]!;
    final indices = _getBucketIndices(block);
    for (int i = indices.start; i <= indices.end; i++) {
      _buckets[i].remove(bid);
    }
  }

  late HitTestResult hitTestResult;

  void resetHitTestHl(HitTestResultType type) {
    switch (type) {
      case HitTestResultType.port:
        ref.read(linkController).eraseHighlightPort();
        break;
      case HitTestResultType.link:
        ref.read(linkController).eraseHighlightLink();
        break;
      default:
        break;
    }
  }

  /// 核心函数：给定一个offset，进行hittest，返回层级最高的bid
  void hitTest(Offset position) {
    if(!receiveInput) return;
    final mouseX = position.dx;
    print("dointHitTest");
    // 1. 粗筛：O(1) 找到鼠标所在的桶
    if (mouseX < 0 || mouseX >= CANVAS_WIDTH) return;
    final bucketIndex = (mouseX / BUCKET_WIDTH).floor();

    final List<int> candidateBids = _buckets[bucketIndex];
    if (candidateBids.isEmpty) return;

    // 2. 精筛：遍历桶内少量候选者
    final List<BlockData> hits = [];
    for (final bid in candidateBids) {
      final block = blocks[bid]!;
      // 先判断是不是在端口和块范围内
      if (block.isInsidePortRange(position)) {
        hits.add(block);
      }
    }

    if (hits.isEmpty) {
      var res = ref.read(linkController).hitTestLink(position);
      if (res != null) {
        hitTestResult.type = HitTestResultType.link;
        hitTestResult.id = res;
      } else {
        hitTestResult.type = HitTestResultType.none;
      }
      return;
    }
    bool result = false;
    if (hits.length != 1) {
      // 3. Z轴解析：从所有命中者中找到层级最高的
      hits.sort((a, b) => b.layer.compareTo(a.layer));
    }
    var precise = hits.first.isInsideBlock(position);
    if (precise == 0) {
      hitTestResult.type = HitTestResultType.block;
      hitTestResult.id = hits.first.bid;
      return;
    } else if (precise == 1) {
      result = ref
          .read(linkController)
          .isInsideOutPortRange(hits.first.bid, position);
    } else {
      result = ref
          .read(linkController)
          .isInsideInPortRange(hits.first.bid, position);
    }
    if (result) {
      isLinking = result;
      hitTestResult.type = HitTestResultType.port;
    } else {
      var res = ref.read(linkController).hitTestLink(position);
      if (res != null) {
        hitTestResult.type = HitTestResultType.link;
        hitTestResult.id = res;
      } else {
        hitTestResult.type = HitTestResultType.none;
      }
    }
  }

  bool isMovingBlock = false;
  double? movingBlockH;
  Offset? pointerBlockDelta;

  ///通过provider更新命中块
  void moveBlock(Offset position) {
    if (hitTestResult.type != HitTestResultType.block) {
      return;
    }
    if (!isMovingBlock) {
      removeBlockFromBuckets(hitTestResult.id!);
      isMovingBlock = true;
      var b = blocks[hitTestResult.id!]!;
      movingBlockH = b.height.toDouble();
      pointerBlockDelta = position - b.position;
      ref.read(linkController).beforeUpdatePortPos(hitTestResult.id!);
    } else {
      var nPos = Offset(
        (position.dx - pointerBlockDelta!.dx).clamp(0, 6700),
        (position.dy - pointerBlockDelta!.dy).clamp(0, 4000 - movingBlockH!),
      );
      ref
          .read(blockPositionAndFocusProvider(hitTestResult.id!).notifier)
          .state = (
        nPos,
        true,
      );
      currentFocusedBlockId = hitTestResult.id;
      ref.read(linkController).updatePortsPos(hitTestResult.id!, nPos);
    }
  }

  bool isLinking = false;

  void notifyLinkController(Offset position) {
    ref.read(linkController).processLinkingInputs(screenToScene(position));
  }

  //当鼠标抬起的时候，就可以删除命中
  void eraseHitTestResult(Offset position) {
    if (isMovingBlock) {
      position = screenToScene(position);
      position = position - pointerBlockDelta!;
      endDrag(position);
    }
    hitTestResult.type = HitTestResultType.none;
    movingBlockH = null;
    pointerBlockDelta = null;
  }

  void endDrag(Offset pos) {
    pos = Offset(pos.dx.clamp(0, 6700), pos.dy.clamp(0, 4000 - movingBlockH!));
    ref.read(linkController).endUpdatePortsPos(hitTestResult.id!, pos);
    addBlock(blocks[hitTestResult.id!]!);
    isMovingBlock = false;
  }

  ///canvasMove

  void moveCanvas(Offset delta) {
    //必须要clone一份并且重新赋值，否则不会刷新！
    var tempMat = transformationController.value.clone();
    //这里我们需要控制一下边界，让画布不会飞出屏幕
    double scale = tempMat[0]; // 当前缩放比例
    // 应用 delta 并 clamp
    //你敢信我调整这个用了一个小时！我iPad上有这个草图，反正算起来是个很抽象的东西
    //简单来讲，这个东西他的0坐标不在中心或者左上角，是在“当缩放为1也就是屏幕原来大小的时候屏幕左上角所在的位置”
    //如果开了debug的话，就是那个黄色的警戒框的左上角。。。
    //然后画个图大概就能想通了
    double newX = (tempMat[12] + delta.dx).clamp(
      _viewportHalfSize.dx * 2 -
          (CONTENT_HALF_WIDTH + _viewportHalfSize.dx) * scale,
      (CONTENT_HALF_WIDTH - _viewportHalfSize.dx) * scale,
    );
    double newY = (tempMat[13] + delta.dy).clamp(
      _viewportHalfSize.dy * 2 -
          (CONTENT_HALF_HEIGHT + _viewportHalfSize.dy) * scale,
      (CONTENT_HALF_HEIGHT - _viewportHalfSize.dy) * scale,
    );
    tempMat[12] = newX;
    tempMat[13] = newY;
    transformationController.value = tempMat;
  }

  void zoomCanvas(double delta) {
    delta = delta.clamp(0.85, 1.15);

    const double minScale = 0.25;
    const double maxScale = 5.0;
    final Matrix4 cur = transformationController.value;
    final Matrix4 tmp = cur.clone();

    // 当前缩放（假设你只做等比缩放，使用 m[0] / m[5]）
    final double curScale = tmp[0];
    double targetScale = (curScale * delta).clamp(minScale, maxScale);

    // 如果缩放没变化就直接返回
    if ((targetScale - curScale).abs() < 1e-12) return;

    // focal 必须是 scene-space（content-local），如果 pointerHoverLoc 是 viewport point，先转换
    final Offset focal = pointerCurrentRawLoc;

    // 按 focal 缩放：先平移到 focal -> 缩放比例为 target/cur -> 再平移回
    final double scaleRatio = targetScale / curScale;
    tmp.translate(focal.dx, focal.dy);
    tmp.scale(scaleRatio);
    tmp.translate(-focal.dx, -focal.dy);

    // --- 计算允许的平移范围（采用你之前的思路） ---
    final double scale = targetScale;
    final double viewportW = _viewportHalfSize.dx * 2;
    final double viewportH = _viewportHalfSize.dy * 2;
    final double contentW = CONTENT_HALF_WIDTH * 2;
    final double contentH = CONTENT_HALF_HEIGHT * 2;

    double minX =
        _viewportHalfSize.dx * 2 -
        (CONTENT_HALF_WIDTH + _viewportHalfSize.dx) * scale;
    double maxX = (CONTENT_HALF_WIDTH - _viewportHalfSize.dx) * scale;

    double minY =
        _viewportHalfSize.dy * 2 -
        (CONTENT_HALF_HEIGHT + _viewportHalfSize.dy) * scale;
    double maxY = (CONTENT_HALF_HEIGHT - _viewportHalfSize.dy) * scale;

    // 当缩放后内容比视口小时 -> 居中处理（避免 minX>maxX 的奇怪情况）
    // 居中结果用一个合理的 translation（平均值）
    if (minX > maxX) {
      final double centeredX = (viewportW - contentW * scale) / 2;
      minX = maxX = centeredX;
    }
    if (minY > maxY) {
      final double centeredY = (viewportH - contentH * scale) / 2;
      minY = maxY = centeredY;
    }

    // 取缩放后 tmp 的平移分量并 clamp 到范围内
    double newX = tmp[12].clamp(minX, maxX);
    double newY = tmp[13].clamp(minY, maxY);

    // 如果 newX/newY 完全在范围内，说明可以「以焦点缩放」
    // 否则我们把平移修正到合法区间（这一步相当于“移动焦点以防飞出”）
    tmp[12] = newX;
    tmp[13] = newY;

    // 最终写回
    transformationController.value = tmp;
  }

  OverlayEntry? _overlayEntry;
  void showRightButtonOverlay(Offset globalPos, HitTestResult hitTestResult) {
    receiveInput = false;
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (_overlayEntry != null) {
                  _overlayEntry!.remove();
                  _overlayEntry = null;
                }
                receiveInput = true;
              },
            ),
            Positioned(
              top: globalPos.dy,
              left: globalPos.dx + 10, //稍微往外面偏移一点
              child: Builder(
                builder: (context) {
                  if (hitTestResult.type == HitTestResultType.block) {
                    return OnBlockPopUpMenu(
                      close: () {
                        if (_overlayEntry != null) {
                          _overlayEntry!.remove();
                          _overlayEntry = null;
                        }
                        receiveInput = true;
                      },
                      bid: hitTestResult.id!,
                    );
                  }
                  return BlankPositionPopUpMenu(
                    close: () {
                      if (_overlayEntry != null) {
                        _overlayEntry!.remove();
                        _overlayEntry = null;
                      }
                      receiveInput = true;
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
    if (canvasOverlay.currentContext != null) {
      Overlay.of(canvasOverlay.currentContext!).insert(_overlayEntry!);
    }
  }
}
