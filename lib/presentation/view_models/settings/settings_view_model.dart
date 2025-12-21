import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/domain/models/notification_type_setting.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/manage_notifications_use_case.dart';
import 'package:srl_app/domain/usecases/manage_settings_use_case.dart';
import 'package:srl_app/presentation/view_models/settings/settings_state.dart';

part 'settings_view_model.g.dart';

@riverpod
class SettingsViewModel extends _$SettingsViewModel {
  late final ManageSettingsUseCase _manageSettingsUseCase;
  late final ManageNotificationsUseCase _manageNotificationsUseCase;

  StreamSubscription<dynamic>? _notificationSubscription;

  @override
  SettingsState build() {
    _manageSettingsUseCase = ref.watch(
      manageSettingsUseCaseProvider,
    );
    _manageNotificationsUseCase = ref.watch(manageNotificationsUseCaseProvider);

    ref.onDispose(() {
      unawaited(_notificationSubscription?.cancel());
    });

    unawaited(_checkPermission());

    _subscribe();

    return SettingsState(
      isDarkMode: _manageSettingsUseCase.getDarkMode(),
      followSystem: _manageSettingsUseCase.getFollowSystem(),
      primaryColor: _manageSettingsUseCase.getPrimaryColor() ?? AppPalette.sky,
    );
  }

  void _subscribe() {
    _notificationSubscription = _manageNotificationsUseCase
        .watchPreferences()
        .listen(
          (List<NotificationTypeSetting> notifications) {
            state = state.copyWith(
              notificationSettings: notifications,
              isLoading: false,
            );
          },
          onError: (dynamic error) {
            state = state.copyWith(error: error.toString(), isLoading: false);
          },
        );
  }

  // UI/Theming Settings
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

  // Notification Settings
  Future<void> toggleNotificationSetting({
    required NotificationType type,
    required bool isEnabled,
  }) async {
    await _manageNotificationsUseCase.toggleNotificationType(
      type: type,
      isEnabled: isEnabled,
    );
  }

  Future<void> updateNotification(
    NotificationType type,
    NotificationTypeSetting settings,
  ) async {
    await _manageNotificationsUseCase.updatePreference(type, settings);
  }
}
