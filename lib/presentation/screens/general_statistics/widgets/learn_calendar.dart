import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/presentation/view_models/statistics/statistics_view_model.dart';
import 'package:srl_app/presentation/view_models/statistics/ui_model/enriched_session_instance.dart';

/// Shows on which days one has learned;
/// How many sessions were conducted on that particular day
class LearnCalendar extends ConsumerStatefulWidget {
  const LearnCalendar({required this.enrichedInstances, super.key});

  final List<EnrichedSessionInstance> enrichedInstances;

  @override
  ConsumerState<LearnCalendar> createState() => _LearnCalendarState();
}

class _LearnCalendarState extends ConsumerState<LearnCalendar> {
  int? _selectedSessions;
  DateTime? _selectedDate;
  List<EnrichedSessionInstance> _selectedDateInstances = [];
  final GlobalKey _calendarKey = GlobalKey();

  // Generate a color palette based on the given base color
  // Base is the darkest color
  Map<int, Color> generateColorPalette(Color baseColor, int steps) {
    return Map.fromEntries(
      List.generate(steps, (index) {
        final ratio = index / (steps - 1);
        // Target color bit off-white so we can still view it on the map
        final targetColor = Color.lerp(baseColor, Colors.white, 0.9)!;
        final color = Color.lerp(baseColor, targetColor, ratio)!;
        return MapEntry(index, color);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorpalette = generateColorPalette(context.colorScheme.primary, 6);

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
              colorsets: colorpalette,
              datasets: _buildCalendarDataset(),
              weekTextColor: AppPalette.grey,
              textColor: Colors.black,
              monthFontSize: 16,
              initDate: DateTime.now(),
              flexible: true,
              colorMode: ColorMode.color,
              onClick: (DateTime date) {
                final dataset = _buildCalendarDataset();
                setState(() {
                  _selectedDate = date;
                  _selectedSessions = dataset[date] ?? 0;
                  _selectedDateInstances = ref
                      .watch(statisticsViewModelProvider)
                      .getInstancesByDateAndSorted(date);
                });
              },
              size: 30,
              fontSize: 12,
            ),

            const VerticalSpace(size: SpaceSize.small),

            _buildLegend(
              context,
              Map.fromEntries(colorpalette.entries.toList().reversed),
            ),

            if (_selectedDate != null) ...[
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: AppPalette.darkGrey.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  '''Einheiten am ${DateFormat('dd.MM.', 'de_DE').format(_selectedDate!)}: ${_selectedSessions ?? 0}''',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const VerticalSpace(size: SpaceSize.small),
              _buildSessionsList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    if (_selectedDateInstances.isEmpty) {
      return Text(
        'Keine Einheiten an diesem Tag',
        style: context.textTheme.bodyMedium?.copyWith(
          color: AppPalette.grey,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lerneinheiten', style: context.textTheme.headlineSmall),
        const VerticalSpace(size: SpaceSize.xsmall),
        ..._selectedDateInstances.map((enrichedInstance) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: context.colorScheme.primary,
                  size: 20,
                ),
                const HorizontalSpace(
                  size: SpaceSize.small,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat(
                          'HH:mm',
                        ).format(enrichedInstance.instance.scheduledAt),
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Add more instance details here if needed
                      Text(enrichedInstance.sessionName),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Map<DateTime, int> _buildCalendarDataset() {
    final dataset = <DateTime, int>{};

    // Group instances by date
    for (final enrichedInstance in widget.enrichedInstances) {
      if (enrichedInstance.instance.status == SessionStatus.completed) {
        // Normalize to start of day
        final date = DateTime(
          enrichedInstance.instance.scheduledAt.year,
          enrichedInstance.instance.scheduledAt.month,
          enrichedInstance.instance.scheduledAt.day,
        );
        // Increment count for this day
        dataset[date] = (dataset[date] ?? 0) + 1;
      }
    }
    return dataset;
  }

  Widget _buildLegend(BuildContext context, Map<int, Color> colorpalette) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text('Weniger', style: context.textTheme.bodySmall),
        const HorizontalSpace(
          size: SpaceSize.xsmall,
        ),
        ...colorpalette.keys.map(
          (key) => Padding(
            padding: const EdgeInsetsGeometry.only(right: 2),
            child: _legendBox(colorpalette[key]!),
          ),
        ),
        const HorizontalSpace(
          size: SpaceSize.xsmall,
        ),
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
