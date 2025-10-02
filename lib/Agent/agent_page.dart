import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/utils/api_database_service.dart';
import 'package:uni_chat/utils/dialog.dart';

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
                "Agent管理",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
              Expanded(child: SizedBox()),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return StdButton(
                    text: "创建一个新的Agent",
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    return FutureBuilder(
      future: DatabaseService.instance.getAllAgents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("没有可用的Agent", style: TextStyle(color: theme.boxColor)),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final agent = snapshot.data![index];
            return StdListTile(
              leading: FlutterLogo(size: 50),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(agent.name, style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.boxColor,
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
        color: theme.surfaceColor,
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
                  "确定要删除此Agent吗？\n 删除后所有和此Agent关联的聊天记录将会一并删除",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  StdButton(
                    color: theme.boxColor,
                    onPressed: () {
                      OverlayPortalService.hide(context);
                    },
                    text: "取消",
                  ),
                  const SizedBox(width: 16),
                  StdButton(
                    color: Colors.red,
                    onLongPress: () async {
                      OverlayPortalService.hide(context);
                      await DatabaseService.instance.deleteAgent(agentId);
                    },
                    text: "确定(长按)",
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
