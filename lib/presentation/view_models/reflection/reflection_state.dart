import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/core/utils/time_utils.dart';
import 'package:srl_app/domain/models/models.dart';

part "reflection_state.freezed.dart";

@freezed
abstract class ReflectionState with _$ReflectionState {
  const ReflectionState._();

  const factory ReflectionState({
    required SessionInstanceModel sessionInstance,
    @Default("") String? freeText,
    @Default(3) int? mood,
    @Default(false) bool isLoading,
  }) = _ReflectionState;

  String get totalTimeFocused =>
      TimeUtils.formatTime(sessionInstance.totalFocusSecondsElapsed);

  String get totalTimeInBreak =>
      TimeUtils.formatTime(sessionInstance.totalBreakSecondsElapsed);
}
