import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    required bool isDarkMode,
    required bool followSystem,
    required Color primaryColor,
    bool? hasNotificationPermission,
  }) = _SettingsState;
}
