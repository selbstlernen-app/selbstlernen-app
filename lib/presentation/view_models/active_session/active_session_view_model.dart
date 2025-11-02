import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';

part 'active_session_view_model.g.dart';

@riverpod
class ActiveSessionViewModel extends _$ActiveSessionViewModel {
  Timer? _timer;

  @override
  ActiveSessionState build(FullSessionModel fullSession) {
    ref.onDispose(() {
      _timer?.cancel();
    });

    return ActiveSessionState(
      fullSession: fullSession,
      remainingSeconds: (fullSession.session.focusTimeMin ?? 25) * 60,
    );
  }

  void startTimer() {
    if (state.timerStatus == TimerStatus.initial) {
      state = state.copyWith(
        sessionStartTime: DateTime.now(),
        timerStatus: TimerStatus.running,
      );
    } else if (state.timerStatus == TimerStatus.paused) {
      state = state.copyWith(timerStatus: TimerStatus.running);
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(timerStatus: TimerStatus.paused);
  }

  void _tick() {
    if (state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);

      // Track elapsed time based on phase
      if (state.currentPhase == SessionPhase.focus) {
        state = state.copyWith(
          totalFocusSecondsElapsed: state.totalFocusSecondsElapsed + 1,
        );
      } else {
        state = state.copyWith(
          totalBreakSecondsElapsed: state.totalBreakSecondsElapsed + 1,
        );
      }
    } else {
      _handlePhaseComplete();
    }
  }

  void skipPhase() {
    _handlePhaseComplete();
  }

  // Function to switch phase dependent on the current one (focus -> short/long break)
  void _handlePhaseComplete() {
    final SessionModel session = state.fullSession.session;

    switch (state.currentPhase) {
      case SessionPhase.focus:
        // say we have 4 focus phases, then 3 are FK last is FL
        final int nextFocusPhase = state.totalFocusPhases + 1;
        final int focusPhases = session.focusPhases ?? 4;

        // Determine next break type (if we have 4 % 4 = 0, take long break, else short break)
        if (nextFocusPhase % focusPhases == 0) {
          // Just completed the last focus phase -> moving on to long break
          _startPhase(
            phase: SessionPhase.longBreak,
            durationSeconds: (session.longBreakTimeMin ?? 15) * 60,
          );
        } else {
          // Completed a regular focus phase
          _startPhase(
            phase: SessionPhase.shortBreak,
            durationSeconds: (session.breakTimeMin ?? 5) * 60,
          );
        }
        break;

      // After short break, start next focus phase and increase total focus phase
      case SessionPhase.shortBreak:
        final int newTotalFocusPhases = state.totalFocusPhases + 1;
        _startPhase(
          phase: SessionPhase.focus,
          durationSeconds: (session.focusTimeMin ?? 25) * 60,
          totalFocusPhases: newTotalFocusPhases,
        );
        break;

      // After long break, increment cycle and start new focus phase
      case SessionPhase.longBreak:
        final int newTotalFocusPhases = state.totalFocusPhases + 1;
        _startPhase(
          phase: SessionPhase.focus,
          durationSeconds: (session.focusTimeMin ?? 25) * 60,
          totalFocusPhases: newTotalFocusPhases,
          completedCycles: state.completedCycles + 1,
        );
        break;
    }
  }

  void _startPhase({
    required SessionPhase phase,
    required int durationSeconds,
    int? totalFocusPhases,
    int? completedCycles,
  }) {
    state = state.copyWith(
      currentPhase: phase,
      remainingSeconds: durationSeconds,
      totalFocusPhases: totalFocusPhases ?? state.totalFocusPhases,
      completedCycles: completedCycles ?? state.completedCycles,
    );
  }

  // Complete a goal
  void toggleGoalCompletion(String goalId) {
    final Set<String> completed = Set<String>.from(state.completedGoalIds);
    if (completed.contains(goalId)) {
      completed.remove(goalId);
    } else {
      completed.add(goalId);
    }
    state = state.copyWith(completedGoalIds: completed);
  }

  // Complete a task
  void toggleTaskCompletion(String taskId) {
    final Set<String> completed = Set<String>.from(state.completedTaskIds);
    if (completed.contains(taskId)) {
      completed.remove(taskId);
    } else {
      completed.add(taskId);
    }
    state = state.copyWith(completedTaskIds: completed);
  }

  Future<void> stopSession() async {
    _timer?.cancel();
    state = state.copyWith(timerStatus: TimerStatus.completed);

    // Save session tracking data
    await _saveSessionTracking();
  }

  Future<void> _saveSessionTracking() async {
    if (state.sessionStartTime == null) return;

    // TODO: Add a tracking model to database - including all information from the state (look up whats relevant)

    // TODO: Create and then save to corresponding repository, e.g.:
    // await ref.read(sessionTrackingRepositoryProvider).insert(tracking);
  }
}
