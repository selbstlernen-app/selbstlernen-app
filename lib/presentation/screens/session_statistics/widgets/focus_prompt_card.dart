import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/focus_check.dart';

class FocusPromptCard extends StatelessWidget {
  const FocusPromptCard({
    required this.focusChecks,
    super.key,
  });

  final List<FocusCheck> focusChecks;

  @override
  Widget build(BuildContext context) {
    final total = focusChecks.length;
    final good = focusChecks.where((c) => c.level == FocusLevel.good).length;
    final okay = focusChecks.where((c) => c.level == FocusLevel.okay).length;
    final distracted = focusChecks
        .where((c) => c.level == FocusLevel.distracted)
        .length;

    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fokus-Verlauf',
            style: context.textTheme.headlineMedium,
          ),
          const VerticalSpace(
            size: SpaceSize.small,
          ),
          _StatRow(
            emoji: '🎯',
            label: 'Gut fokussiert',
            count: good,
            total: total,
          ),
          _StatRow(
            emoji: '😐',
            label: 'Mittelmäßig',
            count: okay,
            total: total,
          ),
          _StatRow(
            emoji: '😴',
            label: 'Abgelenkt',
            count: distracted,
            total: total,
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.emoji,
    required this.label,
    required this.count,
    required this.total,
  });

  final String emoji;
  final String label;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0
        ? (count / total * 100).toStringAsFixed(0)
        : '0';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const HorizontalSpace(
            size: SpaceSize.small,
          ),
          Expanded(child: Text(label)),
          Text(
            '$count × ($percentage%)',
            style: context.textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}
