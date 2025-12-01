import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/card_layout.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_time_spent/stats_bar_chart.dart';

class FocusTimeSpentCard extends ConsumerWidget {
  const FocusTimeSpentCard({
    required this.stats,
    required this.lastInstances,
    required this.targetFocusMinutes,
    super.key,
  });

  final SessionStatistics stats;
  final List<SessionInstanceModel> lastInstances;
  final double targetFocusMinutes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalMinutes = stats.totalFocusMinutes;

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    final averageFocus = stats.averageFocusMinutesPerSession.floor();
    final averageHours = averageFocus ~/ 60;
    final averageMinutes = averageFocus % 60;

    final expectedTime = targetFocusMinutes;
    final expectedHours = expectedTime ~/ 60;
    final expectedMinutes = expectedTime % 60;

    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Fokuszeit', style: context.textTheme.headlineMedium),
          const VerticalSpace(size: SpaceSize.xsmall),
          Text(
            'Deine Fokuszeit der zuletzt abgeschlossenen Einheiten',
            style: context.textTheme.bodySmall!.copyWith(
              color: AppPalette.grey,
            ),
          ),

          const VerticalSpace(size: SpaceSize.xsmall),
          Divider(
            color: context.colorScheme.tertiary,
            thickness: 4,
            radius: BorderRadius.circular(10),
          ),
          const VerticalSpace(size: SpaceSize.xsmall),

          // Some info in three columns
          Row(
            children: <Widget>[
              _StatColumn(
                label: 'Gesamtzeit',
                value: hours > 0 ? '$hours h $minutes min' : '$minutes min',
              ),

              _StatDivider(),

              if (stats.averageFocusMinutesPerSession > 0) ...<Widget>[
                _StatColumn(
                  label: 'Ø Fokuszeit',
                  value: averageHours > 0
                      ? '$averageHours h $averageMinutes min'
                      : '$averageMinutes min',
                  coloredPoint: AppPalette.orange,
                ),
                _StatDivider(),
              ],

              if (expectedTime > 0) ...<Widget>[
                _StatColumn(
                  label: 'Erwartet',
                  value: expectedHours > 0
                      ? '$expectedHours h ${expectedMinutes.toInt()} min'
                      : '${expectedMinutes.toInt()} min',
                  coloredPoint: AppPalette.rose,
                ),
              ],
            ],
          ),

          const VerticalSpace(size: SpaceSize.xlarge),

          // Bar chart
          SizedBox(
            height: 200,
            child: StatsBarChart(
              lastInstances: lastInstances,
              targetFocusMinutes: targetFocusMinutes,
              averageFocusMinutes: stats.averageFocusMinutesPerSession,
            ),
          ),
        ],
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
  const _StatColumn({
    required this.value,
    required this.label,
    this.coloredPoint,
  });

  final String value;
  final String label;
  final Color? coloredPoint;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (coloredPoint != null)
                Container(
                  height: 5,
                  width: 5,
                  decoration: BoxDecoration(
                    color: coloredPoint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              Text(
                value,
                textAlign: TextAlign.center,
                style: context.textTheme.headlineSmall,
              ),
            ],
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
