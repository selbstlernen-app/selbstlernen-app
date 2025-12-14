import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/theme/theme.dart';
import 'package:srl_app/presentation/view_models/settings/settings_view_model.dart';

part 'theme_provider.g.dart';

@riverpod
bool isDarkMode(Ref ref) {
  return ref.watch(settingsViewModelProvider).isDarkMode;
}

@riverpod
Color? primaryColor(Ref ref) {
  return ref.watch(settingsViewModelProvider).primaryColor;
}

@riverpod
ThemeData theme(Ref ref) {
  final isDarkMode = ref.watch(isDarkModeProvider);
  final primaryColor = ref.watch(primaryColorProvider);

  return CustomTheme.getTheme(
    isDark: isDarkMode,
    primaryColor: primaryColor ?? AppPalette.sky,
  );
}
