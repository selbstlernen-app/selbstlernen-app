import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/session_utils.dart';
import 'package:srl_app/core/utils/statistics_ui_utils.dart';
import 'package:srl_app/core/utils/time_utils.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

class FocusTimeBarChart extends StatefulWidget {
  const FocusTimeBarChart({
    required this.lastInstances,
    required this.dates,
    required this.targetFocusMinutes,
    required this.averageFocusMinutes,
    super.key,
  });

  final List<SessionInstanceModel> lastInstances;
  final List<DateTime> dates;
  final double targetFocusMinutes;
  final double averageFocusMinutes;

  @override
  State<FocusTimeBarChart> createState() => _StatsBarChartState();
}

class _StatsBarChartState extends State<FocusTimeBarChart> {
  int? touchedGroupIndex;
  Timer? _tooltipTimer;

  late Map<String, int> _dayCounts;

  double get _maxY {
    final maxInstance = widget.lastInstances.isNotEmpty
        ? widget.lastInstances
              .map(
                (instance) => instance.totalFocusSecondsElapsed / 60.0,
              )
              .reduce(max)
        : 0.0;
    final maxValue = max(maxInstance, widget.targetFocusMinutes);
    final computedMax = max(maxValue, widget.averageFocusMinutes);

    // Add 20 minutes for UI/UX
    return (computedMax + 20).ceilToDouble();
  }

  double get _interval => _calculateInterval(_maxY);

  /// Returns visually fitting interval depending on the max y value
  double _calculateInterval(double maxY) {
    if (maxY <= 60) return 10;
    if (maxY <= 120) return 30;
    if (maxY <= 300) return 60;
    return 180;
  }

  @override
  void initState() {
    super.initState();
    _dayCounts = calculateDateOccurences(widget.lastInstances);
  }

  @override
  void dispose() {
    _tooltipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: _maxY,
        alignment: BarChartAlignment.spaceAround,
        rotationQuarterTurns: 1,
        barGroups: _buildBarGroups(),
        titlesData: _buildTitlesData(),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: _interval,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppPalette.grey.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
        barTouchData: _buildTouchData(context),
        extraLinesData: _buildExtraLines(),
      ),
    );
  }

  BarTouchData _buildTouchData(BuildContext context) {
    return BarTouchData(
      enabled: true,
      allowTouchBarBackDraw: true,
      touchCallback: (event, response) {
        if (event is! FlTapUpEvent) return;

        final index = response?.spot?.touchedBarGroupIndex;

        setState(() => touchedGroupIndex = index);
        _tooltipTimer?.cancel();

        if (index != null) {
          _tooltipTimer = Timer(const Duration(milliseconds: 2000), () {
            if (mounted) {
              setState(() => touchedGroupIndex = null);
            }
          });
        }
      },
      touchTooltipData: BarTouchTooltipData(
        fitInsideVertically: true,
        tooltipMargin: 16,
        getTooltipColor: (_) => context.colorScheme.inverseSurface,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          if (groupIndex >= widget.lastInstances.length) return null;

          final instance = widget.lastInstances[groupIndex];
          final date = instance.completedAt!;
          final key = DateFormat('yyyyMMdd').format(date);

          final dateTitle = (_dayCounts[key] ?? 0) > 1
              ? DateFormat('dd.MM HH:mm').format(date)
              : null;

          final timeString = TimeUtils.formatTimeString(
            totalSeconds: instance.totalFocusSecondsElapsed,
          );

          var seconds = '';
          if (timeString.seconds != '00') {
            seconds = '\n${timeString.seconds} sec';
          }

          return BarTooltipItem(
            '${dateTitle != null ? '$dateTitle\n' : ''}'
            '''${timeString.hours != null ? '${timeString.hours} h ${timeString.minutes} min' : '${timeString.minutes} min${seconds}'}''',
            TextStyle(
              color: context.colorScheme.onInverseSurface,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      leftTitles: const AxisTitles(),
      topTitles: const AxisTitles(),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();

            if (index < 0 || index >= widget.dates.length) {
              return const SizedBox.shrink();
            }
            return SideTitleWidget(
              meta: meta,
              child: Text(
                DateFormat('dd.MM').format(widget.dates[index]),
                style: context.textTheme.bodySmall,
              ),
            );
          },
        ),
      ),
      // Bottom title
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: _interval,
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            if (value >= _maxY) {
              return const SizedBox.shrink();
            }

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
              child: Text(text, style: StatisticsUiUtils.styleBottomBar),
            );
          },
        ),
      ),
    );
  }

  ExtraLinesData _buildExtraLines() {
    return ExtraLinesData(
      horizontalLines: [
        HorizontalLine(
          y: widget.targetFocusMinutes,
          color: AppPalette.tealLight,
          strokeWidth: 3,
          dashArray: [6, 7],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppPalette.teal,
            ),
            labelResolver: (_) => 'Erwartet',
          ),
        ),
        HorizontalLine(
          y: widget.averageFocusMinutes,
          color: AppPalette.orangeLight,
          strokeWidth: 3,
          dashArray: [10, 7],
          label: HorizontalLineLabel(
            show: true,
            padding: const EdgeInsets.all(4),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppPalette.orange,
            ),
            labelResolver: (_) => 'Ø Avg',
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List<BarChartGroupData>.generate(
      widget.lastInstances.length,
      (int index) {
        final minutes =
            widget.lastInstances[index].totalFocusSecondsElapsed / 60.0;

        return BarChartGroupData(
          x: index,
          barRods: <BarChartRodData>[
            BarChartRodData(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(5),
                topLeft: Radius.circular(5),
              ),
              // if no minutes were completed, still show a bar
              toY: minutes == 0 ? 0.1 : minutes,
              color: touchedGroupIndex == index
                  ? AppPalette.pink
                  : AppPalette.pinkLight,
              width: 24,
            ),
          ],
          showingTooltipIndicators: touchedGroupIndex == index
              ? const <int>[0]
              : const <int>[],
        );
      },
    );
  }
}
