import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/Chat/panels/constant_value_indexer.dart';
import 'package:uni_chat/Persona/persona_provider.dart';
import 'package:uni_chat/utils/database_service.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:uni_chat/utils/tokenizer.dart';
import 'package:uuid/uuid.dart';

import '../theme_manager.dart';
import '../utils/dialog.dart';

class PersonaIndicator extends StatefulWidget {
  const PersonaIndicator({super.key});

  @override
  State<PersonaIndicator> createState() => _PersonaIndicatorState();
}

class _PersonaIndicatorState extends State<PersonaIndicator> {
  OverlayEntry? _overlayEntry;
  final GlobalKey<_PersonaSwitcherContainerState> _overlayKey = GlobalKey();

  void showPersonaSwitcher() {
    final overlay = Overlay.of(context);
    final rb = context.findRenderObject() as RenderBox;
    final pos = rb.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          ModalBarrier(color: Colors.transparent, onDismiss: hide),
          PersonaSwitcherContainer(
            onClose: hide,
            key: _overlayKey,
            initialSize: rb.size.longestSide,
            initPos: pos,
          ),
        ],
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void hide() {
    _overlayKey.currentState?.reverse().then((_) {
      if (_overlayEntry != null) {
        _overlayEntry?.remove();
        setState(() {
          _overlayEntry = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return (_overlayEntry != null)
        ? SizedBox.shrink()
        : Material(
            clipBehavior: Clip.antiAlias,
            color: Colors.transparent,
            shape: CircleBorder(
              side: BorderSide(color: Colors.black, width: 1.5),
            ),
            child: InkWell(
              onHover: (value) {},
              onTap: () {
                showPersonaSwitcher();
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.person),
              ),
            ),
          );
  }
}

class PersonaSwitcherContainer extends StatefulWidget {
  const PersonaSwitcherContainer({
    super.key,
    required this.initialSize,
    required this.initPos,
    required this.onClose,
  });
  final double initialSize;
  final Offset initPos;
  final dynamic onClose;

  @override
  State<PersonaSwitcherContainer> createState() =>
      _PersonaSwitcherContainerState();
}

class _PersonaSwitcherContainerState extends State<PersonaSwitcherContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _heightAnimation;
  late Animation<BorderRadius?> _borderRadiusAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  final double _finalWidth = 400.0;
  final double _finalHeight = 300.0;
  static Curve curve = Curves.easeInOutSine;
  @override
  void initState() {
    super.initState();

    // 1. 初始化 AnimationController
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // 2. 定义各个属性的 Tween
    // 宽度动画：从圆形直径到最终宽度
    _widthAnimation = Tween<double>(
      begin: widget.initialSize,
      end: _finalWidth,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _heightAnimation = Tween<double>(
      begin: widget.initialSize,
      end: _finalHeight,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    // 圆角动画：从圆形到圆角矩形
    _borderRadiusAnimation =
        BorderRadiusTween(
          begin: BorderRadius.circular(widget.initialSize / 2),
          end: BorderRadius.circular(15.0),
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );

    // 平移动画：向左平移
    _slideAnimation =
        Tween<double>(
          begin: 0,
          end: 60, //侧边栏的宽度是50，再来10作为间隙
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
        );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    // 3. 在第一帧渲染后立即启动动画
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 公开一个方法用于播放关闭动画
  Future<void> reverse() async {
    await _controller.reverse();
  }

  /// 公开一个方法用于播放展开动画
  void forward() {
    _controller.forward();
  }

  late ThemeConfig theme;
  @override
  Widget build(BuildContext context) {
    var s = MediaQuery.of(context).size;
    var initBottom = s.height - widget.initPos.dy - widget.initialSize;
    return Consumer(
      builder: (context, ref, child) {
        theme = ref.watch(themeProvider);
        return child!;
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Positioned(
            left: widget.initPos.dx + _slideAnimation.value,
            width: _widthAnimation.value,
            bottom: initBottom,
            height: _heightAnimation.value,
            child: OverlayPortalScope(
              child: Material(
                borderRadius: _borderRadiusAnimation.value,
                clipBehavior: Clip.hardEdge,
                color: theme.surfaceColor,
                elevation: 4,
                child: Center(
                  child: (_opacityAnimation.value >= 0.7)
                      ? Opacity(
                          opacity: _opacityAnimation.value,
                          child: PersonaSwitcher(onClose: widget.onClose),
                        )
                      : SizedBox.shrink(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PersonaSwitcher extends ConsumerStatefulWidget {
  const PersonaSwitcher({super.key, required this.onClose});
  final dynamic onClose;

  @override
  ConsumerState<PersonaSwitcher> createState() => _PersonaSwitcherState();
}

class _PersonaSwitcherState extends ConsumerState<PersonaSwitcher> {
  OverlayEntry? _overlayEntry;
  final GlobalKey<_PersonaEditorState> _personaSwitcherKey =
      GlobalKey<_PersonaEditorState>();
  void _showEditor(BuildContext context, {Persona? persona}) {
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 背景变暗和点击外部关闭
          ModalBarrier(
            color: Colors.black.withAlpha(80),
            onDismiss: () {
              _personaSwitcherKey.currentState?.handleClose();
            },
          ),
          OverlayPortalScope(
            child: PersonaEditor(
              persona: persona,
              key: _personaSwitcherKey,
              onClose: handleClose,
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void handleClose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  late ThemeConfig theme;
  Widget _popupMenu(Persona persona, BuildContext context) {
    return Material(
      elevation: 4.0,
      color: theme.surfaceColor,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: 150, // Set a reasonable width for the menu
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              leading: Icon(Icons.person),
              title: Text('设为默认'),
              onTap: () async {
                OverlayPortalService.hide(context);
                await DatabaseService.instance.setPersonaAsDefault(persona.id);
                var p = ref.read(personaProvider);
                if (persona.id == p.id) {
                  ref
                      .read(personaProvider.notifier)
                      .setPersona(persona.copyWith(isDefault: true));
                } else {
                  ref
                      .read(personaProvider.notifier)
                      .setPersona(p.copyWith(isDefault: false));
                }
              },
            ),
            ListTile(
              dense: true,
              leading: Icon(Icons.edit),
              title: Text('编辑'),
              onTap: () {
                _showEditor(context, persona: persona);
                OverlayPortalService.hide(context);
                widget.onClose();
              },
            ),
            ListTile(
              dense: true,
              iconColor: Colors.red,
              textColor: Colors.red,
              leading: Icon(Icons.delete),
              title: Text('删除(长按)'),
              onLongPress: () async {
                OverlayPortalService.hide(context);
                await DatabaseService.instance.deletePersona(persona.id);
                if (persona.id == ref.read(personaProvider).id) {
                  var p = await DatabaseService.instance.getDefaultPersona();
                  ref
                      .read(personaProvider.notifier)
                      .setPersona(
                        p ??
                            Persona(
                              id: Uuid().v4(),
                              name: "",
                              content: "",
                              data: {},
                            ),
                      );
                }
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPersonaListTile(Persona persona) {
    return ListTile(
      leading: FlutterLogo(),
      title: (persona.isDefault)
          ? Row(
              children: [
                Text(persona.name),
                const SizedBox(width: 5),
                Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  child: Text(
                    "默认",
                    style: TextStyle(
                      color: ColorParser.textColor(theme.primaryColor),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            )
          : Text(persona.name),
      onTap: () {
        ref.read(personaProvider.notifier).setPersona(persona);
        widget.onClose();
      },
      //此处的building是必须的，因为我们需要获得的render box是这个按钮的
      trailing: Builder(
        builder: (context) {
          return IconButton(
            icon: Icon(Icons.more_vert_outlined),
            onPressed: () {
              var rb = context.findRenderObject() as RenderBox;
              OverlayPortalService.show(
                context,
                barrierVisible: false,
                offset: rb.localToGlobal(Offset.zero).translate(40, 0),
                child: _popupMenu(persona, context),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildPersonaListItems(
    BuildContext context,
    List<Persona> personas,
    Persona selectedPersona,
  ) {
    List<Widget> items = [];
    for (var persona in personas) {
      if (persona.id != selectedPersona.id) {
        items.add(buildPersonaListTile(persona));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);
    return FutureBuilder(
      future: DatabaseService.instance.getAllPersonas(),
      builder: (context, asyncSnapshot) {
        var persona = ref.watch(personaProvider);
        if (!asyncSnapshot.hasData || asyncSnapshot.data == null) {
          return const CircularProgressIndicator();
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              StdListTile(
                leading: SizedBox(height: 40, width: 40, child: FlutterLogo()),
                title: (persona.isDefault)
                    ? Row(
                        children: [
                          Text(persona.name, style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 5),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            child: Text(
                              "默认",
                              style: TextStyle(
                                color: ColorParser.textColor(
                                  theme.primaryColor,
                                ),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(persona.name, style: TextStyle(fontSize: 18)),
                subtitle: Text(
                  persona.content,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {},
                trailing: Builder(
                  builder: (context) {
                    return IconButton(
                      icon: Icon(Icons.more_vert_outlined),
                      onPressed: () {
                        var rb = context.findRenderObject() as RenderBox;
                        OverlayPortalService.show(
                          context,
                          barrierVisible: false,
                          offset: rb
                              .localToGlobal(Offset.zero)
                              .translate(40, 0),
                          child: _popupMenu(persona, context),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text("切换身份", style: TextStyle(fontSize: 16)),
              Expanded(
                child: ListView(
                  children: _buildPersonaListItems(
                    context,
                    asyncSnapshot.data!,
                    persona,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      child: StdButton(
                        text: "Add Persona",
                        onPressed: () {
                          widget.onClose();
                          _showEditor(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class PersonaEditor extends StatefulWidget {
  const PersonaEditor({super.key, required this.onClose, this.persona});
  final dynamic onClose;
  final Persona? persona;
  @override
  State<PersonaEditor> createState() => _PersonaEditorState();
}

class _PersonaEditorState extends State<PersonaEditor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  @override
  void initState() {
    super.initState();

    // 初始化动画控制器和动画
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
    );

    // 使用 CurvedAnimation 让动画曲线更自然
    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
      reverseCurve: Curves.easeInQuart,
    );

    // 定义缩放和淡入淡出动画的具体数值范围
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(curvedAnimation);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curvedAnimation);

    // 启动进入动画
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 处理关闭事件：先反向播放动画，动画结束后再调用父级的onClose方法
  void handleClose() {
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
                    "确定要放弃更改吗？",
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
                      onPressed: () async {
                        close();
                      },
                      text: "确定",
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

  void close() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  late ThemeConfig theme;
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double targetWidth = screenSize.width * 0.65;
    final double targetHeight = screenSize.height * 0.75;

    // FadeTransition 和 ScaleTransition 组合实现进入和退出动画
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Center(
          // AnimatedContainer 用于实现尺寸变化的动画
          child: SizedBox(
            width: targetWidth,
            height: targetHeight,
            child: Consumer(
              builder: (context, ref, child) {
                theme = ref.watch(themeProvider);
                return child!;
              },
              child: PersonaEditorContent(
                onClose: close,
                persona:
                    widget.persona ??
                    Persona(id: Uuid().v4(), name: "", content: "", data: {}),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PersonaEditorContent extends ConsumerStatefulWidget {
  const PersonaEditorContent({
    super.key,
    required this.onClose,
    required this.persona,
  });
  final dynamic onClose;
  final Persona persona;

  @override
  ConsumerState<PersonaEditorContent> createState() =>
      _PersonaEditorContentState();
}

class _PersonaEditorContentState extends ConsumerState<PersonaEditorContent> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _entryNameController = TextEditingController();
  final TextEditingController _entryContentController = TextEditingController();

  final ValueNotifier<int> _tokenNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.persona.name;
    _descriptionController.text = widget.persona.content;
    personaData = widget.persona.data.values.toList();
  }

  @override
  void dispose() {
    _tokenNotifier.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget buildPersonaDataEntry(PersonaDataEntry entry) {
    return StdListTile(
      onTap: () {},
      title: Text(entry.name),
      subtitle: Text(entry.content),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              OverlayPortalService.show(
                context,
                child: _personaDataEntryEdit(entry),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                personaData.remove(entry);
              });
            },
          ),
        ],
      ),
    );
  }

  PersonaDataEntry? _entryAdding;

  Widget _personaDataEntryEdit(PersonaDataEntry entry) {
    // 在打开编辑器时，将当前条目数据填充到控制器中
    _entryNameController.text = entry.name;
    _entryContentController.text = entry.content;
    final formKey = GlobalKey<FormState>();
    return SizedBox(
      width: 400,
      height: 400,
      child: Material(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '编辑条目',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('名称', style: TextStyle(fontSize: 16)),
                StdTextFormField(
                  controller: _entryNameController,
                  hintText: '请输入名称',
                  validateFailureText: '请输入名称',
                ),
                const SizedBox(height: 16),
                Text('内容', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: StdTextFormField(
                    isExpanded: true,
                    controller: _entryContentController,
                    hintText: '请输入内容',
                    validateFailureText: '请输入内容',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StdButton(
                      color: theme.backgroundColor,
                      text: '取消',
                      onPressed: () {
                        // 清除控制器文本
                        _entryNameController.clear();
                        _entryContentController.clear();
                        OverlayPortalService.hide(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    StdButton(
                      text: '保存',
                      onPressed: () {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        // 更新条目数据
                        setState(() {
                          entry.name = _entryNameController.text;
                          entry.content = _entryContentController.text;
                        });
                        // 清除控制器文本
                        _entryNameController.clear();
                        _entryContentController.clear();
                        // 关闭弹窗
                        OverlayPortalService.hide(context);
                        _writeIn();
                      },
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

  void _writeIn() {
    setState(() {
      if (_entryAdding != null) {
        personaData.add(_entryAdding!);
        _entryAdding = null;
      }
    });
  }

  void calculateToken() {
    var oldToken = _tokenNotifier.value;
    int token = 0;
    for (var entry in personaData) {
      token += LLMTokenEstimator.estimateTokens(entry.name);
      token += LLMTokenEstimator.estimateTokens(entry.content);
    }
    token += LLMTokenEstimator.estimateTokens(_nameController.text);
    token += LLMTokenEstimator.estimateTokens(_descriptionController.text);
    if (token == oldToken) {
      return;
    }
    _tokenNotifier.value = token;
  }

  List<PersonaDataEntry> personaData = [];
  late ThemeConfig theme;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    theme = ref.watch(themeProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calculateToken();
    });
    return Material(
      borderRadius: BorderRadius.circular(8),
      color: theme.surfaceColor,
      clipBehavior: Clip.hardEdge,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                "编辑身份",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 200, child: FlutterLogo(size: 100)),
                          const SizedBox(height: 16),
                          StdTextFormField(
                            hintText: "请输入名称",
                            controller: _nameController,
                            validateFailureText: "请输入名称",
                            onChanged: (value) {
                              calculateToken();
                            },
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: StdTextFormField(
                              isExpanded: true,
                              hintText: "请介绍一下自己",
                              controller: _descriptionController,
                              validateFailureText: "请输入描述",
                              onChanged: (value) {
                                calculateToken();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 16),
                            Text(
                              '编辑记忆条目',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(child: const SizedBox(width: 16)),
                            StdButton(
                              text: "添加条目",
                              onPressed: () {
                                setState(() {
                                  _entryAdding = PersonaDataEntry(
                                    name: "",
                                    entryMode: PersonaEntryMode.alwaysInsert,
                                    content: "",
                                  );
                                });
                                OverlayPortalService.show(
                                  context,
                                  child: _personaDataEntryEdit(_entryAdding!),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: theme.backgroundColor,
                            ),
                            child: ListView.builder(
                              itemCount: personaData.length,
                              itemBuilder: (context, index) {
                                return buildPersonaDataEntry(
                                  personaData[index],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ValueListenableBuilder(
                  valueListenable: _tokenNotifier,
                  builder: (context, value, child) {
                    return Text(
                      "${_tokenNotifier.value} Tokens",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                StdCheckbox(
                  text: "设置为默认身份",
                  value: widget.persona.isDefault,
                  onChanged: (b) {
                    setState(() {
                      widget.persona.isDefault = b!;
                    });
                  },
                ),
                const SizedBox(width: 16),
                StdButton(
                  color: theme.backgroundColor,
                  text: "取消",
                  onPressed: () {
                    widget.onClose();
                  },
                ),
                const SizedBox(width: 8),
                StdButton(
                  text: "保存",
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _save();
                      widget.onClose();
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

  void _save() async {
    var pd = {for (var p in personaData) p.name: p};
    var p = widget.persona.copyWith(
      name: _nameController.text,
      content: _descriptionController.text,
      data: pd,
    );
    await DatabaseService.instance.createOrUpdatePersona(p);
    //此处provider也需要重新加载一下
    ref.read(personaProvider.notifier).setPersona(p);
  }
}
