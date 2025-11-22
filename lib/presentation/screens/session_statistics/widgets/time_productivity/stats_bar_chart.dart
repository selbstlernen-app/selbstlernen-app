import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/chart_utils.dart';
import 'package:srl_app/core/utils/time_utils.dart';

class StatsBarChart extends StatefulWidget {
  const StatsBarChart({
    super.key,
    required this.weekdayMinutes,
    required this.plannedFocusMinutesPerWeekday,
    required this.averageFocusMinutesPerSession,
  });

  final List<double> weekdayMinutes;
  final List<int> plannedFocusMinutesPerWeekday;
  final double averageFocusMinutesPerSession;

  @override
  State<StatsBarChart> createState() => _StatsBarChartState();
}

class _StatsBarChartState extends State<StatsBarChart> {
  int? touchedGroupIndex;

  double get _maxY {
    final int maxPlanned = widget.plannedFocusMinutesPerWeekday.reduce(max);
    final int maxActual = widget.weekdayMinutes.reduce(max).toInt();

    final int computedMax = max(maxPlanned, maxActual);

    return computedMax.ceilToDouble();
  }

  double get _interval => _calculateNiceInterval(_maxY);

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
              strokeWidth: 2,
              color: AppPalette.darkPurple,
              dashArray: <int>[10, 16],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateNiceInterval(double maxY) {
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
        if (response == null || response.spot == null) {
          setState(() {
            touchedGroupIndex = null;
          });
          return;
        }
        final int index = response.spot!.touchedBarGroupIndex;
        setState(() {
          if (event is FlTapUpEvent || event is FlTapDownEvent) {
            touchedGroupIndex = index;
          } else {
            touchedGroupIndex = null;
          }
        });
      },
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => Colors.blue,
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        tooltipMargin: 2,
        getTooltipItem:
            (
              BarChartGroupData group,
              int groupIndex,
              BarChartRodData rod,
              int rodIndex,
            ) {
              return BarTooltipItem(
                TimeUtils.formatToolTipTime(rod.toY),
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    String text = switch (value.toInt()) {
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
          maxY <= 60 ? "0 min" : "0 h",
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
      final double minutes = widget.weekdayMinutes[index];
      final int plannedMinutes = widget.plannedFocusMinutesPerWeekday[index];

      return BarChartGroupData(
        x: index,
        barRods: <BarChartRodData>[
          BarChartRodData(
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: plannedMinutes.toDouble(),
              color: Colors.grey.shade300,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            toY: minutes,
            color: touchedGroupIndex == index
                ? AppPalette.pastelEmerald
                : AppPalette.pastelViolet,

            width: 20,
          ),
        ],
        showingTooltipIndicators: touchedGroupIndex == index
            ? const <int>[1]
            : const <int>[],
      );
    });
  }
}
