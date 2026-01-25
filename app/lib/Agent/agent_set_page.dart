import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/api_configs/api_database.dart';
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/main.dart';
import 'package:uni_chat/theme_manager.dart';
import 'package:uni_chat/utils/database_service.dart';
import 'package:uni_chat/utils/document_display.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:uni_chat/utils/tokenizer.dart';
import 'package:uuid/uuid.dart';

import '../generated/l10n.dart';
import '../utils/file_utils.dart';
import '../utils/llm_image_indexer.dart' show LLMImageIndexer;
import '../utils/overlays.dart';
import 'agentProvider.dart';

/// @param onSaveReturn 这个是在保存的时候调用的
/// @param onBack 这个在取消的时候调用，如果保留空的话就不会有取消按钮（也就是给初始页面用的）
class AgentSetPage extends StatelessWidget {
  const AgentSetPage({super.key, required this.onSaveReturn, this.onBack});
  final dynamic onSaveReturn;
  final void Function()? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 15),
        DocumentDisplay(),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AgentEditDetails(),
          ),
        ),
        Expanded(
          flex: 3,
          child: Expanded(
            child: AgentEditConfigure(
              onSaveReturn: onSaveReturn,
              onBack: onBack,
            ),
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
    return AgentData(
      version: 1,
      id: id,
      name: name!,
      description: description,
      providerId: provider!.id,
      modelId: model!.id,
      systemPrompt: systemPrompt,
      knowledgeBases: knowledgeBases.toList(),
      createdAt: createdAt,
      modelSpecifics: modelSettings,
    );
  }

  static Future<AgentEditState> fromAgentData(AgentData agentData) async {
    var pv = await ApiDatabase.instance.getProviderById(agentData.providerId);
    var m = await ApiDatabase.instance.getModelById(agentData.modelId);
    return AgentEditState(
      id: agentData.id,
      name: agentData.name,
      provider: pv,
      model: m,
      description: agentData.description,
      systemPrompt: agentData.systemPrompt,
      knowledgeBases: agentData.knowledgeBases.toSet(),
      createdAt: agentData.createdAt,
    );
  }
}

final agentEditState = StateProvider((ref) => AgentEditState());

class AgentEditConfigure extends ConsumerStatefulWidget {
  const AgentEditConfigure({
    super.key,
    required this.onSaveReturn,
    this.onBack,
  });
  final dynamic onSaveReturn;
  final void Function()? onBack;
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
                      onImageChanged: (s, setImage) async {
                        var f = await s.copyTo(
                          await PathProvider.getPath("chat/avatars"),
                          rename: agentState.id,
                          replaceIfExist: true,
                          createDirIfNotExist: true,
                        );
                        setImage(f.path);
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
                if (widget.onBack != null)
                  Expanded(
                    child: StdButton(
                      text: S.of(context).cancel_long_press,
                      color: theme.thirdGradeColor,
                      onPressed: () {},
                      onLongPress: () {
                        ref.read(agentEditState.notifier).state =
                            AgentEditState();
                        widget.onBack!();
                      },
                    ),
                  ),
                if (widget.onBack != null) const SizedBox(width: 20),
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
            widget.onSaveReturn();
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

  double width = 465;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var state = ref.watch(agentEditState);
    calcPercentage(state, ref);
    return LayoutBuilder(
      builder: (context, c) {
        width = c.maxWidth;
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
      },
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
                (width >= 465)
                    ? S.of(context).token_available_for_chat(percentages[6].$2)
                    : "${percentages[6].$2}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
        const SizedBox(height: 4),
        Text(
          (width >= 465)
              ? S.of(context).total_context_lim(percentages[0].$2)
              : "${percentages[0].$2}",
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
          //节约空间，否则在文档打开的时候必定溢出
          if (width >= 465) SizedBox(width: 10),
          if (width >= 465) Text(text),
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(documentDisplayProvider.notifier)
              .setUrl("$websiteURL/docs/Agents/model_settings");
        });
        return _AgentModelSettings();
      case PropertyEditing.sysPrompt:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(documentDisplayProvider.notifier)
              .setUrl("$websiteURL/docs/Agents/system_prompts");
        });
        return _SysPromptEdit();
      case PropertyEditing.opening:
        return Opening();
      case PropertyEditing.knowledgeBase:
        return SizedBox();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(documentDisplayProvider.notifier)
              .setUrl("$websiteURL/docs/Agents/knowledge_base");
        });
      //return MemoryBase();
      case PropertyEditing.UIQL:
        return Uiql();
      default:
        return SizedBox();
    }
  }
}

class _AgentModelSettings extends ConsumerStatefulWidget {
  const _AgentModelSettings({super.key});
  @override
  ConsumerState<_AgentModelSettings> createState() =>
      _AgentModelSettingsState();
}

class _AgentModelSettingsState extends ConsumerState<_AgentModelSettings> {
  void _notifyListeners() {
    var n = ref.read(agentEditState.notifier);
    n.state = n.state.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    var edit = ref.watch(
      agentEditState.select(
        (e) =>
            (model: e.model, settings: e.modelSettings, provider: e.provider),
      ),
    );
    var modelConf = edit.settings;
    var theme = ref.watch(themeProvider);
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
            ShowDocButton(),
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
              if (edit.model == null || edit.provider == null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: StdButton(
                    text: S.of(context).model_select,
                    onPressed: () {
                      OverlayPortalService.showDialog(
                        context,
                        height: 800,
                        width: 450,
                        child: ModelSelect(
                          theme: theme,
                          onSelect: (p, m) async {
                            var n = ref.read(agentEditState.notifier);
                            var ms = n.state.modelSettings;
                            ms.maxContextTokens = m.contextLength ?? 4096;
                            ms.maxGenerationTokens =
                                m.maxCompletionTokens ?? 1024;
                            n.state = n.state.copyWith(provider: p, model: m);
                            await OverlayPortalService.hide(context);
                          },
                        ),
                        backGroundColor: theme.zeroGradeColor,
                      );
                    },
                  ),
                ),
              if (edit.model != null && edit.provider != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      ModelSelect.buildPreview(
                        context,
                        30,
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        edit.provider!,
                        edit.model!,
                        () {
                          OverlayPortalService.showDialog(
                            context,
                            height: 800,
                            width: 450,
                            child: ModelSelect(
                              theme: theme,
                              onSelect: (p, m) async {
                                var n = ref.read(agentEditState.notifier);
                                var ms = n.state.modelSettings;
                                ms.maxContextTokens = m.contextLength ?? 4096;
                                ms.maxGenerationTokens =
                                    m.maxCompletionTokens ?? 1024;
                                n.state = n.state.copyWith(
                                  provider: p,
                                  model: m,
                                );
                                await OverlayPortalService.hide(context);
                              },
                            ),
                            backGroundColor: theme.zeroGradeColor,
                          );
                        },
                        theme,
                      ),
                    ],
                  ),
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
                max: (edit.model?.contextLength ?? 1145141919).toDouble(),
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
                max: (edit.model?.maxCompletionTokens ?? 1145141919).toDouble(),
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

class ModelSelect extends StatefulWidget {
  const ModelSelect({super.key, required this.theme, required this.onSelect});
  final ThemeConfig theme;
  final void Function(ApiProvider provider, Model model) onSelect;

  static Widget buildPreview(
    BuildContext context,
    double height,
    EdgeInsets padding,
    ApiProvider provider,
    Model model,
    VoidCallback? onTap,
    ThemeConfig theme,
  ) {
    var imgP = LLMImageIndexer.tryGetImagePath(model.family);
    return StdButton(
      onPressed: onTap,
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imgP != null)
            StdAvatar(length: height, assetImage: AssetImage(imgP)),
          const SizedBox(width: 10),
          Text(
            "${model.friendlyName} | ${provider.name}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  @override
  State<ModelSelect> createState() => _ModelSelectState();
}

class _ModelSelectState extends State<ModelSelect> {
  Widget buildSearchResult(Model model) {
    var imgP = LLMImageIndexer.tryGetImagePath(model.family);
    return StdListTile(
      onTap: () {
        if (_selectedModel != model) {
          setState(() {
            _selectedModel = model;
          });
        }
      },
      leading: (imgP != null)
          ? StdAvatar(length: 50, assetImage: AssetImage(imgP))
          : null,
      title: Text.rich(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        TextSpan(
          text: model.friendlyName,
          children: [
            TextSpan(
              text: "  ${model.family}",
              style: TextStyle(
                color: widget.theme.darkTextColor.withAlpha(150),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      subtitle: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: model.abilities.map((e) => getInfoTags(e)).toList(),
        ),
      ),
    );
  }

  Widget getInfoTags(ModelAbility ability) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      height: 25,
      decoration: BoxDecoration(
        color: widget.theme.primaryColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          ability.name(context),
          style: TextStyle(color: widget.theme.brightTextColor, fontSize: 12),
        ),
      ),
    );
  }

  Model? _selectedModel;
  List<ApiProvider> _providers = [];
  Widget selectProvider() {
    return Column(
      children: [
        buildSearchResult(_selectedModel!),
        const SizedBox(height: 8),
        Text(
          S.of(context).select_provider,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FutureBuilder(
            future: ApiDatabase.instance.getApiProviderByModelId(
              _selectedModel!.id,
            ),
            builder: (context, pv) {
              if (pv.hasData) {
                _providers = pv.data!;
                return ListView.builder(
                  itemBuilder: (context, e) => buildProvider(_providers[e]),
                  itemCount: _providers.length,
                );
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget buildProvider(ApiProvider provider) {
    var imgP = LLMImageIndexer.tryGetImagePath(provider.preset);
    return StdListTile(
      onTap: () {
        if (_selectedModel != null) {
          widget.onSelect(provider, _selectedModel!);
        }
      },
      leading: (imgP != null)
          ? StdAvatar(length: 40, assetImage: AssetImage(imgP))
          : null,
      title: Text(
        provider.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: widget.theme.bodyTextStyle,
      ),
    );
  }

  Widget search() {
    return FutureBuilder(
      future: (_showAll)
          ? ApiDatabase.instance.getAllModels()
          : ApiDatabase.instance.getAvailableModels(),
      builder: (context, model) {
        if (model.hasData) {
          _models = model.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StdSearch(
                  key: ValueKey(_models.length),
                  hintText: S.of(context).search_for_models,
                  isOutlined: true,
                  searchItems: _models.map((e) => e.friendlyName).toList(),
                  itemBuilder: (context, e) => buildSearchResult(_models[e]),
                  noResultPage: Center(
                    child: Text(
                      S.of(context).model_not_found,
                      style: TextStyle(
                        color: widget.theme.darkTextColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              StdButton(
                text: (_showAll) ? "显示可用模型" : "显示所有模型",
                onPressed: () {
                  setState(() {
                    _showAll = !_showAll;
                  });
                },
              ),
            ],
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  List<Model> _models = [];
  bool _showAll = false;
  @override
  Widget build(BuildContext context) {
    if (_selectedModel != null) {
      return selectProvider();
    }
    return search();
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
            ShowDocButton(),
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

/*
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
                  child: RagSettingPage(
                    onSaveReturn: _dismiss,
                    onBack: _dismiss,
                  ),
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
            ShowDocButton(),
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
        const SizedBox(height: 16),
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
                ref.read(ragEditState.notifier).changeState(id: Uuid().v7());
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
        ),*/
      ],
    );
  }
}
*/
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
