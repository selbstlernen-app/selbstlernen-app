import 'dart:math';

import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/time_utils.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_time_spent/focus_time_bar_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/history_dialog.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/toggle_show_all_button.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';

class FocusTimeSpentCard extends StatefulWidget {
  const FocusTimeSpentCard({
    required this.stats,
    required this.completedInstances,
    required this.targetFocusMinutes,
    required this.showGeneralStatsOnly,
    this.sessionType = SessionComplexity.simple,
    super.key,
  });

  final SessionStatistics stats;
  final List<SessionInstanceModel> completedInstances;
  final double targetFocusMinutes;
  final SessionComplexity sessionType;
  final bool showGeneralStatsOnly;

  @override
  State<FocusTimeSpentCard> createState() => _FocusTimeSpentCardState();
}

class _FocusTimeSpentCardState extends State<FocusTimeSpentCard> {
  bool showAllInstances = false;

  List<SessionInstanceModel> _getDisplayedInstances() {
    if (showAllInstances) return widget.completedInstances;
    return widget.completedInstances.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final latestInstance = widget.completedInstances.firstOrNull;
    final todayFocusSeconds = latestInstance?.totalFocusSecondsElapsed ?? 0;

    final todayStr = TimeUtils.formatTimeString(
      totalSeconds: todayFocusSeconds,
    );

    final avgStr = TimeUtils.formatTimeString(
      totalSeconds: (widget.stats.averageFocusMinutesPerSession * 60).toInt(),
    );
    final breakStr = TimeUtils.formatTimeString(
      totalSeconds: (widget.stats.averageBreakMinutesPerSession * 60).toInt(),
    );
    final expectedStr = TimeUtils.formatTimeString(
      totalSeconds: (widget.targetFocusMinutes * 60).toInt(),
    );

    final todayMinutes = todayFocusSeconds / 60;
    final hitTarget = todayMinutes >= widget.targetFocusMinutes;

    final chartHeight = showAllInstances
        ? min(widget.completedInstances.length * 32, 500)
        : 200;

    final isAdvancedTimer = widget.sessionType == SessionComplexity.advanced;

    return CardLayout(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fokuszeit', style: context.textTheme.headlineMedium),
              IconButton(
                color: AppPalette.grey.withValues(alpha: 0.5),
                icon: const Icon(Icons.history_rounded),
                onPressed: () => showHistoryBottomSheet(
                  context,
                  widget.completedInstances,
                  'Fokuszeit',
                  (instance) {
                    final timeString = TimeUtils.formatTimeString(
                      totalSeconds: instance.totalFocusSecondsElapsed,
                    );
                    return timeString.hours != null
                        ? '${timeString.hours} h ${timeString.minutes} min'
                        : '${timeString.minutes} min ${timeString.seconds}s';
                  },
                ),
              ),
            ],
          ),

          const VerticalSpace(
            size: SpaceSize.small,
          ),

          // Key stats
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!widget.showGeneralStatsOnly)
                _TimeStatChip(
                  label: hitTarget ? 'Ziel erreicht 🎯' : 'Heute',
                  timeString: todayStr,
                  color: hitTarget ? AppPalette.emerald : AppPalette.fuchsia,
                ),

              _TimeStatChip(
                label: 'Erwartet',
                timeString: expectedStr,
                color: AppPalette.teal,
              ),

              if (widget.stats.averageFocusMinutesPerSession > 0)
                _TimeStatChip(
                  label: 'Ø Fokus',
                  timeString: avgStr,
                  color: AppPalette.pink,
                ),

              if (isAdvancedTimer &&
                  widget.stats.averageBreakMinutesPerSession > 0)
                _TimeStatChip(
                  label: 'Ø Pause',
                  timeString: breakStr,
                  color: AppPalette.orange,
                ),
            ],
          ),

          const VerticalSpace(
            size: SpaceSize.small,
          ),

          // Reusable toggle button
          ToggleShowAllButton(
            showAll: showAllInstances,
            thresholdExceeded: widget.completedInstances.length > 5,
            onToggle: () {
              setState(() => showAllInstances = !showAllInstances);
            },
          ),

          const VerticalSpace(size: SpaceSize.small),

          // Bar chart
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            height: chartHeight.toDouble(),
            child: FocusTimeBarChart(
              sessionType: widget.sessionType,
              lastInstances: _getDisplayedInstances(),
              dates: _getDisplayedInstances()
                  .map((i) => i.completedAt ?? DateTime.now())
                  .toList(),
              targetFocusMinutes: widget.targetFocusMinutes,
              averageFocusMinutes: widget.stats.averageFocusMinutesPerSession,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeStatChip extends StatelessWidget {
  const _TimeStatChip({
    required this.label,
    required this.timeString,
    required this.color,
  });

  final String label;
  final TimeString timeString;
  final Color color;

  @override
  Widget build(BuildContext context) {
    String displayTime;

    if (timeString.hours != null && int.parse(timeString.hours!) > 0) {
      displayTime = '${timeString.hours} h ${timeString.minutes} min';
    } else {
      displayTime = '${timeString.minutes} min';
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayTime,
            style: context.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppPalette.grey,
            ),
          ),
        ],
      ),
    );
  }
}
