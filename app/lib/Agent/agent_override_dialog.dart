import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/Agent/agentProvider.dart';
import 'package:uni_chat/Agent/agent_models.dart';
import 'package:uni_chat/Agent/agent_set_page.dart';
import 'package:uni_chat/Agent/model_select.dart';
import 'package:uni_chat/Chat/chat_models.dart';
import 'package:uni_chat/database/database_service.dart';
import 'package:uni_chat/l10n/generated/l10n.dart';
import 'package:uni_chat/utils/uni_theme.dart';
import 'package:uni_chat/utils/overlays.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';

class AgentOverrideDialog extends ConsumerStatefulWidget {
  const AgentOverrideDialog({
    super.key,
    required this.session,
    required this.baseAgentData,
  });
  final ChatSession session;
  final AgentData baseAgentData;

  @override
  ConsumerState<AgentOverrideDialog> createState() =>
      _AgentOverrideDialogState();
}

class _AgentOverrideDialogState extends ConsumerState<AgentOverrideDialog> {
  bool _isLoading = true;

  late TextEditingController _systemPromptController;
  @override
  void initState() {
    super.initState();
    _initializeState();
    _systemPromptController = TextEditingController(
      text: widget.baseAgentData.systemPrompt,
    );
  }

  Future<void> _initializeState() async {
    // Current agent might already have overrides applied
    final currentAgent = ref.read(agentProvider);
    if (currentAgent != null) {
      final editState = await AgentEditState.fromAgentData(
        currentAgent.toAgentData(),
      );
      ref.read(agentEditState.notifier).state = editState;
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = UniTheme.of(context);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final editState = ref.watch(agentEditState);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).agent_override_title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            // Full Settings Button
            StdButton(
              onPressed: () async {
                await OverlayPortalService.hide(context);
                // Record initial state for diff calculation
                final initialState = ref.read(agentEditState).toAgentData();

                OverlayWrapper.showOverlay(
                  context,
                  barrierDismissible: false,
                  overlayContent: Builder(
                    builder: (context) {
                      return Container(
                        margin: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: theme.secondGradeColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AgentSetPage(
                          session: widget.session,
                          baseAgentData: widget.baseAgentData,
                          onSaveReturn: () {
                            OverlayWrapper.removeOverlay(context);
                          },
                          onBack: () {
                            OverlayWrapper.removeOverlay(context);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              color: theme.thirdGradeColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.settings, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    S.of(context).full_settings,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          S.of(context).model,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        OverlayPortalScope(
          child: Builder(
            builder: (context) {
              if (editState.model == null || editState.provider == null) {
                return StdButton(
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
                );
              }
              return Row(
                children: [
                  ModelSelect.buildPreview(
                    context,
                    30,
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    editState.provider!,
                    editState.model!,
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
                    theme,
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // System Prompt
        Text(
          S.of(context).sys_prompt,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        StdTextFieldOutlined(
          maxLines: 5,
          hintText: S.of(context).enter_sys_prompt_here,
          controller: _systemPromptController,
          onChanged: (val) {
            ref.read(agentEditState.notifier).state = editState.copyWith(
              systemPrompt: val,
            );
          },
        ),
        const SizedBox(height: 16),
        StdCheckbox(
          text: S.of(context).model_time_telling,
          value: editState.modelSettings.enableTimeTelling,
          onChanged: (val) {
            ref.read(agentEditState.notifier).state = editState.copyWith(
              modelSettings: editState.modelSettings.copyWith(
                enableTimeTelling: val,
              ),
            );
          },
        ),
        StdCheckbox(
          text: S.of(context).model_system_telling,
          value: editState.modelSettings.enableUsrSystemInformation,
          onChanged: (val) {
            ref.read(agentEditState.notifier).state = editState.copyWith(
              modelSettings: editState.modelSettings.copyWith(
                enableUsrSystemInformation: val,
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            StdButton(
              onPressed: () => OverlayPortalService.hide(context),
              child: Text(S.of(context).cancel),
            ),
            const SizedBox(width: 12),
            StdButton(
              color: theme.primaryColor,
              onPressed: () async {
                final config = editState.toAgentData().toConfigureMap();
                final overrideJson = jsonEncode(config);

                await DatabaseService.instance.updateSessionOverride(
                  widget.session.id,
                  overrideJson,
                );

                // Reload agent with override
                await ref
                    .read(agentProvider.notifier)
                    .loadAgentById(
                      widget.session.agentId,
                      overrideJson: overrideJson,
                      forceReload: true,
                    );

                if (context.mounted) {
                  OverlayPortalService.hide(context);
                }
              },
              child: Text(
                S.of(context).save,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
