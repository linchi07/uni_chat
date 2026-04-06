import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uni_chat/api_configs/api_database.dart';
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';

class TokenUsageDashboard extends ConsumerStatefulWidget {
  final String providerId;

  const TokenUsageDashboard({super.key, required this.providerId});

  @override
  ConsumerState<TokenUsageDashboard> createState() =>
      _TokenUsageDashboardState();
}

class _TokenUsageDashboardState extends ConsumerState<TokenUsageDashboard> {
  String _timeRange = '24h';
  bool _isLoading = true;

  // Data using Records
  ({int prompt, int completion, int cached, Map<String, double> costs})
  _summary = (prompt: 0, completion: 0, cached: 0, costs: {});
  List<({DateTime time, int total, double cost, String? currency})>
  _trendBuckets = [];
  List<({Model? model, String modelId, int total, double cost})>
  _modelBuckets = [];
  List<({ApiKey key, int total, double cost})> _keyBuckets = [];
  List<({ApiKeyUsage usage, Model? model})> _detailedLogs = [];

  int _selectedBarIndex = -1;
  int? _touchedPieIndex;
  int? _touchedKeyPieIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final adb = ApiDatabase.instance;
    final now = DateTime.now();
    DateTime start;

    switch (_timeRange) {
      case '7d':
        start = now.subtract(const Duration(days: 7));
        break;
      case '30d':
        start = now.subtract(const Duration(days: 30));
        break;
      case '24h':
      default:
        start = now.subtract(const Duration(hours: 24));
        break;
    }

    final groupByDay = _timeRange != '24h';

    try {
      final summary = await adb.getUsageSummary(
        widget.providerId,
        start: start,
        end: now,
      );
      final trendRaw = await adb.getTrendBuckets(
        widget.providerId,
        start: start,
        end: now,
      );
      final models = await adb.getModelUsageBuckets(
        widget.providerId,
        start: start,
        end: now,
      );
      final keys = await adb.getKeyUsageBuckets(
        widget.providerId,
        start: start,
        end: now,
      );

      final groupedTrend =
          <DateTime, ({int total, double cost, String? currency})>{};
      for (var item in trendRaw) {
        final t = item.time;
        final bucketTime = groupByDay
            ? DateTime(t.year, t.month, t.day)
            : DateTime(t.year, t.month, t.day, t.hour);
        final existing = groupedTrend[bucketTime];
        groupedTrend[bucketTime] = (
          total: (existing?.total ?? 0) + item.total,
          cost: (existing?.cost ?? 0) + (item.cost ?? 0.0),
          currency: item.currency ?? existing?.currency,
        );
      }
      final trend =
          groupedTrend.entries
              .map(
                (e) => (
                  time: e.key,
                  total: e.value.total,
                  cost: e.value.cost,
                  currency: e.value.currency,
                ),
              )
              .toList()
            ..sort((a, b) => a.time.compareTo(b.time));

      setState(() {
        _summary = summary;
        _trendBuckets = trend;
        _modelBuckets = models;
        _keyBuckets = keys;
        _isLoading = false;
        _selectedBarIndex = -1;
        _detailedLogs = [];
      });

      // Initially load all logs for the period
      _loadDetailedLogs(start, now);
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDetailedLogs(DateTime start, DateTime end) async {
    final adb = ApiDatabase.instance;
    try {
      final logs = await adb.getDetailedUsageLogs(
        widget.providerId,
        start: start,
        end: end,
      );
      setState(() {
        _detailedLogs = logs;
      });
    } catch (e) {
      debugPrint('Error loading detailed logs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRangeSelector(),
          const SizedBox(height: 20),
          _buildSummarySection(),
          const SizedBox(height: 20),
          _buildChartsGrid(),
          const SizedBox(height: 20),
          _buildTimeTrendSection(),
          const SizedBox(height: 20),
          _buildDetailedLogList(),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: '24h', label: Text('24小时')),
        ButtonSegment(value: '7d', label: Text('7天')),
        ButtonSegment(value: '30d', label: Text('30天')),
      ],
      selected: {_timeRange},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          _timeRange = newSelection.first;
          _loadData();
        });
      },
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
    );
  }

  Widget _buildSummarySection() {
    final total = _summary.prompt + _summary.completion;
    return Column(
      children: [
        Row(
          children: [
            _SummaryCard(
              title: '总 Prompt',
              value: NumberFormat.compact().format(_summary.prompt),
              icon: Icons.upload_file,
              color: Colors.blue,
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              title: '总 Completion',
              value: NumberFormat.compact().format(_summary.completion),
              icon: Icons.download_done,
              color: Colors.green,
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              title: '总消耗',
              value: NumberFormat.compact().format(total),
              icon: Icons.summarize,
              color: Colors.orange,
            ),
            const SizedBox(width: 12),
            _SummaryCard(
              title: '缓存节省',
              value: NumberFormat.compact().format(_summary.cached),
              icon: Icons.bolt,
              color: Colors.purple,
            ),
          ],
        ),
        if (_summary.costs.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children:
                _summary.costs.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: _SummaryCard(
                      title: '预估费用 (${e.key})',
                      value: e.value.toStringAsFixed(4),
                      icon: Icons.account_balance_wallet,
                      color: Colors.redAccent,
                    ),
                  );
                }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildChartsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildModelDistributionCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildKeyDistributionCard()),
            ],
          );
        } else {
          return Column(
            children: [
              _buildModelDistributionCard(),
              const SizedBox(height: 16),
              _buildKeyDistributionCard(),
            ],
          );
        }
      },
    );
  }

  Widget _buildModelDistributionCard() {
    return _DashboardCard(
      title: '模型消耗分布',
      child: SizedBox(
        height: 300,
        child: _ModelDistributionPieChart(
          buckets: _modelBuckets,
          touchedIndex: _touchedPieIndex,
          onTouch: (index) => setState(() => _touchedPieIndex = index),
        ),
      ),
    );
  }

  Widget _buildKeyDistributionCard() {
    if (_keyBuckets.length <= 1) {
      return const SizedBox.shrink();
    }
    return _DashboardCard(
      title: 'API Key 使用分布',
      child: SizedBox(
        height: 300,
        child: _KeyDistributionPieChart(
          buckets: _keyBuckets,
          touchedIndex: _touchedKeyPieIndex,
          onTouch: (index) => setState(() => _touchedKeyPieIndex = index),
        ),
      ),
    );
  }

  Widget _buildTimeTrendSection() {
    return _DashboardCard(
      title: '调用趋势',
      child: SizedBox(
        height: 350,
        child: _TrendBarChart(
          buckets: _trendBuckets,
          selectedIndex: _selectedBarIndex,
          groupByDay: _timeRange != '24h',
          onTap: (index) {
            setState(() {
              _selectedBarIndex = index;
            });
            if (index != -1) {
              final bucket = _trendBuckets[index];
              final start = bucket.time;
              final end = _timeRange == '24h'
                  ? start.add(const Duration(hours: 1))
                  : DateTime(start.year, start.month, start.day, 23, 59, 59);
              _loadDetailedLogs(start, end);
            } else {
              _loadData(); // Reload full period logs
            }
          },
        ),
      ),
    );
  }

  Widget _buildDetailedLogList() {
    return _DashboardCard(
      title: _selectedBarIndex != -1 ? '选中时段详情' : '最近调用记录',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _detailedLogs.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final log = _detailedLogs[index];
          return StdListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.api,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(log.model?.friendlyName ?? log.usage.modelId),
            subtitle: Row(
              children: [
                Text(DateFormat('MM-dd HH:mm:ss').format(log.usage.time)),
                if (log.usage.cost != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${log.usage.cost!.toStringAsFixed(4)} ${log.usage.currency ?? ''}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.redAccent.withAlpha(200),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${log.usage.totalTokens} tokens',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${log.usage.promptTokens}P / ${log.usage.completionTokens}C',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _DashboardCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _ModelDistributionPieChart extends StatelessWidget {
  final List<({Model? model, String modelId, int total, double cost})> buckets;
  final int? touchedIndex;
  final Function(int?) onTouch;

  const _ModelDistributionPieChart({
    required this.buckets,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) return const Center(child: Text('暂无数据'));

    final total = buckets.fold(0, (sum, item) => sum + item.total);

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            if (!event.isInterestedForInteractions ||
                pieTouchResponse == null ||
                pieTouchResponse.touchedSection == null) {
              onTouch(-1);
              return;
            }
            onTouch(pieTouchResponse.touchedSection!.touchedSectionIndex);
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 4,
        centerSpaceRadius: 60,
        sections: List.generate(buckets.length, (i) {
          final isTouched = i == touchedIndex;
          final radius = isTouched ? 65.0 : 60.0;
          final fontSize = isTouched ? 16.0 : 14.0;
          final bucket = buckets[i];
          final percentage = (bucket.total / total * 100).toStringAsFixed(1);

          return PieChartSectionData(
            color: Colors.primaries[i % Colors.primaries.length],
            value: bucket.total.toDouble(),
            title: isTouched
                ? '${bucket.model?.friendlyName ?? bucket.modelId}\n$percentage%'
                : '$percentage%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
      ),
    );
  }
}

class _KeyDistributionPieChart extends StatelessWidget {
  final List<({ApiKey key, int total, double cost})> buckets;
  final int? touchedIndex;
  final Function(int?) onTouch;

  const _KeyDistributionPieChart({
    required this.buckets,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) return const Center(child: Text('暂无数据'));

    final total = buckets.fold(0, (sum, item) => sum + item.total);

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            if (!event.isInterestedForInteractions ||
                pieTouchResponse == null ||
                pieTouchResponse.touchedSection == null) {
              onTouch(-1);
              return;
            }
            onTouch(pieTouchResponse.touchedSection!.touchedSectionIndex);
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 4,
        centerSpaceRadius: 60,
        sections: List.generate(buckets.length, (i) {
          final isTouched = i == touchedIndex;
          final radius = isTouched ? 65.0 : 60.0;
          final bucket = buckets[i];
          final label =
              bucket.key.remark ??
              bucket.key.key.substring(math.max(0, bucket.key.key.length - 6));
          final percentage = (bucket.total / total * 100).toStringAsFixed(1);

          return PieChartSectionData(
            color: Colors.primaries[(i + 5) % Colors.primaries.length],
            value: bucket.total.toDouble(),
            title: isTouched ? '$label\n$percentage%' : '$percentage%',
            radius: radius,
            titleStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
      ),
    );
  }
}

class _TrendBarChart extends StatelessWidget {
  final List<({DateTime time, int total, double cost, String? currency})>
  buckets;
  final int selectedIndex;
  final bool groupByDay;
  final Function(int) onTap;

  const _TrendBarChart({
    required this.buckets,
    required this.selectedIndex,
    required this.groupByDay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) return const Center(child: Text('暂无数据'));

    final maxVal = buckets
        .fold(0, (max, item) => math.max(max, item.total))
        .toDouble();
    final dateFormat = groupByDay ? DateFormat('MM-dd') : DateFormat('HH:mm');

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal * 1.2,
        barTouchData: BarTouchData(
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            if (event is FlTapUpEvent &&
                barTouchResponse != null &&
                barTouchResponse.spot != null) {
              onTap(barTouchResponse.spot!.touchedBarGroupIndex);
            }
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final bucket = buckets[groupIndex];
              return BarTooltipItem(
                '${dateFormat.format(bucket.time)}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '${bucket.total} tokens',
                    style: const TextStyle(color: Colors.yellow, fontSize: 12),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= buckets.length)
                  return const SizedBox.shrink();
                // Show every Nth label to avoid overcrowding
                if (buckets.length > 10 &&
                    value.toInt() % (buckets.length ~/ 6) != 0)
                  return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    dateFormat.format(buckets[value.toInt()].time),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(buckets.length, (i) {
          final isSelected = i == selectedIndex;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: buckets[i].total.toDouble(),
                color: isSelected ? Colors.orange : Colors.blue.withAlpha(180),
                width: isSelected ? 18 : 12,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxVal * 1.2,
                  color: Colors.blue.withAlpha(10),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
