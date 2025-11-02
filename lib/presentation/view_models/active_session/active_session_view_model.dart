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

  void _handlePhaseComplete() {
    final SessionModel session = state.fullSession.session;

    switch (state.currentPhase) {
      // If currently in focus add a short/long break
      case SessionPhase.focus:
        final int newTotalFocusPhases = state.totalFocusPhases + 1;
        final int focusPhases = session.focusPhases ?? 4;

        // Determine next break type
        if (newTotalFocusPhases % focusPhases == 0) {
          _startPhase(
            phase: SessionPhase.longBreak,
            durationSeconds: (session.longBreakTimeMin ?? 15) * 60,
            totalFocusPhases: newTotalFocusPhases,
          );
        } else {
          _startPhase(
            phase: SessionPhase.shortBreak,
            durationSeconds: (session.breakTimeMin ?? 5) * 60,
            totalFocusPhases: newTotalFocusPhases,
          );
        }
        break;

      // In case of break, start new focus session
      case SessionPhase.shortBreak:
        _startPhase(
          phase: SessionPhase.focus,
          durationSeconds: (session.focusTimeMin ?? 25) * 60,
        );
      // Only count as new cycle, when long break is over
      case SessionPhase.longBreak:
        _startPhase(
          phase: SessionPhase.focus,
          durationSeconds: (session.focusTimeMin ?? 25) * 60,
          completedCycles: state.completedCycles,
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
