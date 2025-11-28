import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/domain/models/models.dart';

class StatsLineChart extends StatefulWidget {
  const StatsLineChart({required this.instances, super.key});

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
    final completed = widget.instances
        .where(
          (SessionInstanceModel i) =>
              i.status == SessionStatus.completed && i.completedAt != null,
        )
        .toList();

    if (completed.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Keine abgeschlossenen Sessions'),
        ),
      );
    }

    completed.sort(
      (SessionInstanceModel a, SessionInstanceModel b) =>
          a.completedAt!.compareTo(b.completedAt!),
    );
    final groups = <BarChartGroupData>[];
    final dateStrings = <String>[];

    for (var i = 0; i < completed.length; i++) {
      final s = completed[i];
      final dtStart = s.scheduledAt;
      var dtEnd = s.completedAt!;

      if (dtEnd.isBefore(dtStart)) {
        dtEnd = dtEnd.add(const Duration(days: 1));
      }

      final start = _toHour(s.scheduledAt);
      final end = _toHour(s.completedAt!);

      final fromY = start;
      final toY = end;

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

      dateStrings.add('${s.completedAt!.day}.${s.completedAt!.month}');
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
                getTitlesWidget: (double value, _) => Text('${value.toInt()}h'),
              ),
            ),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= dateStrings.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(dateStrings[i]),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(
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
                    final session = completed[group.x];
                    final dtStart = session.scheduledAt;
                    final dtEnd = session.completedAt!;

                    final dur = dtEnd.difference(dtStart);

                    return BarTooltipItem(
                      'Start: ${_fmt(dtStart)}\n'
                      'End: ${_fmt(dtEnd)}\n'
                      'Dauer: ${_formatDuration(dur)}',
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
    final h = d.inHours;
    final m = d.inMinutes % 60;

    if (h > 0) {
      return '${h}h ${m}m';
    } else {
      return '${m}m';
    }
  }
}
