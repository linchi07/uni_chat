import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_chat/Agent/agent_set_page.dart';
import 'package:uni_chat/Chat/chat_state.dart';
import 'package:uni_chat/Persona/persona_provider.dart';
import 'package:uni_chat/Persona/persona_switcher.dart';
import 'package:uni_chat/database/database_service.dart';
import 'package:uni_chat/l10n/generated/l10n.dart';
import 'package:uni_chat/main.dart';
import 'package:uni_chat/settings_page/api_configure.dart';
import 'package:uni_chat/theme_manager.dart';
import 'package:uni_chat/utils/overlays.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'dart:convert';
import 'package:uni_chat/Agent/agent_models.dart';
import 'package:uni_chat/api_configs/api_database.dart';

import 'utils/web_view/webview_all.dart';

const BASE_URL = "https://unichat.wejoinnwk.com/";

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

  void _skipToQuickChat() {
    _pageController.animateToPage(
      7,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Widget welcomePage() {
    return Column(
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            S.of(context).slogan,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
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
              animate: true,
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
                    child: FutureBuilder(
                      future: Future.delayed(const Duration(milliseconds: 400)),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return Column(
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
                                  onLinkTap: (url, title) async {
                                    var u = Uri.parse(url);
                                    if (await canLaunchUrl(u)) {
                                      await launchUrl(u);
                                    }
                                  },
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
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  bool _addPvChecked = false;

  Widget providerAddHint() {
    var children = [
      Expanded(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context).setup_provider_add,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                          height: 600,
                          child: ApiPresetSelect(
                            onClose: () async {
                              await OverlayPortalService.hide(context);
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
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.zeroGradeColor,
          ),
          child: Webview(url: "${BASE_URL}docs/models-and-apis/intro"),
        ),
      ),
    ];
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
            child: (PlatForm().isMobile)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: children,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: children,
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
              onExit: (f) async {
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
    var children = [
      Expanded(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context).setup_add_agent,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.zeroGradeColor,
          ),
          child: Webview(url: "${BASE_URL}docs/agents/agent-brief"),
        ),
      ),
    ];
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
              const Spacer(),
              StdButton(
                text: S.of(context).skip_to_quick_chat,
                onPressed: _skipToQuickChat,
              ),
            ],
          ),
          Expanded(
            child: (PlatForm().isMobile)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: children,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: children,
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
                onPressed: () {
                  prevPage();
                },
                icon: Icon(Icons.arrow_back_ios_sharp),
              ),
              const SizedBox(width: 5),
              Text(
                S.of(context).setup_agent_hint,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              StdButton(
                text: S.of(context).skip_to_quick_chat,
                onPressed: _skipToQuickChat,
              ),
            ],
          ),
          Expanded(
            child: AgentSetPage(
              onSaveReturn: () async {
                //ref.read(ragEditState.notifier).newState();
                try {
                  var agent = await DatabaseService.instance
                      .getAllAgents()
                      .then((v) => v.firstWhere((e) => e.id != "@instant"));
                  await DatabaseService.instance.setDefaultAgent(agent.id);
                } catch (e) {
                  // ignore
                }
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
    var children = [
      Expanded(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.of(context).setup_add_persona,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  textAlign: TextAlign.center,
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
      const SizedBox(width: 30),
      Expanded(
        child: Container(
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.all(4),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.zeroGradeColor,
          ),
          child: Webview(url: "${BASE_URL}docs/agents/persona"),
        ),
      ),
    ];
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
              const Spacer(),
              StdButton(
                text: S.of(context).skip_to_quick_chat,
                onPressed: _skipToQuickChat,
              ),
            ],
          ),
          Expanded(
            child: (PlatForm().isMobile)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: children,
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: children,
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
              const Spacer(),
              StdButton(
                text: S.of(context).skip_to_quick_chat,
                onPressed: _skipToQuickChat,
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
                    textAlign: TextAlign.center,
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
                          Flexible(
                            child: Text(
                              S.of(context).star_github,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
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
                      //set the default model for instant chat
                      try {
                        final providers = await ApiDatabase.instance
                            .getAllProviders();
                        if (providers.isNotEmpty) {
                          final firstProvider = providers.first;
                          final configs = await ApiDatabase.instance
                              .getProviderModelConfigs(firstProvider.id);
                          if (configs.isNotEmpty) {
                            final firstConfig = configs.first;
                            final modelConfig = ModelConfigure(
                              modelId: firstConfig.modelId,
                              providerId: firstProvider.id,
                              maxGenerationTokens: -1,
                              maxContextTokens: 1000000000,
                              enableTimeTelling: false,
                              enableUsrLanguage: false,
                              enableUsrSystemInformation: false,
                            );
                            await i.setString(
                              "instant_agent_configure",
                              jsonEncode(modelConfig.toMap()),
                            );
                          }
                        }
                      } catch (e) {
                        // Ignore or log
                      }
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
