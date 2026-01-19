import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/goal_task_completion/completion_line_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/history_dialog.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/toggle_show_all_button.dart';

class GoalTaskCompletionCard extends StatefulWidget {
  const GoalTaskCompletionCard({
    required this.stats,
    required this.totalGoals,
    required this.totalTasks,
    required this.pastInstances,
    super.key,
  });

  final SessionStatistics stats;

  /// list of all instances; skipped, missed and completed
  final List<SessionInstanceModel> pastInstances;

  final int totalGoals;
  final int totalTasks;

  @override
  State<GoalTaskCompletionCard> createState() => _GoalTaskCompletionCardState();
}

class _GoalTaskCompletionCardState extends State<GoalTaskCompletionCard> {
  bool showAllInstances = false;

  List<SessionInstanceModel> get allDoneInstances => widget.pastInstances
      .where((instance) => instance.status == SessionStatus.completed)
      .toList();

  double _calcAverage(List<SessionInstanceModel> instances, bool isGoal) {
    if (instances.isEmpty) return 0;
    final total = instances.fold<double>(
      0,
      (sum, i) => sum + (isGoal ? i.completedGoalsRate : i.completedTasksRate),
    );
    return total / instances.length;
  }

  @override
  Widget build(BuildContext context) {
    final done = allDoneInstances;
    final avgGoals = _calcAverage(done, true);
    final avgTasks = _calcAverage(done, false);

    final hasData = done.isNotEmpty || widget.stats.totalGoalsCompleted > 0;

    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ziele & Aufgaben', style: context.textTheme.headlineMedium),

              IconButton(
                color: AppPalette.grey.withValues(alpha: 0.5),
                icon: const Icon(
                  Icons.history_rounded,
                ),
                onPressed: () => showHistoryBottomSheet(
                  context,
                  widget.pastInstances,
                  'Ziele und Aufgaben',
                  (instance) =>
                      '''${instance.totalCompletedGoals} Ziele erledigt\n${instance.totalCompletedTasks} Aufgaben erledigt''',
                ),
              ),
            ],
          ),

          if (!hasData)
            const _EmptyState()
          else ...[
            // LINE CHART BUTTON AND AVG STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ToggleShowAllButton(
                  showAll: showAllInstances,
                  thresholdExceeded: done.length > 5,
                  onToggle: () {
                    setState(() => showAllInstances = !showAllInstances);
                  },
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Ø ${avgGoals.toStringAsFixed(0)}% Ziele',
                      style: context.textTheme.bodyMedium,
                    ),
                    Text(
                      'Ø ${avgTasks.toStringAsFixed(0)}% Aufgaben',
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),

            const VerticalSpace(size: SpaceSize.small),

            CompletionLineChart(
              instances: allDoneInstances,
              showAllInstances: showAllInstances,
            ),

            Text(
              'Abgeschlossene Aufgaben und Ziele über alle Sitzungen hinweg',
              style: context.textTheme.bodySmall!.copyWith(
                color: AppPalette.grey,
              ),
            ),

            const VerticalSpace(
              size: SpaceSize.small,
            ),

            IntrinsicHeight(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _ProductivitySquare(
                      icon: Icons.flag_rounded,
                      iconColor: AppPalette.sky,
                      label: 'Ziele erreicht',
                      total: widget.stats.totalGoalsCompleted,
                      average: widget.stats.averageGoalsPerSession,
                    ),
                  ),
                  const HorizontalSpace(size: SpaceSize.small),
                  Expanded(
                    child: _ProductivitySquare(
                      icon: Icons.task_alt_rounded,
                      iconColor: AppPalette.emerald,
                      label: 'Aufgaben erledigt',
                      total: widget.stats.totalTasksCompleted,
                      average: widget.stats.averageTasksPerSession,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProductivitySquare extends StatelessWidget {
  const _ProductivitySquare({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.total,
    required this.average,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int total;
  final double average;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: iconColor, size: 32),
          const VerticalSpace(size: SpaceSize.xsmall),
          Text(
            '$total',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          Text(
            label,
            style: context.textTheme.bodySmall!.copyWith(color: iconColor),
            textAlign: TextAlign.center,
          ),
          if (average > 0) ...<Widget>[
            const VerticalSpace(size: SpaceSize.xsmall),
            Text(
              'Ø ${average.toStringAsFixed(1)}/Einheit',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppPalette.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const VerticalSpace(size: SpaceSize.small),
        Icon(
          Icons.task_alt_rounded,
          size: 48,
          color: AppPalette.grey.withValues(alpha: 0.3),
        ),
        const VerticalSpace(size: SpaceSize.small),
        Text(
          'Noch keine Ziel oder Aufgaben-Daten',
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '''Hake Ziele oder Aufgaben in deiner nächsten Einheit ab, um deinen Verlauf zu sehen.''',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppPalette.grey,
          ),
        ),
      ],
    );
  }
}
