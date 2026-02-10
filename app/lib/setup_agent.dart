import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_chat/Agent/agent_set_page.dart';
import 'package:uni_chat/Chat/chat_state.dart';
import 'package:uni_chat/Persona/persona_provider.dart';
import 'package:uni_chat/Persona/persona_switcher.dart';
import 'package:uni_chat/settings_page/api_configure.dart';
import 'package:uni_chat/settings_page/settings.dart';
import 'package:uni_chat/theme_manager.dart';
import 'package:uni_chat/utils/overlays.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'generated/l10n.dart';
import 'utils/web_view/webview_all.dart';

class SetupAgent extends ConsumerStatefulWidget {
  const SetupAgent({super.key});

  @override
  ConsumerState<SetupAgent> createState() => _SetupAgentState();
}

class _SetupAgentState extends ConsumerState<SetupAgent> {
  final PageController _pageController = PageController();

  late ThemeConfig theme;

  @override
  void initState() {
    super.initState();
    theme = ref.read(themeProvider);
  }

  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);
    return Material(
      color: theme.secondGradeColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          welcomePage(),
          providerAddHint(),
          addProvider(),
          personaHint(),
          persona(),
          addAgentHint(),
          addAgent(),
          finish(),
        ],
      ),
    );
  }

  void nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget welcomePage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                "Switch language here (在这里切换语言):",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              LanguageSwitcher(),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(80),
                    spreadRadius: 3,
                    blurRadius: 4,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: Image.asset("resources/uni_chat_no_bg.png"),
            ),
            const SizedBox(height: 5),
            Text(
              S.of(context).title,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              S.of(context).slogan,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            StdButton(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  S.of(context).setup_start,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              onPressed: () {
                OverlayPortalService.show(
                  context,
                  child: SizedBox(
                    width: 500,
                    height: 600,
                    child: Material(
                      color: theme.zeroGradeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              S.of(context).setup_pre_warning,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Expanded(
                              child: SingleChildScrollView(
                                child: GptMarkdown(
                                  S.of(context).setup_pre_warn_content,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            StdButton(
                              text:
                                  "${S.of(context).got_it} (${S.of(context).long_press})",
                              onLongPress: () {
                                OverlayPortalService.hide(context);
                                nextPage();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  bool _addPvChecked = false;

  Widget providerAddHint() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  prevPage();
                },
                icon: Icon(Icons.arrow_back_ios_sharp),
              ),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            S.of(context).setup_provider_add,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            S.of(context).setup_provider_add_hint,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          StdCheckbox(
                            text: S.of(context).setup_api_prepared,
                            value: _addPvChecked,
                            onChanged: (value) {
                              setState(() {
                                _addPvChecked = !_addPvChecked;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          if (_addPvChecked)
                            StdButton(
                              text: S.of(context).next_step,
                              onPressed: () {
                                if (_addPvChecked) {
                                  OverlayPortalService.showDialog(
                                    context,
                                    width: 450,
                                    height: 800,
                                    child: ApiPresetSelect(
                                      onClose: () async {
                                        await OverlayPortalService.hide(
                                          context,
                                        );
                                        nextPage();
                                      },
                                    ),
                                    backGroundColor: theme.zeroGradeColor,
                                  );
                                }
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.zeroGradeColor,
                    ),
                    child: Webview(url: "http://localhost:3000/"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget addProvider() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              prevPage();
            },
            icon: Icon(Icons.arrow_back_ios_sharp),
          ),
          Expanded(
            child: ApiConfigurePage(
              onExit: (f) {
                if (!f) {
                  prevPage();
                } else {
                  nextPage();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget addAgentHint() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              prevPage();
            },
            icon: Icon(Icons.arrow_back_ios_sharp),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            S.of(context).setup_add_agent,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            S.of(context).setup_add_agent_hint,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          StdButton(
                            text: S.of(context).next_step,
                            onPressed: () {
                              nextPage();
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: theme.zeroGradeColor,
                    ),
                    child: Webview(url: "http://localhost:3000/"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget addAgent() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.arrow_back_ios_sharp),
              ),
              const SizedBox(width: 5),
              Text(
                S.of(context).setup_agent_hint,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Expanded(
            child: AgentSetPage(
              onSaveReturn: () {
                //ref.read(ragEditState.notifier).newState();
                nextPage();
              },
            ),
          ),
        ],
      ),
    );
  }
  /*
  Widget knowledgeBase() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  ref.read(agentEditState.notifier).state = AgentEditState(
                    id: Uuid().v7(),
                  );
                  prevPage();
                },
                icon: Icon(Icons.arrow_back_ios_sharp),
              ),
              const SizedBox(width: 5),
              Text(
                S.of(context).setup_knowledgeBase,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Expanded(child: const SizedBox()),
              StdButton(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    S.of(context).skip,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                onPressed: () {
                  nextPage();
                },
              ),
            ],
          ),
          Expanded(child: RagSettingPage(onSaveReturn: nextPage)),
        ],
      ),
    );
  }
  知识库和agent的设置合并
*/

  Widget personaHint() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              prevPage();
            },
            icon: Icon(Icons.arrow_back_ios_sharp),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            S.of(context).setup_add_persona,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            S.of(context).setup_add_persona_hint,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          StdButton(
                            text: S.of(context).next_step,
                            onPressed: () {
                              nextPage();
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  width: 700,
                  height: 600,
                  clipBehavior: Clip.hardEdge,
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.zeroGradeColor,
                  ),
                  child: Webview(url: "http://localhost:3000/"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget persona() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  prevPage();
                },
                icon: Icon(Icons.arrow_back_ios_sharp),
              ),
              const SizedBox(width: 5),
              Text(
                S.of(context).setup_persona,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Expanded(
            child: PersonaEditorContent(
              isSetup: true,
              onSaveReturn: nextPage,
              persona: Persona(
                id: Uuid().v7(),
                name: "",
                content: "",
                data: {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget finish() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              prevPage();
            },
            icon: Icon(Icons.arrow_back_ios_sharp),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    S.of(context).setup_finished,
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  StdButton(
                    color: Colors.redAccent,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "resources/github-mark-white.png",
                            height: 30,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            S.of(context).star_github,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      launchUrl(
                        Uri.parse("https://github.com/linchi07/uni_chat"),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  StdButton(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        S.of(context).setup_finished_btn,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    onPressed: () async {
                      var i = await SharedPreferences.getInstance();
                      await i.setBool("isSetUp", true);
                      ref.read(chatStateProvider.notifier).clearSession();
                      // or there will be an agent not found error
                      if (mounted) {
                        OverlayWrapper.removeOverlay(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
