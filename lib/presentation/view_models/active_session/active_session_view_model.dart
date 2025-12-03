import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/focus_check.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/focus_prompter.dart';
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
  FocusPrompter? _focusPrompter;

  @override
  ActiveSessionState build(int instanceId) {
    _instanceId = instanceId;
    _manageSessionUseCase = ref.watch(manageSessionUseCaseProvider);
    _manageGoalUseCase = ref.watch(manageGoalUseCaseProvider);
    _manageTasksUseCase = ref.watch(manageTasksUseCaseProvider);

    _manangeInstanceUseCase = ref.watch(manangeInstanceUseCaseProvider);
    _completeInstanceUseCase = ref.watch(completeInstanceUseCaseProvider);
    _getInstanceUseCase = ref.watch(getInstanceUseCaseProvider);

    unawaited(_loadData());

    ref.onDispose(() async {
      _timer?.cancel();
      unawaited(_goalsSubscription?.cancel());
      unawaited(_tasksSubscription?.cancel());
    });

    return const ActiveSessionState();
  }

  Future<void> _loadData() async {
    try {
      // Load the instance (created either in detail screen or formula)
      final instance = await _getInstanceUseCase.getInstanceById(_instanceId);

      final sessionId = int.parse(instance.sessionId);

      final session = await _manageSessionUseCase.getSessionById(
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
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ---- FOCUS PROMPT RELATED ----
  void startFocusPrompting() {
    if (state.session == null) return;

    _focusPrompter?.dispose();
    _focusPrompter = FocusPrompter(
      session: state.session!,
      onPromptTrigger: _showFocusPrompt,
    );
    _focusPrompter?.startPrompting();
  }

  void _showFocusPrompt() {
    state = state.copyWith(showFocusPrompt: true);
  }

  void recordUserInteraction() {
    _focusPrompter?.recordInteraction();
  }

  Future<void> recordFocusLevel(FocusLevel level) async {
    if (state.instance == null) return;

    final focusCheck = FocusCheck(timestamp: DateTime.now(), level: level);

    final updatedInstance = state.instance!.copyWith(
      focusChecks: [...state.instance!.focusChecks, focusCheck],
    );

    state = state.copyWith(instance: updatedInstance, showFocusPrompt: false);

    await _manangeInstanceUseCase.updateInstance(updatedInstance);

    _focusPrompter?.recordInteraction();
  }

  // ---- GOAL/TASK RELATED ----
  void setCountUpwards({required bool countUpwards}) {
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
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> orphanTask(TaskModel task) async {
    try {
      await _manageTasksUseCase.updateTask(task.copyWith(goalId: null));
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteTask({required String taskId}) async {
    try {
      await _manageTasksUseCase.deleteTask(int.parse(taskId));
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void toggleExpandedGoal(String id) {
    state = state.copyWith(
      expandedGoalId: state.expandedGoalId == id ? null : id,
    );
  }

  // ---- TIMER RELATED ----
  void startTimer() {
    if (state.timerStatus == TimerStatus.initial) {
      state = state.copyWith(
        sessionStartTime: DateTime.now(),
        timerStatus: TimerStatus.running,
      );

      // Start focus prompt when timer has been started
      startFocusPrompting();
    } else if (state.timerStatus == TimerStatus.paused) {
      state = state.copyWith(timerStatus: TimerStatus.running);
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await _tick();
    });
  }

  Future<void> pauseTimer() async {
    _timer?.cancel();
    _focusPrompter?.stopPrompting();
    state = state.copyWith(timerStatus: TimerStatus.paused);
    await _autoSave();
  }

  Future<void> _tick() async {
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
      await _handlePhaseComplete();
    }
  }

  Future<void> skipPhase() async {
    await _handlePhaseComplete();
  }

  /// Function to switch phase dependent
  /// on the current one (focus -> short/long break)
  Future<void> _handlePhaseComplete() async {
    // Vibrate when allowed
    await _vibrateForPhaseChange();

    final session = state.session!;

    switch (state.currentPhase) {
      case SessionPhase.focus:
        // say we have 4 focus phases, then 3 are FK last is FL
        final nextFocusPhase = state.totalFocusPhases + 1;
        final focusPhases = session.focusPhases;

        // Determine next break type (if we have 4 % 4 = 0, take long break
        // else short break)
        if (nextFocusPhase % focusPhases == 0) {
          // Just completed the last focus phase -> moving on to long break
          await _startPhase(
            phase: SessionPhase.longBreak,
            durationSeconds: (session.longBreakTimeMin) * 60,
            currentPhaseIndex: state.currentPhaseIndex + 1,
          );
        } else {
          // Completed a regular focus phase
          await _startPhase(
            phase: SessionPhase.shortBreak,
            durationSeconds: (session.breakTimeMin) * 60,
            currentPhaseIndex: state.currentPhaseIndex + 1,
          );
        }

      // After short break, start next focus phase and increase total
      // focus phase
      case SessionPhase.shortBreak:
        final newTotalFocusPhases = state.totalFocusPhases + 1;
        await _startPhase(
          phase: SessionPhase.focus,
          durationSeconds: (session.focusTimeMin) * 60,
          totalFocusPhases: newTotalFocusPhases,
          currentPhaseIndex: state.currentPhaseIndex + 1,
        );

      // After long break, increment block and start new focus phase
      case SessionPhase.longBreak:
        final newTotalFocusPhases = state.totalFocusPhases + 1;
        await _startPhase(
          phase: SessionPhase.focus,
          durationSeconds: (session.focusTimeMin) * 60,
          totalFocusPhases: newTotalFocusPhases,
          completedBlocks: state.completedBlocks + 1,
          currentPhaseIndex: 0,
        );
    }
  }

  Future<void> _startPhase({
    required SessionPhase phase,
    required int durationSeconds,
    int? totalFocusPhases,
    int? completedBlocks,
    int? currentPhaseIndex,
  }) async {
    state = state.copyWith(
      currentPhase: phase,
      remainingSeconds: durationSeconds,
      totalFocusPhases: totalFocusPhases ?? state.totalFocusPhases,
      completedBlocks: completedBlocks ?? state.completedBlocks,
      currentPhaseIndex: currentPhaseIndex ?? state.currentPhaseIndex,
      currentPhaseElapsed: 0,
    );
    switch (phase) {
      case SessionPhase.focus:
        // Start focus prompting again when timer has been started
        startFocusPrompting();
      // Stop prompting in either long or short break
      case SessionPhase.longBreak:
        _focusPrompter?.stopPrompting();
      case SessionPhase.shortBreak:
        _focusPrompter?.stopPrompting();
    }
    await _autoSave();
  }

  Future<void> _vibrateForPhaseChange() async {
    try {
      if (await Vibration.hasCustomVibrationsSupport()) {
        await Vibration.vibrate(duration: 200);
      } else if (await Vibration.hasVibrator()) {
        // Fallback: short vibration
        await Vibration.vibrate(duration: 200);
      }
    } on Exception catch (_) {
      // ignore errors silently (e.g., when in simulator / unsupported)
    }
  }

  // Complete a goal
  Future<void> toggleGoalCompletion(String goalId) async {
    final completed = Set<String>.from(state.completedGoalIds);
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
    final completed = Set<String>.from(state.completedTaskIds);
    if (completed.contains(taskId)) {
      completed.remove(taskId);
    } else {
      completed.add(taskId);
    }
    state = state.copyWith(completedTaskIds: completed);

    await _autoSave();
  }

  /// Is called when:
  /// The session is paused or stopped
  /// A goal or task have be checked off
  /// A break phase has been completed
  /// Every min when a focus phase is ongoing
  Future<void> _autoSave() async {
    if (state.instance == null || state.instance!.id == null) return;

    try {
      final updatedInstance = state.instance!.copyWith(
        totalFocusSecondsElapsed: state.totalFocusSecondsElapsed,
        totalBreakSecondsElapsed: state.totalBreakSecondsElapsed,
        totalFocusPhases: state.totalFocusPhases,
        totalCompletedBlocks: state.completedBlocks,
        totalCompletedGoals: state.completedGoalIds.length,
        totalCompletedTasks: state.completedTaskIds.length,
        status: SessionStatus.inProgress,
      );

      await _manangeInstanceUseCase.updateInstance(updatedInstance);
    } on Exception catch (e) {
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

    try {
      final updatedInstance = state.instance!.copyWith(
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

      // If user decides to keep the newly added items,
      // set keepForFutureSessions to true
      for (final goalId in goalIdsToKeep) {
        await _manageGoalUseCase.updateGoalFutureStatus(
          goalId,
          keptForFutureSessions: true,
        );
      }
      for (final taskId in taskIdsToKeep) {
        await _manageTasksUseCase.updateTaskFutureStatus(
          taskId,
          keptForFutureSessions: true,
        );
      }

      state = state.copyWith(instance: updatedInstance);

      return updatedInstance;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}
