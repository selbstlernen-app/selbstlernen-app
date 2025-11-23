import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

/// TODO: IMPLEMENT ON HOME PAGE?
/// Widget to show on which days one has learned;
/// How many sessions were conducted on that particular day
class LearnIntensityMap extends StatefulWidget {
  const LearnIntensityMap({super.key, required this.instances});

  final List<SessionInstanceModel> instances;

  @override
  State<LearnIntensityMap> createState() => _LearnIntensityMapState();
}

class _LearnIntensityMapState extends State<LearnIntensityMap> {
  int? _selectedSessions;
  DateTime? _selectedDate;
  final GlobalKey _calendarKey = GlobalKey();
  Timer? _tooltipTimer;

  @override
  void dispose() {
    _tooltipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Aktivität', style: context.textTheme.headlineMedium),
            const VerticalSpace(size: SpaceSize.xsmall),
            Text(
              'Markiert die Tage, an denen du gelernt hast.',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppPalette.grey,
              ),
            ),

            const VerticalSpace(size: SpaceSize.small),

            HeatMapCalendar(
              key: _calendarKey,
              showColorTip: false,
              colorsets: const <int, Color>{
                1: Color(0xFFE8F5E9),
                2: Color(0xFFA5D6A7),
                3: Color(0xFF66BB6A),
                4: Color(0xFF43A047),
              },
              datasets: _buildCalendarDataset(),
              weekTextColor: AppPalette.grey,
              textColor: Colors.black,
              monthFontSize: 16,
              initDate: DateTime.now(),
              flexible: true,
              colorMode: ColorMode.color,
              onClick: (DateTime date) {
                final Map<DateTime, int> dataset = _buildCalendarDataset();
                setState(() {
                  _selectedDate = date;
                  _selectedSessions = dataset[date] ?? 0;
                });

                _tooltipTimer?.cancel();

                // Auto-dismiss after 3 seconds
                _tooltipTimer = Timer(const Duration(seconds: 3), () {
                  setState(() {
                    _selectedDate = null;
                    _selectedSessions = null;
                  });
                });
              },
              size: 30,
              fontSize: 12,
            ),

            const VerticalSpace(size: SpaceSize.small),

            _buildLegend(context),

            if (_selectedDate != null)
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                decoration: BoxDecoration(
                  color: AppPalette.darkGrey.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  "Einheiten am ${DateFormat('dd.MM.', 'de_DE').format(_selectedDate!)}: ${_selectedSessions ?? 0}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, int> _buildCalendarDataset() {
    final Map<DateTime, int> dataset = <DateTime, int>{};

    // Group instances by date
    for (final SessionInstanceModel instance in widget.instances) {
      if (instance.status == SessionStatus.completed) {
        // Normalize to start of day
        final DateTime date = DateTime(
          instance.scheduledAt.year,
          instance.scheduledAt.month,
          instance.scheduledAt.day,
        );
        // Increment count for this day
        dataset[date] = (dataset[date] ?? 0) + 1;
      }
    }
    return dataset;
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
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
