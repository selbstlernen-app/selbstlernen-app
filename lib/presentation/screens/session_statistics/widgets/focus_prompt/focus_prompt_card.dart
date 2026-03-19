import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/focus_check.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/chart_header.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/empty_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_prompt/average_focus_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_prompt/focus_check_utils.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_prompt/focus_prompt_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/reflection_box.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/toggle_show_all_button.dart';

class FocusPromptCard extends StatefulWidget {
  const FocusPromptCard({
    required this.allDoneInstances,
    required this.focusChecks,
    required this.currentInstance,
    required this.showGeneralStatsOnly,
    super.key,
  });

  /// List of all completed sessions, where focus checks were possibly done
  final List<SessionInstanceModel> allDoneInstances;

  /// Current instance; may be a skipped one
  final SessionInstanceModel currentInstance;

  /// Current instance's focus checks, may be empty
  final List<FocusCheck> focusChecks;

  /// Flag to show only trends or not
  /// (when showing stats for no specific instance)
  final bool showGeneralStatsOnly;

  @override
  State<FocusPromptCard> createState() => _FocusPromptCardState();
}

class _FocusPromptCardState extends State<FocusPromptCard> {
  late bool showAllInstances = widget.showGeneralStatsOnly;

  String _getReflectionText(double avg) {
    if (avg >= 2.5) {
      return 'Deine Aufmerksamkeit ist super! Was hilft dir besonders konzentriert zu bleiben?';
    } else if (avg >= 1.5) {
      return 'Deine Aufmerksamkeit ist eher im mittleren Bereich. Wodurch lässt du dich ablenken?';
    } else {
      return 'Dein Fokus ist eher niedrig. Lag es am Thema, an der Umgebung oder brauchst du vielleicht längere Pausen?';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if current session has any focus checks before calculating
    final hasCurrentFocusChecks = widget.currentInstance.focusChecks.isNotEmpty;
    final instancesWithFocusChecks = widget.allDoneInstances
        .where((i) => i.focusChecks.isNotEmpty)
        .toList();

    // Only calculate if data is given
    int? averageMoodIndex;
    if (showAllInstances && instancesWithFocusChecks.isNotEmpty) {
      final avg = calculateOverallAverageFocus(widget.allDoneInstances);
      if (!avg.isNaN && !avg.isInfinite) {
        averageMoodIndex = avg.toInt() - 1;
      }
    } else if (!showAllInstances && hasCurrentFocusChecks) {
      final avg = calculateSessionAverageFocus(widget.currentInstance);
      if (!avg.isNaN && !avg.isInfinite) {
        averageMoodIndex = avg.toInt() - 1;
      }
    }

    // Determine if any data given for the current view mode
    final hasDataToShow = showAllInstances
        ? instancesWithFocusChecks.isNotEmpty
        : hasCurrentFocusChecks;

    final displayedAvg = showAllInstances
        ? calculateOverallAverageFocus(widget.allDoneInstances)
        : calculateSessionAverageFocus(widget.currentInstance);

    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChartHeader(
            title: 'Aufmerksamkeit',
            instances: instancesWithFocusChecks,
            getAttributeValue: (instance) =>
                '''Ø ${calculateSessionAverageFocus(instance).toStringAsFixed(2)} aufmerksam''',
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Do not show toggle button in case of general stats
              if (!widget.showGeneralStatsOnly)
                ToggleShowAllButton(
                  showAll: showAllInstances,
                  thresholdExceeded: widget.allDoneInstances.length > 4,
                  onToggle: () {
                    setState(() => showAllInstances = !showAllInstances);
                  },
                  collapsedLabel: 'Heutige',
                  expandedLabel: 'Trends anzeigen',
                )
              else
                const Spacer(),

              if (widget.allDoneInstances.length > 4 &&
                  averageMoodIndex != null &&
                  averageMoodIndex >= 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Constants.focusEmojis[averageMoodIndex],
                      style: const TextStyle(fontSize: 28),
                    ),
                    const HorizontalSpace(size: SpaceSize.small),
                    Text(
                      '''Ø ${displayedAvg.toStringAsFixed(1)}''',
                      style: context.textTheme.bodyLarge,
                    ),
                  ],
                ),
            ],
          ),

          const VerticalSpace(size: SpaceSize.small),

          if (!hasDataToShow)
            const EmptyChart(
              iconData: Icons.insights_rounded,
              infoTitle: 'Noch keine Fokusdaten',
              infoSubtitle:
                  '''Beantworte Fokusabfragen während deiner Lerneinheit, um deinen Aufmerksamkeits-Verlauf sehen zu können.''',
            )
          else
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeInCubic,
              switchOutCurve: Curves.easeOutCubic,
              child:
                  (showAllInstances // show average chart if clicked; else not
                  ? AverageFocusChart(
                      key: const ValueKey('avg_chart'),
                      instances: widget.allDoneInstances
                          .where((i) => i.focusChecks.isNotEmpty)
                          .toList(),
                    )
                  : FocusLevelChart(
                      key: const ValueKey('level_chart'),
                      instance: widget.currentInstance,
                    )),
            ),
          ReflectionBox(
            color: AppPalette.teal,
            iconData: Icons.lightbulb_outlined,
            reflection: _getReflectionText(displayedAvg),
          ),
        ],
      ),
    );
  }
}
