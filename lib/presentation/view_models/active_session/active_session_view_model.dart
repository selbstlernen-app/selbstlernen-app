import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:vibration/vibration.dart';

part 'active_session_view_model.g.dart';

@riverpod
class ActiveSessionViewModel extends _$ActiveSessionViewModel {
  late final ManageGoalUseCase _manageGoalUseCase;
  late final ManageTasksUseCase _manageTasksUseCase;
  late final ManageSessionUseCase _manageSessionUseCase;
  late final ManangeInstanceUseCase _manangeInstanceUseCase;

  late final GetInstanceUseCase _getInstanceUseCase;
  late final CompleteInstanceUseCase _completeInstanceUseCase;
  late final int _instanceId;

  late StreamSubscription<dynamic>? _goalsSubscription;
  late StreamSubscription<dynamic>? _tasksSubscription;

  Timer? _timer;

  @override
  ActiveSessionState build(int instanceId) {
    _instanceId = instanceId;
    _manageSessionUseCase = ref.watch(manageSessionUseCaseProvider);
    _manageGoalUseCase = ref.watch(manageGoalUseCaseProvider);
    _manageTasksUseCase = ref.watch(manageTasksUseCaseProvider);

    _manangeInstanceUseCase = ref.watch(manangeInstanceUseCaseProvider);
    _completeInstanceUseCase = ref.watch(completeInstanceUseCaseProvider);
    _getInstanceUseCase = ref.watch(getInstanceUseCaseProvider);

    _loadData();

    ref.onDispose(() {
      _timer?.cancel();
      _goalsSubscription?.cancel();
      _tasksSubscription?.cancel();
    });

    return const ActiveSessionState(isLoading: true);
  }

  Future<void> _loadData() async {
    try {
      // Load the instance (created either in detail screen or formula)
      final SessionInstanceModel instance = await _getInstanceUseCase
          .getInstanceById(_instanceId);

      final int sessionId = int.parse(instance.sessionId);

      final SessionModel session = await _manageSessionUseCase.getSessionById(
        sessionId,
      );

      state = state.copyWith(
        session: session,
        instance: instance,
        totalFocusSecondsElapsed: instance.totalFocusSecondsElapsed,
        totalBreakSecondsElapsed: instance.totalBreakSecondsElapsed,
        totalFocusPhases: instance.totalFocusPhases,
        completedBlocks: instance.totalCompletedBlocks,
        remainingSeconds: session.focusTimeMin * 60,
        isLoading: false,
      );

      _goalsSubscription = _manageGoalUseCase
          .watchGoalsBySessionIdAndDate(sessionId, DateTime.now())
          .listen((List<GoalModel> goals) {
            state = state.copyWith(goals: goals);
          });

      _tasksSubscription = _manageTasksUseCase
          .watchTasksBySessionIdAndDate(sessionId, DateTime.now())
          .listen((List<TaskModel> tasks) {
            state = state.copyWith(tasks: tasks);
          });
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void setCountUpwards(bool countUpwards) {
    state = state.copyWith(countUpwards: countUpwards);
  }

  void toggleEditMode() {
    state = state.copyWith(isEditMode: !state.isEditMode);
  }

  Future<void> addTask(String title, {String? goalId}) async {
    if (state.session == null) return;

    try {
      await _manageTasksUseCase.createTask(
        TaskModel(
          sessionId: state.session!.id,
          title: title,
          isCompleted: false,
          goalId: goalId,
          keptForFutureSessions: false,
        ),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> orphanTask(TaskModel task) async {
    try {
      await _manageTasksUseCase.updateTask(task.copyWith(goalId: null));
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteTask({required String taskId}) async {
    try {
      await _manageTasksUseCase.deleteTask(int.parse(taskId));
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addGoal(String title) async {
    if (state.session == null) return;

    try {
      await _manageGoalUseCase.createGoal(
        GoalModel(
          sessionId: state.session!.id,
          title: title,
          isCompleted: false,
          keptForFutureSessions: false,
        ),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteGoal({required String goalId}) async {
    try {
      await _manageGoalUseCase.deleteGoal(int.parse(goalId));
      state = state.copyWith(
        expandedGoalId: state.expandedGoalId == goalId
            ? null
            : state.expandedGoalId,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
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
          currentPhaseElapsed: state.currentPhaseElapsed + 1,
        );
      } else if (state.currentPhase == SessionPhase.shortBreak) {
        state = state.copyWith(
          totalBreakSecondsElapsed: state.totalBreakSecondsElapsed + 1,
          currentPhaseElapsed: state.currentPhaseElapsed + 1,
        );
      } else {
        state = state.copyWith(
          totalLongBreakSecondsElapsed: state.totalLongBreakSecondsElapsed + 1,
          currentPhaseElapsed: state.currentPhaseElapsed + 1,
        );
      }
    } else {
      _handlePhaseComplete();
    }
  }

  void skipPhase() {
    _handlePhaseComplete();
  }

  void toggleExpandedGoal(String id) {
    state = state.copyWith(
      expandedGoalId: state.expandedGoalId == id ? null : id,
    );
  }

  // Function to switch phase dependent on the current one (focus -> short/long break)
  void _handlePhaseComplete() {
    // Vibrate when allowed
    _vibrateForPhaseChange();

    final SessionModel session = state.session!;

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
            currentPhaseIndex: state.currentPhaseIndex + 1,
          );
        } else {
          // Completed a regular focus phase
          _startPhase(
            phase: SessionPhase.shortBreak,
            durationSeconds: (session.breakTimeMin) * 60,
            currentPhaseIndex: state.currentPhaseIndex + 1,
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
          currentPhaseIndex: state.currentPhaseIndex + 1,
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
          currentPhaseIndex: 0,
        );
        break;
    }
  }

  void _startPhase({
    required SessionPhase phase,
    required int durationSeconds,
    int? totalFocusPhases,
    int? completedBlocks,
    int? currentPhaseIndex,
  }) {
    state = state.copyWith(
      currentPhase: phase,
      remainingSeconds: durationSeconds,
      totalFocusPhases: totalFocusPhases ?? state.totalFocusPhases,
      completedBlocks: completedBlocks ?? state.completedBlocks,
      currentPhaseIndex: currentPhaseIndex ?? state.currentPhaseIndex,
      currentPhaseElapsed: 0,
    );
    _autoSave();
  }

  Future<void> _vibrateForPhaseChange() async {
    try {
      if (await Vibration.hasCustomVibrationsSupport()) {
        await Vibration.vibrate(duration: 1000);
      } else if (await Vibration.hasVibrator()) {
        // Fallback: short vibration
        await Vibration.vibrate(duration: 300);
      }
    } catch (e) {
      // ignore errors silently (e.g., when in simulator / unsupported)
    }
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

  // Future<void> stopSession() async {
  //   if (state.timerStatus == TimerStatus.completed) return;
  //   _timer?.cancel();
  //   state = state.copyWith(timerStatus: TimerStatus.completed);

  //   // Then complete (w/o mood or notes)
  //   await completeSession();
  // }

  /// Is called when:
  /// The session is paused or stopped
  /// A goal or task have be checked off
  /// A break phase has been completed
  /// Every min when a focus phase is ongoing
  Future<void> _autoSave() async {
    if (state.instance == null || state.instance!.id == null) return;

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

      await _manangeInstanceUseCase.updateInstance(updatedInstance);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Final completion of the instance; is called
  /// after the reflection screen
  Future<SessionInstanceModel> completeSession({
    required List<String> goalIdsToKeep,
    required List<String> taskIdsToKeep,
  }) async {
    if (state.instance == null) return state.instance!;

    print(goalIdsToKeep);
    print(taskIdsToKeep);

    try {
      final SessionInstanceModel updatedInstance = state.instance!.copyWith(
        completedAt: DateTime.now(),
        status: SessionStatus.completed,
        totalFocusSecondsElapsed: state.totalFocusSecondsElapsed,
        totalBreakSecondsElapsed: state.totalBreakSecondsElapsed,
        totalFocusPhases: state.totalFocusPhases,
        totalCompletedBlocks: state.completedBlocks,
        totalCompletedGoals: state.completedGoalIds.length,
        totalCompletedTasks: state.completedTaskIds.length,
      );

      await _completeInstanceUseCase.call(updatedInstance);

      // If user decides to keep the newly added items, then set keepForFutureSessions to true
      for (String goalId in goalIdsToKeep) {
        await _manageGoalUseCase.updateGoalFutureStatus(goalId, true);
      }
      for (String taskId in taskIdsToKeep) {
        await _manageTasksUseCase.updateTaskFutureStatus(taskId, true);
      }

      state = state.copyWith(instance: updatedInstance);

      return updatedInstance;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}
