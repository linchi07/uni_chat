import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/RAG/rag_databases.dart';
import 'package:uni_chat/RAG/rag_entity.dart';
import 'package:uni_chat/RAG/rag_settings.dart';
import 'package:uni_chat/utils/api_database_service.dart';

import '../generated/l10n.dart';
import '../theme_manager.dart';
import '../utils/dialog.dart';
import '../utils/prebuilt_widgets.dart';

class RagPage extends StatefulWidget {
  const RagPage({super.key});

  @override
  State<RagPage> createState() => _RagPageState();
}

class _RagPageState extends State<RagPage> {
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
      return RagSettingPage(onBack: onBack);
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
                "知识库&记忆",
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
              Expanded(child: SizedBox()),
              StdButton(
                text: "新建知识库",
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
              const SizedBox(width: 30),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: RAGSelector(onEdit: onEdit),
          ),
        ),
      ],
    );
  }
}

class RAGSelector extends ConsumerWidget {
  const RAGSelector({super.key, required this.onEdit});
  final dynamic onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    return FutureBuilder(
      future: RAGDatabaseManager().getAllKnowledgeBases(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("没有知识库", style: TextStyle(color: theme.thirdGradeColor)),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final base = snapshot.data![index];
            return StdListTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(base.name, style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: base.status == KnowledgeBaseStat.OK
                          ? Colors.greenAccent
                          : Colors.orangeAccent[200],
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Text(
                      base.status.getName(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                ],
              ),
              subtitle: Text(base.description),
              onTap: () {},
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      var kb = snapshot.data![index];
                      var em = await ApiDatabaseService.instance
                          .getProviderModelConfig(
                            kb.embeddings.first.modelConfigId,
                          );
                      if (em == null) {
                        return;
                      }
                      var em2 = await ApiDatabaseService.instance
                          .getProviderAndModelByModelConfig(em.id);
                      var r = await RAGDatabaseManager()
                          .getAutoIndexRulesByKnowledgeBaseId(kb.id);
                      ref.read(ragEditState.notifier).state = RagEditState(
                        id: kb.id,
                        name: kb.name,
                        description: kb.description,
                        embedding: em2.$2,
                        provider: em2.$1,
                        dimensions: kb.embeddings.first.vectorDimension,
                        indexMethods: kb.defaultIndexMethod,
                        indexRules: {for (var r in r) r.id: r},
                      );
                      onEdit();
                    },
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      OverlayPortalService.show(
                        context,
                        child: _confirmDeleteDialog(theme, context, base.id),
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
                  "确认要删除该知识库吗？",
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
