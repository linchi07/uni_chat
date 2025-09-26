import 'dart:ui';

import 'package:uni_chat/Editor/BlockComponents/components.dart';
import 'package:uni_chat/Editor/BlockComponents/components_layout_engine.dart';
import 'package:uni_chat/Editor/Core/link_painter.dart';
import 'package:uni_chat/Editor/Core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

///管理所有的线和端口的连接
class LinkController {
  Ref ref;
  LinkController(this.ref) {
    inPortBuckets = List.generate(
      gridHeight,
      (_) => List.generate(gridWidth, (_) => []),
    );
    outPortBuckets = List.generate(
      gridHeight,
      (_) => List.generate(gridWidth, (_) => []),
    );
  }
  Map<int, List<Port>> _inPorts = {};
  Map<int, List<Port>> _outPorts = {};

  ///这个主要是方便在移动的时候快速的找到每个块连接到的link，前面的int是指bid
  Map<int, List<Link>> _establishedLinksByBlocks = {};

  ///这个才是为了快速查找和重建设计的map
  Map<int, Link> _establishedLinks = {};

  int? currentSelectedLinkId;

  // 假设的常量
  static const double BUCKET_SIZE = 500.0;
  static const double CANVAS_WIDTH = 7000.0;
  static const double CANVAS_HEIGHT = 4000.0;

  // 计算网格维度
  final int gridWidth = (CANVAS_WIDTH / BUCKET_SIZE).ceil();
  final int gridHeight = (CANVAS_HEIGHT / BUCKET_SIZE).ceil();

  late List<List<List<Port>>> inPortBuckets;

  late List<List<List<Port>>> outPortBuckets;

  List<Link> tmpLinks = [];
  Port? highlightPort;
  Link? highlightLink;

  List<Link> persistLinks = [];

  void addOrUpdateInPorts(int bid, List<Port> ports) {
    _inPorts[bid] = ports;
    for (var port in ports) {
      addPortToBucket(port, inPortBuckets);
    }
  }

  void addOrUpdateOutPorts(int bid, List<Port> ports) {
    _outPorts[bid] = ports;
    for (var port in ports) {
      addPortToBucket(port, outPortBuckets);
    }
  }

  bool isInsideInPortRange(int bid, Offset localPosition) {
    var ports = _inPorts[bid];
    if (ports != null) {
      for (var port in ports) {
        ///由于两个点之间的间距远大于7px，所以直接就可以返回真，不用选出距离最小的
        if ((port.globalPosition - localPosition).distanceSquared <= 255) {
          if (!port.isLinked) {
            //由于inPort只能够同时连接一个输入，所以说如果已经连接的话就不高亮了
            linkingPort = port;
            highlightPort = port;
            ref.read(tmpLinkPainterNotifier.notifier).state ^= true;
          }
          return true;
        }
      }
    }
    return false;
  }

  bool isInsideOutPortRange(int bid, Offset localPosition) {
    var ports = _outPorts[bid];
    if (ports != null) {
      for (var port in ports) {
        ///由于两个点之间的间距远大于5px，所以直接就可以返回真，不用选出距离最小的
        if ((port.globalPosition - localPosition).distanceSquared <= 255) {
          linkingPort = port;
          highlightPort = port;
          ref.read(tmpLinkPainterNotifier.notifier).state ^= true;
          return true;
        }
      }
    }
    return false;
  }

  void eraseHighlightPort() {
    if (highlightPort != null) {
      highlightPort = null;
      ref.read(tmpLinkPainterNotifier.notifier).state ^= true;
    }
  }

  void eraseHighlightLink() {
    if (highlightLink != null) {
      highlightLink = null;
      ref.read(tmpLinkPainterNotifier.notifier).state ^= true;
    }
  }

  Port? linkingPort;
  bool isLinking = false;

  void processLinkingInputs(Offset pointer) {
    isLinking = true;
    if (linkingPort != null) {
      tmpLinks.clear();
      var l = Link(
        linkId: -1,
        inPort: linkingPort!,
        startPos: linkingPort!.globalPosition,
        outPort: Port.nullPort,
        endPos: pointer,
        color: linkingPort!.color,
        type: linkingPort!.shape,
      );

      l.computeBezierLinkPath();
      tmpLinks.add(l);
      highlightPort = findNearestAvailablePort(
        position: pointer,
        targetType: linkingPort!.dataType,
        buckets: (linkingPort!.type == PortType.inPort)
            ? outPortBuckets
            : inPortBuckets,
      );
      //依然用老方法来刷新
      ref.read(tmpLinkPainterNotifier.notifier).state ^= true;
    }
  }

  void endLink() {
    if (highlightPort != null) {
      if (highlightPort!.type == PortType.inPort) {
        establishLink(linkingPort!, highlightPort!);
      } else {
        establishLink(highlightPort!, linkingPort!);
      }
    }
    tmpLinks.clear();
    ref.read(tmpLinkPainterNotifier.notifier).state ^= true;
    isLinking = false;
    linkingPort = null;
    highlightPort = null;
  }

  int linkId = 0;

  void establishLink(Port from, Port to) {
    if (from.bid == to.bid) {
      //这样不可以！
      return;
    }
    var link = Link(
      linkId: linkId,
      outPort: from,
      startPos: from.globalPosition,
      inPort: to,
      endPos: to.globalPosition,
      color: from.color,
      type: from.shape,
    );
    //这里提前计算贝塞尔曲线
    link.computeBezierLinkPath();
    if (_establishedLinksByBlocks.containsKey(from.bid)) {
      _establishedLinksByBlocks[from.bid]!.add(link);
    } else {
      _establishedLinksByBlocks[from.bid] = [link];
    }
    if (_establishedLinksByBlocks.containsKey(to.bid)) {
      _establishedLinksByBlocks[to.bid]!.add(link);
    } else {
      _establishedLinksByBlocks[to.bid] = [link];
    }
    _establishedLinks[linkId++] = link;
    to.isLinked = true;
    from.isLinked = true;
    if (to.links != null) {
      to.links!.add(link);
    } else {
      to.links = [link];
    }
    if (from.links != null) {
      from.links!.add(link);
    } else {
      from.links = [link];
    }
    ref
        .read(blockComponentNotifier(to.bid).notifier)
        .notifyAndUpdatePortConnection(to.portId, from);
    ref
        .read(blockComponentNotifier(from.bid).notifier)
        .notifyAndUpdatePortConnection(from.portId, to);
    refreshPersistLinks();
  }

  void refreshPersistLinks() {
    persistLinks = _establishedLinks.values.toList();
    ref.read(persistentLinkProvider.notifier).state ^= true;
  }

  void beforeUpdatePortPos(int bid) {
    var ls = _establishedLinksByBlocks[bid];
    tmpLinks = List.from(ls ?? []);
    if (ls != null) {
      for (var l in ls) {
        _establishedLinks.remove(l.linkId);
      }
    }
    var ip = _inPorts[bid];
    for (var p in ip!) {
      removePortFromBucket(p, inPortBuckets);
    }
    var op = _outPorts[bid];
    for (var p in op!) {
      removePortFromBucket(p, outPortBuckets);
    }
    refreshPersistLinks();
  }

  static const Offset PORT_LAYOUT_FIX = Offset(-20, 60);

  void updatePortsPos(int bid, Offset pos) {
    var inp = _inPorts[bid];
    if (inp != null) {
      for (int i = 0; i < inp.length; i++) {
        inp[i].globalPosition = pos + inp[i].localPosition + PORT_LAYOUT_FIX;
      }
    }
    var out = _outPorts[bid];
    if (out != null) {
      for (int i = 0; i < out.length; i++) {
        out[i].globalPosition = pos + out[i].localPosition + PORT_LAYOUT_FIX;
      }
    }
    for (int i = 0; i < tmpLinks.length; i++) {
      var l = tmpLinks[i];
      //这里不用判定inp和out是否空，因为如果是空的话就不可能链接到这个组件的
      //这里$1是bid，$2是outPortId
      //由于outPort的原始索引是负数，而且从-1开始，inPort的原始索引是正数从1开始，所以要特殊处理
      if (l.outPort.bid == bid) {
        l.startPos = out![-(l.outPort.portId) - 1].globalPosition;
      } else {
        l.endPos = inp![l.inPort.portId - 1].globalPosition;
      }
      l.computeBezierLinkPath();
    }
    ref.read(tmpLinkPainterNotifier.notifier).state ^= true;
  }

  void endUpdatePortsPos(int bid, Offset pos) {
    var inp = _inPorts[bid];
    if (inp != null) {
      for (int i = 0; i < inp.length; i++) {
        inp[i].globalPosition = pos + inp[i].localPosition + PORT_LAYOUT_FIX;
        addPortToBucket(inp[i], inPortBuckets);
      }
    }
    var out = _outPorts[bid];
    if (out != null) {
      for (int i = 0; i < out.length; i++) {
        out[i].globalPosition = pos + out[i].localPosition + PORT_LAYOUT_FIX;
        addPortToBucket(out[i], outPortBuckets);
      }
    }
    for (int i = 0; i < tmpLinks.length; i++) {
      var l = tmpLinks[i];
      //这里不用判定inp和out是否空，因为如果是空的话就不可能链接到这个组件的
      //这里$1是bid，$2是outPortId
      //由于outPort的原始索引是负数，而且从-1开始，inPort的原始索引是正数从1开始，所以要特殊处理
      if (l.outPort.bid == bid) {
        l.startPos = out![-(l.outPort.portId) - 1].globalPosition;
      } else {
        l.endPos = inp![l.inPort.portId - 1].globalPosition;
      }
      _establishedLinks[l.linkId] = l;
    }
    tmpLinks.clear();
    ref.read(tmpLinkPainterNotifier.notifier).state ^= true;
    refreshPersistLinks();
  }

  //下面是port的链接时的hitTest，依然是gemini

  void addPortToBucket(Port port, List<List<List<Port>>> buckets) {
    // 1. 计算 bucket 索引
    final int bucketX = (port.globalPosition.dx / BUCKET_SIZE).floor();
    final int bucketY = (port.globalPosition.dy / BUCKET_SIZE).floor();

    // 安全检查，确保索引在有效范围内
    if (bucketY >= 0 &&
        bucketY < gridHeight &&
        bucketX >= 0 &&
        bucketX < gridWidth) {
      // 2. 更新 Port 自身的索引缓存
      port.bucketIndex = (bucketX, bucketY);
      // 3. 将 Port 添加到对应的 bucket 列表中
      buckets[bucketY][bucketX].add(port);
    } else {
      // 如果端口在画布外，将其索引设置为无效值
      port.bucketIndex = (-1, -1);
    }
  }

  void removePortFromBucket(Port port, List<List<List<Port>>> buckets) {
    // 1. 直接从 Port 对象中获取 bucket 索引，无需重新计算！
    final (int bucketX, int bucketY) = port.bucketIndex;

    // 2. 检查索引是否有效
    if (bucketY >= 0 &&
        bucketY < gridHeight &&
        bucketX >= 0 &&
        bucketX < gridWidth) {
      // 3. 直接定位到 bucket 并删除该 Port
      // List.remove() 的效率取决于列表长度，但我们的bucket内元素通常很少
      buckets[bucketY][bucketX].remove(port);
    }
  }

  Port? findNearestAvailablePort({
    required Offset position, // 鼠标或连接线末端的当前位置
    required DataType targetType, // 正在寻找的端口数据类型
    required List<List<List<Port>>> buckets, // 在输入端口还是输出端口中寻找
  }) {
    Port? nearestPort;
    double minDistanceSq = double.infinity; // 使用距离的平方进行比较！

    // 1. 计算中心 bucket 的索引
    final int centerX = (position.dx / BUCKET_SIZE).floor();
    final int centerY = (position.dy / BUCKET_SIZE).floor();

    // 2. 遍历中心 bucket 及周围8个相邻 bucket (形成一个3x3的网格)
    for (int j = -1; j <= 1; j++) {
      for (int i = -1; i <= 1; i++) {
        final int currentY = centerY + j;
        final int currentX = centerX + i;

        // 3. 边界检查，跳过无效的 bucket 索引
        if (currentY < 0 ||
            currentY >= gridHeight ||
            currentX < 0 ||
            currentX >= gridWidth) {
          continue;
        }

        // 4. 获取 bucket 内的所有 port
        final List<Port> candidatePorts = buckets[currentY][currentX];

        // 5. 遍历这个小列表中的 port
        for (final port in candidatePorts) {
          // 6. 应用逻辑过滤
          if ((port.isLinked && port.type == PortType.inPort) ||
              port.dataType != targetType) {
            continue;
          }
          // 7. 计算距离的平方（避免开方）
          final double distanceSq =
              (port.globalPosition - position).distanceSquared;

          // 8. 如果找到更近的，就更新结果
          if (distanceSq < minDistanceSq) {
            minDistanceSq = distanceSq;
            nearestPort = port;
          }
        }
      }
    }
    //只有小于sqrt500px的才能被入选
    if (minDistanceSq > 500) {
      return null;
    }
    // 9. 返回找到的最近的 Port，如果没找到则返回 null
    return nearestPort;
  }

  ///接下来是贝塞尔曲线的hitTest，Gemini巨献

  /// 辅助函数：计算一个点到一条线段的最短距离的平方
  /// 这是标准的几何算法，高效且避免了开方(sqrt)
  double _distanceSqToLineSegment(Offset p, Offset v, Offset w) {
    final double l2 =
        (v.dx - w.dx) * (v.dx - w.dx) + (v.dy - w.dy) * (v.dy - w.dy);
    if (l2 == 0.0) {
      // 线段的起点和终点是同一个点
      return (p - v).distanceSquared;
    }

    // 将点p投影到线段所在的直线上
    final double t =
        ((p.dx - v.dx) * (w.dx - v.dx) + (p.dy - v.dy) * (w.dy - v.dy)) / l2;

    // 约束t在[0, 1]范围内，找到线段上离点p最近的点
    final double clampedT = t.clamp(0.0, 1.0);

    // 计算最近点坐标
    final Offset closestPoint = Offset(
      v.dx + clampedT * (w.dx - v.dx),
      v.dy + clampedT * (w.dy - v.dy),
    );

    return (p - closestPoint).distanceSquared;
  }

  static const double LINK_SELECTION_THRESHOLD = 10.0;
  static const double LINK_SELECTION_THRESHOLD_SQUARED = 100;

  int? hitTestLink(Offset position) {
    int? bestMatchId;
    // 我们寻找的是在阈值内，距离最近的线。所以初始最小距离就是阈值本身。
    double minDistanceSq = LINK_SELECTION_THRESHOLD_SQUARED;
    var allLinks = _establishedLinks;
    for (final link in allLinks.values) {
      // --- 第一层过滤: 粗略的包围盒检测 (Broad Phase) ---
      // 直接使用缓存的边界值，无对象创建
      if (position.dx < link.minX - LINK_SELECTION_THRESHOLD ||
          position.dx > link.maxX + LINK_SELECTION_THRESHOLD ||
          position.dy < link.minY - LINK_SELECTION_THRESHOLD ||
          position.dy > link.maxY + LINK_SELECTION_THRESHOLD) {
        continue; // 鼠标完全在线条的包围盒之外，快速跳过
      }

      // --- 第二层过滤: 精确的折线距离检测 (Narrow Phase) ---
      final points = link.cachedPoints;
      if (points == null || points.length < 2) {
        continue;
      }

      // 遍历由离散点构成的每一条短线段
      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];

        // 计算鼠标位置到这条短线段的距离的平方
        final double distSq = _distanceSqToLineSegment(position, p1, p2);

        // 如果这个距离比我们已知的最近距离还要小
        if (distSq < minDistanceSq) {
          // 更新最近距离和最佳匹配的ID
          minDistanceSq = distSq;
          bestMatchId = link.linkId;
        }
      }
    }
    if (bestMatchId == null) {
      return null;
    }
    highlightLink = _establishedLinks[bestMatchId];
    if (highlightLink != null) {
      ref.read(tmpLinkPainterNotifier.notifier).state ^= true;
    }
    return bestMatchId;
  }

  void deleteBlockLinks(int bid) {
    var links = _establishedLinksByBlocks.remove(bid);
    if (links != null) {
      for (Link l in links) {
        if (l.inPort.bid == bid) {
          l.outPort.links?.remove(l);
          l.outPort.isLinked = false;
          ref.read(blockComponentNotifier(l.outPort.bid).notifier).notifyAndUpdatePortConnection(l.outPort.portId,l.outPort);
          _establishedLinksByBlocks[l.outPort.bid]?.remove(l);
        } else {
          l.inPort.links?.remove(l);
          l.inPort.isLinked = false;
          ref.read(blockComponentNotifier(l.inPort.bid).notifier).notifyAndUpdatePortConnection(l.inPort.portId,l.inPort);
          _establishedLinksByBlocks[l.inPort.bid]?.remove(l);
        }
        _establishedLinks.remove(l.linkId);
      }
    }
    refreshPersistLinks();
    var iP = _inPorts[bid];
    if (iP != null) {
      for (var p in iP) {
        removePortFromBucket(p, inPortBuckets);
      }
    }
    var oP = _outPorts[bid];
    if (oP != null) {
      for (var p in oP) {
        removePortFromBucket(p, outPortBuckets);
      }
    }
  }
}
