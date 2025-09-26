import 'package:uni_chat/Chat/chat_page_main.dart';
import 'package:uni_chat/Chat/panels/basic_pannel.dart';
import 'package:uni_chat/Chat/panels/constant_value_indexer.dart';
import 'package:uni_chat/Chat/panels/panel_data.dart';
import 'package:uni_chat/utils/code/src/code_field/text_selection.dart';
import 'package:uni_chat/utils/file_utils.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
//注意！这里我们直接从github上把这个包源码扒拉下来改了一下
//因为这个包的某些原因不能输入中文。。。。 github issue上有人提的
//好在这个作者很友好的使用了相对路径命名
//所以不用全局替换依赖了
//所以我究竟是要吐槽这个作者不修bug还是夸他相对路径命名让我很好魔改呢？
import 'package:uni_chat/utils/code/flutter_code_editor.dart' as ce;
import 'package:flutter_riverpod/src/consumer.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/dart.dart';

import '../../../utils/base64_image.dart';

class TextPanel extends BasicPanel {
  TextPanel({super.key, required super.name});

  @override
  (String, List<Base64Image>?) panelSummary(PanelData data) {
    var text = data.props['text'] ?? '';
    var s = (text.isNotEmpty && text != "")
        ? "该面板现在显示的内容是：\n$text"
        : "该面板现在没有显示任何文字内容";
    return (s, null);
  }

  @override
  Widget buildInternal(BuildContext context, WidgetRef ref, PanelData data) {
    var text = data.props['text'] ?? '';
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(child: Text(text, style: const TextStyle(fontSize: 18))),
    );
  }
}

class ButtonPanel extends BasicPanel {
  ButtonPanel({super.key, required super.name});
  @override
  (String, List<Base64Image>?) panelSummary(PanelData data) {
    var text = data.props['text'];
    var action = data.props['onPressed'];
    var s = (text != null && text.isNotEmpty)
        ? "该按钮现在显示的内容是：\n$text"
        : "该按钮现在没有显示任何文字内容";
    s = (action != null && action.isNotEmpty)
        ? "$s\n该按钮现在绑定的操作名称是：\n$action"
        : "s\n该按钮现在没有绑定任何操作";
    return (s, null);
  }

  @override
  Widget buildInternal(BuildContext context, WidgetRef ref, PanelData data) {
    var text = data.props['text'] ?? '';
    var action = data.props['onPressed'];
    if (action != null && !data.resource.promptBindings.contains(action)) {
      data.resource.promptBindings.add(action);
    }
    var color = ColorParser.parseColor(data.props['color']) ?? Colors.blue;
    return Material(
      clipBehavior: Clip.hardEdge,
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: action == null
            ? null
            : () {
                PanelManager.onBindActionCalled(action, ref);
              },
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: ColorParser.textColor(color), fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class MarkDownPanel extends BasicPanel {
  MarkDownPanel({super.key, required super.name});
  @override
  (String, List<Base64Image>?) panelSummary(PanelData data) {
    var text = data.props['text'];
    var s = (text != null && text.isNotEmpty)
        ? "该面板现在显示的MARK_DOWN是：\n$text"
        : "该面板现在没有显示任何MARK_DOWN内容";
    return (s, null);
  }

  @override
  Widget buildInternal(BuildContext context, WidgetRef ref, PanelData data) {
    var text = data.props['text'] ?? '';
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GptMarkdown(text),
    );
  }
}

class TextFieldPanel extends BasicPanel {
  TextFieldPanel({super.key, required super.name});
  
  @override
  (String, List<Base64Image>?) panelSummary(PanelData data) {
    var i = data.props['inputValueName'];
    var s = (i != null && i.isNotEmpty)
        ? "该面板现在绑定的输入变量名是：\n$i"
        : "该面板现在没有绑定任何输入变量";
    var input = data.props['input'];
    s = (input != null && input.isNotEmpty)
        ? "$s\n该面板现在的输入内容是：\n$input"
        : "s\n该面板现在没有输入任何内容";
    return (s, null);
  }
  
  

  @override
  Widget buildInternal(BuildContext context, WidgetRef ref, PanelData data) {
    var textVarName = data.props['inputValueName'];
    if (textVarName != null && !data.resource.variables.contains(textVarName)) {
      data.resource.variables.add(textVarName);
    }
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextFieldMainContent(data: data,),
    );
  }
}

class TextFieldMainContent extends ConsumerStatefulWidget {
  const TextFieldMainContent({
    super.key,
    required this.data,
  });

  final PanelData data;

  @override
  ConsumerState<TextFieldMainContent> createState() => _TextFieldMainContentState();
}

class _TextFieldMainContentState extends ConsumerState<TextFieldMainContent> {
  late TextEditingController textController;
  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    textController.addListener(onTextChanged);
  }
  
  void onTextChanged() {
    var text = textController.text;
    var textVarName = widget.data.props['inputValueName'];
    if (text.isNotEmpty && textVarName != null&&widget.data.props['input'] != text) {
      widget.data.props['input'] = text;
      PanelManager.onVariableUpdate(widget.data.name, textVarName, ref, text);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    var hText = widget.data.props['hintText'] ?? '';
    var textVarName = widget.data.props['inputValueName'];
    return TextField(
      controller: textController,
      decoration: InputDecoration.collapsed(hintText: hText),
      onSubmitted: (value) {
        if (value.isNotEmpty && textVarName != null) {
          widget.data.props['input'] = value;
          PanelManager.onVariableUpdate(widget.data.name, textVarName, ref, value);
        }
      },
    );
  }
}

class CodePanel extends BasicPanel {
  CodePanel({super.key, required super.name});
  @override
  (String, List<Base64Image>?) panelSummary(PanelData data) {
    var name = data.props['projectName'];
    var code = data.props['code'];
    var selection = data.props['selection'];
    var language = data.props['language'];
    String s = name == null ? "该面板现在没有项目名" : "该面板现在的项目名是：\n$name";
    s = language == null ? "$s 该面板现在没有指定编程语言，如果你能推断出编程语言，请填写。" : "$s 该面板现在使用的语言是：\n$language";
    s = code == null ? "$s 该面板现在没有任何代码" : "$s 该面板上的代码是：\n$code";
    s = selection == null ? s : "$s\n当前用户光标选中的代码片段是：\n$selection";
    return (s, null);
  }

  @override
  Widget buildInternal(BuildContext context, WidgetRef ref, PanelData data) {
    return CodePanelMainContent(
      parentData: data,
      key: ValueKey("${data.name}|1145141919810"),
    );
  }
}

class CodePanelMainContent extends ConsumerStatefulWidget {
  const CodePanelMainContent({required Key key, required this.parentData})
    : super(key: key);
  final PanelData parentData;
  @override
  ConsumerState<CodePanelMainContent> createState() => _CodePanelMainContentState();
}

class _CodePanelMainContentState extends ConsumerState<CodePanelMainContent> {
  late final ce.CodeController controller;
  late PanelData data;
  @override
  void initState() {
    super.initState();
    disableSave = true;
    controller = ce.CodeController();
    controller.addListener(codeChanged);
    //这里注意，stateful widget 貌似会破坏引用传递链，导致我这边没法修改父组件的props（实际上我测试下来hashcode是变化的）
  }

  (int, int)? selection;
  //这里必须控制，否则的话控制器会在我们把full text保存的时候触发保存，然后反而重置了props；
  //这里说一个灵异事件，我本来写的是enable Save = false 这样的设计，我初始化变量的时候，都是设置的false，但是他会自动变为true
  //而即使我把唯一一个会将其设置为true的函数注释掉他还是会自动设置为true。最后的解决之道是反转if！没错，反转if。。。。。
  bool disableSave = true;
  void codeChanged() {
    if (!disableSave && controller.fullText != data.props['code']) {
      data.props['code'] = controller.fullText;
    }else{
      disableSave = false;
    }

    bool isSelected = false;
    if (controller.selection.length != 0) {
      isSelected = true;
      data.props['selection'] = controller.fullText.substring(
        controller.selection.start,
        controller.selection.end,
      );
      var r = controller.getSelectedLineRange();
      selection = (r.start, r.end);
    }
    showSelectionState.value = (isSelected) ? selection : null;
  }
  
  void replaceCode(Map<String,String> param) {
    var oldString = param['oldString'];
    var newString = param['newString'];
    if (oldString != null && newString != null) {
      disableSave = true;
      data.props['code'] ??= '';
      data.props['code'] = data.props['code']!.replaceAll(oldString, newString);
      setState(() {

      });
    }
  }
  
  void appendCode(Map<String,String> param){
    var appendString = param['appendString'];
    if (appendString != null) {
      disableSave = true;
      data.props['code'] ??= '';
      data.props['code'] = data.props['code']! + appendString;
      setState(() {
        
      });
    }
  }

  // 添加一个状态来控制提示信息的显示
  // 这里使用value change是必须的，set state 会导致某些冲突问题
  final showSelectionState = ValueNotifier<(int, int)?>(null);
  final showCopiedState = ValueNotifier<bool>(false);
  @override
  Widget build(BuildContext context) {
    data = ref.read(panelDataProvider(widget.parentData.name));
    data.functions['replace'] = replaceCode;
    data.functions['append'] = appendCode;
    //注意一下，gpt markdown这个包用的也是flutter code editor，所以得防止冲突。。。。
    var projectName = data.props['projectName'] ?? '';
    var language = data.props['language'];
    controller.language = ce.LanguageMap.languageTypes[language?.toLowerCase()];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      disableSave = true;
      //注意这里要设置两次true，因为clear的时候会触发一次
      controller.clear();
      disableSave = true;
      controller.fullText = (data.props['code'] ?? '');
    });
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          height: 45,
          color: Colors.white,
          child: Row(
            children: [
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 70,
                ),
                padding: const EdgeInsets.symmetric(horizontal:  8,vertical: 2),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: TextEditingController(text: language?.toUpperCase()),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '类型',
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 16),
                  onSubmitted: (String value) {
                    language = value;
                    data.props['language'] = value;
                  },
                ),
              ),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: projectName),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '请输入文件名',
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 18),
                  onSubmitted: (String value) {
                    projectName = value;
                    data.props['projectName'] = value;
                  },
                ),
              ),
              if (selection != null)
                ValueListenableBuilder<(int, int)?>(
                  valueListenable: showSelectionState,
                  builder:
                      (BuildContext context, (int, int)? value, Widget? child) {
                        if (value == null) {
                          return SizedBox();
                        }
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[400],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            '通知Ai：选中 ${selection!.$1 + 1} - ${selection!.$2}行',
                          ),
                        );
                      },
                ),
              ValueListenableBuilder<bool>(
                valueListenable: showCopiedState,
                builder: (context, showCopied, child) {
                  return Row(
                    children: [
                      if (showCopied) ...[
                        Text('已拷贝', style: TextStyle(color: Colors.green)),
                        SizedBox(width: 8),
                      ],
                      IconButton(
                        onPressed: () async {
                          try {
                            //这里需要包裹一下，因为这个弱智包不让你拷贝空的剪切板
                            await FlutterClipboard.copy(controller.fullText);
                            // 显示"已拷贝"提示
                            showCopiedState.value = true;
                            // 延迟几秒后隐藏提示
                            Future.delayed(Duration(seconds: 3), () {
                              showCopiedState.value = false;
                            });
                          } catch (e) {
                            print(e);
                          }
                        },
                        icon: Icon(Icons.copy),
                      ),
                    ],
                  );
                },
              ),
              IconButton(
                onPressed: () async {
                  await FileUtils.saveTextToFile(
                    controller.fullText,
                    "${projectName == "" ? 'Untitled' : projectName}.${ce.LanguageMap.saveFiletype[language] ?? 'txt'}",
                  );
                },
                icon: Icon(Icons.save_outlined),
              ),
            ],
          ),
        ),
        Expanded(
          //见注释
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                color: Colors.grey[100],
                child: SingleChildScrollView(
                  child: Container(
                    constraints: constraints.copyWith(
                      minHeight: constraints.maxHeight,
                      maxHeight: double.infinity,
                    ),
                    child: ce.CodeField(
                      cursorColor: Colors.grey[600],
                      background: Colors.grey[100],
                      controller: controller,
                      gutterStyle: ce.GutterStyle(
                        width: 70,
                        margin: 0,
                        textAlign: TextAlign.right,
                      ),
                      textStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
