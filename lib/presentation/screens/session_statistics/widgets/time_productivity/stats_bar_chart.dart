import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/chart_utils.dart';
import 'package:srl_app/core/utils/time_utils.dart';

class StatsBarChart extends StatefulWidget {
  const StatsBarChart({
    required this.weekdayMinutes,
    required this.plannedFocusMinutesPerWeekday,
    required this.averageFocusMinutesPerSession,
    super.key,
  });

  final List<double> weekdayMinutes;
  final List<int> plannedFocusMinutesPerWeekday;
  final double averageFocusMinutesPerSession;

  @override
  State<StatsBarChart> createState() => _StatsBarChartState();
}

class _StatsBarChartState extends State<StatsBarChart> {
  int? touchedGroupIndex;
  Timer? _tooltipTimer;

  double get _maxY {
    final maxPlanned = widget.plannedFocusMinutesPerWeekday.reduce(max);
    final maxActual = widget.weekdayMinutes.reduce(max).toInt();

    final int computedMax = max(maxPlanned, maxActual);

    return computedMax.ceilToDouble();
  }

  double get _interval => _calculateInterval(_maxY);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: _maxY,
        alignment: BarChartAlignment.spaceAround,
        barGroups: _buildBarGroups(),
        titlesData: _buildTitlesData(_interval, _maxY),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barTouchData: _buildBarTouchData(),
        extraLinesData: ExtraLinesData(
          horizontalLines: <HorizontalLine>[
            HorizontalLine(
              y: widget.averageFocusMinutesPerSession,
              color: AppPalette.purple,
              dashArray: <int>[10, 16],
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
        getTooltipColor: (_) => AppPalette.primary,
        tooltipPadding: const EdgeInsets.all(4),
        tooltipMargin: 12,
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
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 48,
          interval: interval,
          getTitlesWidget: (double value, TitleMeta meta) =>
              getLeftTitles(value, meta, maxY),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: true, getTitlesWidget: getTitles),
      ),
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    final text = switch (value.toInt()) {
      0 => 'Mo',
      1 => 'Di',
      2 => 'Mi',
      3 => 'Do',
      4 => 'Fr',
      5 => 'Sa',
      6 => 'So',
      _ => '',
    };
    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(text, style: ChartUtils.styleBottomBar),
    );
  }

  Widget getLeftTitles(double value, TitleMeta meta, double maxY) {
    if (value > maxY) return const SizedBox.shrink();

    if (value == 0) {
      return SideTitleWidget(
        meta: meta,
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
      child: Text(
        TimeUtils.formatBarChartTime(value),
        style: ChartUtils.styleLeftBar,
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List<BarChartGroupData>.generate(7, (int index) {
      final minutes = widget.weekdayMinutes[index];
      final plannedMinutes = widget.plannedFocusMinutesPerWeekday[index];

      return BarChartGroupData(
        x: index,
        barRods: <BarChartRodData>[
          BarChartRodData(
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: plannedMinutes.toDouble(),
              color: AppPalette.grey.withValues(alpha: 0.2),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            toY: minutes,
            color: touchedGroupIndex == index
                ? AppPalette.orangeLight
                : AppPalette.primary,
            width: 20,
          ),
        ],
        showingTooltipIndicators: touchedGroupIndex == index
            ? const <int>[0]
            : const <int>[],
      );
    });
  }
}
