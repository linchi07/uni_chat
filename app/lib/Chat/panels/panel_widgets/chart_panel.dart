import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_chat/Chat/panels/basic_pannel.dart';
import 'package:uni_chat/Chat/panels/panel_data.dart';

import '../../../utils/images.dart';
import '../constant_value_indexer.dart';

/// 主面板组件，作为UIQL的入口
class ChartPanel extends BasicPanel {
  ChartPanel({super.key, required super.name});

  @override
  (String, List<Base64Image>?) panelSummary(PanelData data) {
    var type = data.props['type']?.toString().toLowerCase();
    var s = type == null ? "当前未提供图表类型，面板上显示一个空白。" : "当前图表类型为 $type。";
    var title = data.props['title']?.toString();
    s = title == null ? "$s \n当前未提供图表标题" : "$s\n当前图表标题为 $title。";
    var rawData = data.props['data'];
    var error = data.props['error'];
    if (error != null) {
      s = "$s \n当前图表数据存在错误，请检查数据。\n- 检查JSON格式是否正确。\n- 检查数据结构是否符合 $type 图表的要求。错误信息为： $error。";
      return (s, null);
    }
    s = rawData == null ? "$s \n当前未提供图表数据" : "$s\n当前图表数据为 $rawData。";
    return (s, null);
  }

  @override
  Widget buildInternal(BuildContext context, WidgetRef ref, PanelData data) {
    // 提取通用属性
    final chartType = data.props['type']?.toString().toLowerCase();
    final rawData = data.props['data'];
    final title = data.props['title']?.toString();

    // 如果没有指定图表类型，返回提示
    if (chartType == null) {
      return const SizedBox();
    }

    // Fallback 规则 1: 如果 data 属性不存在或为空，则显示空白面板
    // 这支持了先 CREATE 面板，后 UPDATE 数据的流程
    if (rawData == null || rawData.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    try {
      // 尝试解码JSON数据
      final decodedData = jsonDecode(rawData.toString());
      data.props.remove("error");
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 显示标题
            if (title != null)
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            // 图表主体
            Expanded(
              child: Chart(
                chartType: chartType,
                chartData: decodedData,
                panelProps: data.props, // 将整个 props 传递下去
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      data.props['error'] = e.toString();
      // Fallback 规则 2: 如果 data 存在但格式错误，在UI上明确报错
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 45),
            const SizedBox(height: 8.0),
            Text(
              '图表数据错误:\n- 检查JSON格式是否正确。\n- 检查数据结构是否符合"$chartType"图表的要求。\n 如果这是Ai编辑的代码，请将错误信息反馈给他让他修改 \n\n错误详情: ${e.toString()}',
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }
  }
}

/// 核心图表渲染组件
class Chart extends StatefulWidget {
  const Chart({
    super.key,
    required this.chartType,
    required this.chartData,
    required this.panelProps,
  });

  final String chartType;
  final dynamic chartData;
  final Map<String, dynamic> panelProps;

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  @override
  Widget build(BuildContext context) {
    // 颜色生成器，用于在未提供颜色时自动分配
    final colorGenerator = _ColorGenerator();

    switch (widget.chartType) {
      case 'bar':
      case 'line':
        return _buildBarAndLineChart(context, widget.chartType, colorGenerator);
      case 'pie':
        return _buildPieChart(context, colorGenerator);
      case 'scatter':
        return _buildScatterChart(context, colorGenerator);
      case 'radar':
        return _buildRadarChart(context, colorGenerator);
      default:
        return Center(child: Text('不支持的图表类型: ${widget.chartType}'));
    }
  }

  /// 构建条形图和折线图 (共享数据结构)
  Widget _buildBarAndLineChart(
    BuildContext context,
    String type,
    _ColorGenerator colorGenerator,
  ) {
    // 解析数据
    final labels = List<String>.from(widget.chartData['labels'] ?? []);
    final datasets = List<Map<String, dynamic>>.from(
      widget.chartData['datasets'] ?? [],
    );

    if (labels.isEmpty || datasets.isEmpty) {
      throw Exception('条形图/折线图需要 "labels" 和 "datasets" 数组。');
    }

    // 提取面板属性
    final showLegend = widget.panelProps['showLegend'] ?? true;

    final legendItems = <_LegendItem>[];

    // 为每个数据集生成图表数据和图例项
    final chartSpecificData = datasets.asMap().entries.map((entry) {
      final index = entry.key;
      final dataset = entry.value;
      final name = dataset['name']?.toString() ?? 'Series ${index + 1}';
      final color =
          ColorParser.parseColor(dataset['color']?.toString()) ??
          colorGenerator.next();
      final values = List<num>.from(dataset['values'] ?? []);

      legendItems.add(_LegendItem(name, color));

      if (type == 'line') {
        return LineChartBarData(
          spots: values
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
              .toList(),
          isCurved: true,
          color: color,
          barWidth: 4,
        );
      } else {
        // bar
        return BarChartRodData(
          toY: 0, // 初始值，实际值在 BarChartGroupData 中设置
          color: color,
          width: 16,
        );
      }
    }).toList();

    // 构建X轴标题
    final SideTitles bottomTitles = SideTitles(
      showTitles: true,
      reservedSize: 30,
      getTitlesWidget: (value, meta) {
        final index = value.toInt();
        if (index >= 0 && index < labels.length) {
          return SideTitleWidget(
            meta: meta,
            child: Text(labels[index], style: const TextStyle(fontSize: 12)),
          );
        }
        return const SizedBox.shrink();
      },
    );

    return Column(
      children: [
        if (showLegend) _LegendWidget(items: legendItems),
        Expanded(
          child: type == 'line'
              ? LineChart(
                  LineChartData(
                    lineBarsData: chartSpecificData.cast<LineChartBarData>(),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      bottomTitles: AxisTitles(sideTitles: bottomTitles),
                    ),
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                  ),
                )
              : BarChart(
                  BarChartData(
                    barGroups: List.generate(labels.length, (labelIndex) {
                      return BarChartGroupData(
                        x: labelIndex,
                        barRods: datasets.asMap().entries.map((datasetEntry) {
                          final datasetIndex = datasetEntry.key;
                          final dataset = datasetEntry.value;
                          final values = List<num>.from(
                            dataset['values'] ?? [],
                          );
                          final color =
                              ColorParser.parseColor(
                                dataset['color']?.toString(),
                              ) ??
                              legendItems[datasetIndex].color;
                          return BarChartRodData(
                            borderRadius: BorderRadius.zero,
                            toY: values.length > labelIndex
                                ? values[labelIndex].toDouble()
                                : 0,
                            color: color,
                            width: 16,
                          );
                        }).toList(),
                      );
                    }),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      bottomTitles: AxisTitles(sideTitles: bottomTitles),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: true),
                  ),
                ),
        ),
      ],
    );
  }

  int pieChartTouchedIndex = -1;

  /// 构建饼图
  Widget _buildPieChart(BuildContext context, _ColorGenerator colorGenerator) {
    final List<Map<String, dynamic>> dataList = List.from(widget.chartData);
    if (dataList.isEmpty) throw Exception('饼图数据不能为空数组。');

    final showLegend = widget.panelProps['showLegend'] ?? true;
    final showPercentage =
        widget.panelProps['showPercentage'] ?? true; // 默认true
    final isDonut = widget.panelProps['isDonut'] ?? false;

    final totalValue = dataList.fold(
      0.0,
      (sum, item) => sum + (item['value'] as num),
    );
    final legendItems = <_LegendItem>[];
    //这里由于构建顺序问题，只能遍历两遍了。。。。因为layout builder的遍历是后于legend构建的
    for (var item in dataList) {
      final label = item['label']?.toString() ?? 'N/A';
      final color =
          ColorParser.parseColor(item['color']?.toString()) ??
          colorGenerator.next();
      legendItems.add(_LegendItem(label, color));
    }

    return Column(
      children: [
        if (showLegend) _LegendWidget(items: legendItems),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final diameter = min(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
                final baseRadius = diameter * 0.4;
                final explodedRadius = diameter * 0.45;
                final centerSpaceRadius = isDonut ? diameter * 0.35 : 0;
                final sections = dataList.map((item) {
                  final value = (item['value'] as num).toDouble();
                  final color =
                      ColorParser.parseColor(item['color']?.toString()) ??
                      colorGenerator.next();
                  final isExploded = item['isExploded'] ?? false;
                  final percentage = (value / totalValue * 100).toStringAsFixed(
                    0,
                  );
                  return PieChartSectionData(
                    value: value,
                    title: showPercentage ? '$percentage%' : '',
                    radius:
                        isExploded ||
                            pieChartTouchedIndex == dataList.indexOf(item)
                        ? explodedRadius
                        : baseRadius,
                    color: color,
                    titleStyle: TextStyle(
                      fontSize: min(14 * baseRadius / 50.toInt(), 25),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList();
                return PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            pieChartTouchedIndex = -1;
                            return;
                          }
                          pieChartTouchedIndex = pieTouchResponse
                              .touchedSection!
                              .touchedSectionIndex;
                        });
                      },
                    ),
                    sections: sections,
                    centerSpaceRadius: centerSpaceRadius.toDouble(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 构建散点图
  Widget _buildScatterChart(
    BuildContext context,
    _ColorGenerator colorGenerator,
  ) {
    final datasets = List<Map<String, dynamic>>.from(
      widget.chartData['datasets'] ?? [],
    );
    if (datasets.isEmpty) throw Exception('散点图需要 "datasets" 数组。');

    final showLegend = widget.panelProps['showLegend'] ?? true;
    final legendItems = <_LegendItem>[];

    final scatterSpots = datasets
        .map((dataset) {
          final name = dataset['name']?.toString() ?? 'Dataset';
          final color =
              ColorParser.parseColor(dataset['color']?.toString()) ??
              colorGenerator.next();
          final points = List<Map<String, dynamic>>.from(
            dataset['points'] ?? [],
          );

          legendItems.add(_LegendItem(name, color));

          return points.map((point) {
            final x = (point['x'] as num).toDouble();
            final y = (point['y'] as num).toDouble();
            return ScatterSpot(
              x,
              y,
              dotPainter: FlDotCirclePainter(color: color, radius: 8),
            );
          }).toList();
        })
        .expand((list) => list)
        .toList();

    return Column(
      children: [
        if (showLegend) _LegendWidget(items: legendItems),
        Expanded(
          child: ScatterChart(
            ScatterChartData(
              scatterSpots: scatterSpots,
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(show: true),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),
      ],
    );
  }

  int radarChartTouchedIndex = -1;
  int radarChartTouchedEntryIndex = -1;
  Offset radarChartTouchPosition = Offset.zero;

  /// 构建雷达图
  Widget _buildRadarChart(
    BuildContext context,
    _ColorGenerator colorGenerator,
  ) {
    final ticks = List<String>.from(widget.chartData['ticks'] ?? []);
    final datasets = List<Map<String, dynamic>>.from(
      widget.chartData['dataSets'] ?? [],
    );
    if (ticks.isEmpty || datasets.isEmpty) {
      throw Exception('雷达图需要 "ticks" 和 "dataSets" 数组。');
    }

    final showLegend = widget.panelProps['showLegend'] ?? true;
    final legendItems = <_LegendItem>[];
    Map<String, double> rdChartEntryData = {};
    final radarDataSets = datasets.asMap().entries.map((entry) {
      final index = entry.key;
      final dataset = entry.value;
      final name = dataset['name']?.toString() ?? 'Dataset ${index + 1}';
      final values = List<num>.from(dataset['values'] ?? []);
      final color =
          ColorParser.parseColor(dataset['color']?.toString()) ??
          colorGenerator.next();

      legendItems.add(_LegendItem(name, color));
      int mapIndex = 0;
      return RadarDataSet(
        dataEntries: values.map((v) {
          rdChartEntryData["${index}_$mapIndex"] = v.toDouble();
          mapIndex++;
          return RadarEntry(value: v.toDouble());
        }).toList(),
        borderColor: color,
        fillColor: radarChartTouchedIndex == index
            ? color.withAlpha(100)
            : color.withAlpha(60),
        entryRadius: 3,
      );
    }).toList();

    var rdWidget = RadarChart(
      RadarChartData(
        radarTouchData: RadarTouchData(
          touchCallback: (FlTouchEvent event, response) {
            if (!event.isInterestedForInteractions) {
              setState(() {
                radarChartTouchedIndex = -1;
                radarChartTouchedEntryIndex = -1;
                radarChartTouchPosition = Offset.zero;
              });
              return;
            }
            setState(() {
              radarChartTouchedEntryIndex =
                  response?.touchedSpot?.touchedRadarEntryIndex ?? -1;
              radarChartTouchedIndex =
                  response?.touchedSpot?.touchedDataSetIndex ?? -1;
              radarChartTouchPosition = event.localPosition ?? Offset.zero;
            });
          },
        ),
        dataSets: radarDataSets,
        getTitle: (index, angle) => RadarChartTitle(text: ticks[index]),
        tickCount: ticks.length,
        ticksTextStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        gridBorderData: const BorderSide(color: Colors.grey, width: 2),
      ),
    );

    return Stack(
      alignment: Alignment.topRight,
      children: [
        if (showLegend)
          Positioned(width: 130, child: _LegendWidget(items: legendItems)),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Builder(
            builder: (context) {
              if (radarChartTouchedEntryIndex != -1 &&
                  radarChartTouchedIndex != -1 &&
                  radarChartTouchPosition != Offset.zero) {
                return Stack(
                  children: [
                    rdWidget,
                    CustomPaint(
                      painter: PreviewWindowPainter(
                        text:
                            rdChartEntryData["${radarChartTouchedIndex}_$radarChartTouchedEntryIndex"]
                                ?.toString() ??
                            "",
                        position: radarChartTouchPosition.translate(30, 0),
                      ),
                    ),
                  ],
                );
              }
              return rdWidget;
            },
          ),
        ),
      ],
    );
  }
}

/// 颜色生成器，用于 fallback
class _ColorGenerator {
  final Random _random = Random();
  final Set<Color> _usedColors = {};

  Color next() {
    Color color;
    do {
      // 生成一个饱和度较高、亮度适中的随机颜色
      final hsv = HSVColor.fromAHSV(
        1.0,
        _random.nextDouble() * 360,
        _random.nextDouble() * 0.5 + 0.5,
        _random.nextDouble() * 0.4 + 0.6,
      );
      color = hsv.toColor();
    } while (_usedColors.contains(color));
    _usedColors.add(color);
    return color;
  }
}

/// 图例项的数据模型
class _LegendItem {
  final String name;
  final Color color;
  _LegendItem(this.name, this.color);
}

/// 可复用的图例组件
class _LegendWidget extends StatelessWidget {
  const _LegendWidget({required this.items});
  final List<_LegendItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: items.map((item) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, color: item.color),
              const SizedBox(width: 8),
              Text(item.name),
            ],
          );
        }).toList(),
      ),
    );
  }
}

///fl——charts的原生不提供雷达图的预览，我们只能自己画了
class PreviewWindowPainter extends CustomPainter {
  final String? text;
  final TextStyle textStyle;
  final Offset? position;

  PreviewWindowPainter({
    this.text,
    this.position,
    this.textStyle = const TextStyle(color: Colors.black, fontSize: 14),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (text == null || position == null) return;
    // 创建文本画笔
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );

    // 布局文本
    textPainter.layout();

    final backgroundPaint = Paint()
      ..color = Colors.grey[500]!
      ..style = PaintingStyle.fill;

    final backgroundRect = Rect.fromLTWH(
      position!.dx - 5,
      position!.dy - 5,
      textPainter.width + 10,
      textPainter.height + 10,
    );

    final backgroundRRect = RRect.fromRectAndRadius(
      backgroundRect,
      Radius.circular(5),
    );

    canvas.drawRRect(backgroundRRect, backgroundPaint);

    // 绘制文本
    textPainter.paint(canvas, position!);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
