import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/theme/app_palette.dart';
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
    final theme = Theme.of(context);

    // Filter and sort instances with mood ratings
    final moodInstances = instances.where((i) => i.mood != null).toList()
      ..sort((a, b) => a.completedAt!.compareTo(b.completedAt!));

    if (moodInstances.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '''Noch keine Stimmungsdaten vorhanden.\nBewerte deine Lerneinheiten, um Trends zu erkennen!''',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    // Get last 5 or all instances based on toggle
    final displayInstances = showAllInstances
        ? moodInstances
        : moodInstances.length > 5
        ? moodInstances.sublist(moodInstances.length - 5)
        : moodInstances;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
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
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= displayInstances.length) {
                          return const SizedBox.shrink();
                        }
                        final date = displayInstances[index].completedAt!;
                        return Transform.rotate(
                          angle: showAllInstances ? -20 : 0,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              showAllInstances
                                  ? '#${index + 1}'
                                  : '${date.month}/${date.day}',
                              style: theme.textTheme.bodySmall,
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
                      reservedSize: 40,
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
                minX: 0,
                maxX: (displayInstances.length - 1).toDouble(),
                minY: 0,
                maxY: 4,
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
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: theme.colorScheme.primary,
                          strokeWidth: 2,
                          strokeColor: theme.colorScheme.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        theme.colorScheme.inverseSurface,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        final instance = displayInstances[index];
                        final moodEmoji = Constants.emojiMoods[spot.y.toInt()];

                        return LineTooltipItem(
                          '''$moodEmoji\n${_getMoodLabel(spot.y.toInt())}\n'''
                          '''${instance.completedAt!.month}/${instance.completedAt!.day}''',
                          TextStyle(
                            color: theme.colorScheme.onInverseSurface,
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
        ],
      ),
    );
  }

  String _getMoodLabel(int index) {
    switch (index) {
      case 0:
        return 'Sehr Schlecht';
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
