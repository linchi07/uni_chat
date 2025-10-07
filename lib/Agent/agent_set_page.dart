import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/RAG/rag_databases.dart';
import 'package:uni_chat/RAG/rag_settings.dart';
import 'package:uni_chat/llm_provider/pre_built_models.dart';
import 'package:uni_chat/theme_manager.dart';
import 'package:uni_chat/utils/api_database_service.dart';
import 'package:uni_chat/utils/database_service.dart';
import 'package:uni_chat/utils/llm_image_indexer.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:uni_chat/utils/tokenizer.dart';
import 'package:uuid/uuid.dart';

import '../generated/l10n.dart';
import '../utils/dialog.dart';
import '../utils/file_utils.dart';
import 'agentProvider.dart';

class AgentSetPage extends StatelessWidget {
  const AgentSetPage({super.key, required this.onBack});
  final dynamic onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 30),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AgentEditDetails(),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                S.of(context).agent_sets,
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(child: AgentEditConfigure(onBack: onBack)),
            ],
          ),
        ),
      ],
    );
  }
}

enum PropertyEditing {
  sysPrompt,
  model,
  knowledgeBase,
  UIQL,
  USRIdentity,
  opening,
  sysAndEnvironmentVars,
}

class AgentEditState {
  late final String id;
  final bool isValidateMode;
  final bool isTokenEnough;
  final PropertyEditing editing;
  final String? name;
  final String? description;
  ApiProvider? provider;
  final Model? model;
  late final ModelSpecifics modelSettings;
  final String? systemPrompt;
  final String? configure;
  late final Set<String> knowledgeBases;
  final bool enableUIQL;
  late final DateTime createdAt;
  bool autoCreateMDB;
  AgentEditState({
    String? id,
    this.isTokenEnough = true,
    this.isValidateMode = false,
    this.editing = PropertyEditing.sysPrompt,
    ModelSpecifics? modelSettings,
    this.name,
    this.provider,
    this.model,
    this.enableUIQL = true,
    this.description,
    this.systemPrompt,
    this.configure,
    Set<String>? knowledgeBases,
    DateTime? createdAt,
    this.autoCreateMDB = true,
  }) {
    this.knowledgeBases = knowledgeBases ?? <String>{};
    this.id = id ?? Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
    this.modelSettings = modelSettings ?? ModelSpecifics();
  }

  AgentEditState copyWith({
    String? id,
    bool? isTokenEnough,
    bool? isValidateMode,
    PropertyEditing? editing,
    String? name,
    String? description,
    String? systemPrompt,
    String? configure,
    Set<String>? knowledgeBases,
    DateTime? createdAt,
    ApiProvider? provider,
    Model? model,
    bool? enableUIQL,
    ModelSpecifics? modelSettings,
    bool? autoCreateMDB,
  }) {
    return AgentEditState(
      id: id ?? this.id,
      isTokenEnough: isTokenEnough ?? this.isTokenEnough,
      isValidateMode: isValidateMode ?? this.isValidateMode,
      modelSettings: modelSettings ?? this.modelSettings,
      enableUIQL: enableUIQL ?? this.enableUIQL,
      provider: provider ?? this.provider,
      model: model ?? this.model,
      editing: editing ?? this.editing,
      name: name ?? this.name,
      description: description ?? this.description,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      configure: configure ?? this.configure,
      knowledgeBases: knowledgeBases ?? this.knowledgeBases,
      createdAt: createdAt ?? this.createdAt,
      autoCreateMDB: autoCreateMDB ?? this.autoCreateMDB,
    );
  }

  bool valid() {
    return name != null && isTokenEnough && provider != null && model != null;
  }

  Future<AgentData> toAgentData() async {
    var modelConfig = await ApiDatabaseService.instance
        .getProviderModelConfigsForModelWithProvider(model!.id, provider!.id);
    if (modelConfig.firstOrNull == null) {
      //TODO: handle this
      throw Exception("模型配置不存在");
    }
    return AgentData(
      id: id,
      name: name!,
      description: description,
      modelProviderConfigureId: modelConfig.first.id,
      systemPrompt: systemPrompt,
      knowledgeBases: knowledgeBases.toList(),
      createdAt: createdAt,
      modelSpecifics: modelSettings,
    );
  }

  factory AgentEditState.fromAgentData(
    AgentData agentData,
    ApiProvider? provider,
    Model? model,
  ) {
    return AgentEditState(
      id: agentData.id,
      name: agentData.name,
      provider: provider,
      model: model,
      description: agentData.description,
      systemPrompt: agentData.systemPrompt,
      knowledgeBases: agentData.knowledgeBases.toSet(),
      createdAt: agentData.createdAt,
    );
  }
}

final agentEditState = StateProvider((ref) => AgentEditState());

class AgentEditConfigure extends ConsumerStatefulWidget {
  const AgentEditConfigure({super.key, required this.onBack});
  final dynamic onBack;
  @override
  ConsumerState<AgentEditConfigure> createState() => _AgentEditConfigureState();
}

class _AgentEditConfigureState extends ConsumerState<AgentEditConfigure>
    with SingleTickerProviderStateMixin {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  void _onPropertySelect(PropertyEditing propertyEdit) {
    var n = ref.read(agentEditState.notifier);
    n.state = n.state.copyWith(editing: propertyEdit);
  }

  Widget? _buildModelSelectIndicator() {
    if (agentState.isValidateMode &&
        (agentState.model == null || agentState.provider == null)) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: theme.thirdGradeColor,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Text(
          (agentState.model == null)
              ? S.of(context).model_select
              : S.of(context).plz_select_provider,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
      );
    }
    return (agentState.model != null && agentState.provider != null)
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: (agentState.editing == PropertyEditing.model)
                  ? theme.zeroGradeColor
                  : theme.thirdGradeColor,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Text(
              agentState.model!.friendlyName,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
          )
        : null;
  }

  late AgentEditState agentState;
  late ThemeConfig theme;
  @override
  Widget build(BuildContext context) {
    agentState = ref.watch(agentEditState);
    theme = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: SizedBox(
              height: 80,
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.zeroGradeColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(60),
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: StdAvatarPicker(
                      initialWidget: Center(
                        child: Text(
                          S.of(context).select_image_hint,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      onImageChanged: (s, e, setImage) async {
                        final sessionFilesDir = Directory(
                          await PathProvider.getPath("chat/avatars"),
                        );
                        if (!await sessionFilesDir.exists()) {
                          await sessionFilesDir.create(recursive: true);
                        }
                        final file = File(
                          await PathProvider.getPath(
                            "chat/avatars/${agentState.id}.$e",
                          ),
                        );
                        final sink = file.openWrite();
                        await s.forEach(sink.add);
                        await sink.close();
                        setImage(file.path);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          controller: nameController,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: S.of(context).agent_name_hint,
                            border: InputBorder.none,
                            hintStyle:
                                (agentState.name == null &&
                                    agentState.isValidateMode)
                                ? TextStyle(fontSize: 20, color: Colors.red)
                                : null,
                          ),
                          onChanged: (value) {
                            var n = ref.read(agentEditState.notifier);
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
                            hintText: S.of(context).agent_desc_hint,
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            var n = ref.read(agentEditState.notifier);
                            n.state = n.state.copyWith(description: value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 180, child: EditPageTokenUsageStatistics()),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              S.of(context).agent_sets,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              clipBehavior: Clip.hardEdge,
              child: ListView(
                children: [
                  StdListTile(
                    title: Text(
                      S.of(context).model_sets,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    trailing: _buildModelSelectIndicator(),
                    isSelected: agentState.editing == PropertyEditing.model,
                    onTap: () {
                      _onPropertySelect(PropertyEditing.model);
                    },
                  ),
                  const Divider(),
                  StdListTile(
                    title: Text(
                      S.of(context).sys_prompt,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    trailing:
                        (agentState.systemPrompt != null &&
                            agentState.systemPrompt!.isNotEmpty)
                        ? (Text(
                            "${LLMTokenEstimator.estimateTokens(agentState.systemPrompt!)}tokens",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  (agentState.editing ==
                                      PropertyEditing.sysPrompt)
                                  ? theme.zeroGradeColor
                                  : theme.primaryColor,
                            ),
                          ))
                        : null,
                    isSelected: agentState.editing == PropertyEditing.sysPrompt,
                    onTap: () {
                      _onPropertySelect(PropertyEditing.sysPrompt);
                    },
                  ),
                  const Divider(),
                  StdListTile(
                    title: Text(
                      S.of(context).knowledge_base_and_contexts,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    isSelected:
                        agentState.editing == PropertyEditing.knowledgeBase,
                    onTap: () {
                      _onPropertySelect(PropertyEditing.knowledgeBase);
                    },
                  ),
                  const Divider(),
                  StdListTile(
                    title: Text(
                      S.of(context).ui_interaction_set,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    trailing: (Text(
                      (agentState.enableUIQL)
                          ? S.of(context).enable
                          : S.of(context).disable,
                      style: TextStyle(
                        fontSize: 12,
                        color: (agentState.editing == PropertyEditing.UIQL)
                            ? theme.zeroGradeColor
                            : theme.primaryColor,
                      ),
                    )),
                    isSelected: agentState.editing == PropertyEditing.UIQL,
                    onTap: () {
                      _onPropertySelect(PropertyEditing.UIQL);
                    },
                  ),
                  const Divider(),
                  StdListTile(
                    title: Text(
                      S.of(context).usr_persona_set,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    isSelected:
                        agentState.editing == PropertyEditing.USRIdentity,
                    onTap: () {
                      _onPropertySelect(PropertyEditing.USRIdentity);
                    },
                  ),
                  const Divider(),
                  StdListTile(
                    title: Text(
                      S.of(context).opening_set,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    trailing:
                        (agentState.systemPrompt != null &&
                            agentState.systemPrompt!.isNotEmpty)
                        ? (Text(
                            "${agentState.systemPrompt!.length}tokens",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  (agentState.editing ==
                                      PropertyEditing.sysPrompt)
                                  ? theme.zeroGradeColor
                                  : theme.primaryColor,
                            ),
                          ))
                        : null,
                    isSelected: agentState.editing == PropertyEditing.opening,
                    onTap: () {
                      _onPropertySelect(PropertyEditing.opening);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: StdButton(
                    text: S.of(context).cancel_long_press,
                    color: theme.thirdGradeColor,
                    onPressed: () {},
                    onLongPress: () {
                      ref.read(agentEditState.notifier).state =
                          AgentEditState();
                      widget.onBack();
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(child: _buildSaveButton()),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
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
    agentState = ref.read(agentEditState);
    if (agentState.name != null) {
      nameController.text = agentState.name!;
    }
    if (agentState.description != null) {
      descriptionController.text = agentState.description!;
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
        text: (!agentState.isTokenEnough)
            ? S.of(context).model_context_not_enough
            : S.of(context).save,
        onPressed: () async {
          ref.read(agentEditState.notifier).state = agentState.copyWith(
            isValidateMode: true,
          );
          if (agentState.valid()) {
            await DatabaseService.instance.createOrUpdateAgent(
              await agentState.toAgentData(),
            );
            ref.read(agentEditState.notifier).state = AgentEditState();
            //此处强制刷新
            await ref
                .read(agentProvider.notifier)
                .loadAgentById(agentState.id, forceReload: true);
            widget.onBack();
          } else {
            _controller.forward(from: 0);
          }
        },
      ),
    );
  }
}

class EditPageTokenUsageStatistics extends ConsumerWidget {
  // ignore: prefer_const_constructors_in_immutables
  EditPageTokenUsageStatistics({super.key});
  static const double innerRadius = 15;
  late final List<(double, int)> percentages;
  void calcPercentage(AgentEditState state, WidgetRef ref) {
    var total = state.modelSettings.maxContextTokens;
    var interSysPrompt = 0;
    interSysPrompt = (state.modelSettings.enableUsrSystemInformation)
        ? interSysPrompt + 15
        : interSysPrompt;
    interSysPrompt = (state.modelSettings.enableUsrLanguage)
        ? interSysPrompt + 6
        : interSysPrompt;
    interSysPrompt = (state.modelSettings.enableTimeTelling)
        ? interSysPrompt + 10
        : interSysPrompt;
    var sysPrompt = (state.systemPrompt == null
        ? 0
        : LLMTokenEstimator.estimateTokens(state.systemPrompt!));
    var uIQL = (state.enableUIQL ? 1000 : 0);
    var knowledgeBase = 1000;
    var opening = 1000;
    var left =
        total - interSysPrompt - sysPrompt - uIQL - knowledgeBase - opening;
    if (left < 0) {
      left = 0;
      if (state.isTokenEnough) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(agentEditState.notifier).state = state.copyWith(
            isTokenEnough: false,
          );
        });
      }
    }
    if (!state.isTokenEnough && left > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(agentEditState.notifier).state = state.copyWith(
          isTokenEnough: true,
        );
      });
    }
    percentages = [
      (0, total),
      (interSysPrompt / (total - left) * 360, interSysPrompt),
      (sysPrompt / (total - left) * 360, sysPrompt),
      (knowledgeBase / (total - left) * 360, knowledgeBase),
      (opening / (total - left) * 360, opening),
      (uIQL / (total - left) * 360, uIQL),
      (left / (total - left) * 360, left),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var state = ref.watch(agentEditState);
    calcPercentage(state, ref);
    return Row(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sections: _getSections(context),
              centerSpaceRadius: 35,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // 处理触摸事件
                },
              ),
            ),
          ),
        ),
        _buildLegend(context),
      ],
    );
  }

  List<PieChartSectionData> _getSections(BuildContext context) {
    return [
      PieChartSectionData(
        color: Colors.deepOrange,
        value: percentages[1].$1,
        showTitle: false,
        title: "",
        radius: innerRadius,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.orangeAccent,
        value: percentages[2].$1,
        title: S.of(context).sys_prompt,
        showTitle: false,
        radius: innerRadius,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.indigoAccent,
        value: percentages[3].$1,
        title: S.of(context).knowledge_base,
        radius: innerRadius,
        showTitle: false,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: percentages[4].$1,
        title: S.of(context).opening,
        radius: innerRadius,
        showTitle: false,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: percentages[5].$1,
        title: S.of(context).ui_interactions,
        radius: innerRadius,
        showTitle: false,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildLegend(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (percentages[6].$2 == 0)
            ? Text(
                S.of(context).enlarge_context_or_simplify_prompt,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Text(
                S.of(context).token_available_for_chat(percentages[6].$2),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
        const SizedBox(height: 4),
        Text(
          S.of(context).total_context_lim(percentages[0].$2),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        _buildLegendItem(
          Colors.deepOrange,
          S.of(context).system_internal_prompt(percentages[1].$2),
        ),
        _buildLegendItem(
          Colors.orangeAccent,
          S.of(context).system_prompt_tokens(percentages[2].$2),
        ),
        _buildLegendItem(
          Colors.indigoAccent,
          S.of(context).knowledge_base_tokens(percentages[3].$2),
        ),
        _buildLegendItem(
          Colors.green,
          S.of(context).longest_opening(percentages[4].$2),
        ),
        _buildLegendItem(
          Colors.purple,
          S.of(context).ui_interactions_tokens(percentages[5].$2),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, color: color),
          SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}

class AgentEditDetails extends ConsumerWidget {
  const AgentEditDetails({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var agentSet = ref.watch(agentEditState);
    switch (agentSet.editing) {
      case PropertyEditing.model:
        return _AgentModelSettings(modelSpecifics: agentSet.modelSettings);
      case PropertyEditing.sysPrompt:
        return _SysPromptEdit();
      case PropertyEditing.opening:
        return Opening();
      case PropertyEditing.knowledgeBase:
        return MemoryBase();
      case PropertyEditing.UIQL:
        return Uiql();
      default:
        return SizedBox();
    }
  }
}

class _AgentModelSettings extends ConsumerStatefulWidget {
  const _AgentModelSettings({super.key, required this.modelSpecifics});
  final ModelSpecifics modelSpecifics;
  @override
  ConsumerState<_AgentModelSettings> createState() =>
      _AgentModelSettingsState();
}

class _AgentModelSettingsState extends ConsumerState<_AgentModelSettings> {
  ModelSpecifics get modelConf => widget.modelSpecifics;
  void _notifyListeners() {
    var n = ref.read(agentEditState.notifier);
    n.state = n.state.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              S.of(context).model_sets,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            IconButton(icon: Icon(Icons.info_outline), onPressed: () {}),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '更多知识请查看文档',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              Text(
                S.of(context).model_select,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(children: [ModelDropDown()]),
              ),
              Text(
                S.of(context).provider_select,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(children: [_ProviderDropDown()]),
              ),
              Text(
                S.of(context).model_property,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              StdSlider(
                label: S.of(context).model_maximum_context_length,
                value: modelConf.maxContextTokens.toDouble(),
                toInt: true,
                onChanged: (value) {
                  if (value.toInt() < modelConf.maxGenerationTokens) {
                    modelConf.maxGenerationTokens = value.toInt();
                  }
                  modelConf.maxContextTokens = value.toInt();
                  _notifyListeners();
                },
                min: 100,
                max: 1145141919,
              ),
              StdSlider(
                label: S.of(context).model_maximum_generate_length,
                value: modelConf.maxGenerationTokens.toDouble(),
                toInt: true,
                onChanged: (value) {
                  if (modelConf.maxContextTokens < value.toInt()) {
                    modelConf.maxContextTokens = value.toInt();
                  }
                  modelConf.maxGenerationTokens = value.toInt();
                  _notifyListeners();
                },
                min: 100,
                max: 1145141919,
              ),
              Text(
                S.of(context).model_basic_info_pass_through_setting,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              StdCheckbox(
                text: S.of(context).model_time_telling,
                value: modelConf.enableTimeTelling,
                onChanged: (val) {
                  if (val == null) return;
                  modelConf.enableTimeTelling = val;
                  _notifyListeners();
                },
              ),
              StdCheckbox(
                text: S.of(context).model_system_telling,
                value: modelConf.enableUsrSystemInformation,
                onChanged: (val) {
                  if (val == null) return;
                  modelConf.enableUsrSystemInformation = val;
                  _notifyListeners();
                },
              ),
              StdCheckbox(
                text: S.of(context).model_local_telling,
                value: modelConf.enableUsrLanguage,
                onChanged: (val) {
                  if (val == null) return;
                  modelConf.enableUsrLanguage = val;
                  _notifyListeners();
                },
              ),
              const SizedBox(height: 8),
              Text(
                S.of(context).model_advance_properties,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              StdSlider(
                label: S.of(context).temperature,
                value: modelConf.temperature,
                onChanged: (value) {
                  modelConf.temperature = value;
                  _notifyListeners();
                },
                min: 0,
                max: 2,
              ),
              StdSlider(
                label: S.of(context).freq_penalty,
                value: modelConf.frequencyPenalty,
                min: -2,
                max: 2,
                onChanged: (value) {
                  modelConf.frequencyPenalty = value;
                  _notifyListeners();
                },
              ),
              StdSlider(
                label: S.of(context).pres_penalty,
                value: modelConf.presencePenalty,
                min: -2,
                max: 2,
                onChanged: (value) {
                  modelConf.presencePenalty = value;
                  _notifyListeners();
                },
              ),
              StdSlider(
                label: S.of(context).top_p,
                value: modelConf.topP,
                min: 0,
                max: 1,
                onChanged: (value) {
                  modelConf.topP = value;
                  _notifyListeners();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ModelDropDown extends ConsumerStatefulWidget {
  const ModelDropDown({super.key});
  @override
  ConsumerState<ModelDropDown> createState() => _ModelDropDownState();
}

class _ModelDropDownState extends ConsumerState<ModelDropDown>
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
    selectedIndex = ref.read(agentEditState).model;
  }

  void onTap(Model model) {
    if (model == selectedIndex) return;
    setState(() {
      selectedIndex = model;
    });
    var n = ref.read(agentEditState.notifier);
    n.state.modelSettings.modelName = model.friendlyName;
    var n2 = n.state.copyWith(model: model);
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
      width: 350,
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
                        withAbilities: {ModelAbility.textGenerate},
                        exceptAbilities: {ModelAbility.embedding},
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
                              Center(child: Text(S.of(context).no_model)),
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
    selectedIndex = ref.read(agentEditState).provider;
  }

  void onTap(ApiProvider provider) {
    setState(() {
      selectedIndex = provider;
    });
    var n = ref.read(agentEditState.notifier);
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
    var as = ref.watch(agentEditState);
    if (as.model == null) {
      return SizedBox();
    }
    ref.listen(agentEditState, (previous, next) {
      if (previous != null &&
          previous.provider != null &&
          previous.model != next.model) {
        selectedIndex = null;
      }
    });
    return SizedBox(
      height: 40,
      width: 350,
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
                        as.model!.id,
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

class _SysPromptEdit extends ConsumerStatefulWidget {
  const _SysPromptEdit({super.key});

  @override
  ConsumerState<_SysPromptEdit> createState() => _SysPromptEditState();
}

class _SysPromptEditState extends ConsumerState<_SysPromptEdit> {
  late TextEditingController controller;
  int charCount = 0;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    // 初始化时设置当前字符数
    final currentState = ref.read(agentEditState);
    if (currentState.systemPrompt != null) {
      controller.text = currentState.systemPrompt!;
      charCount = currentState.systemPrompt!.length;
    }
  }

  void onSubmit(AgentEditState s) {
    //这里卡了一个bug，on Submitted似乎无法正常触发
    var value = controller.text;
    if (charCount > s.modelSettings.maxContextTokens) {
      value = value.substring(0, s.modelSettings.maxContextTokens);
    }
    var n = ref.read(agentEditState.notifier);
    n.state = n.state.copyWith(systemPrompt: value);
  }

  @override
  Widget build(BuildContext context) {
    var s = ref.watch(agentEditState);
    var theme = ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              S.of(context).sys_prompt,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            IconButton(icon: Icon(Icons.info_outline), onPressed: () {}),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '更多知识请查看文档',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text("关于占位符的使用,请查看文档"),
        const SizedBox(height: 16),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              fillColor: theme.primaryColor,
              focusColor: theme.primaryColor,
              hintText: S.of(context).enter_sys_prompt_here,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: (charCount <= s.modelSettings.maxContextTokens)
                      ? theme.primaryColor
                      : Colors.red,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: (charCount <= s.modelSettings.maxContextTokens)
                      ? theme.primaryColor
                      : Colors.red,
                  width: 2.5,
                ),
              ),
              border: const OutlineInputBorder(),
              // 添加计数器显示
              counterStyle: TextStyle(
                color: (charCount <= s.modelSettings.maxContextTokens)
                    ? theme.primaryColor
                    : Colors.red,
                fontSize: 15.0,
              ),
              counterText: (charCount <= s.modelSettings.maxContextTokens)
                  ? '$charCount/${s.modelSettings.maxContextTokens}'
                  : S
                        .of(context)
                        .over_maximum_context_length_hint(
                          charCount,
                          s.modelSettings.maxContextTokens,
                        ),
            ),
            // 监听文本变化更新计数
            onChanged: (value) {
              setState(() {
                charCount = LLMTokenEstimator.estimateTokens(value);
              });
              onSubmit(s);
            },
            expands: true,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class MemoryBase extends ConsumerStatefulWidget {
  const MemoryBase({super.key});

  @override
  ConsumerState<MemoryBase> createState() => _MemoryBaseState();
}

class _MemoryBaseState extends ConsumerState<MemoryBase> {
  Widget _autoCreateInfo() {
    return SizedBox();
  }

  OverlayEntry? _overlayEntry;
  void showMemoryBaseCreation() {
    final overlay = Overlay.of(context);
    var size = MediaQuery.of(context).size;
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        alignment: Alignment.center,
        children: [
          // 背景变暗
          ModalBarrier(color: Colors.black.withAlpha(80)),
          SizedBox(
            height: size.height * 0.9,
            width: size.width * 0.9,
            child: Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              color: theme.secondGradeColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: OverlayPortalScope(
                  child: RagSettingPage(onBack: _dismiss),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {});
  }

  late ThemeConfig theme;
  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);
    var as = ref.watch(agentEditState);
    var mdb = as.knowledgeBases;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              "记忆库设置",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            IconButton(icon: Icon(Icons.info_outline), onPressed: () {}),
          ],
        ),
        /*
        Container(
          padding: EdgeInsets.all(16),
          width: double.maxFinite,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text("自动创建Agent专属记忆库"),
              StdCheckbox(
                text: "是否启用",
                value: as.autoCreateMDB,
                onChanged: (value) {
                  ref.read(agentEditState).autoCreateMDB = value ?? false;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),*/
        Row(
          children: [
            Expanded(
              child: Text(
                "请选择与要与该Agent关联的记忆库",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            StdButton(
              text: "创建一个新记忆库",
              onPressed: () {
                showMemoryBaseCreation();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder(
            future: RAGDatabaseManager().getAllKnowledgeBases(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return StdListTile(
                        leading: StdCheckbox(
                          value: mdb.contains(item.id),
                          onChanged: (value) {
                            if (value ?? false) {
                              mdb.add(item.id);
                            } else {
                              mdb.remove(item.id);
                            }
                            setState(() {});
                          },
                        ),
                        title: Text(item.name),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class Opening extends ConsumerStatefulWidget {
  const Opening({super.key});

  @override
  ConsumerState<Opening> createState() => _OpeningState();
}

class _OpeningState extends ConsumerState<Opening> {
  late TextEditingController controller;
  int charCount = 0;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    // 初始化时设置当前字符数
    final currentState = ref.read(agentEditState);
    if (currentState.systemPrompt != null) {
      controller.text = currentState.systemPrompt!;
      charCount = LLMTokenEstimator.estimateTokens(currentState.systemPrompt!);
    }
  }

  void onSubmit(AgentEditState s) {
    //这里卡了一个bug，on Submitted似乎无法正常触发
    var value = controller.text;
    if (value.isEmpty) {
      return;
    }
    if (charCount > s.modelSettings.maxContextTokens) {
      value = value.substring(0, s.modelSettings.maxContextTokens);
    }
    var n = ref.read(agentEditState.notifier);
    n.state = n.state.copyWith(systemPrompt: value);
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    var s = ref.watch(agentEditState);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              S.of(context).opening_set,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            IconButton(icon: Icon(Icons.info_outline), onPressed: () {}),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '更多知识请查看文档',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text("关于占位符的使用,请查看文档"),
        const SizedBox(height: 16),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              fillColor: theme.primaryColor,
              focusColor: theme.primaryColor,
              hintText: S.of(context).enter_opening_here,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: (charCount <= s.modelSettings.maxContextTokens)
                      ? theme.primaryColor
                      : Colors.red,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: (charCount <= s.modelSettings.maxContextTokens)
                      ? theme.primaryColor
                      : Colors.red,
                  width: 2.5,
                ),
              ),
              border: const OutlineInputBorder(),
              // 添加计数器显示
              counterStyle: TextStyle(
                color: (charCount <= s.modelSettings.maxContextTokens)
                    ? theme.primaryColor
                    : Colors.red,
                fontSize: 15.0,
              ),
              counterText: (charCount <= s.modelSettings.maxContextTokens)
                  ? '$charCount/${s.modelSettings.maxContextTokens}'
                  : S
                        .of(context)
                        .over_maximum_context_length_hint(
                          charCount,
                          s.modelSettings.maxContextTokens,
                        ),
            ),
            // 监听文本变化更新计数
            onChanged: (value) {
              setState(() {
                charCount = LLMTokenEstimator.estimateTokens(controller.text);
              });
              onSubmit(s);
            },
            expands: true,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class Uiql extends ConsumerWidget {
  const Uiql({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var agent = ref.watch(agentEditState);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              S.of(context).ui_interaction_set,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            IconButton(icon: Icon(Icons.info_outline), onPressed: () {}),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '该功能是一个实验功能，目前正在完善，更多相关信息请查看文档 \n This is a experimental feature, more information please see the documentation ',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        StdCheckbox(
          value: agent.enableUIQL,
          onChanged: (value) {
            var n = ref.read(agentEditState.notifier);
            n.state = agent.copyWith(enableUIQL: value);
          },
          text: S.of(context).enable_ui_interactions,
        ),
      ],
    );
  }
}
