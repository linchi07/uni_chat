import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/error_handling.dart';
import 'package:uni_chat/utils/overlays.dart';

import '../database/database_service.dart';
import '../generated/l10n.dart';
import '../theme_manager.dart';
import '../utils/prebuilt_widgets.dart';
import 'agent_models.dart';
import 'agent_set_page.dart';

class AgentPage extends StatefulWidget {
  const AgentPage({super.key});

  @override
  State<AgentPage> createState() => _AgentPageState();
}

class _AgentPageState extends State<AgentPage> {
  bool _isEditing = false;
  void onBack() {
    setState(() {
      _isEditing = false;
    });
  }

  void onEdit() {
    setState(() {
      _isEditing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return AgentSetPage(onSaveReturn: onBack, onBack: onBack);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              Text(
                S.of(context).agent_manage,
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
              Expanded(child: SizedBox()),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return StdButton(
                    text: S.of(context).create_new_agent,
                    onPressed: () {
                      ref.read(agentEditState.notifier).state =
                          AgentEditState();
                      setState(() {
                        _isEditing = true;
                      });
                    },
                  );
                },
              ),
              const SizedBox(width: 30),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 5, 10),
            child: AgentSelector(onEdit: onEdit),
          ),
        ),
      ],
    );
  }
}

class AgentSelector extends ConsumerWidget {
  const AgentSelector({super.key, required this.onEdit});
  final dynamic onEdit;

  Future<(List<AgentData>, List<File?>)> getAgentAndAvatars() async {
    var allAgents = await DatabaseService.instance.getAllAgents();
    var agents =
        allAgents.where((agent) => agent.id != INSTANT_AGENT_ID).toList();
    var avatars = <File?>[];
    for (var agent in agents) {
      avatars.add(await agent.getAvatar());
    }
    return (agents, avatars);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    return StatefulBuilder(
      builder: (context, setState) {
        return FutureBuilder(
          future: getAgentAndAvatars(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  (snapshot.error is AppException)
                      ? (snapshot.error as AppException).unwrapAndGetMessage(
                          context,
                        )
                      : S.of(context).error_occurred,
                  style: TextStyle(color: theme.thirdGradeColor),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.$1.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context).no_agent,
                      style: TextStyle(color: theme.thirdGradeColor),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.$1.length,
              itemBuilder: (context, index) {
                final agent = snapshot.data!.$1[index];
                return StdListTile(
                  leading: StdAvatar(
                    file: snapshot.data!.$2[index],
                    length: 50,
                    showBorder: true,
                  ),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(agent.name, style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.thirdGradeColor,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Text(
                          agent.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(agent.description ?? ""),
                  onTap: () {},
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          ref.read(agentEditState.notifier).state =
                              await AgentEditState.fromAgentData(agent);
                          onEdit();
                        },
                        icon: Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () {
                          OverlayPortalService.showDialog(
                            context,
                            child: Text(
                              S.of(context).agent_delete_confirm,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            actions: [
                              StdButton(
                                color: theme.thirdGradeColor,
                                onPressed: () {
                                  OverlayPortalService.hide(context);
                                },
                                text: S.of(context).cancel,
                              ),
                              const SizedBox(width: 16),
                              StdButton(
                                color: theme.errorColor,
                                onLongPress: () async {
                                  await OverlayPortalService.hide(context);
                                  await DatabaseService.instance.deleteAgent(
                                    agent.id,
                                  );
                                  setState(() {});
                                },
                                text: S.of(context).confirm_long_press,
                              ),
                            ],
                            backGroundColor: theme.zeroGradeColor,
                          );
                        },
                        icon: Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
