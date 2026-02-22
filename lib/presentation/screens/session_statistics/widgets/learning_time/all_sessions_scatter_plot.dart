import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/statistics_ui_utils.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/learning_time/learning_time_type.dart';

class AllSessionsScatterPlot extends StatelessWidget {
  const AllSessionsScatterPlot({
    required this.instances,
    required this.plannedTime,
    super.key,
  });

  final List<SessionInstanceModel> instances;
  final TimeOfDay? plannedTime;

  @override
  Widget build(BuildContext context) {
    final sorted = instances.where((i) => i.completedAt != null).toList()
      ..sort((a, b) => a.completedAt!.compareTo(b.completedAt!));

    if (sorted.isEmpty) return const SizedBox.shrink();

    final spots = sorted.asMap().entries.map((entry) {
      final i = entry.key;
      final instance = entry.value;
      final y =
          instance.completedAt!.hour + instance.completedAt!.minute / 60.0;
      final hour = instance.completedAt!.hour;
      final timeType = LearningTimeTypeDetails.fromHour(hour);

      return ScatterSpot(
        i.toDouble(),
        y,
        dotPainter: FlDotCirclePainter(
          radius: 6,
          color: timeType.color,
          strokeWidth: 2,
          strokeColor: context.colorScheme.surface,
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: ScatterChart(
            ScatterChartData(
              minX: 0,
              maxX: (sorted.length - 1).toDouble(),
              minY: 0,
              maxY: 24,
              scatterSpots: spots,

              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 6,
                    getTitlesWidget: (value, _) => Text(
                      '${value.toInt().toString().padLeft(2, '0')}:00',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: AppPalette.grey,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= sorted.length) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        child: Transform.rotate(
                          angle: -20,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              DateFormat(
                                'dd.MM',
                              ).format(sorted[index].completedAt!),
                              style: StatisticsUiUtils.styleBottomBar,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: 6,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: AppPalette.grey.withValues(alpha: 0.15),
                  strokeWidth: 1,
                ),
              ),

              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: AppPalette.grey),
                  left: BorderSide(color: AppPalette.grey),
                ),
              ),

              scatterTouchData: ScatterTouchData(
                touchTooltipData: ScatterTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipColor: (_) => context.colorScheme.inverseSurface,
                  getTooltipItems: (spot) {
                    final instance = sorted[spots.indexOf(spot)];
                    final time = DateFormat(
                      'HH:mm',
                    ).format(instance.completedAt!);
                    final date = DateFormat(
                      'dd.MM.yy',
                    ).format(instance.completedAt!);
                    return ScatterTooltipItem(
                      '$date\n$time Uhr',
                      textStyle: TextStyle(
                        color: context.colorScheme.onInverseSurface,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        const VerticalSpace(),

        // Legend
        Wrap(
          spacing: 4,
          runSpacing: 8,
          children: LearningTimeType.values
              .where((t) => t != LearningTimeType.undefined)
              .map(
                (type) => _ScatterLegendItem(
                  color: type.color,
                  label: '${type.label} (${type.timeRange})',
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ScatterLegendItem extends StatelessWidget {
  const _ScatterLegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const HorizontalSpace(
          size: SpaceSize.small,
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(color: AppPalette.grey),
        ),
      ],
    );
  }
}
