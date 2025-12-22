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
  late List<SessionInstanceModel> allDoneInstances;

  @override
  void initState() {
    super.initState();

    // Only display such that were actually completed;
    // and thus have goals/tasks possibly checked off during session
    allDoneInstances = [
      ...widget.pastInstances.where(
        (instance) => instance.status == SessionStatus.completed,
      ),
    ];
  }

  double _calcAverageGoalCompletion(List<SessionInstanceModel> instances) {
    final avgGoalCompletion = instances.fold<double>(
      0,
      (double sum, SessionInstanceModel i) => sum + i.completedGoalsRate,
    );

    return avgGoalCompletion / instances.length;
  }

  double _calcAverageTaskCompletion(List<SessionInstanceModel> instances) {
    final avgTaskCompletion = instances.fold<double>(
      0,
      (double sum, SessionInstanceModel i) => sum + i.completedTasksRate,
    );

    return avgTaskCompletion / instances.length;
  }

  @override
  Widget build(BuildContext context) {
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

          // LINE CHART BUTTON AND AVG STATS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ToggleShowAllButton(
                showAll: showAllInstances,
                thresholdExceeded: allDoneInstances.length > 4,
                onToggle: () {
                  setState(() => showAllInstances = !showAllInstances);
                },
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Ø ${_calcAverageGoalCompletion(
                      allDoneInstances,
                    ).toStringAsFixed(1)}% Ziele',
                    style: context.textTheme.bodyMedium,
                  ),
                  Text(
                    'Ø ${_calcAverageTaskCompletion(
                      allDoneInstances,
                    ).toStringAsFixed(1)}% Aufgaben',
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
                    icon: Icons.flag,
                    iconColor: AppPalette.sky,
                    label: 'Ziele erreicht',
                    total: widget.stats.totalGoalsCompleted,
                    average: widget.stats.averageGoalsPerSession,
                  ),
                ),
                const HorizontalSpace(size: SpaceSize.small),
                Expanded(
                  child: _ProductivitySquare(
                    icon: Icons.task_alt,
                    iconColor: AppPalette.emerald,
                    label: 'Aufgaben erledigt',
                    total: widget.stats.totalTasksCompleted,
                    average: widget.stats.averageTasksPerSession,
                  ),
                ),
              ],
            ),
          ),
          const VerticalSpace(
            size: SpaceSize.xsmall,
          ),
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
