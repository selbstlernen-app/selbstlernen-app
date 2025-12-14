import 'dart:ui';

import 'package:srl_app/data/database/daos/settings_dao.dart';
import 'package:srl_app/domain/settings_repository.dart';

class SettingsRepositoryImp implements SettingsRepository {
  SettingsRepositoryImp(this._dao);

  final SettingsDao _dao;

  // Get current settings
  @override
  Future<SettingsData> getSettings() async {
    final row = await _dao.getSetting();

    return SettingsData(
      isDarkMode: row.isDarkMode,
      primaryColor: Color(row.primaryColor),
    );
  }

  // Save dark mode
  @override
  Future<void> saveDarkMode({required bool isDarkMode}) async {
    await _dao.saveDarkMode(isDark: isDarkMode);
  }

  // Save primary color
  @override
  Future<void> savePrimaryColor(int color) async {
    await _dao.savePrimaryColor(color);
  }

  // Watch settings changes
  @override
  @override
  Stream<SettingsData> watchSettings() {
    return _dao.watchSettings().map(
      (row) => SettingsData(
        isDarkMode: row.isDarkMode,
        primaryColor: Color(row.primaryColor),
      ),
    );
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
