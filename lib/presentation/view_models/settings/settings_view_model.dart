import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/manage_settings_use_case.dart';
import 'package:srl_app/presentation/view_models/settings/settings_state.dart';

part 'settings_view_model.g.dart';

@riverpod
class SettingsViewModel extends _$SettingsViewModel {
  late final ManageSettingsUseCase _manageSettingsUseCase;

  @override
  SettingsState build() {
    _manageSettingsUseCase = ref.watch(
      manageSettingsUseCaseProvider,
    );
    unawaited(_loadData());
    return const SettingsState();
  }

  Future<void> _loadData() async {
    try {
      final data = await _manageSettingsUseCase.getSettings();

      state = state.copyWith(
        isDarkMode: data.isDarkMode,
        primaryColor: data.primaryColor,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> toggleDarkMode({required bool darkMode}) async {
    state = state.copyWith(isLoading: true);

    try {
      await _manageSettingsUseCase.saveDarkMode(isDarkMode: darkMode);
      state = state.copyWith(
        isDarkMode: darkMode,
        isLoading: false,
        error: null,
      );
    } on Exception catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Fehler beim Speichern des Modus',
      );
    }
  }

  // Change primary color
  Future<void> changePrimaryColor(Color color) async {
    state = state.copyWith(isLoading: true);

    try {
      await _manageSettingsUseCase.savePrimaryColor(color);
      state = state.copyWith(
        primaryColor: color,
        isLoading: false,
        error: null,
      );
    } on Exception catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Fehler beim Speichern der Farbe',
      );
    }
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    state = state.copyWith(isLoading: true);

    try {
      await _manageSettingsUseCase.resetDefault();

      state = const SettingsState();
    } on Exception catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Fehler beim Zurücksetzen',
      );
    }
  }
}
