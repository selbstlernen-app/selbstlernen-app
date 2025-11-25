import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/horizontal_space.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/card_layout.dart';

class GoalTaskCompletionCard extends StatelessWidget {
  const GoalTaskCompletionCard({super.key, required this.stats});

  final SessionStatistics stats;

  @override
  Widget build(BuildContext context) {
    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Ziele & Aufgaben", style: context.textTheme.headlineMedium),
          const VerticalSpace(size: SpaceSize.small),
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _ProductivitySquare(
                    icon: Icons.flag,
                    iconColor: AppPalette.error,
                    label: 'Ziele erreicht',
                    total: stats.totalGoalsCompleted,
                    average: stats.averageGoalsPerSession,
                  ),
                ),
                const HorizontalSpace(size: SpaceSize.small),
                Expanded(
                  child: _ProductivitySquare(
                    icon: Icons.task_alt,
                    iconColor: AppPalette.success,
                    label: 'Aufgaben erledigt',
                    total: stats.totalTasksCompleted,
                    average: stats.averageTasksPerSession,
                  ),
                ),
              ],
            ),
          ),

          if (stats.totalGoalsCompleted > 0 ||
              stats.totalTasksCompleted > 0) ...<Widget>[
            const VerticalSpace(size: SpaceSize.medium),
            Divider(
              color: context.colorScheme.tertiary,
              thickness: 4,
              radius: BorderRadius.circular(10),
            ),
            _ProductivityProgressBar(
              label: 'Ziele',
              value: stats.totalGoalsCompleted,
              totalValue: stats.totalOpenGoals,
              color: AppPalette.success,
            ),
            const SizedBox(height: 12),
            _ProductivityProgressBar(
              label: 'Aufgaben',
              value: stats.totalTasksCompleted,
              totalValue: stats.totalOpenTasks,
              color: AppPalette.error,
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
