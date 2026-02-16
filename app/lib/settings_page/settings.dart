import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_chat/settings_page/about.dart';
import 'package:uni_chat/utils/layout_widget.dart';
import 'package:uni_chat/utils/overlays.dart';

import '../generated/l10n.dart';
import '../main.dart';
import '../theme_manager.dart';
import '../utils/prebuilt_widgets.dart';
import 'api_configure.dart' show ApiSettings;

/// “账户”设置页面的占位符
class _GeneralSettings extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    var idx = ThemeManager.themes.indexWhere((e) => e.theme == theme);
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
        LanguageSwitcher(),
        const SizedBox(height: 20),
        StdDropDown(
          height: 55,
          initialIndex: (idx == -1) ? null : idx,
          itemBuilder: (c, index, onTap) {
            return StdListTile(
              title: Text(ThemeManager.themes[index].name),
              onTap: () async {
                var p = await SharedPreferences.getInstance();
                await p.setString("theme", ThemeManager.themes[index].name);
                ref
                    .read(themeProvider.notifier)
                    .updateTheme(theme: ThemeManager.themes[index].theme);
                onTap(index);
              },
            );
          },
          itemCount: ThemeManager.themes.length,
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

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    Future<int?> selectedIndex() async {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('language');
      if (language == null) {
        return null;
      }
      var l = languages.keys.toList();
      return l.indexOf(language);
    }

    var languageCount = languages.keys.toList();
    var languageLocale = languages.values.toList();
    return FutureBuilder(
      future: selectedIndex(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return Consumer(
          builder: (context, ref, child) {
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
    );
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

final settingsMenuKey = GlobalKey<SettingsMenuState>();

class SettingsMenu extends ConsumerStatefulWidget {
  const SettingsMenu({super.key});

  @override
  ConsumerState<SettingsMenu> createState() => SettingsMenuState();
}

class SettingsMenuState extends ConsumerState<SettingsMenu>
    with SingleTickerProviderStateMixin {
  // 用于驱动进入和退出动画的控制器
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  // 标记当前是否为最大化状态
  bool isMaximized = false;
  bool _forceMaximize = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      OverlayWrapper.registerOnClose(context, () async {
        await _animationController.reverse();
        return true;
      });
    });
    spc = SplitViewController(
      defaultRight: ApiSettings(),
      onPop: () {
        setState(() {
          selectedIndex = -1;
        });
      },
    );
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
      OverlayWrapper.removeOverlay(context);
    });
  }

  // 切换最大化/还原状态
  void toggleMaximize() {
    setState(() {
      isMaximized = !isMaximized;
    });
  }

  Widget? _insertPage;
  void Function()? onPagePop;
  void insertPage(Widget page, {void Function()? onPop}) {
    setState(() {
      onPagePop = onPop;
      _insertPage = page;
    });
  }

  void popPage() {
    onPagePop?.call();
    setState(() {
      onPagePop = null;
      _insertPage = null;
    });
  }

  void onSelect(Widget page) {
    spc.push(
      Material(color: theme.secondGradeColor, child: page),
      topBar: AppBar(
        backgroundColor: theme.secondGradeColor,
        automaticallyImplyLeading: false,
        leading: StdIconButton(
          icon: Icons.arrow_back_ios_sharp,
          onPressed: spc.pop,
        ),
      ),
    );
  }

  int selectedIndex = 0;

  late ThemeConfig theme;
  Size lastScreenSize = Size.zero;
  late SplitViewController spc;

  @override
  Widget build(BuildContext context) {
    var settingItems = [
      _SettingItem(
        icon: Icons.network_check,
        title: S.of(context).api_settings,
        contentWidget: ApiSettings(),
      ),
      /*
      _SettingItem(
        icon: Icons.model_training,
        title: S.of(context).model_management,
        contentWidget: ModelSettings(),
      ),
       */
      _SettingItem(
        icon: Icons.settings_outlined,
        title: S.of(context).general_settings,
        contentWidget: _GeneralSettings(),
      ),
      _SettingItem(
        icon: Icons.info_outline,
        title: S.of(context).about,
        contentWidget: UNIChatAbout(),
      ),
    ];
    final screenSize = MediaQuery.of(context).size;
    var dur = (lastScreenSize == screenSize)
        ? const Duration(milliseconds: 350)
        : Duration.zero;
    lastScreenSize = screenSize;
    // 判断屏幕尺寸，如果是小屏幕，则强制为最大化
    if (PlatForm().isMobilePlatform ||
        screenSize.height <= 600 ||
        screenSize.width <= 900) {
      isMaximized = true;
      _forceMaximize = true;
    } else {
      _forceMaximize = false;
    }
    theme = ref.watch(themeProvider);
    // 根据是否最大化，计算菜单的目标尺寸
    final double targetWidth = isMaximized
        ? screenSize.width - ((PlatForm().isMobile) ? 20 : 60)
        : screenSize.width * 0.65;
    final double targetHeight = isMaximized
        ? screenSize.height - 48
        : screenSize.height * 0.75;
    final double targetBorderRadius = isMaximized ? 10 : 14;

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
            duration: dur,
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
            child: Material(
              color: theme.secondGradeColor,
              child: Column(
                children: [
                  // 标题栏
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_insertPage != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: StdIconButton(
                              tooltip: '返回',
                              icon: Icons.arrow_back_ios_new,
                              onPressed: popPage,
                            ),
                          ),
                        Expanded(child: const SizedBox()),
                        if (!_forceMaximize)
                          StdIconButton(
                            tooltip: isMaximized ? '还原' : '最大化',
                            icon: isMaximized
                                ? Icons.close_fullscreen
                                : Icons.open_in_full_sharp,
                            onPressed: toggleMaximize,
                          ),
                        StdIconButton(
                          tooltip: '关闭',
                          icon: Icons.close,
                          onPressed: _handleClose,
                        ),
                      ],
                    ),
                  ),
                  // 内容区
                  Expanded(
                    child: (_insertPage != null)
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: _insertPage!,
                          )
                        : SplitView(
                            maxLeftWidth: 300,
                            controller: spc,
                            leftPercent: 0.3,
                            onLayout: (p, s, f) {
                              if (f && s == SplitViewStatus.collapsedWithLeft) {
                                selectedIndex = -1;
                                return;
                              }
                              if (p == SplitViewStatus.expanded &&
                                  s == SplitViewStatus.collapsedWithLeft) {
                                selectedIndex = -1;
                                return;
                              }
                              if (p == SplitViewStatus.collapsedWithLeft &&
                                  s == SplitViewStatus.expanded) {
                                selectedIndex = 0;
                              }
                            },
                            left: Material(
                              color: theme.secondGradeColor,
                              child: Column(
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
                                            isSelected: selectedIndex == index,
                                            onTap: () => setState(() {
                                              selectedIndex = index;
                                              onSelect(
                                                settingItems[index]
                                                    .contentWidget,
                                              );
                                            }),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
