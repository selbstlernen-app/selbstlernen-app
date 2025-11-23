class TimeUtils {
  // Function to format time to 00:00 (mm:SS)
  static String formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  static String formatBarChartTime(double minutes) {
    if (minutes < 60) {
      if (minutes.toStringAsFixed(1).contains(RegExp(".0"))) {
        return "${minutes.floor()} min";
      }
      return "${minutes.toStringAsFixed(1)} min";
    } else {
      final double hours = minutes / 60;

      if (hours.toStringAsFixed(1).contains(RegExp(".0"))) {
        return "${hours.floor()} h";
      }
      return "${hours.toStringAsFixed(1)} h";
    }
  }

  static String formatToolTipTime(double time) {
    if (time < 60) {
      return "${time.toStringAsFixed(1)} min";
    } else {
      final double hours = time / 60;
      return "${hours.toStringAsFixed(1)} h";
    }
  }
}
