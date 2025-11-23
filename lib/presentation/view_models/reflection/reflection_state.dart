import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/core/utils/time_utils.dart';
import 'package:srl_app/domain/models/models.dart';

part "reflection_state.freezed.dart";

@freezed
abstract class ReflectionState with _$ReflectionState {
  const ReflectionState._();

  const factory ReflectionState({
    required SessionInstanceModel instance,
    String? notes,
    int? mood,
  }) = _ReflectionState;

  String get totalTimeFocused =>
      TimeUtils.formatTime(instance.totalFocusSecondsElapsed);

  String get totalTimeInBreak =>
      TimeUtils.formatTime(instance.totalBreakSecondsElapsed);

  String get totalTimeSpent => TimeUtils.formatTime(
    instance.totalBreakSecondsElapsed + instance.totalFocusSecondsElapsed,
  );
}
