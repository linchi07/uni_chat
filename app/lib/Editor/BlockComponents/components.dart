import 'package:uni_chat/Editor/Core/block_data.dart';
import 'package:uni_chat/Editor/Core/persistent_data_recorder.dart';
import 'package:uni_chat/Editor/Core/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Structures { single, array }

class DataType {
  final Structures structure;
  final Color color;
  final IconData icon;
  // 新增static map用于根据string值查找对应的data type
  static final Map<String, DataType> typeMap = {
    'string': DataType(Structures.single, Colors.amber, Icons.abc),
    'int': DataType(Structures.single, Colors.blue, Icons.numbers),
    'bool': DataType(Structures.single, Colors.red, Icons.rule),
    'json': DataType(Structures.single, Colors.green, Icons.data_object),
    'file': DataType(Structures.single, Colors.brown, Icons.folder_outlined),
    'image': DataType(Structures.single, Colors.cyan, Icons.image_outlined),
    'audio': DataType(Structures.single, Colors.pink, Icons.graphic_eq),
    'video': DataType(
      Structures.single,
      Colors.purple,
      Icons.videocam_outlined,
    ),
    'pdf': DataType(Structures.single, Colors.grey, Icons.picture_as_pdf),
    'string[]': DataType(Structures.array, Colors.amber, Icons.data_array),
    'int[]': DataType(Structures.array, Colors.blue, Icons.data_array),
  };

  DataType(this.structure, this.color, this.icon);

  // 根据string值获取对应的DataType实例
  static DataType fromString(String typeString) {
    return typeMap[typeString] ??
        DataType(Structures.single, Colors.black, Icons.error);
  }
}

Widget varNameTextInPort(String varName) {
  return Text("  $varName", style: TextStyle(fontSize: 13));
}

Widget varNameTextOutPort(String varName) {
  return Text("$varName  ", style: TextStyle(fontSize: 13));
}

class DefaultOutPort extends StatelessWidget {
  final int bid;
  final int id;
  final dynamic params;
  const DefaultOutPort({
    super.key,
    required this.params,
    required this.bid,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    String portName = params["name"];
    String datatype = params["type"];
    return LayoutId(
      id: id,
      child: SizedBox(
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            varNameTextOutPort(portName),
            const SizedBox(height: 2),
            TypeIndicator(type: datatype),
          ],
        ),
      ),
    );
  }
}

class TypeIndicator extends StatelessWidget {
  final String type;
  const TypeIndicator({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    var dt = DataType.fromString(type);
    return Container(
      height: 30,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 19,
            width: 19,
            decoration: BoxDecoration(
              color: dt.color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(dt.icon, color: Colors.white, size: 15),
          ),
          const SizedBox(width: 5),
          Text(
            type,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class StringPort extends ConsumerWidget {
  final int bid;
  final int id;
  final dynamic params;
  StringPort({
    super.key,
    required this.params,
    required this.bid,
    required this.id,
  });

  BuildContext? _textboxContext;
  OverlayEntry? _overlayEntry;
  WidgetRef? _ref;

  void _showOverLay() {
    if (_textboxContext == null) return;
    var context = _textboxContext!;
    var renderBox = context.findRenderObject() as RenderBox;
    var eci = _ref!.read(editorControllerInstance);
    var size = renderBox.size * eci.zoom;
    eci.receiveInput = false;
    var offset = renderBox.localToGlobal(Offset.zero);
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (_overlayEntry != null) {
                  _overlayEntry!.remove();
                  _overlayEntry = null;
                  _ref!.read(editorControllerInstance).receiveInput = true;
                }
              },
              onPanStart: (details) {
                  //在用户尝试拖画布的时候也关掉
                if (_overlayEntry != null) {
                  _overlayEntry!.remove();
                  _overlayEntry = null;
                  _ref!.read(editorControllerInstance).receiveInput = true;
                }
              },
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy,
                child: Container(
                  height: size.height,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: OverlayTextField(zoom: eci.zoom,overlayEntry: _overlayEntry,componentId: (bid,id),),
                ),
              ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String textBoxText = params["textBoxHintText"] ?? "";
    _ref = ref;
    return LayoutId(
      id: id,
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          ref.listen(
            //这里的$2就是hitComponent，框架限制就是这样
            blockComponentNotifier(bid).select((state) => state.hitComponent[id]),
            (previousValue, nextValue) {
              // 当状态从 true 变为 false 时，执行一次性逻辑
              if (nextValue!.$1 == true) {
                ref.read(blockComponentNotifier(bid).notifier).rogerHit(id);
                _showOverLay();
              }
            },
          );
          var ci = ref.watch(blockComponentNotifier(bid).select((state)=>state.componentsInfo[id]));
          if(ci != null&&ci.type == RecordDataType.string){
            textBoxText = ci.value;
          }
          return SizedBox(
            width: 180,
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                varNameTextInPort(params["varName"]),
                const SizedBox(height: 2),
                TextBox(
                  text: textBoxText,
                  passContext: (c) => _textboxContext = c,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TextBox extends StatelessWidget {
  final String text;
  final void Function(BuildContext) passContext;
  const TextBox({super.key, required this.text, required this.passContext});

  @override
  Widget build(BuildContext context) {
    passContext(context);
    return Container(
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: Center(child: Text(text)),
    );
  }
}

///我必须吹爆Gemini，太强了！！！！！我就负责拷贝黏贴就好了
///之所以要转门做一个输入框，是因为textField会在这里出现光标错位的问题，Cupertino也会有类似的问题
class OverlayTextField extends ConsumerStatefulWidget {
  final double zoom;
  final (int,int)? componentId;
  final OverlayEntry? overlayEntry;
  final EdgeInsetsGeometry? padding;
  final TextAlign? textAlign;
  final TextStyle? style;
  const OverlayTextField({
    super.key,
    this.componentId,
    required this.zoom,
    this.padding,
    this.textAlign, this.style, required this.overlayEntry,
  });

  @override
  ConsumerState<OverlayTextField> createState() => _OverlayTextFieldState();
}

class _OverlayTextFieldState extends ConsumerState<OverlayTextField>
    implements TextSelectionGestureDetectorBuilderDelegate {
  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get forcePressEnabled => false; // 桌面端不需要压力感应

  @override
  bool get selectionEnabled => true; // 我们当然要允许选择

  // --- 其他你需要的状态 ---
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // 声明一个 builder 变量
  late final TextSelectionGestureDetectorBuilder
  _selectionGestureDetectorBuilder;

  @override
  void initState() {
    super.initState();
    // 实例化 Builder，并把 state 自己 (this) 作为 delegate 传入
    _selectionGestureDetectorBuilder = TextSelectionGestureDetectorBuilder(
      delegate: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RecordDataType? dataType;
    if(widget.componentId != null){
      var text = ref.read(blockComponentNotifier(widget.componentId!.$1)).componentsInfo[widget.componentId!.$2];
      if(text != null){
        if(text.type==RecordDataType.string) {
          _controller.text = text.value;
          dataType = RecordDataType.string;
        }else if(text.type==RecordDataType.int){
          _controller.text = text.value.toString();
          dataType = RecordDataType.int;
        }
      }
    }
    var s = widget.style??TextStyle(fontSize: 14, color: Colors.black);
    s = s.copyWith(fontSize: (s.fontSize??14)*widget.zoom);
    _focusNode.requestFocus();
    return _selectionGestureDetectorBuilder.buildGestureDetector(
      // HitTestBehavior.translucent 确保即使在空白区域点击也能响应
      behavior: HitTestBehavior.translucent,
      child: Center(
        child: Padding(
          padding:
              widget.padding ??
              EdgeInsets.symmetric(horizontal: 8 * (widget.zoom)),
          child: EditableText(
            textAlign: widget.textAlign ?? TextAlign.center,
            // 关键：把你在 delegate 中定义的 GlobalKey 赋给 EditableText
            key: editableTextKey,
            controller: _controller,
            focusNode: _focusNode,
            onTapOutside: (value) {
              _focusNode.unfocus();
              if(_controller.text.isEmpty&&widget.componentId != null){
                ref.read(blockComponentNotifier(widget.componentId!.$1).notifier).updateComponentInfo(widget.componentId!.$2,DynamicWithType(null, RecordDataType.none));
                return;
              }
              if(widget.overlayEntry != null){
                widget.overlayEntry!.remove();
                ref.read(editorControllerInstance).receiveInput = true;
              }
            },
            onSubmitted: (value) {
              if(value.isEmpty&&widget.componentId != null){
                ref.read(blockComponentNotifier(widget.componentId!.$1).notifier).updateComponentInfo(widget.componentId!.$2,DynamicWithType(null, RecordDataType.none));
                return;
              }
              if(widget.componentId != null){
                if(dataType == null||dataType == RecordDataType.string) {
                  ref.read(blockComponentNotifier(widget.componentId!.$1).notifier).updateComponentInfo(widget.componentId!.$2, DynamicWithType(value, RecordDataType.string));
                }else if(dataType == RecordDataType.int){
                  ref.read(blockComponentNotifier(widget.componentId!.$1).notifier).updateComponentInfo(widget.componentId!.$2, DynamicWithType(int.parse(value), RecordDataType.int));
                }
              }
              if(widget.overlayEntry != null){
                widget.overlayEntry!.remove();
                ref.read(editorControllerInstance).receiveInput = true;
              }
            },
            // 其他基本配置
            style: s,
            cursorColor: Colors.blue,
            backgroundCursorColor: Colors.grey,
            selectionColor: Colors.blue.withAlpha(100),

            // 注意：这里我们不再需要 selectionControls，因为手势和菜单现在由
            // TextSelectionGestureDetector 和 contextMenuBuilder (如果需要) 管理
          ),
        ),
      ),
    );
  }
}

class BoolPort extends StatefulWidget {
  final int bid;
  final int id;
  final dynamic params;

  const BoolPort({
    super.key,
    required this.params,
    required this.id,
    required this.bid,
  });

  @override
  State<BoolPort> createState() => _BoolPortState();
}

class _BoolPortState extends State<BoolPort> {
  bool? _value;

  void toggle(bool value,BlockComponentNotifier? bcn) {
      setState(() {
        _value = value;
      });
      if(bcn != null) {
        bcn.updateComponentInfoNoTrigger(widget.id, DynamicWithType(_value!, RecordDataType.bool));
      }
  }
  
  @override
  void initState() {
    super.initState();
    _value ??= (widget.params["initialValue"]??false);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutId(
      id: widget.id,
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          ref.listen(
            //这里的$2就是hitComponent，框架限制就是这样
            blockComponentNotifier(widget.bid).select((state) {
              return state.hitComponent[widget.id];
            }),
            (previousValue, nextValue) {
              // 当状态从 true 变为 false 时，执行一次性逻辑
              if (nextValue!.$1 == true) {
                var bcn = ref
                    .read(blockComponentNotifier(widget.bid).notifier);
                bcn.rogerHit(widget.id);
                toggle(!_value!,bcn);
              }
            },
          );
          ref.listen(blockComponentNotifier(widget.bid).select((state)=>state.componentsInfo[widget.id]), (previousValue, nextValue) {
            if (nextValue != null&& nextValue.type != RecordDataType.none && nextValue.value != _value ) {
              toggle(!_value!,null);
            }
          },);
          return child!;
        },
        child: SizedBox(
          height: 60,
          width: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              varNameTextInPort(widget.params["varName"]),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOutSine,
                height: 30,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _value! ? Colors.blue : Colors.grey[200],
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  alignment: _value!
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  curve: Curves.easeInOutQuad,
                  child: _switchKnob(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchKnob() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 1),
          ],
        ),
        height: 23,
        width: 20,
      ),
    );
  }
}

class IntPort extends ConsumerStatefulWidget {
  final int bid;
  final int id;
  final dynamic params;
  const IntPort({
    super.key,
    required this.bid,
    required this.id,
    required this.params,
  });

  @override
  ConsumerState<IntPort> createState() => _IntPortState();
}

class _IntPortState extends ConsumerState<IntPort> {
  int _value = 0;
  void add() {
      setState(() {
      _value++;
    });
      ref.read(blockComponentNotifier(widget.bid).notifier).updateComponentInfoNoTrigger(widget.id, DynamicWithType(_value, RecordDataType.int));
  }

  void minus() {
      setState(() {
        _value--;
      });
      ref.read(blockComponentNotifier(widget.bid).notifier).updateComponentInfoNoTrigger(widget.id, DynamicWithType(_value, RecordDataType.int));
  }

  void hitPending(Offset locPos) {
    if (locPos.dx < 27) {
      minus();
    } else if (locPos.dx > 73) {
      add();
    } else {
      _showOverLay();
    }
  }

  BuildContext? _textboxContext;
  OverlayEntry? _overlayEntry;

  void _showOverLay() {
    if (_textboxContext == null) return;
    var context = _textboxContext!;
    var renderBox = context.findRenderObject() as RenderBox;
    var eci = ref.read(editorControllerInstance);
    //这是因为这个数字的输入不是整个renderBox导致的,好在我们是固定pixel布局，可以直接硬编码
    var size = Size(46, renderBox.size.height) * eci.zoom;
    eci.receiveInput = false;
    var offset = renderBox.localToGlobal(Offset.zero);
    offset = offset.translate(27 * eci.zoom, 0);
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (_overlayEntry != null) {
                  _overlayEntry!.remove();
                  _overlayEntry = null;
                  ref.read(editorControllerInstance).receiveInput = true;
                }
              },
              onPanStart: (details) {
                //在用户尝试拖画布的时候也关掉
                if (_overlayEntry != null) {
                  _overlayEntry!.remove();
                  _overlayEntry = null;
                  ref.read(editorControllerInstance).receiveInput = true;
                }
              },
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy,
              child: SizedBox(
                height: size.height,
                width: size.width,
                child: Container(
                  color: Colors.grey[200],
                  child: OverlayTextField(
                    componentId: (widget.bid, widget.id),
                    overlayEntry: _overlayEntry,
                    zoom: eci.zoom,
                    padding: EdgeInsets.all(0),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }
  
  @override
  void initState() {
    super.initState();
    _value = widget.params["initialValue"]??_value;
    ref.read(blockComponentNotifier(widget.bid).notifier).updateComponentInfoNoTrigger(widget.id, DynamicWithType(_value, RecordDataType.int));
  }
  
  void changeValue(int value) {
    WidgetsBinding.instance.addPostFrameCallback((_){
      setState(() {
        _value = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutId(
      id: widget.id,
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          ref.listen(
            blockComponentNotifier(widget.bid).select((state) {
              return state.hitComponent[widget.id];
            }),
            (previousValue, nextValue) {
              // 当状态从 true 变为 false 时，执行一次性逻辑
              if (nextValue!.$1 == true) {
                hitPending(nextValue.$2);
                ref
                    .read(blockComponentNotifier(widget.bid).notifier)
                    .rogerHit(widget.id);
              }
            },
          );
          var ci = ref.watch(blockComponentNotifier(widget.bid).select((state)=>state.componentsInfo[widget.id]));
          if(ci != null&&ci.type == RecordDataType.int&&ci.value != _value){
              changeValue(ci.value);
          }else {
            ref.read(blockComponentNotifier(widget.bid).notifier).updateComponentInfoNoTrigger(widget.id, DynamicWithType(_value, RecordDataType.int));
          }
          return child!;
        },
        child: SizedBox(
          height: 60,
          width: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              varNameTextInPort(widget.params["varName"]),
              const SizedBox(height: 2),
              NumberInputBox(
                value: _value,
                setContext: (value) {
                  _textboxContext = value;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NumberInputBox extends StatelessWidget {
  final void Function(BuildContext) setContext;
  const NumberInputBox({
    super.key,
    required int value,
    required this.setContext,
  }) : _value = value;

  final int _value;

  @override
  Widget build(BuildContext context) {
    setContext(context);
    return Container(
      height: 30,
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Row(
        children: [
          Icon(Icons.remove, color: Colors.grey[600]),
          Expanded(child: Text(_value.toString(), textAlign: TextAlign.center,maxLines: 1,overflow: TextOverflow.ellipsis,)),
          Icon(Icons.add, color: Colors.grey[600]),
        ],
      ),
    );
  }
}
