import 'dart:ui';

import 'package:uni_chat/Editor/Core/input_controller.dart';
import 'package:uni_chat/Editor/Core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DesiredHitType{
  click,
  longPress,
  doubleClick,
}

class HitTestArea{
  final int id;
  final int start;
  final int end;
  //由于每个组件的高度都一样，所以没必要存高度，
  // 而且由于组件的整体高度是已知的，所以没必要用AABB
  final DesiredHitType type;
  HitTestArea({required this.id,required this.start,required this.end,required this.type});
}

///处理块内部的组件的HitTest
class InBlockHitTestEngine{
  final Ref ref;
  InBlockHitTestEngine(this.ref);
  final Map<int,List<(HitTestArea,HitTestArea?)>> _blockHitTestMap = {};
  
  void registerHitTestArea(int bid,List<(HitTestArea,HitTestArea?)> areas){
    _blockHitTestMap[bid] = areas;
  }
  
  bool doInBlockHitTest(int bid,Offset localPos,{InputBehaviour? inputBehaviour}){
    var x = localPos.dx;
    var y = localPos.dy;
    int line = 0;
    if(x<10||x>290){
      //点击在白边上
      return false;
    }
    if((inputBehaviour!= null&&inputBehaviour == InputBehaviour.doubleClicking)&&y<60){
      //点击在banner
      //没有点击在banner白边上
      //这里不让整个banner都有判定，方便拖拽
      if((y>4&&y<56)&&x>65&&x<290){
          //hit在banner文本框
        notifyThoseBeingHit(bid, 0, localPos);
          return true;
      }
    }else{
      y -= 70;//这里是60+10，10是layout的上padding
      if(y<0){
        return false;
      }
      line = (y/60).toInt();
      y = y%60;
      if(y<25||y>55.5){
        //hit在白边和变量文字上
        return false;
      }
      //接下来才是进行盒检测
      var ln = _blockHitTestMap[bid];
      if(ln == null||ln.isEmpty||ln.length <line){
        //没有这个块
        //正常来讲，这种情况可以直接抛错误，因为明显逻辑上不可能存在
        //但是谁知道呢？
        return false;
      }
      var l = ln[line];
      //后续可以加上，我们预留的检测type也就是比如双击才能触发
      if(x>l.$1.start&&x<l.$1.end){
        notifyThoseBeingHit(bid, l.$1.id,Offset(x-l.$1.start,y-4.5));
          return true;
      }
      if(l.$2!= null&&(x>l.$2!.start&&x<l.$2!.end)){
        notifyThoseBeingHit(bid, l.$2!.id,Offset(x-l.$2!.start,y-4.5));
          return true;
      }
    }
    return false;
  }
  
  void notifyThoseBeingHit(int bid,int hid,Offset locPos){
    ref.read(blockComponentNotifier(bid).notifier).notifyAndUpdateHitComponent(hid, true,locPos);
  }
}