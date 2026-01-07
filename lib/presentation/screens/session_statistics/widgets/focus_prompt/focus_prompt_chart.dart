import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/statistics_ui_utils.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_prompt/focus_check_utils.dart';

class FocusLevelChart extends StatelessWidget {
  const FocusLevelChart({
    required this.instance,
    super.key,
  });

  final SessionInstanceModel instance;

  /// Returns visually fitting interval depending on the max y value
  double _calculateInterval(double maxY) {
    if (maxY <= 10) return 1;
    if (maxY <= 30) return 5;
    if (maxY <= 60) return 10;
    if (maxY <= 120) return 30;
    if (maxY <= 300) return 60;
    if (maxY <= 600) return 120;
    return 180;
  }

  @override
  Widget build(BuildContext context) {
    final focusData = prepareFocusCheckData(instance);

    if (focusData.isEmpty) {
      return Center(
        child: Text(
          'Heute keine Fokusabfrage-Daten in dieser Lerneinheit gesammelt',
          style: context.textTheme.bodySmall,
        ),
      );
    }

    final spots = focusData.map((data) {
      return FlSpot(
        data.minutesIntoSession.toDouble(),
        focusLevelToValue(data.check.level),
      );
    }).toList();

    final lastCheck = focusData.last.minutesIntoSession.toDouble();
    // Round to nearest multiple of 10 for max x
    final maxX = (lastCheck / 10).ceilToDouble() * 10;

    return SizedBox(
      height: 160,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: LineChart(
          LineChartData(
            minX: 0,
            minY: 0,
            maxX: maxX,
            maxY: 3,
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
              verticalInterval: _calculateInterval(maxX),
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
                  reservedSize: 20,
                  interval: _calculateInterval(maxX),
                  getTitlesWidget: (value, meta) {
                    final totalMinutes = value.toInt();
                    final hours = totalMinutes ~/ 60;
                    final mins = totalMinutes % 60;

                    String text;
                    if (hours > 0) {
                      text = mins > 0 ? '$hours h $mins min' : '$hours h';
                    } else {
                      text = '$mins min';
                    }

                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        text,
                        style: StatisticsUiUtils.styleBottomBar,
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
                    final level = focusData[index].check.level;
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
                    final data = focusData[index];
                    final level = data.check.level;

                    return LineTooltipItem(
                      '${data.minutesIntoSession} min\n${getFocusLabel(level)}',
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
