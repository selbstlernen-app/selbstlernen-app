import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

/// TODO: IMPLEMENT ON HOME PAGE?
/// Widget to show on which days one has learned;
/// How many sessions were conducted on that particular day
class LearnIntensityMap extends StatelessWidget {
  const LearnIntensityMap({super.key, required this.instances});

  final List<SessionInstanceModel> instances;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Aktivität', style: context.textTheme.titleLarge),
            const VerticalSpace(size: SpaceSize.small),
            Text(
              'Zeigt an welchen Tagen du gelernt hast',
              style: context.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),

            HeatMapCalendar(
              showColorTip: false,
              colorsets: const <int, Color>{
                1: Color(0xFFE8F5E9),
                2: Color(0xFFA5D6A7),
                3: Color(0xFF66BB6A),
                4: Color(0xFF43A047),
              },
              datasets: _buildCalendarDataset(),
              initDate: _getStartDate(),
              flexible: true,
              colorMode: ColorMode.color,
              size: 30,
              fontSize: 12,
            ),
            const VerticalSpace(size: SpaceSize.small),

            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Map<DateTime, int> _buildCalendarDataset() {
    final Map<DateTime, int> dataset = <DateTime, int>{};

    // Group instances by date
    for (final SessionInstanceModel instance in instances) {
      if (instance.status == SessionStatus.completed) {
        // Normalize to start of day for calendar
        final DateTime date = DateTime(
          instance.scheduledAt.year,
          instance.scheduledAt.month,
          instance.scheduledAt.day,
        );

        // Increment count for this day (intensity)
        dataset[date] = (dataset[date] ?? 0) + 1;
      }
    }

    return dataset;
  }

  DateTime _getStartDate() {
    if (instances.isEmpty) return DateTime.now();

    // Start from first instance or 3 months ago, whichever is more recent
    final SessionInstanceModel firstInstance = instances.reduce(
      (SessionInstanceModel a, SessionInstanceModel b) =>
          a.scheduledAt.isBefore(b.scheduledAt) ? a : b,
    );
    final DateTime threeMonthsAgo = DateTime.now().subtract(
      const Duration(days: 90),
    );

    return firstInstance.scheduledAt.isAfter(threeMonthsAgo)
        ? firstInstance.scheduledAt
        : threeMonthsAgo;
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Weniger', style: context.textTheme.bodySmall),
        const SizedBox(width: 8),
        _legendBox(const Color(0xFFE8F5E9)),
        const SizedBox(width: 4),
        _legendBox(const Color(0xFFA5D6A7)),
        const SizedBox(width: 4),
        _legendBox(const Color(0xFF66BB6A)),
        const SizedBox(width: 4),
        _legendBox(const Color(0xFF43A047)),
        const SizedBox(width: 8),
        Text('Mehr', style: context.textTheme.bodySmall),
      ],
    );
  }

  Widget _legendBox(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
