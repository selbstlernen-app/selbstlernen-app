import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/statistics_ui_utils.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_prompt/focus_check_utils.dart';

/// Shows the focus across all session instances
class AverageFocusChart extends StatelessWidget {
  const AverageFocusChart({
    required this.instances,
    super.key,
  });

  /// List of all instances where focus checks are not empty
  final List<SessionInstanceModel> instances;

  @override
  Widget build(BuildContext context) {
    // Calculate averages of past instances and map them to their date
    final sessionAverages =
        instances
            .map((instance) {
              final average = calculateSessionAverageFocus(instance);

              return MapEntry(
                instance.completedAt ?? instance.scheduledAt,
                average,
              );
            })
            .whereType<MapEntry<DateTime, double>>()
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    final spots = sessionAverages.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    // Map the counts of instances on the same day, group by date
    final dayCounts = <String, int>{};
    for (final instance in instances) {
      final date = instance.completedAt!;
      final key = DateFormat('yyyyMMdd').format(date);
      dayCounts[key] = (dayCounts[key] ?? 0) + 1;
    }

    return SizedBox(
      height: 160,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: LineChart(
          LineChartData(
            minX: 0,
            minY: 0,
            maxY: Constants.focusEmojis.length.toDouble(),
            maxX: (instances.length - 1).toDouble(),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(
                  color: AppPalette.grey,
                ),
                left: BorderSide(
                  color: AppPalette.grey,
                ),
              ),
            ),
            gridData: FlGridData(
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppPalette.grey.withValues(alpha: 0.3),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final focusIndex = value.toInt() - 1;
                    if (focusIndex < 0 ||
                        focusIndex >= Constants.emojiMoods.length) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      Constants.focusEmojis[focusIndex],
                      style: const TextStyle(fontSize: 24),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= sessionAverages.length) {
                      return const SizedBox.shrink();
                    }
                    final date = sessionAverages[index].key;
                    return SideTitleWidget(
                      meta: meta,
                      child: Transform.rotate(
                        angle: -20,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat('dd.MM').format(date),
                            style: StatisticsUiUtils.styleBottomBar,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppPalette.blue,
                preventCurveOverShooting: true,
                preventCurveOvershootingThreshold: 0,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  getDotPainter: (spot, percent, barData, index) {
                    // Get the average focus level for this session
                    final averageFocusLevel = sessionAverages[index].value;

                    // Convert the average back to a FocusLevel enum
                    final level = valueToFocusLevel(averageFocusLevel);

                    return FlDotCirclePainter(
                      radius: 4,
                      strokeWidth: 2,
                      color: getFocusColor(level),
                      strokeColor: context.colorScheme.surface,
                    );
                  },
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final index = spot.spotIndex;
                    final date = sessionAverages[index].key;
                    final avg = sessionAverages[index].value;

                    final key = DateFormat(
                      'yyyyMMdd',
                    ).format(sessionAverages[index].key);

                    return LineTooltipItem(
                      '''${dayCounts[key]! > 1 ? DateFormat('dd.MM\nhh:mm').format(date) : DateFormat('dd.MM').format(date)}'''
                      '''\nØ ${avg.toStringAsFixed(1)}''',
                      TextStyle(
                        color: context.colorScheme.onInverseSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
