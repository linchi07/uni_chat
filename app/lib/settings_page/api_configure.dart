import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/api_configs/api_database.dart';
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/main.dart';
import 'package:uni_chat/settings_page/settings.dart' show settingsMenuKey;
import 'package:uni_chat/theme_manager.dart';
import 'package:uni_chat/utils/overlays.dart';
import 'package:uni_chat/utils/paged_scroll/paged_scroll.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:uuid/uuid.dart';

import '../generated/l10n.dart';
import '../utils/llm_image_indexer.dart';

class ApiSettings extends ConsumerStatefulWidget {
  const ApiSettings({super.key});

  @override
  ConsumerState<ApiSettings> createState() => _ApiSettingsState();
}

class _ApiSettingsState extends ConsumerState<ApiSettings> {
  Widget getInfoTags(String category, String amount) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      height: 30,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          "$category  $amount",
          style: TextStyle(color: theme.brightTextColor),
        ),
      ),
    );
  }

  late ThemeConfig theme;
  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).api_settings,
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: theme.darkTextColor,
                ),
              ),
              StdButton(
                onPressed: () {
                  OverlayPortalService.showDialog(
                    context,
                    width: 450,
                    height: 800,
                    child: ApiPresetSelect(
                      onClose: () async {
                        await OverlayPortalService.hide(context);
                        var sc = settingsMenuKey.currentState;
                        if (sc != null) {
                          sc.insertPage(
                            ApiConfigurePage(
                              onExit: (_) =>
                                  settingsMenuKey.currentState?.popPage(),
                            ),
                          );
                        }
                      },
                    ),
                    backGroundColor: theme.zeroGradeColor,
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    const SizedBox(width: 8.0),
                    Text(
                      S.of(context).add_provider,
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: ApiDatabase.instance.getAllProviders(),
            builder: (context, f) {
              if (!f.hasData) {
                return const SizedBox();
              }
              var providers = f.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: providers.length,
                itemBuilder: (context, index) {
                  final provider = providers[index];
                  var img = LLMImageIndexer.tryGetImagePath(provider.preset);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      onTap: () {},
                      tileColor: theme.zeroGradeColor,
                      leading: (img != null)
                          ? StdAvatar(length: 40, assetImage: AssetImage(img))
                          : null,
                      title: Text(provider.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StdIconButton(
                            icon: Icons.edit_outlined,
                            onPressed: () async {
                              var ac = await ApiConfigure.formDatabase(
                                provider.id,
                              );
                              var cs = settingsMenuKey.currentState;
                              if (ac != null && cs != null) {
                                ref.read(apiConfigureProvider.notifier).state =
                                    ac;
                                cs.insertPage(
                                  ApiConfigurePage(
                                    onExit: (_) =>
                                        settingsMenuKey.currentState?.popPage(),
                                  ),
                                );
                              }
                            },
                          ),
                          StdIconButton(
                            icon: Icons.delete_outline,
                            onPressed: () {
                              OverlayPortalService.showDialog(
                                context,
                                child: Text(
                                  textAlign: TextAlign.center,
                                  S
                                      .of(context)
                                      .provider_delete_warning(provider.name),
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: theme.darkTextColor,
                                  ),
                                ),
                                backGroundColor: theme.zeroGradeColor,
                                actions: [
                                  StdButton(
                                    text: S.of(context).cancel,
                                    onPressed: () {
                                      OverlayPortalService.hide(context);
                                    },
                                  ),
                                  const SizedBox(width: 8.0),
                                  StdButton(
                                    color: theme.errorColor,
                                    text: S.of(context).confirm_long_press,
                                    onLongPress: () async {
                                      OverlayPortalService.hide(context);
                                      await ApiDatabase.instance
                                          .deleteApiProvider(provider.id);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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

class ApiPresetSelect extends ConsumerWidget {
  const ApiPresetSelect({super.key, required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: FutureBuilder(
            future: ApiDatabase.instance.getAllProviderPresets(
              onlyAvailable: true,
            ),
            builder: (context, f) {
              if (f.hasData) {
                var langC = PlatForm().languageCode;
                return StdSearch(
                  isOutlined: true,
                  hintText: S.of(context).search_provider,
                  searchItems: f.data!.map((e) => e.getName(langC)).toList(),
                  itemBuilder: (context, index) {
                    var imgP = LLMImageIndexer.tryGetImagePath(
                      f.data![index].id,
                    );
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StdListTile(
                        onTap: () async {
                          onClose();
                          ref
                              .read(apiConfigureProvider.notifier)
                              .state = await ApiConfigure.fromProviderPreset(
                            f.data![index],
                          );
                        },
                        leading: (imgP != null)
                            ? StdAvatar(
                                length: 40,
                                assetImage: AssetImage(imgP),
                              )
                            : null,
                        title: Text(
                          f.data![index].getName(langC),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                  noResultPage: Center(child: Text(S.of(context).no_results)),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        StdButton(
          text: S.of(context).add_other_provider,
          onPressed: () async {
            onClose();
            ref.read(apiConfigureProvider.notifier).state = ApiConfigure(
              id: Uuid().v7(),
              type: ProviderPresetType.fullyCustomize,
            );
          },
        ),
      ],
    );
  }
}

class ApiConfigure {
  ProviderPreset? providerPreset;
  late final String id;
  ProviderPresetType? type;
  bool showVerFlags;
  String? name;
  String? endpoint;
  ApiType? apiType;
  late List<ApiKey> keys;
  late List<({Model model, ProviderModelConfig config})> models;

  String? get providerImage {
    if (providerPreset == null) return null;
    return LLMImageIndexer.tryGetImagePath(providerPreset!.id);
  }

  ApiConfigure({
    this.providerPreset,
    required this.id,
    this.type,
    this.name,
    this.endpoint,
    this.showVerFlags = true,
    this.apiType,
    List<ApiKey>? keys,
    List<({Model model, ProviderModelConfig config})>? models,
  }) {
    this.keys = keys ?? [];
    this.models = models ?? [];
  }

  static Future<ApiConfigure> fromProviderPreset(ProviderPreset preset) async {
    var id = (preset.type == ProviderPresetType.singleInstance)
        ? "@officialSingleton-${Uuid().v5(Uuid().v5(Namespace.x500.value, "unichat"), preset.id)}"
        : (preset.type == ProviderPresetType.typeSetMultiInstance ||
              preset.type == ProviderPresetType.typeSetMultiInstanceWithoutKey)
        ? "@officialMulti-${Uuid().v7()}"
        : Uuid().v7();
    List<({Model model, ProviderModelConfig config})> configs = [];
    if (preset.models != null) {
      for (var mo in preset.models!) {
        var m = await ApiDatabase.instance.getModelById(mo.modelId);
        if (m != null) {
          mo.providerId = id;
          configs.add((model: m, config: mo));
        }
      }
    }
    return ApiConfigure(
      showVerFlags: (preset.type == ProviderPresetType.singleInstance)
          ? false
          : true,
      providerPreset: preset,
      id: id,
      name: (preset.type == ProviderPresetType.singleInstance)
          ? preset.getName(PlatForm().languageCode ?? "en")
          : null,
      type: preset.type,
      endpoint: preset.endpoint,
      apiType: preset.apiType,
      models: configs,
    );
  }

  static Future<ApiConfigure?> formDatabase(String providerID) async {
    var apip = await ApiDatabase.instance.getProviderById(providerID);
    var keys = await ApiDatabase.instance.getApiKeys(providerID);
    var pmfc = await ApiDatabase.instance.getProviderModelConfigs(providerID);
    List<Model> model = [];
    for (var m in pmfc) {
      var mo = await ApiDatabase.instance.getModelById(m.modelId);
      if (mo != null) {
        model.add(mo);
      }
    }
    ProviderPreset? ps;
    if (apip?.preset != null) {
      ps = await ApiDatabase.instance.getProviderPresetById(apip!.preset!);
    }
    if (apip != null) {
      List<({Model model, ProviderModelConfig config})> m = [];
      if (model.isNotEmpty && model.length == pmfc.length) {
        // we've got on delete cascade so the length of model and config should be the same
        for (var i = 0; i < model.length; i++) {
          m.add((model: model[i], config: pmfc[i]));
        }
      }
      return ApiConfigure(
        id: apip.id,
        providerPreset: ps,
        type: ps?.type ?? ProviderPresetType.fullyCustomize,
        apiType: apip.type,
        name: apip.name,
        endpoint: apip.endpoint,
        keys: keys,
        models: m,
      );
    }
    return null;
  }

  ApiConfigure copyWith({
    ProviderPreset? providerPreset,
    String? id,
    ProviderPresetType? type,
    String? name,
    String? endpoint,
    ApiType? apiType,
    bool? showVerFlags,
    List<ApiKey>? keys,
    List<({Model model, ProviderModelConfig config})>? models,
  }) {
    return ApiConfigure(
      providerPreset: providerPreset ?? this.providerPreset,
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      endpoint: endpoint ?? this.endpoint,
      showVerFlags: showVerFlags ?? this.showVerFlags,
      apiType: apiType ?? this.apiType,
      keys: keys ?? this.keys,
      models: models ?? this.models,
    );
  }

  bool getIfValid() {
    return name != null &&
        endpoint != null &&
        apiType != null &&
        keys.isNotEmpty &&
        models.isNotEmpty;
  }

  ApiProvider toProvider() {
    if (!getIfValid()) {
      throw Exception("Invalid api configure");
    }
    return ApiProvider(
      id: id,
      name: name!,
      endpoint: (showVerFlags) ? endpoint! + apiType!.vFlag : endpoint!,
      type: apiType!,
      preset: providerPreset?.id,
    );
  }

  Future<void> save() => ApiDatabase.instance.saveApiConfigure(this);
}

final StateProvider<ApiConfigure> apiConfigureProvider =
    StateProvider<ApiConfigure>((_) => ApiConfigure(id: Uuid().v7()));

class ApiConfigurePage extends ConsumerStatefulWidget {
  const ApiConfigurePage({super.key, required this.onExit});
  final void Function(bool finished) onExit;
  @override
  ConsumerState<ApiConfigurePage> createState() => _ApiConfigureState();
}

class _ApiConfigureState extends ConsumerState<ApiConfigurePage> {
  PageController controller = PageController();
  late bool showBasic;
  late final int indexShift;

  @override
  initState() {
    super.initState();
    theme = ref.read(themeProvider);
    ac = ref.read(apiConfigureProvider);
    showBasic = ac.type != ProviderPresetType.singleInstance;
    if (showBasic) {
      indexShift = 0;
    } else {
      indexShift = -1;
    }
    children = [
      if (showBasic) SingleChildScrollView(child: _BaseInfo(theme: theme)),
      ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ApiKeyInfo(theme: theme, apiKey: ac.keys[index]),
          );
        },
        itemCount: ac.keys.length,
      ),
      ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ModelInfo(
              theme: theme,
              model: ac.models[index].model,
              modelConfig: ac.models[index].config,
            ),
          );
        },
        itemCount: ac.models.length,
      ),
    ];
  }

  final ValueNotifier<int> _currentPage = ValueNotifier(0);

  Widget _buildSidebar() {
    return Consumer(
      builder: (context, ref, c) {
        var ac = ref.watch(apiConfigureProvider);
        var img = ac.providerImage;
        return ValueListenableBuilder(
          valueListenable: _currentPage,
          builder: (context, page, child) {
            var lanC = Localizations.localeOf(context).languageCode;
            var acName = ac.name != null && ac.name! != "";
            var endpoint = ac.endpoint != null && ac.endpoint! != "";
            var endPointValid =
                endpoint && (Uri.tryParse(ac.endpoint!)?.isAbsolute ?? false);
            String? endPointT = (ac.endpoint != null && ac.apiType != null)
                ? (ac.showVerFlags)
                      ? ac.endpoint! + ac.apiType!.vFlag
                      : ac.endpoint
                : null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (img != null)
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(60),
                            blurRadius: 2,
                            spreadRadius: 1,
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                      height: 150,
                      width: 150,
                      child: Image.asset(
                        width: 150,
                        height: 150,
                        fit: BoxFit.fitWidth,
                        img,
                      ),
                    ),
                  ),
                Expanded(
                  child: ShaderMask(
                    blendMode: BlendMode.dstOut,
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent, // 底部结束点透明
                          Colors.black, // 中间保持不透明
                        ],
                        stops: const [0.9, 1.0],
                      ).createShader(bounds);
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: ListView(
                        children: [
                          if (ac.type ==
                                  ProviderPresetType.typeSetMultiInstance &&
                              ac.providerPreset != null)
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                child: Text(
                                  ac.providerPreset!.getName(lanC),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.brightTextColor,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            (acName) ? ac.name! : S.of(context).name_not_set,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: (acName)
                                  ? theme.darkTextColor
                                  : theme.errorColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (endpoint && endPointT != null)
                                ? (endPointValid)
                                      ? "${S.of(context).valid}: $endPointT"
                                      : "${S.of(context).endPoint_might_not_valid}: $endPointT"
                                : S.of(context).endPoint_not_set,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: (endpoint)
                                  ? (endPointValid)
                                        ? theme.okColor
                                        : theme.warningColor
                                  : theme.errorColor,
                            ),
                          ),
                          Text(
                            ac.apiType?.getFriendlyName() ??
                                S.of(context).unknown,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: (ac.apiType != null)
                                  ? theme.darkTextColor
                                  : theme.errorColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (showBasic)
                            StdListTile(
                              title: Text(S.of(context).basic_configure),
                              subtitle: _indicator(
                                acName && endpoint,
                                ValueKey("base info set"),
                                S.of(context).configure_all_set,
                                S.of(context).configure_not_set,
                              ),
                              isSelected: page == 0,
                              onTap: () {
                                controller.animateToPage(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInSine,
                                );
                              },
                            ),
                          StdListTile(
                            title: Text(S.of(context).api_keys_configure),
                            isSelected: page == 1 + indexShift,
                            subtitle: _indicator(
                              ac.keys.isNotEmpty,
                              ValueKey("api key set"),
                              S
                                  .of(context)
                                  .api_keys_confiugured(ac.keys.length),
                              S.of(context).api_keys_not_set,
                            ),
                            onTap: () {
                              controller.animateToPage(
                                1 + indexShift,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInSine,
                              );
                            },
                          ),
                          StdListTile(
                            isSelected: page == 2 + indexShift,
                            title: Text(S.of(context).model_configure),
                            onTap: () {
                              controller.animateToPage(
                                2 + indexShift,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInSine,
                              );
                            },
                            subtitle: _indicator(
                              ac.models.isNotEmpty,
                              ValueKey("model set"),
                              S.of(context).model_configured(ac.models.length),
                              S.of(context).model_configure_not_set,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                StdButton(
                  color: theme.thirdGradeColor,
                  text: (page == 0)
                      ? S.of(context).cancel
                      : S.of(context).previous_step,
                  onPressed: () {
                    if (page == 0) {
                      widget.onExit(false);
                      return;
                    }
                    controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInSine,
                    );
                  },
                ),
                const SizedBox(height: 10),
                StdButton(
                  text: (page == 2 + indexShift)
                      ? S.of(context).save
                      : S.of(context).next_step,
                  onPressed: () async {
                    if (page == 2 + indexShift) {
                      if (ac.getIfValid()) {
                        await ac.save();
                        widget.onExit(true);
                      }
                    } else {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInSine,
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        );
      },
    );
  }

  Widget _indicator(bool isOK, Key key, String okText, String failText) {
    return AnimatedCrossFade(
      key: key,
      firstChild: Row(
        children: [
          Icon(Icons.check, color: theme.okColor),
          const SizedBox(width: 5),
          Text(okText),
        ],
      ),
      secondChild: Row(
        children: [
          Icon(Icons.close, color: theme.errorColor),
          const SizedBox(width: 5),
          Text(failText),
        ],
      ),
      crossFadeState: (isOK)
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 300),
    );
  }

  List<Widget> children = [];

  late ThemeConfig theme;
  late ApiConfigure ac;
  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);
    // the paged scroll widget has its own limits:
    // it requires the children to directly be a scrollable
    // any consumer widget will break this chain
    // so there is no way to watch provider per page
    // this listen method makes sure that only the page that changes will be rebuilt
    // however it relies heavily on the hashcode of lists
    // so everytime a copy with is made , we need to create a new list through "[...]"
    ref.listen(apiConfigureProvider, (previous, next) {
      ac = next;
      var ssFlag = false;
      if (ac.keys != previous?.keys) {
        children[1 + indexShift] = ListView.builder(
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: ApiKeyInfo(theme: theme, apiKey: ac.keys[index]),
            );
          },
          itemCount: ac.keys.length,
        );
        ssFlag = true;
      }
      if (ac.models != previous?.models) {
        children[2 + indexShift] = ListView.builder(
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: ModelInfo(
                theme: theme,
                model: ac.models[index].model,
                modelConfig: ac.models[index].config,
              ),
            );
          },
          itemCount: ac.models.length,
        );
        ssFlag = true;
      }
      if (ssFlag) {
        setState(() {});
      }
    });
    List<Widget> header = [
      if (showBasic) SizedBox.shrink(),
      ApiKeyHeader(theme: theme),
      ModelAddPageHeader(theme: theme),
    ];
    return Row(
      children: [
        Expanded(flex: 1, child: _buildSidebar()),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: PagedScroll(
            controller: controller,
            onPageChanged: (page) {
              var n = ref.read(apiConfigureProvider.notifier);
              //force listening widget to save changes
              n.state = n.state.copyWith();
              _currentPage.value = page;
            },
            headerBuilder: (_, index) {
              return header[index];
            },
            children: children,
          ),
        ),
      ],
    );
  }
}

class _BaseInfo extends ConsumerStatefulWidget {
  const _BaseInfo({super.key, required this.theme});
  final ThemeConfig theme;
  @override
  ConsumerState<_BaseInfo> createState() => __BaseInfoState();
}

class __BaseInfoState extends ConsumerState<_BaseInfo> {
  ThemeConfig get theme => widget.theme;

  late TextStyle tStyle;
  ApiType? get selected => ac.apiType;

  ValueNotifier<String?> endPointText = ValueNotifier(null);
  late ApiConfigure ac;
  @override
  void initState() {
    super.initState();
    ac = ref.read(apiConfigureProvider);
    name.text = ac.name ?? "";
    endpoint.text = ac.endpoint ?? "";
    endPointText.value = endpoint.text;
    endpoint.addListener((){
      endPointText.value = endpoint.text;
    });
  }

  TextEditingController name = TextEditingController();
  TextEditingController endpoint = TextEditingController();
  @override
  Widget build(BuildContext context) {
    ac = ref.watch(apiConfigureProvider);
    ref.listen(apiConfigureProvider, (_, ac) {
      ac.name = name.text;
      ac.endpoint = endpoint.text;
    });
    tStyle = TextStyle(fontSize: 20, color: theme.darkTextColor);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).basic_configure,
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: theme.darkTextColor,
            ),
          ),
          const Divider(height: 20, thickness: 1),
          Text(
            S.of(context).name,
            style: TextStyle(fontSize: 20, color: theme.darkTextColor),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 500,
              decoration: BoxDecoration(
                color: theme.zeroGradeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: StdTextFieldOutlined(
                controller: name,
                hintText: S.of(context).plz_enter_name,
                onSubmitted: (s) {
                  ref.read(apiConfigureProvider.notifier).state = ac.copyWith(
                    name: s,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (ac.type == ProviderPresetType.fullyCustomize)
            ...apiTypeSelector(ac),
          Text(
            S.of(context).end_point(""),
            style: TextStyle(fontSize: 20, color: theme.darkTextColor),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 500,
              decoration: BoxDecoration(
                color: theme.zeroGradeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: StdTextFieldOutlined(
                onSubmitted: (s) {
                  ref.read(apiConfigureProvider.notifier).state = ac.copyWith(
                    endpoint: s,
                  );
                },
                controller: endpoint,
                hintText: S.of(context).enter_end_point,
              ),
            ),
          ),
          const SizedBox(height: 10),
          StdCheckbox(
            text: S.of(context).add_ver_flag,
            value: ac.showVerFlags,
            onChanged: (value) {
              ref.read(apiConfigureProvider.notifier).state = ac.copyWith(
                showVerFlags: value,
              );
            },
          ),
          const SizedBox(height: 10),
          endPointIndicator(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Widget> apiTypeSelector(ApiConfigure ac) {
    return [
      const SizedBox(height: 20),
      Text(
        S.of(context).api_type,
        style: TextStyle(fontSize: 20, color: theme.darkTextColor),
      ),
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerLeft,
        child: StdDropDown(
          height: 50,
          width: 500,
          initialIndex: selected?.index,
          onChanged: (index) {
            ref.read(apiConfigureProvider.notifier).state = ac.copyWith(
              apiType: selected,
            );
          },
          itemBuilder: (context, index, onTap) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: StdListTile(
                title: Text(ApiType.values[index].getFriendlyName()),
                onTap: () {
                  onTap(index);
                },
              ),
            );
          },
          itemCount: ApiType.values.length,
        ),
      ),
    ];
  }

  Widget endPointIndicator() {
    return ValueListenableBuilder(
      valueListenable: endPointText,
      builder: (context, text, c) {
        return (text == null || selected == null)
            ? const SizedBox()
            : Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 500,
                  decoration: BoxDecoration(
                    color: theme.zeroGradeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(S.of(context).end_point_preview, style: tStyle),
                      const SizedBox(height: 10),
                      ...selected!.getEndPointInfo(
                        (ac.showVerFlags) ? (text + ac.apiType!.vFlag) : text,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
      },
    );
  }
}

class ApiKeyHeader extends StatefulWidget {
  const ApiKeyHeader({super.key, required this.theme});
  final ThemeConfig theme;

  @override
  State<ApiKeyHeader> createState() => _ApiKeyState();
}

class _ApiKeyState extends State<ApiKeyHeader> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                S.of(context).api_key,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: widget.theme.darkTextColor,
                ),
              ),
              Expanded(child: const SizedBox(width: 10)),
              StdButton(
                text: S.of(context).add_api_key,
                onPressed: () {
                  OverlayPortalService.showDialog(
                    context,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    width: 450,
                    child: Consumer(
                      builder: (context, ref, c) {
                        return ApiKeyEditMenu(
                          theme: widget.theme,
                          apiKey: ApiKey(
                            ref.read(apiConfigureProvider).id,
                            Uuid().v7(),
                            "",
                          ),
                          onSave: (k) {
                            var n = ref.read(apiConfigureProvider.notifier);
                            n.state = n.state.copyWith(
                              keys: [...n.state.keys, k],
                            );
                            OverlayPortalService.hide(context);
                          },
                          onCancel: () {
                            OverlayPortalService.hide(context);
                          },
                        );
                      },
                    ),
                    backGroundColor: widget.theme.zeroGradeColor,
                  );
                },
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          const Divider(height: 20, thickness: 1),
        ],
      ),
    );
  }
}

class ApiKeyInfo extends ConsumerStatefulWidget {
  const ApiKeyInfo({super.key, required this.theme, required this.apiKey});
  final ThemeConfig theme;
  final ApiKey apiKey;

  @override
  ConsumerState<ApiKeyInfo> createState() => _ApiKeyInfoState();
}

class _ApiKeyInfoState extends ConsumerState<ApiKeyInfo> {
  ApiKey get apiKey => widget.apiKey;
  bool hideKey = true;
  @override
  void initState() {
    super.initState();
    tStyle = TextStyle(
      fontSize: 15,
      color: widget.theme.brightTextColor,
      fontWeight: FontWeight.bold,
    );
  }

  late TextStyle tStyle;
  @override
  Widget build(BuildContext context) {
    var enableAdvance = apiKey.enableAdvanced();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: widget.theme.zeroGradeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SelectionArea(
            child: Row(
              children: [
                if (apiKey.remark != null)
                  Text(
                    apiKey.remark!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 25,
                      color: widget.theme.darkTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(width: 5),
                StdIconButton(
                  icon: (hideKey) ? Icons.visibility : Icons.visibility_off,
                  onPressed: () {
                    setState(() {
                      hideKey = !hideKey;
                    });
                  },
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    (!hideKey) ? apiKey.key : "•" * 20,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: widget.theme.darkTextColor.withAlpha(150),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                StdIconButton(
                  icon: Icons.edit_outlined,
                  onPressed: () {
                    OverlayPortalService.showDialog(
                      context,
                      backGroundColor: widget.theme.zeroGradeColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      width: 450,
                      child: ApiKeyEditMenu(
                        theme: widget.theme,
                        apiKey: apiKey,
                        onSave: (k) {
                          var n = ref.read(apiConfigureProvider.notifier);
                          var l = <ApiKey>[];
                          for (var key in n.state.keys) {
                            if (identical(key, apiKey)) {
                              l.add(k);
                            } else {
                              l.add(key);
                            }
                          }
                          n.state = n.state.copyWith(keys: l);
                          OverlayPortalService.hide(context);
                        },
                        onCancel: () {
                          OverlayPortalService.hide(context);
                        },
                      ),
                    );
                    editMenu(context, widget.theme);
                  },
                ),
                const SizedBox(width: 5),
                StdIconButton(
                  icon: Icons.monitor_heart_outlined,
                  onPressed: () {},
                ),
                const SizedBox(width: 5),
                StdIconButton(
                  icon: Icons.delete_outline,
                  onPressed: () {
                    OverlayPortalService.showDialog(
                      context,
                      child: Text(
                        S.of(context).delete_confirm,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: widget.theme.darkTextColor,
                        ),
                      ),
                      actions: [
                        StdButton(
                          text: S.of(context).cancel,
                          onPressed: () {
                            OverlayPortalService.hide(context);
                          },
                        ),
                        const SizedBox(width: 10),
                        StdButton(
                          text: S.of(context).confirm_long_press,
                          onLongPress: () {
                            var n = ref.read(apiConfigureProvider.notifier);
                            n.state = n.state.copyWith(
                              keys: n.state.keys
                                  .where((element) => element != apiKey)
                                  .toList(),
                            );
                            OverlayPortalService.hide(context);
                          },
                          color: widget.theme.errorColor,
                        ),
                      ],
                      backGroundColor: widget.theme.zeroGradeColor,
                    );
                  },
                ),
                if (!enableAdvance)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: enableButton(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          if (enableAdvance)
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (apiKey.rpm != null)
                          getInfoTags(
                            S.of(context).request_per_minute,
                            apiKey.rpm!.toString(),
                          ),
                        if (apiKey.rpd != null)
                          getInfoTags(
                            S.of(context).request_daily_limit,
                            apiKey.rpd!.toString(),
                          ),
                        if (apiKey.tokenLimit != null)
                          getInfoTags(
                            S.of(context).token_daily_limit,
                            apiKey.tokenLimit!.toString(),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                enableButton(),
              ],
            ),
        ],
      ),
    );
  }

  Widget enableButton() {
    return SizedBox(
      width: 90,
      child: StdButton(
        onPressed: () {
          setState(() {
            apiKey.enabled = !apiKey.enabled;
          });
        },
        color: (apiKey.enabled)
            ? widget.theme.okColor
            : widget.theme.errorColor,
        child: Text(
          (apiKey.enabled) ? S.of(context).enable : S.of(context).disable,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: widget.theme.brightTextColor,
          ),
        ),
      ),
    );
  }

  Widget getInfoTags(String category, String amount) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      height: 30,
      decoration: BoxDecoration(
        color: widget.theme.primaryColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(child: Text("$category  $amount", style: tStyle)),
    );
  }

  void editMenu(BuildContext context, ThemeConfig theme) {}
}

class ApiKeyEditMenu extends StatefulWidget {
  const ApiKeyEditMenu({
    super.key,
    required this.theme,
    required this.apiKey,
    required this.onSave,
    required this.onCancel,
  });
  final ThemeConfig theme;
  final ApiKey apiKey;
  final void Function(ApiKey) onSave;
  final void Function() onCancel;

  @override
  State<ApiKeyEditMenu> createState() => _ApiKeyEditMenuState();
}

class _ApiKeyEditMenuState extends State<ApiKeyEditMenu> {
  ThemeConfig get theme => widget.theme;
  late TextStyle ts;
  @override
  void initState() {
    super.initState();
    ts = TextStyle(fontSize: 15, color: theme.darkTextColor);
    _apiKeyController.text = apiKey.key;
    _remark.text = apiKey.remark ?? "";
    _rpm.text = apiKey.rpm?.toString() ?? "";
    _rpd.text = apiKey.rpd?.toString() ?? "";
    _tL.text = apiKey.tokenLimit?.toString() ?? "";
  }

  ApiKey get apiKey => widget.apiKey;
  bool showAdvanced = false;
  var fKey = GlobalKey<FormState>();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _remark = TextEditingController();
  final TextEditingController _rpm = TextEditingController();
  final TextEditingController _rpd = TextEditingController();
  final TextEditingController _tL = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: fKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            S.of(context).api_keys_configure,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: theme.darkTextColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(S.of(context).api_key, style: ts),
          const SizedBox(height: 5),
          StdTextFormFieldOutlined(
            hintText: S.of(context).fill_in_api_key,
            controller: _apiKeyController,
            validateFailureText: S.of(context).fill_in_api_key,
          ),
          const SizedBox(height: 10),
          Text(S.of(context).remark, style: ts),
          const SizedBox(height: 5),
          StdTextFormFieldOutlined(
            hintText:
                S.of(context).plz_enter + S.of(context).remark.toLowerCase(),
            controller: _remark,
            validator: (v) {
              return null;
            },
          ),
          const SizedBox(height: 20),
          // 高级设置标题行，带开关
          GestureDetector(
            onTap: () {
              setState(() {
                showAdvanced = !showAdvanced;
              });
            },
            child: Row(
              children: [
                StdIconButton(
                  icon: (showAdvanced) ? Icons.expand_less : Icons.expand_more,
                  onPressed: () {
                    setState(() {
                      showAdvanced = !showAdvanced;
                    });
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    S.of(context).advance_settings,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.darkTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showAdvanced) ...advancedSetting(context),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StdButton(
                text: S.of(context).cancel,
                onPressed: () {
                  widget.onCancel();
                },
              ),
              const SizedBox(width: 10),
              StdButton(
                text: S.of(context).confirm,
                onPressed: () {
                  if (!fKey.currentState!.validate()) {
                    return;
                  }
                  var k = apiKey.copyWith(
                    id: apiKey.id,
                    key: _apiKeyController.text,
                    remark: _remark.text,
                    rpm: int.tryParse(_rpm.text),
                    rpd: int.tryParse(_rpd.text),
                    tokenLimit: int.tryParse(_tL.text),
                  );
                  widget.onSave(k);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> advancedSetting(BuildContext context) {
    return [
      const SizedBox(height: 10),
      Row(
        children: [
          Text(S.of(context).request_per_minute, style: ts),
          const SizedBox(width: 10),
          Expanded(
            child: StdTextFormFieldOutlined(
              hintText:
                  "${S.of(context).plz_enter}${S.of(context).request_per_minute.toLowerCase()}",
              controller: _rpm,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                } else if (int.tryParse(value) == null) {
                  return S.of(context).plz_enter_digit;
                } else if (int.tryParse(value)! < 0) {
                  return S.of(context).plz_enter_a_number_bigger_than_zero;
                }
                return null;
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Text(S.of(context).request_daily_limit, style: ts),
          const SizedBox(width: 10),
          Expanded(
            child: StdTextFormFieldOutlined(
              hintText:
                  S.of(context).plz_enter +
                  S.of(context).request_daily_limit.toLowerCase(),
              controller: _rpd,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                } else if (int.tryParse(value) == null) {
                  return S.of(context).plz_enter_digit;
                } else if (int.tryParse(value)! < 0) {
                  return S.of(context).plz_enter_a_number_bigger_than_zero;
                }
                return null;
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Text(S.of(context).token_daily_limit, style: ts),
          const SizedBox(width: 10),
          Expanded(
            child: StdTextFormFieldOutlined(
              hintText:
                  S.of(context).plz_enter +
                  S.of(context).token_daily_limit.toLowerCase(),
              controller: _tL,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return null;
                } else if (int.tryParse(value) == null) {
                  return S.of(context).plz_enter_digit;
                } else if (int.tryParse(value)! < 0) {
                  return S.of(context).plz_enter_a_number_bigger_than_zero;
                }
                return null;
              },
            ),
          ),
        ],
      ),
    ];
  }
}

class ModelAddPageHeader extends StatefulWidget {
  const ModelAddPageHeader({super.key, required this.theme});
  final ThemeConfig theme;
  @override
  State<ModelAddPageHeader> createState() => _ModelAddPageHeaderState();
}

class _ModelAddPageHeaderState extends State<ModelAddPageHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                S.of(context).model,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: widget.theme.darkTextColor,
                ),
              ),
              Expanded(child: const SizedBox(width: 10)),
              Consumer(
                builder: (context, ref, child) {
                  var theme = ref.watch(themeProvider);
                  var ac = ref.read(apiConfigureProvider);
                  return StdButton(
                    text: S.of(context).add_model,
                    onPressed: () {
                      OverlayPortalService.showDialog(
                        context,
                        child: ModelAddWidget(
                          theme: theme,
                          modelConfig: ProviderModelConfig(
                            providerId: ac.id,
                            modelId: "",
                            callName: "",
                          ),
                          onSave: (m, p) {
                            ref.read(apiConfigureProvider.notifier).state = ac
                                .copyWith(
                                  models: [...ac.models, (model: m, config: p)],
                                );
                            OverlayPortalService.hide(context);
                          },
                        ),
                        backGroundColor: theme.zeroGradeColor,
                        width: 450,
                      );
                    },
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
            ],
          ),
          const Divider(height: 20, thickness: 1),
        ],
      ),
    );
  }
}

class ModelInfo extends ConsumerStatefulWidget {
  const ModelInfo({
    super.key,
    required this.theme,
    required this.model,
    required this.modelConfig,
  });
  final ThemeConfig theme;
  final Model model;
  final ProviderModelConfig modelConfig;

  @override
  ConsumerState<ModelInfo> createState() => _ModelInfoState();
}

class _ModelInfoState extends ConsumerState<ModelInfo> {
  Model get model => widget.model;
  bool hideKey = true;
  @override
  void initState() {
    super.initState();
    tStyle = TextStyle(
      fontSize: 15,
      color: widget.theme.brightTextColor,
      fontWeight: FontWeight.bold,
    );
  }

  late TextStyle tStyle;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: widget.theme.zeroGradeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          StdAvatar(
            length: 50,
            assetImage: AssetImage(LLMImageIndexer.getImagePath(model.family)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectionArea(
                  child: Row(
                    children: [
                      Text(
                        model.friendlyName,
                        style: TextStyle(
                          fontSize: 25,
                          color: widget.theme.darkTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          model.family,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            color: widget.theme.darkTextColor.withAlpha(150),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      StdIconButton(
                        icon: Icons.edit_outlined,
                        onPressed: () {
                          OverlayPortalService.showDialog(
                            context,
                            width: 450,
                            backGroundColor: widget.theme.zeroGradeColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            child: ModelConfigureWidget(
                              providerConfig: widget.modelConfig,
                              model: model,
                              theme: widget.theme,
                              onSave: (c) {
                                var n = ref.read(apiConfigureProvider.notifier);
                                var ac = n.state;
                                for (int i = 0; i < ac.models.length; i++) {
                                  if (ac.models[i].model.id == model.id) {
                                    ac.models[i] = (model: model, config: c);
                                  }
                                }
                                n.state = ac.copyWith(models: [...ac.models]);
                                OverlayPortalService.hide(context);
                              },
                              onCancel: () {
                                OverlayPortalService.hide(context);
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 5),
                      StdIconButton(
                        icon: Icons.delete_outline,
                        onPressed: () {
                          OverlayPortalService.showDialog(
                            context,
                            child: Text(
                              S.of(context).delete_confirm,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: widget.theme.darkTextColor,
                              ),
                            ),
                            actions: [
                              StdButton(
                                text: S.of(context).cancel,
                                onPressed: () {
                                  OverlayPortalService.hide(context);
                                },
                              ),
                              const SizedBox(width: 10),
                              StdButton(
                                text: S.of(context).confirm_long_press,
                                onLongPress: () {
                                  var n = ref.read(
                                    apiConfigureProvider.notifier,
                                  );
                                  n.state = n.state.copyWith(
                                    models: [
                                      ...n.state.models.where(
                                        (element) =>
                                            element.model.id != model.id,
                                      ),
                                    ],
                                  );
                                  OverlayPortalService.hide(context);
                                },
                                color: widget.theme.errorColor,
                              ),
                            ],
                            backGroundColor: widget.theme.zeroGradeColor,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        (widget.modelConfig.abilitiesOverride ??
                                model.abilities)
                            .map((e) => getInfoTags(e))
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getInfoTags(ModelAbility ability) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      height: 30,
      decoration: BoxDecoration(
        color: widget.theme.primaryColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(child: Text(ability.name(context), style: tStyle)),
    );
  }
}

class ModelAddWidget extends StatefulWidget {
  const ModelAddWidget({
    super.key,
    required this.theme,
    required this.onSave,
    required this.modelConfig,
  });
  final ThemeConfig theme;
  final ProviderModelConfig modelConfig;
  final void Function(Model, ProviderModelConfig) onSave;

  @override
  State<ModelAddWidget> createState() => _ModelAddWidgetState();
}

class _ModelAddWidgetState extends State<ModelAddWidget> {
  Model? currentSelected;
  bool adding = false;
  @override
  Widget build(BuildContext context) {
    if (adding) {
      return AnimatedContainer(
        key: ValueKey("modelAdd"),
        duration: const Duration(milliseconds: 200),
        height: 600,
        child: AddNewModel(
          theme: widget.theme,
          modelConfig: widget.modelConfig,
          onCancel: () {
            setState(() {
              adding = false;
            });
          },
          onSave: (c) async {
            await ApiDatabase.instance.insertModel(c.model);
            widget.onSave(c.model, c.config);
          },
        ),
      );
    } else if (currentSelected != null) {
      widget.modelConfig.modelId = currentSelected!.id;
      return AnimatedContainer(
        key: ValueKey("modelAdd"),
        duration: const Duration(milliseconds: 200),
        height: 400,
        child: ModelConfigureWidget(
          model: currentSelected!,
          theme: widget.theme,
          onSave: (c) {
            widget.onSave(currentSelected!, c);
          },
          onCancel: () {
            setState(() {
              currentSelected = null;
            });
          },
          providerConfig: widget.modelConfig,
        ),
      );
    } else {
      return AnimatedContainer(
        key: ValueKey("modelAdd"),
        height: 800,
        duration: const Duration(milliseconds: 200),
        child: search(),
      );
    }
  }

  Widget buildSearchResult(Model model) {
    var imgP = LLMImageIndexer.tryGetImagePath(model.family);
    return StdListTile(
      onTap: () {
        setState(() {
          currentSelected = model;
        });
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

  List<Model> _models = [];
  Widget search() {
    return FutureBuilder(
      future: ApiDatabase.instance.getAllModels(),
      builder: (context, model) {
        if (model.hasData) {
          _models = model.data!;
          return StdSearch(
            hintText: S.of(context).search_for_models,
            isOutlined: true,
            searchItems: _models.map((e) => e.friendlyName).toList(),
            itemBuilder: (context, e) => buildSearchResult(_models[e]),
            noResultPage: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context).model_not_found,
                    style: TextStyle(
                      color: widget.theme.darkTextColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  StdButton(
                    text: S.of(context).add_model,
                    onPressed: () {
                      setState(() {
                        adding = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}

class AddNewModel extends StatefulWidget {
  const AddNewModel({
    super.key,
    required this.theme,
    required this.onSave,
    required this.onCancel,
    required this.modelConfig,
  });
  final ProviderModelConfig modelConfig;
  final ThemeConfig theme;
  final void Function(({Model model, ProviderModelConfig config})) onSave;
  final void Function() onCancel;

  @override
  State<AddNewModel> createState() => _AddNewModelState();
}

class _AddNewModelState extends State<AddNewModel> {
  @override
  Widget build(BuildContext context) {
    return addNew();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var selectedAbilities = <ModelAbility>{ModelAbility.textGenerate};
  final modelNameController = TextEditingController();
  final modelFriendlyNameController = TextEditingController();
  final modelFamilyController = TextEditingController();

  Widget addNew() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).create_new_model,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: widget.theme.darkTextColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            S.of(context).fill_model_call_name,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 4),
          StdTextFormFieldOutlined(
            validateFailureText:
                "${S.of(context).plz_enter}${S.of(context).fill_model_call_name}",
            controller: modelNameController,
            hintText: S.of(context).model_call_name_hint,
          ),
          const SizedBox(height: 10),
          Text(
            S.of(context).model_friendly_name,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 4),
          StdTextFormFieldOutlined(
            validateFailureText:
                "${S.of(context).plz_enter}${S.of(context).model_friendly_name}",
            controller: modelFriendlyNameController,
            hintText: S.of(context).model_friendly_name_hint,
          ),
          const SizedBox(height: 10),
          Text(
            S.of(context).model_family,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 4),
          StdTextFormFieldOutlined(
            validateFailureText:
                "${S.of(context).plz_enter}${S.of(context).model_family}",
            controller: modelFamilyController,
            hintText: S.of(context).model_family_hint,
          ),
          const SizedBox(height: 10),
          Text(S.of(context).model_ability, style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          _modelAbility(),
          Expanded(child: const SizedBox()),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StdButton(text: S.of(context).cancel, onPressed: widget.onCancel),
              const SizedBox(width: 10),
              StdButton(
                text: S.of(context).save,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    var id = Uuid().v7();
                    widget.onSave((
                      model: Model(
                        friendlyName: modelFriendlyNameController.text,
                        family: modelFamilyController.text,
                        abilities: selectedAbilities.toSet(),
                        id: id,
                      ),
                      config: ProviderModelConfig(
                        providerId: widget.modelConfig.providerId,
                        modelId: id,
                        callName: modelNameController.text,
                      ),
                    ));
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modelAbility() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: ModelAbility.values.map((ability) {
        return StdCheckbox(
          value: selectedAbilities.contains(ability),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                selectedAbilities = ability.checkIfValid(
                  selectedAbilities,
                  ability,
                );
              } else {
                selectedAbilities.remove(ability);
              }
            });
          },
          text: ability.name(context),
        );
      }).toList(),
    );
  }
}

class ModelConfigureWidget extends StatefulWidget {
  const ModelConfigureWidget({
    super.key,
    required this.model,
    required this.providerConfig,
    required this.theme,
    required this.onSave,
    required this.onCancel,
  });
  final ThemeConfig theme;
  final Model model;
  final ProviderModelConfig providerConfig;
  final void Function(ProviderModelConfig) onSave;
  final void Function() onCancel;

  @override
  State<ModelConfigureWidget> createState() => _ModelConfigureWidgetState();
}

class _ModelConfigureWidgetState extends State<ModelConfigureWidget> {
  late TextStyle tStyle;
  ProviderModelConfig get pConfig => widget.providerConfig;
  ThemeConfig get theme => widget.theme;
  @override
  void initState() {
    super.initState();
    pConfig.abilitiesOverride ??= widget.model.abilities;
    tStyle = TextStyle(fontSize: 15, color: theme.darkTextColor);
    callNameController.text = pConfig.callName;
  }

  final fKey = GlobalKey<FormState>();
  final TextEditingController callNameController = TextEditingController();

  Widget buildModelResult() {
    var model = widget.model;
    var imgP = LLMImageIndexer.tryGetImagePath(model.family);
    return StdListTile(
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
          style: TextStyle(color: widget.theme.brightTextColor, fontSize: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: fKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 10),
          Text(
            S.of(context).model_configure,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: theme.darkTextColor,
            ),
          ),
          const SizedBox(height: 10),
          buildModelResult(),
          const SizedBox(height: 10),
          Text(S.of(context).fill_model_call_name, style: tStyle),
          const SizedBox(height: 5),
          StdTextFormFieldOutlined(
            maxLines: 2,
            hintText: S.of(context).model_call_name_hint,
            controller: callNameController,
            validateFailureText: S.of(context).plz_fill_model_call_name,
          ),
          const SizedBox(height: 10),
          Text(
            S.of(context).model_property,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.darkTextColor,
            ),
          ),
          const SizedBox(height: 5),
          Wrap(
            children: widget.model.abilities.map((e) {
              return StdCheckbox(
                text: e.name(context),
                value: pConfig.abilitiesOverride?.contains(e) ?? false,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      if (val) {
                        pConfig.abilitiesOverride!.add(e);
                      } else {
                        pConfig.abilitiesOverride!.remove(e);
                      }
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StdButton(
                text: S.of(context).cancel,
                onPressed: () {
                  widget.onCancel();
                },
              ),
              const SizedBox(width: 10),
              StdButton(
                text: S.of(context).confirm,
                onPressed: () {
                  if (!fKey.currentState!.validate()) {
                    return;
                  }
                  pConfig.modelId = widget.model.id;
                  pConfig.callName = callNameController.text;
                  widget.onSave(pConfig);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
