import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/domain/models/notification_type_setting.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/manage_notifications_use_case.dart';
import 'package:srl_app/domain/usecases/manage_settings_use_case.dart';
import 'package:srl_app/notification_service.dart';
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

    unawaited(checkPermission());

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

  // Notification Settings
  Future<void> checkPermission() async {
    if (!ref.mounted) return;

    final hasPermission = await Permission.notification.isGranted;

    if (!hasPermission) {
      await _clearAllNotifications();
    }

    state = state.copyWith(hasNotificationPermission: hasPermission);
  }

  Future<void> _clearAllNotifications() async {
    // Cancel all (pending) notifications
    await NotificationService().cancelAllNotifications();

    // Disable all notifications (visually -> since permissions already turned off anyway)
    final disabledSettings = state.notificationSettings
        ?.map(
          (n) => n.copyWith(enabled: false),
        )
        .toList();

    if (disabledSettings != null) {
      for (final setting in disabledSettings) {
        await _manageNotificationsUseCase.updatePreference(
          setting.type,
          setting,
        );
      }
    }
  }

  Future<void> toggleNotificationSetting({
    required NotificationType type,
    required bool isEnabled,
  }) async {
    await _manageNotificationsUseCase.toggleNotificationType(
      type: type,
      isEnabled: isEnabled,
    );

    // Schedule notification if toggled
    final updatedSetting = state.notificationSettings?.firstWhere(
      (s) => s.type == type,
    );
    // Update the setting so notification is sent
    if (updatedSetting != null) {
      final settingToSchedule = updatedSetting.copyWith(enabled: isEnabled);
      await _scheduleNotification(settingToSchedule);
    }
  }

  Future<void> updateNotification(
    NotificationType type,
    NotificationTypeSetting settings,
  ) async {
    await _manageNotificationsUseCase.updatePreference(type, settings);

    // After update, check and adapt scheduling
    await _scheduleNotification(settings);
  }

  // Schedule notifications
  Future<void> _scheduleNotification(NotificationTypeSetting setting) async {
    if (!setting.enabled) {
      // Cancel any notification types if disabled
      await NotificationService().cancelNotificationsForType(setting.type);
      return;
    }

    await NotificationService().scheduleNotification(
      type: setting.type,
      frequency: setting.frequency,
      preferredTime: setting.preferredTime,
      customMessage: setting.customMessage,
    );
  }
}
