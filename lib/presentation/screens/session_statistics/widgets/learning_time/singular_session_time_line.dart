import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

class SingularSessionTimeLine extends StatefulWidget {
  const SingularSessionTimeLine({
    required this.instance,
    required this.plannedTime,
    super.key,
  });

  final SessionInstanceModel instance;
  final TimeOfDay plannedTime;

  @override
  State<SingularSessionTimeLine> createState() =>
      _SingularSessionTimeLineState();
}

class _SingularSessionTimeLineState extends State<SingularSessionTimeLine> {
  bool showPlannedTime = false;
  double _hourFraction(int hour, int minute) => (hour + minute / 60.0) / 24.0;

  @override
  Widget build(BuildContext context) {
    final completedAt = widget.instance.completedAt!;
    final completedFraction = _hourFraction(
      completedAt.hour,
      completedAt.minute,
    );
    final plannedFraction = showPlannedTime
        ? _hourFraction(widget.plannedTime.hour, widget.plannedTime.minute)
        : null;

    final plannedDateTime = DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
      widget.plannedTime.hour,
      widget.plannedTime.minute,
    );

    final differenceMinutes = showPlannedTime
        ? completedAt.difference(plannedDateTime).inMinutes
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
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
                        'Geplant ${widget.plannedTime.format(context)}',
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

        const VerticalSpace(
          size: SpaceSize.xsmall,
        ),

        TextButton.icon(
          style: TextButton.styleFrom(
            backgroundColor: context.colorScheme.tertiary,
            foregroundColor: AppPalette.grey,
            visualDensity: VisualDensity.compact,
          ),
          onPressed: () => setState(() => showPlannedTime = !showPlannedTime),
          icon: Icon(
            showPlannedTime ? Icons.visibility_off : Icons.visibility,
            color: context.colorScheme.onTertiary,
            size: 16,
          ),
          label: Text(
            showPlannedTime ? 'Verstecken' : 'Geplante Zeit anzeigen',
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onTertiary,
            ),
          ),
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
        const markerWidth = 4.0;

        return SizedBox(
          height: 32,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              // Track
              Container(
                height: 8,
                width: width,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Markers (planned and actual time)
              ...markers.map((m) {
                final x = (m.fraction * width) - (markerWidth / 2);
                return Positioned(
                  left: x,
                  child: Row(
                    children: [
                      Container(
                        width: markerWidth,
                        height: 24,
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
