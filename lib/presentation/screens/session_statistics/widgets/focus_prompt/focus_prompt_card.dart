import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/focus_check.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_prompt/average_focus_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_prompt/focus_check_utils.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_prompt/focus_prompt_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/history_dialog.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/toggle_show_all_button.dart';

class FocusPromptCard extends StatefulWidget {
  const FocusPromptCard({
    required this.allDoneInstances,
    required this.focusChecks,
    required this.currentInstance,
    required this.showGeneralStatsOnly,
    super.key,
  });

  final List<SessionInstanceModel> allDoneInstances;
  final SessionInstanceModel currentInstance;
  final List<FocusCheck> focusChecks;
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

    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fokus-Verlauf',
                style: context.textTheme.headlineMedium,
              ),

              IconButton(
                color: AppPalette.grey.withValues(alpha: 0.5),
                icon: const Icon(
                  Icons.history_rounded,
                ),
                onPressed: () => showHistoryBottomSheet(
                  context,
                  widget.allDoneInstances,
                  'Fokus-Verlauf',
                  (instance) =>
                      '''Ø ${calculateSessionAverageFocus(instance)} Fokus''',
                ),
              ),
            ],
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
                ),

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

          AnimatedSwitcher(
            duration: const Duration(seconds: 2),
            switchInCurve: Curves.fastEaseInToSlowEaseOut,
            switchOutCurve: Curves.fastEaseInToSlowEaseOut,
            child: showAllInstances
                ? AverageFocusChart(instances: widget.allDoneInstances)
                : FocusLevelChart(instance: widget.currentInstance),
          ),
        ],
      ),
    );
  }
}
