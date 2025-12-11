class TimeString {
  const TimeString({
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  final String? hours;
  final String minutes;
  final String seconds;
}

class TimeUtils {
  // Function to format time to 00:00 (mm:SS)
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Returns the time split into hours, minutes and seconds
  /// Each as string with 0 padding for singular nums
  static TimeString formatTimeString({
    required int totalSeconds,
    bool zeroPadding = true,
  }) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours == 0 && minutes == 0) {
      return TimeString(
        hours: null,
        minutes: minutes.toString(),
        seconds: seconds.toString(),
      );
    }

    return TimeString(
      hours: zeroPadding
          ? (hours > 0 ? hours.toString().padLeft(2, '0') : null)
          : (hours > 0 ? hours.toString() : null),
      minutes: zeroPadding
          ? minutes.toString().padLeft(2, '0')
          : minutes.toString(),
      seconds: zeroPadding
          ? seconds.toString().padLeft(2, '0')
          : seconds.toString(),
    );
  }

  static String formatBarChartTime(double minutes) {
    if (minutes < 60) {
      if (minutes.toStringAsFixed(1).contains(RegExp('.0'))) {
        return '${minutes.floor()} min';
      }
      return '${minutes.toStringAsFixed(1)} min';
    } else {
      final hours = minutes / 60;

      if (hours.toStringAsFixed(1).contains(RegExp('.0'))) {
        return '${hours.floor()} h';
      }
      return '${hours.toStringAsFixed(1)} h';
    }
  }
}
