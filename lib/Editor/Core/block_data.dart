import 'dart:math';
import 'dart:ui';

import 'package:uni_chat/Editor/Core/persistent_data_recorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../BlockComponents/components_layout_engine.dart';

///这里是和移动还有布局有关系的data
class BlockData { 
  final int bid;
  int layer = 0;
  Offset position = Offset.zero;//左上角
  //宽统一为300
  static const double width = 300.0;
  int height = 400;
  BlockConfig config = testBlockConfigs[Random().nextInt(3)];
  BlockData({required this.bid,required this.layer,required this.position});
  ///检测这个点是否在块内
  bool isInside(Offset point){
    return point.dx >= position.dx && point.dx <= position.dx + width && point.dy >= position.dy && point.dy <= position.dy + height;
  }
  ///检测这个点是否在端口和块的范围内
  bool isInsidePortRange(Offset point){
    //端口的范围是10，但是由于我们希望使用一个接近15px就吸附的效果，所以这里我们使用25
    return point.dx >= position.dx-25 && point.dx <= position.dx + width +25 && point.dy >= position.dy && point.dy <= position.dy + height;
  }
  
  ///检测这个点在块内部，还是输入端口，还是输出端口\n
  ///0代表内部，-1代表输入端口，1代表输出端口\n
  ///！注意！必须配合[isInsidePortRange]或者[isInside]使用，这两个必须是真才能用这个函数，因为他不检测y轴坐标！也不检测是否在端口和块的范围内！
  int isInsideBlock(Offset point){
    if(point.dx<position.dx){
      return -1;
    }else if(point.dx<position.dx+width){
      return 0;
    }else{
      return 1;
    }
  }
}


enum BType{
 control,
 llm,
}

class BlockType{
  final BType type;
  final Color color;
  BlockType({required this.type,required this.color});
  static BlockType control = BlockType(type: BType.control, color: Colors.blue); 
}

class BlockConfig{
  final String name;
  final BlockType type;
  final IconData icon;
  final String? description;
  final Map<String,dynamic> inPorts;
  final Map<String,dynamic> outPorts;
  BlockConfig(this.inPorts, this.outPorts, {required this.name,required this.type,required this.icon,this.description});
}



class BlockComponentNotifier extends FamilyNotifier<BlockComponentInfo, int> {
  @override
  BlockComponentInfo build(int bid) {
    return BlockComponentInfo(
      portConnection: {},
      hitComponent: {},
      componentsInfo:  {},
    );
  }
  
  Map<int,List<Port>> get portConnection{
    return state.portConnection;
  }
  Map<int,(bool,Offset)> get hitComponent{
    return state.hitComponent;
  }
  Map<int,DynamicWithType> get componentsInfo{
    return state.componentsInfo;
  }

// 更新 portConnection 的方法
void notifyAndUpdatePortConnection(int portId, Port connectedPort) {
  final newPortConnection = Map.of(state.portConnection); // 创建新的Map
  if (newPortConnection[portId] == null) {
    newPortConnection[portId] = <Port>[];
  }
  newPortConnection[portId]!.add(connectedPort);
  // 使用 copyWith 创建新的不可变状态对象
  state = state.copyWith(portConnection: newPortConnection); // 传入新的Map
}

  void rogerHit(int hid){
    final newHitComponent = Map.of(state.hitComponent);
    newHitComponent[hid] = (false, Offset.zero);
    state = state.copyWith(hitComponent: newHitComponent);
  }

  // 更新 hitComponent 的方法
  void notifyAndUpdateHitComponent(int id, bool hit, Offset hitLocPos) {
    final newHitComponent = Map.of(state.hitComponent);
    newHitComponent[id] = (hit, hitLocPos);
    state = state.copyWith(hitComponent: newHitComponent);
  }
  
  ///不触发listen和watch事件的刷新
  void updateComponentInfoNoTrigger(int id,DynamicWithType value){
    //这里就是要让他不触发监听器，否则会循环触发导致bug
    state.componentsInfo[id] =  value;
  }

  ///触发listen和watch事件的更新
  void updateComponentInfo(int id,DynamicWithType value){
    final newComponentInfo = Map.of(state.componentsInfo);
    newComponentInfo[id] = value;
    state = state.copyWith(componentsInfo: newComponentInfo);
  }
  
}
class BlockComponentInfo {
 Map<int, List<Port>> portConnection; // 建议将 int? 改为 bool
 Map<int, (bool, Offset)> hitComponent;
 Map<int,DynamicWithType> componentsInfo;

 BlockComponentInfo({this.portConnection = const {}, this.hitComponent = const {}, this.componentsInfo = const {}});

  // 创建一个新实例，并允许部分字段更新
  BlockComponentInfo copyWith({
    Map<int, List<Port>>? portConnection,
    Map<int, (bool, Offset)>? hitComponent,
    Map<int,DynamicWithType>? componentsInfo,
  }) {
    return BlockComponentInfo(
      portConnection: portConnection ?? this.portConnection,
      hitComponent: hitComponent ?? this.hitComponent,
      componentsInfo: componentsInfo ?? this.componentsInfo,
    );
  }
}



final List<BlockConfig> testBlockConfigs = [
  // 1. 一个简单的节点：一个字符串输入和一个默认输出
  BlockConfig(
      {
        "string": {
          "varName": "message",
          "textBoxHintText": "Enter a message",
        }
      },
      {
        "default": {
          "name": "result",
          "type": "string",
        }
      },
      name: "Simple Echo",
      type: BlockType.control,
      icon: Icons.chat,
      description: "Echoes the input string."
  ),

  // 2. 带有布尔值输入的节点
  BlockConfig(
      {
        "bool": {
          "varName": "enabled",
          "componentSize": ComponentSize.small,
        }
      },
      {
        "default": {
          "name": "status",
          "type": "bool",
        }
      },
      name: "Toggle Switch",
      type: BlockType.control,
      icon: Icons.toggle_on,
      description: "Toggles a boolean value."
  ),

  // 3. 混合输入和不同组件尺寸的复杂节点
  BlockConfig(
      {
        "string": {
          "varName": "Title",
          "textBoxHintText": "Block Title",
          "componentSize": ComponentSize.extraLarge,
        },
        "bool": {
          "varName": "is_active",
          "componentSize": ComponentSize.small,
        },
        "int": {
          "varName": "is_active",
          "componentSize": ComponentSize.fullLength,
        }
      },
      {
        "default": {
          "name": "output_string",
          "type": "string",
        }
      },
      name: "Mixed Ports",
      type: BlockType.control,
      icon: Icons.merge_type,
      description: "Combines a string and a boolean input."
  ),
];
