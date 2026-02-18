import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:srl_app/domain/repositories/settings_repository.dart';

class SettingsRepositoryImp implements SettingsRepository {
  SettingsRepositoryImp(this._prefs);

  final SharedPreferences _prefs;
  static const _darkModeKey = 'dark_mode';
  static const _followSystemKey = 'follow_system';
  static const _primaryColorKey = 'primary_color';
  static const _timerStartsAutomaticallyKey = 'timer_starts_automatically';

  static const _timerEndKey = 'time_stamp';

  // Getters
  @override
  bool get isDarkMode => _prefs.getBool(_darkModeKey) ?? false;

  @override
  bool get followSystem => _prefs.getBool(_followSystemKey) ?? true;

  @override
  Color? get primaryColor {
    final colorValue = _prefs.getInt(_primaryColorKey);
    return colorValue != null ? Color(colorValue) : null;
  }

  @override
  bool get timerStartsAutomatically =>
      _prefs.getBool(_timerStartsAutomaticallyKey) ?? true;

  @override
  DateTime? get timeStamp {
    final iso = _prefs.getString(_timerEndKey);
    return iso != null ? DateTime.tryParse(iso) : null;
  }

  // Setters
  @override
  Future<void> setDarkMode({required bool value}) async {
    await _prefs.setBool(_darkModeKey, value);
  }

  @override
  Future<void> setFollowSystem({required bool value}) async {
    await _prefs.setBool(_followSystemKey, value);
  }

  @override
  Future<void> setPrimaryColor(Color? color) async {
    if (color != null) {
      await _prefs.setInt(_primaryColorKey, color.toARGB32());
    } else {
      await _prefs.remove(_primaryColorKey);
    }
  }

  @override
  Future<void> setTimerStartsAutomatically({required bool value}) async {
    await _prefs.setBool(_timerStartsAutomaticallyKey, value);
  }

  @override
  Future<void> setTimeStamp(DateTime? timestamp) async {
    if (timestamp == null) {
      await _prefs.remove(_timerEndKey);
    } else {
      await _prefs.setString(_timerEndKey, timestamp.toIso8601String());
    }
  }
}
