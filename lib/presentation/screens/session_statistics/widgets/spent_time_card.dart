import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/stats_bar_chart.dart';

class SpentTimeCard extends ConsumerWidget {
  const SpentTimeCard({
    super.key,
    required this.stats,
    required this.weekdayMinutes,
  });

  final SessionStatistics stats;
  final List<double> weekdayMinutes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

            const VerticalSpace(size: SpaceSize.xsmall),
            Divider(
              color: context.colorScheme.tertiary,
              thickness: 4,
              radius: const BorderRadius.all(Radius.circular(10)),
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

                if (stats.averageFocusMinutesPerSession > 0) ...[
                  _StatColumn(
                    label: 'Ø Fokuszeit',
                    value: averageHours > 0
                        ? '$averageHours h $averageMinutes min'
                        : '$averageMinutes min',
                  ),
                  _StatDivider(),
                ],

                _StatColumn(
                  label: 'Gesamtanzahl',
                  value: stats.totalInstances.toString(),
                ),
              ],
            ),

            const VerticalSpace(size: SpaceSize.xlarge),

            // Bar chart
            SizedBox(
              height: 200,
              child: StatsBarChart(weekdayMinutes: weekdayMinutes),
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
        radius: const BorderRadius.all(Radius.circular(10)),
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

// class ProductivityCard extends StatelessWidget {
//   const ProductivityCard({super.key, required this.stats});

//   final SessionStatistics stats;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Text('Produktivität', style: context.textTheme.titleLarge),
//             const SizedBox(height: 16),

//             // Goals and Tasks
//             Row(
//               children: <Widget>[
//                 Expanded(
//                   child: _ProductivityMetric(
//                     icon: Icons.flag,
//                     iconColor: AppPalette.green,
//                     label: 'Ziele erreicht',
//                     total: stats.totalGoalsCompleted,
//                     average: stats.averageGoalsPerSession,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: _ProductivityMetric(
//                     icon: Icons.task_alt,
//                     iconColor: AppPalette.purple,
//                     label: 'Aufgaben erledigt',
//                     total: stats.totalTasksCompleted,
//                     average: stats.averageTasksPerSession,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // Progress bars
//             if (stats.totalGoalsCompleted > 0 ||
//                 stats.totalTasksCompleted > 0) ...<Widget>[
//               const Divider(),
//               const SizedBox(height: 16),
//               _ProductivityProgressBar(
//                 label: 'Ziele',
//                 value: stats.totalGoalsCompleted,
//                 color: AppPalette.green,
//               ),
//               const SizedBox(height: 12),
//               _ProductivityProgressBar(
//                 label: 'Aufgaben',
//                 value: stats.totalTasksCompleted,
//                 color: AppPalette.purple,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ProductivityMetric extends StatelessWidget {
//   const _ProductivityMetric({
//     required this.icon,
//     required this.iconColor,
//     required this.label,
//     required this.total,
//     required this.average,
//   });

//   final IconData icon;
//   final Color iconColor;
//   final String label;
//   final int total;
//   final double average;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: iconColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: <Widget>[
//           Icon(icon, color: iconColor, size: 32),
//           const SizedBox(height: 8),
//           Text(
//             '$total',
//             style: context.textTheme.headlineMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: iconColor,
//             ),
//           ),
//           Text(
//             label,
//             style: context.textTheme.bodySmall,
//             textAlign: TextAlign.center,
//           ),
//           if (average > 0) ...<Widget>[
//             const SizedBox(height: 4),
//             Text(
//               'Ø ${average.toStringAsFixed(1)}/Einheit',
//               style: context.textTheme.bodySmall?.copyWith(
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// class _ProductivityProgressBar extends StatelessWidget {
//   const _ProductivityProgressBar({
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   final String label;
//   final int value;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: <Widget>[
//             Text(label, style: context.textTheme.bodyMedium),
//             Text(
//               '$value',
//               style: context.textTheme.titleSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         LinearProgressIndicator(
//           value: value / (value + 10), // Normalize to look good

//           valueColor: AlwaysStoppedAnimation<Color>(color),
//           minHeight: 8,
//           borderRadius: BorderRadius.circular(4),
//         ),
//       ],
//     );
//   }
// }
