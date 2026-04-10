import 'dart:async';
import 'dart:io' as io show Platform;
import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uni_chat/Chat/chat_page.dart';
import 'package:uni_chat/Chat/chat_state.dart';
import 'package:uni_chat/Chat/session_selector.dart';
import 'package:uni_chat/Persona/persona_switcher.dart';
import 'package:uni_chat/api_configs/api_database.dart';
import 'package:uni_chat/database/database_service.dart';
import 'package:uni_chat/error_handling.dart';
import 'package:uni_chat/platform_specifics/platform_specifics.dart';
import 'package:uni_chat/settings_page/settings.dart';
import 'package:uni_chat/setup_agent.dart';
import 'package:uni_chat/theme_manager.dart';
import 'package:uni_chat/top_banner.dart';
import 'package:uni_chat/utils/overlays.dart';

import 'Agent/agent_page.dart';
import 'generated/l10n.dart';
import 'utils/auto_update_service.dart';
import 'utils/log_manager.dart';

final Map<String, Locale> languages = const {
  "简体中文": Locale("zh"),
  "English": Locale("en"),
};

const String websiteURL = "http://localhost:3000/zh-Hans";

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
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
  @override
  void initState() {
    super.initState();
    isSetUp = widget.isSetUp;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Widget mainContent = MainCont(key: masterNavigatorKey);
    List<Override> ovr;
    late ThemeConfig theme;
    if (widget.themeName != null) {
      theme = ThemeManager.themes
          .firstWhere(
            (element) => element.name == widget.themeName,
            orElse: () => (name: 'light', theme: ThemeManager.light),
          )
          .theme;
    } else {
      theme = ThemeManager.light;
    }
    ovr = [
      themeProvider.overrideWith((ref) {
        return ThemeManager(theme);
      }),
    ];
    return ProviderScope(
      overrides: ovr,
      child: MaterialApp(
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
            ? const ScrollBehavior().copyWith(physics: const IOSScrollPhysics())
            : null,
        theme: ThemeData(
          fontFamily: (PlatForm().isWindows) ? "Segoe UI" : null,
          fontFamilyFallback: (PlatForm().isWindows)
              ? [
                  "Microsoft YaHei",
                  "Yu Gothic UI",
                  "Malgun Gothic",
                  "Segoe UI Emoji",
                  "Segoe UI Symbol",
                  "NotoSymbols",
                ]
              : null,
          // fix the font glitches in windows when displaying SC
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: OverlayWrapper(
          child: OverlayPortalScope(
            child: Builder(
              builder: (context) {
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
                      bottom: PlatForm().platform != RunningPlatform.ipadOS,
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
                    constraints: BoxConstraints(minHeight: 480, minWidth: 640),
                    child: mainContent,
                  );
                }
                return mainContent;
              },
            ),
          ),
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

enum Pages { chat, agent, Rag }

class MainContState extends ConsumerState<MainCont> {
  Pages page = Pages.chat;
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

  List<Widget> _buildMenuItems() {
    return [
      IconButton(
        onPressed: () {
          if (page == Pages.chat) {
            return;
          }
          setState(() {
            page = Pages.chat;
          });
        },
        icon: Icon(Icons.chat_bubble_outline),
      ),
      IconButton(
        onPressed: () {
          if (page == Pages.agent) {
            return;
          }
          setState(() {
            page = Pages.agent;
          });
        },
        icon: Icon(Icons.groups_outlined),
      ),
      /*
                      IconButton(
                        onPressed: () {
                          if (page == Pages.Rag) {
                            return;
                          }
                          setState(() {
                            page = Pages.Rag;
                          });
                        },
                        icon: Icon(Icons.book_outlined),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.mode_edit_outline_outlined),
                      ),
                       */
    ];
  }

  @override
  Widget build(BuildContext context) {
    var s = MediaQuery.of(context).size;
    var theme = ref.watch(themeProvider);
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
                ..._buildMenuItems(),
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
                    width: 50,
                    decoration: BoxDecoration(color: theme.zeroGradeColor),
                    child: Column(
                      children: [
                        ..._buildMenuItems(),
                        const Spacer(),
                        PersonaIndicator(),
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
                        // to avoid the menu button being cut off
                        if (PlatForm().platform == RunningPlatform.ipadOS)
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
