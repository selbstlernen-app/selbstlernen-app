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

  static TimeString formatTimeString({required int totalSeconds}) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return TimeString(
      hours: hours > 0 ? hours.toString().padLeft(2, '0') : null,
      minutes: minutes.toString().padLeft(2, '0'),
      seconds: seconds.toString().padLeft(2, '0'),
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

  static String formatToolTipTime(double time) {
    if (time < 60) {
      return '${time.toStringAsFixed(1)} min';
    } else {
      final hours = time / 60;
      return '${hours.toStringAsFixed(1)} h';
    }
  }
}
