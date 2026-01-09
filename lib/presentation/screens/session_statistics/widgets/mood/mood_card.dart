import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/history_dialog.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/mood/mood_line_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/toggle_show_all_button.dart';

class MoodCard extends StatefulWidget {
  const MoodCard({
    required this.stats,
    required this.instances,
    super.key,
  });

  final SessionStatistics stats;
  final List<SessionInstanceModel> instances;

  @override
  State<MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<MoodCard> {
  bool showAllInstances = false;

  @override
  Widget build(BuildContext context) {
    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stimmung',
                style: context.textTheme.headlineMedium,
              ),
              IconButton(
                color: AppPalette.grey.withValues(alpha: 0.5),
                icon: const Icon(Icons.history_rounded),
                onPressed: () => showHistoryBottomSheet(
                  context,
                  widget.instances,
                  'Stimmung',
                  (instance) => instance.mood != null
                      ? Constants.emojiMoods[instance.mood!]
                      : '-',
                ),
              ),
            ],
          ),

          if (widget.stats.averageMood == null) const _EmptyMoodState(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.instances.where((i) => i.mood != null).length > 4)
                ToggleShowAllButton(
                  showAll: showAllInstances,
                  thresholdExceeded:
                      widget.instances.where((i) => i.mood != null).length > 4,
                  onToggle: () {
                    setState(() => showAllInstances = !showAllInstances);
                  },
                ),

              // Average mood
              if (widget.stats.averageMood != null)
                Row(
                  children: [
                    Text(
                      Constants.emojiMoods[widget.stats.averageMood!
                          .round()
                          .clamp(
                            0,
                            4,
                          )],
                      style: const TextStyle(
                        fontSize: 28,
                      ),
                    ),
                    const HorizontalSpace(
                      size: SpaceSize.small,
                    ),

                    Text(
                      'Ø ${widget.stats.averageMood!.toStringAsFixed(1)}',
                      style: context.textTheme.bodyLarge,
                    ),
                  ],
                ),
            ],
          ),

          const VerticalSpace(size: SpaceSize.small),

          // Chart
          if (widget.instances.where((i) => i.mood != null).length > 1)
            MoodLineChart(
              instances: widget.instances,
              showAllInstances: showAllInstances,
            ),
        ],
      ),
    );
  }
}

class _EmptyMoodState extends StatelessWidget {
  const _EmptyMoodState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const VerticalSpace(size: SpaceSize.small),
        Icon(
          Icons.emoji_emotions_outlined,
          size: 48,
          color: AppPalette.grey.withValues(alpha: 0.3),
        ),
        const VerticalSpace(size: SpaceSize.small),
        Text(
          'Noch keine Stimmungs-Daten',
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '''Bewerte am Ende deiner nächsten Einheit deine Stimmung, um deinen Verlauf zu sehen.''',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppPalette.grey,
          ),
        ),
      ],
    );
  }
}
