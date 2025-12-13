import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/session_status_utils.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/history_dialog.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    required this.stats,
    required this.instances,
    super.key,
  });

  final SessionStatistics stats;
  final List<SessionInstanceModel> instances;

  @override
  Widget build(BuildContext context) {
    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fortschritt', style: context.textTheme.headlineMedium),
              IconButton(
                color: AppPalette.grey.withValues(alpha: 0.5),
                icon: const Icon(Icons.history_rounded),
                onPressed: () => showHistoryBottomSheet(
                  context,
                  instances,
                  'Einheiten-Fortschritt',
                  (instance) => getSubtitle(instance.status),
                ),
              ),
            ],
          ),

          // Progress summary text
          Text(
            stats.totalInstances == 1
                ? '''Abgeschlossen (100%)'''
                : '''${stats.completedInstances + stats.skippedInstances + stats.missedInstances} von ${stats.totalInstances} Einheiten abgeschlossen (${(stats.combinedRate * 100).toStringAsFixed(1)} %)''',
            style: context.textTheme.bodySmall,
          ),

          const VerticalSpace(size: SpaceSize.small),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  // Completed section
                  if (stats.completionRate > 0)
                    Expanded(
                      flex: (stats.completionRate * 1000).toInt(),
                      child: Container(
                        color: getColor(SessionStatus.completed),
                      ),
                    ),
                  // Missed section
                  if (stats.missRate > 0)
                    Expanded(
                      flex: (stats.missRate * 1000).toInt(),
                      child: Container(
                        color: getColor(SessionStatus.missed),
                      ),
                    ),
                  // Skipped section
                  if (stats.skipRate > 0)
                    Expanded(
                      flex: (stats.skipRate * 1000).toInt(),
                      child: Container(
                        color: getColor(SessionStatus.skipped),
                      ),
                    ),
                  // Remaining/open section
                  if (stats.combinedRate < 1)
                    Expanded(
                      flex: ((1 - stats.combinedRate) * 1000).toInt(),
                      child: Container(color: context.colorScheme.tertiary),
                    ),
                ],
              ),
            ),
          ),

          const VerticalSpace(),

          // Stat chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(
                label: 'Durchgeführt',
                value: stats.completedInstances,
                color: getColor(SessionStatus.completed),
                textStyle: context.textTheme.bodySmall,
              ),
              if (stats.missedInstances > 0)
                _StatChip(
                  label: 'Verpasst',
                  value: stats.missedInstances,
                  color: getColor(SessionStatus.missed),
                  textStyle: context.textTheme.bodySmall,
                ),
              if (stats.skippedInstances > 0)
                _StatChip(
                  label: 'Übersprungen',
                  value: stats.skippedInstances,
                  color: getColor(SessionStatus.skipped),
                  textStyle: context.textTheme.bodySmall,
                ),
              _StatChip(
                label: 'Noch offen',
                value: stats.openInstances,
                color: context.colorScheme.onTertiary,
                textStyle: context.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.textStyle,
  });

  final String label;
  final int value;
  final Color color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 4,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const HorizontalSpace(size: SpaceSize.small),
          Text(
            '$value $label',
            style: textStyle?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
