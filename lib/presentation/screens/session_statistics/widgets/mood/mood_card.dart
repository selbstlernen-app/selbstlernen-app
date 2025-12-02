import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/custom_icon_button.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/card_layout.dart';
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
    final theme = Theme.of(context);

    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stimmung',
                style: theme.textTheme.headlineMedium,
              ),
            ],
          ),

          const VerticalSpace(size: SpaceSize.xsmall),
          Text(
            'Überblicke deine Stimmungs-Trends',
            style: context.textTheme.bodySmall!.copyWith(
              color: AppPalette.grey,
            ),
          ),

          if (widget.stats.averageMood != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Constants.emojiMoods[widget.stats.averageMood!
                          .round()
                          .clamp(
                            0,
                            4,
                          )],
                      style: const TextStyle(
                        fontSize: 32,
                      ),
                    ),
                    const HorizontalSpace(
                      size: SpaceSize.small,
                    ),

                    Text(
                      'Avg. ${widget.stats.averageMood!.toStringAsFixed(1)}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ],
            ),

          // Chart
          MoodLineChart(
            instances: widget.instances,
            showAllInstances: showAllInstances,
          ),

          // Optional: Mood legend
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                for (var i = 0; i < Constants.emojiMoods.length; i++)
                  _MoodLegendItem(
                    emoji: Constants.emojiMoods[i],
                    label: _getMoodLabel(i),
                  ),
              ],
            ),
          ),

          if (widget.instances.where((i) => i.mood != null).length > 5)
            CustomIconButton(
              icon: Icon(
                showAllInstances ? Icons.compress : Icons.expand,
                size: 16,
              ),
              onPressed: () {
                setState(() {
                  showAllInstances = !showAllInstances;
                });
              },
              isActive: true,
              label: showAllInstances ? 'Weniger' : 'Alle Anzeigen',
            ),
        ],
      ),
    );
  }

  String _getMoodLabel(int index) {
    switch (index) {
      case 0:
        return 'Terrible';
      case 1:
        return 'Bad';
      case 2:
        return 'Okay';
      case 3:
        return 'Good';
      case 4:
        return 'Great';
      default:
        return '';
    }
  }
}

class _MoodLegendItem extends StatelessWidget {
  const _MoodLegendItem({
    required this.emoji,
    required this.label,
  });

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
