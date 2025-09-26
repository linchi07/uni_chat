import 'package:uni_chat/Chat/chat_page_main.dart';
import 'package:uni_chat/Chat/panels/panel_layout_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uni_chat/Chat/panels/panel_layout_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 管理面板数据
/// 经过测试之后发现，riverpod本身的状态管理机制会导致一些问题，比如我这里修改一个key的值之后他另一边读取一下没了
/// 而且我又不需要他通知watcher去刷新，所以用一个单例来手动管理更好一点。
class PanelPersistentDataManagerSingleton {
  // 私有构造函数
  PanelPersistentDataManagerSingleton._privateConstructor();

  // 静态实例
  static final PanelPersistentDataManagerSingleton _instance =
      PanelPersistentDataManagerSingleton._privateConstructor();

  // 工厂构造函数，总是返回同一个实例
  factory PanelPersistentDataManagerSingleton() {
    return _instance;
  }

  Map<String, Map<String, String>> panelsProps = {};
  Map<String, Map<String, PanelFunction>> panelsFunctions = {};
}

class PanelData {
  final String name;
  final String type;
  Layout layout;
  set props(Map<String, String> s) {
    PanelPersistentDataManagerSingleton().panelsProps[name] = s;
  }
  Map<String, String> get props {
    return PanelPersistentDataManagerSingleton().panelsProps[name] ?? {};
  }
  
  set functions(Map<String, PanelFunction> s) {
    PanelPersistentDataManagerSingleton().panelsFunctions[name] = s;
  }
  Map<String, PanelFunction> get functions {
    return PanelPersistentDataManagerSingleton().panelsFunctions[name] ?? {};
  }
  PanelResource resource = PanelResource();
  PanelData({
    required this.name,
    required this.type,
    required this.layout,
    Map<String, PanelFunction>? functions,
    Map<String, String>? props,
  }) {
    if (props != null) {
      this.props = props;
    } 
    //对于json而言
    // 不能加默认值，这里的读取是，首先props是被调用get 读到一个null ，然后json那边传过来的set再赋给singleton，然后再执行构造函数，此时props是null自然就会触发默认赋值然后就会给赋值一个空的map
    //此处的props是指的是props而不是this.props，而且这样不会有任何影响，因为singleton那边也会默认赋值一个空的map
    /*else {
      this.props = {};
    }*/
    if (functions != null) {
      this.functions = functions;
    } else {
      this.functions = {};
    }
  }

  // 新增 toJson 方法
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      // layout 被忽略，如要求所示
      'props': props,
      // functions 通常不序列化，因为它们是运行时的函数对象
      'type': type,
    };
  }

  // 新增 fromJson 工厂构造函数
  factory PanelData.fromJson(Map<String, dynamic> json, Layout layout) {
    return PanelData(
      name: json['name'] as String,
      type: json['type'] as String,
      layout: layout,
      props: Map<String, String>.from(json['props'] as Map),
      // functions 不从 json 恢复，因为它们是运行时定义的函数对象
    );
  }
  

  PanelData copyWith({
    String? name,
    Layout? layout,
    Map<String, String>? props,
    Map<String, PanelFunction>? functions,
    String? type,
  }) {
    //防止对象的引用被改变
    this.props.addAll(props ?? {});
    this.functions.addAll(functions ?? {});
    return PanelData(
      type: type ?? this.type,
      name: name ?? this.name,
      layout: layout ?? this.layout,
      props: this.props,
      functions: this.functions,
    );
  }

  void updateParams(Map<String, String>? params) {
    for (var param in params!.entries) {
      props[param.key] = param.value;
    }
  }
}

///记录面板申请的资源，方便释放
class PanelResource {
  List<String> promptBindings = [];
  List<String> variables = [];

  void addBinding(String binding) {
    if (!promptBindings.contains(binding)) {
      promptBindings.add(binding);
    }
  }

  void addVariable(String variable, WidgetRef ref) {
    if (!variables.contains(variable)) {
      variables.add(variable);
    }
  }
}

final panelDataProvider = StateProvider.family<PanelData, String>((ref, name) {
  // 这里可以根据name来返回不同的PanelData实例
  // 示例中简单地创建一个默认实例
  final defaultLayout = Layout(
    name: "",
    id: -1,
    height: 1,
    width: 1,
    layoutEngine: ref.read(panelLayoutEngineProvider),
  );
  return PanelData(name: name,type: "default", layout: defaultLayout);
});
