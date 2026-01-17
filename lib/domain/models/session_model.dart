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
    DateTime? updatedAt,
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

  // Check if the current session is of simple timer kind - or pomodoro like
  bool get hasSimpleTimer => breakTimeMin == 0 && longBreakTimeMin == 0;
}
