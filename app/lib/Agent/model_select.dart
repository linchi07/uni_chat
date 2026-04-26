import 'package:flutter/material.dart';
import 'package:uni_chat/api_configs/api_database.dart';
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/l10n/generated/l10n.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:uni_chat/utils/uni_theme.dart';

import '../utils/llm_icons.dart';

class ModelSelect extends StatefulWidget {
  const ModelSelect({super.key, required this.theme, required this.onSelect});
  final UniThemeData theme;
  final void Function(ApiProvider provider, Model model) onSelect;

  static Widget buildPreview(
    BuildContext context,
    double height,
    EdgeInsets padding,
    ApiProvider provider,
    Model model,
    VoidCallback? onTap,
    UniThemeData theme,
  ) {
    var imgP = LLMImageIndexer.tryGetImagePath(model.family);
    return LayoutBuilder(
      builder: (context, c) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 330, minHeight: height),
          child: StdButton(
            onPressed: onTap,
            padding: padding,
            child: (c.maxWidth >= 300)
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (imgP != null)
                        StdAvatar(
                          length: height - 10,
                          assetImage: AssetImage(imgP),
                        ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          "${model.friendlyName} | ${provider.name}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  )
                : (imgP != null)
                ? StdAvatar(length: height, assetImage: AssetImage(imgP))
                : const Icon(Icons.auto_awesome),
          ),
        );
      },
    );
  }

  @override
  State<ModelSelect> createState() => _ModelSelectState();
}

class _ModelSelectState extends State<ModelSelect> {
  Widget buildSearchResult(Model model) {
    var imgP = LLMImageIndexer.tryGetImagePath(model.family);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (_selectedModel != model) {
            setState(() {
              _selectedModel = model;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.theme.thirdGradeColor.withAlpha(60),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.theme.primaryColor.withAlpha(20)),
          ),
          child: Row(
            children: [
              StdAvatar(
                length: 36,
                assetImage: imgP != null ? AssetImage(imgP) : null,
                whenNull: Icon(
                  Icons.smart_toy_outlined,
                  color: widget.theme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      TextSpan(
                        text: model.friendlyName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.theme.textColor,
                          fontSize: 15,
                        ),
                        children: [
                          TextSpan(
                            text: "  ${model.family}",
                            style: TextStyle(
                              color: widget.theme.textColor.withAlpha(150),
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: model.abilities
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(
                                  right: 4,
                                  top: 2,
                                ),
                                child: getInfoTags(e),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getInfoTags(ModelAbility ability) {
    return ability.abilityTagWidget(context, widget.theme.primaryColor);
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
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget buildProvider(ApiProvider provider) {
    var imgP = LLMImageIndexer.tryGetImagePath(provider.preset);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (_selectedModel != null) {
            widget.onSelect(provider, _selectedModel!);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: widget.theme.thirdGradeColor.withAlpha(60),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.theme.primaryColor.withAlpha(20)),
          ),
          child: Row(
            children: [
              StdAvatar(
                length: 32,
                assetImage: imgP != null ? AssetImage(imgP) : null,
                whenNull: Icon(
                  Icons.precision_manufacturing_outlined,
                  color: widget.theme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  provider.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: widget.theme.textColor,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
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
                text: (_showAll)
                    ? S.of(context).show_available_models
                    : S.of(context).show_all_models,
                onPressed: () {
                  setState(() {
                    _showAll = !_showAll;
                  });
                },
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
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
