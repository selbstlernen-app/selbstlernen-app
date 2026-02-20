import 'dart:ui';
import 'package:srl_app/domain/repositories/settings_repository.dart';

class ManageSettingsUseCase {
  const ManageSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  bool getDarkMode() => _repository.isDarkMode;
  bool getFollowSystem() => _repository.followSystem;
  Color? getPrimaryColor() => _repository.primaryColor;
  bool getTimerStartsAutomatically() => _repository.timerStartsAutomatically;

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

  // Toggles the automatic timer start
  Future<void> toggleTimerStartsAutomatically() async {
    final current = _repository.timerStartsAutomatically;
    await _repository.setTimerStartsAutomatically(value: !current);
  }

  // Toggles the intro screen
  Future<void> toggleIntroScreen() async {
    final current = _repository.playIntro;
    await _repository.setPlayIntro(value: !current);
  }
}
