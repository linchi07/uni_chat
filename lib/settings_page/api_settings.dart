import 'package:uni_chat/Chat/chat_state.dart' hide ApiProvider;
import 'package:uni_chat/llm_provider/pre_build_providers.dart';
import 'package:uni_chat/theme_manager.dart';
import 'package:uni_chat/utils/dialog.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_dialog/overlay_dialog.dart';
import 'package:uuid/uuid.dart';
import '../llm_provider/api_service.dart';
import '../utils/api_database_service.dart';

// --- 为右侧内容区创建的占位小部件 ---
// 在实际应用中，您会用真实的设置界面替换它们。
class ApiSettingsView extends ConsumerStatefulWidget {
  const ApiSettingsView({super.key});

  @override
  ConsumerState<ApiSettingsView> createState() => _ApiSettingsViewState();
}

class _ApiSettingsViewState extends ConsumerState<ApiSettingsView> {
  late Future<List<ApiProvider>> _providersFuture;
  bool isAddingProvider = false;
  bool isEditingProvider = false;
  String editingProviderId = "";
  @override
  void initState() {
    super.initState();
    _refreshProviders();
  }

  void _refreshProviders() {
    setState(() {
      _providersFuture = ApiDatabaseService.instance.getAllProviders();
    });
  }

  void _editProvider(ApiProvider provider) async {
    var keys = await ApiDatabaseService.instance.getApiKeysByProvider(
      provider.id,
    );
    editingProviderId = provider.id;
    var modelsConfigs = await ApiDatabaseService.instance
        .getProviderModelConfigsForProvider(provider.id);
    List<ModelsConfigData> mcd = [];
    for (var modelConfig in modelsConfigs) {
      var model = await ApiDatabaseService.instance.getModel(
        modelConfig.modelId,
      );
      if (model == null) continue;
      mcd.add(
        ModelsConfigData.fromProviderModelConfig(
          modelConfig,
          model.friendlyName,
        ),
      );
    }
    ref.read(addApiState.notifier).state = AddApiState(
      name: provider.name,
      endPoint: provider.apiEndpoint,
      keys: keys,
      models: mcd,
    );
    setState(() {
      isAddingProvider = false;
      isEditingProvider = true;
    });
  }

  Future<void> saveEditResult() async {
    var as = ref.read(addApiState);
    ApiProvider? p = await ApiDatabaseService.instance.getProvider(
      editingProviderId,
    );
    if (p == null) {
      return;
    }
    await ApiDatabaseService.instance.updateProvider(
      p.copyWith(name: as.name, apiEndpoint: as.endPoint),
    );
    for (var k in as.keys) {
      k = k.copyWith(providerId: p.id);
      await ApiDatabaseService.instance.createOrUpdateApiKey(apiKey: k);
    }
    for (var m in as.models) {
      var model = await ApiDatabaseService.instance.findOrCreateModel(
        m.friendlyName,
      );
      await ApiDatabaseService.instance.createOrUpdateProviderModelConfig(
        modelConfigData: m,
        modelId: model.id,
        providerId: p.id,
      );
    }
  }

  Future<void> _deleteProvider(ApiProvider provider) async {
    OverlayPortalService.show(
      context,
      child: SizedBox(
        width: 300,
        height: 200,
        child: Material(
          color: theme.surfaceColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 50),
                Expanded(
                  child: Text(
                    "确定要删除此提供者吗？",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StdButton(
                      color: theme.boxColor,
                      onPressed: () {
                        OverlayPortalService.hide(context);
                      },
                      text: "取消",
                    ),
                    const SizedBox(width: 16),
                    StdButton(
                      color: Colors.red,
                      onLongPress: () async {
                        OverlayPortalService.hide(context);
                        await ApiDatabaseService.instance.deleteProvider(
                          provider.id,
                        );
                        _refreshProviders();
                      },
                      text: "确定(长按)",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void back() {
    setState(() {
      isAddingProvider = false;
      isEditingProvider = false;
      _refreshProviders();
    });
  }

  late ThemeConfig theme;
  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);
    return Builder(
      builder: (context) {
        if (isAddingProvider) {
          return _AddProvider(onBack: back);
        }
        if (isEditingProvider) {
          return EditProvider(onBack: back, save: saveEditResult);
        }
        return FutureBuilder<List<ApiProvider>>(
          future: _providersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('加载错误: ${snapshot.error}'));
            }

            final providers = snapshot.data ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'API 设置',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          return StdButton(
                            onPressed: () {
                              ref.read(addApiState.notifier).state =
                                  AddApiState();
                              setState(() {
                                isAddingProvider = true;
                              });
                            },
                            child: child!,
                          );
                        },

                        child: Row(
                          children: [
                            Icon(Icons.add, color: Colors.white),
                            const SizedBox(width: 8.0),
                            Text(
                              '添加提供商',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (providers.isEmpty)
                  const Expanded(child: Center(child: Text('暂无API提供商，请添加一个')))
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: providers.length,
                      itemBuilder: (context, index) {
                        final provider = providers[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            onTap: () {},
                            tileColor: theme.surfaceColor,
                            leading: FlutterLogo(size: 50),
                            title: Text(provider.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('类型: ${provider.type}'),
                                Text('端点: ${provider.apiEndpoint}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editProvider(provider),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteProvider(provider),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class EditProvider extends ConsumerStatefulWidget {
  const EditProvider({super.key, required this.onBack, required this.save});
  final dynamic onBack;
  final dynamic save;

  @override
  ConsumerState<EditProvider> createState() => _EditProviderState();
}

class _EditProviderState extends ConsumerState<EditProvider> {
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    as = ref.read(addApiState);
    nameController.text = as.name!;
    endPointController.text = as.endPoint!;
  }

  late AddApiState as;
  final endPointController = TextEditingController();
  late ThemeConfig theme;
  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);
    var as = ref.watch(addApiState);
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 60),
      children: [
        Text(
          "编辑提供商 ${as.name}",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text("名称"),
        const SizedBox(height: 4),
        StdTextField(controller: nameController, hintText: "eg: OpenAI"),
        const SizedBox(height: 10),
        Text("端点"),
        const SizedBox(height: 4),
        StdTextField(
          controller: endPointController,
          hintText: "eg: https://api.openai.com/v1",
        ),
        const SizedBox(height: 10),
        Text("API 密钥"),
        const SizedBox(height: 4),
        SizedBox(height: 400, child: ApiKeyManagerPanel()),
        const SizedBox(height: 10),
        Text("模型"),
        const SizedBox(height: 4),
        SizedBox(
          height: 600,
          child: ModelManagePanel(loadProviderPresetModels: false),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            StdButton(
              color: theme.boxColor,
              child: Text("取消"),
              onPressed: () {
                widget.onBack();
              },
            ),
            const SizedBox(width: 10),
            StdButton(
              child: Text("保存", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                ref.read(addApiState.notifier).state = as.copyWith(
                  endPoint: endPointController.text,
                  name: nameController.text,
                );
                await widget.save();
                widget.onBack();
              },
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

class AddApiState {
  final String? name;
  //这些bool值时必要的，因为copy with传入null的时候他会设置为原始值，所以不能依靠他是不是null来判断是否需要设置
  final bool isNameSet;
  final String? type;
  final bool isTypeSet;
  final String? endPoint;
  final bool isEndPointSet;
  late final List<ApiKey> keys;
  final bool isKeysSet;
  late final List<ModelsConfigData> models;
  final bool isModelsSet;
  AddApiState({
    this.name,
    this.type,
    this.endPoint,
    List<ApiKey>? keys,
    List<ModelsConfigData>? models,
    this.isKeysSet = false,
    this.isModelsSet = false,
    this.isNameSet = false,
    this.isTypeSet = false,
    this.isEndPointSet = false,
  }) {
    this.models = models ?? [];
    this.keys = keys ?? [];
  }
  AddApiState copyWith({
    String? name,
    String? type,
    String? endPoint,
    List<ApiKey>? keys,
    List<ModelsConfigData>? models,
    bool? isKeysSet,
    bool? isModelsSet,
    bool? isNameSet,
    bool? isTypeSet,
    bool? isEndPointSet,
  }) {
    return AddApiState(
      name: name ?? this.name,
      type: type ?? this.type,
      endPoint: endPoint ?? this.endPoint,
      keys: keys ?? this.keys,
      models: models ?? this.models,
      isKeysSet: isKeysSet ?? this.isKeysSet,
      isModelsSet: isModelsSet ?? this.isModelsSet,
      isNameSet: isNameSet ?? this.isNameSet,
      isTypeSet: isTypeSet ?? this.isTypeSet,
      isEndPointSet: isEndPointSet ?? this.isEndPointSet,
    );
  }

  bool validIfAllSet() {
    return name != null &&
        type != null &&
        endPoint != null &&
        keys.isNotEmpty &&
        models.isNotEmpty &&
        isKeysSet &&
        isModelsSet &&
        isNameSet &&
        isTypeSet &&
        isEndPointSet;
  }
}

final addApiState = StateProvider((ref) => AddApiState());

class _AddProvider extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  const _AddProvider({required this.onBack});

  @override
  ConsumerState<_AddProvider> createState() => _AddProviderState();
}

class _AddProviderState extends ConsumerState<_AddProvider> {
  final _nameController = TextEditingController();
  final _endpointController = TextEditingController();

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    theme = ref.read(themeProvider);
    pages = [
      _providerSelect(),
      _buildProviderInfo(),
      _setEndPoint(),
      _apiKeyInput(),
      _buildModelsInput(),
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _endpointController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> pages = [];

  void scrollPage(AddApiState as) {
    int tPage = 0;
    if (!as.isNameSet) {
    } else if (!as.isTypeSet) {
      tPage = 1;
    } else if (!as.isEndPointSet) {
      tPage = 2;
    } else if (!as.isKeysSet) {
      tPage = 3;
    } else if (!as.isModelsSet) {
      tPage = 4;
    } else {
      tPage = 5;
    }
    if (_pageController.page == tPage) {
      return;
    }
    _pageController.animateToPage(
      tPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _apiGridTile({required PresetProvider provider}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: StdListTile(
        backgroundColor: theme.surfaceColor,
        onTap: () {
          var n = ref.read(addApiState.notifier);
          n.state = n.state.copyWith(
            isNameSet: true,
            isTypeSet: provider.type != null,
            isEndPointSet: provider.endPoint != null,
            name: provider.name,
            type: provider.type,
            endPoint: provider.endPoint,
          );
        },
        leading: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          clipBehavior: Clip.hardEdge,
          child: FlutterLogo(),
        ),
        title: Text(provider.name),
      ),
    );
  }

  Widget _providerSelect() {
    var l = PresetProvider.providers.values.toList();
    return FutureBuilder(
      future: ApiDatabaseService.instance.getAllProviders(),
      builder: (context, asyncSnapshot) {
        if (!asyncSnapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        Set<String> providers = {};
        for (var p in asyncSnapshot.data!) {
          providers.add(p.name);
        }
        for (int index = 0; index < l.length; index++) {
          if (providers.contains(l[index].name)) {
            l.removeAt(index);
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择提供商',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              //grid view的支持不太好，直接用listview实现两栏视图得了
              child: ListView.builder(
                itemCount: (l.length / 2).ceilToDouble().toInt(),
                itemBuilder: (context, index) {
                  var p1 = l[index * 2];
                  var p2 = index * 2 + 1 < l.length ? l[index * 2 + 1] : null;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: _apiGridTile(provider: p1)),
                        if (p2 != null)
                          Expanded(child: _apiGridTile(provider: p2)),
                        if (p2 == null) Expanded(child: const SizedBox()),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _apiKeyInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '添加API密钥',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(child: ApiKeyManagerPanel()),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StdButton(
                color: theme.boxColor,
                onPressed: () {
                  var n = ref.read(addApiState.notifier);
                  n.state = n.state.copyWith(
                    isKeysSet: false,
                    isEndPointSet: false,
                    isNameSet: false,
                  );
                },
                child: Text('返回'),
              ),
              const SizedBox(width: 16),
              StdButton(
                onPressed: () {
                  var n = ref.read(addApiState.notifier);
                  n.state = n.state.copyWith(isKeysSet: true);
                },
                child: Text('下一步', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderInfo() {
    var t = ref.read(addApiState).type;
    final formKey = GlobalKey<FormState>(); // 创建表单key用于验证

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '输入供应商详细信息',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text("名称(例如：OpenAI)"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: theme.boxColor,
            ),
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'eg：OpenAI',
                border: InputBorder.none, // 移除默认边框
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入提供商名称';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 4),
          const Text("API类型"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: theme.boxColor,
            ),
            child: DropdownButtonFormField<String>(
              dropdownColor: theme.boxColor,
              value: t,
              items: const [
                DropdownMenuItem(value: 'openai', child: Text('OpenAI兼容')),
                DropdownMenuItem(value: 'google', child: Text('Google兼容')),
              ],
              onChanged: (value) {
                if (value != null) {
                  t = value;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请选择API类型';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: InputBorder.none, // 移除默认边框
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StdButton(
                color: theme.boxColor,
                child: Text("返回"),
                onPressed: () {
                  var n = ref.read(addApiState.notifier);
                  n.state = n.state.copyWith(isNameSet: false);
                },
              ),
              const SizedBox(width: 16),
              StdButton(
                child: Text("下一步", style: const TextStyle(color: Colors.white)),
                onPressed: () {
                  // 验证表单
                  if (formKey.currentState!.validate()) {
                    var n = ref.read(addApiState.notifier);
                    n.state = n.state.copyWith(
                      isNameSet: true,
                      isTypeSet: true,
                      name: _nameController.text,
                      type: t,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModelsInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '确认需要添加的模型',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(child: ModelManagePanel()),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StdButton(
                color: theme.boxColor,
                child: Text("返回"),
                onPressed: () {
                  var n = ref.read(addApiState.notifier);
                  n.state = n.state.copyWith(
                    isKeysSet: false,
                    isModelsSet: false,
                  );
                },
              ),
              const SizedBox(width: 16),
              StdButton(
                child: Text("完成", style: TextStyle(color: Colors.white)),
                onPressed: () {
                  var n = ref.read(addApiState.notifier);
                  n.state = n.state.copyWith(isModelsSet: true);
                  addProvider();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _setEndPoint() {
    final formKey = GlobalKey<FormState>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '输入API端点',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: theme.boxColor,
              ),
              child: TextFormField(
                controller: _endpointController,
                decoration: const InputDecoration(
                  hintText: 'eg：https://api.openai.com/v1/chat/completions',
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入API 端点';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                StdButton(
                  color: theme.boxColor,
                  child: Text("返回"),
                  onPressed: () {
                    var n = ref.read(addApiState.notifier);
                    n.state = n.state.copyWith(
                      isNameSet: true,
                      isTypeSet: false,
                      isEndPointSet: false,
                    );
                  },
                ),
                const SizedBox(width: 16),
                StdButton(
                  child: Text(
                    "下一步",
                    style: const TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      var n = ref.read(addApiState.notifier);
                      n.state = n.state.copyWith(
                        isEndPointSet:
                            true, // 这里应该是 isEndPointSet 而不是 isKeysSet
                        endPoint: _endpointController.text,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  late ThemeConfig theme;
  @override
  Widget build(BuildContext context) {
    ref.listen(addApiState, (previous, next) {
      scrollPage(next);
    });
    theme = ref.watch(themeProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '添加新的提供商',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          AddIndicator(key: ValueKey("11114514")),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: pages,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addProvider() async {
    var as = ref.read(addApiState);
    if (!as.validIfAllSet()) {
      ref.read(addApiState.notifier).state = as.copyWith();
      return;
    }
    var pv = await ApiDatabaseService.instance.createProvider(
      name: as.name!,
      type: as.type!,
      apiEndpoint: as.endPoint!,
    );
    for (var key in as.keys) {
      key = key.copyWith(providerId: pv.id);
      await ApiDatabaseService.instance.createOrUpdateApiKey(apiKey: key);
    }
    for (var model in as.models) {
      var m = await ApiDatabaseService.instance.findOrCreateModel(
        model.friendlyName,
      );
      await ApiDatabaseService.instance.createOrUpdateProviderModelConfig(
        providerId: pv.id,
        modelId: m.id,
        modelConfigData: model,
      );
    }
    widget.onBack();
  }
}

// API 密钥管理面板组件
class ApiKeyManagerPanel extends ConsumerStatefulWidget {
  const ApiKeyManagerPanel({super.key});

  @override
  ConsumerState<ApiKeyManagerPanel> createState() => _ApiKeyManagerPanelState();
}

class _ApiKeyManagerPanelState extends ConsumerState<ApiKeyManagerPanel> {
  // 用于存储 API 密钥的列表
  final List<ApiKey> _apiKeys = [];

  @override
  void initState() {
    super.initState();
    _apiKeys.addAll(ref.read(addApiState).keys);
  }

  // 控制 API 密钥可见性的状态
  final Map<int, bool> _keyVisibility = {};

  // 添加新的 API 密钥
  void _addApiKey(String key, String remark) {
    setState(() {
      _apiKeys.add(
        ApiKey(
          id: Uuid().v4(),
          providerId: "114514",
          keyValue: key,
          keyAlias: remark,
          isEnabled: true,
        ),
      );
    });
    var n = ref.read(addApiState.notifier);
    n.state = n.state.copyWith(keys: _apiKeys);
  }

  // 删除指定索引的 API 密钥
  void _deleteApiKey(int index) {
    setState(() {
      _apiKeys.removeAt(index);
      _keyVisibility.remove(index);
    });
    var n = ref.read(addApiState.notifier);
    n.state = n.state.copyWith(keys: _apiKeys);
  }

  // 切换指定索引的 API 密钥的可见性
  void _toggleKeyVisibility(int index) {
    setState(() {
      _keyVisibility[index] = !(_keyVisibility[index] ?? false);
    });
  }

  final _formKey = GlobalKey<FormState>();
  bool isDialogKeyVisible = false; // 用于对话框内部状态
  late ThemeConfig theme;
  final apiKeyController = TextEditingController();
  final remarkController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: theme.boxColor,
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 8, 8, 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: theme.surfaceColor,
              ),
              child: _apiKeys.isEmpty
                  ? const Center(
                      child: Text(
                        '暂无 API 密钥\n请点击右下角按钮添加',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _apiKeys.length,
                      itemBuilder: (context, index) {
                        final apiKey = _apiKeys[index];
                        final isKeyVisible = _keyVisibility[index] ?? false;

                        // ⭐ 主要修改点：当密钥隐藏时，生成等长的掩码字符串
                        final obscuredKey = '•' * apiKey.keyValue.length;

                        return ListTile(
                          //TODO：这里理论上应该是有hover的效果的，但是不知道为什么他没了
                          onTap: () {},
                          title: Text(
                            apiKey.keyAlias.isNotEmpty
                                ? apiKey.keyAlias
                                : isKeyVisible
                                ? apiKey.keyValue
                                : obscuredKey,
                          ),
                          subtitle: apiKey.keyValue.isNotEmpty
                              ? Text(
                                  isKeyVisible ? apiKey.keyValue : obscuredKey,
                                )
                              : null, // 使用新的掩码字符串
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                iconSize: 20,
                                padding: EdgeInsets.all(2),
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  isKeyVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () => _toggleKeyVisibility(index),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                iconSize: 20,
                                padding: EdgeInsets.all(2),
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.remove),
                                onPressed: () => _deleteApiKey(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  iconSize: 25,
                  padding: EdgeInsets.all(1),
                  onPressed: () {
                    OverlayPortalService.show(
                      context,
                      child: SizedBox(
                        width: 400,
                        height: 300,
                        child: Material(
                          color: theme.surfaceColor,
                          clipBehavior: Clip.hardEdge,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: StatefulBuilder(
                            builder: (context, setDialogState) {
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '添加 API 密钥',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: Form(
                                        key:
                                            _formKey, // 需要在State类中定义GlobalKey<FormState>()
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "填写API密钥",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: theme.boxColor,
                                              ),
                                              child: TextFormField(
                                                controller: apiKeyController,
                                                obscureText:
                                                    !isDialogKeyVisible,
                                                decoration: InputDecoration(
                                                  hintText: 'sk-xxxx',
                                                  border: InputBorder.none,
                                                  suffixIcon: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        constraints:
                                                            const BoxConstraints(),
                                                        iconSize: 18,
                                                        icon: Icon(
                                                          isDialogKeyVisible
                                                              ? Icons.visibility
                                                              : Icons
                                                                    .visibility_off,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            isDialogKeyVisible =
                                                                !isDialogKeyVisible;
                                                          });
                                                        },
                                                      ),
                                                      IconButton(
                                                        constraints:
                                                            const BoxConstraints(),
                                                        iconSize: 18,
                                                        icon: const Icon(
                                                          Icons.clear,
                                                        ),
                                                        onPressed: () {
                                                          apiKeyController
                                                              .clear();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return '请输入API密钥';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              "填写备注（留空默认无）",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: theme.boxColor,
                                              ),
                                              child: TextField(
                                                controller: remarkController,
                                                decoration: InputDecoration(
                                                  hintText: '备注（留空默认无）',
                                                  border: InputBorder.none,
                                                  suffixIcon: IconButton(
                                                    constraints:
                                                        const BoxConstraints(),
                                                    iconSize: 18,
                                                    icon: const Icon(
                                                      Icons.clear,
                                                    ),
                                                    onPressed: () {
                                                      remarkController.clear();
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        StdButton(
                                          color: theme.backgroundColor,
                                          child: const Text('取消'),
                                          onPressed: () {
                                            OverlayPortalService.hide(context);
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        StdButton(
                                          child: const Text(
                                            '添加',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              _addApiKey(
                                                apiKeyController.text,
                                                remarkController.text,
                                              );
                                              apiKeyController.clear();
                                              remarkController.clear();
                                              OverlayPortalService.hide(
                                                context,
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                    apiKeyController.clear();
                    remarkController.clear();
                  },
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ModelManagePanel extends ConsumerStatefulWidget {
  const ModelManagePanel({super.key, this.loadProviderPresetModels = true});
  final bool loadProviderPresetModels;

  @override
  ConsumerState<ModelManagePanel> createState() => _ModelManagePanelState();
}

class _ModelManagePanelState extends ConsumerState<ModelManagePanel> {
  @override
  void initState() {
    super.initState();
    var n = ref.read(addApiState.notifier);
    var as = n.state;

    if (!widget.loadProviderPresetModels) return;

    final provider = PresetProvider.providers[as.name];
    if (provider?.models != null) {
      for (var model in provider!.models) {
        if (!as.models.contains(model)) {
          as.models.add(model);
        }
      }
    }
  }

  late ThemeConfig theme;

  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);
    final as = ref.watch(addApiState);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.grey[200],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 8, 8, 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.white,
              ),
              child: as.models.isEmpty
                  ? const Center(
                      child: Text(
                        '暂无模型\n请点击右下角按钮添加',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: as.models.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(as.models[index].friendlyName),
                              const SizedBox(width: 8),
                              for (var ability in as.models[index].abilities)
                                ability.widget,
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                as.models.removeAt(index);
                                ref.read(addApiState.notifier).state = as
                                    .copyWith(models: as.models);
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  iconSize: 25,
                  padding: EdgeInsets.all(1),
                  onPressed: () {
                    OverlayPortalService.show(
                      context,
                      child: SizedBox(
                        width: 400,
                        height: 600,
                        child: Material(
                          color: theme.surfaceColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ModelSelect(),
                        ),
                      ),
                    );
                  },
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ModelSelect extends ConsumerStatefulWidget {
  const ModelSelect({super.key});

  @override
  ConsumerState<ModelSelect> createState() => _ModelSelectState();
}

class _ModelSelectState extends ConsumerState<ModelSelect> {
  bool _isAddingNewModel = false;
  Model? _selectedModel;

  void _addNewModel(
    String friendlyName,
    String callName,
    Set<ApiAbility> abilities,
  ) {
    var as = ref.read(addApiState.notifier);
    final newModels = List<ModelsConfigData>.from(as.state.models)
      ..add(
        ModelsConfigData(
          callName: callName,
          friendlyName: friendlyName,
          abilities: abilities,
        ),
      );
    as.state = as.state.copyWith(models: newModels);
  }

  final _callNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late ThemeConfig theme;

  Widget _confirmAdd() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '填写模型调用名',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          StdListTile(
            title: Text(_selectedModel!.friendlyName),
            subtitle: Text(_selectedModel!.family),
            isSelected: true,
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: StdTextFormField(
              controller: _callNameController,
              hintText: '请输入模型调用名',
              validateFailureText: '请输入模型调用名',
            ),
          ),
          const SizedBox(height: 20),
          const Text("模型能力", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: ApiAbility.values.map((ability) {
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
                text: ability.name,
              );
            }).toList(),
          ),
          Expanded(child: SizedBox()),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StdButton(
                color: theme.boxColor,
                text: '取消',
                onPressed: () {
                  setState(() {
                    _selectedModel = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              StdButton(
                text: '保存',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addNewModel(
                      _selectedModel!.friendlyName,
                      _callNameController.text,
                      selectedAbilities,
                    );
                    OverlayPortalService.hide(context);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Set<ApiAbility> selectedAbilities = {ApiAbility.textGenerate};

  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);
    if (_isAddingNewModel) {
      return const AddModelDialog();
    }
    if (_selectedModel != null) {
      return _confirmAdd();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '  选择一个模型',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: FutureBuilder(
              future: ApiDatabaseService.instance.getAllModels(),
              builder: (context, asyncSnapshot) {
                if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<String> modelName = [];
                for (var item in asyncSnapshot.data!) {
                  modelName.add(item.friendlyName);
                }
                return StdSearch(
                  searchItems: modelName,
                  itemBuilder: (BuildContext context, int index) {
                    return StdListTile(
                      title: Text(modelName[index]),
                      subtitle: Text(asyncSnapshot.data![index].family),
                      onTap: () {
                        setState(() {
                          _selectedModel = asyncSnapshot.data![index];
                        });
                      },
                    );
                  },
                  noResultPage: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('没有结果'),
                      const SizedBox(height: 20),
                      StdButton(
                        text: '创建一个新的模型',
                        onPressed: () {
                          setState(() {
                            _isAddingNewModel = true;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddModelDialog extends ConsumerStatefulWidget {
  const AddModelDialog({super.key});

  @override
  ConsumerState<AddModelDialog> createState() => _AddModelDialogState();
}

class _AddModelDialogState extends ConsumerState<AddModelDialog> {
  final modelNameController = TextEditingController();
  final modelFriendlyNameController = TextEditingController();
  final modelFamilyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  var oldString = '';
  var selectedAbilities = <ApiAbility>{ApiAbility.textGenerate};

  late ThemeConfig theme;

  @override
  void initState() {
    super.initState();
    modelNameController.addListener(syncAndUpdateFormField);
  }

  void syncAndUpdateFormField() {
    if (oldString == modelFriendlyNameController.text &&
        modelNameController.text != oldString) {
      modelFriendlyNameController.text = modelNameController.text;
      oldString = modelNameController.text;
    }
  }

  void _addModel() {
    if (_formKey.currentState!.validate()) {
      final as = ref.read(addApiState);
      final newModels = List<ModelsConfigData>.from(as.models)
        ..add(
          ModelsConfigData(
            callName: modelNameController.text,
            friendlyName: modelFriendlyNameController.text,
            abilities: selectedAbilities,
          ),
        );
      ref.read(addApiState.notifier).state = as.copyWith(models: newModels);
      _resetForm();
      OverlayPortalService.hide(context);
    }
  }

  void _resetForm() {
    modelNameController.clear();
    modelFriendlyNameController.clear();
    modelFamilyController.clear();
    oldString = '';
    selectedAbilities = {ApiAbility.textGenerate};
  }

  @override
  void dispose() {
    modelNameController.removeListener(syncAndUpdateFormField);
    modelNameController.dispose();
    modelFriendlyNameController.dispose();
    modelFamilyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '添加模型',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 9),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: modelNameController,
                      label: "模型调用名称",
                      hint: '请输入模型调用名称（例如：qwen/qwen-7b-chat）',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: modelFriendlyNameController,
                      label: "模型友好名",
                      hint: '请输入模型友好名（例如：Qwen 7B）',
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: modelFamilyController,
                      label: "模型家族",
                      hint: '请输入模型家族（例如：Qwen）',
                    ),
                    const SizedBox(height: 10),
                    _modelAbility(),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StdButton(
                color: theme.backgroundColor,
                child: const Text('取消'),
                onPressed: () {
                  _resetForm();
                  OverlayPortalService.hide(context);
                },
              ),
              const SizedBox(width: 8),
              StdButton(
                onPressed: _addModel,
                child: const Text('添加', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: theme.boxColor,
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              suffixIcon: IconButton(
                iconSize: 18,
                icon: const Icon(Icons.clear),
                onPressed: controller.clear,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入$label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _modelAbility() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("模型能力", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: ApiAbility.values.map((ability) {
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
              text: ability.name,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class AddIndicator extends ConsumerWidget {
  const AddIndicator({super.key});
  static const _animationDuration = Duration(milliseconds: 300);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var as = ref.watch(addApiState);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: as.isNameSet
          ? Center(
              key: ValueKey('logo_visible'),
              child: SizedBox(
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(height: 80, width: 80, child: FlutterLogo()),
                      Column(
                        children: [
                          _typeSet(context, as),
                          _endPointSet(context, as),
                          _apiKey(context, as),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SizedBox(key: ValueKey('logo_hidden'), height: 0),
    );
  }

  Widget _typeSet(BuildContext context, AddApiState as) {
    return SizedBox(
      width: 200,
      child: AnimatedSwitcher(
        key: ValueKey('type_set'),
        duration: _animationDuration,
        child: (as.isTypeSet)
            ? ListTile(
                dense: true,
                leading: Icon(Icons.check, color: Colors.green),
                title: Text(
                  '端点类型已设置',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${as.type}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            : null,
      ),
    );
  }

  Widget _endPointSet(BuildContext context, AddApiState as) {
    return SizedBox(
      width: 200,
      child: AnimatedSwitcher(
        key: ValueKey('endpoint_set'),
        duration: _animationDuration,
        child: (as.isEndPointSet)
            ? ListTile(
                dense: true,
                leading: Icon(Icons.check, color: Colors.green),
                title: Text(
                  '端点已设置',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${as.endPoint}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            : null,
      ),
    );
  }

  Widget _apiKey(BuildContext context, AddApiState as) {
    return SizedBox(
      width: 200,
      child: AnimatedSwitcher(
        key: ValueKey('api_key_set'),
        duration: _animationDuration,
        child: (as.isKeysSet)
            ? ListTile(
                dense: true,
                leading: Icon(Icons.check, color: Colors.green),
                title: Text(
                  'ApiKey已设置',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '共${as.keys?.length}个Key',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            : null,
      ),
    );
  }

  Widget _model(BuildContext context, AddApiState as) {
    return SizedBox(
      width: 200,
      child: AnimatedSwitcher(
        key: ValueKey('model_set'),
        duration: _animationDuration,
        child: (as.isModelsSet)
            ? ListTile(
                dense: true,
                leading: Icon(Icons.check, color: Colors.green),
                title: Text(
                  '模型已设置',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '共${as.models.length}个模型已添加',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            : null,
      ),
    );
  }
}
