import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/usecases/create_session_instance_use_case.dart';
import 'package:srl_app/domain/usecases/edit_session_instance_use_case.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';

part 'active_session_view_model.g.dart';

@riverpod
class ActiveSessionViewModel extends _$ActiveSessionViewModel {
  Timer? _timer;
  late CreateSessionInstanceUseCase _createSessionInstanceUseCase;
  late EditSessionInstanceUseCase _editSessionInstanceUseCase;

  @override
  ActiveSessionState build(FullSessionModel fullSession) {
    ref.onDispose(() {
      _timer?.cancel();
    });
    _createSessionInstanceUseCase = ref.read(
      createSessionInstanceUseCaseProvider,
    );
    _editSessionInstanceUseCase = ref.read(editSessionInstanceUseCaseProvider);

    return ActiveSessionState(
      fullSession: fullSession,
      remainingSeconds: (fullSession.session.focusTimeMin) * 60,
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
    _timer?.cancel();
    state = state.copyWith(timerStatus: TimerStatus.completed);

    // Save session tracking data
    await _saveSessionTracking();
  }

  Future<void> initializeSession() async {
    final SessionInstanceModel sessionInstance = SessionInstanceModel(
      sessionId: state.fullSession.session.id!,
      status: SessionStatus.inProgress,
      createdAt: DateTime.now(),
    );

    final int instanceId = await _createSessionInstanceUseCase
        .createSessionInstance(sessionInstance);

    state = state.copyWith(instanceId: instanceId.toString());
  }

  Future<void> _saveSessionTracking() async {
    if (state.sessionStartTime == null) return;

    final SessionInstanceModel sessionInstance = SessionInstanceModel(
      sessionId: state.fullSession.session.id!,
      status: SessionStatus.completed,

      totalCompletedGoals: state.completedGoalIds.length,
      totalCompletedTasks: state.completedTaskIds.length,

      totalBreakSecondsElapsed: state.totalBreakSecondsElapsed,
      totalCompletedBlocks: state.completedBlocks,
      totalFocusPhases: state.totalFocusPhases,
      totalFocusSecondsElapsed: state.totalFocusSecondsElapsed,

      completedAt: DateTime.now(),
    );

    await _editSessionInstanceUseCase.editSessionInstance(
      int.parse(state.instanceId!),
      sessionInstance,
    );
  }
}
