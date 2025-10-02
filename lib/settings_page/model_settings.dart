import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/utils/api_database_service.dart';
import 'package:uni_chat/utils/dialog.dart';
import 'package:uni_chat/utils/llm_image_indexer.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';

import '../theme_manager.dart';

class ModelSettings extends ConsumerStatefulWidget {
  const ModelSettings({super.key});

  @override
  ConsumerState<ModelSettings> createState() => _ModelSettingsState();
}

class _ModelSettingsState extends ConsumerState<ModelSettings> {
  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('模型管理', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder(
              future: ApiDatabaseService.instance.getAllModels(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.isEmpty) {
                  return const Center(child: Text('没有模型,请前往API设置中添加'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final model = snapshot.data![index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              onTap: () {},
                              tileColor: theme.surfaceColor,
                              leading: CircleAvatar(
                                radius: 25,
                                foregroundImage: AssetImage(
                                  LLMImageIndexer.getImagePath(model.family),
                                ),
                                foregroundColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                              ),
                              title: Text(model.friendlyName),
                              subtitle: Text(model.family),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  OverlayPortalService.show(
                                    context,
                                    child: _confirmDeleteDialog(
                                      context,
                                      model.id,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          StdButton(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                "查看所有提供该模型的提供商",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            onPressed: () {
                              OverlayPortalService.show(
                                context,
                                child: _showProviders(context, model.id),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  late ThemeConfig theme;

  Widget _confirmDeleteDialog(BuildContext context, String modelId) {
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
                  "确定要删除此模型吗？\n 删除后所有提供此模型的提供者将无法使用此模型。",
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
                      await ApiDatabaseService.instance.deleteModel(modelId);
                      setState(() {});
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

  Widget _showProviders(BuildContext context, String modelId) {
    return SizedBox(
      width: 400,
      height: 500,
      child: Material(
        color: theme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.hardEdge,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                "该模型的所有提供商",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder(
                  future: ApiDatabaseService.instance.getProvidersByModel(
                    modelId,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return StdListTile(
                          title: Text(snapshot.data![index].name),
                          subtitle: Text(snapshot.data![index].type),
                          onTap: () {},
                        );
                      },
                    );
                  },
                ),
              ),
              StdButton(
                text: "关闭",
                onPressed: () {
                  OverlayPortalService.hide(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
