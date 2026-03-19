import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/chart_header.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/empty_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/learning_time/all_sessions_scatter_plot.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/learning_time/learning_time_type.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/learning_time/singular_session_time_line.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/reflection_box.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/toggle_show_all_button.dart';

class SessionTimingCard extends StatefulWidget {
  const SessionTimingCard({
    required this.allDoneInstances,
    required this.currentInstance,
    required this.plannedTime,
    this.showGeneralStatsOnly = false,
    super.key,
  });

  final List<SessionInstanceModel> allDoneInstances;
  final SessionInstanceModel currentInstance;
  final TimeOfDay plannedTime;

  final bool showGeneralStatsOnly;

  @override
  State<SessionTimingCard> createState() => _SessionTimingCardState();
}

class _SessionTimingCardState extends State<SessionTimingCard> {
  late bool showAllInstances = widget.showGeneralStatsOnly;
  bool showPlannedTime = false;

  LearningTimeType _getAvgLearningTimeType(
    List<SessionInstanceModel> instances,
  ) {
    final hours = instances
        .where((i) => i.completedAt != null)
        .map((i) => i.completedAt!.hour + i.completedAt!.minute / 60.0)
        .toList();

    if (hours.isEmpty) return LearningTimeType.undefined;

    final median = (hours..sort())[hours.length ~/ 2];

    if (median < 9) return LearningTimeType.earlyBird;
    if (median < 12) return LearningTimeType.morningLearner;
    if (median < 17) return LearningTimeType.afternoonLearner;
    if (median < 21) return LearningTimeType.eveningLearner;
    return LearningTimeType.nightOwl;
  }

  @override
  Widget build(BuildContext context) {
    final completedInstances =
        widget.allDoneInstances.where((i) => i.completedAt != null).toList()
          ..sort((a, b) => a.completedAt!.compareTo(b.completedAt!));

    final hasData = showAllInstances
        ? completedInstances.isNotEmpty
        : widget.currentInstance.completedAt != null;

    final avgLearningTimeType = _getAvgLearningTimeType(completedInstances);

    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChartHeader(
            title: showAllInstances ? 'Lernzeiten' : 'Lernzeit',
            instances: widget.allDoneInstances,
            getAttributeValue: (instance) {
              if (instance.completedAt == null) return '–';
              final completed = DateFormat(
                'HH:mm',
              ).format(instance.completedAt!);
              final planned =
                  '${widget.plannedTime.hour.toString().padLeft(2, '0')}:'
                  '${widget.plannedTime.minute.toString().padLeft(2, '0')}';
              return 'Geplant: $planned\nAbgeschlossen: $completed';
            },
          ),

          // Toggle + TimeBadge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!widget.showGeneralStatsOnly)
                ToggleShowAllButton(
                  showAll: showAllInstances,
                  thresholdExceeded: completedInstances.length > 1,
                  onToggle: () =>
                      setState(() => showAllInstances = !showAllInstances),
                  collapsedLabel: 'Diese Sitzung',
                  expandedLabel: 'Alle Sitzungen',
                )
              else
                const Spacer(),

              if (showAllInstances &&
                  avgLearningTimeType != LearningTimeType.undefined)
                _TimeTypeBadge(timeType: avgLearningTimeType),
            ],
          ),

          const VerticalSpace(),

          if (!hasData)
            const EmptyChart(
              iconData: Icons.schedule_rounded,
              infoTitle: 'Noch keine Lernzeit-Daten',
              infoSubtitle:
                  '''Schließe deine nächste Sitzung ab, um zu sehen wann du am häufigsten lernst.''',
            )
          else
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: showAllInstances
                  ? AllSessionsScatterPlot(
                      key: const ValueKey('all'),
                      instances: completedInstances,
                      plannedTime: widget.plannedTime,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingularSessionTimeLine(
                          key: const ValueKey('single'),
                          instance: widget.currentInstance,
                          showPlannedTime: showPlannedTime,
                          plannedTime: widget.plannedTime,
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            textStyle: context.textTheme.labelSmall,
                          ),
                          onPressed: () => setState(() {
                            showPlannedTime = !showPlannedTime;
                          }),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                showPlannedTime
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              const HorizontalSpace(
                                size: SpaceSize.xsmall,
                              ),
                              Text(
                                showPlannedTime
                                    ? 'Ausblenden'
                                    : 'Geplante Zeit einblenden',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

          // Reflection Box
          if (showAllInstances &&
              avgLearningTimeType != LearningTimeType.undefined) ...[
            ReflectionBox(
              color: avgLearningTimeType.color,
              reflection: avgLearningTimeType.timeInsight,
              emoji: avgLearningTimeType.emoji,
            ),
          ],
        ],
      ),
    );
  }
}

/// Badge given related to the time of learning
class _TimeTypeBadge extends StatelessWidget {
  const _TimeTypeBadge({required this.timeType});
  final LearningTimeType timeType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: timeType.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: timeType.color,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Text(timeType.emoji, style: const TextStyle(fontSize: 16)),
          const HorizontalSpace(size: SpaceSize.xsmall),
          Text(
            timeType.label,
            style: context.textTheme.bodySmall?.copyWith(
              color: timeType.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
