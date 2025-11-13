import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';

part 'active_session_view_model.g.dart';

@riverpod
class ActiveSessionViewModel extends _$ActiveSessionViewModel {
  Timer? _timer;
  late SessionInstanceUseCase _sessionInstanceUseCase;

  late CompleteInstanceUseCase _completeInstanceUseCase;

  @override
  ActiveSessionState build(FullSessionModel fullSession) {
    ref.onDispose(() {
      _timer?.cancel();
    });
    _sessionInstanceUseCase = ref.read(sessionInstanceUseCaseProvider);
    _completeInstanceUseCase = ref.read(completeInstanceUseCaseProvider);
    _initializeSessionInstance();

    return ActiveSessionState(
      fullSession: fullSession,
      remainingSeconds: (fullSession.session.focusTimeMin) * 60,
    );
  }

  Future<void> _initializeSessionInstance() async {
    final DateTime today = DateTime.now();
    final SessionInstanceModel instance;

    // In case we have a non-repeating session; get its one and only instance
    if (!fullSession.session.isRepeating) {
      instance = await _sessionInstanceUseCase.getInstanceBySessionId(
        int.parse(fullSession.session.id!),
      );
    } else {
      instance = await _sessionInstanceUseCase.getInstanceBySessionIdAndDate(
        int.parse(fullSession.session.id!),
        today,
      );
    }
    state = state.copyWith(instanceId: instance.id);
  }

  void setCountUpwards(bool countUpwards) {
    state = state.copyWith(countUpwards: countUpwards);
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
      } else if (state.currentPhase == SessionPhase.shortBreak) {
        state = state.copyWith(
          totalBreakSecondsElapsed: state.totalBreakSecondsElapsed + 1,
        );
      } else {
        state = state.copyWith(
          totalLongBreakSecondsElapsed: state.totalLongBreakSecondsElapsed + 1,
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
        final int focusPhases = session.focusPhases;

        // Determine next break type (if we have 4 % 4 = 0, take long break, else short break)
        if (nextFocusPhase % focusPhases == 0) {
          // Just completed the last focus phase -> moving on to long break
          _startPhase(
            phase: SessionPhase.longBreak,
            durationSeconds: (session.longBreakTimeMin) * 60,
          );
        } else {
          // Completed a regular focus phase
          _startPhase(
            phase: SessionPhase.shortBreak,
            durationSeconds: (session.breakTimeMin) * 60,
          );
        }
        break;

      // After short break, start next focus phase and increase total focus phase
      case SessionPhase.shortBreak:
        final int newTotalFocusPhases = state.totalFocusPhases + 1;
        _startPhase(
          phase: SessionPhase.focus,
          durationSeconds: (session.focusTimeMin) * 60,
          totalFocusPhases: newTotalFocusPhases,
        );
        break;

      // After long break, increment block and start new focus phase
      case SessionPhase.longBreak:
        final int newTotalFocusPhases = state.totalFocusPhases + 1;
        _startPhase(
          phase: SessionPhase.focus,
          durationSeconds: (session.focusTimeMin) * 60,
          totalFocusPhases: newTotalFocusPhases,
          completedBlocks: state.completedBlocks + 1,
        );
        break;
    }
  }

  void _startPhase({
    required SessionPhase phase,
    required int durationSeconds,
    int? totalFocusPhases,
    int? completedBlocks,
  }) {
    state = state.copyWith(
      currentPhase: phase,
      remainingSeconds: durationSeconds,
      totalFocusPhases: totalFocusPhases ?? state.totalFocusPhases,
      completedBlocks: completedBlocks ?? state.completedBlocks,
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
    if (state.timerStatus == TimerStatus.completed) return;
    _timer?.cancel();
    state = state.copyWith(timerStatus: TimerStatus.completed);

    // Save instance tracking data
    await _saveSessionTracking();
  }

  Future<void> _saveSessionTracking() async {
    if (state.sessionStartTime == null) return;

    final SessionInstanceModel sessionInstance = SessionInstanceModel(
      sessionId: state.fullSession.session.id!,
      id: state.instanceId,
      status: SessionStatus.completed,
      scheduledAt: state.scheduledAt ?? DateTime.now(),

      totalCompletedGoals: state.completedGoalIds.length,
      totalCompletedTasks: state.completedTaskIds.length,

      totalBreakSecondsElapsed: state.totalBreakSecondsElapsed,
      totalCompletedBlocks: state.completedBlocks,
      totalFocusPhases: state.totalFocusPhases,
      totalFocusSecondsElapsed: state.totalFocusSecondsElapsed,

      completedAt: DateTime.now(),
    );

    await _completeInstanceUseCase.call(sessionInstance);
  }
}
