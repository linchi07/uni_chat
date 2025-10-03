import 'dart:io' as io show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_chat/Chat/chat_page_main.dart';
import 'package:uni_chat/Chat/chat_state.dart';
import 'package:uni_chat/Chat/session_selector.dart';
import 'package:uni_chat/Persona/persona_switcher.dart';
import 'package:uni_chat/settings_page/settings.dart';
import 'package:uni_chat/theme_manager.dart';
import 'package:uni_chat/utils/dialog.dart';

import 'Agent/agent_page.dart';
import 'generated/l10n.dart';

final Map<String, Locale> languages = const {
  "简体中文": Locale("zh"),
  "English": Locale("en"),
};

Future<void> main() async {
  if (io.Platform.isAndroid) {
    PlatForm().platform = Platform.android;
  } else if (io.Platform.isIOS) {
    PlatForm().platform = Platform.ios;
  } else if (io.Platform.isMacOS) {
    PlatForm().platform = Platform.macos;
  } else if (io.Platform.isWindows) {
    PlatForm().platform = Platform.windows;
  }
  if (PlatForm._instance.platform == Platform.macos) {
    //要改好多东西啊
    WidgetsFlutterBinding.ensureInitialized();
    await WindowManipulator.initialize();
    await WindowManipulator.hideTitle();
    await WindowManipulator.makeTitlebarTransparent();
    await WindowManipulator.addToolbar();
    await WindowManipulator.setToolbarStyle(
      toolbarStyle: NSWindowToolbarStyle.unified,
    );
    await WindowManipulator.enableFullSizeContentView();
  }
  final prefs = await SharedPreferences.getInstance();
  var l = prefs.getString("language");
  var local = languages[l];
  runApp(UNIChat(locale: local));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

enum Platform { web, android, ios, macos, windows }

class PlatForm {
  static final PlatForm _instance = PlatForm._internal();

  Platform platform = Platform.web;
  String platformInfo = '';
  String location = '';
  factory PlatForm() => _instance;

  PlatForm._internal();
}

class UNIChat extends StatelessWidget {
  const UNIChat({super.key, this.locale});
  final Locale? locale;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var mainContent = MainCont();
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        navigatorKey: navigatorKey,
        title: '',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: OverlayPortalScope(
          child: Builder(
            builder: (context) {
              if (locale != null) {
                S.load(locale!);
              }
              if (PlatForm().platform == Platform.macos) {
                return MacOSMenuBar(mainContent: mainContent);
              }
              return mainContent;
            },
          ),
        ),
      ),
    );
  }
}

class MacOSMenuBar extends ConsumerStatefulWidget {
  const MacOSMenuBar({super.key, required this.mainContent});

  final MainCont mainContent;

  @override
  ConsumerState<MacOSMenuBar> createState() => _MacOSMenuBarState();
}

class _MacOSMenuBarState extends ConsumerState<MacOSMenuBar> {
  OverlayEntry? _overlayEntry;
  void _showSettingsMenu(BuildContext context) {
    if (_overlayEntry != null) {
      return;
    }
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 背景变暗和点击外部关闭
          ModalBarrier(
            color: Colors.black.withAlpha(80),
            onDismiss: _hideSettingsMenu,
          ),
          SettingsMenu(onClose: _hideSettingsMenu),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideSettingsMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

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
                    _showSettingsMenu(context);
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
                    ref.read(chatStateProvider.notifier).clearSession();
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
                  onSelected: () {},
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
  ConsumerState<MainCont> createState() => _MainContState();
}

enum Pages { chat, agent }

class _MainContState extends ConsumerState<MainCont> {
  Pages page = Pages.chat;
  Widget? _bannerWidget() {
    switch (page) {
      case Pages.chat:
        return ChatBannerWidget();
      case Pages.agent:
        return null;
    }
  }

  Widget _bodyWidget() {
    switch (page) {
      case Pages.chat:
        return ChatPageMain();
      case Pages.agent:
        return AgentPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    return Scaffold(
      backgroundColor: theme.secondGradeColor,
      body: Column(
        children: [
          MainBanner(bannerWidget: _bannerWidget()),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 50,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            page = Pages.chat;
                          });
                        },
                        icon: Icon(Icons.chat_bubble_outline),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            page = Pages.agent;
                          });
                        },
                        icon: Icon(Icons.groups_outlined),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.mode_edit_outline_outlined),
                      ),
                      Expanded(child: SizedBox()),
                      PersonaIndicator(),
                      SettingsMenuButton(),
                    ],
                  ),
                ),
                Expanded(child: _bodyWidget()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MainBanner extends ConsumerWidget {
  const MainBanner({super.key, this.bannerWidget});
  final Widget? bannerWidget;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Container(
      height: 50,
      color: theme.zeroGradeColor,
      child: Stack(
        children: [
          Row(
            children: [
              const SizedBox(width: 21),
              if (PlatForm._instance.platform == Platform.macos)
                //这里解释一下，因为macOS的标题栏有3个点，所以这里要绘制3个点，我们的那个包默认下是在窗口失去焦点的时候直接不显示红绿灯，所以这里直接画一个上去
                CustomPaint(size: Size(50, 50), painter: ThreeDotsPainter()),
              if (PlatForm._instance.platform != Platform.macos)
                const SizedBox(width: 50),
              const SizedBox(width: 21),
              Text(
                S.of(context).title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Center(child: bannerWidget),
        ],
      ),
    );
  }
}

class ThreeDotsPainter extends CustomPainter {
  final Color dotColor;
  final double dotRadius;

  ThreeDotsPainter({this.dotColor = Colors.grey, this.dotRadius = 5.7});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor.withAlpha(200)
      ..style = PaintingStyle.fill;

    // 计算三个点的位置（水平居中排列）
    final centerX = size.width / 2;
    final centerY = size.height / 2 + 1;
    const dotSpacing = 20;

    // 绘制三个点
    canvas.drawCircle(Offset(centerX - dotSpacing, centerY), dotRadius, paint);

    canvas.drawCircle(Offset(centerX, centerY), dotRadius, paint);

    canvas.drawCircle(Offset(centerX + dotSpacing, centerY), dotRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SettingsMenuButton extends StatefulWidget {
  const SettingsMenuButton({super.key});

  @override
  State<SettingsMenuButton> createState() => _SettingsMenuButtonState();
}

class _SettingsMenuButtonState extends State<SettingsMenuButton> {
  OverlayEntry? _overlayEntry;

  void _showSettingsMenu(BuildContext context) {
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 背景变暗和点击外部关闭
          ModalBarrier(
            color: Colors.black.withAlpha(80),
            onDismiss: _hideSettingsMenu,
          ),
          SettingsMenu(onClose: _hideSettingsMenu),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideSettingsMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        _showSettingsMenu(context);
      },
      icon: Icon(Icons.settings_outlined),
    );
  }
}
