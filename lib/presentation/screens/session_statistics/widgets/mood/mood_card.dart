import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/custom_icon_button.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/history_dialog.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/mood/mood_line_chart.dart';

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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.instances.where((i) => i.mood != null).length > 5)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: context.colorScheme.tertiary,
                    foregroundColor: context.colorScheme.onTertiary,
                    textStyle: context.textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onTertiary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      showAllInstances = !showAllInstances;
                    });
                  },
                  icon: Icon(
                    showAllInstances ? Icons.compress : Icons.expand,
                  ),
                  label: Text(
                    showAllInstances ? 'Weniger' : 'Alle anzeigen',
                  ),
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

          const VerticalSpace(),

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
