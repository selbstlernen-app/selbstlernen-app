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
