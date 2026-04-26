import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uni_chat/api_configs/api_database.dart';
import 'package:uni_chat/api_configs/api_models.dart';
import 'package:uni_chat/utils/prebuilt_widgets.dart';
import 'package:uni_chat/utils/uni_theme.dart';
import 'package:uni_chat/utils/llm_icons.dart';
import 'package:uni_chat/l10n/generated/l10n.dart';

class TokenUsageDashboard extends ConsumerStatefulWidget {
  final String providerId;

  const TokenUsageDashboard({super.key, required this.providerId});

  @override
  ConsumerState<TokenUsageDashboard> createState() =>
      _TokenUsageDashboardState();
}

class DailyLogSummary {
  final String dateStr;
  final int callCount;
  final int totalTokens;
  final int promptTokens;
  final int completionTokens;
  final double cost;
  final String? currency;

  DailyLogSummary({
    required this.dateStr,
    required this.callCount,
    required this.totalTokens,
    required this.promptTokens,
    required this.completionTokens,
    required this.cost,
    this.currency,
  });
}

// 独立顶层函数，供给 compute 使用，支持 24h 小时级聚合
List<DailyLogSummary> _aggregateLogsByTimeRange(Map<String, dynamic> params) {
  final logs = params['logs'] as List<({ApiKeyUsage usage, Model? model})>;
  final is24h = params['is24h'] as bool;

  final groupMap = <String, DailyLogSummary>{};
  final dateFormat = is24h ? DateFormat('MM-dd HH:00') : DateFormat('yyyy-MM-dd');

  for (var log in logs) {
    final dateStr = dateFormat.format(log.usage.time);
    final existing = groupMap[dateStr];

    groupMap[dateStr] = DailyLogSummary(
      dateStr: dateStr,
      callCount: (existing?.callCount ?? 0) + 1,
      totalTokens: (existing?.totalTokens ?? 0) + (log.usage.totalTokens ?? 0),
      promptTokens: (existing?.promptTokens ?? 0) + (log.usage.promptTokens ?? 0),
      completionTokens: (existing?.completionTokens ?? 0) + (log.usage.completionTokens ?? 0),
      cost: (existing?.cost ?? 0.0) + (log.usage.cost ?? 0.0),
      currency: log.usage.currency ?? existing?.currency,
    );
  }

  final result = groupMap.values.toList()
    ..sort((a, b) => b.dateStr.compareTo(a.dateStr));
  return result;
}

class _TokenUsageDashboardState extends ConsumerState<TokenUsageDashboard> {
  String _timeRange = '24h';
  bool _isLoading = true;
  bool _isChangingRange = false;
  ApiProvider? _provider;

  ({int prompt, int completion, int cached, Map<String, double> costs})
  _summary = (prompt: 0, completion: 0, cached: 0, costs: {});
  List<({DateTime time, int total, double cost, String? currency})>
  _trendBuckets = [];
  List<({Model? model, String modelId, int total, double cost})> _modelBuckets =
      [];
  List<({ApiKey key, int total, double cost})> _keyBuckets = [];
  List<DailyLogSummary> _dailySummaries = [];

  int _selectedBarIndex = -1;
  int? _touchedPieIndex;
  int? _touchedKeyPieIndex;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool isChangingRange = false}) async {
    if (isChangingRange) {
      setState(() => _isChangingRange = true);
    } else {
      setState(() => _isLoading = true);
    }
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
      _provider = await adb.getProviderById(widget.providerId);

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
        _isChangingRange = false;
        _selectedBarIndex = -1;
        _dailySummaries = [];
      });

      _loadDetailedLogs(start, now);
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
        _isChangingRange = false;
      });
    }
  }

  Future<void> _loadDetailedLogs(DateTime start, DateTime end) async {
    try {
      final logs = await ApiDatabase.instance.getDetailedUsageLogs(
        widget.providerId,
        start: start,
        end: end,
      );
      
      final summaries = await compute(_aggregateLogsByTimeRange, {
        'logs': logs,
        'is24h': _timeRange == '24h',
      });

      setState(() {
        _dailySummaries = summaries;
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

    final theme = UniTheme.of(context);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final total = _summary.prompt + _summary.completion;

              final topHeight = _summary.costs.isNotEmpty ? 350.0 : 240.0;

              final topLayout = isWide
                  ? SizedBox(
                      height: topHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _SummaryCard(
                                          title: S.of(context).dashboard_prompt_tokens,
                                          value: NumberFormat.compact().format(_summary.prompt),
                                          icon: Icons.upload_file,
                                          color: const Color(0xFF3B82F6),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _SummaryCard(
                                          title: S.of(context).dashboard_completion_tokens,
                                          value: NumberFormat.compact().format(_summary.completion),
                                          icon: Icons.download_done,
                                          color: const Color(0xFF10B981),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _SummaryCard(
                                          title: S.of(context).dashboard_total_tokens,
                                          value: NumberFormat.compact().format(total),
                                          icon: Icons.summarize,
                                          color: const Color(0xFFF59E0B),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _SummaryCard(
                                          title: S.of(context).dashboard_cache_saved,
                                          value: NumberFormat.compact().format(_summary.cached),
                                          icon: Icons.bolt,
                                          color: const Color(0xFF8B5CF6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_summary.costs.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: Row(
                                      children: _summary.costs.entries.map((e) {
                                        return Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              right: e.key == _summary.costs.keys.last ? 0 : 12,
                                            ),
                                            child: _SummaryCard(
                                              title: S.of(context).dashboard_est_cost(e.key),
                                              value: e.value.toStringAsFixed(4),
                                              icon: Icons.account_balance_wallet,
                                              color: const Color(0xFFEF4444),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 4,
                            child: _buildModelDistributionCard(useExpanded: true),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        _buildSummarySection(),
                        const SizedBox(height: 20),
                        _buildModelDistributionCard(),
                      ],
                    );

              final bottomLayout = isWide
                  ? SizedBox(
                      height: 320,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 6, child: _buildTimeTrendSection(useExpanded: true)),
                          if (_keyBuckets.length > 1) ...[
                            const SizedBox(width: 16),
                            Expanded(flex: 4, child: _buildKeyDistributionCard(useExpanded: true)),
                          ],
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        _buildTimeTrendSection(),
                        const SizedBox(height: 20),
                        if (_keyBuckets.length > 1) _buildKeyDistributionCard(),
                      ],
                    );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  topLayout,
                  const SizedBox(height: 20),
                  if (!isWide && _keyBuckets.length > 1) ...[
                    _buildKeyDistributionCard(),
                    const SizedBox(height: 20),
                  ],
                  bottomLayout,
                  const SizedBox(height: 20),
                  _buildDetailedLogList(),
                ],
              );
            },
          ),
        ),
        if (_isChangingRange)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              minHeight: 3,
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    final theme = UniTheme.of(context);
    final ranges = ['24h', '7d', '30d'];
    final labels = ['24h', '7d', '30d'];
    
    String imagePath = 'resources/unknown.png';
    if (_provider != null) {
      imagePath = LLMImageIndexer.getImagePath(_provider!.preset ?? _provider!.name);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (_provider != null) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.thirdGradeColor),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _provider!.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
            ],
          ],
        ),
        StdSegmentedControl(
          labels: labels,
          currentIndex: ranges.indexOf(_timeRange),
          onIndexChanged: (index) {
            if (ranges[index] != _timeRange) {
              setState(() {
                _timeRange = ranges[index];
                _loadData(isChangingRange: true);
              });
            }
          },
          width: 220,
          margin: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildSummarySection() {
    final total = _summary.prompt + _summary.completion;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;
        final cards = [
          _SummaryCard(
            title: S.of(context).dashboard_prompt_tokens,
            value: NumberFormat.compact().format(_summary.prompt),
            icon: Icons.upload_file,
            color: const Color(0xFF3B82F6),
          ),
          _SummaryCard(
            title: S.of(context).dashboard_completion_tokens,
            value: NumberFormat.compact().format(_summary.completion),
            icon: Icons.download_done,
            color: const Color(0xFF10B981),
          ),
          _SummaryCard(
            title: S.of(context).dashboard_total_tokens,
            value: NumberFormat.compact().format(total),
            icon: Icons.summarize,
            color: const Color(0xFFF59E0B),
          ),
          _SummaryCard(
            title: S.of(context).dashboard_cache_saved,
            value: NumberFormat.compact().format(_summary.cached),
            icon: Icons.bolt,
            color: const Color(0xFF8B5CF6),
          ),
        ];

        return Column(
          children: [
            if (isNarrow)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: cards,
              )
            else
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: cards,
              ),
            if (_summary.costs.isNotEmpty) ...[
              const SizedBox(height: 12),
              Column(
                children: _summary.costs.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SummaryCard(
                      title: S.of(context).dashboard_est_cost(e.key),
                      value: e.value.toStringAsFixed(4),
                      icon: Icons.account_balance_wallet,
                      color: const Color(0xFFEF4444),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildModelDistributionCard({bool useExpanded = false}) {
    final chartWidget = _ModelDistributionPieChart(
      buckets: _modelBuckets,
      touchedIndex: _touchedPieIndex,
      onTouch: (index) => setState(() => _touchedPieIndex = index),
    );
    
    return _DashboardCard(
      title: S.of(context).dashboard_model_dist,
      useExpanded: useExpanded,
      child: useExpanded ? chartWidget : SizedBox(height: 220, child: chartWidget),
    );
  }

  Widget _buildKeyDistributionCard({bool useExpanded = false}) {
    final chartWidget = _KeyDistributionPieChart(
      buckets: _keyBuckets,
      touchedIndex: _touchedKeyPieIndex,
      onTouch: (index) => setState(() => _touchedKeyPieIndex = index),
    );

    return _DashboardCard(
      title: S.of(context).dashboard_key_dist,
      useExpanded: useExpanded,
      child: useExpanded ? chartWidget : SizedBox(height: 220, child: chartWidget),
    );
  }

  Widget _buildTimeTrendSection({bool useExpanded = false}) {
    final chartWidget = _TrendBarChart(
      buckets: _trendBuckets,
      selectedIndex: _selectedBarIndex,
      groupByDay: _timeRange != '24h',
      onTap: (index) {
        setState(() {
          _selectedBarIndex = index;
        });
        if (index != -1 && index < _trendBuckets.length) {
          final bucket = _trendBuckets[index];
          final start = bucket.time;
          final end = _timeRange == '24h'
              ? start.add(const Duration(hours: 1))
              : DateTime(start.year, start.month, start.day, 23, 59, 59);
          _loadDetailedLogs(start, end);
        } else {
          _loadData(isChangingRange: true);
        }
      },
    );
    
    return _DashboardCard(
      title: S.of(context).dashboard_usage_trend,
      useExpanded: useExpanded,
      child: useExpanded ? chartWidget : SizedBox(height: 300, child: chartWidget),
    );
  }

  Widget _buildDetailedLogList() {
    final theme = UniTheme.of(context);
    return _DashboardCard(
      title: _selectedBarIndex != -1 
          ? S.of(context).dashboard_selected_period 
          : (_timeRange == '24h' ? S.of(context).dashboard_hour_record : S.of(context).dashboard_history_record),
      child: _dailySummaries.isEmpty
          ? Center(child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(S.of(context).dashboard_no_record, style: const TextStyle(color: Colors.grey)),
            ))
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dailySummaries.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: theme.thirdGradeColor.withAlpha(100),
              ),
              itemBuilder: (context, index) {
                final summary = _dailySummaries[index];
                return StdListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.secondGradeColor,
                    child: Icon(
                      _timeRange == '24h' ? Icons.access_time : Icons.calendar_today,
                      size: 18,
                      color: theme.primaryColor,
                    ),
                  ),
                  title: Text(
                    summary.dateStr,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.textColor,
                    ),
                  ),
                  subtitle: Text(
                    S.of(context).dashboard_call_times(summary.callCount),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textColor.withAlpha(150),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${summary.totalTokens} tokens',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textColor,
                        ),
                      ),
                      Text(
                        '${summary.promptTokens}P / ${summary.completionTokens}C',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.textColor.withAlpha(120),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _SummaryCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UniTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.zeroGradeColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.thirdGradeColor.withAlpha(150),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.textColor.withAlpha(180),
                ),
              ),
              Icon(icon, color: color.withAlpha(200), size: 16),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends ConsumerWidget {
  final String title;
  final Widget child;
  final bool useExpanded;

  const _DashboardCard({
    required this.title,
    required this.child,
    this.useExpanded = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UniTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.zeroGradeColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.thirdGradeColor.withAlpha(150),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 20),
          useExpanded ? Expanded(child: child) : child,
        ],
      ),
    );
  }
}

List<Color> _getChartPalette(UniThemeData theme) {
  final isDark = theme.zeroGradeColor.computeLuminance() < 0.5;
  if (isDark) {
    return [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFFEC4899), // Pink
    ];
  } else {
    return [
      const Color(0xFF2563EB),
      const Color(0xFF059669),
      const Color(0xFFD97706),
      const Color(0xFFDC2626),
      const Color(0xFF7C3AED),
      const Color(0xFFDB2777),
    ];
  }
}

class _ModelDistributionPieChart extends ConsumerWidget {
  final List<({Model? model, String modelId, int total, double cost})> buckets;
  final int? touchedIndex;
  final Function(int?) onTouch;

  const _ModelDistributionPieChart({
    required this.buckets,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UniTheme.of(context);
    if (buckets.isEmpty) return Center(child: Text(S.of(context).dashboard_no_record));

    final total = buckets.fold(0, (sum, item) => sum + item.total);
    final colors = _getChartPalette(theme);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;

        final chartWidget = PieChart(
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
            sectionsSpace: 2,
            centerSpaceRadius: 45,
            sections: List.generate(buckets.length, (i) {
              final isTouched = i == touchedIndex;
              final radius = isTouched ? 35.0 : 30.0;
              final bucket = buckets[i];

              return PieChartSectionData(
                color: colors[i % colors.length],
                value: bucket.total.toDouble(),
                title: '', 
                radius: radius,
              );
            }),
          ),
        );

        final legendWidget = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(buckets.length, (i) {
            final bucket = buckets[i];
            final color = colors[i % colors.length];
            final percentage = (bucket.total / total * 100).toStringAsFixed(1);
            final isSelected = i == touchedIndex;

            return MouseRegion(
              onEnter: (_) => onTouch(i),
              onExit: (_) => onTouch(-1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withAlpha(30)
                      : theme.secondGradeColor.withAlpha(100),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      bucket.model?.friendlyName ?? bucket.modelId,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: theme.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );

        if (isNarrow) {
          return Column(
            children: [
              Expanded(child: chartWidget),
              const SizedBox(height: 12),
              legendWidget,
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(flex: 4, child: chartWidget),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: legendWidget,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class _KeyDistributionPieChart extends ConsumerWidget {
  final List<({ApiKey key, int total, double cost})> buckets;
  final int? touchedIndex;
  final Function(int?) onTouch;

  const _KeyDistributionPieChart({
    required this.buckets,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UniTheme.of(context);
    if (buckets.isEmpty) return Center(child: Text(S.of(context).dashboard_no_record));

    final total = buckets.fold(0, (sum, item) => sum + item.total);
    final colors = _getChartPalette(theme);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;

        final chartWidget = PieChart(
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
            sectionsSpace: 2,
            centerSpaceRadius: 45,
            sections: List.generate(buckets.length, (i) {
              final isTouched = i == touchedIndex;
              final radius = isTouched ? 35.0 : 30.0;
              final bucket = buckets[i];

              return PieChartSectionData(
                color: colors[(i + 3) % colors.length],
                value: bucket.total.toDouble(),
                title: '',
                radius: radius,
              );
            }),
          ),
        );

        final legendWidget = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(buckets.length, (i) {
            final bucket = buckets[i];
            final color = colors[(i + 3) % colors.length];
            final percentage = (bucket.total / total * 100).toStringAsFixed(1);
            final isSelected = i == touchedIndex;

            final label =
                bucket.key.remark ??
                (bucket.key.key.length > 6
                    ? '...${bucket.key.key.substring(bucket.key.key.length - 6)}'
                    : bucket.key.key);

            return MouseRegion(
              onEnter: (_) => onTouch(i),
              onExit: (_) => onTouch(-1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withAlpha(30)
                      : theme.secondGradeColor.withAlpha(100),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: theme.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );

        if (isNarrow) {
          return Column(
            children: [
              Expanded(child: chartWidget),
              const SizedBox(height: 12),
              legendWidget,
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(flex: 4, child: chartWidget),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: legendWidget,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class _TrendBarChart extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UniTheme.of(context);
    if (buckets.isEmpty) return Center(child: Text(S.of(context).dashboard_no_record));

    final maxVal =
        buckets.fold(0, (max, item) => math.max(max, item.total)).toDouble();
    final dateFormat = groupByDay ? DateFormat('MM-dd') : DateFormat('HH:mm');

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal == 0 ? 100 : maxVal * 1.2,
        barTouchData: BarTouchData(
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            if (event is FlTapUpEvent &&
                barTouchResponse != null &&
                barTouchResponse.spot != null) {
              onTap(barTouchResponse.spot!.touchedBarGroupIndex);
            }
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => theme.secondGradeColor,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final bucket = buckets[groupIndex];
              return BarTooltipItem(
                '${dateFormat.format(bucket.time)}\n',
                TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '${bucket.total} tokens',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
                if (value.toInt() < 0 || value.toInt() >= buckets.length) {
                  return const SizedBox.shrink();
                }
                if (buckets.length > 10 &&
                    value.toInt() % (buckets.length ~/ 6 + 1) != 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    dateFormat.format(buckets[value.toInt()].time),
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textColor.withAlpha(150),
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                color: isSelected
                    ? theme.primaryColor
                    : theme.primaryColor.withAlpha(100),
                width: isSelected ? 16 : 12,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxVal == 0 ? 100 : maxVal * 1.2,
                  color: theme.secondGradeColor.withAlpha(80),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
