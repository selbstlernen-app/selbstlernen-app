import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/chart_header.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/empty_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/mood/mood_line_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/reflection_box.dart';
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

  List<SessionInstanceModel> get _ratedInstances =>
      widget.instances
          .where((i) => i.mood != null && i.completedAt != null)
          .toList()
        ..sort((a, b) => a.completedAt!.compareTo(b.completedAt!));

  String _getMoodString(double avg) {
    if (avg < 1.5) {
      return 'schlechte';
    } else if (avg < 2.5) {
      return 'gedrückte';
    } else if (avg < 3.5) {
      return 'gehobene';
    } else {
      return 'gute';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rated = _ratedInstances;

    // Last 3 sessions with notes
    final withNotes = rated
        .where((i) => i.notes != null && i.notes!.trim().isNotEmpty)
        .toList()
        .reversed
        .take(2)
        .toList();

    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChartHeader(
            title: 'Stimmung',
            instances: _ratedInstances,
            getAttributeValue: (instance) {
              final emoji = Constants.emojiMoods[instance.mood!];

              final note = (instance.notes?.trim().isNotEmpty ?? false)
                  ? '\n„${instance.notes!.trim()}"'
                  : '';
              return '$emoji$note';
            },
          ),

          if (widget.stats.averageMood == null)
            const EmptyChart(
              iconData: Icons.emoji_emotions_outlined,
              infoTitle: 'Noch keine Stimmungs-Daten',
              infoSubtitle:
                  '''Bewerte am Ende deiner nächsten Einheit deine Stimmung, um deinen Verlauf zu sehen.''',
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (rated.length > 4)
                  ToggleShowAllButton(
                    showAll: showAllInstances,
                    thresholdExceeded: true,
                    onToggle: () {
                      setState(() => showAllInstances = !showAllInstances);
                    },
                  )
                else
                  const Spacer(),
                // Emoji Avg
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

            const VerticalSpace(),

            MoodLineChart(
              instances: rated,
              showAllInstances: showAllInstances,
            ),

            ReflectionBox(
              color: AppPalette.teal,
              iconData: Icons.question_answer_outlined,
              reflection:
                  'Was sind Gründe für deine durchschnittlich ${_getMoodString(widget.stats.averageMood!)} Stimmung?',
            ),

            // Show recent notes
            if (withNotes.isNotEmpty) ...[
              const VerticalSpace(size: SpaceSize.small),
              Text(
                'Deine letzten Notizen',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const VerticalSpace(size: SpaceSize.xsmall),
              ...withNotes.map(
                (instance) => _NoteSnippet(instance: instance),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _NoteSnippet extends StatelessWidget {
  const _NoteSnippet({required this.instance});
  final SessionInstanceModel instance;

  @override
  Widget build(BuildContext context) {
    final emoji = Constants.emojiMoods[instance.mood!.clamp(0, 4)];
    final date = instance.completedAt != null
        ? DateFormat('dd.MM.yy').format(instance.completedAt!)
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const HorizontalSpace(size: SpaceSize.xsmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppPalette.grey,
                  ),
                ),
                Text(
                  // Truncate long notes
                  instance.notes!.length > 120
                      ? '${instance.notes!.substring(0, 120).trimRight()}…'
                      : instance.notes!,
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
