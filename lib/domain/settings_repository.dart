import 'dart:ui' show Color;

import 'package:srl_app/data/repositories/settings_repository_imp.dart';

abstract class SettingsRepository {
  // CRUD operations
  Future<SettingsData> getSettings();
  Future<void> saveDarkMode({required bool isDarkMode});
  Future<void> savePrimaryColor(int colorValue);
  Stream<SettingsData> watchSettings();
}
