import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/card_layout.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/core/utils/time_utils.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/focus_time_spent/focus_time_bar_chart.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/history_dialog.dart';
import 'package:srl_app/presentation/screens/session_statistics/widgets/toggle_show_all_button.dart';

class FocusTimeSpentCard extends StatefulWidget {
  const FocusTimeSpentCard({
    required this.stats,
    required this.completedInstances,
    required this.targetFocusMinutes,
    super.key,
  });

  final SessionStatistics stats;
  final List<SessionInstanceModel> completedInstances;
  final double targetFocusMinutes;

  @override
  State<FocusTimeSpentCard> createState() => _FocusTimeSpentCardState();
}

class _FocusTimeSpentCardState extends State<FocusTimeSpentCard> {
  bool showAllInstances = false;

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
    final expectedStr = TimeUtils.formatTimeString(
      totalSeconds: (widget.targetFocusMinutes * 60).toInt(),
    );

    final displayedInstances = showAllInstances
        ? widget.completedInstances
        : widget.completedInstances.take(5).toList();

    final chartHeight =
        (showAllInstances ? (widget.completedInstances.length * 36) : 200)
            .toDouble();

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

          // Key stats
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TimeStatChip(
                label: 'Heute',
                timeString: todayStr,
                color: AppPalette.pink,
              ),
              if (widget.stats.averageFocusMinutesPerSession > 0)
                _TimeStatChip(
                  label: 'Ø Fokuszeit',
                  timeString: avgStr,
                  color: AppPalette.orange,
                ),
              _TimeStatChip(
                label: 'Erwartet',
                timeString: expectedStr,
                color: AppPalette.teal,
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
            height: showAllInstances ? chartHeight : 200,
            child: FocusTimeBarChart(
              lastInstances: displayedInstances,
              dates: displayedInstances
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
    final displayTime = timeString.hours != null
        ? '${timeString.hours} h ${timeString.minutes} min'
        : '${timeString.minutes} min';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayTime,
                style: context.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const VerticalSpace(
            size: SpaceSize.xsmall,
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
