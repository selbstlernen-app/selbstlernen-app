import 'package:freezed_annotation/freezed_annotation.dart';

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
    @Default(true) bool isPomodoro,
    int? totalTimeMin,
    @Default(25) int? focusTimeMin,
    @Default(5) int? breakTimeMin,
    @Default(15) int? longBreakTimeMin,
    @Default(4) int? focusPhases,
    @Default(true) bool hasFocusPrompt,
    @Default(true) bool hasMoodPrompt,
    @Default(true) bool hasFreetextPrompt,
    DateTime? createdAt,

    // Not saved in db;  computed upfront
    int? totalInstances,
    int? completedInstances,
  }) = _SessionModel;
}
