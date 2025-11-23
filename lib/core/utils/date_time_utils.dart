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

    int count = 0;
    DateTime current = start;

    // Iterate through each day from start to end (both are inclusive)
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      if (weekdays.contains(current.weekday - 1)) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }

    return count;
  }
}
