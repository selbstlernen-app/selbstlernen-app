import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/statistics_ui_utils.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

class MoodLineChart extends StatelessWidget {
  const MoodLineChart({
    required this.instances,
    this.showAllInstances = false,
    super.key,
  });

  final List<SessionInstanceModel> instances;
  final bool showAllInstances;

  @override
  Widget build(BuildContext context) {
    // Filter and sort instances with mood ratings
    final moodInstances = instances.where((i) => i.mood != null).toList()
      ..sort((a, b) => a.completedAt!.compareTo(b.completedAt!));

    // Get last 5 or all instances based on toggle
    final displayInstances = showAllInstances
        ? moodInstances
        : moodInstances.length > 4
        ? moodInstances.sublist(moodInstances.length - 5)
        : moodInstances;

    // Map the counts of instances on the same day, group by date
    final dayCounts = <String, int>{};
    for (final instance in displayInstances) {
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
            maxX: (displayInstances.length - 1).toDouble(),
            minY: 0,
            maxY: 4,
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppPalette.grey.withValues(alpha: 0.3),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= displayInstances.length) {
                      return const SizedBox.shrink();
                    }
                    final date = displayInstances[index].completedAt!;
                    return SideTitleWidget(
                      meta: meta,
                      child: Transform.rotate(
                        angle: showAllInstances ? -20 : 0,
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
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) {
                    final moodIndex = value.toInt();
                    if (moodIndex < 0 ||
                        moodIndex >= Constants.emojiMoods.length) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      Constants.emojiMoods[moodIndex],
                      style: const TextStyle(fontSize: 24),
                    );
                  },
                ),
              ),
            ),
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

            lineBarsData: [
              LineChartBarData(
                spots: displayInstances
                    .asMap()
                    .entries
                    .map(
                      (entry) => FlSpot(
                        entry.key.toDouble(),
                        entry.value.mood!.toDouble(),
                      ),
                    )
                    .toList(),
                isCurved: true,
                preventCurveOverShooting: true,
                preventCurveOvershootingThreshold: 0,
                color: AppPalette.amber,
                barWidth: 3,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(
                  show: true,
                  color: AppPalette.amber.withValues(alpha: 0.1),
                ),
                dotData: FlDotData(
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: showAllInstances ? 4 : 6,
                      color: AppPalette.amber,
                      strokeWidth: 2,
                      strokeColor: context.colorScheme.surface,
                    );
                  },
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                getTooltipColor: (touchedSpot) =>
                    context.colorScheme.inverseSurface,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final index = spot.x.toInt();
                    final instance = displayInstances[index];
                    final moodEmoji = Constants.emojiMoods[spot.y.toInt()];
                    final key = DateFormat(
                      'yyyyMMdd',
                    ).format(instance.completedAt!);

                    return LineTooltipItem(
                      '''$moodEmoji\n${_getMoodLabel(spot.y.toInt())}\n'''
                      '''${dayCounts[key]! > 1 ? DateFormat('dd.MM HH:mm').format(instance.completedAt!) : DateFormat('dd.MM').format(instance.completedAt!)}''',

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

  String _getMoodLabel(int index) {
    switch (index) {
      case 0:
        return 'Sehr\nSchlecht';
      case 1:
        return 'Schlecht';
      case 2:
        return 'Okay';
      case 3:
        return 'Gut';
      case 4:
        return 'Super';
      default:
        return '';
    }
  }
}
