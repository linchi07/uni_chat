import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide MetaData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:uni_chat/RAG/rag_databases.dart';
import 'package:uni_chat/RAG/rag_entity.dart';
import 'package:uni_chat/RAG/rag_process.dart';
import 'package:uni_chat/llm_provider/pre_built_models.dart';
import 'package:uni_chat/utils/api_database_service.dart';
import 'package:uni_chat/utils/back_ground_task_manager.dart';
import 'package:uni_chat/utils/database_service.dart';
import 'package:uni_chat/utils/file_utils.dart';
import 'package:uuid/uuid.dart';

import '../generated/l10n.dart';
import '../theme_manager.dart';
import '../utils/dialog.dart';
import '../utils/llm_image_indexer.dart';
import '../utils/prebuilt_widgets.dart';

class RagEditState {
  late final String id;
  final String? name;
  final String? description;
  final Model? embedding;
  ApiProvider? provider;
  final int? dimensions;
  final int? maxTokens;
  final bool isValidateMode;
  late final Set<RAGIndexMethod> defaultIndexMethods;
  final int requireEmbedding;
  //这些内容只会被在整个编辑模式的确定按钮按下的时候从数据库移除
  late final Set<String> contentRemoveRequireConfirmed;
  //为什么有memory和content两个呢？主要是上面那个是已经存入数据库了，在取消的时候会被remove。(文档比较大，所以先放进数据库中)
  //而下面那个没有被存入数据库，只有在添加的时候才会被存入数据库
  //万一用户添加到一半强制退出了怎么办，这不会影响基础功能
  //TODO: clean database when needed by removing those content that doesn't have a available knowledge base id
  late final Map<String, OriginalContent> memoriesAddRequireConfirmed;
  late final Map<String, OriginalContent> contentModifiedRequireConfirmed;
  late final Map<String, AutoIndexRule> indexRules;
  RagEditState({
    String? id,
    this.name,
    this.description,
    this.embedding,
    this.provider,
    this.dimensions,
    this.maxTokens,
    this.isValidateMode = false,
    Set<RAGIndexMethod>? indexMethods,
    Set<String>? contentRemoveRequireConfirmed,
    Map<String, OriginalContent>? memoriesAddRequireConfirmed,
    Map<String, OriginalContent>? contentModifiedRequireConfirmed,
    Map<String, AutoIndexRule>? indexRules,
    this.requireEmbedding = 0,
  }) {
    this.id = id ?? Uuid().v4();
    this.defaultIndexMethods = indexMethods ?? {RAGIndexMethod.vector};
    this.contentRemoveRequireConfirmed = contentRemoveRequireConfirmed ?? {};
    this.memoriesAddRequireConfirmed = memoriesAddRequireConfirmed ?? {};
    this.contentModifiedRequireConfirmed =
        contentModifiedRequireConfirmed ?? {};
    this.indexRules = indexRules ?? {};
  }

  bool validate() {
    if (!(name?.isNotEmpty ?? false)) {
      return false;
    }
    if (embedding == null || provider == null || dimensions == null) {
      return false;
    }
    return true;
  }

  //这么多循环，或许需要放到后台线程执行
  //TODO: throw this into a background thread
  Future<KnowledgeBase> save() async {
    for (var cr in contentRemoveRequireConfirmed) {
      await RAGDatabaseManager().deleteOriginalContent(cr);
    }
    for (var o in memoriesAddRequireConfirmed.values) {
      if (o.content.isNotEmpty &&
          (o.metadata.originalName?.isNotEmpty ?? false)) {
        o.content.trim();
        o.metadata.originalName = o.metadata.originalName!.trim();
        await RAGDatabaseManager().insertOriginalContent(o);
      }
    }
    for (var c in contentModifiedRequireConfirmed.values) {
      if (c.content.isNotEmpty &&
          (c.metadata.originalName?.isNotEmpty ?? false)) {
        c.hash = await RagProcessor.xxH3(c.content);
        await RAGDatabaseManager().updateOriginalContent(c);
      }
    }
    for (var c in indexRules.values) {
      await RAGDatabaseManager().insertOrUpdateAutoIndexRule(c);
    }
    var mfid = await ApiDatabaseService.instance
        .getProviderModelConfigsForModelWithProvider(
          embedding!.id,
          provider!.id,
        );
    var em = Embedding(
      id: Uuid().v4(),
      knowledgeBaseId: id,
      embeddingModelName: embedding?.friendlyName ?? "",
      vectorDimension: dimensions!,
      modelConfigId: mfid.first.id,
    );
    var kb = KnowledgeBase(
      id: id,
      name: name!,
      description: description ?? "",
      defaultIndexMethod: defaultIndexMethods,
      embeddings: [em],
      createdAt: DateTime.now(),
    );
    await RAGDatabaseManager().insertOrUpdateKnowledgeBase(kb);
    return kb;
  }

  RagEditState copyWith({
    String? id,
    String? name,
    String? description,
    Model? embedding,
    ApiProvider? provider,
    int? dimension,
    int? maxTokens,
    bool? isValidateMode,
    int? requireEmbedding,
    Set<RAGIndexMethod>? indexMethods,
    List<String>? contentAddRequireConfirmed,
    Set<String>? contentRemoveRequireConfirmed,
    Map<String, OriginalContent>? memoriesAddRequireConfirmed,
    Map<String, OriginalContent>? contentModifiedRequireConfirmed,
    Map<String, AutoIndexRule>? indexRules,
  }) {
    return RagEditState(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      embedding: embedding ?? this.embedding,
      provider: provider ?? this.provider,
      dimensions: dimension ?? this.dimensions,
      maxTokens: maxTokens ?? this.maxTokens,
      isValidateMode: isValidateMode ?? this.isValidateMode,
      requireEmbedding: requireEmbedding ?? this.requireEmbedding,
      indexMethods: indexMethods ?? this.defaultIndexMethods,
      contentRemoveRequireConfirmed:
          contentRemoveRequireConfirmed ?? this.contentRemoveRequireConfirmed,
      memoriesAddRequireConfirmed:
          memoriesAddRequireConfirmed ?? this.memoriesAddRequireConfirmed,
      contentModifiedRequireConfirmed:
          contentModifiedRequireConfirmed ??
          this.contentModifiedRequireConfirmed,
      indexRules: indexRules ?? this.indexRules,
    );
  }
}

final ragEditState = StateProvider((ref) => RagEditState());

enum SelectedRAGSection {
  fileManagement,
  websiteManagement,
  entriesManagement,
  autoIndexSettings,
}

class RagSettingPage extends ConsumerStatefulWidget {
  const RagSettingPage({super.key, required this.onBack});
  final dynamic onBack;
  @override
  ConsumerState<RagSettingPage> createState() => _RagSettingPageState();
}

class _RagSettingPageState extends ConsumerState<RagSettingPage>
    with SingleTickerProviderStateMixin {
  late RagEditState ragState;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  late ThemeConfig theme;
  Widget _sideBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              S.of(context).edit_knowledge_base,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            controller: nameController,
            decoration: InputDecoration(
              isDense: true,
              hintText: S.of(context).enter_knowledge_base_name,
              border: InputBorder.none,
              hintStyle: (ragState.name == null && ragState.isValidateMode)
                  ? TextStyle(fontSize: 20, color: Colors.red)
                  : null,
            ),
            onChanged: (value) {
              var n = ref.read(ragEditState.notifier);
              n.state = n.state.copyWith(name: value);
            },
          ),
          const SizedBox(height: 3),
          TextField(
            style: const TextStyle(fontSize: 15),
            controller: descriptionController,
            minLines: 2,
            maxLines: 2,
            decoration: InputDecoration(
              isDense: true,
              hintText: S.of(context).enter_knowledge_base_description,
              border: InputBorder.none,
            ),
            onChanged: (value) {
              var n = ref.read(ragEditState.notifier);
              n.state = n.state.copyWith(description: value);
            },
          ),
          const SizedBox(height: 10),
          Text(S.of(context).embedding_model, style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          EmbeddingDropDown(),
          const SizedBox(height: 10),
          _ProviderDropDown(),
          const SizedBox(height: 10),
          Text(
            S.of(context).embedding_dimension,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          _dimensionDropDown(),
          const SizedBox(height: 10),
          Text(
            S.of(context).default_index_method,
            style: TextStyle(fontSize: 18),
          ),
          _defaultIndexMethod(),
          const SizedBox(height: 10),
          Expanded(child: _knowledgeBaseSections()),
          Row(
            children: [
              Expanded(
                child: StdButton(
                  text: S.of(context).cancel_long_press,
                  color: theme.thirdGradeColor,
                  onLongPress: () async {
                    var n = ref.read(ragEditState.notifier);
                    n.state = RagEditState();
                    widget.onBack();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _buildSaveButton()),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);
    ragState = ref.watch(ragEditState);
    var mainContent = switch (selectedSection) {
      SelectedRAGSection.fileManagement => RagFileManagement(),
      SelectedRAGSection.websiteManagement => RagWebsiteManagement(),
      SelectedRAGSection.entriesManagement => RagMemoryManagement(),
      SelectedRAGSection.autoIndexSettings => RagAutoIndexManagement(),
    };
    return Row(
      children: [
        const SizedBox(width: 16),
        Expanded(child: _sideBar()),
        Expanded(flex: 2, child: mainContent),
      ],
    );
  }

  SelectedRAGSection selectedSection = SelectedRAGSection.fileManagement;

  Widget _knowledgeBaseSections() {
    //防止无法clip的问题
    return Material(
      clipBehavior: Clip.hardEdge,
      color: Colors.transparent,
      child: ListView(
        children: [
          StdListTile(
            title: Text(
              S.of(context).file_manage,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            onTap: () {
              setState(() {
                selectedSection = SelectedRAGSection.fileManagement;
              });
            },
            isSelected: selectedSection == SelectedRAGSection.fileManagement,
          ),
          const Divider(),
          StdListTile(
            title: Text(
              S.of(context).website_manage,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            onTap: () {
              setState(() {
                selectedSection = SelectedRAGSection.websiteManagement;
              });
            },
            isSelected: selectedSection == SelectedRAGSection.websiteManagement,
          ),
          const Divider(),
          StdListTile(
            title: Text(
              S.of(context).memory_manage,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            onTap: () {
              setState(() {
                selectedSection = SelectedRAGSection.entriesManagement;
              });
            },
            isSelected: selectedSection == SelectedRAGSection.entriesManagement,
          ),
          const Divider(),
          StdListTile(
            title: Text(
              S.of(context).auto_index_rules_set,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            onTap: () {
              setState(() {
                selectedSection = SelectedRAGSection.autoIndexSettings;
              });
            },
            isSelected: selectedSection == SelectedRAGSection.autoIndexSettings,
          ),
        ],
      ),
    );
  }

  Widget _defaultIndexMethod() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StdCheckbox(
          text: S.of(context).vector_index,
          value: ragState.defaultIndexMethods.contains(RAGIndexMethod.vector),
          onChanged: (val) {
            if (val == null) return;
            (val)
                ? ragState.defaultIndexMethods.add(RAGIndexMethod.vector)
                : ragState.defaultIndexMethods.remove(RAGIndexMethod.vector);
            var n = ref.read(ragEditState.notifier);
            n.state = ragState.copyWith();
          },
        ),
        StdCheckbox(
          text: S.of(context).keyword_index,
          value: ragState.defaultIndexMethods.contains(RAGIndexMethod.keyword),
          onChanged: (val) {
            if (val == null) return;
            (val)
                ? ragState.defaultIndexMethods.add(RAGIndexMethod.keyword)
                : ragState.defaultIndexMethods.remove(RAGIndexMethod.keyword);
            var n = ref.read(ragEditState.notifier);
            n.state = ragState.copyWith();
          },
        ),
        StdCheckbox(
          text: S.of(context).regex_index,
          value: ragState.defaultIndexMethods.contains(RAGIndexMethod.regex),
          onChanged: (val) {
            if (val == null) return;
            (val)
                ? ragState.defaultIndexMethods.add(RAGIndexMethod.regex)
                : ragState.defaultIndexMethods.remove(RAGIndexMethod.regex);
            var n = ref.read(ragEditState.notifier);
            n.state = ragState.copyWith();
          },
        ),
      ],
    );
  }

  static List<int> dimensions = const [512, 768, 1024, 1536];
  Widget _dimensionDropDown() {
    return StdDropDown(
      initialIndex: (ragState.dimensions == null)
          ? null
          : dimensions.indexWhere((e) => ragState.dimensions == e),
      height: 50,
      width: double.maxFinite,
      nullHint: Text(S.of(context).plz_select_embedding_dimension),
      onChanged: (index) {
        var n = ref.read(ragEditState.notifier);
        n.state = n.state.copyWith(dimension: dimensions[index]);
      },
      itemBuilder: (context, index, onTap) {
        return StdListTile(
          title: Text(dimensions[index].toString()),
          onTap: () {
            onTap(index);
          },
        );
      },
      itemCount: dimensions.length,
    );
  }

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 定义左右晃动的非线性动画
    _animation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1.5),
          TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1.5),
          TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutSine, // 使用非线性曲线
          ),
        );
    _controller.addListener(() {
      setState(() {});
    });
    ragState = ref.read(ragEditState);
    if (ragState.name != null) {
      nameController.text = ragState.name!;
    }
    if (ragState.description != null) {
      descriptionController.text = ragState.description!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSaveButton() {
    return Transform.translate(
      offset: Offset(_animation.value, 0), // 根据动画值设置水平位移
      child: StdButton(
        text:
            (ragState.provider == null ||
                ragState.dimensions == null ||
                ragState.embedding == null)
            ? S.of(context).model_or_dimension_not_set
            : S.of(context).save,
        onPressed: () async {
          ref.read(ragEditState.notifier).state = ragState.copyWith(
            isValidateMode: true,
          );
          if (ragState.validate()) {
            var kb = await ragState.save();
            var ac = Activity(
              name: kb.name,
              referTo: kb.id,
              type: ActivityType.ragEmbedding,
              stateType: ActivityStateType.loading,
            );
            ref.read(activityProvider.notifier).startActivity(ac);
            widget.onBack();
          } else {
            _controller.forward(from: 0);
          }
        },
      ),
    );
  }
}

class EmbeddingDropDown extends ConsumerStatefulWidget {
  const EmbeddingDropDown({super.key});
  @override
  ConsumerState<EmbeddingDropDown> createState() => _ModelDropDownState();
}

class _ModelDropDownState extends ConsumerState<EmbeddingDropDown>
    with SingleTickerProviderStateMixin {
  Model? selectedIndex;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.7, curve: Curves.easeInOut), // 前半段时间执行
      ),
    );
    selectedIndex = ref.read(ragEditState).embedding;
  }

  void onTap(Model model) {
    if (model == selectedIndex) return;
    setState(() {
      selectedIndex = model;
    });
    var n = ref.read(ragEditState.notifier);
    var n2 = n.state.copyWith(embedding: model);
    //此处在模型更改的时候需清除提供商
    n2.provider = null;
    n.state = n2;
    // 注意：这里的key应该与show时使用的key一致
    OverlayPortalService.hide(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    return SizedBox(
      height: 40,
      width: double.maxFinite,
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: theme.zeroGradeColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: () {
            var rb = context.findRenderObject() as RenderBox;
            OverlayPortalService.show(
              context,
              barrierVisible: false,
              offset: rb.localToGlobal(Offset.zero),
              // 这是你要求修改的部分
              child: SizeTransition(
                sizeFactor: _scaleAnimation,
                child: SizedBox(
                  width: rb.size.width + 4,
                  height: rb.size.height * 7 + 3,
                  child: Material(
                    elevation: 4,
                    color: theme.zeroGradeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FutureBuilder(
                      future: ApiDatabaseService.instance.getAllModels(
                        withAbilities: {ModelAbility.embedding},
                      ),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (asyncSnapshot.data == null) {
                          return Center(
                            child: Text(S.of(context).error_occurred),
                          );
                        }
                        return Column(
                          children: [
                            // 这个三元运算符可以简化
                            if (selectedIndex != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 16.0),
                                    StdAvatar(
                                      assetImage: AssetImage(
                                        LLMImageIndexer.getImagePath(
                                          selectedIndex!.family,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        selectedIndex!.friendlyName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: theme.textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Divider(),
                            if (asyncSnapshot.data!.isEmpty)
                              Expanded(
                                child: Center(
                                  child: Text(
                                    S.of(context).no_embedding_model,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            //只是用来绘制inkwell
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: (_scaleAnimation.isCompleted)
                                    ? SizedBox()
                                    : ListView.builder(
                                        itemCount: asyncSnapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          return StdListTile(
                                            onTap: () {
                                              onTap(asyncSnapshot.data![index]);
                                            },
                                            title: Text(
                                              asyncSnapshot
                                                  .data![index]
                                                  .friendlyName,
                                            ),
                                            subtitle: Text(
                                              asyncSnapshot.data![index].family,
                                            ),
                                            leading: StdAvatar(
                                              assetImage: AssetImage(
                                                LLMImageIndexer.getImagePath(
                                                  asyncSnapshot
                                                      .data![index]
                                                      .family,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
            // 启动动画 (这个是必须的)
            _controller.forward(from: 0.0);
          },
          child: (selectedIndex == null)
              ? Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        S.of(context).select_model_hint,
                        style: TextStyle(fontSize: 16, color: theme.textColor),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: theme.textColor),
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16),
                    StdAvatar(
                      length: 26,
                      assetImage: AssetImage(
                        LLMImageIndexer.getImagePath(selectedIndex!.family),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedIndex!.friendlyName,
                        style: TextStyle(fontSize: 16, color: theme.textColor),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ProviderDropDown extends ConsumerStatefulWidget {
  const _ProviderDropDown({super.key});
  @override
  ConsumerState<_ProviderDropDown> createState() => _ProviderDropDownState();
}

class _ProviderDropDownState extends ConsumerState<_ProviderDropDown>
    with SingleTickerProviderStateMixin {
  ApiProvider? selectedIndex;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.7, curve: Curves.easeInOut), // 前半段时间执行
      ),
    );
    selectedIndex = ref.read(ragEditState).provider;
  }

  void onTap(ApiProvider provider) {
    setState(() {
      selectedIndex = provider;
    });
    var n = ref.read(ragEditState.notifier);
    n.state = n.state.copyWith(provider: provider);
    // 注意：这里的key应该与show时使用的key一致
    OverlayPortalService.hide(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    var as = ref.watch(ragEditState);
    if (as.embedding == null) {
      return SizedBox();
    }
    ref.listen(ragEditState, (previous, next) {
      if (previous != null &&
          previous.provider != null &&
          previous.embedding != next.embedding) {
        selectedIndex = null;
      }
    });
    return SizedBox(
      height: 40,
      width: double.maxFinite,
      child: Material(
        clipBehavior: Clip.hardEdge,
        color: theme.zeroGradeColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: () {
            var rb = context.findRenderObject() as RenderBox;
            OverlayPortalService.show(
              context,
              barrierVisible: false,
              offset: rb.localToGlobal(Offset.zero),
              // 这是你要求修改的部分
              child: SizeTransition(
                sizeFactor: _scaleAnimation,
                child: SizedBox(
                  width: rb.size.width + 4,
                  height: rb.size.height * 7 + 3,
                  child: Material(
                    elevation: 4,
                    color: theme.zeroGradeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FutureBuilder(
                      future: ApiDatabaseService.instance.getProvidersByModel(
                        as.embedding!.id,
                      ),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (asyncSnapshot.data == null) {
                          return Center(
                            child: Text(S.of(context).error_occurred),
                          );
                        }
                        return Column(
                          children: [
                            // 这个三元运算符可以简化
                            if (selectedIndex != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 16.0),
                                    StdAvatar(
                                      assetImage: AssetImage(
                                        LLMImageIndexer.getImagePath(
                                          selectedIndex!.name,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        selectedIndex!.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: theme.textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Divider(),
                            if (asyncSnapshot.data!.isEmpty)
                              Center(child: Text(S.of(context).no_provider)),
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: (_scaleAnimation.isCompleted)
                                    ? SizedBox()
                                    : ListView.builder(
                                        itemCount: asyncSnapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          return StdListTile(
                                            onTap: () {
                                              onTap(asyncSnapshot.data![index]);
                                            },
                                            title: Text(
                                              asyncSnapshot.data![index].name,
                                            ),
                                            leading: StdAvatar(
                                              assetImage: AssetImage(
                                                LLMImageIndexer.getImagePath(
                                                  asyncSnapshot
                                                      .data![index]
                                                      .name,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
            // 启动动画 (这个是必须的)
            _controller.forward(from: 0.0);
          },
          child: (selectedIndex == null)
              ? Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        S.of(context).plz_select_provider,
                        style: TextStyle(fontSize: 16, color: theme.textColor),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: theme.textColor),
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16),
                    StdAvatar(
                      length: 26,
                      assetImage: AssetImage(
                        LLMImageIndexer.getImagePath(selectedIndex!.name),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedIndex!.name,
                        style: TextStyle(fontSize: 16, color: theme.textColor),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class RagFileManagement extends ConsumerStatefulWidget {
  const RagFileManagement({super.key});

  @override
  ConsumerState<RagFileManagement> createState() => _RagFileManagementState();
}

class _RagFileManagementState extends ConsumerState<RagFileManagement> {
  List<OriginalContent> documents = [];
  bool _isLoading = false;
  late RagEditState ragState;
  late RagEditState old;
  @override
  void initState() {
    super.initState();
    ragState = ref.read(ragEditState);
    old = ragState;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDocuments();
    });
  }

  Future<void> _loadDocuments() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });
    try {
      final fetchedDocuments = await RAGDatabaseManager()
          .getAllOriginalContentOfKnowledgeBaseIdWithType(
            ragState.id,
            RagContentType.document,
          );
      for (var i = 0; i < fetchedDocuments.length; ++i) {
        var o = fetchedDocuments[i];
        if (ragState.contentRemoveRequireConfirmed.contains(o.id)) {
          fetchedDocuments.removeAt(i);
          --i;
        }
        if (ragState.contentModifiedRequireConfirmed.containsKey(o.id)) {
          fetchedDocuments.removeAt(i);
          --i;
        }
      }
      fetchedDocuments.addAll(ragState.contentModifiedRequireConfirmed.values);
      if (mounted) {
        setState(() {
          documents = fetchedDocuments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      // 处理错误，例如显示提示信息
    }
  }

  //网上找了半天，没找到合适的，要不然要钱，直接自己画了
  static Map<String, Widget> fileIcons = {
    ".json": Container(
      decoration: BoxDecoration(
        color: Colors.green[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          "JSON",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    ".docx": Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          "DOCX",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    '.csv': Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          "CSV",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    '.txt': Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          "TXT",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    '.md': Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          "MD",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    '.html': Container(
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          "HTML",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  };

  OriginalContent? _selected;
  bool isDroppingFiles = false;
  bool isDropFilesValid = false;
  bool isProcessing = false;
  (bool, dynamic, String) validateFormat(DropItem item) {
    if (item.canProvide(Formats.md)) {
      return (true, Formats.md, "md");
    }

    if (item.canProvide(Formats.htmlFile)) {
      return (true, Formats.htmlFile, "html");
    }

    if (item.canProvide(Formats.csv)) {
      return (true, Formats.csv, "csv");
    }

    if (item.canProvide(Formats.docx)) {
      return (true, Formats.docx, "docx");
    }
    if (item.canProvide(Formats.plainTextFile)) {
      return (true, Formats.plainTextFile, "txt");
    }
    if (item.canProvide(Formats.json)) {
      return (true, Formats.json, "json");
    }
    return (false, null, "");
  }

  void process(String path) async {
    try {
      //这个在后台运行
      var oc = await RagProcessor.loadTextDocument(
        path,
        ragState.id,
        ragState.defaultIndexMethods,
      );
      var n = ref.read(ragEditState.notifier);
      //所有和SQLite有关的操作都在前台进行，防止多线程冲突，或者哪天有空了给他加一个mutex。
      n.state.contentModifiedRequireConfirmed[oc.id] = oc;
      n.state = n.state.copyWith();
      await _loadDocuments();
      await File(path).delete();
    } catch (e) {
      // TODO: 错误处理
      print(e);
    }
    setState(() {
      isProcessing = false;
    });
  }

  late ThemeConfig theme;
  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);
    ragState = ref.watch(ragEditState);
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    Widget child;
    if (old.id != ragState.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDocuments();
        old = ragState;
      });
      child = const SizedBox();
    }
    child = Row(
      children: [
        Expanded(flex: 2, child: _buildFileView()),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  S.of(context).file_manage,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: theme.thirdGradeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: [
                            "md",
                            "docx",
                            "csv",
                            "txt",
                            "json",
                            "html",
                          ],
                        );
                        if (result != null) {
                          setState(() {
                            isProcessing = true;
                          });
                          process(result.files.single.path!);
                        }
                      },
                      child: Center(
                        child: Text.rich(
                          textAlign: TextAlign.center,
                          TextSpan(
                            text: "${S.of(context).click_or_drop_files_here}\n",
                            children: [
                              TextSpan(
                                text: S.of(context).support_formats,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(),
                (documents.isEmpty)
                    ? Center(child: Text(S.of(context).no_file))
                    : Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Material(
                            clipBehavior: Clip.hardEdge,
                            color: Colors.transparent,
                            child: ListView.builder(
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                return StdListTile(
                                  leading: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Center(
                                      child:
                                          fileIcons[documents[index]
                                              .metadata
                                              .extension] ??
                                          Icon(Icons.question_mark),
                                    ),
                                  ),
                                  title: Text(
                                    documents[index].metadata.originalName ??
                                        "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selected = documents[index];
                                    });
                                  },
                                  subtitle: Text(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    //TODO: don't use iso8601
                                    documents[index].insertedAt
                                        .toIso8601String(),
                                  ),
                                  isSelected: documents[index] == _selected,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );

    if (isProcessing) {
      return Center(child: CircularProgressIndicator());
    }

    return DropRegion(
      formats: Formats.standardFormats,
      onDropLeave: (e) {
        setState(() {
          isDroppingFiles = false;
        });
      },
      onDropOver: (event) {
        if (event.session.allowedOperations.contains(DropOperation.copy)) {
          if (validateFormat(event.session.items.first).$1) {
            setState(() {
              isDropFilesValid = true;
              isDroppingFiles = true;
            });
            return DropOperation.copy;
          } else {
            setState(() {
              isDropFilesValid = false;
              isDroppingFiles = true;
            });
            return DropOperation.forbidden;
          }
        }
        return DropOperation.none;
      },
      onPerformDrop: (e) async {
        var item = e.session.items.first;
        if (item.dataReader == null) {
          return;
        }
        var v = validateFormat(item);
        if (v.$1) {
          item.dataReader?.getFile(
            v.$2,
            (f) async {
              var path = await PathProvider.getPath(
                //有时候他会返回一个null，所以用当前时间
                "RAG/tmp/${f.fileName ?? "${DateTime.now().toIso8601String()}.${v.$3}"}",
              );
              final file = File(path);
              final sink = file.openWrite();
              await f.getStream().forEach(sink.add);
              await sink.close();
              setState(() {
                isProcessing = true;
              });
              process(path);
            },
            onError: (error) {
              return;
            },
          );
        }
      },
      //是的，这样很蠢，但是我发现，必须加上一个container而且必须指定一个颜色，这个时候拖拽有用
      //而不加的话拖拽无法触发，而且加sized box expand 或者centre都没用。有一个玄学问题·····
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            child,
            if (isDroppingFiles)
              Container(
                color: Colors.white.withAlpha(80),
                child: Container(
                  margin: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: (isDropFilesValid)
                        ? Colors.white.withAlpha(120)
                        : Colors.red[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      isDropFilesValid
                          ? S.of(context).drop_files_hint
                          : S.of(context).unsupported_format,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: (isDropFilesValid) ? Colors.black : Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileView() {
    if (_selected == null) {
      return Center(child: Text(S.of(context).no_file_selected));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: Center(
                  child:
                      fileIcons[_selected?.metadata.extension] ??
                      Icon(Icons.question_mark),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selected?.metadata.originalName ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      //TODO: don't use iso8601
                      _selected?.insertedAt.toIso8601String() ?? "",
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  var n = ref.read(ragEditState.notifier);
                  if (_selected != null) {
                    //这不可能发生
                    n.state.contentRemoveRequireConfirmed.add(_selected!.id);
                    n.state = n.state.copyWith();
                    setState(() {
                      _selected = null;
                      _loadDocuments();
                    });
                  }
                },
                icon: Icon(Icons.delete_outline, color: Colors.red, size: 30),
              ),
              const SizedBox(width: 20),
            ],
          ),
          const Divider(),
          (_selected?.indexMethod.isNotEmpty ?? true)
              ? Text(
                  S.of(context).index_settings,
                  style: TextStyle(fontSize: 20),
                )
              : Text.rich(
                  TextSpan(
                    text: S.of(context).index_settings,
                    style: TextStyle(fontSize: 20),
                    children: [
                      TextSpan(
                        text: "           ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: S.of(context).no_index_method_warning,
                        style: TextStyle(fontSize: 15, color: Colors.red),
                      ),
                    ],
                  ),
                ),
          StdCheckbox(
            textWidget: Text.rich(
              TextSpan(
                text: S.of(context).vector_index,
                children: [
                  TextSpan(
                    text: " ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: S.of(context).vec_index_hint,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            value:
                _selected?.indexMethod.contains(RAGIndexMethod.vector) ?? false,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                if (value) {
                  _selected?.indexMethod.add(RAGIndexMethod.vector);
                } else {
                  _selected?.indexMethod.remove(RAGIndexMethod.vector);
                }
                update();
              });
            },
          ),
          StdCheckbox(
            textWidget: Text.rich(
              TextSpan(
                text: S.of(context).keyword_index,
                children: [
                  TextSpan(
                    text: " ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: S.of(context).keyword_index_hint,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            value:
                _selected?.indexMethod.contains(RAGIndexMethod.keyword) ??
                false,
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                if (val) {
                  _selected?.indexMethod.add(RAGIndexMethod.keyword);
                } else {
                  _selected?.indexMethod.remove(RAGIndexMethod.keyword);
                }
                update();
              });
            },
          ),
          if (_selected?.indexMethod.contains(RAGIndexMethod.keyword) ?? false)
            _setKeywordSearch(),
          StdCheckbox(
            textWidget: Text.rich(
              TextSpan(
                text: S.of(context).regex_index,
                children: [
                  TextSpan(
                    text: " ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: S.of(context).regex_index_hint,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            value:
                _selected?.indexMethod.contains(RAGIndexMethod.regex) ?? false,
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                if (val) {
                  _selected?.indexMethod.add(RAGIndexMethod.regex);
                } else {
                  _selected?.indexMethod.remove(RAGIndexMethod.regex);
                }
                update();
              });
            },
          ),
          if (_selected?.indexMethod.contains(RAGIndexMethod.regex) ?? false)
            _setRegXSearch(),
          Expanded(
            child: SelectionArea(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: theme.zeroGradeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      _selected?.content ?? S.of(context).no_preview,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void update() {
    if (ragState.memoriesAddRequireConfirmed.containsKey(_selected?.id)) {
      ragState.memoriesAddRequireConfirmed[_selected!.id] = _selected!;
    } else {
      ragState.contentModifiedRequireConfirmed[_selected!.id] = _selected!;
    }
  }

  Widget _setKeywordSearch() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.of(context).enter_key_word_hint),
        StdTextFieldOutlined(
          hintText: S.of(context).enter_key_word_hint,
          onChanged: (value) {
            _selected?.keyWords = value;
          },
        ),
      ],
    );
  }

  Widget _setRegXSearch() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //我暂时没有考虑好怎么支持多个正则，需要转义，所以现在就是一个正则
        Text(S.of(context).enter_regex_hint),
        StdTextFieldOutlined(
          hintText: S.of(context).enter_regex_hint,
          onChanged: (value) {
            _selected?.regex = [value];
          },
        ),
      ],
    );
  }
}

class RagWebsiteManagement extends ConsumerStatefulWidget {
  const RagWebsiteManagement({super.key});

  @override
  ConsumerState<RagWebsiteManagement> createState() =>
      _RagWebsiteManagementState();
}

class _RagWebsiteManagementState extends ConsumerState<RagWebsiteManagement> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("网络索引功能将在后续实现 Web Search will be implemented later"),
    );
  }
}

class RagMemoryManagement extends ConsumerStatefulWidget {
  const RagMemoryManagement({super.key});

  @override
  ConsumerState<RagMemoryManagement> createState() =>
      _RagMemoryManagementState();
}

class _RagMemoryManagementState extends ConsumerState<RagMemoryManagement> {
  List<OriginalContent> memories = [];
  bool _isLoading = false;
  late RagEditState ragState;
  OriginalContent? _selected;

  @override
  void initState() {
    super.initState();
    ragState = ref.read(ragEditState);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMemories();
    });
  }

  Future<void> _loadMemories() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var oc = <OriginalContent>[];
      oc.addAll(ragState.memoriesAddRequireConfirmed.values);
      oc.addAll(
        await RAGDatabaseManager()
            .getAllOriginalContentOfKnowledgeBaseIdWithType(
              ragState.id,
              RagContentType.memory,
            ),
      );
      for (var i = 0; i < oc.length; ++i) {
        var o = oc[i];
        if (ragState.contentRemoveRequireConfirmed.contains(o.id)) {
          oc.removeAt(i);
          --i;
        }
      }
      if (mounted) {
        setState(() {
          memories = oc;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      // 处理错误，例如显示提示信息
    }
  }

  Widget _sideBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            S.of(context).memory_manage,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: StdButton(
              onPressed: () {
                var oc = OriginalContent(
                  id: Uuid().v7(),
                  knowledgeBaseId: ragState.id,
                  content: "",
                  contentType: RagContentType.memory,
                  insertedAt: DateTime.now(),
                  indexMethod: {...ragState.defaultIndexMethods},
                  metadata: MetaData(
                    originalName: "",
                    description: "",
                    contentType: RagContentType.memory,
                    createdAt: DateTime.now(),
                    lastModified: DateTime.now(),
                  ),
                );
                ragState.memoriesAddRequireConfirmed[oc.id] = oc;
                ref.read(ragEditState.notifier).state = ragState.copyWith();
                setState(() {
                  _selected = oc;
                  nameController.clear();
                  contentController.clear();
                  _loadMemories();
                });
              },
              child: SizedBox(
                width: double.maxFinite,
                child: Text(
                  textAlign: TextAlign.center,
                  S.of(context).no_memory,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.brightTextColor,
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          (memories.isEmpty)
              ? Expanded(child: Center(child: Text(S.of(context).no_memory)))
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Material(
                      clipBehavior: Clip.hardEdge,
                      color: Colors.transparent,
                      child: ListView.builder(
                        itemCount: memories.length,
                        itemBuilder: (context, index) {
                          var s = memories[index].id == _selected?.id;
                          return StdListTile(
                            title: Text(
                              //曲线救国实现编辑实时同步
                              ((s && _selected != null)
                                      ? _selected!.metadata.originalName
                                      : memories[index]
                                            .metadata
                                            .originalName) ??
                                  "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              setState(() {
                                _selected = memories[index];
                                //理论上这里绝对不可能是空
                                nameController.text =
                                    _selected?.metadata.originalName ?? "";
                                contentController.text =
                                    _selected?.content ?? "";
                              });
                            },
                            subtitle: Text(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              //TODO: don't use iso8601
                              memories[index].insertedAt.toIso8601String(),
                            ),
                            isSelected: s,
                          );
                        },
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  late ThemeConfig theme;
  @override
  Widget build(BuildContext context) {
    ragState = ref.watch(ragEditState);
    theme = ref.watch(themeProvider);
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Row(
      children: [
        Expanded(flex: 2, child: _buildMemoryView()),
        Expanded(flex: 1, child: _sideBar()),
      ],
    );
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  String lastV = "";
  Widget _buildMemoryView() {
    if (_selected == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(S.of(context).select_or_add_memory)],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: SizedBox()),
              IconButton(
                onPressed: () {
                  if (_selected == null) return;
                  if (ragState.memoriesAddRequireConfirmed[_selected!.id] !=
                      null) {
                    ragState.memoriesAddRequireConfirmed.remove(_selected!.id);
                    setState(() {
                      _selected = null;
                      _loadMemories();
                    });
                  } else {
                    ragState.contentRemoveRequireConfirmed.add(_selected!.id);
                    setState(() {
                      _selected = null;
                      _loadMemories();
                    });
                  }
                },
                icon: Icon(Icons.delete_outline, color: Colors.red, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 8),
          (_selected != null &&
                  (_selected!.metadata.originalName?.isNotEmpty ?? false))
              ? Text(S.of(context).memory_name, style: TextStyle(fontSize: 18))
              : Row(
                  children: [
                    Text(
                      S.of(context).memory_name,
                      style: TextStyle(fontSize: 18),
                    ),
                    Spacer(),
                    Text(
                      S.of(context).memory_name_waring,
                      style: TextStyle(fontSize: 15, color: Colors.red),
                    ),
                  ],
                ),
          const SizedBox(height: 8),
          StdTextFieldOutlined(
            controller: nameController,
            hintText: S.of(context).memory_name,
            onChanged: (v) {
              setState(() {
                _selected?.metadata.originalName = v;
                update();
              });
              if (_selected == null) {
                return;
              }
              ragState.memoriesAddRequireConfirmed[_selected!.id] = _selected!;
              //蜜汁抽象
            },
          ),
          const SizedBox(height: 8),
          (_selected != null && (_selected!.content.isNotEmpty ?? false))
              ? Text(
                  S.of(context).memory_content,
                  style: TextStyle(fontSize: 18),
                )
              : Row(
                  children: [
                    Text(
                      S.of(context).memory_content,
                      style: TextStyle(fontSize: 18),
                    ),
                    Spacer(),
                    Text(
                      S.of(context).memory_content_waring,
                      style: TextStyle(fontSize: 15, color: Colors.red),
                    ),
                  ],
                ),
          Text("关于占位符的使用，请查看文档", style: TextStyle(fontSize: 15)),
          const SizedBox(height: 8),
          Expanded(
            child: StatefulBuilder(
              builder: (context, ss) {
                return StdTextFieldOutlined(
                  controller: contentController,
                  hintText: S.of(context).memory_content,
                  isExpanded: true,
                  onChanged: (v) {
                    ss(() {
                      _selected = _selected?.copyWith(content: v);
                      update();
                    });
                    if ((lastV.isEmpty && v.isNotEmpty) ||
                        (lastV.isNotEmpty && v.isEmpty)) {
                      lastV = v;
                      setState(() {});
                    }
                  },
                );
              },
            ),
          ),
          const Divider(),
          (_selected?.indexMethod.isNotEmpty ?? true)
              ? Text(
                  S.of(context).index_settings,
                  style: TextStyle(fontSize: 20),
                )
              : Text.rich(
                  TextSpan(
                    text: S.of(context).index_settings,
                    style: TextStyle(fontSize: 20),
                    children: [
                      TextSpan(
                        text: "           ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: S.of(context).no_index_method_warning,
                        style: TextStyle(fontSize: 15, color: Colors.red),
                      ),
                    ],
                  ),
                ),
          StdCheckbox(
            textWidget: Text.rich(
              TextSpan(
                text: S.of(context).vector_index,
                children: [
                  TextSpan(
                    text: "           ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: S.of(context).vec_index_hint,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            value:
                _selected?.indexMethod.contains(RAGIndexMethod.vector) ?? false,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                if (value) {
                  _selected?.indexMethod.add(RAGIndexMethod.vector);
                } else {
                  _selected?.indexMethod.remove(RAGIndexMethod.vector);
                }
                update();
              });
            },
          ),
          StdCheckbox(
            textWidget: Text.rich(
              TextSpan(
                text: S.of(context).keyword_index,
                children: [
                  TextSpan(
                    text: "           ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: S.of(context).keyword_index_hint,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            value:
                _selected?.indexMethod.contains(RAGIndexMethod.keyword) ??
                false,
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                if (val) {
                  _selected?.indexMethod.add(RAGIndexMethod.keyword);
                } else {
                  _selected?.indexMethod.remove(RAGIndexMethod.keyword);
                }
                update();
              });
            },
          ),
          if (_selected?.indexMethod.contains(RAGIndexMethod.keyword) ?? false)
            _setKeywordSearch(),
          StdCheckbox(
            textWidget: Text.rich(
              TextSpan(
                text: S.of(context).regex_index,
                children: [
                  TextSpan(
                    text: "           ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: S.of(context).regex_index_hint,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            value:
                _selected?.indexMethod.contains(RAGIndexMethod.regex) ?? false,
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                if (val) {
                  _selected?.indexMethod.add(RAGIndexMethod.regex);
                } else {
                  _selected?.indexMethod.remove(RAGIndexMethod.regex);
                }
                update();
              });
            },
          ),
          if (_selected?.indexMethod.contains(RAGIndexMethod.regex) ?? false)
            _setRegXSearch(),
        ],
      ),
    );
  }

  void update() {
    if (ragState.memoriesAddRequireConfirmed.containsKey(_selected?.id)) {
      ragState.memoriesAddRequireConfirmed[_selected!.id] = _selected!;
    } else {
      ragState.contentModifiedRequireConfirmed[_selected!.id] = _selected!;
    }
  }

  Widget _setKeywordSearch() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.of(context).enter_key_word_hint),
        StdTextFieldOutlined(
          hintText: S.of(context).enter_key_word_hint,
          onChanged: (value) {
            _selected?.keyWords = value;
          },
        ),
      ],
    );
  }

  Widget _setRegXSearch() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.of(context).enter_regex_hint),
        StdTextFieldOutlined(
          hintText: S.of(context).enter_regex_hint,
          onChanged: (value) {
            _selected?.regex = [value];
          },
        ),
      ],
    );
  }
}

class RagAutoIndexManagement extends ConsumerStatefulWidget {
  const RagAutoIndexManagement({super.key});

  @override
  ConsumerState<RagAutoIndexManagement> createState() =>
      _RagAutoIndexManagementState();
}

class _RagAutoIndexManagementState
    extends ConsumerState<RagAutoIndexManagement> {
  late RagEditState ragState;
  List<AutoIndexRule> rules = [];
  Map<String, AgentData> agents = {};

  @override
  void initState() {
    super.initState();
    ragState = ref.read(ragEditState);
    _loadRules();
  }

  void _loadRules() {
    rules = ragState.indexRules.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    ragState = ref.watch(ragEditState);
    theme = ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              "${S.of(context).auto_index_rules_set}(BETA)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
            Expanded(child: SizedBox()),
            StdButton(
              text: S.of(context).create_new_rule,
              onPressed: () {
                setState(() {
                  rules.add(
                    AutoIndexRule(
                      id: Uuid().v4(),
                      knowledgeBaseId: ragState.id,
                      agents: [],
                      autoIndexMethod: AutoIndexMethod.always,
                      ragIndexMethod: {RAGIndexMethod.vector},
                    ),
                  );
                });
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: (rules.isEmpty)
              ? Center(child: Text(S.of(context).no_rules))
              : ListView.builder(
                  itemCount: rules.length,
                  itemBuilder: (c, i) {
                    return _buildRule(rules[i]);
                  },
                ),
        ),
      ],
    );
  }

  late ThemeConfig theme;
  Widget _buildRule(AutoIndexRule rule) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.zeroGradeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      S.of(context).auto_index_rules_1,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    StdButton(
                      color: theme.thirdGradeColor,
                      text: (rule.agents.isEmpty)
                          ? S.of(context).select_agent
                          : S.of(context).selected_agent(rule.agents.length),
                      onPressed: () {
                        OverlayPortalService.show(
                          context,
                          child: _buildAgentList(rule),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    Text(
                      S.of(context).auto_index_rules_2,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    issuerDropdown(rule),
                    const SizedBox(width: 10),
                    methodDropdown(rule),
                    const SizedBox(width: 10),
                    Text(
                      S.of(context).auto_index_rules_3,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                if (rule.autoIndexMethod == AutoIndexMethod.regex)
                  _setRegXSearch(rule),
                if (rule.autoIndexMethod == AutoIndexMethod.keyword)
                  _setKeywordSearch(rule),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                rules.remove(rule);
              });
            },
            icon: Icon(Icons.remove),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _setKeywordSearch(AutoIndexRule rule) {
    var controller = TextEditingController(text: rule.keyword);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(S.of(context).enter_key_word_hint),
        StdTextFieldOutlined(
          controller: controller,
          hintText: S.of(context).enter_key_word_hint,
          onChanged: (value) {
            rule.keyword = value;
          },
        ),
      ],
    );
  }

  Widget _setRegXSearch(AutoIndexRule rule) {
    var controller = TextEditingController(text: rule.regex?.firstOrNull ?? "");
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(S.of(context).enter_regex_hint),
        StdTextFieldOutlined(
          controller: controller,
          hintText: S.of(context).enter_regex_hint,
          onChanged: (value) {
            rule.regex = [value];
          },
        ),
      ],
    );
  }

  bool validate(AutoIndexRule rule) {
    if (rule.agents.isEmpty) return false;
    switch (rule.autoIndexMethod) {
      case AutoIndexMethod.keyword:
        return rule.keyword?.isNotEmpty ?? false;
      case AutoIndexMethod.regex:
        return rule.regex?.isNotEmpty ?? false;
      default:
        return true;
    }
  }

  void save(AutoIndexRule rule) {
    if (validate(rule)) {
      ragState.indexRules[rule.id] = rule;
    }
  }

  Set<AgentData> agentsSelected = {};

  Widget _buildAgentList(AutoIndexRule rule) {
    return SizedBox(
      height: 600,
      width: 700,
      child: Material(
        color: theme.zeroGradeColor,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).select_agent,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: FutureBuilder(
                  future: getAgentAndAvatars(),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState != ConnectionState.done ||
                        asyncSnapshot.data == null) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return StatefulBuilder(
                      builder: (context, setState) {
                        var build = <Widget>[];
                        for (
                          int i = 0;
                          i < asyncSnapshot.data!.$1.length;
                          i++
                        ) {
                          var a = asyncSnapshot.data!.$1[i];
                          var f = asyncSnapshot.data!.$2[i];
                          build.add(
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SizedBox(
                                width: 150,
                                child: StdListTile(
                                  isSelected: agentsSelected.contains(a),
                                  onTap: () {
                                    setState(() {
                                      if (agentsSelected.contains(a)) {
                                        agentsSelected.remove(a);
                                      } else {
                                        agentsSelected.add(a);
                                      }
                                    });
                                  },
                                  title: Text(a.name),
                                  leading: StdAvatar(file: f, length: 25),
                                ),
                              ),
                            ),
                          );
                        }
                        return SingleChildScrollView(
                          child: Wrap(children: build),
                        );
                      },
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  StdButton(
                    text: S.of(context).cancel,
                    color: theme.thirdGradeColor,
                    onPressed: () {
                      agentsSelected.clear();
                      OverlayPortalService.hide(context);
                    },
                  ),
                  const SizedBox(width: 10),
                  StdButton(
                    text: S.of(context).confirm,
                    onPressed: () {
                      OverlayPortalService.hide(context);
                      setState(() {
                        rule.agents = agentsSelected.map((m) => m.id).toList();
                        agentsSelected.clear();
                      });
                      save(rule);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<(List<AgentData>, List<File?>)> getAgentAndAvatars() async {
    var agents = await DatabaseService.instance.getAllAgents();
    var avatars = <File?>[];
    for (var agent in agents) {
      var avatar = await agent.getAvatar();
      avatars.add(avatar);
    }
    return (agents, avatars);
  }

  static List<Issuer> issuerEnum = [Issuer.assistant, Issuer.user, Issuer.any];
  Widget issuerDropdown(AutoIndexRule rule) {
    List<String> issuers = [
      S.of(context).ai,
      S.of(context).user,
      S.of(context).any,
    ];
    int? init;
    switch (rule.issuer) {
      case Issuer.any:
        init = 2;
        break;
      case Issuer.user:
        init = 1;
        break;
      case Issuer.assistant:
        init = 0;
        break;
      case null:
    }
    return StdDropDown(
      initialIndex: init,
      color: theme.thirdGradeColor,
      width: 150,
      height: 45,
      onChanged: (index) {
        rule.issuer = issuerEnum[index];
        validate(rule);
        setState(() {});
      },
      itemBuilder: (context, index, onTap) {
        return StdListTile(
          title: Text(issuers[index]),
          onTap: () {
            onTap(index);
          },
        );
      },
      itemCount: 3,
    );
  }

  Widget methodDropdown(AutoIndexRule rule) {
    List<String> method = [
      S.of(context).index_all,
      S.of(context).keyword_match,
      S.of(context).regex_match,
    ];
    int? init;
    switch (rule.autoIndexMethod) {
      case AutoIndexMethod.regex:
        init = 2;
        break;
      case AutoIndexMethod.keyword:
        init = 1;
        break;
      case AutoIndexMethod.always:
        init = 0;
        break;
    }
    return StdDropDown(
      initialIndex: init,
      color: theme.thirdGradeColor,
      width: 200,
      height: 45,
      onChanged: (index) {
        switch (index) {
          case 0:
            rule.autoIndexMethod = AutoIndexMethod.always;
            break;
          case 1:
            rule.autoIndexMethod = AutoIndexMethod.keyword;
            break;
          case 2:
            rule.autoIndexMethod = AutoIndexMethod.regex;
            break;
        }
        validate(rule);
        setState(() {});
      },
      itemBuilder: (context, index, onTap) {
        return StdListTile(
          title: Text(method[index]),
          onTap: () {
            onTap(index);
          },
        );
      },
      itemCount: 3,
    );
  }
}
