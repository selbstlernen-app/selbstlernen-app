import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/full_session_model.dart';

part 'active_session_state.freezed.dart';

enum SessionPhase { focus, shortBreak, longBreak }

enum TimerStatus { initial, running, paused, completed }

@freezed
abstract class ActiveSessionState with _$ActiveSessionState {
  const factory ActiveSessionState({
    required FullSessionModel fullSession,
    @Default(SessionPhase.focus) SessionPhase currentPhase,
    @Default(TimerStatus.initial) TimerStatus timerStatus,
    @Default(0) int remainingSeconds,
    @Default(0) int totalFocusSecondsElapsed,
    @Default(0) int totalBreakSecondsElapsed,

    @Default(0) int totalFocusPhases,
    @Default(0) int completedCycles,
    DateTime? sessionStartTime,
  }) = _ActiveSessionState;
}
