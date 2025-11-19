class TimeUtils {
  // Function to format time to 00:00 (mm:SS)
  static String formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  static String formatBarChartTime(double time) {
    final int seconds = time.floor();
    final int hours = seconds ~/ 60;
    final int minutes = seconds % 60;

    return hours > 0 ? "$hours h" : "$minutes min";
  }
}
