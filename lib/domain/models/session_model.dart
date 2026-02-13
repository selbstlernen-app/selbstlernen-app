import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/core/utils/date_time_utils.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';

part 'session_model.freezed.dart';

@freezed
abstract class SessionModel with _$SessionModel {
  const factory SessionModel({
    required String title,
    String? id,
    @Default(false) bool isRepeating,

    @Default(SessionComplexity.simple) SessionComplexity complexity,

    DateTime? startDate,
    DateTime? endDate,
    @Default(<int>[]) List<int> selectedDays, // 0 = Monday, 6 = Sunday

    @Default(TimeOfDay(hour: 10, minute: 0)) TimeOfDay plannedTime,
    @Default(false) bool hasNotification,

    @Default(<int>[]) List<int> learningStrategyIds,

    @Default(25) int focusTimeMin,
    @Default(5) int breakTimeMin,
    @Default(4) int pomodoroPhases,

    @Default(true) bool hasFocusPrompt,
    @Default(15) int focusPromptInterval,
    @Default(false) bool showFocusPromptAlways,

    @Default(false) bool isArchived,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SessionModel;
  const SessionModel._();

  // -- Getters --
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

  bool get isSimple => complexity == SessionComplexity.simple;

  // -- Helpers --
  SessionPhase phaseFromIndex(int index) {
    if (index.isEven) {
      return SessionPhase.focus;
    }
    // Odd index means short break
    return SessionPhase.shortBreak;
  }

  int getDefaultDuration(SessionPhase phase) {
    switch (phase) {
      case SessionPhase.focus:
        return focusTimeMin * 60;
      case SessionPhase.shortBreak:
        return breakTimeMin * 60;
    }
  }
}
