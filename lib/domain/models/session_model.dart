import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/core/utils/date_time_utils.dart';

part 'session_model.freezed.dart';

@freezed
abstract class SessionModel with _$SessionModel {
  const SessionModel._();

  const factory SessionModel({
    String? id,
    required String title,
    @Default(false) bool isRepeating,
    DateTime? startDate,
    DateTime? endDate,
    @Default(<int>[]) List<int> selectedDays,
    @Default(<String>[]) List<String> learningStrategies,
    @Default(25) int focusTimeMin,
    @Default(5) int breakTimeMin,
    @Default(15) int longBreakTimeMin,
    @Default(4) int focusPhases,

    @Default(true) bool hasFocusPrompt,
    @Default(15) int focusPromptInterval,
    @Default(false) bool showFocusPromptAlways,

    @Default(true) bool hasFreetextPrompt,

    DateTime? createdAt,

    @Default(0) int completedInstances,
    @Default(false) bool isCompleted,
  }) = _SessionModel;

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
}
