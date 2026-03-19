import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/learning_strategy/strategy_usage_for_session.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/empty_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/toggle_show_all_button.dart';

class StrategyComparisonChart extends ConsumerStatefulWidget {
  const StrategyComparisonChart({
    required this.strategies,
    required this.currentStrategyIds,
    super.key,
  });

  final List<StrategyUsageForSession> strategies;
  final List<int> currentStrategyIds;

  @override
  ConsumerState<StrategyComparisonChart> createState() =>
      _StrategyComparisonChartState();
}

class _StrategyComparisonChartState
    extends ConsumerState<StrategyComparisonChart> {
  bool showPastStrategies = false;

  @override
  Widget build(BuildContext context) {
    // Filter only rated strategies
    final ratedStrategies = widget.strategies
        .where((s) => s.ratings.isNotEmpty)
        .toList();

    final currentStrategies = ratedStrategies
        .where((s) => widget.currentStrategyIds.contains(s.strategyId))
        .toList();

    final pastStrategies = ratedStrategies
        .where((s) => !widget.currentStrategyIds.contains(s.strategyId))
        .toList();

    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Lernstrategien im Vergleich',
                style: context.textTheme.headlineMedium,
              ),
            ],
          ),

          const VerticalSpace(),

          if (currentStrategies.isEmpty)
            const EmptyChart(
              iconData: Icons.star_outline_rounded,
              infoTitle: 'Noch keine Ratingdaten',
              infoSubtitle:
                  '''Bewerte am Ende deiner nächsten Einheit deine Lernstrategien, um ihre Effektvität zu verfolgen.''',
            )
          else ...[
            ...currentStrategies.map((strategy) {
              return ProgressBarRating(strategy: strategy);
            }),

            const VerticalSpace(),

            ToggleShowAllButton(
              showAll: showPastStrategies,
              onToggle: () {
                setState(() => showPastStrategies = !showPastStrategies);
              },
              thresholdExceeded: pastStrategies.isNotEmpty,
              expandedLabel: 'Vergangene Strategien anzeigen',
            ),

            // Past strategies
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: showPastStrategies
                  ? Column(
                      children: [
                        const VerticalSpace(),
                        ...pastStrategies.map((strategy) {
                          return ProgressBarRating(strategy: strategy);
                        }),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }
}

class ProgressBarRating extends ConsumerWidget {
  const ProgressBarRating({required this.strategy, super.key});

  final StrategyUsageForSession strategy;

  Color _getColorForRating(double rating) {
    if (rating >= 4) return AppPalette.green;
    if (rating >= 3) return AppPalette.orange;
    return AppPalette.red;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  strategy.strategyTitle,
                  style: context.textTheme.bodyMedium,
                ),
              ),
              Text(
                strategy.averageRating!.toStringAsFixed(2),
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const HorizontalSpace(
                size: SpaceSize.xsmall,
              ),
              const Icon(
                Icons.star,
                size: 14,
              ),
            ],
          ),
          const VerticalSpace(
            size: SpaceSize.small,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (strategy.averageRating ?? 0) / 5.0,
              minHeight: 8,
              backgroundColor: context.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getColorForRating(strategy.averageRating!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
