import 'dart:ui';

import 'package:srl_app/data/database/daos/settings_dao.dart';
import 'package:srl_app/domain/settings_repository.dart';

class SettingsRepositoryImp implements SettingsRepository {
  SettingsRepositoryImp(this._dao);

  final SettingsDao _dao;

  // Get current settings
  @override
  Future<SettingsData> getSettings() async {
    final isDarkMode = await _dao.getDarkMode();
    final colorValue = await _dao.getPrimaryColor();
    return SettingsData(
      isDarkMode: isDarkMode,
      primaryColor: Color(colorValue),
    );
  }

  // Save dark mode
  @override
  Future<void> saveDarkMode({required bool isDarkMode}) async {
    await _dao.setDarkMode(isDark: isDarkMode);
  }

  // Save primary color
  @override
  Future<void> savePrimaryColor(int color) async {
    await _dao.setPrimaryColor(color);
  }

  // Watch settings changes
  @override
  Stream<SettingsData> watchSettings() async* {
    await for (final isDarkMode in _dao.watchDarkMode()) {
      final colorValue = await _dao.getPrimaryColor();
      yield SettingsData(
        isDarkMode: isDarkMode,
        primaryColor: Color(colorValue),
      );
    }
  }
}

// Helper class to get data in readable form
class SettingsData {
  SettingsData({
    required this.isDarkMode,
    required this.primaryColor,
  });

  final bool isDarkMode;
  final Color primaryColor;
}
