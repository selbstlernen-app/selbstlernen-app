class DateTimeUtils {
  static String dateTimeToString({required DateTime date}) {
    return "${date.day}.${date.month}.${date.year}";
  }
}
