import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'api_database.dart';
import 'api_models.dart';
import '../generated/l10n.dart';

class TokenUsageDashboard extends StatefulWidget {
  final ApiProvider provider;

  const TokenUsageDashboard({super.key, required this.provider});

  @override
  State<TokenUsageDashboard> createState() => _TokenUsageDashboardState();
}

class _TokenUsageDashboardState extends State<TokenUsageDashboard> {
  List<ApiKeyUsage> _recentUsage = [];
  bool _isLoading = true;
  String _timeRange = '7d'; // '24h', '7d', '30d'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final now = DateTime.now();
    DateTime start;
    if (_timeRange == '24h') {
      start = now.subtract(const Duration(hours: 24));
    } else if (_timeRange == '30d') {
      start = now.subtract(const Duration(days: 30));
    } else {
      start = now.subtract(const Duration(days: 7));
    }

    final usage = await ApiDatabase.instance.getProviderUsage(
      widget.provider.id,
      start: start,
    );
    if (mounted) {
      setState(() {
        _recentUsage = usage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("${widget.provider.name} ${s.token_usage}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [const Color(0xFFF0F2F5), const Color(0xFFFFFFFF)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildTimeRangeSelector(),
                    const SizedBox(height: 16),
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    _buildMainChart(),
                    const SizedBox(height: 24),
                    _buildBreakdownSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: '24h', label: Text('24h')),
        ButtonSegment(value: '7d', label: Text('7d')),
        ButtonSegment(value: '30d', label: Text('30d')),
      ],
      selected: {_timeRange},
      onSelectionChanged: (val) {
        setState(() => _timeRange = val.first);
        _loadData();
      },
    );
  }

  Widget _buildSummaryCards() {
    int totalPrompt = 0;
    int totalCompletion = 0;
    for (var u in _recentUsage) {
      totalPrompt += u.usage.promptTokens;
      totalCompletion += u.usage.completionTokens;
    }
    int total = totalPrompt + totalCompletion;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: S.of(context).total_tokens,
            value: NumberFormat.compact().format(total),
            color: Colors.blue,
            icon: Icons.token,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: S.of(context).prompt,
            value: NumberFormat.compact().format(totalPrompt),
            color: Colors.green,
            icon: Icons.input,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: S.of(context).completion,
            value: NumberFormat.compact().format(totalCompletion),
            color: Colors.orange,
            icon: Icons.output,
          ),
        ),
      ],
    );
  }

  Widget _buildMainChart() {
    // Group usage by day or hour
    Map<String, int> grouped = {};
    final dateFormat = _timeRange == '24h' 
        ? DateFormat('HH:00') 
        : DateFormat('MM-dd');

    for (var u in _recentUsage) {
      final key = dateFormat.format(u.time);
      grouped[key] = (grouped[key] ?? 0) + u.usage.total;
    }

    final sortedKeys = grouped.keys.toList()..sort();
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedKeys.length; i++) {
      spots.add(FlSpot(i.toDouble(), grouped[sortedKeys[i]]!.toDouble()));
    }

    if (spots.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(child: Text(S.of(context).no_data_period)),
      );
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).usage_trend, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        int idx = val.toInt();
                        if (idx >= 0 && idx < sortedKeys.length && idx % (sortedKeys.length > 5 ? (sortedKeys.length / 5).ceil() : 1) == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(sortedKeys[idx], style: const TextStyle(fontSize: 10)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [Colors.blue.withOpacity(0.3), Colors.purple.withOpacity(0.01)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownSection() {
    // Model breakdown
    Map<String, int> modelUsage = {};
    for (var u in _recentUsage) {
      modelUsage[u.modelId] = (modelUsage[u.modelId] ?? 0) + u.usage.total;
    }
    final sortedModels = modelUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.of(context).model_breakdown, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        ...sortedModels.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(e.key),
            trailing: Text("${NumberFormat.compact().format(e.value)} tokens"),
            leading: const Icon(Icons.psychology),
          ),
        )),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
