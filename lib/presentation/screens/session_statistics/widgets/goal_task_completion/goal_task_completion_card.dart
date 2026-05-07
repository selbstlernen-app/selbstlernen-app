import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/custom_filter_chip.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/chart_header.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/empty_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/goal_task_completion/completion_line_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/toggle_show_all_button.dart';

enum CompletionViewMode {
  combined,
  goals,
  tasks,
}

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
  CompletionViewMode viewMode = CompletionViewMode.combined;

  List<SessionInstanceModel> get allDoneInstances => widget.pastInstances
      .where((instance) => instance.status == SessionStatus.completed)
      .toList();

  double _calcAvg(List<SessionInstanceModel> instances) {
    if (instances.isEmpty) return 0;

    if (viewMode == CompletionViewMode.combined) {
      final total = instances.fold<double>(0, (sum, i) {
        var activeCategories = 0;
        double instanceSum = 0;

        // Check if there were either any goals and/or tasks any goals to complete
        if (i.totalCompletedGoals > 0) {
          instanceSum += i.completedGoalsRate;
          activeCategories++;
        }
        if (i.totalCompletedTasks > 0) {
          instanceSum += i.completedTasksRate;
          activeCategories++;
        }

        // If both are empty, this instance contributes 0;
        // Else, divide by 1 or 2 depending on what was present
        final instanceAvg = activeCategories > 0
            ? instanceSum / activeCategories
            : 0;
        return sum + instanceAvg;
      });

      return total / instances.length;
    } else {
      final total = instances.fold<double>(
        0,
        (sum, i) =>
            sum +
            (viewMode == CompletionViewMode.goals
                ? i.completedGoalsRate
                : i.completedTasksRate),
      );
      return total / instances.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = allDoneInstances;
    final avgCombined = _calcAvg(done);

    final hasData = done.isNotEmpty || widget.stats.totalGoalsCompleted > 0;

    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ChartHeader(
            title: 'Ziele & Aufgaben',
            instances: widget.pastInstances,
            getAttributeValue: (instance) =>
                '''${instance.totalCompletedGoals} Ziele erledigt\n${instance.totalCompletedTasks} Aufgaben erledigt''',
          ),

          if (!hasData)
            const EmptyChart(
              iconData: Icons.task_alt_rounded,
              infoTitle: 'Noch keine Ziel oder Aufgaben-Daten',
              infoSubtitle:
                  '''Hake Ziele oder Aufgaben in deiner nächsten Einheit ab, um deinen Verlauf zu sehen.''',
            )
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
                      'Ø ${avgCombined.toStringAsFixed(0)}% Gesamt',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      avgCombined >= 80
                          ? 'Sehr konstant 🎯'
                          : avgCombined >= 60
                          ? 'Gute Entwicklung'
                          : 'Noch Luft nach oben',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppPalette.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const VerticalSpace(),

            Wrap(
              spacing: 8,
              children: [
                CustomFilterChip(
                  label: 'Gesamt',
                  isActive: viewMode == CompletionViewMode.combined,
                  onPressed: () => setState(() {
                    viewMode = CompletionViewMode.combined;
                  }),
                ),
                CustomFilterChip(
                  label: 'Ziele',
                  isActive: viewMode == CompletionViewMode.goals,
                  onPressed: () => setState(() {
                    viewMode = CompletionViewMode.goals;
                  }),
                ),

                CustomFilterChip(
                  label: 'Aufgaben',
                  isActive: viewMode == CompletionViewMode.tasks,
                  onPressed: () => setState(() {
                    viewMode = CompletionViewMode.tasks;
                  }),
                ),
              ],
            ),

            const VerticalSpace(),

            CompletionLineChart(
              instances: done,
              avg: avgCombined,
              showAllInstances: showAllInstances,
              viewMode: viewMode,
            ),

            const VerticalSpace(
              size: SpaceSize.small,
            ),

            Text(
              'Dein Fortschritt über alle abgeschlossenen Sitzungen',
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$total',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              const HorizontalSpace(size: SpaceSize.xsmall),
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ],
          ),

          const VerticalSpace(size: SpaceSize.small),

          Text(
            label,
            style: context.textTheme.bodySmall!.copyWith(color: iconColor),
            textAlign: TextAlign.center,
          ),
          if (average > 0) ...<Widget>[
            const VerticalSpace(size: SpaceSize.xsmall),
            Text(
              'Ø ${average.toStringAsFixed(1)}/Einheit',
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppPalette.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
