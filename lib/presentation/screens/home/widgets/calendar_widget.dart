import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/view_models/home/home_view_model.dart';

class CalendarWidget extends ConsumerWidget {
  const CalendarWidget({super.key});

  List<DateTime> _generateDays() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final offset = now.weekday < 3 ? 0 : 2;

    return List.generate(
      6,
      (i) => DateUtils.dateOnly(startOfWeek.add(Duration(days: i + offset))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(
      homeViewModelProvider.select((s) => s.dateToFilterFor),
    );

    final daysToDisplay = _generateDays();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: daysToDisplay.map((date) {
            final isSelected = DateUtils.isSameDay(date, selectedDate);

            return SizedBox(
              width: (constraints.maxWidth / daysToDisplay.length) - 4,
              child: GestureDetector(
                onTap: () {
                  if (!isSelected) {
                    ref.read(homeViewModelProvider.notifier).updateDate(date);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colorScheme.primary
                        : context.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat(
                          'EE',
                          'de_DE',
                        ).format(date).replaceAll('.', ''),
                        style: context.textTheme.labelMedium?.copyWith(
                          color: isSelected
                              ? context.colorScheme.onPrimary
                              : context.colorScheme.onTertiary,
                        ),
                      ),
                      Text(
                        '${date.day}',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? context.colorScheme.onPrimary
                              : context.colorScheme.onTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
