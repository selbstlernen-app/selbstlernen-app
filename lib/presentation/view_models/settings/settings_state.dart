import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
import 'package:srl_app/domain/models/notification_type_setting.dart';
import 'package:srl_app/domain/models/session_model.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    required bool isDarkMode,
    required bool followSystem,
    required Color primaryColor,
    required bool timerStartsAutomatically,

    List<NotificationTypeSetting>? notificationSettings,
    bool? hasNotificationPermission,

    List<LearningStrategyModel>? learningStrategies,

    List<SessionModel>? activeSessions,

    String? error,
    @Default(true) bool isLoading,
  }) = _SettingsState;
}
