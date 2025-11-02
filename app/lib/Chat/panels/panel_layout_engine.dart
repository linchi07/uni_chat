import 'dart:convert';
import 'dart:ffi';

import 'package:uni_chat/Chat/chat_page_main.dart';
import 'package:uni_chat/Chat/panels/basic_pannel.dart';
import 'package:uni_chat/Chat/panels/panel_data.dart';
import 'package:uni_chat/Chat/panels/panel_factory.dart';
import 'package:uni_chat/Chat/panels/panel_widgets/panels.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Layout {
  final int id;
  final String name;
  late int x;
  late int y;
  int width;
  int height;
  final PanelLayoutEngine _layoutEngine;
  get spaces => _layoutEngine.spaces;

  Layout({
    required this.id,
    required this.name,
    int? xPos,
    int? yPos,
    required this.width,
    required this.height,
    required PanelLayoutEngine layoutEngine,
  }) : _layoutEngine = layoutEngine {
    x = xPos ?? 0;
    y = yPos ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }

  /// 从 JSON Map 创建 Layout 对象
  static Layout fromJson(
    Map<String, dynamic> json,
    PanelLayoutEngine layoutEngine,
  ) {
    return Layout(
      id: json['id'],
      name: json['name'],
      xPos: json['x'],
      yPos: json['y'],
      width: json['width'],
      height: json['height'],
      layoutEngine: layoutEngine,
    );
  }

  int get size => width * height;
  @override
  String toString() {
    return 'Layout{id: $id, name: $name, x: $x, y: $y, width: $width, height: $height, size: $size}';
  }

  // 添加 copyWith 方法
  Layout copyWith({
    int? id,
    String? name,
    int? x,
    int? y,
    int? width,
    int? height,
    PanelLayoutEngine? layoutEngine,
  }) {
    return Layout(
      id: id ?? this.id,
      name: name ?? this.name,
      xPos: x ?? this.x,
      yPos: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      layoutEngine: layoutEngine ?? this._layoutEngine,
    );
  }

  (int, int)? findSpace() {
    for (int i = 0; i < _layoutEngine.horizontalAxisCount; i++) {
      for (int j = 0; j < _layoutEngine.verticalAxisCount; j++) {
        if (spaces[j][i] == 0) {
          if (searchFreeArea(j, i)) {
            return (j, i);
          }
        }
      }
    }
    return null;
  }

  bool searchFreeArea(int x, int y) {
    //这里就是这么写的，纵轴的宽是宽，横轴的宽是高，这个道理
    if (_layoutEngine.horizontalAxisCount < y + height ||
        _layoutEngine.verticalAxisCount < x + width) {
      return false;
    }
    for (int i = y; i < y + height; i++) {
      for (int j = x; j < x + width; j++) {
        if (spaces[j][i] != 0) {
          return false;
        }
      }
    }
    return true;
  }

  bool _searchArea(int x, int y) {
    //这里就是这么写的，纵轴的宽是宽，横轴的宽是高，这个道理
    if (_layoutEngine.horizontalAxisCount < y + height ||
        _layoutEngine.verticalAxisCount < x + width) {
      return false;
    }
    for (int i = y; i < y + height; i++) {
      for (int j = x; j < x + width; j++) {
        if (spaces[j][i] < 0) {
          return false;
        }
      }
    }
    return true;
  }

  ///标记了一处地点，并且统计那些需要被挤出去的名单
  Set<int> markAsTerritory(int x, int y) {
    Set<int> needToBePushed = {};
    for (int i = y; i < y + height; i++) {
      for (int j = x; j < x + width; j++) {
        if (spaces[j][i] > 0 && !needToBePushed.contains(spaces[j][i])) {
          needToBePushed.add(spaces[j][i]);
          //这里必须要让他提前把领地让出来，否则的在尺寸不一样的面板的时候，他会出现我占领了挤掉的面板的一部分土地，但是还有一部分还是归属原来的面板
          //这甚至能导致我自己把自己挤走这种脑残事情出现
          //其实这里不应该用问号，因为理论上这个panel一定存在，正确的做法是直接抛出未定义错误
          _layoutEngine.panelsLayout[spaces[j][i]]?.giveOutTerrain();
        }
        spaces[j][i] = -id;
      }
    }
    return needToBePushed;
  }

  ///出让区域，这样就可以swap了
  void giveOutTerrain() {
    for (int i = y; i < y + height; i++) {
      for (int j = x; j < x + width; j++) {
        spaces[j][i] = 0;
      }
    }
  }

  ///放置
  void settleDown(int x, int y) {
    for (int i = y; i < y + height; i++) {
      for (int j = x; j < x + width; j++) {
        spaces[j][i] = id;
      }
    }
    this.x = x;
    this.y = y;
  }

  ///当触发面板移动或者缩放时，会调用此方法，把别的面板给挤走
  void squish(int x, int y) {
    if (_layoutEngine.horizontalAxisCount < y + height) {
      return;
    }
    if (x + width > _layoutEngine.verticalAxisCount) {
      _layoutEngine.verticalAxisCount = x + width;
      _layoutEngine._ref.read(stackRefreshNotifier.notifier).state ^= true;
    }
    for (var t in markAsTerritory(x, y)) {
      _layoutEngine.panelsLayout[t]?.beSquish();
    }
    settleDown(x, y);
    _layoutEngine.notifyPanelAction(name);
  }

  ///被别的面板给挤走
  ///这里的思路是一个递归的调用，当一个面板被重新放置或者他扩容的时候，他会把其他的面板给挤走
  ///然后被挤走的面板再找到位置，把这里的面板给挤走
  ///递归调用从而最终找到位置
  ///而且每次挤走都会把当前格子标为负数，意味着这里不能被占用并且挤出去，防止死循环
  void beSquish() {
    //储存垂直索引起始点
    var x = this.x;
    var y = this.y;
    do {
      for (int i = y; i < _layoutEngine.horizontalAxisCount; i++) {
        //缩进指针，这是为了让他在横向布局上更加紧凑，也就是类似于向别的列借空间的思路
        for (int p = x - 1; p >= 0; p--) {
          if (spaces[p][i] != 0) {
            break;
          }
          x = p;
        }
        for (int j = x; j < _layoutEngine.verticalAxisCount; j++) {
          if (spaces[j][i] < 0) {
            continue;
          } else {
            //如果找到了可以挤的地方
            if (_searchArea(j, i)) {
              for (var t in markAsTerritory(j, i)) {
                _layoutEngine.panelsLayout[t]?.beSquish();
              }
              //这里是这样的，首先先标记为领地，然后把别的面板给挤走引发连锁反应
              //由于调用是递归的，所以当这里的安顿被调用的时候，更后面的面板已经被放置了，就可以安心反转id，重归于好了
              settleDown(j, i);
              _layoutEngine.notifyPanelAction(name);
              return;
            }
          }
        }
      }
      //找不到，尝试让控制器扩容列表
      if (_layoutEngine.verticalAxisCount ==
          _layoutEngine.maxVerticalAxisCount) {
        x = _layoutEngine.verticalAxisCount++;
        //扩容的时候刷新一下，由于stack和那个容器是一个widget,，所以都能通知到
        _layoutEngine.expandSpaceX();
        _layoutEngine._ref.read(stackRefreshNotifier.notifier).state ^= true;
        y = 0;
      } else {
        //然后就可以重新尝试了，注意，由于我们的二维数组始终是最大的空间，所以直接改逻辑索引不用担心越界问题
        //这种非迭代器的循环就是好在能够随便改东西不会给你扔错误
        //而且注意这里x和j不是零，是因为我们的思路是：新开一列把面板放在新的一列中，如果重置为0的话，面板可能会放在前面列中的空闲空间里
        //是的，这样本身没问题，但是会打乱面板的上下文关系，所以这里需要重新计算一下
        x = _layoutEngine.verticalAxisCount++;
        //扩容的时候刷新一下，由于stack和那个容器是一个widget,，所以都能通知到
        _layoutEngine._ref.read(stackRefreshNotifier.notifier).state ^= true;
        y = 0;
      }
    } while (true);
  }

  ///找到所有可以补位的面板
  Set<int> findCandidate() {
    Set<int> candidates = {};
    //我们的候选人只能是紧贴着当前面板的后面的，或者如果面板后面无人的话，那么就是下一行的第一个面板
    if (_layoutEngine.verticalAxisCount > x + width) {
      //通知所有这个面板的后面的元素（对于一个高为2的面板，他后面可能有两列元素）
      //这里高度不用设置边界检查，因为不可能超出边界，如果真的超出了那也是未定义行为
      //顺便注意一下，比如一个 1x2 的面板 A 被移除了，它右边紧邻的是一个 2x2 的面板 B，B 的左上角 y 坐标和 A 的 y 坐标不一致。
      // 当前的 findCandidate 理论上依然是会识别到的，因为他判断候选人的逻辑是：只要你领地和我接壤，我就通知你为潜在候选人。
      for (int i = 0; i < height; i++) {
        var c = spaces[x + width][y + i];
        if (c > 0 && c != id) {
          candidates.add(c);
        }
      }
    } else {
      if (y + height < _layoutEngine.horizontalAxisCount) {
        var c = spaces[0][y + height];
        if (c > 0 && c != id) {
          candidates.add(c);
        }
      }
    }
    return candidates;
  }

  ///当前一个面板被删除或者被移走，而且必须要是紧贴的相临面板（防止把用户手动放的特殊位置的面板给打乱了）
  ///此时调用这个方法启动补位机制，把他空出来的位置给补上
  ///和上面的squish不同，他虽然也是递归，但是始终是先调用父级补位，然后调用子级补位
  void beCandidate() {
    (int, int)? lastAvailable;
    bool breakFlag = false;
    //先把自己的地方给让出来
    for (var i = 0; i < width; i++) {
      for (var j = 0; j < height; j++) {
        if (spaces[x + i][y + j] == id) {
          spaces[x + i][y + j] = 0;
        }
      }
    }
    for (int i = y; i >= 0; i--) {
      for (int j = x; j >= 0; j--) {
        if (spaces[j][i] == 0) {
          if (searchFreeArea(j, i)) {
            lastAvailable = (j, i);
          } else {
            continue;
          }
        } else {
          breakFlag = true;
          break;
        }
      }
      if (breakFlag) {
        break;
      }
    }
    if (lastAvailable == null) return;
    //然后再占用新的地方，注意，必须要先占用再找候选人，否则会两个来回死循环互相让对方为候选人，然后就会so了
    //同样将其标记为负数值，否则还是有循环来回候选人的问题
    for (var i = 0; i < width; i++) {
      for (var j = 0; j < height; j++) {
        spaces[lastAvailable.$1 + i][lastAvailable.$2 + j] = -id;
      }
    }
    //这里我们在面板的坐标移动之前找到候补面板，否则会乱套
    var c = findCandidate();
    //现在在移动
    x = lastAvailable.$1;
    y = lastAvailable.$2;
    _layoutEngine.notifyPanelAction(name);
    //和squish不一样，我们移动之后再让候补面板移动，这点很不同
    for (var ci in c) {
      if (ci != id) {
        _layoutEngine.panelsLayout[ci]?.beCandidate();
      }
    }
    settleDown(x, y);
  }
}

//特别说明，这里的actualPx是比如横轴的像素数量
//而这里的axisCount是轴的数量
//而perUnit是宽，也就是比如横轴宽是纵轴的像素除以横轴数量，这点非常绕，一定要牢记
class LayoutConfig {
  final double horizontalAxisActualPixels;
  final double verticalAxisActualPixels;
  final int maxVerticalAxisCount;
  final int horizontalAxisCount;
  final int verticalAxisCount;
  double get horizontalAxisPixelPerUnit =>
      verticalAxisActualPixels /
      (horizontalAxisCount + 1); //由于是top定位，所以说最下面那个根轴不用，但是计算的时候却要加回去
  double get verticalAxisPixelPerUnit =>
      horizontalAxisActualPixels / maxVerticalAxisCount;

  LayoutConfig({
    required this.horizontalAxisActualPixels,
    required this.verticalAxisActualPixels,
    required this.maxVerticalAxisCount,
    required this.horizontalAxisCount,
    required this.verticalAxisCount,
  });

  LayoutConfig copyWith({
    double? horizontalAxisActualPixels,
    double? verticalAxisActualPixels,
    int? maxVerticalAxisCount,
    int? horizontalAxisCount,
    int? verticalAxisCount,
  }) {
    return LayoutConfig(
      horizontalAxisActualPixels:
          horizontalAxisActualPixels ?? this.horizontalAxisActualPixels,
      verticalAxisActualPixels:
          verticalAxisActualPixels ?? this.verticalAxisActualPixels,
      maxVerticalAxisCount: maxVerticalAxisCount ?? this.maxVerticalAxisCount,
      horizontalAxisCount: horizontalAxisCount ?? this.horizontalAxisCount,
      verticalAxisCount: verticalAxisCount ?? this.verticalAxisCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LayoutConfig &&
        horizontalAxisActualPixels == other.horizontalAxisActualPixels &&
        verticalAxisActualPixels == other.verticalAxisActualPixels &&
        maxVerticalAxisCount == other.maxVerticalAxisCount &&
        horizontalAxisCount == other.horizontalAxisCount &&
        verticalAxisCount == other.verticalAxisCount;
  }

  @override
  int get hashCode => Object.hash(
    horizontalAxisActualPixels,
    verticalAxisActualPixels,
    maxVerticalAxisCount,
    horizontalAxisCount,
    verticalAxisCount,
  );
}

final layoutConfigProvider = StateProvider<LayoutConfig>((ref) {
  return LayoutConfig(
    horizontalAxisActualPixels: 1000,
    verticalAxisActualPixels: 1000,
    maxVerticalAxisCount: 10,
    horizontalAxisCount: 10,
    verticalAxisCount: 0,
  );
});

final panelLayoutEngineProvider = Provider<PanelLayoutEngine>((ref) {
  return PanelLayoutEngine(ref: ref);
});

class PanelLayoutEngine {
  late Ref _ref;
  late LayoutConfig _config;

  // 保存当前配置的引用
  LayoutConfig get config => _config;

  // 使用 getter 访问配置属性
  double get horizontalAxisActualPixels => _config.horizontalAxisActualPixels;
  double get verticalAxisActualPixels => _config.verticalAxisActualPixels;
  int get maxVerticalAxisCount => _config.maxVerticalAxisCount;
  int get horizontalAxisCount => _config.horizontalAxisCount;
  int get verticalAxisCount => _config.verticalAxisCount;
  set verticalAxisCount(val) {
    var n = _ref.read(layoutConfigProvider.notifier);
    n.state = n.state.copyWith(verticalAxisCount: val);
    //注意一下，这里不能用up
  }

  PanelLayoutEngine({required Ref ref}) {
    _ref = ref;
    // 初始化时获取当前配置
    _config = ref.read(layoutConfigProvider);

    // 监听配置变化
    ref.listen<LayoutConfig>(layoutConfigProvider, (previous, next) {
      handleResize(next);
    });
    //这里采用的是物理分配最大的数组，但是我们逻辑上动态扩容和缩容，也就是维持vertical axis count，防止越界问题。
    availableSpaceCount = horizontalAxisCount * verticalAxisCount;
    spaces = List.generate(
      maxVerticalAxisCount,
      (_) => List.filled(horizontalAxisCount, 0, growable: true),
    );
  }
  bool get isSoftLimitExceeded => verticalAxisCount > maxVerticalAxisCount;

  void expandSpaceX() {
    spaces.add(List.filled(horizontalAxisCount, 0));
  }

  void expandSpaceY() {
    for (var i = 0; i < horizontalAxisCount; i++) {
      spaces[i].add(0);
    }
  }

  int availableSpaceCount = 0;
  //对于这个二维数组，接下来会看到j i i j 乱飞
  //记住，对于这个数组不论在什么时候都是x轴在前，y轴在后也就是[x][y]
  List<List<int>> spaces = [];
  Map<String, Widget> panels = {};
  Map<int, Layout> panelsLayout = {};
  int currentPanelIndex = 1;
  //没错id必须从1开始，因为0代表这块地是空的。。。。绝对不是我想要仿效lua
  bool checkPanelFit(PanelData panelData) {
    return availableSpaceCount >= panelData.layout.size;
  }

  bool isLayoutInvalid = false;

  void handleResize(LayoutConfig newConfig) {
    if (newConfig.maxVerticalAxisCount == config.maxVerticalAxisCount &&
        config.horizontalAxisCount == newConfig.horizontalAxisCount) {
      _config = newConfig;
      return;
    }
    var previousConfig = _config;
    if (newConfig.horizontalAxisCount < previousConfig.horizontalAxisCount) {
      // --- 步骤 1: 处理极端情况 ---
      // 找出当前所有面板中最高的一个
      int tallestPanelHeight = 0;
      for (var layout in panelsLayout.values) {
        if (layout.height > tallestPanelHeight) {
          tallestPanelHeight = layout.height;
        }
      }

      // 如果新的可用高度（horizontalAxisCount）连最高的面板都放不下
      if (tallestPanelHeight > 0 &&
          newConfig.horizontalAxisCount < tallestPanelHeight) {
        // 标记布局为无效状态
        isLayoutInvalid = true;
        // 通知 UI 强制刷新以显示“窗口过小”的提示
        _ref.read(stackRefreshNotifier.notifier).state ^= true;
        // 终止后续的布局计算，因为当前状态无法处理
        _config = newConfig; //这里还是得要记得更新config，否则的话resize不好用的
        return;
      }
    } else if (newConfig.horizontalAxisCount >
            previousConfig.horizontalAxisCount &&
        spaces.length < newConfig.horizontalAxisCount) {
      expandSpaceY();
    }
    // 如果能从无效状态恢复（窗口被拉大了），则重置标志
    if (isLayoutInvalid) {
      isLayoutInvalid = false;
      // UI 会在下一次刷新时自动恢复正常
    }
    // --- 步骤 2: 识别被影响的面板并标记无效区域 ---
    final Set<int> displacedPanelIds = {};
    final List<(int, int)> regionReplaced = [];
    // 临时标记，-1 代表“因 resize 而无效的区域”
    const int RESIZE_OBSTACLE = -114514;

    _config = newConfig;

    // 检查因高度缩小而失效的行 (horizontalAxisCount 变小)
    if (newConfig.horizontalAxisCount < previousConfig.horizontalAxisCount) {
      // 遍历所有被“裁掉”的行
      for (
        int i = newConfig.horizontalAxisCount;
        i < previousConfig.horizontalAxisCount;
        i++
      ) {
        // 遍历这些行中的所有列
        for (int j = 0; j < verticalAxisCount; j++) {
          final panelId = spaces[j][i];
          if (panelId > 0) {
            // 如果这个格子上有一个面板，记录下面板ID
            displacedPanelIds.add(panelId);
          }
          // 无论如何，都将这个格子标记为障碍物
          spaces[j][i] = RESIZE_OBSTACLE;
          regionReplaced.add((j, i));
        }
      }
    }

    // 检查因宽度缩小而失效的列 (verticalAxisCount 变小)
    // 注意：这里我们应该用 previousConfig.verticalAxisCount 来确保遍历范围正确
    if (newConfig.verticalAxisCount < previousConfig.verticalAxisCount) {
      // 遍历所有被“裁掉”的列
      for (
        int j = newConfig.verticalAxisCount;
        j < previousConfig.verticalAxisCount;
        j++
      ) {
        // 遍历这些列中的所有行
        for (int i = 0; i < previousConfig.horizontalAxisCount; i++) {
          final panelId = spaces[j][i];
          if (panelId > 0) {
            displacedPanelIds.add(panelId);
          }
          spaces[j][i] = RESIZE_OBSTACLE;
          regionReplaced.add((j, i));
        }
      }
    }

    // --- 步骤 3: 触发挤压 ---
    // 现在，让所有被影响的面板自己去找新家
    for (final panelId in displacedPanelIds) {
      final layout = panelsLayout[panelId];
      if (layout != null) {
        // 调用 beSquish()。
        // beSquish 内部的 searchArea 会因为我们设置的 RESIZE_OBSTACLE
        // 而自动避开这些无效区域，从而找到新的有效位置。
        layout.beSquish();
      }
    }

    // --- 步骤 4: 清理临时标记 ---
    //是的，正常情况下我们应该可以直接根据prev + new来判断并且删除坐标，但是不知道是什么玄学，反正就是删除不干净。。。
    //所以最好的方法就是这样弄，我相信这玩意扩容应该消耗不了多少性能的。
    for (final r in regionReplaced) {
      if (spaces[r.$1][r.$2] == RESIZE_OBSTACLE) spaces[r.$1][r.$2] = 0;
    }

    // --- 步骤 5: 收缩整理 ---
    shrinkVerticalAxis();
  }

  void shrinkAllOversizedPanels() {
    // 获取当前布局允许的最大高度
    final maxAllowedHeight = horizontalAxisCount;
    if (maxAllowedHeight <= 0) return; // 防止在极端情况下执行

    // 遍历所有面板
    for (var layout in panelsLayout.values) {
      // 如果面板的当前高度超过了允许的最大高度
      if (layout.height > maxAllowedHeight) {
        // 调用现有的 resizePanel 方法，将高度缩小到最大值，宽度保持不变
        resizePanel(layout.id, layout.width, maxAllowedHeight);
      }
    }

    // 缩小操作完成后，布局状态应该恢复正常
    isLayoutInvalid = false;
    // 强制刷新UI以显示新的布局
    _ref.read(stackRefreshNotifier.notifier).state ^= true;
  }

  bool placePanel(String pName, String pType) {
    var panelTuple = PanelsFactory.createPanel(pName, pType, this);
    var panelData = panelTuple.$1;
    var widgetSetUpFunc = panelTuple.$2;

    // ------------ 新逻辑开始 ------------
    var newLayout = panelData.layout; // 从 PanelData 获取 Layout 实例

    // 1. 让 Layout 自己寻找一个最佳起始点
    var startPos = newLayout.findSpace();
    //如果比垂直的值还高的话那确实没办法了
    if (newLayout.height > horizontalAxisCount) {
      return false;
    }

    while (startPos == null && verticalAxisCount < maxVerticalAxisCount) {
      verticalAxisCount++;
      startPos = newLayout.findSpace(); // 再次尝试
    }
    //只是作为托底来用，当ai或者用户意外的添加一块超大的面板的时候直接扩容整个数组
    while (startPos == null) {
      verticalAxisCount++;
      expandSpaceX();
      startPos = newLayout.findSpace();
    }

    // 2. 如果找到了位置，就执行 "挤压" 操作
    // 将 Layout 实例添加到引擎的追踪 map 中
    panelsLayout[newLayout.id] = newLayout;

    // 调用 squish，这将处理所有碰撞和连锁反应
    newLayout.squish(startPos.$1, startPos.$2);

    // 更新 panelData 中的最终位置 (squish内部已经更新了layout实例的x,y)
    // 这一步是为了确保 provider 中的数据同步
    final finalLayout = panelsLayout[newLayout.id]!;
    _ref.read(panelDataProvider(panelData.name).notifier).state = panelData
        .copyWith(layout: finalLayout);

    panels[panelData.name] = widgetSetUpFunc(panelData.name);
    return true;
  }

  void dropPanel(String name) {
    var data = _ref.read(panelDataProvider(name));
    var layout = data.layout;

    // ------------ 新逻辑开始 ------------
    // 1. 在移除前，找到所有潜在的候选人
    // 注意：需要确保 layout 实例是 panelsLayout 中的最新实例
    var actualLayout = panelsLayout[layout.id];
    if (actualLayout == null) return; // 如果找不到，直接返回

    var candidates = actualLayout.findCandidate();

    // 2. 将面板从布局中移除 (清空其占用的空间)
    for (
      int i = actualLayout.y;
      i < actualLayout.y + actualLayout.height;
      i++
    ) {
      for (
        int j = actualLayout.x;
        j < actualLayout.x + actualLayout.width;
        j++
      ) {
        spaces[j][i] = 0;
      }
    }

    // 3. 从追踪map中移除
    panelsLayout.remove(layout.id);
    panels.remove(name);
    availableSpaceCount += layout.size;

    // 4. 触发所有候选人的补位机制
    for (var candidateId in candidates) {
      panelsLayout[candidateId]?.beCandidate();
    }

    // 5. 最后尝试收缩空间
    shrinkVerticalAxis();
    // ------------ 新逻辑结束 ------------
  }

  ///在切换会话的时候调用，删除所有面板，清空空间
  void clearSpace() {
    for (int i = 0; i < spaces.length; i++) {
      for (int j = 0; j < spaces[i].length; j++) {
        spaces[i][j] = 0;
      }
    }
    panelsLayout.clear();
    panels.clear();
    currentPanelIndex = 0;
  }

  void shrinkVerticalAxis() {
    var vac = verticalAxisCount;
    for (int i = verticalAxisCount - 1; i >= 0; i--) {
      for (int j = 0; j < spaces[i].length; j++) {
        if (spaces[i][j] != 0) {
          verticalAxisCount = vac;
          _ref.read(stackRefreshNotifier.notifier).state ^= true;
          return;
        }
      }
      if (vac == 0) {
        verticalAxisCount = vac;
        _ref.read(stackRefreshNotifier.notifier).state ^= true;
        return;
      }
      vac = i;
    }
    verticalAxisCount = vac;
    _ref.read(stackRefreshNotifier.notifier).state ^= true;
    //或许我应该好好好好睡一觉，我感觉现在像在做梦一样
    //各种理论上不会发生的问题接二连三的发生
    //比如循环的时候数组被修改之类的。。。
    //我感觉活在梦里，想死了
  }

  ///通知riverpod刷新一下面板的位置
  void notifyPanelAction(String panelName) {
    var n = _ref.read(panelDataProvider(panelName).notifier);
    n.state = n.state.copyWith();
  }

  /// 移动面板的核心方法，现在是所有拖拽操作的唯一入口
  void movePanel(int panelId, int newX, int newY) {
    var layout = panelsLayout[panelId];
    if (layout != null) {
      // 1. 将自己原来的领地让出来，为后续的面板移动和自己的新位置做准备
      layout.giveOutTerrain();
      // 这会让布局变化感觉更即时、更流畅
      var c = layout.findCandidate();
      // 3. 在新位置执行“挤压”操作，安顿下来并引发连锁反应
      layout.squish(newX, newY);
      //安顿完毕之后才能启动补位机制
      for (var ci in c) {
        panelsLayout[ci]?.beCandidate();
      }
    }
    shrinkVerticalAxis();
  }

  // --- 新增 resizePanel 方法 ---
  void resizePanel(int panelId, int newWidth, int newHeight) {
    var layout = panelsLayout[panelId];
    if (layout == null) return;

    // 如果尺寸没有实际变化，则不执行任何操作
    if (layout.width == newWidth && layout.height == newHeight) {
      return;
    }

    final oldWidth = layout.width;
    final oldHeight = layout.height;
    // 关键步骤：先让出旧的领地，为重新计算做准备
    layout.giveOutTerrain();
    Set<int>? c;
    if (oldHeight > newHeight) {
      c = layout.findCandidate();
      //这里不能直接在这里就触发补位机制，而是必须要等到面板本身的地块被确认之后才能触发，否则的话会发生问题。
      //layout.callCandidate();
    }

    // 更新面板自身的尺寸
    // 我们直接修改 map 中的实例，因为 layout 是它的引用
    layout.width = newWidth;
    layout.height = newHeight;
    // --- 根据扩容或缩容，执行不同逻辑 ---
    if (oldWidth > newWidth) {
      shrinkVerticalAxis();
    }

    // **情况2：面板正在扩大 或 缩小**
    // 无论是扩大还是缩小，我们都需要在原点重新执行一次 squish
    // - 对于扩大：新的、更大的面板会把邻居挤走。
    // - 对于缩小：虽然已经调用了 candidate，但 squish 能确保自身在新尺寸下被正确放置。
    layout.squish(layout.x, layout.y);
    if (c == null) return;
    for (var ci in c) {
      panelsLayout[ci]?.beCandidate();
    }
  }
  
  ///从json中加载的时候尝试重新布局
  ///需要考虑到的是重加载的时候万一窗口大小改变的话，那么需要重新计算一下
  bool relayoutPanel(Layout layout, String pName, String pType) {
    var panelTuple = PanelsFactory.createPanel(pName, pType, this);
    var panelData = panelTuple.$1;
    var widgetSetUpFunc = panelTuple.$2;
    (int, int)? space = (layout.x, layout.y);
    //如果比垂直的值还高的话那确实没办法了
    if (layout.height > horizontalAxisCount) {
      return false;
    } else if (layout.y + layout.height > horizontalAxisCount) {
      space = layout.findSpace();
    }

    //只是作为托底来用，当ai或者用户意外的添加一块超大的面板的时候直接扩容整个数组
    while (layout.x + layout.width > verticalAxisCount || space == null) {
      verticalAxisCount++;
      expandSpaceX();
      space = layout.findSpace();
    }

    // 2. 如果找到了位置，就执行 "挤压" 操作
    // 将 Layout 实例添加到引擎的追踪 map 中
    panelsLayout[layout.id] = layout;

    // 调用 squish，这将处理所有碰撞和连锁反应
    layout.squish(space.$1, space.$2);

    // 更新 panelData 中的最终位置 (squish内部已经更新了layout实例的x,y)
    // 这一步是为了确保 provider 中的数据同步
    final finalLayout = panelsLayout[layout.id]!;
    _ref.read(panelDataProvider(panelData.name).notifier).state = panelData
        .copyWith(layout: finalLayout);

    panels[panelData.name] = widgetSetUpFunc(panelData.name);
    return true;
  }
}
