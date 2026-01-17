import 'dart:async';
import 'dart:io';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/core/utils/notification_utils.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/live_activity_service.dart';
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
        currentPhaseIndex: instance.currentPhaseIndex,
        currentPhase: phaseFromIndex(
          instance.currentPhaseIndex,
          session.focusPhases,
        ),
        remainingSeconds:
            instance.remainingSeconds ??
            getDefaultDuration(
              phaseFromIndex(instance.currentPhaseIndex, session.focusPhases),
              session,
            ),

        isLoading: false,
      );

      _goalsSubscription = _manageGoalUseCase
          .watchGoalsBySessionIdAndDate(sessionId, DateTime.now())
          .listen((List<GoalModel> goals) {
            // Filter out deleted goals
            final filteredGoals = goals
                .where((goal) => !state.goalIdsToDelete.contains(goal.id))
                .toList();

            state = state.copyWith(
              goals: filteredGoals,
              allOriginalGoals: goals,
            );
          });

      _tasksSubscription = _manageTasksUseCase
          .watchTasksBySessionIdAndDate(sessionId, DateTime.now())
          .listen((List<TaskModel> tasks) {
            // Filter out deleted tasks
            final filteredTasks = tasks
                .where((task) => !state.taskIdsToDelete.contains(task.id))
                .toList();
            state = state.copyWith(
              tasks: filteredTasks,
              allOriginalTasks: tasks,
            );
          });
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
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

  Future<void> deleteTasks(List<String> taskIds) async {
    try {
      for (final taskId in taskIds) {
        await _manageTasksUseCase.deleteTask(int.parse(taskId));
      }
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
          keptForFutureSessions: false,
        ),
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteGoals(List<String> goalIds) async {
    try {
      for (final goalId in goalIds) {
        await _manageGoalUseCase.deleteGoal(int.parse(goalId));
      }
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void removeGoalById({required String goalId}) {
    final newGoals = state.goals.where((g) => g.id != goalId).toList();
    // Remove goal and its expanded section
    state = state.copyWith(
      goals: newGoals,
      goalIdsToDelete: [...state.goalIdsToDelete, goalId],
      expandedGoalId: state.expandedGoalId == goalId
          ? null
          : state.expandedGoalId,
    );
  }

  void removeTaskById({required String taskId}) {
    final newTasks = state.tasks.where((g) => g.id != taskId).toList();
    state = state.copyWith(
      tasks: newTasks,
      taskIdsToDelete: [...state.taskIdsToDelete, taskId],
    );
  }

  void toggleExpandedGoal(String id) {
    state = state.copyWith(
      expandedGoalId: state.expandedGoalId == id ? null : id,
    );
  }

  // ---- TIMER RELATED ----
  void _setupBackgroundListeners() {
    FlutterBackgroundService().on('update').listen((event) {
      if (event != null && state.timerStatus == TimerStatus.running) {
        // Sync background time to UI state
        final bgSeconds = event['remainingSeconds'] as int;

        // Only update if there is a discrepancy to avoid loop jitters
        if ((state.remainingSeconds - bgSeconds).abs() > 1) {
          state = state.copyWith(remainingSeconds: bgSeconds);
        }
      }
    });

    FlutterBackgroundService().on('finished').listen((_) {
      _handlePhaseComplete();
    });
  }

  Future<void> startTimer() async {
    // In case of double taps
    if (state.timerStatus == TimerStatus.running) return;

    final service = FlutterBackgroundService();

    if (!(await service.isRunning())) {
      await service.startService();
    }

    // Tells background service the remaining seconds to start with
    service
      ..invoke('setTimer', {'seconds': state.remainingSeconds})
      ..invoke('start');

    // Tell iOS live activity to start
    if (Platform.isIOS) {
      await ref
          .read(liveActivityServiceProvider.notifier)
          .start(
            secondsRemaining: state.remainingSeconds,
            title: NotificationUtils.getPhaseLabel(state.currentPhase),
          );
    }

    if (state.timerStatus == TimerStatus.initial) {
      state = state.copyWith(
        timerStatus: TimerStatus.running,
      );
      startFocusPrompting(); // Start focus prompt when timer has been started
    } else if (state.timerStatus == TimerStatus.paused) {
      state = state.copyWith(timerStatus: TimerStatus.running);
    }

    _timer?.cancel();
    _timer = null;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_tick());
    });
  }

  Future<void> pauseTimer() async {
    _timer?.cancel();

    // Stop background task
    FlutterBackgroundService().invoke('stop');
    if (Platform.isIOS) {
      await ref.read(liveActivityServiceProvider.notifier).stop();
    }

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
    var shortBreak = state.totalBreakSecondsElapsed;
    var longBreak = state.totalLongBreakSecondsElapsed;

    switch (state.currentPhase) {
      case SessionPhase.focus:
        focus++;
      case SessionPhase.shortBreak:
        shortBreak++;
      case SessionPhase.longBreak:
        longBreak++;
    }

    state = state.copyWith(
      remainingSeconds: newRemaining,
      currentPhaseElapsed: newElapsed,
      totalFocusSecondsElapsed: focus,
      totalBreakSecondsElapsed: shortBreak,
      totalLongBreakSecondsElapsed: longBreak,
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

    if (state.currentPhase == SessionPhase.focus) {
      // Determine next break type
      // E.g. we have 4 % 4 = 0, take long else short break
      final isLongBreak =
          (state.totalFocusPhases + 1) % session.focusPhases == 0;
      nextPhase = isLongBreak
          ? SessionPhase.longBreak
          : SessionPhase.shortBreak;
      duration =
          (isLongBreak ? session.longBreakTimeMin : session.breakTimeMin) * 60;
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

    // Sync the background notification label
    final label = NotificationUtils.getPhaseLabel(phase);
    final subtitle = NotificationUtils.getSubtitle(phase);

    // Refresh background service with updated values; start again for new phase
    FlutterBackgroundService().invoke('updatePhase', {
      'title': label,
      'subtitle': subtitle,
    });
    FlutterBackgroundService().invoke('setTimer', {'seconds': durationSeconds});
    FlutterBackgroundService().invoke('start');

    // Update the existing live activity with new phase info
    if (Platform.isIOS) {
      await ref
          .read(liveActivityServiceProvider.notifier)
          .update(
            secondsRemaining: durationSeconds,
            title: NotificationUtils.getPhaseLabel(phase),
          );
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

  void updateTimestamp(DateTime timestamp) {
    state = state.copyWith(lastActiveTimestamp: timestamp);
  }

  Future<void> syncTimerAfterBackground() async {
    if (state.lastActiveTimestamp != null &&
        state.timerStatus == TimerStatus.running) {
      final secondsGone = DateTime.now()
          .difference(state.lastActiveTimestamp!)
          .inSeconds;
      var remainingCatchup = secondsGone;

      while (remainingCatchup > 0) {
        // Case 1: Time remaining is within current phase
        if (remainingCatchup < state.remainingSeconds) {
          _syncTotals(remainingCatchup);

          state = state.copyWith(
            remainingSeconds: state.remainingSeconds - remainingCatchup,
            currentPhaseElapsed: state.currentPhaseElapsed + remainingCatchup,
          );

          remainingCatchup = 0;
        } else {
          // Case 2: Time exceeds current phase, move to the next one(s)
          remainingCatchup -= state.remainingSeconds;
          _syncTotals(remainingCatchup);
          await _handlePhaseComplete(isSynching: true);
        }
      }
      // Perform a single save to the db after returning
      await _autoSave();
    }
  }

  // Helper to sync the total values and correct statistics
  void _syncTotals(int seconds) {
    state = state.copyWith(
      totalFocusSecondsElapsed: state.currentPhase == SessionPhase.focus
          ? state.totalFocusSecondsElapsed + seconds
          : state.totalFocusSecondsElapsed,
      totalBreakSecondsElapsed: state.currentPhase == SessionPhase.shortBreak
          ? state.totalBreakSecondsElapsed + seconds
          : state.totalBreakSecondsElapsed,
      totalLongBreakSecondsElapsed: state.currentPhase == SessionPhase.longBreak
          ? state.totalLongBreakSecondsElapsed + seconds
          : state.totalLongBreakSecondsElapsed,
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
    required List<String> goalIdsToDelete,
    required List<String> taskIdsToDelete,
  }) async {
    if (state.instance == null) return state.instance!;

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
