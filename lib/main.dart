import 'dart:io' as io show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_chat/Chat/chat_page_main.dart';
import 'package:uni_chat/Chat/chat_state.dart';
import 'package:uni_chat/Chat/session_selector.dart';
import 'package:uni_chat/Persona/persona_switcher.dart';
import 'package:uni_chat/settings_page/settings.dart';
import 'package:uni_chat/theme_manager.dart';
import 'package:uni_chat/top_banner.dart';
import 'package:uni_chat/utils/dialog.dart';

import 'Agent/agent_page.dart';
import 'RAG/RAG_main_page.dart';
import 'generated/l10n.dart';

final Map<String, Locale> languages = const {
  "简体中文": Locale("zh"),
  "English": Locale("en"),
};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    await WindowManipulator.initialize();
    await WindowManipulator.hideTitle();
    await WindowManipulator.makeTitlebarTransparent();
    await WindowManipulator.addToolbar();
    await WindowManipulator.setToolbarStyle(
      toolbarStyle: NSWindowToolbarStyle.unified,
    );
    await WindowManipulator.enableFullSizeContentView();
    var d = await getApplicationDocumentsDirectory();
    print(d);
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

enum Pages { chat, agent, Rag }

class _MainContState extends ConsumerState<MainCont> {
  Pages page = Pages.chat;
  Widget? _bannerWidget() {
    switch (page) {
      case Pages.chat:
        return ChatBannerWidget();
      case Pages.agent:
        return null;
      case Pages.Rag:
        return null;
    }
  }

  Widget _bodyWidget() {
    switch (page) {
      case Pages.chat:
        return ChatPageMain();
      case Pages.agent:
        return AgentPage();
      case Pages.Rag:
        return RagPage();
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
