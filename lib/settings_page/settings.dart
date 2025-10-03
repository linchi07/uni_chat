import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_chat/settings_page/model_settings.dart';
import 'package:uni_chat/utils/dialog.dart';

import '../generated/l10n.dart';
import '../main.dart';
import '../theme_manager.dart';
import '../utils/prebuilt_widgets.dart';
import 'api_settings.dart';

/// “账户”设置页面的占位符
class _GeneralSettings extends StatelessWidget {
  Future<int?> selectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language');
    if (language == null) {
      return null;
    }
    var l = languages.keys.toList();
    return l.indexOf(language);
  }

  @override
  Widget build(BuildContext context) {
    var languageCount = languages.keys.toList();
    var languageLocale = languages.values.toList();
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          S.of(context).general_settings,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        Text(S.of(context).language_settings, style: TextStyle(fontSize: 18)),
        const SizedBox(height: 20),
        Consumer(
          builder: (context, ref, child) {
            return FutureBuilder(
              future: selectedIndex(),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return StdDropDown(
                  initialWidget: Center(
                    child: Text(
                      S.of(context).language_select,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  initialIndex: asyncSnapshot.data,
                  height: 55.0,
                  onChanged: (index) async {
                    await S.load(languageLocale[index]);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('language', languageCount[index]);
                    //由于大量组件都是接入theme的所以这样相当于让界面重新构建了
                    ref.read(themeProvider.notifier).updateTheme();
                  },
                  itemBuilder: (context, index, onTap) {
                    return StdListTile(
                      title: Text(languageCount[index]),
                      onTap: () {
                        onTap(index);
                      },
                    );
                  },
                  itemCount: languageCount.length,
                );
              },
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          S.of(context).language_switch_restart_note,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// --- 主要的 SettingsMenu 小部件 ---

/// 一个数据类，用于清晰地组织每个设置项。
class _SettingItem {
  final IconData icon;
  final String title;
  final Widget contentWidget;

  _SettingItem({
    required this.icon,
    required this.title,
    required this.contentWidget,
  });
}

class SettingsMenu extends ConsumerStatefulWidget {
  // onClose 回调函数，用于在动画结束后通知父组件移除 OverlayEntry
  final VoidCallback onClose;

  const SettingsMenu({super.key, required this.onClose});

  @override
  ConsumerState<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends ConsumerState<SettingsMenu>
    with SingleTickerProviderStateMixin {
  // 用于驱动进入和退出动画的控制器
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  // 标记当前是否为最大化状态
  bool _isMaximized = false;
  int _selectedIndex = 0; // 新增：追踪当前选中的索引，默认为0

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器和动画
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
    );

    // 使用 CurvedAnimation 让动画曲线更自然
    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
      reverseCurve: Curves.easeInQuart,
    );

    // 定义缩放和淡入淡出动画的具体数值范围
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(curvedAnimation);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curvedAnimation);

    // 启动进入动画
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 处理关闭事件：先反向播放动画，动画结束后再调用父级的onClose方法
  void _handleClose() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  // 切换最大化/还原状态
  void _toggleMaximize() {
    setState(() {
      _isMaximized = !_isMaximized;
    });
  }

  void _onSelectItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late ThemeConfig theme;

  @override
  Widget build(BuildContext context) {
    var settingItems = [
      _SettingItem(
        icon: Icons.network_check,
        title: S.of(context).api_settings,
        contentWidget: ApiSettingsView(),
      ),
      _SettingItem(
        icon: Icons.model_training,
        title: S.of(context).model_management,
        contentWidget: ModelSettings(),
      ),
      _SettingItem(
        icon: Icons.settings_outlined,
        title: S.of(context).general_settings,
        contentWidget: _GeneralSettings(),
      ),
      _SettingItem(
        icon: Icons.info_outline,
        title: S.of(context).about,
        contentWidget: AboutPage(),
      ),
    ];
    final screenSize = MediaQuery.of(context).size;
    theme = ref.watch(themeProvider);
    // 根据是否最大化，计算菜单的目标尺寸
    final double targetWidth = _isMaximized
        ? screenSize.width - 60
        : screenSize.width * 0.65;
    final double targetHeight = _isMaximized
        ? screenSize.height - 48
        : screenSize.height * 0.75;
    final double targetBorderRadius = _isMaximized ? 10 : 14;

    // FadeTransition 和 ScaleTransition 组合实现进入和退出动画
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Center(
          // AnimatedContainer 用于实现尺寸变化的动画
          child: AnimatedContainer(
            width: targetWidth,
            height: targetHeight,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(targetBorderRadius),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            // 使用ClipRRect来确保子内容不会溢出圆角
            clipBehavior: Clip.hardEdge,
            //创建的overlay缺少了很多的属性，所以这里创建了一个新的MaterialApp来提供这些属性
            child: OverlayPortalScope(
              child: Material(
                color: theme.secondGradeColor,
                child: Column(
                  children: [
                    // 标题栏
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: _isMaximized ? '还原' : '最大化',
                          icon: Icon(
                            _isMaximized
                                ? Icons.close_fullscreen
                                : Icons.open_in_full_sharp,
                          ),
                          onPressed: _toggleMaximize,
                        ),
                        IconButton(
                          tooltip: '关闭',
                          icon: const Icon(Icons.close),
                          onPressed: _handleClose,
                        ),
                      ],
                    ),
                    // 内容区
                    Expanded(
                      child: Row(
                        children: [
                          // 左侧导航栏
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Text(
                                  S.of(context).preferences,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  width: 230,
                                  child: ClipRect(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16.0,
                                        horizontal: 8.0,
                                      ),
                                      itemCount: settingItems.length,
                                      itemBuilder: (context, index) {
                                        final item = settingItems[index];
                                        return StdListTile(
                                          leading: Icon(item.icon),
                                          title: Text(item.title),
                                          isSelected: _selectedIndex == index,
                                          onTap: () => _onSelectItem(index),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // 右侧内容区
                          Expanded(
                            child: settingItems[_selectedIndex].contentWidget,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
