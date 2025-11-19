import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/time_utils.dart';

class StatsBarChart extends StatelessWidget {
  const StatsBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: barGroups,
        gridData: const FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
    enabled: false,
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (BarChartGroupData group) => Colors.transparent,
      tooltipPadding: EdgeInsets.zero,
      tooltipMargin: 8,
      getTooltipItem:
          (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: AppPalette.pastelEmerald,
                fontWeight: FontWeight.bold,
              ),
            );
          },
    ),
  );

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
    return SideTitleWidget(meta: meta, space: 4, child: Text(text));
  }

  Widget getLeftTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      child: Text(
        TimeUtils.formatBarChartTime(value),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: getTitles,
      ),
    ),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        interval: 4,
        getTitlesWidget: getLeftTitles,
      ),
    ),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );

  FlBorderData get borderData => FlBorderData(show: false);

  LinearGradient get _barsGradient => LinearGradient(
    colors: <Color>[AppPalette.green, AppPalette.darkGreen],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  List<BarChartGroupData> get barGroups => <BarChartGroupData>[
    BarChartGroupData(
      x: 0,
      barRods: <BarChartRodData>[
        BarChartRodData(toY: 8, gradient: _barsGradient),
      ],
      showingTooltipIndicators: <int>[0],
    ),
    BarChartGroupData(
      x: 1,
      barRods: <BarChartRodData>[
        BarChartRodData(toY: 10, gradient: _barsGradient),
      ],
      showingTooltipIndicators: <int>[0],
    ),
    BarChartGroupData(
      x: 2,
      barRods: <BarChartRodData>[
        BarChartRodData(toY: 14, gradient: _barsGradient),
      ],
      showingTooltipIndicators: <int>[0],
    ),
    BarChartGroupData(
      x: 3,
      barRods: <BarChartRodData>[
        BarChartRodData(toY: 15, gradient: _barsGradient),
      ],
      showingTooltipIndicators: <int>[0],
    ),
    BarChartGroupData(
      x: 4,
      barRods: <BarChartRodData>[
        BarChartRodData(toY: 13, gradient: _barsGradient),
      ],
      showingTooltipIndicators: <int>[0],
    ),
    BarChartGroupData(
      x: 5,
      barRods: <BarChartRodData>[
        BarChartRodData(toY: 10, gradient: _barsGradient),
      ],
      showingTooltipIndicators: <int>[0],
    ),
    BarChartGroupData(
      x: 6,
      barRods: <BarChartRodData>[
        BarChartRodData(toY: 16, gradient: _barsGradient),
      ],
      showingTooltipIndicators: <int>[0],
    ),
  ];
}
