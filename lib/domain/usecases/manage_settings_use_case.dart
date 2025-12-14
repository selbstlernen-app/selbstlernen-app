import 'dart:ui';

import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/data/repositories/settings_repository_imp.dart';
import 'package:srl_app/domain/settings_repository.dart';

class ManageSettingsUseCase {
  const ManageSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<SettingsData> getSettings() async {
    return _repository.getSettings();
  }

  // Toggle dark mode
  Future<void> saveDarkMode({required bool isDarkMode}) async {
    await _repository.saveDarkMode(isDarkMode: isDarkMode);
  }

  // Change primary color
  Future<void> savePrimaryColor(Color color) async {
    final colorValue = color.toARGB32();
    await _repository.savePrimaryColor(colorValue);
  }

  // Reset to defaults
  Future<void> resetDefault() async {
    await _repository.saveDarkMode(isDarkMode: false);
    await _repository.savePrimaryColor(AppPalette.sky.toARGB32());
  }
}
