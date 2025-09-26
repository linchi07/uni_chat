import 'dart:collection';

import 'package:flutter/gestures.dart';

enum InputBehaviour {
  none,
  leftButtonDown, //触发按下事件
  leftButtonUp, //删除触发的事件的临时变量（例如hitTest）
  clicking,
  selecting,
  doubleClicking,
  dragging,
  draggingCanvas,
  rightButtonClicking,
  zooming,
}

class ControllerInput {
  InputBehaviour behaviour;
  Offset? delta;
  Offset? localPosition;
  Offset? globalPosition;
  double? zoomDelta;
  ControllerInput({
    required this.behaviour,
    this.delta,
    this.localPosition,
    this.zoomDelta,
  });
}

class PointerStat {
  bool isDown;
  bool isDragging;
  Offset position;
  PointerDeviceKind type;
  int button;
  Duration timeStamp;
  Offset delta;
  PointerStat({
    required this.delta,
    required this.isDown,
    required this.isDragging,
    required this.position,
    required this.type,
    required this.button,
    required this.timeStamp,
  });
}

class InputController {
  InputController({required this.notifyInput, required this.notifyHover});
  final void Function(ControllerInput currentInput) notifyInput;
  final void Function(Offset mouseHoverLoc) notifyHover;

  ///存储所有的！！触屏和手写笔！！的输入指针事件。注意！只有按下的指针才会存在事件！也就是hover不算在内
  HashMap<int, PointerStat> touchInputPointers = HashMap();
  PointerStat? cursorInputPointer; //鼠标和触控板输入
  PointerStat? lastCursorInputPointer; //上一次的事件。
  // 注意！只有鼠标完整的按下去和抬起来才算一个事件的更新
  //也就是说拖拽和按下都只是算作一个事件而不是很多的事件的集合

  ///为了方便处理，我们把最后一个输入类型视为当前正在输入的设备，其他的输入事件会忽略
  PointerDeviceKind currentDeviceKind = PointerDeviceKind.unknown;
  ControllerInput lastInput = ControllerInput(behaviour: InputBehaviour.none);

  ///注：手势部分暂时忽略，我没功夫做手机的东西，以后再说
  void pointerHover(PointerHoverEvent event) {
    notifyHover(event.localPosition);
  }

  void pointerDown(PointerDownEvent event) {
    if (currentDeviceKind != event.kind) {
      currentDeviceKind = event.kind;

      ///什么意思呢？就是说我们把手写笔看作是一个手指头·····
      if (!((currentDeviceKind == PointerDeviceKind.stylus ||
              currentDeviceKind == PointerDeviceKind.touch) &&
          (event.kind == PointerDeviceKind.touch ||
              event.kind == PointerDeviceKind.stylus))) {
        touchInputPointers.clear();
      }
    }

    ///我们只需要手动处理触摸和笔，触控板的多手指操作交给系统处理
    if (currentDeviceKind == PointerDeviceKind.touch ||
        currentDeviceKind == PointerDeviceKind.stylus) {
      touchInputPointers[event.pointer] = PointerStat(
        isDown: true,
        position: event.localPosition,
        type: event.kind,
        button: event.buttons,
        delta: event.delta,
        timeStamp: event.timeStamp,
        isDragging: false,
      );
    } else {
      if (event.buttons == 1) {
        lastInput.behaviour = InputBehaviour.leftButtonDown;
        lastInput.globalPosition = event.position;
        lastInput.localPosition = event.localPosition;
        notifyInput(lastInput);
      }
      cursorInputPointer = PointerStat(
        isDown: true,
        position: event.localPosition,
        type: event.kind,
        button: event.buttons,
        delta: event.delta,
        timeStamp: event.timeStamp,
        isDragging: false,
      );
    }
  }

  void pointerMove(PointerMoveEvent event) {
    if (currentDeviceKind == PointerDeviceKind.touch ||
        currentDeviceKind == PointerDeviceKind.stylus) {
      touchInputPointers[event.pointer] = PointerStat(
        isDown: true,
        position: event.localPosition,
        type: event.kind,
        button: event.buttons,
        delta: event.delta,
        timeStamp: event.timeStamp,
        isDragging: false,
      );
    } else {
      if (cursorInputPointer == null) {
        return;
      }
      if (event.buttons == 1) {
        lastInput.delta = event.delta;
        lastInput.localPosition = event.localPosition;
        lastInput.globalPosition = event.position;
        lastInput.behaviour = InputBehaviour.dragging;
        notifyInput(lastInput);
      }
      //这里鼠标和触控板要分开
      //这个只是鼠标的
      if (event.buttons == 2 || event.buttons == 4) {
        lastInput.delta = event.delta;
        lastInput.behaviour = InputBehaviour.draggingCanvas;
        notifyInput(lastInput);
      }
      cursorInputPointer = PointerStat(
        isDown: true,
        position: event.localPosition,
        type: event.kind,
        button: event.buttons,
        delta: event.delta,
        timeStamp: event.timeStamp,
        isDragging: true,
      );
    }
  }

  void pointerUp(PointerUpEvent event) {
    if (currentDeviceKind == PointerDeviceKind.touch ||
        currentDeviceKind == PointerDeviceKind.stylus) {
      touchInputPointers[event.pointer] = PointerStat(
        isDown: false,
        position: event.localPosition,
        type: event.kind,
        button: event.buttons,
        delta: event.delta,
        timeStamp: event.timeStamp,
        isDragging: false,
      );
    } else {
      if (cursorInputPointer == null) {
        return;
      }
      if (cursorInputPointer!.button == 1) {
        //通知控制器删掉临时变量
        lastInput.behaviour = InputBehaviour.leftButtonUp;
        lastInput.localPosition = event.localPosition;
        lastInput.globalPosition = event.position;
        notifyInput(lastInput);
        //先得是左键
        if (!cursorInputPointer!.isDragging) {
          //先判断是点击事件还是拖拽事件
          if (cursorInputPointer!.isDown) {
            if (cursorInputPointer!.timeStamp - event.timeStamp <
                Duration(milliseconds: 100)) {
              //这说明是快速点击，不是长按，接下来判断是不是双击
              //如果仔细看判断逻辑的话会发现，如果是双击的话，仍然会发送一个单击事件，不过我发现其实也没啥问题，
              // 就相当于单击选中了节点，然后双击打开。不用用异步等待逻辑之类的来确保这真的是单击
              if (lastCursorInputPointer != null &&
                  !(lastCursorInputPointer!.isDown) &&
                  event.timeStamp - lastCursorInputPointer!.timeStamp <
                      Duration(milliseconds: 300) &&
                  //这里是要确保连点击三次鼠标不算作双击
                  lastInput.behaviour != InputBehaviour.doubleClicking) {
                //双击！
                lastInput.localPosition = event.localPosition;
                lastInput.globalPosition = event.position;
                lastInput.behaviour = InputBehaviour.doubleClicking;
                notifyInput(lastInput);
              } else {
                //单击！
                lastInput.localPosition = event.localPosition;
                lastInput.globalPosition = event.position;
                lastInput.behaviour = InputBehaviour.clicking;
                notifyInput(lastInput);
              }
            }
          }
        }
      } else if (cursorInputPointer!.button == 2) {
        //鼠标右键
        if (!cursorInputPointer!.isDragging) {
          //先判断是点击事件还是拖拽事件
          if (cursorInputPointer!.isDown) {
            if (cursorInputPointer!.timeStamp - event.timeStamp <
                Duration(milliseconds: 100)) {
              //这说明是快速点击，不是长按，接下来判断是不是双击
              //右键没有双击操作，我们只要排除双击就好了
              lastInput.localPosition = event.localPosition;
              lastInput.globalPosition = event.position;
              lastInput.behaviour = InputBehaviour.rightButtonClicking;
              notifyInput(lastInput);
              print("右单");
            }
          }
        }
      }
      lastCursorInputPointer = cursorInputPointer;
      cursorInputPointer = null;
      lastCursorInputPointer!.isDown = false;
    }
  }

  void pointerSignal(PointerSignalEvent event) {
    if (event.kind == PointerDeviceKind.mouse && event is PointerScrollEvent) {
      lastInput.behaviour = InputBehaviour.zooming;
      lastInput.zoomDelta = event.scrollDelta.dy;
      notifyInput(lastInput);
    }
  }

  double _lastZoomScale = 1.0; // 用于存储上一次事件的scale值
  bool _isZooming = false; // 标记是否正在缩放

  // 在手势开始时重置状态
  void pointerPanZoomStart(PointerPanZoomStartEvent event) {
    if (event.kind == PointerDeviceKind.trackpad) {
      _lastZoomScale = 1.0;
      _isZooming = false; // 初始假设不是缩放，直到scale变化
    }
  }

  // 处理手势更新
  void pointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (event.kind == PointerDeviceKind.trackpad) {
      // 检查scale是否显著变化，以区分拖拽和缩放
      // 由于浮点数精度问题，不直接与1.0比较
      if ((event.scale - 1.0).abs() > 0.00001) {
        _isZooming = true;

        // 计算缩放增量
        final double zoomDelta = event.scale / _lastZoomScale;
        _lastZoomScale = event.scale;

        lastInput.behaviour = InputBehaviour.zooming;
        lastInput.zoomDelta = zoomDelta; // 直接使用这个增量
        notifyInput(lastInput);
        
      } else if (!_isZooming) {
        // 如果没有开始缩放，则视为拖动
        lastInput.behaviour = InputBehaviour.draggingCanvas;
        lastInput.delta = event.panDelta * 1.5; //增加点灵敏度
        notifyInput(lastInput);
      }
    }
  }

  // 在手势结束时重置
  void pointerPanZoomEnd(PointerPanZoomEndEvent event) {
    _lastZoomScale = 1.0;
    _isZooming = false;
  }
}
