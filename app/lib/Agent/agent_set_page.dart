import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart'
    show MDEditor, MDEditorController;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:uni_chat/Chat/chat_models.dart';
import 'package:uni_chat/api_configs/api_database.dart';
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/database/database_service.dart';
import 'package:uni_chat/l10n/generated/l10n.dart';
import 'package:uni_chat/utils/file_utils.dart';
import 'package:uni_chat/utils/layout_widget.dart';
import 'package:uni_chat/utils/overlays.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:uni_chat/utils/tokenizer.dart';
import 'package:uni_chat/utils/uni_theme.dart';
import 'package:uuid/uuid.dart';

import 'agentProvider.dart';
import 'agent_models.dart';
import 'model_select.dart';

/// @param onSaveReturn 这个是在保存的时候调用的
/// @param onBack 这个在取消的时候调用，如果保留空的话就不会有取消按钮（也就是给初始页面用的）
class AgentSetPage extends ConsumerStatefulWidget {
  const AgentSetPage({
    super.key,
    required this.onSaveReturn,
    this.onBack,
    this.session,
    this.baseAgentData,
  });
  final dynamic onSaveReturn;
  final void Function()? onBack;
  final ChatSession? session;
  final AgentData? baseAgentData;

  @override
  ConsumerState<AgentSetPage> createState() => _AgentSetPageState();
}

class _AgentSetPageState extends ConsumerState<AgentSetPage> {
  late SplitViewController spc;
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  PropertyEditing? get editing => editingNotifier.value;
  ValueNotifier<PropertyEditing?> editingNotifier = ValueNotifier(null);

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
              color: (editing == PropertyEditing.model)
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
  late UniThemeData theme;
  @override
  void initState() {
    super.initState();
    spc = SplitViewController(
      onPop: () {
        if (editing != null) {
          editingNotifier.value = null;
        }
      },
    );
    agentState = ref.read(agentEditState);
    // theme = ref.read(themeProvider);
    if (agentState.name != null) {
      nameController.text = agentState.name!;
    }
    if (agentState.description != null) {
      descriptionController.text = agentState.description!;
    }
    editingNotifier.addListener(() {
      if (mounted) {
        if (editing == null) {
          spc.pop();
        } else {
          spc.push(
            Material(
              color: theme.secondGradeColor,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _pg(editing!),
              ),
            ),
            topBar: _topBar(),
          );
        }
      }
    });
  }

  Widget _pg(PropertyEditing pe) {
    switch (pe) {
      case PropertyEditing.model:
        return _AgentModelSettings();
      case PropertyEditing.sysPrompt:
        return _SysPromptEdit();
      case PropertyEditing.opening:
        return Opening();
      //return MemoryBase();
      case PropertyEditing.USRIdentity:
        return UserIdentity();
    }
  }

  Widget _topBar() {
    return ValueListenableBuilder(
      valueListenable: editingNotifier,
      builder: (context, value, child) {
        Widget title;
        switch (value) {
          case null:
            title = const SizedBox();
          case PropertyEditing.sysPrompt:
            title =
                (agentState.systemPrompt != null &&
                    agentState.systemPrompt!.isNotEmpty)
                ? (Text(
                    "${LLMTokenEstimator.estimateTokens(agentState.systemPrompt!)}tokens",
                    style: TextStyle(
                      fontSize: 12,
                      color: (editing == PropertyEditing.sysPrompt)
                          ? theme.zeroGradeColor
                          : theme.primaryColor,
                    ),
                  ))
                : const SizedBox();
          case PropertyEditing.model:
            title = _buildModelSelectIndicator() ?? const SizedBox();
          case PropertyEditing.USRIdentity:
            title = const SizedBox();
          case PropertyEditing.opening:
            title = const SizedBox();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: AppBar(
            primary: false,
            scrolledUnderElevation: 0,
            title: DefaultTextStyle(
              style: TextStyle(fontSize: 15, color: theme.brightTextColor),
              child: title,
            ),
            backgroundColor: theme.secondGradeColor,
            leading: StdIconButton(
              icon: Icons.arrow_back_ios_sharp,
              onPressed: () {
                spc.pop();
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    theme = UniTheme.of(context);
    agentState = ref.watch(agentEditState);
    spc.defaultRight = _SysPromptEdit();
    return KeyboardDismisser(
      child: Material(
        color: theme.secondGradeColor,
        child: SplitView(
          onLayout: (p, c, f) {
            if (p == SplitViewStatus.collapsedWithLeft &&
                c == SplitViewStatus.expanded) {
              editingNotifier.value = PropertyEditing.sysPrompt;
            }
            if (f && c == SplitViewStatus.expanded) {
              editingNotifier.value = PropertyEditing.sysPrompt;
            }
          },
          key: ValueKey("ageSV"),
          controller: spc,
          leftPercent: 0.375,
          left: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: buildSidebar(context),
          ),
        ),
      ),
    );
  }

  Widget buildSidebar(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: SizedBox(
                  height: 90,
                  child: (widget.session != null)
                      ? Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withAlpha(50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  S.of(context).agent_override_editing_hint,
                                  style: TextStyle(color: theme.primaryColor),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Row(
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
                                          ? TextStyle(
                                              fontSize: 20,
                                              color: Colors.red,
                                            )
                                          : null,
                                    ),
                                    onChanged: (value) {
                                      var n = ref.read(agentEditState.notifier);
                                      n.state = n.state.copyWith(name: value);
                                    },
                                  ),
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
                                      n.state = n.state.copyWith(
                                        description: value,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              TokenStats(),
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
                  child: ValueListenableBuilder(
                    valueListenable: editingNotifier,
                    builder: (context, editing, child) {
                      return ListView(
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
                            isSelected: editing == PropertyEditing.model,
                            onTap: () {
                              editingNotifier.value = PropertyEditing.model;
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
                                          (editing == PropertyEditing.sysPrompt)
                                          ? theme.zeroGradeColor
                                          : theme.primaryColor,
                                    ),
                                  ))
                                : null,
                            isSelected: editing == PropertyEditing.sysPrompt,
                            onTap: () {
                              editingNotifier.value = PropertyEditing.sysPrompt;
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
                            isSelected: editing == PropertyEditing.USRIdentity,
                            onTap: () {
                              editingNotifier.value =
                                  PropertyEditing.USRIdentity;
                            },
                          ),
                          const Divider(),
                          StdListTile(
                            title: Text(
                              S.of(context).opening_configure_title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            isSelected: editing == PropertyEditing.opening,
                            onTap: () {
                              editingNotifier.value = PropertyEditing.opening;
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
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
                  if (widget.onBack != null) const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButtons(
                      onSaveReturn: widget.onSaveReturn,
                      session: widget.session,
                      baseAgentData: widget.baseAgentData,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButtons extends ConsumerStatefulWidget {
  const _ActionButtons({
    required this.onSaveReturn,
    this.session,
    this.baseAgentData,
  });
  final dynamic onSaveReturn;
  final ChatSession? session;
  final AgentData? baseAgentData;
  @override
  ConsumerState<_ActionButtons> createState() => __ActionButtonsState();
}

class __ActionButtonsState extends ConsumerState<_ActionButtons>
    with SingleTickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var agentState = ref.watch(agentEditState);
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
            if (widget.session != null && widget.baseAgentData != null) {
              // Override mode
              final config = agentState.toAgentData().toConfigureMap();
              final overrideJson = jsonEncode(config);

              await DatabaseService.instance.updateSessionOverride(
                widget.session!.id,
                overrideJson,
              );

              // Reload agent with override
              await ref
                  .read(agentProvider.notifier)
                  .loadAgentById(
                    widget.session!.agentId,
                    overrideJson: overrideJson,
                    forceReload: true,
                  );
            } else {
              // Standard mode
              await DatabaseService.instance.createOrUpdateAgent(
                agentState.toAgentData(),
              );
              //此处强制刷新
              await ref
                  .read(agentProvider.notifier)
                  .loadAgentById(agentState.id, forceReload: true);
            }

            ref.read(agentEditState.notifier).state = AgentEditState();
            widget.onSaveReturn();
          } else {
            _controller.forward(from: 0);
          }
        },
      ),
    );
  }
}

enum PropertyEditing { sysPrompt, model, USRIdentity, opening }

class AgentEditState {
  late final String id;
  final bool isValidateMode;
  final bool isTokenEnough;
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
  final PersonaConfigure userIdentity;
  final OpeningConfigure opening;

  AgentEditState({
    String? id,
    this.isTokenEnough = true,
    this.isValidateMode = false,
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
    this.userIdentity = const PersonaConfigure(),
    this.opening = const OpeningConfigure(),
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
    PersonaConfigure? userIdentity,
    OpeningConfigure? opening,
  }) {
    return AgentEditState(
      id: id ?? this.id,
      isTokenEnough: isTokenEnough ?? this.isTokenEnough,
      isValidateMode: isValidateMode ?? this.isValidateMode,
      modelSettings: modelSettings ?? this.modelSettings,
      enableUIQL: enableUIQL ?? this.enableUIQL,
      provider: provider ?? this.provider,
      model: model ?? this.model,
      name: name ?? this.name,
      description: description ?? this.description,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      configure: configure ?? this.configure,
      knowledgeBases: knowledgeBases ?? this.knowledgeBases,
      createdAt: createdAt ?? this.createdAt,
      autoCreateMDB: autoCreateMDB ?? this.autoCreateMDB,
      userIdentity: userIdentity ?? this.userIdentity,
      opening: opening ?? this.opening,
    );
  }

  bool valid() {
    return name != null && isTokenEnough && provider != null && model != null;
  }

  ModelConfigure _toModelConfigure() {
    return ModelConfigure(
      modelId: model!.id,
      providerId: provider!.id,
      maxContextTokens: modelSettings.maxContextTokens,
      maxGenerationTokens: modelSettings.maxGenerationTokens,
      customParameters: modelSettings.customParameters,
      thinkingMode: modelSettings.thinkingMode,
      enableTimeTelling: modelSettings.enableTimeTelling,
      enableUsrLanguage: modelSettings.enableUsrLanguage,
      enableUsrSystemInformation: modelSettings.enableUsrSystemInformation,
    );
  }

  AgentData toAgentData() {
    return AgentData(
      version: 1,
      id: id,
      name: name!,
      description: description,
      modelConfigure: _toModelConfigure(),
      userIdentityConfigure: userIdentity,
      openingConfigure: opening,
      systemPrompt: systemPrompt,
      knowledgeBases: knowledgeBases.toList(),
      createdAt: createdAt,
    );
  }

  static Future<AgentEditState> fromAgentData(AgentData agentData) async {
    var pv = await ApiDatabase.instance.getProviderById(
      agentData.modelConfigure.providerId,
    );
    var m = await ApiDatabase.instance.getModelById(
      agentData.modelConfigure.modelId,
    );
    return AgentEditState(
      id: agentData.id,
      name: agentData.name,
      provider: pv,
      model: m,
      modelSettings: ModelSpecifics(
        maxContextTokens: agentData.modelConfigure.maxContextTokens,
        maxGenerationTokens: agentData.modelConfigure.maxGenerationTokens,
        customParameters: agentData.modelConfigure.customParameters,
        thinkingMode: agentData.modelConfigure.thinkingMode,
        enableTimeTelling: agentData.modelConfigure.enableTimeTelling,
        enableUsrLanguage: agentData.modelConfigure.enableUsrLanguage,
        enableUsrSystemInformation:
            agentData.modelConfigure.enableUsrSystemInformation,
      ),
      description: agentData.description,
      systemPrompt: agentData.systemPrompt,
      createdAt: agentData.createdAt,
      opening: agentData.openingConfigure ?? const OpeningConfigure(),
      userIdentity: agentData.userIdentityConfigure ?? const PersonaConfigure(),
    );
  }
}

final agentEditState = StateProvider((ref) => AgentEditState());

class TokenStats extends ConsumerStatefulWidget {
  const TokenStats({super.key});

  @override
  ConsumerState<TokenStats> createState() => _TokenStatsState();
}

class _TokenStatsState extends ConsumerState<TokenStats> {
  late UniThemeData theme;

  @override
  void initState() {
    super.initState();
    // theme = ref.read(themeProvider);
  }

  late List<(double, int)> percentages;
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
    var left = total - interSysPrompt - sysPrompt;
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
      (left / (total - left) * 360, left),
    ];
  }

  double width = 465;

  @override
  Widget build(BuildContext context) {
    theme = UniTheme.of(context);
    var state = ref.watch(agentEditState);
    calcPercentage(state, ref);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          (percentages[3].$2 == 0)
              ? Text(
                  S.of(context).enlarge_context_or_simplify_prompt,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Text(
                  S.of(context).token_available_for_chat(percentages[3].$2),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
          const SizedBox(height: 2),
          Text(
            S.of(context).total_context_lim(percentages[0].$2),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildLine(),
          const SizedBox(height: 8),
          _buildLegend(context),
        ],
      ),
    );
  }

  Expanded _buildLineItem(String title, int value, Color color) {
    return Expanded(
      flex: value,
      child: Container(color: color),
    );
  }

  Widget _buildLine() {
    return Container(
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.zeroGradeColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          _buildLineItem("", percentages[1].$2, theme.errorColor),
          const SizedBox(width: 3),
          _buildLineItem("", percentages[2].$2, theme.warningColor),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      children: [
        _buildLegendItem(
          theme.errorColor,
          S.of(context).system_internal_prompt(percentages[1].$2),
        ),
        _buildLegendItem(
          theme.warningColor,
          S.of(context).system_prompt_tokens(percentages[2].$2),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 12, height: 12, child: ColoredBox(color: color)),
          const SizedBox(width: 4),
          Text(text),
        ],
      ),
    );
  }
}

class _AgentModelSettings extends ConsumerStatefulWidget {
  const _AgentModelSettings();
  @override
  ConsumerState<_AgentModelSettings> createState() =>
      _AgentModelSettingsState();
}

class _AgentModelSettingsState extends ConsumerState<_AgentModelSettings> {
  void _notifyListeners() {
    var n = ref.read(agentEditState.notifier);
    n.state = n.state.copyWith(modelSettings: n.state.modelSettings.copyWith());
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
    var theme = UniTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          S.of(context).model_sets,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                            ms.maxContextTokens = m.contextLength ?? 1000000000;
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
                                ms.maxContextTokens =
                                    m.contextLength ?? 1000000000;
                                ms.maxGenerationTokens =
                                    m.maxCompletionTokens ?? -1;
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
                max: (edit.model?.contextLength ?? 1000000000).toDouble(),
              ),
              StdCheckbox(
                text: S.of(context).limit_model_generate_length,
                value: modelConf.maxGenerationTokens != -1,
                onChanged: (val) {
                  if (val == null) return;
                  if (val) {
                    modelConf.maxGenerationTokens =
                        edit.model?.maxCompletionTokens ?? 1024;
                  } else {
                    modelConf.maxGenerationTokens = -1;
                  }
                  _notifyListeners();
                },
              ),
              if (modelConf.maxGenerationTokens != -1)
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
                  max: (edit.model?.maxCompletionTokens ?? 1145141919)
                      .toDouble(),
                ),
              if (edit.model != null &&
                  edit.model!.abilities.contains(ModelAbility.thinking)) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      "${ModelParamName.thinking.friendlyName(context)}: ",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StdDropDown(
                      height: 50,
                      width: 150,
                      initialIndex: ThinkingMode.values.indexOf(
                        modelConf.thinkingMode,
                      ),
                      itemCount: ThinkingMode.values.length,
                      itemBuilder: (context, index, onTap) {
                        String label = ThinkingMode.values[index].friendlyName(
                          context,
                        );
                        return StdListTile(
                          title: Text(label),
                          onTap: () => onTap(index),
                        );
                      },
                      onChanged: (index) {
                        modelConf.thinkingMode = ThinkingMode.values[index];
                        _notifyListeners();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
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
              const SizedBox(height: 8),
              if (edit.model != null && edit.model!.parameters != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).model_advance_properties,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    StdButton(
                      text: S.of(context).select_parameter,
                      onPressed: () {
                        final availableParams = edit.model!.parameters!
                            .where(
                              (p) => !modelConf.customParameters.containsKey(p),
                            )
                            .toList();

                        if (availableParams.isEmpty) return;

                        OverlayPortalService.showDialog(
                          width: 400,
                          height: 600,
                          context,
                          backGroundColor: theme.zeroGradeColor,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.of(context).select_parameter,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: ListView.builder(
                                  itemBuilder: (context, index) {
                                    var param = availableParams[index];
                                    return ListTile(
                                      title: Text(param.friendlyName(context)),
                                      subtitle: Text(param.apiName),
                                      onTap: () {
                                        modelConf.customParameters[param] =
                                            param.initialValue;
                                        OverlayPortalService.hide(context);
                                        _notifyListeners();
                                      },
                                    );
                                  },
                                  itemCount: availableParams.length,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                ...modelConf.customParameters.entries.map((entry) {
                  final param = entry.key;
                  final value = entry.value;

                  Widget input;
                  if (param.uiType == ParamUIType.doubleSlider ||
                      param.uiType == ParamUIType.intSlider) {
                    input = Expanded(
                      child: StdSlider(
                        label: param.friendlyName(context),
                        value: (value as num).toDouble(),
                        toInt: param.uiType == ParamUIType.intSlider,
                        min: param.min,
                        max: param.max,
                        onChanged: (val) {
                          modelConf.customParameters[param] =
                              param.uiType == ParamUIType.intSlider
                              ? val.toInt()
                              : val;
                          _notifyListeners();
                        },
                      ),
                    );
                  } else if (param.uiType == ParamUIType.boolean) {
                    input = Expanded(
                      child: StdCheckbox(
                        text: param.friendlyName(context),
                        value: value as bool,
                        onChanged: (val) {
                          if (val != null) {
                            modelConf.customParameters[param] = val;
                            _notifyListeners();
                          }
                        },
                      ),
                    );
                  } else if (param.uiType == ParamUIType.stringList) {
                    final List<String> options;
                    if (param == ModelParamName.thinking) {
                      options = ThinkingMode.values.map((e) => e.name).toList();
                    } else if (param == ModelParamName.reasoningEffort) {
                      options = ['low', 'medium', 'high'];
                    } else {
                      options = [value.toString()];
                    }

                    input = Expanded(
                      child: Row(
                        children: [
                          Text("${param.friendlyName(context)}: "),
                          const SizedBox(width: 8),
                          StdDropDown(
                            width: 150,
                            initialIndex: options.indexOf(value.toString()),
                            itemCount: options.length,
                            itemBuilder: (context, index, onTap) {
                              String label = options[index];
                              if (param == ModelParamName.thinking) {
                                label = ThinkingMode.values[index].friendlyName(
                                  context,
                                );
                              }
                              return StdListTile(
                                title: Text(label),
                                onTap: () => onTap(index),
                              );
                            },
                            onChanged: (index) {
                              modelConf.customParameters[param] =
                                  options[index];
                              _notifyListeners();
                            },
                          ),
                        ],
                      ),
                    );
                  } else {
                    input = Expanded(
                      child: Text(
                        "${param.friendlyName(context)}: ${value.toString()}",
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        input,
                        const SizedBox(width: 8),
                        StdIconButton(
                          icon: Icons.delete_outline,
                          color: Colors.redAccent,
                          onPressed: () {
                            modelConf.customParameters.remove(param);
                            _notifyListeners();
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SysPromptEdit extends ConsumerStatefulWidget {
  const _SysPromptEdit();

  @override
  ConsumerState<_SysPromptEdit> createState() => _SysPromptEditState();
}

class _SysPromptEditState extends ConsumerState<_SysPromptEdit> {
  late MDEditorController mdController;
  ValueNotifier<int> charCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    // 初始化时设置当前字符数
    final currentState = ref.read(agentEditState);
    mdController = MDEditorController(
      initialText: currentState.systemPrompt,
      onInput: (text) {
        ref
            .read(agentEditState.notifier)
            .update((state) => state.copyWith(systemPrompt: text));
        charCount.value = LLMTokenEstimator.estimateTokens(text);
      },
    );
    // 初始化字数
    charCount.value = LLMTokenEstimator.estimateTokens(
      currentState.systemPrompt ?? "",
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = UniTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            S.of(context).sys_prompt,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.primaryColor, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: MDEditor(
                backgroundColor: theme.zeroGradeColor,
                frontGroundColor: theme.primaryColor,
                controller: mdController,
                hintText: S.of(context).enter_sys_prompt_here,
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: charCount,
            builder: (context, value, child) {
              return Text(
                "$value Tokens",
                style: TextStyle(color: theme.darkTextColor, fontSize: 16),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
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
  late TextEditingController sloganController;
  late MDEditorController firstMessageController;

  @override
  void initState() {
    super.initState();
    final currentState = ref.read(agentEditState);
    sloganController = TextEditingController(text: currentState.opening.slogan);
    firstMessageController = MDEditorController(
      initialText: currentState.opening.firstMessage,
      onInput: (value) {
        var n = ref.read(agentEditState.notifier);
        n.state = n.state.copyWith(
          opening: n.state.opening.copyWith(firstMessage: value),
        );
      },
    );
  }

  @override
  void dispose() {
    sloganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                S.of(context).opening_configure_title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                S.of(context).opening_slogan_label,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: S.of(context).opening_slogan_hint,
                child: const Icon(Icons.info_outline, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StdTextFieldOutlined(
            hintText: S.of(context).opening_slogan_label,
            controller: sloganController,
            onSubmitted: (value) {
              var n = ref.read(agentEditState.notifier);
              n.state = n.state.copyWith(
                opening: n.state.opening.copyWith(slogan: value),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                S.of(context).opening_message_label,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: S.of(context).opening_message_hint,
                child: const Icon(Icons.info_outline, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: UniTheme.of(context).primaryColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: MDEditor(
                backgroundColor: UniTheme.of(context).zeroGradeColor,
                frontGroundColor: UniTheme.of(context).primaryColor,
                controller: firstMessageController,
                hintText:
                    S.of(context).plz_enter +
                    S.of(context).opening_message_label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserIdentity extends ConsumerStatefulWidget {
  const UserIdentity({super.key});

  @override
  ConsumerState<UserIdentity> createState() => _UserIdentityState();
}

class _UserIdentityState extends ConsumerState<UserIdentity> {
  late MDEditorController additionalInfoController;

  @override
  void initState() {
    super.initState();
    final currentState = ref.read(agentEditState);
    additionalInfoController = MDEditorController(
      initialText: currentState.userIdentity.personaAdditionalInfo,
      onInput: (value) {
        var n = ref.read(agentEditState.notifier);
        n.state = n.state.copyWith(
          userIdentity: n.state.userIdentity.copyWith(
            personaAdditionalInfo: value,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var uiden = ref.watch(agentEditState.select((s) => s.userIdentity));
    var theme = UniTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                S.of(context).usr_persona_set,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              IconButton(icon: Icon(Icons.info_outline), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).select_agent_default_persona,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          StdButton(
            onPressed: () {
              OverlayPortalService.showDialog(
                context,
                height: 600,
                width: 400,
                child: personaSelector(context),
                backGroundColor: theme.zeroGradeColor,
              );
            },
            text: S.of(context).select_agent_default_persona,
            child: (uiden.defaultPersona == null)
                ? null
                : FutureBuilder(
                    future: () async {
                      var p = await DatabaseService.instance.getPersonaById(
                        uiden.defaultPersona!,
                      );
                      if (p == null) {
                        return null;
                      } else {
                        return (p, await p.getAvatar());
                      }
                    }.call(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StdAvatar(file: snapshot.data!.$2),
                            const SizedBox(width: 8),
                            Text(" ${snapshot.data!.$1.name}"),
                          ],
                        );
                      } else {
                        return Text(
                          S.of(context).error_occurred,
                          style: TextStyle(color: theme.errorColor),
                        );
                      }
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).persona_additonal_information,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.primaryColor, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: MDEditor(
                backgroundColor: theme.zeroGradeColor,
                frontGroundColor: theme.primaryColor,
                controller: additionalInfoController,
                hintText:
                    S.of(context).plz_enter +
                    S.of(context).persona_additonal_information.toLowerCase(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget personaSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).select_agent_default_persona,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        FutureBuilder(
          future: DatabaseService.instance.getAllPersonas(),
          builder: (context, asyncSnapshot) {
            if (!asyncSnapshot.hasData) {
              return SizedBox();
            }
            if (asyncSnapshot.hasError || asyncSnapshot.data == null) {
              return Center(child: Text(S.of(context).error_occurred));
            }
            if (asyncSnapshot.data!.isEmpty) {
              return Center(child: Text(S.of(context).no_persona));
            }
            return Expanded(
              child: ListView.builder(
                itemCount: asyncSnapshot.data!.length,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                    future: asyncSnapshot.data![index].getAvatar(),
                    builder: (context, avt) {
                      return StdListTile(
                        leading:
                            ((asyncSnapshot.hasError ||
                                asyncSnapshot.data == null))
                            ? null
                            : StdAvatar(file: avt.data),
                        title: Text(asyncSnapshot.data![index].name),
                        onTap: () async {
                          await OverlayPortalService.hide(context);
                          var n = ref.read(agentEditState.notifier);
                          n.state = n.state.copyWith(
                            userIdentity: PersonaConfigure(
                              defaultPersona: asyncSnapshot.data![index].id,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
