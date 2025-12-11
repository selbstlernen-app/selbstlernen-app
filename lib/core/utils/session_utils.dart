import 'package:intl/intl.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

/// Generates an iterable list of all dates on which a repeating
/// session should take place
Iterable<DateTime> generateScheduledDates(
  DateTime start,
  List<int> selectedWeekdays,
) sync* {
  final today = DateTime.now();
  final normalizedEnd = DateTime(today.year, today.month, today.day);

  var current = DateTime(start.year, start.month, start.day);

  while (!current.isAfter(normalizedEnd)) {
    if (selectedWeekdays.contains(current.weekday - 1)) {
      yield current;
    }
    current = current.add(const Duration(days: 1));
  }
}

/// Returns a map with the amount of instances occuring on a given date
Map<String, int> calculateDateOccurences(List<SessionInstanceModel> instances) {
  final map = <String, int>{};
  for (final instance in instances) {
    final key = DateFormat('yyyyMMdd').format(instance.completedAt!);
    map[key] = (map[key] ?? 0) + 1;
  }
  return map;
}
