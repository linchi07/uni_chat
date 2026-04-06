import 'dart:io';
import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:uni_chat/utils/overlays.dart';
import 'package:uni_chat/utils/paste_and_drop/paste_and_drop.dart';

import '../generated/l10n.dart';
import '../theme_manager.dart';
import 'color.dart';

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
    var theme = ref.watch(themeProvider);
    var c = color ?? theme.primaryColor;
    return Material(
      color: c,
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onHover: (value) {},
        onTap: onPressed,
        onLongPress: onLongPress,
        child: DefaultTextStyle(
          style: TextStyle(color: theme.getTextColor(c)),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(8.0),
            child: child ?? Text(text ?? "", textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class StdButtonOutlined extends ConsumerWidget {
  const StdButtonOutlined({
    super.key,
    this.color,
    this.child,
    this.onPressed,
    this.padding,
    this.onLongPress,
    this.enabled = false,
  });
  final bool enabled;
  final VoidCallback? onLongPress;
  final Color? color;
  final Widget? child;
  final EdgeInsets? padding;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    var c = color ?? theme.primaryColor;
    return Material(
      color: (enabled) ? c : c.withAlpha(20),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: c, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onHover: (value) {},
        splashColor: c.withAlpha(50),
        onTap: onPressed,
        onLongPress: onLongPress,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(4.0),
          child: IconTheme(
            data: IconThemeData(
              color: (enabled) ? theme.getTextColor(c) : c,
              size: 20,
              weight: 300,
            ),
            child: Center(child: child),
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
        (isSelected) ? priColor : highlightColor ?? theme.secondGradeColor,
      ),
      selectedTileColor: priColor,
      selectedColor: ColorParser.textColor(
        (isSelected) ? priColor : highlightColor ?? theme.secondGradeColor,
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
        color: theme.thirdGradeColor,
      ),
      child: TextFormField(
        maxLines: maxLines,
        minLines: minLines,
        onTapOutside: (value) {
          onSubmitted?.call(controller.text);
          FocusScope.of(context).unfocus();
        },
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
            return validateFailureText ?? hintText;
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

class StdTextFormFieldOutlined extends ConsumerWidget {
  StdTextFormFieldOutlined({
    super.key,
    TextEditingController? controller,
    this.hintText,
    this.maxLines,
    this.minLines,
    this.validateFailureText,
    this.showClearButton = false,
    this.onChanged,
    this.validator,
    this.onSubmitted,
    this.isExpanded,
    this.inputFormat,
  }) {
    this.controller = controller ?? TextEditingController();
  }
  late final TextEditingController controller;
  final List<TextInputFormatter>? inputFormat;
  final bool showClearButton;
  final String? validateFailureText;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool? isExpanded;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    return TextFormField(
      maxLines: maxLines,
      minLines: minLines,
      controller: controller,
      inputFormatters: inputFormat,
      onTapOutside: (value) {
        onSubmitted?.call(controller.text);
        FocusScope.of(context).unfocus();
      },
      decoration: InputDecoration(
        fillColor: theme.primaryColor,
        focusColor: theme.primaryColor,
        hintText: hintText,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor, width: 1.0),
        ),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return validateFailureText ?? hintText;
            }
            return null;
          },
      onChanged: onChanged,
      expands: isExpanded ?? false,
      onEditingComplete: () {
        //用on Submitted 一直出bug,只能这样的了
        onSubmitted?.call(controller.text);
      },
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
        color: theme.thirdGradeColor,
      ),
      child: TextField(
        maxLines: maxLines,
        minLines: minLines,
        controller: controller,
        onSubmitted: onSubmitted,
        onTapOutside: (value) {
          onSubmitted?.call(controller.text);
          FocusScope.of(context).unfocus();
        },
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
        onChanged: onChanged,
      ),
    );
  }
}

class StdTextFieldOutlined extends ConsumerWidget {
  StdTextFieldOutlined({
    super.key,
    TextEditingController? controller,
    this.hintText,
    this.maxLines,
    this.minLines,
    this.validateFailureText,
    this.onChanged,
    this.onSubmitted,
    this.isExpanded,
  }) {
    this.controller = controller ?? TextEditingController();
  }
  late final TextEditingController controller;
  final String? validateFailureText;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final bool? isExpanded;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    return TextField(
      controller: controller,
      maxLines: (isExpanded ?? false) ? null : maxLines ?? 1,
      expands: isExpanded ?? false,
      onChanged: onChanged,
      onTapOutside: (focus) {
        onSubmitted?.call(controller.text);
        FocusScope.of(context).unfocus();
      },
      onSubmitted: onSubmitted,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        fillColor: theme.primaryColor,
        focusColor: theme.primaryColor,
        hintText: hintText,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor, width: 1.0),
        ),
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
            inactiveColor: theme.thirdGradeColor,
            thumbColor: theme.zeroGradeColor,
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
            color: theme.thirdGradeColor,
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
        const SizedBox(width: 8),
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
    this.color,
  });
  final int? initialIndex;
  final Widget? initialWidget;
  final Color? color;
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

  late ThemeConfig theme;
  void onShow() {
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
          child: ListView.builder(
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
          height: rb.size.height * 6 + 3,
          child: Material(
            elevation: 4,
            color: widget.color ?? theme.zeroGradeColor,
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
  }

  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: widget.color ?? theme.zeroGradeColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: () {
            onShow();
          },
          child: AbsorbPointer(
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
                : Center(
                    child: widget.itemBuilder(
                      context,
                      selectedIndex!,
                      (index) {},
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class StdSearch extends StatefulWidget {
  const StdSearch({
    super.key,
    this.isOutlined = false,
    this.hintText,
    required this.searchItems,
    required this.itemBuilder,
    required this.noResultPage,
  });
  final List<String> searchItems;
  final bool isOutlined;
  final String? hintText;
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

  int _getFuzzyScore(String query, String target) {
    if (query.isEmpty) return 0;

    final q = query.toLowerCase();
    final t = target.toLowerCase();

    int score = 0;
    int queryIndex = 0;
    int targetIndex = 0;
    int lastMatchIndex = -1;

    while (queryIndex < q.length && targetIndex < t.length) {
      if (q[queryIndex] == t[targetIndex]) {
        // 基础分
        score += 10;

        // 连续匹配奖励：如果当前匹配紧跟上一个匹配
        if (lastMatchIndex != -1 && targetIndex == lastMatchIndex + 1) {
          score += 5;
        }

        // 靠前匹配奖励：如果是字符串开头匹配
        if (targetIndex == 0) {
          score += 8;
        }

        lastMatchIndex = targetIndex;
        queryIndex++;
      }
      targetIndex++;
    }

    // 如果没匹配完所有字符，返回 0
    if (queryIndex != q.length) return 0;

    // 长度惩罚：目标字符串越长，分数越低（密度越小）
    score -= t.length;

    return score;
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredItems = widget.searchItems;
      });
      return;
    }

    // 存储带分数的结果
    List<MapEntry<String, int>> scoredResults = [];

    for (var item in widget.searchItems) {
      int score = _getFuzzyScore(query, item);
      if (score > 0) {
        scoredResults.add(MapEntry(item, score));
      }
    }

    // 根据分数从高到低排序
    scoredResults.sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      _filteredItems = scoredResults.map((e) => e.key).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (!widget.isOutlined)
            StdTextField(
              controller: _searchController,
              hintText: widget.hintText,
              // 每当文本改变时，调用过滤方法
              onChanged: _filterItems,
            ),
          if (widget.isOutlined)
            StdTextFieldOutlined(
              controller: _searchController,
              hintText: widget.hintText,
              // 每当文本改变时，调用过滤方法
              onChanged: _filterItems,
            ),
          const SizedBox(height: 10),

          // 3. 创建用于显示结果的列表 UI
          Expanded(
            child: (_filteredItems.isEmpty)
                ? widget.noResultPage
                : ListView.builder(
                    prototypeItem: widget.itemBuilder(context, 0),
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

class ImageChangeResult {
  late bool isNativeImage;
  NativeImage? _nativeImage;
  PlatformFile? _fileImage;

  ImageChangeResult(NativeImage? nativeImage, PlatformFile? fileImage) {
    isNativeImage = nativeImage != null;
    if (isNativeImage) {
      _nativeImage = nativeImage;
    } else {
      _fileImage = fileImage;
    }
  }

  Future<File> copyTo(
    String pathToDir, {
    String? rename,
    bool replaceIfExist = false,
    bool createDirIfNotExist = false,
    String? extension,
  }) async {
    if (isNativeImage) {
      return _nativeImage!.copyTo(
        pathToDir,
        rename: rename,
        replaceIfExist: replaceIfExist,
        createDirIfNotExist: createDirIfNotExist,
        extension: extension,
      );
    } else {
      var path = _fileImage?.path;
      if (path != null) {
        var f = File(path);
        var dir = Directory(pathToDir);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        var n = rename ?? p.basename(f.path);
        if (extension != null && !extension.startsWith(".")) {
          extension = ".$extension";
        }
        var e = extension ?? p.extension(n);
        return await f.copy(p.join(pathToDir, "$n$e"));
      } else {
        throw Exception("File is null");
      }
    }
  }
}

class StdAvatarPicker extends StatefulWidget {
  const StdAvatarPicker({
    super.key,
    this.initialWidget,
    this.initialAssetImagePath,
    required this.onImageChanged,
    this.initialImageFile,
  });
  final Widget? initialWidget;
  final String? initialAssetImagePath;
  final File? initialImageFile;
  final void Function(ImageChangeResult, void Function(String)) onImageChanged;

  @override
  State<StdAvatarPicker> createState() => _StdAvatarPickerState();
}

class _StdAvatarPickerState extends State<StdAvatarPicker> {
  File? _imageFile;
  bool isDroppingFiles = false;

  void setImage(String path) {
    setState(() {
      _imageFile = File(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return NativeDropRegion(
      supportedFormats: {
        const FileFormat(extension: 'jpg', mimeType: 'image/jpeg'),
        const FileFormat(extension: 'png', mimeType: 'image/png'),
        const FileFormat(extension: 'jpeg', mimeType: 'image/jpeg'),
      },
      onDropLeave: (e) {
        setState(() {
          isDroppingFiles = false;
        });
      },
      onDropEnter: (e) {
        setState(() {
          isDroppingFiles = true;
        });
      },
      onPerformDrop: (e) async {
        var item = e.items.firstOrNull;
        if (item is NativeImage) {
          widget.onImageChanged(ImageChangeResult(item, null), setImage);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          (_imageFile != null)
              ? Image.file(_imageFile!)
              : (widget.initialWidget != null)
              ? widget.initialWidget!
              : (widget.initialImageFile != null)
              ? Image.file(widget.initialImageFile!)
              : (widget.initialAssetImagePath != null)
              ? Image.asset(widget.initialAssetImagePath!)
              : Container(color: Colors.grey),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: false, // 允许选择多个文件
                  withData: true,
                );
                if (result != null) {
                  final file = result.files.single;
                  if (file.path == null) {
                    return;
                  }
                  widget.onImageChanged(
                    ImageChangeResult(null, file),
                    setImage,
                  );
                }
              },
            ),
          ),
          if (isDroppingFiles)
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
              color: Colors.white.withAlpha(180),
              child: Center(
                child: Text(
                  S.of(context).drag_image_hint,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class StdAvatar extends StatelessWidget {
  const StdAvatar({
    super.key,
    this.assetImage,
    this.file,
    this.length = 25,
    this.showBorder = false,
    this.backgroundColor,
    this.whenNull,
  });
  final AssetImage? assetImage;
  final Color? backgroundColor;
  final File? file;
  final Widget? whenNull;
  final double length;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: length,
      width: length,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: Colors.black,
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside,
              )
            : null,
      ),
      child: (file != null)
          ? Center(child: Image.file(file!))
          : (assetImage != null)
          ? Center(child: Image(image: assetImage!))
          : whenNull ?? Icon(Icons.person, size: min(length, 30)),
    );
  }
}

class FileIcon extends StatelessWidget {
  const FileIcon({
    super.key,
    required this.color,
    required this.extension,
    this.size = const Size(30, 30),
  });
  final Color color;
  final Size size;
  final String extension;

  @override
  Widget build(BuildContext context) {
    String e;
    if (extension.startsWith(".")) {
      e = extension.substring(1);
    } else {
      e = extension;
    }
    return Container(
      height: size.height,
      width: size.width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size.shortestSide * 0.2),
      ),
      child: Center(
        child: Text(
          e,
          overflow: TextOverflow.fade,
          style: TextStyle(
            fontSize: size.shortestSide * 0.4,
            color: (color.computeLuminance() > 0.5)
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
    );
  }
}

class StdIconButton extends StatelessWidget {
  const StdIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.padding,
    this.iconSize,
    this.color,
  });
  final IconData icon;
  final void Function() onPressed;
  final EdgeInsets? padding;
  final double? iconSize;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      color: color,
      padding: padding ?? EdgeInsets.all(4),
      constraints: const BoxConstraints(),
      onPressed: onPressed,
      iconSize: iconSize ?? 20,
      icon: Icon(icon),
    );
  }
}

class MDEditor extends StatefulWidget {
  const MDEditor({super.key, required this.maxHeight, required this.minHeight});
  final double maxHeight;
  final double minHeight;
  @override
  State<MDEditor> createState() => _MDEditorState();
}

class _MDEditorState extends State<MDEditor> {
  late EditorState editorState;

  @override
  void initState() {
    super.initState();
    editorState = EditorState.blank();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: widget.minHeight,
        maxHeight: widget.maxHeight,
      ),
      child: IntrinsicHeight(
        child: AppFlowyEditor(
          editorState: editorState,
          shrinkWrap: true,
          autoFocus: true,
          blockComponentBuilders: {...standardBlockComponentBuilderMap},
          editorStyle: EditorStyle.desktop(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            cursorColor: Colors.blue,
            selectionColor: Colors.blue.withValues(alpha: 0.2),
          ),
          commandShortcutEvents: [...standardCommandShortcutEvents],
        ),
      ),
    );
  }
}
