class DateTimeUtils {
  static String dateTimeToString({required DateTime date}) {
    return "${date.day}.${date.month}.${date.year}";
  }

  /// Counts the total number of days between given start and end date
  ///  and a list of weekdays
  static int countDaysBetweenDates(
    DateTime start,
    DateTime end,
    List<int> weekdays,
  ) {
    if (end.isBefore(start)) return 0;

    int totalDays = end.difference(start).inDays + 1; // +1 to include end date
    int fullWeeks = totalDays ~/ 7;
    int remainingDays = totalDays % 7;

    // Count occurrences in full weeks
    int count = fullWeeks * weekdays.length;

    // Count occurrences in remaining days
    DateTime current = start.add(Duration(days: fullWeeks * 7));
    for (int i = 0; i < remainingDays; i++) {
      if (weekdays.contains(current.weekday)) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }

    return count;
  }
}
