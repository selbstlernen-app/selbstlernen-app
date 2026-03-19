import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/focus_check.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/chart_header.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_prompt/average_focus_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_prompt/focus_check_utils.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_prompt/focus_prompt_chart.dart';
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

  @override
  Widget build(BuildContext context) {
    // Check if current session has any focus checks before calculating
    final hasCurrentFocusChecks = widget.currentInstance.focusChecks.isNotEmpty;
    final hasAnyFocusChecks = widget.allDoneInstances.any(
      (instance) => instance.focusChecks.isNotEmpty,
    );

    // Only calculate if data is given
    int? averageMoodIndex;
    if (showAllInstances && hasAnyFocusChecks) {
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
        ? hasAnyFocusChecks
        : hasCurrentFocusChecks;

    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChartHeader(
            title: 'Fokus-Verlauf',
            instances: widget.allDoneInstances,
            getAttributeValue: (instance) =>
                '''Ø ${calculateSessionAverageFocus(instance).toStringAsFixed(2)} Fokus''',
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
                  children: [
                    Text(
                      Constants.focusEmojis[averageMoodIndex],
                      style: const TextStyle(fontSize: 28),
                    ),
                    const HorizontalSpace(size: SpaceSize.small),
                    Text(
                      showAllInstances
                          ? '''Ø '''
                                '''${calculateOverallAverageFocus(widget.allDoneInstances).toStringAsFixed(1)}'''
                          : '''Ø '''
                                ''' ${calculateSessionAverageFocus(widget.currentInstance)}''',
                      style: context.textTheme.bodyLarge,
                    ),
                  ],
                ),
            ],
          ),

          const VerticalSpace(size: SpaceSize.small),

          if (!hasDataToShow)
            const _EmptyFocusState()
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
        ],
      ),
    );
  }
}

class _EmptyFocusState extends StatelessWidget {
  const _EmptyFocusState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.insights_rounded,
          size: 48,
          color: AppPalette.grey.withValues(alpha: 0.3),
        ),
        const VerticalSpace(size: SpaceSize.small),
        Text(
          'Noch keine Fokus-Daten',
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '''Beantworte Fokus-Abfragen während deiner Lerneinheit, um deinen Verlauf zu sehen.''',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppPalette.grey,
          ),
        ),
      ],
    );
  }
}
