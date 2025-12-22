import 'dart:ui';
import 'package:srl_app/domain/settings_repository.dart';

class ManageSettingsUseCase {
  const ManageSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  bool getDarkMode() => _repository.isDarkMode;
  bool getFollowSystem() => _repository.followSystem;
  Color? getPrimaryColor() => _repository.primaryColor;

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    final current = _repository.isDarkMode;

    await _repository.setDarkMode(value: !current);
  }

  // Set follow system
  Future<void> toggleFollowSystem() async {
    final current = _repository.followSystem;
    await _repository.setFollowSystem(value: !current);
  }

  // Change primary color
  Future<void> setPrimaryColor(Color color) async {
    await _repository.setPrimaryColor(color);
  }

  // Clear all settings
  Future<void> clearAllSettings() async {
    await _repository.clearAll();
  }
}
