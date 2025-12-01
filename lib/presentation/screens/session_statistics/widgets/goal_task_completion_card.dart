import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/card_layout.dart';

class GoalTaskCompletionCard extends StatelessWidget {
  const GoalTaskCompletionCard({
    required this.stats,
    required this.currentInstance,
    required this.totalGoals,
    required this.totalTasks,
    super.key,
  });

  final SessionStatistics stats;
  final SessionInstanceModel currentInstance;

  final int totalGoals;
  final int totalTasks;

  @override
  Widget build(BuildContext context) {
    print(totalGoals);
    print("tassks $totalTasks");
    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Ziele & Aufgaben', style: context.textTheme.headlineMedium),
          const VerticalSpace(size: SpaceSize.xsmall),
          Text(
            '''Alle Ziele und Aufgaben, die du über den Verlauf dieser Einheit geschafft hast''',
            style: context.textTheme.bodySmall!.copyWith(
              color: AppPalette.grey,
            ),
          ),

          const VerticalSpace(size: SpaceSize.small),

          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _ProductivitySquare(
                    icon: Icons.flag,
                    iconColor: AppPalette.sky,
                    label: 'Ziele erreicht',
                    total: stats.totalGoalsCompleted,
                    average: stats.averageGoalsPerSession,
                  ),
                ),
                const HorizontalSpace(size: SpaceSize.small),
                Expanded(
                  child: _ProductivitySquare(
                    icon: Icons.task_alt,
                    iconColor: AppPalette.emerald,
                    label: 'Aufgaben erledigt',
                    total: stats.totalTasksCompleted,
                    average: stats.averageTasksPerSession,
                  ),
                ),
              ],
            ),
          ),

          if (totalGoals > 0) ...<Widget>[
            const VerticalSpace(
              size: SpaceSize.small,
            ),
            Divider(
              color: context.colorScheme.tertiary,
              thickness: 4,
              radius: BorderRadius.circular(10),
            ),
            const VerticalSpace(
              size: SpaceSize.small,
            ),

            _ProductivityProgressBar(
              label: 'Ziele',
              value: stats.totalGoalsCompleted,
              totalValue: totalGoals,
              color: AppPalette.sky,
            ),
          ],

          if (totalTasks > 0) ...<Widget>[
            const VerticalSpace(
              size: SpaceSize.small,
            ),

            _ProductivityProgressBar(
              label: 'Aufgaben',
              value: stats.totalTasksCompleted,
              totalValue: totalTasks,
              color: AppPalette.emerald,
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
              style: context.textTheme.bodySmall?.copyWith(
                color: AppPalette.grey,
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
    required this.color,
  });

  final String label;
  final int value;
  final int totalValue;
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
            Text(
              '$totalValue',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const VerticalSpace(size: SpaceSize.xsmall),
        LinearProgressIndicator(
          value: totalValue == 0 ? 0 : value / totalValue,
          backgroundColor: context.colorScheme.tertiary,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }
}
