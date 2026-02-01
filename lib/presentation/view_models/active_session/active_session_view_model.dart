import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/focus_prompter.dart';
import 'package:srl_app/presentation/view_models/settings/settings_view_model.dart';
import 'package:vibration/vibration.dart';

part 'active_session_view_model.g.dart';

@riverpod
Stream<SessionInstanceModel> activeInstance(Ref ref, int instanceId) {
  return ref
      .watch(getInstanceUseCaseProvider)
      .watchSessionInstanceById(instanceId);
}

@riverpod
Stream<SessionModel> activeSession(Ref ref, int instanceId) async* {
  final instance = await ref.watch(activeInstanceProvider(instanceId).future);
  yield* ref
      .watch(manageSessionUseCaseProvider)
      .watchSessionById(int.parse(instance.sessionId));
}

@riverpod
Stream<List<GoalModel>> activeGoals(Ref ref, int instanceId) async* {
  final session = await ref.watch(activeSessionProvider(instanceId).future);
  yield* ref
      .watch(manageGoalUseCaseProvider)
      .watchGoalsBySessionIdAndDate(int.parse(session.id!), DateTime.now());
}

@riverpod
Stream<List<TaskModel>> activeTasks(Ref ref, int instanceId) async* {
  final session = await ref.watch(activeSessionProvider(instanceId).future);
  yield* ref
      .watch(manageTasksUseCaseProvider)
      .watchTasksBySessionIdAndDate(int.parse(session.id!), DateTime.now());
}

@Riverpod(keepAlive: true)
class ActiveSessionViewModel extends _$ActiveSessionViewModel {
  Timer? _timer;
  FocusPrompter? _focusPrompter;

  @override
  ActiveSessionState build(int instanceId) {
    _listenToDataStreams(instanceId);

    ref.onDispose(() {
      _timer?.cancel();
      _focusPrompter?.dispose();
    });

    return const ActiveSessionState();
  }

  void _listenToDataStreams(int instanceId) {
    // .listen to update when manual changes in db happen
    ref
      ..listen(activeInstanceProvider(instanceId), (prev, next) {
        next.whenData((instance) {
          if (state.instance == null) {
            // Initialise session from the instance if already in progress!
            _initializeFromInstance(instance);
          } else {
            state = state.copyWith(instance: instance);
          }
        });
      })
      // Watch goals
      ..listen(activeGoalsProvider(instanceId), (prev, next) {
        next.whenData((goals) {
          final filteredGoals = goals
              .where((goal) => !state.goalIdsToDelete.contains(goal.id))
              .toList();
          state = state.copyWith(goals: filteredGoals, allOriginalGoals: goals);
        });
      });
  }

  Future<void> _initializeFromInstance(SessionInstanceModel instance) async {
    // Fetch session once to setup defaults
    final session = await ref
        .read(manageSessionUseCaseProvider)
        .getSessionById(
          int.parse(instance.sessionId),
        );

    state = state.copyWith(
      session: session,
      instance: instance,
      remainingSeconds:
          instance.remainingSeconds ??
          getDefaultDuration(SessionPhase.focus, session),
      isLoading: false,
    );

    // Auto-start timer logic here
    if (ref.read(settingsViewModelProvider).timerStartsAutomatically) {
      unawaited(startTimer());
    }
  }

  SessionPhase phaseFromIndex(int index, int focusPhases) {
    if (index.isEven) {
      return SessionPhase.focus;
    }
    // Odd index means either long or short break was last
    final lastBreakIndex = (focusPhases * 2) - 1;
    return index == lastBreakIndex
        ? SessionPhase.longBreak
        : SessionPhase.shortBreak;
  }

  int getDefaultDuration(SessionPhase phase, SessionModel session) {
    switch (phase) {
      case SessionPhase.focus:
        return session.focusTimeMin * 60;
      case SessionPhase.shortBreak:
        return session.breakTimeMin * 60;
      case SessionPhase.longBreak:
        return session.longBreakTimeMin * 60;
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

    final focusCheck = FocusCheck(
      atElapsedSeconds: state.totalFocusSecondsElapsed,
      level: level,
    );

    final updatedInstance = state.instance!.copyWith(
      focusChecks: [...state.instance!.focusChecks, focusCheck],
    );

    state = state.copyWith(instance: updatedInstance, showFocusPrompt: false);

    await ref
        .read(manangeInstanceUseCaseProvider)
        .updateInstance(updatedInstance);

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
    await ref
        .read(manageTasksUseCaseProvider)
        .createTask(
          TaskModel(
            sessionId: state.session!.id,
            title: title,
            goalId: goalId,
            keptForFutureSessions: false,
          ),
        );
  }

  Future<void> orphanTask(TaskModel task) async {
    try {
      await ref
          .read(manageTasksUseCaseProvider)
          .updateTask(task.copyWith(goalId: null));
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteTasks(List<String> taskIds) async {
    await Future.wait(
      taskIds.map(
        (taskId) =>
            ref.read(manageTasksUseCaseProvider).deleteTask(int.parse(taskId)),
      ),
    );
  }

  Future<void> addGoal(String title) async {
    if (state.session == null) return;

    try {
      await ref
          .read(manageGoalUseCaseProvider)
          .createGoal(
            GoalModel(
              sessionId: state.session!.id,
              title: title,
              keptForFutureSessions: false,
            ),
          );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteGoals(List<String> goalIds) async {
    await Future.wait(
      goalIds.map(
        (goalId) =>
            ref.read(manageGoalUseCaseProvider).deleteGoal(int.parse(goalId)),
      ),
    );
  }

  void removeGoalById({required String goalId}) {
    final newGoals = state.goals.where((g) => g.id != goalId).toList();

    // Remove goal and its expanded section
    state = state.copyWith(
      goals: newGoals,
      goalIdsToDelete: {...state.goalIdsToDelete, goalId},
      expandedGoalId: state.expandedGoalId == goalId
          ? null
          : state.expandedGoalId,
    );
  }

  void removeTaskById({required String taskId}) {
    final newTasks = state.tasks.where((g) => g.id != taskId).toList();

    state = state.copyWith(
      tasks: newTasks,
      taskIdsToDelete: {...state.taskIdsToDelete, taskId},
    );
  }

  void toggleExpandedGoal(String id) {
    state = state.copyWith(
      expandedGoalId: state.expandedGoalId == id ? null : id,
    );
  }

  // ---- TIMER RELATED ----
  Future<void> startTimer() async {
    if (_timer?.isActive ?? false) return;

    // In case of double taps
    if (state.timerStatus == TimerStatus.running) return;

    state = state.copyWith(
      timerStatus: TimerStatus.running,
    );
    // Start focus prompt when timer has been started
    startFocusPrompting();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_tick());
    });
  }

  Future<void> pauseTimer() async {
    _timer?.cancel();

    await ref.read(settingsRepositoryProvider).setTimerEndTimestamp(null);

    _focusPrompter?.stopPrompting();
    state = state.copyWith(timerStatus: TimerStatus.paused);
    await _autoSave();
  }

  Future<void> _tick() async {
    if (state.remainingSeconds <= 0) {
      await _handlePhaseComplete();
      return;
    }
    // Update times once
    final newRemaining = state.remainingSeconds - 1;
    final newElapsed = state.currentPhaseElapsed + 1;

    var focus = state.totalFocusSecondsElapsed;
    var breakTime = state.totalBreakSecondsElapsed;

    switch (state.currentPhase) {
      case SessionPhase.focus:
        focus++;
      case SessionPhase.shortBreak:
      case SessionPhase.longBreak:
        breakTime++;
    }

    state = state.copyWith(
      remainingSeconds: newRemaining,
      currentPhaseElapsed: newElapsed,
      totalFocusSecondsElapsed: focus,
      totalBreakSecondsElapsed: breakTime,
    );

    // Auto-save to DB every min
    if (newRemaining % 60 == 0) {
      await _autoSave();
    }
  }

  Future<void> skipPhase() async {
    await _handlePhaseComplete();
  }

  /// Handles logic behind moving from focus to either short or long break
  Future<void> _handlePhaseComplete({bool isSynching = false}) async {
    // Vibrate when allowed
    if (!isSynching) {
      await _vibrateForPhaseChange();
    }

    final session = state.session!;
    SessionPhase nextPhase;
    int duration;
    var nextTotalFocus = state.totalFocusPhases;
    var nextBlocks = state.completedBlocks;
    var nextIndex = state.currentPhaseIndex + 1;

    // If we only have focus timer, then we switch no phases visibly
    if (state.session!.hasSimpleTimer) {
      nextPhase = SessionPhase.focus;
      duration = session.focusTimeMin * 60;
      nextBlocks++;
      nextIndex = 0;
    } else {
      if (state.currentPhase == SessionPhase.focus) {
        // Determine next break type
        // E.g. we have 4 % 4 = 0, take long else short break
        final isLongBreak =
            (state.totalFocusPhases + 1) % session.focusPhases == 0;
        nextPhase = isLongBreak
            ? SessionPhase.longBreak
            : SessionPhase.shortBreak;
        duration =
            (isLongBreak ? session.longBreakTimeMin : session.breakTimeMin) *
            60;
      } else {
        // After either short or long break follows focus time
        nextPhase = SessionPhase.focus;
        duration = session.focusTimeMin * 60;
        nextTotalFocus++;
        if (state.currentPhase == SessionPhase.longBreak) {
          nextBlocks++;
          nextIndex = 0;
        }
      }
    }

    return _startPhase(
      phase: nextPhase,
      durationSeconds: duration,
      totalFocusPhases: nextTotalFocus,
      completedBlocks: nextBlocks,
      currentPhaseIndex: nextIndex,
      isSyncMode: isSynching,
    );
  }

  Future<void> _startPhase({
    required SessionPhase phase,
    required int durationSeconds,
    int? totalFocusPhases,
    int? completedBlocks,
    int? currentPhaseIndex,
    bool isSyncMode = false,
  }) async {
    state = state.copyWith(
      currentPhase: phase,
      remainingSeconds: durationSeconds,
      totalFocusPhases: totalFocusPhases ?? state.totalFocusPhases,
      completedBlocks: completedBlocks ?? state.completedBlocks,
      currentPhaseIndex: currentPhaseIndex ?? state.currentPhaseIndex,
      currentPhaseElapsed: 0,
    );

    // Prompting
    final shouldPrompt = phase == SessionPhase.focus;
    if (shouldPrompt) {
      startFocusPrompting();
    } else {
      _focusPrompter?.stopPrompting();
    }

    if (!isSyncMode) {
      await _autoSave();
    }
  }

  Future<void> _vibrateForPhaseChange() async {
    try {
      if (await Vibration.hasCustomVibrationsSupport()) {
        await Vibration.vibrate(duration: 300);
      } else if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(duration: 300);
      }
    } on Exception catch (_) {
      // ignore errors silently (e.g., when in simulator / unsupported)
    }
  }

  Future<void> syncTimerAfterBackground() async {
    final targetEndTime = ref
        .read(settingsRepositoryProvider)
        .timerEndTimestamp;
    if (targetEndTime == null || state.timerStatus != TimerStatus.running) {
      return;
    }

    final now = DateTime.now();
    if (now.isBefore(targetEndTime)) {
      // Still in the same phase; no need to handle difference much
      state = state.copyWith(
        remainingSeconds: targetEndTime.difference(now).inSeconds,
      );
      return;
    }

    var remainingCatchup = now.difference(targetEndTime).inSeconds;

    // Set the new target end time for the phase we currently are in
    final newTarget = DateTime.now().add(
      Duration(seconds: state.remainingSeconds),
    );
    await ref.read(settingsRepositoryProvider).setTimerEndTimestamp(newTarget);

    while (remainingCatchup > 0) {
      if (!ref.mounted) return;

      if (remainingCatchup < state.remainingSeconds) {
        // Case 1: We land inside the CURRENT phase
        _syncTotals(remainingCatchup);
        state = state.copyWith(
          remainingSeconds: state.remainingSeconds - remainingCatchup,
          currentPhaseElapsed: state.currentPhaseElapsed + remainingCatchup,
        );
        remainingCatchup = 0;
      } else {
        // Case 2: The current phase is definitely finished
        remainingCatchup -= state.remainingSeconds;
        _syncTotals(state.remainingSeconds);

        await _handlePhaseComplete(isSynching: true);
      }
    }

    await _autoSave();
  }

  // Helper to sync the total values and correct statistics
  void _syncTotals(int seconds) {
    state = state.copyWith(
      totalFocusSecondsElapsed: state.currentPhase == SessionPhase.focus
          ? state.totalFocusSecondsElapsed + seconds
          : state.totalFocusSecondsElapsed,
      totalBreakSecondsElapsed:
          (state.currentPhase == SessionPhase.shortBreak ||
              state.currentPhase == SessionPhase.longBreak)
          ? state.totalBreakSecondsElapsed + seconds
          : state.totalBreakSecondsElapsed,
    );
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
        completedGoalsRate: state.goals.isNotEmpty
            ? (state.completedGoalIds.length / state.goals.length) * 100
            : 0.0,
        completedTasksRate: state.tasks.isNotEmpty
            ? (state.completedTaskIds.length / state.tasks.length) * 100
            : 0.0,
        status: SessionStatus.inProgress,
        currentPhaseIndex: state.currentPhaseIndex,
        remainingSeconds: state.remainingSeconds,
      );

      await ref
          .read(manangeInstanceUseCaseProvider)
          .updateInstance(updatedInstance);
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Final completion of the instance; is called
  /// after the reflection screen
  Future<SessionInstanceModel> completeSession({
    required List<String> goalIdsToKeep,
    required List<String> taskIdsToKeep,
    required List<String> goalIdsToDelete,
    required List<String> taskIdsToDelete,
  }) async {
    if (state.instance == null) return state.instance!;

    await ref.read(settingsRepositoryProvider).setTimerEndTimestamp(null);

    try {
      // Delete selected tasks and goals
      await deleteGoals(goalIdsToDelete);
      await deleteTasks(taskIdsToDelete);

      final updatedInstance = state.instance!.copyWith(
        completedAt: DateTime.now(),
        status: SessionStatus.completed,
        totalFocusSecondsElapsed: state.totalFocusSecondsElapsed,
        totalBreakSecondsElapsed: state.totalBreakSecondsElapsed,
        totalFocusPhases: state.totalFocusPhases,
        totalCompletedBlocks: state.completedBlocks,
        totalCompletedGoals: state.completedGoalIds.length,
        totalCompletedTasks: state.completedTaskIds.length,
        completedGoalsRate: state.goals.isNotEmpty
            ? (state.completedGoalIds.length / state.goals.length) * 100
            : 0.0,
        completedTasksRate: state.tasks.isNotEmpty
            ? (state.completedTaskIds.length / state.tasks.length) * 100
            : 0.0,
      );

      await ref.read(completeInstanceUseCaseProvider).call(updatedInstance);

      // If user decides to keep the newly added items,
      // set keepForFutureSessions to true
      for (final goalId in goalIdsToKeep) {
        await ref
            .read(manageGoalUseCaseProvider)
            .updateGoalFutureStatus(
              goalId,
              keptForFutureSessions: true,
            );
      }
      for (final taskId in taskIdsToKeep) {
        await ref
            .read(manageTasksUseCaseProvider)
            .updateTaskFutureStatus(
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
