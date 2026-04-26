import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/api_configs/api_database.dart';
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/l10n/generated/l10n.dart';
import 'package:uni_chat/utils/llm_icons.dart';
import 'package:uni_chat/utils/overlays.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:uni_chat/utils/uni_theme.dart';

class ModelManagementPage extends ConsumerStatefulWidget {
  const ModelManagementPage({super.key});

  @override
  ConsumerState<ModelManagementPage> createState() =>
      _ModelManagementPageState();
}

class _ModelManagementPageState extends ConsumerState<ModelManagementPage> {
  List<Model> _customModels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final models = await ApiDatabase.instance.getCustomModels();
      if (!mounted) return;
      setState(() {
        _customModels = models;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getAbilityDisplayName(ModelAbility ability, BuildContext context) {
    final s = S.of(context);
    switch (ability) {
      case ModelAbility.textGenerate:
        return s.textGenerate;
      case ModelAbility.imageGenerate:
        return s.imageGenerate;
      case ModelAbility.image2imageGenerate:
        return s.image2imageGenerate;
      case ModelAbility.file:
        return s.file;
      case ModelAbility.visual:
        return s.visual;
      case ModelAbility.embedding:
        return s.embedding;
      case ModelAbility.audio:
        return s.audio;
      case ModelAbility.video:
        return s.video;
      case ModelAbility.toolCall:
        return s.toolCall;
      case ModelAbility.thinking:
        return s.thinking;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = UniTheme.of(context);
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).model_management,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                S.of(context).model_management_official_hint,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textColor.withAlpha(180),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _customModels.isEmpty
              ? Center(
                  child: Text(
                    isZh ? '暂无自定义模型变体' : 'No custom model variants found',
                    style: TextStyle(
                      color: theme.textColor.withAlpha(150),
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _customModels.length,
                  itemBuilder: (context, index) {
                    final model = _customModels[index];
                    return _buildModelTile(model, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildModelTile(Model model, UniThemeData theme) {
    var imgP = LLMImageIndexer.tryGetImagePath(model.family);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.thirdGradeColor.withAlpha(80),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.primaryColor.withAlpha(20)),
      ),
      child: Row(
        children: [
          StdAvatar(
            length: 36,
            assetImage: imgP != null ? AssetImage(imgP) : null,
            whenNull: Icon(
              Icons.smart_toy_outlined,
              color: theme.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        model.friendlyName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textColor,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${model.family})',
                      style: TextStyle(
                        color: theme.textColor.withAlpha(130),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: model.abilities.map((ability) {
                    return ability.abilityTagWidget(context, theme.primaryColor);
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StdIconButton(
                icon: Icons.edit_outlined,
                onPressed: () => _showEditDialog(model, theme),
              ),
              const SizedBox(width: 12),
              StdIconButton(
                icon: Icons.delete_outline,
                onPressed: () => _showDeleteDialog(model, theme),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Model model, UniThemeData theme) {
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    OverlayPortalService.showDialog(
      context,
      width: 400,
      backGroundColor: theme.zeroGradeColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).delete_confirm,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            S.of(context).delete_variant_confirm,
            style: TextStyle(color: theme.textColor.withAlpha(200)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StdButton(
                text: S.of(context).cancel,
                color: theme.thirdGradeColor,
                onPressed: () => OverlayPortalService.hide(context),
              ),
              const SizedBox(width: 12),
              StdButton(
                text: isZh ? '删除' : 'Delete',
                color: Colors.red.withAlpha(200),
                onPressed: () async {
                  await ApiDatabase.instance.deleteModel(model.id);
                  if (!mounted) return;
                  OverlayPortalService.hide(context);
                  _loadModels();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Model model, UniThemeData theme) {
    if (!mounted) return;

    OverlayPortalService.showDialog(
      context,
      width: 500,
      backGroundColor: theme.zeroGradeColor,
      padding: const EdgeInsets.all(24),
      child: _EditModelDialog(
        model: model,
        theme: theme,
        onSave: () {
          _loadModels();
        },
      ),
    );
  }
}

class _EditModelDialog extends StatefulWidget {
  final Model model;
  final UniThemeData theme;
  final VoidCallback onSave;

  const _EditModelDialog({
    required this.model,
    required this.theme,
    required this.onSave,
  });

  @override
  State<_EditModelDialog> createState() => _EditModelDialogState();
}

class _EditModelDialogState extends State<_EditModelDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _friendlyNameController;
  late TextEditingController _familyController;
  late Set<ModelAbility> _selectedAbilities;

  @override
  void initState() {
    super.initState();
    _friendlyNameController = TextEditingController(
      text: widget.model.friendlyName,
    );
    _familyController = TextEditingController(text: widget.model.family);
    _selectedAbilities = Set.from(widget.model.abilities);
  }

  @override
  void dispose() {
    _friendlyNameController.dispose();
    _familyController.dispose();
    super.dispose();
  }

  String _getAbilityDisplayName(ModelAbility ability, BuildContext context) {
    final s = S.of(context);
    switch (ability) {
      case ModelAbility.textGenerate:
        return s.textGenerate;
      case ModelAbility.imageGenerate:
        return s.imageGenerate;
      case ModelAbility.image2imageGenerate:
        return s.image2imageGenerate;
      case ModelAbility.file:
        return s.file;
      case ModelAbility.visual:
        return s.visual;
      case ModelAbility.embedding:
        return s.embedding;
      case ModelAbility.audio:
        return s.audio;
      case ModelAbility.video:
        return s.video;
      case ModelAbility.toolCall:
        return s.toolCall;
      case ModelAbility.thinking:
        return s.thinking;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).edit_model_variant,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            S.of(context).model_friendly_name,
            style: TextStyle(
              fontSize: 14,
              color: theme.textColor.withAlpha(200),
            ),
          ),
          const SizedBox(height: 6),
          StdTextFormFieldOutlined(
            controller: _friendlyNameController,
            hintText: S.of(context).model_friendly_name_hint,
            validateFailureText:
                S.of(context).plz_enter + S.of(context).model_friendly_name,
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).model_family,
            style: TextStyle(
              fontSize: 14,
              color: theme.textColor.withAlpha(200),
            ),
          ),
          const SizedBox(height: 6),
          StdTextFormFieldOutlined(
            controller: _familyController,
            hintText: S.of(context).model_family_hint,
            validateFailureText:
                S.of(context).plz_enter + S.of(context).model_family,
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).model_ability,
            style: TextStyle(
              fontSize: 14,
              color: theme.textColor.withAlpha(200),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: ModelAbility.values.map((ability) {
              return StdCheckbox(
                value: _selectedAbilities.contains(ability),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedAbilities.add(ability);
                    } else {
                      _selectedAbilities.remove(ability);
                    }
                  });
                },
                text: _getAbilityDisplayName(ability, context),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StdButton(
                text: S.of(context).cancel,
                color: theme.thirdGradeColor,
                onPressed: () => OverlayPortalService.hide(context),
              ),
              const SizedBox(width: 12),
              StdButton(
                text: S.of(context).save,
                color: theme.primaryColor,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Upsert Model
                    final updatedModel = Model(
                      id: widget.model.id,
                      friendlyName: _friendlyNameController.text.trim(),
                      family: _familyController.text.trim(),
                      abilities: _selectedAbilities,
                      order: widget.model.order,
                    );
                    await ApiDatabase.instance.upsertModel(updatedModel);

                    if (!mounted) return;
                    OverlayPortalService.hide(context);
                    widget.onSave();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
