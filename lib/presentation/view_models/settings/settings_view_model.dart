import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/core/theme/app_palette.dart';
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

    unawaited(_checkPermission());

    return SettingsState(
      isDarkMode: _manageSettingsUseCase.getDarkMode(),
      followSystem: _manageSettingsUseCase.getFollowSystem(),
      primaryColor: _manageSettingsUseCase.getPrimaryColor() ?? AppPalette.sky,
    );
  }

  Future<void> _checkPermission() async {
    final hasPermission = await Permission.notification.isGranted;

    state = state.copyWith(hasNotificationPermission: hasPermission);
  }

  Future<void> toggleDarkMode() async {
    await _manageSettingsUseCase.toggleDarkMode();
    state = state.copyWith(isDarkMode: _manageSettingsUseCase.getDarkMode());
  }

  Future<void> toggleFollowSystem() async {
    await _manageSettingsUseCase.toggleFollowSystem();
    state = state.copyWith(
      followSystem: _manageSettingsUseCase.getFollowSystem(),
    );
  }

  Future<void> setPrimaryColor(Color color) async {
    await _manageSettingsUseCase.setPrimaryColor(color);
    state = state.copyWith(primaryColor: color);
  }

  Future<void> clearAllSettings() async {
    await _manageSettingsUseCase.clearAllSettings();
    // Reload state from repository
    state = SettingsState(
      isDarkMode: _manageSettingsUseCase.getDarkMode(),
      followSystem: _manageSettingsUseCase.getFollowSystem(),
      primaryColor: _manageSettingsUseCase.getPrimaryColor() ?? AppPalette.sky,
    );
  }
}
