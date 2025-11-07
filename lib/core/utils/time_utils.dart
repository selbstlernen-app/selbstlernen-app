class TimeUtils {
  // Function to format time to 00:00 (mm:SS)
  static String formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
