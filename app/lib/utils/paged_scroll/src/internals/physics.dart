import 'package:flutter/material.dart';

typedef OnOverScrollCallback = void Function(double overscrollDelta);

class OverScrollTransferPhysics extends ScrollPhysics {
  final OnOverScrollCallback onOverScroll;
  final void Function() onOverScrollEnd;
  const OverScrollTransferPhysics({
    required this.onOverScroll,
    required this.onOverScrollEnd,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  OverScrollTransferPhysics applyTo(ScrollPhysics? ancestor) {
    return OverScrollTransferPhysics(
      onOverScrollEnd: onOverScrollEnd,
      onOverScroll: onOverScroll,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // offset > 0 表示向下拉（内容向 scrollMin 移动）
    // offset < 0 表示向上拉（内容向 scrollMax 移动）

    // 1. 检查是否正在向头部溢出 (Over scroll at top/start)
    if (offset > 0) {
      // 还是否有空间可以滚动？
      final double roomToTop = position.pixels - position.minScrollExtent;

      if (roomToTop <= 0) {
        // 已经在边界或越界了，完全拦截
        onOverScroll(offset);
        return 0.0;
      } else if (offset > roomToTop) {
        // 还没到边界，但是这次滑动会“撞墙”
        // 计算溢出量：总滑动量 - 到墙的距离
        final double overscroll = offset - roomToTop;

        onOverScroll(overscroll);

        // 仅消费到达墙边的距离，剩下的被拦截了
        return roomToTop;
      }
    }

    // 2. 检查是否正在向尾部溢出 (Over scroll at bottom/end)
    if (offset < 0) {
      // 还是否有空间可以滚动？
      final double roomToBottom = position.maxScrollExtent - position.pixels;

      if (roomToBottom <= 0) {
        // 已经在边界或越界了，完全拦截
        onOverScroll(offset);
        return 0.0;
      } else if (offset.abs() > roomToBottom) {
        // 还没到边界，但是这次滑动会“撞墙”
        // 注意 offset 是负数，roomToBottom 是正数
        final double overscroll = offset + roomToBottom;

        onOverScroll(overscroll);

        // 仅消费到达墙边的距离（注意方向）
        return -roomToBottom;
      }
    }

    // 3. 其他情况：未撞墙，表现完全沿用 parent (比如 BouncingScrollPhysics 的阻尼效果等)
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // 检查是否试图滚动到头部边界之外 (Top/Left)
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) {
      // 刚好撞到头部边界
      return value - position.minScrollExtent;
    }
    if (value < position.minScrollExtent &&
        position.minScrollExtent == position.pixels) {
      // 已经在头部边界，还想继续往上滚 -> 完全拦截
      return value - position.minScrollExtent;
    }

    // 检查是否试图滚动到尾部边界之外 (Bottom/Right)
    if (value > position.maxScrollExtent &&
        position.maxScrollExtent > position.pixels) {
      // 刚好撞到尾部边界
      return value - position.maxScrollExtent;
    }
    if (value > position.maxScrollExtent &&
        position.maxScrollExtent == position.pixels) {
      // 已经在尾部边界，还想继续往下滚 -> 完全拦截
      return value - position.maxScrollExtent;
    }

    // 如果没有越界，返回 0.0 表示允许该滚动
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    onOverScrollEnd();
    return super.createBallisticSimulation(position, velocity);
  }
}
