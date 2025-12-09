import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/models.dart';

part 'active_session_state.freezed.dart';

enum SessionPhase { focus, shortBreak, longBreak }

enum TimerStatus { initial, running, paused, completed }

@freezed
abstract class ActiveSessionState with _$ActiveSessionState {
  const factory ActiveSessionState({
    SessionModel? session,
    SessionInstanceModel? instance,
    @Default(<GoalModel>[]) List<GoalModel> goals,
    @Default(<TaskModel>[]) List<TaskModel> tasks,
    // Timer related data
    @Default(SessionPhase.focus) SessionPhase currentPhase,
    @Default(TimerStatus.initial) TimerStatus timerStatus,
    @Default(0) int remainingSeconds,
    @Default(0) int totalFocusSecondsElapsed,
    @Default(0) int totalBreakSecondsElapsed,
    @Default(0) int totalLongBreakSecondsElapsed,
    @Default(0) int totalFocusPhases,
    @Default(0) int completedBlocks,
    @Default(0) int currentPhaseElapsed, // Used for counting upwards
    DateTime? sessionStartTime,

    @Default(0) int currentPhaseIndex,

    // Goal and task tracking
    // Check which goal is currently expanded if any
    @Default(null) String? expandedGoalId,
    @Default(<String>{}) Set<String> completedGoalIds,
    @Default(<String>{}) Set<String> completedTaskIds,

    @Default(false) bool isEditMode,
    @Default(false) bool countUpwards,

    // Toggle focus prompt
    @Default(false) bool showFocusPrompt,

    @Default(true) bool isLoading,
    String? error,
  }) = _ActiveSessionState;
  const ActiveSessionState._();

  List<TaskModel> get ungroupedTasks =>
      tasks.where((TaskModel task) => task.goalId == null).toList();

  List<TaskModel> tasksForGoal(String goalId) =>
      tasks.where((TaskModel task) => task.goalId == goalId).toList();

  List<TaskModel> get newlyAddedTasks =>
      tasks.where((TaskModel task) => !task.keptForFutureSessions).toList();

  List<GoalModel> get newlyAddedGoals =>
      goals.where((GoalModel goal) => !goal.keptForFutureSessions).toList();

  List<GoalModel> getExistingGoalsWithNewTasks() {
    final goalIds = tasks
        .where((TaskModel t) => (t.goalId != null) & (!t.keptForFutureSessions))
        .map((TaskModel t) => t.goalId!)
        .toSet();
    final existingGoalsWithNewTasks = goals
        .where(
          (GoalModel goal) =>
              goal.keptForFutureSessions == goalIds.contains(goal.id),
        )
        .toList();
    return existingGoalsWithNewTasks;
  }

  bool hasEditedItems() {
    return newlyAddedGoals.isNotEmpty || newlyAddedTasks.isNotEmpty;
  }
}
