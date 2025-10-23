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
    int? focusTimeMin,
    int? breakTimeMin,
    int? longBreakTimeMin,
    int? cyclesBeforeLongBreak,
    @Default(true) bool hasFocusPrompt,
    @Default(true) bool hasMoodPrompt,
    @Default(true) bool hasFreetextPrompt,
    DateTime? createdAt,
  }) = _SessionModel;
}
