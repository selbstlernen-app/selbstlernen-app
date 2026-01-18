import 'dart:ui' show Color;

abstract class SettingsRepository {
  bool get isDarkMode;
  bool get followSystem;
  Color? get primaryColor;
  bool get timerStartsAutomatically;

  Future<void> setTimerStartsAutomatically({required bool value});
  Future<void> setDarkMode({required bool value});
  Future<void> setFollowSystem({required bool value});
  Future<void> setPrimaryColor(Color colorValue);
  Future<void> clearAll();
}
