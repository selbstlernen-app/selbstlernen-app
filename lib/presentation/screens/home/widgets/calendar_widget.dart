import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/view_models/home/home_view_model.dart';

class CalendarWidget extends ConsumerWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    // Only watch the selected date
    final selectedDate = ref.watch(
      homeViewModelProvider.select((s) => s.dateToFilterFor),
    );

    var startOfTheWeek = today.subtract(Duration(days: today.weekday - 1));
    var daysToDisplay = <DateTime>[];
    if (today.weekday < 3) {
      // If we did not have Wednesday yet;
      // generate five days starting from Monday
      daysToDisplay = List<DateTime>.generate(
        6,
        (int i) => startOfTheWeek.add(Duration(days: i)),
      );
    } else {
      // Shift start of the week to Wednesday; show rest of the week
      startOfTheWeek = startOfTheWeek.add(const Duration(days: 2));
      daysToDisplay = List<DateTime>.generate(
        6,
        (int i) => startOfTheWeek.add(Duration(days: i)),
      );
    }

    bool isSelected(DateTime date) {
      final selected = selectedDate;
      if (selected == null) return false;
      return date.year == selected.year &&
          date.month == selected.month &&
          date.day == selected.day;
    }

    return Row(
      children: <Widget>[
        ...daysToDisplay.map(
          (DateTime date) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => isSelected(date)
                    ? null
                    : ref.read(homeViewModelProvider.notifier).updateDate(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected(date)
                        ? context.colorScheme.primary
                        : context.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          DateFormat(
                            'EE',
                            'de_DE',
                          ).format(date).replaceAll('.', ''),
                          style: context.textTheme.labelLarge!.copyWith(
                            color: isSelected(date)
                                ? context.colorScheme.onPrimary
                                : context.colorScheme.onTertiary,
                          ),
                        ),
                        Text(
                          date.day.toString(),
                          style: context.textTheme.labelLarge!.copyWith(
                            color: isSelected(date)
                                ? context.colorScheme.onPrimary
                                : context.colorScheme.onTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
