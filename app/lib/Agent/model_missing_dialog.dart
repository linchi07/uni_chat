import 'package:flutter/material.dart';
import 'package:uni_chat/Agent/agent_models.dart';
import 'package:uni_chat/Agent/model_select.dart';
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/l10n/generated/l10n.dart';
import 'package:uni_chat/theme_manager.dart';
import 'package:uni_chat/utils/overlays.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';

class ModelMissingDialog extends StatefulWidget {
  final AgentData agentData;
  final ThemeConfig theme;
  final Function(ApiProvider provider, Model model, bool saveToSettings)
  onConfirm;

  const ModelMissingDialog({
    super.key,
    required this.agentData,
    required this.theme,
    required this.onConfirm,
  });

  @override
  State<ModelMissingDialog> createState() => _ModelMissingDialogState();
}

class _ModelMissingDialogState extends State<ModelMissingDialog> {
  bool _saveToSettings = true;
  ApiProvider? _selectedProvider;
  Model? _selectedModel;
  final ValueNotifier<int> _trigger = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: widget.theme.errorColor,
              size: 28,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                S.of(context).model_unavailable,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.theme.textColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 500,
          child: ValueListenableBuilder(
            valueListenable: _trigger,
            builder: (context, value, child) {
              return Center(
                child: ModelSelect(
                  key: ValueKey(value),
                  theme: widget.theme,
                  onSelect: (provider, model) {
                    setState(() {
                      _selectedProvider = provider;
                      _selectedModel = model;
                    });
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedModel != null && _selectedProvider != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.theme.secondGradeColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.theme.primaryColor.withAlpha(100),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${_selectedModel!.friendlyName} (${_selectedProvider!.name})",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                StdIconButton(
                  icon: Icons.close,
                  onPressed: () {
                    setState(() {
                      _trigger.value++;
                      _selectedModel = null;
                      _selectedProvider = null;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            StdCheckbox(
              text: S.of(context).save_to_agent_settings(widget.agentData.name),
              value: _saveToSettings,
              onChanged: (val) {
                setState(() {
                  _saveToSettings = val ?? false;
                });
              },
            ),
            Expanded(child: const SizedBox(width: 12)),
            StdButton(
              text: S.of(context).cancel,
              color: widget.theme.secondGradeColor,
              onPressed: () {
                OverlayPortalService.hide(context);
              },
            ),
            const SizedBox(width: 12),
            StdButton(
              text: S.of(context).confirm,
              onPressed: (_selectedModel != null && _selectedProvider != null)
                  ? () {
                      widget.onConfirm(
                        _selectedProvider!,
                        _selectedModel!,
                        _saveToSettings,
                      );
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
