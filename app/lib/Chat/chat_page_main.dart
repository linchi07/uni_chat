import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/Chat/chat_panel.dart';
import 'package:uni_chat/Chat/chat_state.dart';
import 'package:uni_chat/Chat/panels/panel_data.dart';
import 'package:uni_chat/Chat/panels/panel_layout_engine.dart';
import 'package:uni_chat/developer_tools/message_bubble_previewer.dart';
import 'package:uni_chat/developer_tools/uiql_previewer.dart';
import 'package:uni_chat/utils/database_service.dart';
import 'package:uni_chat/utils/images.dart';
import 'package:uuid/uuid.dart';

import '../generated/l10n.dart';
import 'chat_models.dart';

class ChatPageMain extends ConsumerStatefulWidget {
  const ChatPageMain({super.key});

  @override
  ConsumerState<ChatPageMain> createState() => _ChatPageMainState();
}

class _ChatPageMainState extends ConsumerState<ChatPageMain> {
  bool _isDebugUiql = false;

  void updateLayout(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var rb = context.findRenderObject() as RenderBox;
      if (!rb.hasSize) return;
      var lcp = ref.read(layoutConfigProvider.notifier);
      lcp.state = lcp.state.copyWith(
        //这里很绕，第一个是横轴的总像素
        horizontalAxisActualPixels: rb.size.width - 450,
        //第二个是纵轴的总像素
        verticalAxisActualPixels: rb.size.height,
        //这里需要注意的是，纵轴的宽是200，所以实际上是横轴的总像素量除以200得到纵轴的行数
        maxVerticalAxisCount: (rb.size.width - 450) ~/ 200,
        //这里也一样，很绕
        horizontalAxisCount:
            (rb.size.height) ~/ 100 - 1, //这里减掉，因为是按照top来定位的，所以会多一行
      );
    });
  }

  bool bubbleDebug = false;
  @override
  Widget build(BuildContext context) {
    var currentSession = ref.watch(chatStateProvider.select((s) => s.session));
    if (currentSession == null) {
      return ChatPanelWhenNoSession();
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        updateLayout(context);
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              height: 40,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(child: SizedBox()),
                  Text(
                    bubbleDebug ? "ChatBubble Preview Mode" : "Chat Mode",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: bubbleDebug,
                    onChanged: (value) {
                      if (!value) {
                        ref.read(panelManager).clear();
                      }
                      setState(() {
                        bubbleDebug = value;
                      });
                    },
                  ),
                  Text(
                    _isDebugUiql ? "UIQL Preview Mode" : "Chat Mode",
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isDebugUiql,
                    onChanged: (value) {
                      if (!value) {
                        ref.read(panelManager).clear();
                      }
                      setState(() {
                        _isDebugUiql = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: (bubbleDebug)
                  ? MessageBubblePreviewer()
                  : _isDebugUiql
                  ? const UIQLPreviewer()
                  : ChatPanel(),
            ),
          ],
        );
      },
    );
  }
}

final stackRefreshNotifier = StateProvider<bool>((ref) {
  return false;
});

final summaryTriggerProvider = StateProvider<bool>((ref) {
  return false;
});

final editModeProvider = StateProvider<bool>((ref) {
  return false;
});

class PanelLayout extends ConsumerWidget {
  const PanelLayout({super.key});

  ///在构建完毕之后才执行函数
  void executeFunction(WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(panelManager).executeFunction();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var config = ref.watch(layoutConfigProvider);
    ref.watch(stackRefreshNotifier);
    var plep = ref.watch(panelLayoutEngineProvider);
    final isEditMode = ref.watch(editModeProvider);
    executeFunction(ref);
    var w = config.verticalAxisPixelPerUnit * config.verticalAxisCount;
    var outW = min(
      w,
      config.maxVerticalAxisCount * config.verticalAxisPixelPerUnit,
    );
    outW.isNaN ? outW = 0 : null;
    w.isNaN ? w = 0 : null;
    if (plep.isLayoutInvalid) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.yellow,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                S.of(context).window_too_small_to_display_allPanels,
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.aspect_ratio),
                label: Text(S.of(context).auto_shrink_large_panel),
                onPressed: () {
                  // 调用引擎中的新方法来修复面板尺寸
                  plep.shrinkAllOversizedPanels();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                S.of(context).or_expand_window,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }
    return AnimatedContainer(
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 200),
      width: outW + 18,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: AnimatedContainer(
          margin: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(),
          width: w,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 200),
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (isEditMode) {
                    ref.read(editModeProvider.notifier).state = false;
                  }
                },
                onLongPress: () {
                  ref.read(editModeProvider.notifier).state = true;
                },
              ),
              ...plep.panels.values,
              if (isEditMode)
                Positioned(
                  top: 10,
                  right: 10,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(editModeProvider.notifier).state = false;
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.all(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.done, color: Colors.white),
                        const SizedBox(width: 2),
                        Text(
                          S.of(context).finish_edit,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef PanelFunction = void Function(Map<String, String>);

final panelManager = Provider<PanelManager>((ref) {
  return PanelManager(ref: ref);
});

///管理所有的面板并负责与UIQL解释器和布局引擎以及大模型交互
class PanelManager {
  late Ref _ref;
  PanelManager({required Ref ref}) {
    _ref = ref;
    _ref.listen(editModeProvider, (p, n) async {
      //此处的监听是为了确保在编辑模式下保存布局
      if (p != null && p && !n) {
        var l = saveToJson();
        if (l != null) {
          var id = _ref.read(chatStateProvider).session?.id;
          if (id != null) {
            await DatabaseService.instance.writeLayout(id, l);
          }
        }
      }
    });
  }
  Set<String> panels = {};
  //只不过是防止重复创建的问题，并且支持穷举删除,真正的数据都在panelDataProvider
  Map<String, String> bindPrompts = {};
  Map<String, int> bindingRefCount = {};
  //存在这种情况：
  // llm创建了一个bind，但是他没有创建一个接受了这个bind的panel，这时候他会一直留在内存中，而不是像正常的bind那样消费者删除了，他也就没了
  // 虽然我觉得一些字符串应该不至于造成内存泄露,但是这里还是上了引用计数

  Map<String, String> variables = {};

  void create(String name, String type, Map<String, String>? params) {
    //之所以这么做，是因为我们如果仔细看解析器的代码，在模型使用create SET的时候，他会不停的调用create方法。
    //因此需要避免重复创建面板，只是更新参数
    if (!panels.contains(name)) {
      _ref.read(panelLayoutEngineProvider).placePanel(name, type);
      panels.add(name);
    }
    updateParams(name, params);
    _ref.read(stackRefreshNotifier.notifier).state ^= true;
  }

  void drop(List<String> names) {
    for (var name in names) {
      var r = _ref.read(panelDataProvider(name)).resource;
      for (var p in r.promptBindings) {
        var brc = bindingRefCount[p];
        if (brc != null) {
          if (brc == 1) {
            bindPrompts.remove(p);
            bindingRefCount.remove(p);
          } else {
            bindingRefCount[p] = brc - 1;
          }
        }
      }
      _ref.read(panelLayoutEngineProvider).dropPanel(name);
      _ref.read(stackRefreshNotifier.notifier).state ^= true;
      panels.remove(name);
    }
  }

  void update(String name, Map<String, String>? params) {
    updateParams(name, params);
  }

  void bind(String name, String prompt) {
    bindPrompts[name] = prompt;
    /*
    if (bindingRefCount[name] == null) {
      bindingRefCount[name] = 1;
    } else {
      bindingRefCount[name] = bindingRefCount[name]! + 1;
    }*/
  }

  ///当一个action被注册之后，按钮或者类似的发生器会在产生事件的时候调用这个方法给llm发送预设提示词。
  static void onBindActionCalled(String actionName, WidgetRef ref) {
    var instance = ref.read(panelManager);
    var action = instance.bindPrompts[actionName];
    if (action != null) {
      action = instance.replaceVariables(action);
      ref.read(chatStateProvider.notifier).sendMessage(action);
    }
  }

  ///占位符的替换，如果没有注册该变量的话，则返回原字符串。
  String replaceVariables(String text) {
    final RegExp regex = RegExp(r'\{\{([\w.]+)\}\}');
    // 使用 replaceAllMapped 方法进行替换
    return text.replaceAllMapped(regex, (Match m) {
      // 匹配到的完整字符串，例如 "{{panelName.varName}}"
      String fullMatch = m.group(0)!;

      // 提取出大括号内的变量名，例如 "name"
      String variableName = m.group(1)!;

      // 根据变量名从数据中查找对应的值
      // 如果找到了，就用值来替换；如果没找到，就保持原样
      return variables[variableName] ?? fullMatch;
    });
  }

  static void onVariableUpdate(
    String panelName,
    String variableName,
    WidgetRef ref,
    String newValue,
  ) {
    var instance = ref.read(panelManager);
    instance.variables["$panelName.$variableName"] = newValue;
  }

  List<(String, String, Map<String, String>)> panelFunctions = [];

  ///执行函数
  void select(String panelName, String fName, Map<String, String> params) {
    panelFunctions.add((panelName, fName, params));
  }

  ///真正执行函数，这主要是由于一个问题， riverpod他的watch是在下一帧来重新构建，但是我们的解析可能在这一帧就解析select。此时由于widget
  ///并没有被构建，函数没有注册，是无法执行的。所以这里是加入到列表中，下一帧再执行。（通过add post frame callback）
  void executeFunction() {
    for (var f in panelFunctions) {
      var panelName = f.$1;
      var fName = f.$2;
      var params = f.$3;
      var panelData = _ref.read(panelDataProvider(panelName));
      var functions = panelData.functions;
      if (functions.containsKey(fName)) {
        functions[fName]!(params);
      }
    }
    panelFunctions.clear();
  }

  Map<String, (String, List<Base64Image>?)> panelSummary = {};
  List<FormattedChatMessage>? triggerPanelSummary() {
    panelSummary.clear();
    _ref.read(summaryTriggerProvider.notifier).state ^= true;
    if (panelSummary.isEmpty) {
      return null;
    }
    List<FormattedChatMessage> panelPrompt = [];
    //这里是一个阻塞的过程，他是同步调用的，所以可以确保我们在set之后map里面就有数据了
    panelPrompt.add(
      FormattedChatMessage(
        type: ChatMessageType.text,
        id: Uuid().v4(),
        sender: MessageSender.system,
        content:
            "以下是当前界面上的面板最新状态，用户可能对面板进行操作所以面板状态可能与创建时不同，甚至部分面板可能被删除，请优先使用这些给定的信息而不是依赖历史聊天记录中的UIQL代码。"
            "（若历史消息中存在以下信息没有给出的面板，则该面板可能被用户删除，不要尝试修改这些面板）",
      ),
    );
    for (var p in panelSummary.entries) {
      var s = "面板名称: ${p.key},面板信息：${p.value.$1}";
      panelPrompt.add(
        FormattedChatMessage(
          type: ChatMessageType.text,
          id: Uuid().v4(),
          sender: MessageSender.system,
          content: s,
        ),
      );
      if (p.value.$2 != null) {
        for (var i = 0; i < p.value.$2!.length; i++) {
          panelPrompt.add(
            FormattedChatMessage(
              type: ChatMessageType.base64Image,
              id: Uuid().v4(),
              sender: MessageSender.system,
              content: p.value.$2![i].base64Image,
              mimeType: p.value.$2![i].mimeType,
            ),
          );
        }
      }
    }
    panelPrompt.add(
      FormattedChatMessage(
        type: ChatMessageType.text,
        id: Uuid().v4(),
        sender: MessageSender.system,
        content: "以上是面板信息，接下来请完成用户请求",
      ),
    );
    return panelPrompt;
  }

  void collectPanelSummary(
    String panelName,
    (String, List<Base64Image>?) summary,
  ) {
    panelSummary[panelName] = summary;
  }

  void clear() {
    for (var p in panels) {
      /*
      var r = _ref.read(panelDataProvider(p)).resource;
      for (var p in r.promptBindings) {
        var brc = bindingRefCount[p];
        if (brc != null) {
          if (brc == 1) {
            bindPrompts.remove(p);
            bindingRefCount.remove(p);
          } else {
            bindingRefCount[p] = brc - 1;
          }
        }
      }*/
      _ref.read(panelLayoutEngineProvider).dropPanel(p);
    }
    panels.clear();
    _ref.read(stackRefreshNotifier.notifier).state ^= true;
  }

  void updateParams(String name, Map<String, String>? params) {
    var n = _ref.read(panelDataProvider(name).notifier);
    n.state = n.state.copyWith(props: {...n.state.props, ...?params});
  }

  void relayoutFromJson(String jsonData) {
    var ple = _ref.read(panelLayoutEngineProvider);
    clear();
    ple.clearSpace();
    int curPanelIndex = 0;
    var data = jsonDecode(jsonData);
    //这就是我觉得dart最糖的地方，md 管的特别多，json的序列化基本上都会出这个问题 dynamic 就是不让直接转换为string，你可以警告，但是不能给我throw啊
    //包括stful widget的变量初始化也是的，就这种细枝末节的事情特别讨厌。
    var dynamicMap = data['bindPrompts'] as Map<String, dynamic>?;
    if (dynamicMap != null) {
      bindPrompts = dynamicMap.cast<String, String>();
    } else {
      bindPrompts = {};
    }
    var lo = (data['panels'] as List<dynamic>?) ?? [];
    //这里也是的，这种傻逼地方严格，真的是脑瘫。json序列化本身就没有人家c#好，还给我整这种事情，劳资不知道多少次在这里踩坑了。
    for (var p in lo) {
      var l = Layout.fromJson(p['layout'], ple);
      if (l.id > curPanelIndex) {
        curPanelIndex = l.id;
      }
      var panelData = PanelData.fromJson(p['panelData'], l);
      if (!ple.relayoutPanel(l, panelData.name, panelData.type)) {
        continue;
        //实在放不下就不要放了。。
      }
      ple.currentPanelIndex = ++curPanelIndex;
      _ref.read(panelDataProvider(panelData.name).notifier).state = panelData;
      panels.add(panelData.name);
    }
  }

  String? saveToJson() {
    if (panels.isEmpty) {
      return null;
    }
    List<Map<String, dynamic>> panelsToSave = [];
    for (var p in panels) {
      var panelData = _ref.read(panelDataProvider(p));
      var l = panelData.layout.toJson();
      var pd = panelData.toJson();
      panelsToSave.add({'layout': l, 'panelData': pd});
    }
    Map<String, dynamic> data = {
      'bindPrompts': bindPrompts,
      'panels': panelsToSave,
    };
    return jsonEncode(data);
  }
}
