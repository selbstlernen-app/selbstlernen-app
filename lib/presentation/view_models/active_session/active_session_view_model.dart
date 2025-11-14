import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';

part 'active_session_view_model.g.dart';

@riverpod
class ActiveSessionViewModel extends _$ActiveSessionViewModel {
  late final FullSessionUseCase _fullSessionUseCase;
  late final UpdateInstanceUseCase _updateInstanceUseCase;
  late final GetInstanceUseCase _getInstanceUseCase;
  late final CompleteInstanceUseCase _completeInstanceUseCase;
  late final int _instanceId;
  late StreamSubscription<dynamic>? _sessionSubscription;

  Timer? _timer;

  @override
  ActiveSessionState build(int instanceId) {
    _instanceId = instanceId;
    _fullSessionUseCase = ref.watch(fullSessionUseCaseProvider);
    _updateInstanceUseCase = ref.watch(updateInstanceUseCaseProvider);
    _completeInstanceUseCase = ref.watch(completeInstanceUseCaseProvider);
    _getInstanceUseCase = ref.watch(getInstanceUseCaseProvider);

    _loadData();

    ref.onDispose(() {
      _timer?.cancel();
      _sessionSubscription?.cancel();
    });

    return const ActiveSessionState(isLoading: true);
  }

  Future<void> _loadData() async {
    try {
      // Load the instance (created either in detail screen or formula)
      final SessionInstanceModel instance = await _getInstanceUseCase
          .getInstanceById(_instanceId);

      final int sessionId = int.parse(instance.sessionId);

      // Watch the full session (in case user adds goals/tasks)
      _sessionSubscription = _fullSessionUseCase
          .watchFullSession(sessionId)
          .listen((FullSessionModel fullSession) {
            state = state.copyWith(
              fullSession: fullSession,
              instance: instance,
              totalFocusSecondsElapsed: instance.totalFocusSecondsElapsed,
              totalBreakSecondsElapsed: instance.totalBreakSecondsElapsed,
              totalFocusPhases: instance.totalFocusPhases,
              completedBlocks: instance.totalCompletedBlocks,
              remainingSeconds: fullSession.session.focusTimeMin * 60,
              isLoading: false,
            );
          });
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
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
    _autoSave();
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
    final SessionModel session = state.fullSession!.session;

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

    _autoSave();
  }

  // Complete a goal
  Future<void> toggleGoalCompletion(String goalId) async {
    final Set<String> completed = Set<String>.from(state.completedGoalIds);
    if (completed.contains(goalId)) {
      completed.remove(goalId);
    } else {
      completed.add(goalId);
    }
    state = state.copyWith(completedGoalIds: completed);

    await _autoSave();
  }

  // Complete a task
  Future<void> toggleTaskCompletion(String taskId) async {
    final Set<String> completed = Set<String>.from(state.completedTaskIds);
    if (completed.contains(taskId)) {
      completed.remove(taskId);
    } else {
      completed.add(taskId);
    }
    state = state.copyWith(completedTaskIds: completed);

    await _autoSave();
  }

  Future<void> stopSession() async {
    if (state.timerStatus == TimerStatus.completed) return;
    _timer?.cancel();
    state = state.copyWith(timerStatus: TimerStatus.completed);

    // Final save before completion
    await _autoSave();

    // Then complete (w/o mood or notes)
    await completeSession();
  }

  /// Is called when:
  /// The session is paused or stopped
  /// A goal or task have be checked off
  /// A break phase has been completed
  /// Every min when a focus phase is ongoing
  Future<void> _autoSave() async {
    if (state.instance == null) return;

    try {
      final SessionInstanceModel updatedInstance = state.instance!.copyWith(
        totalFocusSecondsElapsed: state.totalFocusSecondsElapsed,
        totalBreakSecondsElapsed: state.totalBreakSecondsElapsed,
        totalFocusPhases: state.totalFocusPhases,
        totalCompletedBlocks: state.completedBlocks,
        totalCompletedGoals: state.completedGoalIds.length,
        totalCompletedTasks: state.completedTaskIds.length,
        status: SessionStatus.inProgress,
      );

      await _updateInstanceUseCase.call(updatedInstance);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Final completion of the instance; is called
  /// after the reflection screen
  Future<void> completeSession() async {
    if (state.instance == null) return;

    try {
      await _completeInstanceUseCase.call(
        state.instance!.copyWith(
          completedAt: DateTime.now(),
          status: SessionStatus.completed,
        ),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}
