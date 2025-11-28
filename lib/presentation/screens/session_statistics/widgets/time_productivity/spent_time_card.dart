import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/time_productivity/stats_bar_chart.dart';

class SpentTimeCard extends ConsumerWidget {
  const SpentTimeCard({
    super.key,
    required this.stats,
    required this.weekdayMinutes,
    required this.plannedFocusMinutesPerWeekday,
  });

  final SessionStatistics stats;
  final List<double> weekdayMinutes;
  final List<int> plannedFocusMinutesPerWeekday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int totalMinutes = stats.totalFocusMinutes + stats.totalBreakMinutes;

    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;

    final int averageFocus = stats.averageFocusMinutesPerSession.floor();
    final int averageHours = averageFocus ~/ 60;
    final int averageMinutes = averageFocus % 60;

    final int expectedTime = plannedFocusMinutesPerWeekday.max;
    final int expectedHours = expectedTime ~/ 60;
    final int expectedMinutes = expectedTime % 60;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Fokuszeit", style: context.textTheme.headlineMedium),

            const VerticalSpace(size: SpaceSize.xsmall),
            Divider(
              color: context.colorScheme.tertiary,
              thickness: 4,
              radius: BorderRadius.circular(10),
            ),
            const VerticalSpace(size: SpaceSize.xsmall),

            // Some info in three columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _StatColumn(
                  label: 'Zeit insgesamt',
                  value: hours > 0 ? '$hours h $minutes min' : '$minutes min',
                ),

                _StatDivider(),

                if (stats.averageFocusMinutesPerSession > 0) ...<Widget>[
                  _StatColumn(
                    label: 'Ø Fokuszeit',
                    value: averageHours > 0
                        ? '$averageHours h $averageMinutes min'
                        : '$averageMinutes min',
                  ),
                  _StatDivider(),
                ],

                if (expectedTime > 0) ...<Widget>[
                  _StatColumn(
                    label: 'Erwartet',
                    value: expectedHours > 0
                        ? '$expectedHours h $expectedMinutes min'
                        : '$expectedMinutes min',
                  ),
                ],
              ],
            ),

            const VerticalSpace(size: SpaceSize.xlarge),

            // Bar chart
            SizedBox(
              height: 200,
              child: StatsBarChart(
                weekdayMinutes: weekdayMinutes,
                plannedFocusMinutesPerWeekday: plannedFocusMinutesPerWeekday,
                averageFocusMinutesPerSession:
                    stats.averageFocusMinutesPerSession,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: VerticalDivider(
        thickness: 2,
        color: context.colorScheme.tertiary,
        radius: BorderRadius.circular(10),
      ),
    );
  }
}

/// Visualizes the three columns at the top
class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            value,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineSmall,
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            softWrap: true,
            maxLines: 2,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppPalette.grey,
            ),
          ),
        ],
      ),
    );
  }
}
