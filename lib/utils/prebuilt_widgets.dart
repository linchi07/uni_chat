import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/Chat/panels/constant_value_indexer.dart';
import 'package:uni_chat/utils/dialog.dart';

import '../theme_manager.dart';

class StdButton extends ConsumerWidget {
  const StdButton({
    super.key,
    this.color,
    this.child,
    this.onPressed,
    this.padding,
    this.text,
    this.onLongPress,
  });
  final VoidCallback? onLongPress;
  final Color? color;
  final Widget? child;
  final EdgeInsets? padding;
  final VoidCallback? onPressed;
  final String? text;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var c = color ?? ref.watch(themeProvider).primaryColor;
    return Material(
      color: c,
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onHover: (value) {},
        onTap: onPressed,
        onLongPress: onLongPress,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(8.0),
          child:
              child ??
              Text(
                text ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(color: ColorParser.textColor(c)),
              ),
        ),
      ),
    );
  }
}

class StdListTile extends ConsumerWidget {
  const StdListTile({
    super.key,
    required this.title,
    this.backgroundColor,
    this.highlightColor,
    this.isSelected = false,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? highlightColor;
  final bool isSelected;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    var priColor = backgroundColor ?? theme.primaryColor;
    return ListTile(
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      leading: leading,
      trailing: trailing,
      tileColor: backgroundColor,
      textColor: ColorParser.textColor(
        (isSelected) ? priColor : highlightColor ?? theme.backgroundColor,
      ),
      selectedTileColor: priColor,
      selectedColor: ColorParser.textColor(
        (isSelected) ? priColor : highlightColor ?? theme.backgroundColor,
      ),
      selected: isSelected,
    );
  }
}

class StdCheckbox extends ConsumerWidget {
  const StdCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.text,
    this.textWidget,
    this.mainColor,
  });
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String? text;
  final Widget? textWidget;
  final Color? mainColor;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            splashRadius: 15,
            value: value,
            onChanged: onChanged,
            activeColor: mainColor ?? theme.primaryColor,
            hoverColor: theme.primaryColor.withAlpha(10),
          ),
          if (textWidget != null) textWidget!,
          if (text != null)
            Text(text!, style: TextStyle(color: theme.textColor)),
        ],
      ),
    );
  }
}

class StdTextFormField extends ConsumerWidget {
  StdTextFormField({
    super.key,
    TextEditingController? controller,
    this.hintText,
    this.maxLines,
    this.minLines,
    this.validateFailureText,
    this.showClearButton = false,
    this.onChanged,
    this.onSubmitted,
    this.isExpanded,
  }) {
    this.controller = controller ?? TextEditingController();
  }
  late final TextEditingController controller;
  final bool showClearButton;
  final String? validateFailureText;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool? isExpanded;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.boxColor,
      ),
      child: TextFormField(
        maxLines: maxLines,
        minLines: minLines,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          suffixIcon: (showClearButton)
              ? IconButton(
                  iconSize: 18,
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                  },
                )
              : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validateFailureText;
          }
          return null;
        },
        onChanged: onChanged,
        expands: isExpanded ?? false,
        onEditingComplete: () {
          //用on Submitted 一直出bug,只能这样的了
          onSubmitted?.call(controller.text);
        },
      ),
    );
  }
}

class StdTextField extends ConsumerWidget {
  StdTextField({
    super.key,
    TextEditingController? controller,
    this.hintText,
    this.maxLines,
    this.minLines,
    this.validateFailureText,
    this.onChanged,
    this.onSubmitted,
  }) {
    this.controller = controller ?? TextEditingController();
  }
  late final TextEditingController controller;
  final String? validateFailureText;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.boxColor,
      ),
      child: TextField(
        maxLines: maxLines,
        minLines: minLines,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          suffixIcon: IconButton(
            iconSize: 18,
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.clear();
            },
          ),
        ),
        //用on Submitted 一直出bug,只能这样的了
        onEditingComplete: () {
          onSubmitted?.call(controller.text);
        },
        onChanged: onChanged,
      ),
    );
  }
}

/// 一个通用的 Widget，用于在点击 [child] 时，在其旁边显示一个 [overlayChild]。
///
/// 它封装了 OverlayPortal 的所有逻辑，包括定位、显示/隐藏控制和背景遮罩。
class PopupMenuPortal extends StatefulWidget {
  const PopupMenuPortal({
    super.key,
    required this.child,
    required this.overlayChild,
    this.offset = const Offset(0, 8), // 默认在 child 下方 8 像素处显示
  });

  /// 触发覆盖层显示的 Widget（例如一个按钮）。
  final Widget child;

  /// 要在覆盖层中显示的内容（例如一个菜单）。
  final Widget overlayChild;

  /// 覆盖层相对于 [child] 的位置偏移量。
  final Offset offset;

  @override
  State<PopupMenuPortal> createState() => _PopupMenuPortalState();
}

class _PopupMenuPortalState extends State<PopupMenuPortal> {
  final _overlayPortalController = OverlayPortalController();
  final _anchorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayPortalController,
      overlayChildBuilder: (BuildContext context) {
        // 使用 GlobalKey 来安全地获取 anchor 的 RenderBox
        final RenderBox? anchor =
            _anchorKey.currentContext?.findRenderObject() as RenderBox?;
        if (anchor == null) {
          return const SizedBox.shrink();
        }

        // 将 anchor 的本地坐标转换为全局（覆盖层）坐标
        final Offset position = anchor.localToGlobal(
          // 将我们自定义的偏移量应用到 anchor 的左下角
          anchor.size.bottomLeft(Offset.zero) + widget.offset,
        );

        return Stack(
          children: [
            // 全屏的 GestureDetector 用于实现点击外部关闭菜单的功能
            GestureDetector(
              onTap: _overlayPortalController.hide,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
            // 使用 Positioned 来放置我们的菜单内容
            Positioned(
              top: position.dy,
              left: position.dx,
              child: widget.overlayChild,
            ),
          ],
        );
      },
      // 使用 Key 来将 anchor Widget 和我们的定位逻辑关联起来
      child: GestureDetector(
        key: _anchorKey,
        onTap: _overlayPortalController.toggle,
        child: widget.child,
      ),
    );
  }
}

class AnimatedSidebar extends StatefulWidget {
  final bool isExpanded;
  final double expandedWidth;
  final double collapsedWidth;
  final Widget child;

  const AnimatedSidebar({
    super.key,
    required this.isExpanded,
    this.expandedWidth = 250.0,
    this.collapsedWidth = 0,
    required this.child,
  });

  @override
  State<AnimatedSidebar> createState() => _AnimatedSidebarState();
}

class _AnimatedSidebarState extends State<AnimatedSidebar>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: SizedBox(
        width: widget.isExpanded ? widget.expandedWidth : widget.collapsedWidth,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: widget.isExpanded ? widget.child : null,
        ),
      ),
    );
  }
}

class StdSlider extends ConsumerWidget {
  final String? label;
  final double value;
  final double min;
  final double max;
  final bool toInt;
  final ValueChanged<double>? onChanged;
  final Color? color;
  final Widget? leading;
  const StdSlider({
    this.toInt = false,
    super.key,
    this.label,
    required this.value,
    required this.min,
    required this.max,
    this.onChanged,
    this.color,
    this.leading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    var controller = TextEditingController();
    if (toInt) {
      controller.text = value.toInt().toString();
    } else {
      controller.text = value.toStringAsFixed(2);
    }
    return Row(
      children: [
        leading ?? Text(label ?? "", style: TextStyle(fontSize: 18)),
        Expanded(
          child: Slider(
            min: min,
            max: max,
            activeColor: theme.primaryColor,
            inactiveColor: theme.boxColor,
            thumbColor: theme.surfaceColor,
            value: toInt ? value.roundToDouble() : value,
            onChanged: (val) {
              val = val.clamp(min, max);
              if (toInt) {
                val = val.roundToDouble();
              }
              onChanged?.call(val);
            },
          ),
        ),
        Container(
          width: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: theme.boxColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                var num = double.tryParse(value);
                if (num != null) {
                  num = num.clamp(min, max);
                  if (toInt) {
                    num = num.roundToDouble();
                  }
                  onChanged?.call(num);
                }
              }
            },
          ),
        ),
      ],
    );
  }
}

class StdDropDown extends ConsumerStatefulWidget {
  const StdDropDown({
    super.key,
    this.initialIndex,
    this.initialWidget,
    required this.itemBuilder,
    this.width = 350,
    this.height = 30,
    this.asyncWrapper,
    this.nullHint,
    required this.itemCount,
    this.onChanged,
  });
  final int? initialIndex;
  final Widget? initialWidget;
  final double height;
  final double width;
  final Widget Function(Widget child)? asyncWrapper;
  final int itemCount;
  final Widget? nullHint;
  final Widget Function(
    BuildContext context,
    int index,
    void Function(int index) onTap,
  )
  itemBuilder;
  final ValueChanged<int>? onChanged;
  @override
  ConsumerState<StdDropDown> createState() => _StdDropDownState();
}

class _StdDropDownState extends ConsumerState<StdDropDown>
    with SingleTickerProviderStateMixin {
  int? selectedIndex;
  List<Widget> buildItems(BuildContext context) {
    var items = <Widget>[];
    for (var i = 0; i < widget.itemCount; i++) {
      items.add(widget.itemBuilder(context, i, onTap));
    }
    return items;
  }

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.7, curve: Curves.easeInOut), // 前半段时间执行
      ),
    );
    selectedIndex = widget.initialIndex;
  }

  void onTap(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onChanged?.call(index);
    // 注意：这里的key应该与show时使用的key一致
    OverlayPortalService.hide(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Column(
      children: [
        // 这个三元运算符可以简化
        if (selectedIndex != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: widget.itemBuilder(context, selectedIndex!, onTap),
          ),
        const Divider(),
        Expanded(
          child: (_scaleAnimation.isCompleted)
              ? SizedBox()
              : ListView.builder(
                  itemCount: widget.itemCount,
                  itemBuilder: (context, index) {
                    return widget.itemBuilder(context, index, onTap);
                  },
                ),
        ),
      ],
    );
    if (widget.asyncWrapper != null) {
      child = widget.asyncWrapper!(child);
    }
    var theme = ref.watch(themeProvider);
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: theme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: () {
            var rb = context.findRenderObject() as RenderBox;
            OverlayPortalService.show(
              context,
              barrierVisible: false,
              offset: rb.localToGlobal(Offset.zero),
              // 这是你要求修改的部分
              child: SizeTransition(
                sizeFactor: _scaleAnimation,
                child: SizedBox(
                  width: rb.size.width + 4,
                  height: rb.size.height * 5 + 3,
                  child: Material(
                    elevation: 4,
                    color: theme.surfaceColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: child,
                  ),
                ),
              ),
            );
            // 启动动画 (这个是必须的)
            _controller.forward(from: 0.0);
          },
          child: (selectedIndex == null)
              ? widget.initialWidget ??
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          widget.nullHint ?? SizedBox(),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: theme.textColor,
                          ),
                        ],
                      ),
                    )
              : widget.itemBuilder(context, selectedIndex!, onTap),
        ),
      ),
    );
  }
}

class StdSearch extends StatefulWidget {
  const StdSearch({
    super.key,
    required this.searchItems,
    required this.itemBuilder,
    required this.noResultPage,
  });
  final List<String> searchItems;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Widget noResultPage;
  @override
  State<StdSearch> createState() => _StdSearchState();
}

class _StdSearchState extends State<StdSearch> {
  // 搜索控制器
  final TextEditingController _searchController = TextEditingController();

  // 经过搜索过滤后的数据列表
  List<String> _filteredItems = [];
  late final Map<String, int> _itemIndexMap;

  @override
  void initState() {
    super.initState();
    // 2. 初始时，过滤列表等于全部数据
    _itemIndexMap = {
      for (var i = 0; i < widget.searchItems.length; i++)
        widget.searchItems[i]: i,
    };
    _filteredItems = widget.searchItems;
  }

  @override
  void dispose() {
    // 5. 页面销毁时，释放控制器资源
    _searchController.dispose();
    super.dispose();
  }

  // 1. 新增的高级模糊匹配函数
  /// 检查 [query] 中的字符是否按顺序出现在 [target] 中。
  bool _fuzzyMatch(String query, String target) {
    if (query.isEmpty) {
      return true; // 空搜索默认为匹配所有
    }

    // 为了不区分大小写，统一转为小写
    final lowerCaseQuery = query.toLowerCase();
    final lowerCaseTarget = target.toLowerCase();

    int queryIndex = 0;
    int targetIndex = 0;

    // 当查询索引和目标索引都没有越界时循环
    while (queryIndex < lowerCaseQuery.length &&
        targetIndex < lowerCaseTarget.length) {
      // 如果当前字符匹配，则移动查询索引以匹配下一个字符
      if (lowerCaseQuery[queryIndex] == lowerCaseTarget[targetIndex]) {
        queryIndex++;
      }
      // 无论是否匹配，目标索引总是向前移动
      targetIndex++;
    }

    // 如果查询索引等于查询字符串的长度，说明所有字符都按顺序找到了
    return queryIndex == lowerCaseQuery.length;
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = widget.searchItems;
      });
      return;
    }

    List<String> results = [];
    for (var item in widget.searchItems) {
      // 2. 使用新的模糊匹配函数替换 .contains()
      if (_fuzzyMatch(query, item)) {
        results.add(item);
      }
    }

    setState(() {
      _filteredItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // 3. 创建搜索框 UI
          StdTextField(
            controller: _searchController,
            hintText: '搜索...',
            // 每当文本改变时，调用过滤方法
            onChanged: _filterItems,
          ),
          const SizedBox(height: 10),

          // 3. 创建用于显示结果的列表 UI
          Expanded(
            child: (_filteredItems.isEmpty)
                ? widget.noResultPage
                : ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      //此处需要重新对应item的索引
                      var i = _itemIndexMap[_filteredItems[index]];
                      if (i == null) {
                        return const SizedBox();
                      }
                      return widget.itemBuilder(context, i);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
