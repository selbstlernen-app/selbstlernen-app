import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/general_statistics.dart';

class GoalTaskCompletionCard extends StatelessWidget {
  const GoalTaskCompletionCard({
    required this.stats,
    super.key,
  });

  final GeneralStatistics stats;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: CardLayout(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ziele & Aufgaben', style: context.textTheme.headlineMedium),
            const VerticalSpace(
              size: SpaceSize.xsmall,
            ),
            Text(
              'Alle jemals abgeschlossenen Ziele und Aufgaben',
              style: context.textTheme.bodySmall!.copyWith(
                color: AppPalette.grey,
              ),
            ),
            const VerticalSpace(),

            Row(
              children: <Widget>[
                Expanded(
                  child: _ProductivitySquare(
                    icon: Icons.flag,
                    iconColor: AppPalette.sky,
                    label: 'Ziele erreicht',
                    total: stats.totalGoalsCompleted,
                    average: stats.avgGoalsPerInstance,
                  ),
                ),
                const HorizontalSpace(size: SpaceSize.small),
                Expanded(
                  child: _ProductivitySquare(
                    icon: Icons.task_alt,
                    iconColor: AppPalette.emerald,
                    label: 'Aufgaben erledigt',
                    total: stats.totalTasksCompleted,
                    average: stats.avgTasksPerInstance,
                  ),
                ),
              ],
            ),
          ],
        ),
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
