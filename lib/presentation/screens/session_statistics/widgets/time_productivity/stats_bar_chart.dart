import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/chart_utils.dart';
import 'package:srl_app/core/utils/time_utils.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

class StatsBarChart extends StatefulWidget {
  const StatsBarChart({
    required this.lastInstances,
    required this.targetFocusMinutes,
    required this.averageFocusMinutes,
    super.key,
  });

  final List<SessionInstanceModel> lastInstances;
  final double targetFocusMinutes;
  final double averageFocusMinutes;

  @override
  State<StatsBarChart> createState() => _StatsBarChartState();
}

class _StatsBarChartState extends State<StatsBarChart> {
  int? touchedGroupIndex;
  Timer? _tooltipTimer;

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
        titlesData: _buildTitlesData(_interval, _maxY),
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
        barTouchData: _buildBarTouchData(),
        extraLinesData: ExtraLinesData(
          horizontalLines: <HorizontalLine>[
            HorizontalLine(
              y: widget.targetFocusMinutes,
              color: AppPalette.roseLight,
              strokeWidth: 3,
              dashArray: <int>[10, 7],
              label: HorizontalLineLabel(
                show: true,
                padding: const EdgeInsets.all(4),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.rose,
                ),
                labelResolver: (_) => 'Erwartet',
              ),
            ),
            HorizontalLine(
              y: widget.averageFocusMinutes,
              color: AppPalette.orangeLight,
              strokeWidth: 3,
              dashArray: <int>[10, 7],
              label: HorizontalLineLabel(
                show: true,
                padding: const EdgeInsets.all(4),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.orange,
                ),
                labelResolver: (_) => 'Avg',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns visually fitting interval depending on the max y value
  double _calculateInterval(double maxY) {
    if (maxY <= 60) return 10;
    if (maxY <= 120) return 20;
    if (maxY <= 300) return 60;
    if (maxY <= 600) return 120;
    return 180;
  }

  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      enabled: true,
      allowTouchBarBackDraw: true,
      touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
        if (event is FlTapUpEvent) {
          final index = response?.spot?.touchedBarGroupIndex;

          setState(() {
            touchedGroupIndex = index;
          });

          _tooltipTimer?.cancel();

          // Auto-dismiss after 2 seconds
          if (index != null) {
            _tooltipTimer = Timer(const Duration(milliseconds: 2000), () {
              if (mounted) {
                setState(() {
                  touchedGroupIndex = null;
                });
              }
            });
          }
        }
      },
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => AppPalette.sky,
        tooltipPadding: const EdgeInsets.all(4),
        tooltipMargin: 20,
        getTooltipItem:
            (
              BarChartGroupData group,
              int groupIndex,
              BarChartRodData rod,
              int rodIndex,
            ) {
              return BarTooltipItem(
                TimeUtils.formatToolTipTime(rod.toY),
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              );
            },
      ),
    );
  }

  FlTitlesData _buildTitlesData(double interval, double maxY) {
    return FlTitlesData(
      leftTitles: const AxisTitles(), // top side
      bottomTitles: AxisTitles(
        // left side
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: interval,
          getTitlesWidget: getMinuteTitle,
        ),
      ),
      topTitles: const AxisTitles(), // right side
      rightTitles: AxisTitles(
        // bottom side
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: interval,
          getTitlesWidget: (double value, TitleMeta meta) =>
              getBottomTitles(value, meta, maxY),
        ),
      ),
    );
  }

  Widget getMinuteTitle(double value, TitleMeta meta) {
    final text = switch (value.toInt()) {
      0 => '#1',
      1 => '#2',
      2 => '#3',
      3 => '#4',
      4 => '#5',
      _ => '',
    };
    return SideTitleWidget(
      meta: meta,
      child: Text(text, style: ChartUtils.styleBottomBar),
    );
  }

  Widget getBottomTitles(double value, TitleMeta meta, double maxY) {
    if (value > maxY) return const SizedBox.shrink();

    if (value == 0) {
      return SideTitleWidget(
        meta: meta,
        space: 4,
        child: Text(
          maxY <= 60 ? '0 min' : '0 h',
          style: ChartUtils.styleLeftBar,
        ),
      );
    }

    if (value == maxY) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(
        TimeUtils.formatBarChartTime(value),
        style: ChartUtils.styleLeftBar,
      ),
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
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
              toY: minutes,
              color: touchedGroupIndex == index
                  ? AppPalette.amberLight
                  : AppPalette.orange,
              width: 16,
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
