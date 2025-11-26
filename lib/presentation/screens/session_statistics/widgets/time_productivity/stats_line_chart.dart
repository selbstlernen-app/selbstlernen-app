import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/domain/models/models.dart';

class StatsLineChart extends StatefulWidget {
  const StatsLineChart({super.key, required this.instances});

  final List<SessionInstanceModel> instances;

  @override
  State<StatsLineChart> createState() => _StatsLineChartState();
}

class _StatsLineChartState extends State<StatsLineChart> {
  List<Color> gradientColors = <Color>[AppPalette.success, AppPalette.purple];
  bool showAvg = false;

  double _toHour(DateTime dt) => dt.hour + dt.minute / 60.0;

  @override
  Widget build(BuildContext context) {
    final List<SessionInstanceModel> completed = widget.instances
        .where(
          (SessionInstanceModel i) =>
              i.status == SessionStatus.completed && i.completedAt != null,
        )
        .toList();

    if (completed.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Keine abgeschlossenen Sessions'),
        ),
      );
    }

    completed.sort(
      (SessionInstanceModel a, SessionInstanceModel b) =>
          a.completedAt!.compareTo(b.completedAt!),
    );
    final List<BarChartGroupData> groups = <BarChartGroupData>[];
    final List<String> dateStrings = <String>[];

    for (int i = 0; i < completed.length; i++) {
      final SessionInstanceModel s = completed[i];
      final DateTime dtStart = s.scheduledAt;
      DateTime dtEnd = s.completedAt!;

      if (dtEnd.isBefore(dtStart)) {
        dtEnd = dtEnd.add(const Duration(days: 1));
      }

      final double start = _toHour(s.scheduledAt);
      final double end = _toHour(s.completedAt!);

      final double fromY = start;
      final double toY = end;

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: <BarChartRodData>[
            BarChartRodData(
              fromY: fromY,
              toY: toY,
              width: 12,
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );

      dateStrings.add("${s.completedAt!.day}.${s.completedAt!.month}");
    }

    return SizedBox(
      height: completed.length * 45 + 60,
      child: BarChart(
        BarChartData(
          maxY: 24,
          minY: 0,
          alignment: BarChartAlignment.spaceBetween,
          barGroups: groups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 4,
                reservedSize: 32,
                getTitlesWidget: (double value, _) => Text("${value.toInt()}h"),
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final int i = value.toInt();
                  if (i < 0 || i >= dateStrings.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(dateStrings[i]),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(
            show: true,
            drawVerticalLine: true,
            verticalInterval: 4,
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem:
                  (
                    BarChartGroupData group,
                    int groupIndex,
                    BarChartRodData rod,
                    int rodIndex,
                  ) {
                    final SessionInstanceModel session =
                        completed[group.x.toInt()];
                    final DateTime dtStart = session.scheduledAt;
                    final DateTime dtEnd = session.completedAt!;

                    final Duration dur = dtEnd.difference(dtStart);

                    return BarTooltipItem(
                      "Start: ${_fmt(dtStart)}\n"
                      "End: ${_fmt(dtEnd)}\n"
                      "Dauer: ${_formatDuration(dur)}",
                      const TextStyle(color: Colors.white),
                    );
                  },
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

  String _formatDuration(Duration d) {
    final int h = d.inHours;
    final int m = d.inMinutes % 60;

    if (h > 0) {
      return "${h}h ${m}m";
    } else {
      return "${m}m";
    }
  }
}
