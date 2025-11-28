import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/core/utils/date_time_utils.dart';

part 'session_model.freezed.dart';

@freezed
abstract class SessionModel with _$SessionModel {
  const factory SessionModel({
    required String title,
    String? id,
    @Default(false) bool isRepeating,
    DateTime? startDate,
    DateTime? endDate,
    @Default(<int>[]) List<int> selectedDays, // 0 = Monday, 6 = Sunday
    @Default(<String>[]) List<String> learningStrategies,
    @Default(25) int focusTimeMin,
    @Default(5) int breakTimeMin,
    @Default(15) int longBreakTimeMin,
    @Default(4) int focusPhases,

    @Default(true) bool hasFocusPrompt,
    @Default(15) int focusPromptInterval,
    @Default(false) bool showFocusPromptAlways,

    @Default(true) bool hasFreetextPrompt,

    @Default(false) bool isArchived,

    DateTime? createdAt,
  }) = _SessionModel;
  const SessionModel._();

  // Helper
  int get totalInstances {
    if (!isRepeating) {
      return 1;
    }
    return DateTimeUtils.countDaysBetweenDates(
      startDate!,
      endDate!,
      selectedDays,
    );
  }

  int get totalTimeForOneBlock {
    return (focusTimeMin + breakTimeMin) * focusPhases + longBreakTimeMin;
  }
}

extension SessionExtensions on SessionModel {
  /// Function to determine if a session is scheduled for today or not
  /// @returns true if its not repeating, and false if not scheduled for the day
  bool isScheduledForDate(DateTime date) {
    if (isArchived) return false;

    // One-time session: always shown
    if (!isRepeating) {
      return true;
    }

    final start = startDate ?? date;
    final end = endDate ?? date;

    if (date.isBefore(start) || date.isAfter(end)) return false;

    if (selectedDays.isEmpty) return false;
    // Since weekdays are from 1 to 7 -> We have 0 to 6
    return selectedDays.contains(date.weekday - 1);
  }
}
