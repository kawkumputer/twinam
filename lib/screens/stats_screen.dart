import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/counter.dart';
import '../providers/counter_provider.dart';
import '../providers/settings_provider.dart';

class StatsScreen extends StatefulWidget {
  final String counterId;
  const StatsScreen({super.key, required this.counterId});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedPeriod = 0; // 0=week, 1=month

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(settings.locale);
    final provider = context.watch<CounterProvider>();
    final counter = provider.getCounter(widget.counterId);

    if (counter == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final counterColor = Color(counter.colorValue);
    final chartData = _getChartData(counter);

    return Scaffold(
      appBar: AppBar(
        title: Text('${counter.emoji} ${l10n.translate('stats')}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            Row(
              children: [
                _buildPeriodChip(context, l10n.translate('thisWeek'), 0, counterColor),
                const SizedBox(width: 10),
                _buildPeriodChip(context, l10n.translate('thisMonth'), 1, counterColor),
              ],
            ),

            const SizedBox(height: 28),

            // Chart
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: chartData.isEmpty
                  ? Center(
                      child: Text(
                        l10n.translate('noCounters'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxY(chartData),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                rod.toY.round().toString(),
                                TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < chartData.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      chartData[index].label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _getMaxY(chartData) / 4,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: chartData.asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.value.toDouble(),
                                color: counterColor,
                                width: _selectedPeriod == 0 ? 28 : 14,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),

            const SizedBox(height: 28),

            // Stats cards
            Row(
              children: [
                Expanded(child: _buildStatCard(context, l10n.translate('total'), '${_getTotal(counter)}', counterColor)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, l10n.translate('average'), _getAverage(counter), counterColor)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard(context, l10n.translate('best'), '${_getBest(counter)}', counterColor)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, l10n.translate('today'), '${counter.value}', counterColor)),
              ],
            ),
            if (counter.goal != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      '🔥 ${l10n.translate('streak')}',
                      '${counter.currentStreak} ${l10n.translate('days')}',
                      const Color(0xFFFFB74D),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      l10n.translate('goal'),
                      '${counter.goal}',
                      counterColor,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 28),

            // Activity heatmap
            _buildHeatmap(context, counter, counterColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(BuildContext context, String label, int index, Color color) {
    final isSelected = _selectedPeriod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  List<_ChartEntry> _getChartData(Counter counter) {
    final now = DateTime.now();

    if (_selectedPeriod == 0) {
      // Last 7 days
      return List.generate(7, (i) {
        final date = now.subtract(Duration(days: 6 - i));
        final dayEntries = counter.history.where((e) =>
            !e.isReset &&
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day);
        final maxVal = dayEntries.isEmpty ? 0 : dayEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
        return _ChartEntry(
          label: DateFormat('E').format(date).substring(0, 2),
          value: maxVal,
        );
      });
    } else {
      // Last 30 days (grouped by 5-day periods)
      return List.generate(6, (i) {
        final start = now.subtract(Duration(days: 29 - i * 5));
        final end = now.subtract(Duration(days: 24 - i * 5));
        final entries = counter.history.where((e) =>
            !e.isReset &&
            e.date.isAfter(start.subtract(const Duration(days: 1))) &&
            e.date.isBefore(end.add(const Duration(days: 1))));
        final maxVal = entries.isEmpty ? 0 : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
        return _ChartEntry(
          label: DateFormat('d/M').format(start),
          value: maxVal,
        );
      });
    }
  }

  double _getMaxY(List<_ChartEntry> data) {
    if (data.isEmpty) return 10;
    final maxVal = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return (maxVal + 2).toDouble();
  }

  int _getTotal(Counter counter) {
    return counter.history.where((e) => !e.isReset).fold(0, (sum, e) => sum + e.value);
  }

  String _getAverage(Counter counter) {
    final now = DateTime.now();
    final daysSinceCreation = now.difference(counter.createdAt).inDays + 1;
    if (daysSinceCreation == 0) return '0';
    final avg = _getTotal(counter) / daysSinceCreation;
    return avg.toStringAsFixed(1);
  }

  int _getBest(Counter counter) {
    if (counter.history.isEmpty) return counter.value;
    return counter.history.where((e) => !e.isReset).fold(0, (max, e) => e.value > max ? e.value : max);
  }

  Widget _buildHeatmap(BuildContext context, Counter counter, Color color) {
    final now = DateTime.now();
    const totalDays = 35; // 5 weeks
    final startDate = now.subtract(const Duration(days: totalDays - 1));

    // Build a map of date → max value
    final Map<String, int> dayValues = {};
    int maxVal = 1;
    for (int i = 0; i < totalDays; i++) {
      final date = startDate.add(Duration(days: i));
      final key = '${date.year}-${date.month}-${date.day}';
      final dayEntries = counter.history.where((e) =>
          !e.isReset &&
          e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day);
      final val = dayEntries.isEmpty ? 0 : dayEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
      dayValues[key] = val;
      if (val > maxVal) maxVal = val;
    }

    // Build 5 rows of 7 columns
    final weekDayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📅 Activity',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          // Day labels
          Row(
            children: weekDayLabels.map((label) {
              return Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                          fontSize: 10,
                        ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          // Grid of days
          ...List.generate(5, (week) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: List.generate(7, (day) {
                  final dayIndex = week * 7 + day;
                  final date = startDate.add(Duration(days: dayIndex));
                  final key = '${date.year}-${date.month}-${date.day}';
                  final val = dayValues[key] ?? 0;
                  final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
                  final isFuture = date.isAfter(now);

                  double intensity = 0;
                  if (val > 0 && maxVal > 0) {
                    intensity = (val / maxVal).clamp(0.15, 1.0);
                  }

                  return Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isFuture
                              ? Colors.transparent
                              : val > 0
                                  ? color.withValues(alpha: intensity)
                                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                          border: isToday
                              ? Border.all(color: color, width: 1.5)
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ChartEntry {
  final String label;
  final int value;
  _ChartEntry({required this.label, required this.value});
}
