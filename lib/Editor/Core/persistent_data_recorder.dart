import 'dart:ui';
import 'dart:convert';

import 'package:uni_chat/Editor/Core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RecordDataType {
  none,
  int,
  bool,
  string,
  listInt,
  listString,
  file,
  audio,
  image,
  video,
  pdf;

  @override
  String toString() {
    switch (this) {
      case RecordDataType.none:
        return 'none';
      case RecordDataType.int:
        return 'int';
      case RecordDataType.bool:
        return 'bool';
      case RecordDataType.string:
        return 'string';
      case RecordDataType.listInt:
        return 'listInt';
      case RecordDataType.listString:
        return 'listString';
      case RecordDataType.file:
        return 'file';
      case RecordDataType.audio:
        return 'audio';
      case RecordDataType.image:
        return 'image';
      case RecordDataType.video:
        return 'video';
      case RecordDataType.pdf:
        return 'pdf';
    }
  }

  static RecordDataType fromString(String value) {
    switch (value) {
      case 'none':
        return RecordDataType.none;
      case 'int':
        return RecordDataType.int;
      case 'bool':
        return RecordDataType.bool;
      case 'string':
        return RecordDataType.string;
      case 'listInt':
        return RecordDataType.listInt;
      case 'listString':
        return RecordDataType.listString;
      case 'file':
        return RecordDataType.file;
      case 'audio':
        return RecordDataType.audio;
      case 'image':
        return RecordDataType.image;
      case 'video':
        return RecordDataType.video;
      case 'pdf':
        return RecordDataType.pdf;
      default:
        return RecordDataType.none;
    }
  }
}

class DynamicWithType {
  final dynamic value;
  final RecordDataType type;

  DynamicWithType(this.value, this.type);

  // 新增方法
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'type': type.toString(),
    };
  }

  factory DynamicWithType.fromJson(Map<String, dynamic> json) {
    return DynamicWithType(
      json['value'],
      RecordDataType.fromString(json['type']),
    );
  }
}

class BlockLayoutData {
  final int bid;
  final Offset position;
  final int layoutIndex;
  final String? nickName;

  BlockLayoutData(this.bid, this.position, this.nickName, this.layoutIndex);

  // 新增方法
  Map<String, dynamic> toJson() {
    return {
      'bid': bid,
      'position': {'dx': position.dx, 'dy': position.dy},
      'nickName': nickName,
      'layoutIndex': layoutIndex,
    };
  }

  factory BlockLayoutData.fromJson(Map<String, dynamic> json) {
    return BlockLayoutData(
      json['bid'] as int,
      Offset(json['position']['dx'] as  double, json['position']['dy'] as  double),
      json['nickName'],
      json['layoutIndex'] as int,
    );
  }
}

class ExecPortData {
  final int pid;
  final String pName;
  final List<(int, int)> linkTo;

  ExecPortData(this.pid, this.pName, this.linkTo);

  // 新增方法
  Map<String, dynamic> toJson() {
    return {
      'pid': pid,
      'pName': pName,
      'linkTo': linkTo.map((e) => [e.$1, e.$2]).toList(),
    };
  }

  factory ExecPortData.fromJson(Map<String, dynamic> json) {
    return ExecPortData(
      json['pid'] as int,
      json['pName'] as String,
      (json['linkTo'] as List)
          .map((e) => (e[0] as int, e[1] as int))
          .toList(),
    );
  }
}

class StaticConfigure {
  final String pName;
  final DynamicWithType data;

  StaticConfigure(this.pName, this.data);

  // 新增方法
  Map<String, dynamic> toJson() {
    return {'pName': pName, 'data': data.toJson()};
  }

  factory StaticConfigure.fromJson(Map<String, dynamic> json) {
    return StaticConfigure(
      json['pName'],
      DynamicWithType.fromJson(json['data']),
    );
  }
}

class BlockExecData {
  final int bid;
  final String function;
  final List<ExecPortData> outPorts;
  final List<StaticConfigure> staticConfigure;

  BlockExecData(
    this.bid,
    this.function,
    this.outPorts,
    this.staticConfigure,
  );

  // 新增方法
  Map<String, dynamic> toJson() {
    return {
      'bid': bid,
      'function': function,
      'outPorts': outPorts.map((e) => e.toJson()).toList(),
      'staticConfigure': staticConfigure.map((e) => e.toJson()).toList(),
    };
  }

  factory BlockExecData.fromJson(Map<String, dynamic> json) {
    return BlockExecData(
      json['bid'],
      json['function'],
      (json['outPorts'] as List).map((e) => ExecPortData.fromJson(e)).toList(),
      (json['staticConfigure'] as List)
          .map((e) => StaticConfigure.fromJson(e))
          .toList(),
    );
  }
}

class EditorSaveData {
  final List<BlockExecData> blockExecData;
  final List<BlockLayoutData> blockLayoutData;

  EditorSaveData(this.blockExecData, this.blockLayoutData);

  // 新增方法
  Map<String, dynamic> toJson() {
    return {
      'blockExecData': blockExecData.map((e) => e.toJson()).toList(),
      'blockLayoutData': blockLayoutData.map((e) => e.toJson()).toList(),
    };
  }

  factory EditorSaveData.fromJson(Map<String, dynamic> json) {
    return EditorSaveData(
      (json['blockExecData'] as List)
          .map((e) => BlockExecData.fromJson(e))
          .toList(),
      (json['blockLayoutData'] as List)
          .map((e) => BlockLayoutData.fromJson(e))
          .toList(),
    );
  }
}

class PersistentDataManager {
  final Ref ref;
  PersistentDataManager(this.ref);
  
  void saveData(){
    final allBlocks = ref.read(editorControllerInstance).blocks;
    for(final block in allBlocks.entries){
      var bcn = ref.read(blockComponentNotifier(block.key));
      var nnd = bcn.componentsInfo[0];
      String? nn;
      if(!(nnd == null||nnd.type != RecordDataType.string)){
        nn = nnd.value;
      }
      var bld = BlockLayoutData(block.key,ref.read(blockPositionAndFocusProvider(block.key)).$1,nn,block.value.layer);
      List<ExecPortData> op = [];
      /*
      for(var bi in bcn.componentsInfo.entries){
        if(bi.key == 0){
          continue;
        }
        if(bi.key > 0){
          ip.add(ExecPortData(bi.key, , linkTo))
        }
      }*/
      for(var bo in bcn.portConnection.entries){
        if(bo.key<0){
          
        }
      }
    }
  }
  
}
