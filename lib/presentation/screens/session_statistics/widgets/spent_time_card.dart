import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/horizontal_space.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/stats_bar_chart.dart';

class SpentTimeCard extends StatelessWidget {
  const SpentTimeCard({super.key, required this.stats});

  final SessionStatistics stats;

  @override
  Widget build(BuildContext context) {
    final int totalMinutes = stats.totalFocusMinutes + stats.totalBreakMinutes;
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;

    final int averageFocusMins = stats.averageFocusMinutesPerSession.floor();
    final int averageHours = averageFocusMins ~/ 60;
    final int averageMinutes = averageFocusMins % 60;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Fokuszeit", style: context.textTheme.headlineMedium),

            const VerticalSpace(size: SpaceSize.small),
            Divider(
              color: context.colorScheme.tertiary,
              thickness: 4,
              radius: const BorderRadius.all(Radius.circular(10)),
            ),
            const VerticalSpace(size: SpaceSize.small),

            Row(
              children: <Widget>[
                // Time spent in total
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        hours > 0 ? '$hours h $minutes min' : '$minutes min',
                        style: context.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Zeit insgesamt',
                        style: context.textTheme.bodyMedium?.copyWith(),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Average time spent focused
                if (stats.averageFocusMinutesPerSession > 0) ...<Widget>[
                  const HorizontalSpace(size: SpaceSize.xsmall),
                  SizedBox(
                    height: 20,
                    child: VerticalDivider(
                      color: context.colorScheme.tertiary,
                      thickness: 2,
                      radius: const BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  const HorizontalSpace(size: SpaceSize.xsmall),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          averageHours > 0
                              ? '$averageHours h $averageMinutes min'
                              : '$averageMinutes min',
                          style: context.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Ø Fokuszeit',
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(),
                        ),
                      ],
                    ),
                  ),
                ],

                const HorizontalSpace(size: SpaceSize.xsmall),
                SizedBox(
                  height: 20,
                  child: VerticalDivider(
                    color: context.colorScheme.tertiary,
                    thickness: 2,
                    radius: const BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                const HorizontalSpace(size: SpaceSize.xsmall),

                // Total sessions thus far
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        stats.totalInstances.toString(),
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineSmall,
                      ),
                      Text(
                        'Einheiten insgesamt',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const SizedBox(height: 16),

            // Average per session
            if (stats.completedInstances > 0) ...<Widget>[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Durchschnitt pro Einheit',
                    style: context.textTheme.bodyMedium,
                  ),
                  Text(
                    '${stats.averageFocusMinutesPerSession.toStringAsFixed(0)} Min',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 500, width: 500, child: StatsBarChart()),

            // Phases and blocks
            if (stats.totalFocusPhases > 0 ||
                stats.totalCompletedBlocks > 0) ...<Widget>[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (stats.totalFocusPhases > 0)
                    Expanded(
                      child: _StatChip(
                        icon: Icons.replay,
                        label: '${stats.totalFocusPhases} Fokusphasen',
                      ),
                    ),
                  if (stats.totalFocusPhases > 0 &&
                      stats.totalCompletedBlocks > 0)
                    const SizedBox(width: 8),
                  if (stats.totalCompletedBlocks > 0)
                    Expanded(
                      child: _StatChip(
                        icon: Icons.check_circle_outline,
                        label: '${stats.totalCompletedBlocks} Blöcke',
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: context.colorScheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBreakdownItem extends StatelessWidget {
  const _TimeBreakdownItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class ProductivityCard extends StatelessWidget {
  const ProductivityCard({super.key, required this.stats});

  final SessionStatistics stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Produktivität', style: context.textTheme.titleLarge),
            const SizedBox(height: 16),

            // Goals and Tasks
            Row(
              children: <Widget>[
                Expanded(
                  child: _ProductivityMetric(
                    icon: Icons.flag,
                    iconColor: AppPalette.green,
                    label: 'Ziele erreicht',
                    total: stats.totalGoalsCompleted,
                    average: stats.averageGoalsPerSession,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ProductivityMetric(
                    icon: Icons.task_alt,
                    iconColor: AppPalette.purple,
                    label: 'Aufgaben erledigt',
                    total: stats.totalTasksCompleted,
                    average: stats.averageTasksPerSession,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress bars
            if (stats.totalGoalsCompleted > 0 ||
                stats.totalTasksCompleted > 0) ...<Widget>[
              const Divider(),
              const SizedBox(height: 16),
              _ProductivityProgressBar(
                label: 'Ziele',
                value: stats.totalGoalsCompleted,
                color: AppPalette.green,
              ),
              const SizedBox(height: 12),
              _ProductivityProgressBar(
                label: 'Aufgaben',
                value: stats.totalTasksCompleted,
                color: AppPalette.purple,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProductivityMetric extends StatelessWidget {
  const _ProductivityMetric({
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
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(
            '$total',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          Text(
            label,
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (average > 0) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              'Ø ${average.toStringAsFixed(1)}/Einheit',
              style: context.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
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
    required this.color,
  });

  final String label;
  final int value;
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
              '$value',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / (value + 10), // Normalize to look good

          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
