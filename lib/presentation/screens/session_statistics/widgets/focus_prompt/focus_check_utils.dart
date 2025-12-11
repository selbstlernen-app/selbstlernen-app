import 'package:flutter/material.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/domain/models/focus_check.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

// Helper class for focus check calculation
class FocusCheckWithMinutes {
  FocusCheckWithMinutes(this.check, this.minutesIntoSession);

  // The given focus check
  final FocusCheck check;

  // Elapsed seconds into minutes
  final int minutesIntoSession;
}

/// Converts the focus check points to chart data by
/// converting the elapsed focus seconds to minutes
List<FocusCheckWithMinutes> prepareFocusCheckData(
  SessionInstanceModel instance,
) {
  if (instance.focusChecks.isEmpty) return [];

  return instance.focusChecks
      .map(
        (check) => FocusCheckWithMinutes(
          check,
          check.atElapsedSeconds ~/ 60,
        ),
      )
      .toList()
    ..sort((a, b) => a.minutesIntoSession.compareTo(b.minutesIntoSession));
}

/// Returns a numeric value for the different focus levels
double focusLevelToValue(FocusLevel level) {
  switch (level) {
    case FocusLevel.good:
      return 3;
    case FocusLevel.okay:
      return 2;
    case FocusLevel.distracted:
      return 1;
  }
}

// Returns a rounded focus level for average values
FocusLevel valueToFocusLevel(double value) {
  if (value <= 1.0) return FocusLevel.distracted;
  if (value <= 2.0) return FocusLevel.okay;
  return FocusLevel.good;
}

/// Calculates the average focus level of the instance
double calculateSessionAverageFocus(SessionInstanceModel instance) {
  if (instance.focusChecks.isEmpty) return 0;

  final totalValue = instance.focusChecks.fold<double>(
    0,
    (sum, check) => sum + focusLevelToValue(check.level),
  );

  return totalValue / instance.focusChecks.length;
}

/// Calculates the overall average focus level over all
/// past session instances
double calculateOverallAverageFocus(List<SessionInstanceModel> instances) {
  final validInstances = instances
      .where((instance) => instance.focusChecks.isNotEmpty)
      .toList();

  final totalValue = validInstances.fold<double>(
    0,
    (sum, instance) => sum + calculateSessionAverageFocus(instance),
  );

  return totalValue / validInstances.length;
}

/// Returns the color for the focus level
Color getFocusColor(FocusLevel level) {
  switch (level) {
    case FocusLevel.good:
      return AppPalette.emerald;
    case FocusLevel.okay:
      return AppPalette.yellow;
    case FocusLevel.distracted:
      return AppPalette.rose;
  }
}

/// Returns the label for the focus level
String getFocusLabel(FocusLevel level) {
  switch (level) {
    case FocusLevel.good:
      return 'Gut fokussiert';
    case FocusLevel.okay:
      return 'Mittelmäßig';
    case FocusLevel.distracted:
      return 'Abgelenkt';
  }
}
