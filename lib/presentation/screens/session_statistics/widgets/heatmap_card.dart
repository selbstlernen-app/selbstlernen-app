import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/horizontal_space.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

class HeatmapCard extends StatelessWidget {
  const HeatmapCard({super.key, required this.instances});

  final List<SessionInstanceModel> instances;

  @override
  Widget build(BuildContext context) {
    final List<SessionInstanceModel> completedInstances = instances
        .where((SessionInstanceModel i) => i.status == SessionStatus.completed)
        .toList();

    // Only skipped sessions we do not want to visualize
    if (completedInstances.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Lernzeiten', style: context.textTheme.headlineMedium),
            const VerticalSpace(size: SpaceSize.small),
            Text(
              'Uhrzeiten, zu denen du am häufigsten lernst',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppPalette.darkGrey,
              ),
            ),
            const VerticalSpace(size: SpaceSize.medium),
            _buildTimeOfDayChart(context, completedInstances),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeOfDayChart(
    BuildContext context,
    List<SessionInstanceModel> instances,
  ) {
    // Group instances by the hour and count how many on a specific hour
    final Map<int, int> hourCounts = <int, int>{};

    for (final SessionInstanceModel instance in instances) {
      if (instance.completedAt != null) {
        // Get the hour when session was completed
        final int completionHour = instance.completedAt!.hour;
        hourCounts[completionHour] = (hourCounts[completionHour] ?? 0) + 1;
      }
    }

    // Find max count for scaling
    final int maxCount = hourCounts.values.isEmpty
        ? 1
        : hourCounts.values.reduce((int a, int b) => a > b ? a : b);

    return Column(
      children: <Widget>[
        // Time blocks (24 hours)
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List<Widget>.generate(24, (int hour) {
            final int count = hourCounts[hour] ?? 0;
            final double intensity = count == 0
                ? 0
                : (count / maxCount).clamp(0.2, 1.0);

            return _TimeBlock(hour: hour, count: count, intensity: intensity);
          }),
        ),
        const SizedBox(height: 16),
        _buildTimeLegend(context),
      ],
    );
  }

  Widget _buildTimeLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(Icons.wb_sunny, size: 16, color: Colors.orange),
            const HorizontalSpace(size: SpaceSize.small),
            Text('Morgens', style: context.textTheme.bodySmall),
          ],
        ),

        Row(
          children: <Widget>[
            const Icon(Icons.wb_twilight, size: 16, color: Colors.blue),
            const HorizontalSpace(size: SpaceSize.small),
            Text('Nachmittags', style: context.textTheme.bodySmall),
          ],
        ),

        Row(
          children: <Widget>[
            const Icon(Icons.nights_stay, size: 16, color: Colors.indigo),
            const HorizontalSpace(size: SpaceSize.small),
            Text('Abends', style: context.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.hour,
    required this.count,
    required this.intensity,
  });

  final int hour;
  final int count;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final Color color = _getColorForHour(hour);
    final Color backgroundColor = count > 0
        ? color.withValues(alpha: 0.2 + (intensity * 0.8))
        : Colors.grey[200]!;

    return Tooltip(
      message: count > 0
          ? '$hour:00 Uhr\n$count ${count == 1 ? "Session" : "Sessions"}'
          : '$hour:00 Uhr\nKeine Sessions',
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: count > 0 ? color : Colors.grey[300]!,
            width: count > 0 ? 2 : 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '$hour',
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: count > 0 ? color : Colors.grey[600],
                ),
              ),
              if (count > 0)
                Text('●', style: TextStyle(color: color, fontSize: 8)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForHour(int hour) {
    if (hour >= 6 && hour < 12) {
      // Morning: Orange
      return Colors.orange;
    } else if (hour >= 12 && hour < 18) {
      // Afternoon: Blue
      return Colors.blue;
    } else {
      // Evening/Night: Indigo
      return Colors.indigo;
    }
  }
}
