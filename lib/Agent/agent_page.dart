import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/utils/api_database_service.dart';
import 'package:uni_chat/utils/overlays.dart';

import '../generated/l10n.dart';
import '../theme_manager.dart';
import '../utils/database_service.dart';
import '../utils/prebuilt_widgets.dart';
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
      return AgentSetPage(onBack: onBack);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 60),
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
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
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
    var agents = await DatabaseService.instance.getAllAgents();
    var avatars = <File?>[];
    for (var agent in agents) {
      avatars.add(await agent.getAvatar());
    }
    return (agents, avatars);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    return FutureBuilder(
      future: getAgentAndAvatars(),
      builder: (context, snapshot) {
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
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                      var result = await ApiDatabaseService.instance
                          .getProviderAndModelByModelConfig(
                            agent.modelProviderConfigureId,
                          );
                      ref
                          .read(agentEditState.notifier)
                          .state = AgentEditState.fromAgentData(
                        agent,
                        result.$1,
                        result.$2,
                      );
                      onEdit();
                    },
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      OverlayPortalService.show(
                        context,
                        child: _confirmDeleteDialog(theme, context, agent.id),
                      );
                    },
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _confirmDeleteDialog(
    ThemeConfig theme,
    BuildContext context,
    String agentId,
  ) {
    return SizedBox(
      width: 300,
      height: 200,
      child: Material(
        color: theme.zeroGradeColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  S.of(context).agent_delete_confirm,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  StdButton(
                    color: theme.thirdGradeColor,
                    onPressed: () {
                      OverlayPortalService.hide(context);
                    },
                    text: S.of(context).cancel,
                  ),
                  const SizedBox(width: 16),
                  StdButton(
                    color: Colors.red,
                    onLongPress: () async {
                      OverlayPortalService.hide(context);
                      await DatabaseService.instance.deleteAgent(agentId);
                    },
                    text: S.of(context).confirm_long_press,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
