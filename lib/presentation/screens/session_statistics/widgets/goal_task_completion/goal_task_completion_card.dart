import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/custom_icon_button.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/goal_task_completion/completion_line_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/history_dialog.dart';

class GoalTaskCompletionCard extends StatefulWidget {
  const GoalTaskCompletionCard({
    required this.stats,
    required this.currentInstance,
    required this.totalGoals,
    required this.totalTasks,
    required this.pastInstances,
    super.key,
  });

  final SessionStatistics stats;
  final SessionInstanceModel currentInstance;
  final List<SessionInstanceModel> pastInstances;

  final int totalGoals;
  final int totalTasks;

  @override
  State<GoalTaskCompletionCard> createState() => _GoalTaskCompletionCardState();
}

class _GoalTaskCompletionCardState extends State<GoalTaskCompletionCard> {
  bool showAllInstances = false;

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
    final allDoneInstances = [
      ...widget.pastInstances.where(
        (instance) => instance.status != SessionStatus.skipped,
      ),
      widget.currentInstance,
    ];
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
                  allDoneInstances,
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
              if (allDoneInstances.length > 5)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: context.colorScheme.tertiary,
                    foregroundColor: context.colorScheme.onTertiary,
                    textStyle: context.textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onTertiary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      showAllInstances = !showAllInstances;
                    });
                  },
                  icon: Icon(
                    showAllInstances ? Icons.compress : Icons.expand,
                  ),
                  label: Text(
                    showAllInstances ? 'Weniger' : 'Alle anzeigen',
                  ),
                ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Ø ${_calcAverageGoalCompletion(
                      allDoneInstances,
                    ).toStringAsFixed(1)}% Ziele',
                    style: context.textTheme.bodyLarge,
                  ),
                  Text(
                    'Ø ${_calcAverageTaskCompletion(
                      allDoneInstances,
                    ).toStringAsFixed(1)}% Aufgaben',
                    style: context.textTheme.bodyLarge,
                  ),
                ],
              ),
            ],
          ),

          const VerticalSpace(),

          CompletionLineChart(
            instances: allDoneInstances,
            showAllInstances: showAllInstances,
          ),

          Text(
            'Abgeschlossene Aufgaben und Ziele über alle Sitzungen hinweg',
            style: context.textTheme.bodySmall!.copyWith(
              color: AppPalette.grey,
            ),
            textAlign: TextAlign.center,
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

class _ProductivityProgressBar extends StatelessWidget {
  const _ProductivityProgressBar({
    required this.label,
    required this.value,
    required this.totalValue,
    required this.percentage,
    required this.color,
  });

  final String label;
  final int value;
  final int totalValue;
  final double percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(label, style: context.textTheme.bodyMedium),
            Text('$value/$totalValue', style: context.textTheme.bodyMedium),
          ],
        ),
        Text(percentage.toString(), style: context.textTheme.bodyMedium),
        const VerticalSpace(size: SpaceSize.xsmall),
      ],
    );
  }
}
