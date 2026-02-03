import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/core/services/notification_service.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
import 'package:srl_app/domain/models/notification_type_setting.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/manage_settings_use_case.dart';
import 'package:srl_app/presentation/view_models/providers.dart';
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

    _listenToDataStreams();

    unawaited(checkPermission());

    return SettingsState(
      isDarkMode: _manageSettingsUseCase.getDarkMode(),
      followSystem: _manageSettingsUseCase.getFollowSystem(),
      primaryColor: _manageSettingsUseCase.getPrimaryColor() ?? AppPalette.sky,
      timerStartsAutomatically: _manageSettingsUseCase
          .getTimerStartsAutomatically(),
    );
  }

  void _listenToDataStreams() {
    ref
      ..listen(
        learningStrategiesStreamProvider,
        (previous, next) {
          next.whenData((strategies) {
            state = state.copyWith(
              learningStrategies: strategies,
              isLoading: false,
            );
          });
        },
      )
      ..listen(notificationSettingsStreamProvider, (previous, next) {
        next.whenData((notifications) {
          state = state.copyWith(
            notificationSettings: notifications,
            isLoading: false,
          );
        });
      });
  }

  Future<void> addStrategy(String title, String? explanation) async {
    await ref
        .read(manageLearningStrategyUseCaseProvider)
        .addLearningStrategy(
          LearningStrategyModel(title: title, explanation: explanation),
        );
  }

  Future<void> deleteStrategy(int id) async {
    await ref
        .read(manageLearningStrategyUseCaseProvider)
        .deleteLearningStrategy(id);
  }

  Future<void> updateStrategy(LearningStrategyModel model, int id) async {
    await ref
        .read(manageLearningStrategyUseCaseProvider)
        .updateLearningStrategy(model, id);
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

  Future<void> toggleTimerAutomaticallyStarted() async {
    await _manageSettingsUseCase.toggleTimerStartsAutomatically();
    state = state.copyWith(
      timerStartsAutomatically: _manageSettingsUseCase
          .getTimerStartsAutomatically(),
    );
  }

  Future<void> setPrimaryColor(Color color) async {
    await _manageSettingsUseCase.setPrimaryColor(color);
    state = state.copyWith(primaryColor: color);
  }

  // Notification Settings
  Future<void> checkPermission() async {
    final hasPermission = await Permission.notification.isGranted;
    if (!ref.mounted) return;

    if (!hasPermission) {
      await _clearAllNotifications();
    }

    if (!ref.mounted) return;

    state = state.copyWith(hasNotificationPermission: hasPermission);
  }

  Future<void> _clearAllNotifications() async {
    // Cancel all (pending) notifications
    await NotificationService().cancelAllNotifications();

    // Disable all notifications
    // (visually -> since permissions already turned off anyway)
    final disabledSettings = state.notificationSettings
        ?.map(
          (n) => n.copyWith(enabled: false),
        )
        .toList();

    if (disabledSettings != null) {
      for (final setting in disabledSettings) {
        await ref
            .read(manageNotificationsUseCaseProvider)
            .updatePreference(
              setting.type,
              setting,
            );
      }
    }
  }

  Future<void> toggleNotificationSetting({
    required NotificationTypeSetting setting,
    required NotificationType type,
    required bool isEnabled,
  }) async {
    await ref
        .read(manageNotificationsUseCaseProvider)
        .toggleNotificationType(
          setting: setting,
          type: type,
          isEnabled: isEnabled,
        );

    // Schedule notification if toggled
    final updatedSetting = state.notificationSettings?.firstWhereOrNull(
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
    await ref
        .read(manageNotificationsUseCaseProvider)
        .updatePreference(type, settings);

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
