import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';

class CalendarWidget extends ConsumerWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime today = DateTime.now();

    DateTime startOfTheWeek = today.subtract(Duration(days: today.weekday - 1));
    List<DateTime> daysToDisplay = <DateTime>[];
    if (today.weekday < 3) {
      // If we did not have Wednesday yet; generate five days starting from Monday
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

    return Row(
      children: <Widget>[
        ...daysToDisplay.map(
          (DateTime date) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: date.day == today.day
                      ? context.colorScheme.primary
                      : context.colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        DateFormat(
                          'EE',
                          'de_DE',
                        ).format(date).replaceAll('.', ''),
                        style: context.textTheme.labelLarge!.copyWith(
                          color: date.day == today.day
                              ? context.colorScheme.onPrimary
                              : context.colorScheme.onTertiary,
                        ),
                      ),
                      Text(
                        date.day.toString(),
                        style: context.textTheme.labelLarge!.copyWith(
                          color: date.day == today.day
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
      ],
    );
  }
}
