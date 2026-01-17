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
    final total = instances.length;
    final completed = instances
        .where((i) => i.status == SessionStatus.completed)
        .length;
    final missed = instances
        .where((i) => i.status == SessionStatus.missed)
        .length;
    final skipped = instances
        .where((i) => i.status == SessionStatus.skipped)
        .length;
    final open = instances
        .where(
          (i) =>
              i.status == SessionStatus.scheduled ||
              i.status == SessionStatus.inProgress,
        )
        .length;

    final completionRate = total > 0 ? completed / total : 0.0;
    final missRate = total > 0 ? missed / total : 0.0;
    final skipRate = total > 0 ? skipped / total : 0.0;
    final combinedRate = completionRate + missRate + skipRate;

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
            (total == 1 && completed == 1)
                ? 'Abgeschlossen (100%)'
                : '$completed von $total Einheiten durchgeführt (${(completionRate * 100).toStringAsFixed(0)}%)',
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
                  if (completionRate > 0)
                    Expanded(
                      flex: (completionRate * 100).toInt(),
                      child: Container(
                        color: getColor(SessionStatus.completed),
                      ),
                    ),
                  if (missRate > 0)
                    Expanded(
                      flex: (missRate * 100).toInt(),
                      child: Container(color: getColor(SessionStatus.missed)),
                    ),
                  if (skipRate > 0)
                    Expanded(
                      flex: (skipRate * 100).toInt(),
                      child: Container(color: getColor(SessionStatus.skipped)),
                    ),
                  // Rest is filled by open instances
                  if (combinedRate < 1)
                    Expanded(
                      flex: ((1 - combinedRate) * 100).toInt(),
                      child: Container(
                        color: context.colorScheme.surfaceContainerHighest,
                      ),
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
                value: completed,
                color: getColor(SessionStatus.completed),
              ),
              if (missed > 0)
                _StatChip(
                  label: 'Verpasst',
                  value: missed,
                  color: getColor(SessionStatus.missed),
                ),
              if (skipped > 0)
                _StatChip(
                  label: 'Übersprungen',
                  value: skipped,
                  color: getColor(SessionStatus.skipped),
                ),
              if (open > 0)
                _StatChip(
                  label: 'Noch offen',
                  value: open,
                  color: AppPalette.grey,
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
  });

  final String label;
  final int value;
  final Color color;

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
            style: context.textTheme.bodySmall!.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
