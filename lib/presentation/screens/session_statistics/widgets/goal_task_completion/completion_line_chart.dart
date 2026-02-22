import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/statistics_ui_utils.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/goal_task_completion/goal_task_completion_card.dart';

class CompletionLineChart extends StatelessWidget {
  const CompletionLineChart({
    required this.instances,
    required this.avg,
    this.showAllInstances = false,
    this.viewMode = CompletionViewMode.combined,

    super.key,
  });
  final List<SessionInstanceModel> instances;
  final bool showAllInstances;
  final CompletionViewMode viewMode;
  final double avg;

  double _combinedRate(SessionInstanceModel m) {
    return (m.completedGoalsRate + m.completedTasksRate) / 2;
  }

  @override
  Widget build(BuildContext context) {
    // Filter and sort instances with mood ratings
    final sortedInstances =
        instances.where((i) => i.completedAt != null).toList()
          ..sort((a, b) => a.completedAt!.compareTo(b.completedAt!));

    if (sortedInstances.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '''Noch keine Einheit abgeschlossen.\nSchließe Ziele und Aufgaben in deiner Lerneinheiten ab, um Trends zu erkennen!''',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    // Get last 5 or all instances based on toggle
    final displayInstances = showAllInstances
        ? sortedInstances
        : sortedInstances.length > 4
        ? sortedInstances.sublist(sortedInstances.length - 5)
        : sortedInstances;

    // Map the counts of instances on the same day, group by date
    final dayCounts = <String, int>{};
    for (final instance in displayInstances) {
      final date = instance.completedAt!;
      final key = DateFormat('yyyyMMdd').format(date);
      dayCounts[key] = (dayCounts[key] ?? 0) + 1;
    }

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: 25,
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
                  interval: 25,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toStringAsFixed(0)} %',
                      style: context.textTheme.bodySmall,
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
            maxY: 100,
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.indigo,
                    ),
                    labelResolver: (_) => 'Ø Avg',
                  ),
                  y: avg,
                  dashArray: [6, 4],
                  color: AppPalette.indigoLight,
                ),
              ],
            ),
            lineBarsData: [
              buildLineChartData(
                context: context,
                instances: displayInstances,
                valueSelector: viewMode == CompletionViewMode.combined
                    ? _combinedRate
                    : viewMode == CompletionViewMode.goals
                    ? (m) => m.completedGoalsRate
                    : (m) => m.completedTasksRate,
                color: viewMode == CompletionViewMode.goals
                    ? AppPalette.sky
                    : viewMode == CompletionViewMode.tasks
                    ? AppPalette.emerald
                    : AppPalette.indigo,
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                getTooltipColor: (touchedSpot) =>
                    context.colorScheme.inverseSurface,
                getTooltipItems: (touchedSpots) {
                  if (touchedSpots.isEmpty) return [];

                  final x = touchedSpots.first.x.toInt();
                  final instance = displayInstances[x];

                  final date = DateFormat(
                    'dd.MM',
                  ).format(instance.completedAt!);

                  final value = viewMode == CompletionViewMode.combined
                      ? _combinedRate(instance)
                      : (viewMode == CompletionViewMode.goals
                            ? instance.completedGoalsRate
                            : instance.completedTasksRate);

                  final label = viewMode == CompletionViewMode.combined
                      ? 'Gesamt'
                      : (viewMode == CompletionViewMode.goals
                            ? 'Ziele'
                            : 'Aufgaben');

                  return [
                    LineTooltipItem(
                      '$date\n$label: ${value.toStringAsFixed(1)}%',
                      TextStyle(
                        color: context.colorScheme.onInverseSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ];
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  LineChartBarData buildLineChartData({
    required BuildContext context,
    required List<SessionInstanceModel> instances,
    required double Function(SessionInstanceModel model) valueSelector,
    required Color color,
  }) {
    return LineChartBarData(
      spots: instances
          .asMap()
          .entries
          .map(
            (entry) => FlSpot(
              entry.key.toDouble(),
              valueSelector(entry.value),
            ),
          )
          .toList(),
      isCurved: true,
      preventCurveOverShooting: true,
      preventCurveOvershootingThreshold: 0,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: context.colorScheme.surface,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.1),
      ),
    );
  }
}
