import 'package:flutter/material.dart';
import 'package:uni_chat/api_configs/api_database.dart';
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/l10n/generated/l10n.dart';
import 'package:uni_chat/theme_manager.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';

import '../utils/llm_icons.dart';

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
