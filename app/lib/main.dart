import 'dart:async';
import 'dart:io' as io show Platform;

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uni_chat/Chat/chat_page.dart';
import 'package:uni_chat/Chat/chat_state.dart';
import 'package:uni_chat/Chat/session_selector.dart';
import 'package:uni_chat/Persona/persona_switcher.dart';
import 'package:uni_chat/api_configs/api_database.dart';
import 'package:uni_chat/database/database_service.dart';
import 'package:uni_chat/error_handling.dart';
import 'package:uni_chat/l10n/generated/l10n.dart';
import 'package:uni_chat/platform_specifics/platform_specifics.dart';
import 'package:uni_chat/settings_page/settings.dart';
import 'package:uni_chat/setup_agent.dart';
import 'package:uni_chat/top_banner.dart';
import 'package:uni_chat/utils/auto_update_service.dart';
import 'package:uni_chat/utils/log_manager.dart';
import 'package:uni_chat/utils/overlays.dart';
import 'package:uni_chat/utils/uni_theme.dart';

import 'Agent/agent_page.dart';

final Map<String, Locale> languages = const {
  "简体中文": Locale("zh"),
  "English": Locale("en"),
};

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      final packageInfo = await PackageInfo.fromPlatform();
      PlatForm().version = "V${packageInfo.version}";
      if (io.Platform.isAndroid) {
        PlatForm().platform = RunningPlatform.android;
        var di = await DeviceInfoPlugin().androidInfo;
        PlatForm().platformInfo = "${di.model} running on ${di.version}";
      } else if (io.Platform.isIOS) {
        var di = await DeviceInfoPlugin().iosInfo;
        PlatForm().platformInfo =
            "${di.modelName} running on IOS ${di.systemName}";
        // whether this is an ipad
        if (di.model.contains("iPad")) {
          PlatForm().platform = RunningPlatform.ipadOS;
        } else {
          PlatForm().platform = RunningPlatform.ios;
        }
      } else if (io.Platform.isMacOS) {
        PlatForm().platform = RunningPlatform.macos;
        await MacOSSpecificsSetting.setWindowStyle();
        var di = await DeviceInfoPlugin().macOsInfo;
        PlatForm().platformInfo =
            "${di.modelName} running on MacOS ${di.majorVersion}";
      } else if (io.Platform.isWindows) {
        PlatForm().platform = RunningPlatform.windows;
        await WindowsSpecificsSetting.setWindowStyle();
        await WindowsSpecificsSetting.loadCustomFont();
        var di = await DeviceInfoPlugin().windowsInfo;
        var bn = di.buildNumber;
        String sys = "Windows";
        if (bn > 22000) {
          sys = "Windows 11 ${di.displayVersion}";
        } else if (bn >= 10240) {
          sys = "Windows 10 ${di.displayVersion}";
        } // else might be win 8.1 or 7 since flutter don run on xp
        PlatForm().platformInfo = "${di.computerName} running on $sys";
        //windows 下使用 ffi版本
        //我在考虑把macos 也切换到ffi版本，但是听说好像性能没有提升啥
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      await LogManager.instance.init();

      final prefs = await SharedPreferences.getInstance();
      var l = prefs.getString("language");
      var local = languages[l];

      if (local != null) {
        await S.load(local);
      } else {
        var platformLocale = WidgetsBinding.instance.platformDispatcher.locale;
        if (S.delegate.isSupported(platformLocale)) {
          await S.load(platformLocale);
        } else {
          await S.load(const Locale('en'));
        }
      }

      try {
        await DatabaseService.instance.init();
        await ApiDatabase.instance.init();
      } on DatabaseDowngradeException catch (e) {
        runApp(
          MaterialApp(
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        S.current.db_downgrade_title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        S.current.db_downgrade_error(
                          e.dbName,
                          e.from.toString(),
                          e.to.toString(),
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        S.current.db_downgrade_content,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        return;
      }

      var isSu = prefs.getBool("isSetUp") ?? false;
      var theme = prefs.getString("theme");
      runApp(UNIChat(locale: local, isSetUp: isSu, themeName: theme));
    },
    (error, stack) {
      LogManager.instance.addLog("ERROR: $error\n$stack");
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        LogManager.instance.addLog(line);
        parent.print(zone, line);
      },
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

enum RunningPlatform { web, android, ios, ipadOS, macos, windows }

class PlatForm {
  String version = '';
  static final PlatForm _instance = PlatForm._internal();
  bool get isWindows => platform == RunningPlatform.windows;
  String? languageCode;
  // only enable haptic on ios and macos (since ipads don't have haptic engines)
  bool get enableHaptic =>
      platform == RunningPlatform.ios || platform == RunningPlatform.macos;
  RunningPlatform platform = RunningPlatform.web;
  bool get isMobilePlatform =>
      platform == RunningPlatform.android ||
      platform == RunningPlatform.ios ||
      platform == RunningPlatform.ipadOS;
  bool get isMobile =>
      platform == RunningPlatform.ios || platform == RunningPlatform.android;
  String platformInfo = '';
  String location = '';
  factory PlatForm() => _instance;

  PlatForm._internal();
}

final GlobalKey<MainContState> masterNavigatorKey = GlobalKey<MainContState>();

class UNIChat extends StatefulWidget {
  const UNIChat({
    super.key,
    this.locale,
    required this.isSetUp,
    this.themeName,
  });
  final Locale? locale;
  final String? themeName;
  final bool isSetUp;

  @override
  State<UNIChat> createState() => _UNIChatState();
}

class _UNIChatState extends State<UNIChat> {
  late bool isSetUp;
  bool _isUpdateChecked = false;
  late UniThemeNotifier uniThemeNotifier;

  @override
  void initState() {
    super.initState();
    isSetUp = widget.isSetUp;

    UniThemeData initialThemeData;
    if (widget.themeName == 'dark') {
      initialThemeData = ThemePresets.DARK;
    } else if (widget.themeName == 'solarized') {
      initialThemeData = ThemePresets.SOLARIZED;
    } else {
      initialThemeData = ThemePresets.LIGHT;
    }
    uniThemeNotifier = UniThemeNotifier(
      initialTheme: initialThemeData,
      initialName: widget.themeName ?? 'light',
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: const [],
      child: UniTheme(
        notifier: uniThemeNotifier,
        child: ListenableBuilder(
          listenable: uniThemeNotifier,
          builder: (context, child) {
            final currentThemeData = uniThemeNotifier.data;
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                AppFlowyEditorLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              navigatorKey: navigatorKey,
              title: '',
              scrollBehavior:
                  (PlatForm().platform == RunningPlatform.ios ||
                      PlatForm().platform == RunningPlatform.ipadOS)
                  ? const ScrollBehavior().copyWith(
                      physics: const IOSScrollPhysics(),
                    )
                  : null,
              theme: ThemeData(
                brightness: currentThemeData.isDark
                    ? Brightness.dark
                    : Brightness.light,
                scaffoldBackgroundColor: currentThemeData.zeroGradeColor,
                fontFamily: (PlatForm().isWindows)
                    ? (WindowsSpecificsSetting.customFontLoaded
                          ? WindowsSpecificsSetting.CUSTOM_FONT_FAMILY
                          : "Segoe UI")
                    : null,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue, // 维持这个颜色，自动按照pri来取色，容易出现诡异的问题。
                  brightness: currentThemeData.isDark
                      ? Brightness.dark
                      : Brightness.light,
                ),
              ),
              home: OverlayWrapper(
                child: OverlayPortalScope(
                  child: Builder(
                    builder: (context) {
                      final theme = UniTheme.of(context);
                      Widget mainContent = MainCont(key: masterNavigatorKey);
                      if (!_isUpdateChecked) {
                        // 否则拿不到 overlay 的context引用
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          AutoUpdateService.checkUpdates(
                            context,
                            backgroundColor: theme.zeroGradeColor,
                          );
                        });
                        _isUpdateChecked = true;
                      }
                      if (widget.locale != null) {
                        S.load(widget.locale!);
                        PlatForm().languageCode = widget.locale!.languageCode;
                      } else {
                        PlatForm().languageCode = Localizations.localeOf(
                          context,
                        ).languageCode;
                      }
                      if (PlatForm().platform == RunningPlatform.macos) {
                        mainContent = MacOSMenuBar(mainContent: mainContent);
                      }
                      if (PlatForm().isMobilePlatform) {
                        mainContent = Scaffold(
                          backgroundColor: theme.zeroGradeColor,
                          body: SafeArea(
                            bottom:
                                PlatForm().platform != RunningPlatform.ipadOS,
                            child: mainContent,
                          ),
                        );
                      }
                      if (!widget.isSetUp) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          OverlayWrapper.showOverlay(
                            context,
                            overlayContent: Padding(
                              padding: (PlatForm().isMobile)
                                  ? const EdgeInsets.all(10.0)
                                  : const EdgeInsets.all(50.0),
                              child: SetupAgent(),
                            ),
                            barrierDismissible: false,
                          );
                        });
                        isSetUp =
                            true; // or the setup menu will re-popout when you resize the window
                      }
                      mainContent = AppBarTheme(
                        scrolledUnderElevation: 0,
                        child: mainContent,
                      );
                      if (PlatForm().isWindows) {
                        // windows will force the window to get too small when showing desktop even when window size is set
                        // so we need to avoid the negative constrained error
                        var mdof = MediaQuery.of(context);
                        var s = mdof.size;
                        mainContent = ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: 480,
                            minWidth: 640,
                          ),
                          child: mainContent,
                        );
                      }
                      return mainContent;
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MacOSMenuBar extends ConsumerStatefulWidget {
  const MacOSMenuBar({super.key, required this.mainContent});

  final Widget mainContent;

  @override
  ConsumerState<MacOSMenuBar> createState() => _MacOSMenuBarState();
}

class _MacOSMenuBarState extends ConsumerState<MacOSMenuBar> {
  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: S.of(context).title,
          menus: <PlatformMenuItem>[
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: S.of(context).preferences,
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.comma,
                    meta: true,
                  ),
                  onSelected: () {
                    // make sure there's no settings menu open
                    if (settingsMenuKey.currentState == null) {
                      OverlayWrapper.showOverlay(
                        context,
                        overlayContent: SettingsMenu(key: settingsMenuKey),
                      );
                    }
                  },
                ),
                PlatformMenuItem(label: S.of(context).about, onSelected: () {}),
              ],
            ),
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: S.of(context).quit,
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyQ,
                    meta: true,
                  ),
                  onSelected: () async {
                    await WindowManipulator.closeWindow();
                  },
                ),
              ],
            ),
          ],
        ),
        PlatformMenu(
          label: S.of(context).chat,
          menus: <PlatformMenuItem>[
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: S.of(context).new_chat_session,
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyN,
                    meta: true,
                  ),
                  onSelected: () {
                    masterNavigatorKey.currentState?.setPage(Pages.chat);
                    ref.read(chatStateProvider.notifier).clearSession();
                  },
                ),
                PlatformMenuItem(
                  label: S.of(context).toggle_session_selector,
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyF,
                    meta: true,
                  ),
                  onSelected: () {
                    if (chatBannerKey.currentState?.overlayEntry == null) {
                      chatBannerKey.currentState?.showSessionSelector();
                    } else {
                      chatBannerKey.currentState?.hide();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        PlatformMenu(
          label: "Agent",
          menus: <PlatformMenuItem>[
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: S.of(context).create_new_agent,
                  onSelected: () {
                    masterNavigatorKey.currentState?.setPage(Pages.agent);
                  },
                ),
              ],
            ),
          ],
        ),
        PlatformMenu(
          label: S.of(context).help,
          menus: <PlatformMenuItem>[
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: S.of(context).check_manual,
                  onSelected: () {},
                ),
              ],
            ),
          ],
        ),
      ],
      child: widget.mainContent,
    );
  }
}

class MainCont extends ConsumerStatefulWidget {
  const MainCont({super.key});

  @override
  ConsumerState<MainCont> createState() => MainContState();
}

class SidebarItemData {
  final Pages page;
  final IconData icon;
  final String keyName;
  final String Function(BuildContext) titleBuilder;

  SidebarItemData({
    required this.page,
    required this.icon,
    required this.keyName,
    required this.titleBuilder,
  });
}

enum Pages { chat, agent, Rag }

class MainContState extends ConsumerState<MainCont> {
  Pages page = Pages.chat;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget? _bannerWidget() {
    switch (page) {
      case Pages.chat:
        return ChatBannerWidget(key: chatBannerKey);
      case Pages.agent:
        return null;
      case Pages.Rag:
        return null;
    }
  }

  Widget _bodyWidget() {
    switch (page) {
      case Pages.chat:
        return ChatPage();
      case Pages.agent:
        return AgentPage();
      case Pages.Rag:
        //return RagPage();
        return Container();
    }
  }

  void setPage(Pages page) {
    if (this.page == page) {
      return;
    }
    setState(() {
      this.page = page;
    });
  }

  List<Widget> _buildMenuItems({List<String>? order}) {
    final allItems = <String, Widget>{
      'chat': IconButton(
        onPressed: () {
          if (page == Pages.chat) return;
          setState(() {
            page = Pages.chat;
          });
        },
        icon: Icon(Icons.chat_bubble_outline),
      ),
      'agent': IconButton(
        onPressed: () {
          if (page == Pages.agent) return;
          setState(() {
            page = Pages.agent;
          });
        },
        icon: Icon(Icons.groups_outlined),
      ),
    };

    if (order != null && order.isNotEmpty) {
      var list = <Widget>[];
      for (var key in order) {
        if (allItems.containsKey(key)) {
          list.add(allItems[key]!);
        }
      }
      for (var key in allItems.keys) {
        if (!order.contains(key)) {
          list.add(allItems[key]!);
        }
      }
      return list;
    }

    return allItems.values.toList();
  }

  Widget _buildSidebarTab(
    BuildContext context,
    SidebarItemData item,
    bool showTitle,
    UniThemeData theme,
  ) {
    final isSelected = page == item.page;
    final color = isSelected
        ? theme.primaryColor
        : theme.textColor.withAlpha(180);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(showTitle ? 12 : 24),
          onTap: () {
            if (page == item.page) return;
            setState(() {
              page = item.page;
            });
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: showTitle ? 8 : 10),
            child: showTitle
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, color: color, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        item.titleBuilder(context),
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                : Center(child: Icon(item.icon, color: color, size: 24)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sidebarSettings = ref.watch(sidebarSettingsProvider);
    final showTitle = sidebarSettings.showTitle;
    final order = sidebarSettings.order;

    final allItems = [
      SidebarItemData(
        page: Pages.chat,
        icon: Icons.chat_bubble_outline,
        keyName: 'chat',
        titleBuilder: (c) => S.of(c).sidebar_chat,
      ),
      SidebarItemData(
        page: Pages.agent,
        icon: Icons.groups_outlined,
        keyName: 'agent',
        titleBuilder: (c) => S.of(c).sidebar_agent,
      ),
    ];

    var sidebarItems = <SidebarItemData>[];
    for (var key in order) {
      var item = allItems.firstWhere(
        (element) => element.keyName == key,
        orElse: () => SidebarItemData(
          page: Pages.chat,
          icon: Icons.chat_bubble_outline,
          keyName: '',
          titleBuilder: (c) => "",
        ),
      );
      if (item.keyName.isNotEmpty) {
        sidebarItems.add(item);
      }
    }
    for (var item in allItems) {
      if (!sidebarItems.any((e) => e.keyName == item.keyName)) {
        sidebarItems.add(item);
      }
    }

    var s = MediaQuery.of(context).size;
    var theme = UniTheme.of(context);
    var bnw = _bannerWidget();

    return Scaffold(
      backgroundColor: theme.zeroGradeColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: (s.width >= 500 || page != Pages.chat)
          ? null
          : Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.zeroGradeColor,
              ),
              child: PersonaIndicator(isFloatingAction: true),
            ),
      bottomNavigationBar: (s.width >= 500)
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ..._buildMenuItems(order: order),
                IconButton(
                  onPressed: () {
                    OverlayWrapper.showOverlay(
                      context,
                      overlayContent: SettingsMenu(key: settingsMenuKey),
                    );
                  },
                  icon: Icon(Icons.settings_outlined),
                ),
              ],
            ),
      body: Column(
        children: [
          if (!(PlatForm().isMobile && bnw == null))
            MainBanner(bannerWidget: bnw),
          Expanded(
            child: Row(
              children: [
                if (s.width >= 500)
                  Container(
                    width: showTitle ? 60 : 50,
                    decoration: BoxDecoration(color: theme.zeroGradeColor),
                    child: Column(
                      children: [
                        Expanded(
                          child: ReorderableListView(
                            buildDefaultDragHandles: false,
                            proxyDecorator: (child, index, animation) {
                              return AnimatedBuilder(
                                animation: animation,
                                builder: (context, _) {
                                  return Material(
                                    color: Colors.transparent,
                                    elevation: 0,
                                    child: child,
                                  );
                                },
                              );
                            },
                            onReorder: (oldIndex, newIndex) {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final item = sidebarItems.removeAt(oldIndex);
                              sidebarItems.insert(newIndex, item);
                              final newOrder = sidebarItems
                                  .map((e) => e.keyName)
                                  .toList();
                              ref
                                  .read(sidebarSettingsProvider.notifier)
                                  .setOrder(newOrder);
                            },
                            children: [
                              for (int i = 0; i < sidebarItems.length; i++)
                                ReorderableDragStartListener(
                                  key: ValueKey(sidebarItems[i].keyName),
                                  index: i,
                                  child: _buildSidebarTab(
                                    context,
                                    sidebarItems[i],
                                    showTitle,
                                    theme,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        PersonaIndicator(),
                        const SizedBox(height: 10),
                        IconButton(
                          onPressed: () {
                            OverlayWrapper.showOverlay(
                              context,
                              overlayContent: SettingsMenu(
                                key: settingsMenuKey,
                              ),
                            );
                          },
                          icon: Icon(Icons.settings_outlined),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                if (s.width < 500) const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    key: ValueKey("mainContentWidget"),
                    margin: EdgeInsets.only(right: 4, bottom: 4),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: theme.secondGradeColor,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: _bodyWidget(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarSettings {
  final bool showTitle;
  final List<String> order;
  SidebarSettings({required this.showTitle, required this.order});
  SidebarSettings copyWith({bool? showTitle, List<String>? order}) {
    return SidebarSettings(
      showTitle: showTitle ?? this.showTitle,
      order: order ?? this.order,
    );
  }
}

class SidebarSettingsNotifier extends StateNotifier<SidebarSettings> {
  SidebarSettingsNotifier()
    : super(SidebarSettings(showTitle: true, order: ['chat', 'agent'])) {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final show = prefs.getBool('showSidebarTitle') ?? true;
    final ord = prefs.getStringList('sidebarOrder') ?? ['chat', 'agent'];
    state = SidebarSettings(showTitle: show, order: ord);
  }

  Future<void> setShowTitle(bool val) async {
    state = state.copyWith(showTitle: val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showSidebarTitle', val);
  }

  Future<void> setOrder(List<String> val) async {
    state = state.copyWith(order: val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('sidebarOrder', val);
  }
}

final sidebarSettingsProvider =
    StateNotifierProvider<SidebarSettingsNotifier, SidebarSettings>((ref) {
      return SidebarSettingsNotifier();
    });
