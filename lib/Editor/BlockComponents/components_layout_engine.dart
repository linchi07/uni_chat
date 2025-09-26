import 'dart:io';
import 'package:uni_chat/Editor/Core/link_painter.dart';
import 'package:uni_chat/Editor/BlockComponents/components.dart';
import 'package:uni_chat/Editor/Core/block_data.dart';
import 'package:uni_chat/Editor/Core/block_hitTest_engine.dart';
import 'package:uni_chat/Editor/Core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Core/providers.dart';

const EXTRA_LARGE_COMPONENT_WIDE = 280;
const LARGE_COMPONENT_WIDE = 180;
const SMALL_COMPONENT_WIDE = 100;
const BoxConstraints EXTRA_LARGE_COMPONENT_SIZE = BoxConstraints(
  maxWidth: 280,
  maxHeight: 60,
  minWidth: 280,
  minHeight: 60,
);
const BoxConstraints FULL_LENGTH_COMPONENT_SIZE = BoxConstraints(
  maxWidth: 180,
  maxHeight: 60,
  minWidth: 180,
  minHeight: 60,
);
const BoxConstraints SMALL_COMPONENT_SIZE = BoxConstraints(
  maxWidth: 100,
  maxHeight: 60,
  minWidth: 100,
  minHeight: 60,
);

enum ComponentSize { extraLarge, fullLength, small }

class ComponentInfo {
  final int id;
  final Offset position;
  final ComponentSize size;
  ComponentInfo({required this.id, required this.position, required this.size});
  BoxConstraints getSize() {
    switch (size) {
      case ComponentSize.extraLarge:
        return EXTRA_LARGE_COMPONENT_SIZE;
      case ComponentSize.fullLength:
        return FULL_LENGTH_COMPONENT_SIZE;
      case ComponentSize.small:
        return SMALL_COMPONENT_SIZE;
    }
  }
}

class BlockComponentsLayout extends MultiChildLayoutDelegate {
  final List<ComponentInfo> components;
  double height;
  BlockComponentsLayout({required this.components, required this.height});
  @override
  void performLayout(Size size) {
    ///这里是把customPaint给布局了
    layoutChild(
      "neverGonnaGiveYouUp",//我不会忘记你的！
      BoxConstraints(
        maxWidth: 340,
        maxHeight: height,
        minWidth: 340,
        minHeight: height,
      ),
    );
    positionChild("neverGonnaGiveYouUp", Offset(-20, 0));
    for (var component in components) {
      layoutChild(component.id, component.getSize());
      positionChild(component.id, component.position);
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}

class BlockMainContent extends ConsumerWidget {
  final BlockData block;
  const BlockMainContent({super.key, required this.block});

  /// 布局
  /// 这绝对是我写过最神人的布局逻辑了，写着自己都觉得绷不住
  /// 包括但不限于dynamic乱飞（不得不夸dart的dynamic是真的好用，神级设计）
  /// 不在委托里面写代码而是在外面排好放到委托里面，我还真是曲线救国小能手（笑）
  (
    List<ComponentInfo>,
    List<Widget> widgets,
    double height,
    List<Port> inports,
    List<Port> outports,
    List<(HitTestArea,HitTestArea?)>
  )
  layout() {
    var inPorts = block.config.inPorts;
    var outPorts = block.config.outPorts;
    double posY = 10; //预留10的padding
    const double HORIZONTAL_MINVAL = 10;
    const double HORIZONTAL_MAXVAL = 290;
    int id = 1;//给banner也预留id为0，同时in和out共享一套id，但是out是负数
    var spaceLeft = <int>[];
    var components = <ComponentInfo>[];
    var widgets = <Widget>[];
    var inPortsLoc = <Port>[];
    var outPortsLoc = <Port>[];
    var hitBox = <(HitTestArea, HitTestArea?)>[];
    for (var port in inPorts.entries) {
      switch (port.key) {
        case "string":
          widgets.add(StringPort(params: port.value, id: id, bid: block.bid));
          ComponentSize size =
              port.value["componentSize"] ?? ComponentSize.fullLength;
          components.add(
            ComponentInfo(
              id: id,
              position: Offset(HORIZONTAL_MINVAL, posY),
              size: size,
            ),
          );
          var w = getWidth(size);
          spaceLeft.add(280 - w);
          hitBox.add((
            HitTestArea(
              id: id,
              start: HORIZONTAL_MINVAL.toInt(),
              end: w + HORIZONTAL_MINVAL.toInt(),
              type: DesiredHitType.click,
            ),
            null,
          ));
          inPortsLoc.add(
            //注意画布是左上角为0，这里的10是距离左侧10px，posY加上41，
            // 这个41是这个port component的灰色框的中心，人工修正的值
            Port(
              bid: block.bid,
              localPosition: Offset(10, posY + 41),
              shape: PortShape.circle,
              dataType: DataType.fromString("string"),
              type: PortType.inPort,
              portId: id++,
            ),
          );
          posY += 60;
          break;
        case "bool":
          widgets.add(BoolPort(params: port.value, id: id, bid: block.bid));
          ComponentSize size = ComponentSize.small;
          components.add(
            ComponentInfo(
              id: id,
              position: Offset(HORIZONTAL_MINVAL, posY),
              size: size,
            ),
          );
          spaceLeft.add(280 - getWidth(size));
          hitBox.add((
          HitTestArea(
            id: id,
            start: HORIZONTAL_MINVAL.toInt(),
            end: 70 + HORIZONTAL_MINVAL.toInt(),//这个bool类型的组件的一个特点就是他的hitBox不是他的组件大小，所以要特殊处理
            type: DesiredHitType.click,
          ),
          null,
          ));
          inPortsLoc.add(
            //注意画布是左上角为0，这里的10是距离左侧10px，posY加上41，
            // 这个41是这个port component的灰色框的中心
            Port(
              bid: block.bid,
              localPosition: Offset(10, posY + 41),
              shape: PortShape.circle,
              dataType: DataType.fromString("bool"),
              type: PortType.inPort,
              portId: id++,
            ),
          );
          posY += 60;
          break;
        case "int":
          widgets.add(IntPort(params: port.value, id: id, bid: block.bid));
          var size = ComponentSize.fullLength ;
          components.add(
            ComponentInfo(
              id: id,
              position: Offset(HORIZONTAL_MINVAL, posY),
              size: size,
            ),
          );
          spaceLeft.add(280 - getWidth(size));
          hitBox.add((
          HitTestArea(
            id: id,
            start: HORIZONTAL_MINVAL.toInt(),
            end: 100 + HORIZONTAL_MINVAL.toInt(),//这个类型的组件的一个特点就是他的hitBox不是他的组件大小，所以要特殊处理
            type: DesiredHitType.click,
          ),
          null,
          ));
          inPortsLoc.add(
            //注意画布是左上角为0，这里的10是距离左侧10px，posY加上41，
            // 这个41是这个port component的灰色框的中心
            Port(
              bid: block.bid,
              localPosition: Offset(10, posY + 41),
              shape: PortShape.circle,
              dataType: DataType.fromString("int"),
              type: PortType.inPort,
              portId: id++,
            ),
          );
          posY += 60;
          break;
        default:
          break;
      }
    }
    int pointer = 0;
    id = -1; //出端口和入端口共用id，但是out是负数
    for (var port in outPorts.entries) {
      switch (port.key) {
        case "default":
          widgets.add(
            DefaultOutPort(params: port.value, id: id, bid: block.bid),
          );
          ComponentSize size =
              port.value["componentSize"] ?? ComponentSize.small;
          while (true) {
            if (pointer < spaceLeft.length) {
              var s = getWidth(size);
              if (spaceLeft[pointer] >= s) {
                var y = 60 * pointer.toDouble() + 10; //60为组件高度,10是一开始的padding
                components.add(
                  ComponentInfo(
                    id: id,
                    position: Offset(HORIZONTAL_MAXVAL - s, y),
                    size: size,
                  ),
                  
                );
                outPortsLoc.add(
                  Port(
                    bid: block.bid,
                    localPosition: Offset(330, y + 41),
                    shape: PortShape.circle,
                    dataType: DataType.fromString(port.value['type']),
                    type: PortType.outPort,
                    portId: id--,
                  ),
                );
                break;
              } else {
                pointer++;
              }
            } else {
              var s = getWidth(size);
              posY += 60;
              components.add(
                ComponentInfo(
                  id: id,
                  position: Offset(HORIZONTAL_MAXVAL - s, posY),
                  size: size,
                ),
              );
              outPortsLoc.add(
                Port(
                  bid: block.bid,
                  localPosition: Offset(330, posY + 41),
                  shape: PortShape.rhombus,
                  type: PortType.outPort,
                  portId: id--,
                  dataType: DataType.fromString("string"),
                ),
              );
              break;
            }
          }

          break;
        default:
          break;
      }
    }
    posY += 10; //留一个padding
    ///最后加上绘制端口的customPaint
    widgets.add(
      LayoutId(
        id: "neverGonnaGiveYouUp",
        child: PortPainterWidget(bid: block.bid,inPortsLoc: inPortsLoc, outPortsLoc: outPortsLoc),
      ),
    );
    //将坐标修正为全局坐标然后发送给连接控制器
    //这个20是因为port的坐标是相对于customPaint的坐标，而那个比块本身的x要小20
    //60是需要加上banner的高度来修正
    var relativePosFixVal = Offset(
      block.position.dx - 20,
      block.position.dy + 60,
    );
    for (int i = 0; i < inPortsLoc.length; i++) {
      inPortsLoc[i].globalPosition =
          inPortsLoc[i].localPosition + relativePosFixVal;
    }
    for (int i = 0; i < outPortsLoc.length; i++) {
      outPortsLoc[i].globalPosition =
          outPortsLoc[i].localPosition + relativePosFixVal;
    }
    return (components, widgets, posY, inPortsLoc, outPortsLoc,hitBox);
  }

  int getWidth(ComponentSize size) {
    switch (size) {
      case ComponentSize.fullLength:
        return 180;
      case ComponentSize.extraLarge:
        return 280;
      case ComponentSize.small:
        return 100;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var result = layout();
    var lc = ref.read(linkController);
    lc.addOrUpdateInPorts(block.bid, result.$4);
    lc.addOrUpdateOutPorts(block.bid, result.$5);
    ref.read(inBlockHitTestEngine).registerHitTestArea(block.bid, result.$6);
    block.height = result.$3.toInt() + 60;
    //这里需要加上顶部banner的高度
    return SizedBox(
      width: 300,
      height: result.$3,
      child: CustomMultiChildLayout(
        delegate: BlockComponentsLayout(
          components: result.$1,
          height: result.$3,
        ),
        children: result.$2,
      ),
    );
  }
}

class PortPainterWidget extends ConsumerWidget {
  const PortPainterWidget({
    super.key,
    required this.bid,
    required this.inPortsLoc,
    required this.outPortsLoc,
  });
  final int bid;
  final List<Port> inPortsLoc;
  final List<Port> outPortsLoc;

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    ref.watch(blockComponentNotifier(bid).select((s)=>s.portConnection));
    print(inPortsLoc.first.hashCode);
    return CustomPaint(
      size: Size.infinite,
      painter: PortPainter(inPorts: inPortsLoc, outPorts: outPortsLoc),
    );
  }
}

enum PortShape {
  circle,
  rhombus,
  // 我称它为菱形（rhombus），更贴切一些
  // 其实我也想叫他菱形，但是我不知道这个单词，所以我告诉gemini这个是square，好在他很聪明
}

enum PortType { inPort, outPort }

class Port {
  final int bid;
  final int portId;
  final String portName;
  bool isLinked; //这个选项只有在作为输入端口时才有效
  Offset localPosition;
  Offset globalPosition; // 当在画布上时，这个值是绝对坐标
  final PortShape shape;
  final DataType dataType;
  final PortType type;
  Color get color => dataType.color;
  // 新增字段！用于快速查找和删除。Item1是X索引，Item2是Y索引。
  // 初始化为无效值。
  (int, int) bucketIndex = (-1, -1);
  List<Link>? links;

static final Port nullPort = Port(
  bid: -1145141919810, 
  localPosition: Offset.zero, 
  shape: PortShape.circle, 
  type: PortType.inPort, 
  portId: -1145141919810, 
  dataType: DataType.fromString("string"),
);

  
  Port({
    required this.bid,
    required this.localPosition,
    this.globalPosition = Offset.zero,
    required this.shape,
    required this.type,
    required this.portId,
    this.portName =  "",
    required this.dataType,
    this.isLinked = false,
    this.bucketIndex = const (-1, -1),
  });

  // 添加copyWith方法
  Port copyWith({
    int? bid,
    Offset?  globalPosition,
    PortShape? shape,
    Color? color,
    PortType? type,
    int? portId,
    DataType? dataType,
    bool? isLinked,
    Offset? localPosition,
  }) {
    return Port(
      isLinked: isLinked ?? this.isLinked,
      bid: bid ?? this.bid,
      localPosition: localPosition ?? this.localPosition,
      dataType: dataType ?? this.dataType,
      globalPosition: globalPosition ?? this.globalPosition,
      shape: shape ?? this.shape,
      type: type ?? this.type,
      portId: portId ?? this.portId,
    );
  }
}

class PortPainter extends CustomPainter {
  final List<Port> inPorts;
  final List<Port> outPorts;

  const PortPainter({required this.inPorts, required this.outPorts});

  @override
  void paint(Canvas canvas, Size size) {
    // 常量，方便调整
    const double portRadius = 6.0;
    const double portLineWidth = 2.0;
    const double lineLength = 20.0;

    final Paint linePaint = Paint()
      ..strokeWidth = portLineWidth
      ..style = PaintingStyle.stroke;

    final Paint shapePaint = Paint()
      ..strokeWidth = portLineWidth
      ..style = PaintingStyle.stroke;

    final Paint fillPaint = Paint()..style = PaintingStyle.fill;

    for (final port in inPorts) {
      // 端口主体（小圆点）的中心坐标，这现在是传入的基准点
      final Offset center = port.localPosition;

      linePaint.color = port.color;
      shapePaint.color = port.color;
      fillPaint.color = port.color;

      // 绘制连接线
      final Offset lineStartPoint;
      final Offset lineEndPoint;

      // 输入端口：线从右侧连入，画左侧
      lineStartPoint = center.translate(6, 0);
      lineEndPoint = center.translate(lineLength, 0);

      canvas.drawLine(lineStartPoint, lineEndPoint, linePaint);

      // 绘制端口主体和内部小圆点
      switch (port.shape) {
        case PortShape.circle:
          _drawCirclePort(canvas, center, portRadius, shapePaint, fillPaint,port.isLinked?6:2.5);
          break;
        case PortShape.rhombus:
          _drawRhombusPort(canvas, center, portRadius, shapePaint, fillPaint,port.isLinked?5:1.75);
          break;
      }
    }

    for (final port in outPorts) {
      // 端口主体（小圆点）的中心坐标，这现在是传入的基准点
      final Offset center = port.localPosition;

      linePaint.color = port.color;
      shapePaint.color = port.color;
      fillPaint.color = port.color;

      // 绘制连接线
      final Offset lineStartPoint;
      final Offset lineEndPoint;

      // 输出端口：线从左侧连出，画右侧
      lineStartPoint = center.translate(-lineLength, 0);
      lineEndPoint = center.translate(-6, 0);
      canvas.drawLine(lineStartPoint, lineEndPoint, linePaint);

      // 绘制端口主体和内部小圆点
      switch (port.shape) {
        case PortShape.circle:
          _drawCirclePort(canvas, center, portRadius, shapePaint, fillPaint,port.isLinked?6:2.5);
          break;
        case PortShape.rhombus:
          _drawRhombusPort(canvas, center, portRadius, shapePaint, fillPaint,port.isLinked?5:1.75);
          break;
      }
    }
  }

  void _drawCirclePort(
    Canvas canvas,
    Offset center,
    double portRadius,
    Paint paint,
    Paint fillPaint,
      double circleRadius,
  ) {
    // 绘制圆形
    canvas.drawCircle(center, portRadius, paint);
    // 绘制内部的小圆点
    canvas.drawCircle(center, circleRadius, fillPaint);
  }

  void _drawRhombusPort(
    Canvas canvas,
    Offset center,
    double portRadius,
    Paint paint,
    Paint fillPaint,
      double circleRadius,
  ) {
    // 菱形的四个顶点
    final Path rhombusPath = Path()
      ..moveTo(center.dx - portRadius, center.dy)
      ..lineTo(center.dx, center.dy - portRadius)
      ..lineTo(center.dx + portRadius, center.dy)
      ..lineTo(center.dx, center.dy + portRadius)
      ..close();
    canvas.drawPath(rhombusPath, paint);

    // 绘制内部的小圆点
    canvas.drawCircle(center, circleRadius, fillPaint);
  }

  @override
  bool shouldRepaint(covariant PortPainter oldDelegate) {
    return inPorts != oldDelegate.inPorts || outPorts != oldDelegate.outPorts;
  }
}
