import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool isDarkMode,
    Color? primaryColor,
    @Default(true) bool followSystem,
    @Default(false) bool isLoading,
    String? error,
  }) = _SettingsState;
}
