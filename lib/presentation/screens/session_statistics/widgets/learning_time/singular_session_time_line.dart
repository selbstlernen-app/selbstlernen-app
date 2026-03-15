import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

class SingularSessionTimeLine extends StatelessWidget {
  const SingularSessionTimeLine({
    required this.instance,
    required this.plannedTime,
    required this.showPlannedTime,
    super.key,
  });

  final SessionInstanceModel instance;
  final bool showPlannedTime;
  final TimeOfDay plannedTime;

  double _hourFraction(int hour, int minute) => (hour + minute / 60.0) / 24.0;

  @override
  Widget build(BuildContext context) {
    final completedAt = instance.completedAt!;
    final completedFraction = _hourFraction(
      completedAt.hour,
      completedAt.minute,
    );

    final plannedFraction = showPlannedTime
        ? _hourFraction(
            plannedTime.hour,
            plannedTime.minute,
          )
        : null;

    // Difference in minutes from planned time
    // (positive = late, negative = early)
    final differenceMinutes = plannedFraction != null
        ? ((completedFraction - plannedFraction) * 24 * 60).round()
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 24h bar
        _TimelineBar(
          markers: [
            if (plannedFraction != null)
              _TimeMarker(
                fraction: plannedFraction,
                color: AppPalette.grey.withValues(alpha: 0.6),
              ),
            _TimeMarker(
              fraction: completedFraction,
              color: AppPalette.sky,
            ),
          ],
        ),

        const VerticalSpace(size: SpaceSize.xsmall),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['0:00', '6:00', '12:00', '18:00', '24:00']
              .map(
                (l) => Text(
                  l,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppPalette.grey,
                  ),
                ),
              )
              .toList(),
        ),

        const VerticalSpace(
          size: SpaceSize.small,
        ),

        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showPlannedTime)
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppPalette.grey.withValues(alpha: 0.6),
                        ),
                      ),
                      const HorizontalSpace(
                        size: SpaceSize.small,
                      ),
                      Text(
                        'Geplant ${plannedTime.format(context)}',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: AppPalette.grey,
                        ),
                      ),
                    ],
                  ),
                const VerticalSpace(
                  size: SpaceSize.xsmall,
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppPalette.sky,
                      ),
                    ),
                    const HorizontalSpace(
                      size: SpaceSize.small,
                    ),
                    Text(
                      'Durchgeführt ${DateFormat('HH:mm').format(completedAt)}',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: AppPalette.sky,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const HorizontalSpace(
              size: SpaceSize.xlarge,
            ),

            // Trend showing difference in planned vs actual time
            if (differenceMinutes != null) ...[
              Expanded(child: _TrendChip(differenceMinutes: differenceMinutes)),
            ],
          ],
        ),
      ],
    );
  }
}

class _TimeMarker {
  const _TimeMarker({
    required this.fraction,
    required this.color,
  });
  final double fraction;
  final Color color;
}

class _TimelineBar extends StatelessWidget {
  const _TimelineBar({required this.markers});
  final List<_TimeMarker> markers;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: 16,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Timeline track
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Markers (planned // actual time)
              ...markers.map((m) {
                final x = m.fraction * width;
                return Positioned(
                  left: x,
                  top: -2,
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 28,
                        decoration: BoxDecoration(
                          color: m.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.differenceMinutes});
  final int differenceMinutes;

  @override
  Widget build(BuildContext context) {
    final abs = differenceMinutes.abs();
    final isOnTime = abs <= 30;
    final isLate = differenceMinutes > 0;

    final color = isOnTime
        ? AppPalette.emerald
        : abs <= 60
        ? AppPalette.orange
        : AppPalette.rose;

    final label = isOnTime
        ? 'Pünktlich gestartet'
        : isLate
        ? '$abs Min. später als geplant'
        : '$abs Min. früher als geplant';

    final icon = isOnTime
        ? Icons.check_circle_outline_rounded
        : isLate
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const HorizontalSpace(size: SpaceSize.xsmall),
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
