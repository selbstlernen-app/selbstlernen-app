import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/models.dart';

part 'active_session_state.freezed.dart';

enum SessionPhase { focus, shortBreak, longBreak }

enum TimerStatus { initial, running, paused, completed }

@freezed
abstract class ActiveSessionState with _$ActiveSessionState {
  const ActiveSessionState._();

  const factory ActiveSessionState({
    SessionModel? session,
    SessionInstanceModel? instance,
    @Default(<GoalModel>[]) List<GoalModel> goals,
    @Default(<TaskModel>[]) List<TaskModel> tasks,
    @Default(SessionPhase.focus) SessionPhase currentPhase,
    @Default(TimerStatus.initial) TimerStatus timerStatus,
    @Default(0) int remainingSeconds,
    @Default(0) int totalFocusSecondsElapsed,
    @Default(0) int totalBreakSecondsElapsed,
    @Default(0) int totalLongBreakSecondsElapsed,
    @Default(0) int totalFocusPhases,
    @Default(0) int completedBlocks,
    @Default(0) int currentPhaseElapsed, // used for counting upwards
    DateTime? sessionStartTime,
    // check which goal is currently expanded if any
    @Default(null) String? expandedGoalId,
    @Default(<String>{}) Set<String> completedGoalIds,
    @Default(<String>{}) Set<String> completedTaskIds,
    // Keep track of newly added items and let user decide on what to keep
    // @Default(<String>{}) Set<String> newlyAddedGoalIds,
    // @Default(<String>{}) Set<String> newlyAddedTaskIds,
    @Default(false) bool isEditMode,
    @Default(false) bool countUpwards,
    @Default(true) bool isLoading,
    @Default(0) int currentPhaseIndex,
    String? error,
  }) = _ActiveSessionState;

  List<TaskModel> get ungroupedTasks =>
      tasks.where((TaskModel task) => task.goalId == null).toList();

  List<TaskModel> tasksForGoal(String goalId) =>
      tasks.where((TaskModel task) => task.goalId == goalId).toList();

  List<TaskModel> get newlyAddedTasks => tasks
      .where((TaskModel task) => task.keptForFutureSessions == false)
      .toList();

  List<GoalModel> get newlyAddedGoals => goals
      .where((GoalModel goal) => goal.keptForFutureSessions == false)
      .toList();

  List<GoalModel> getExistingGoalsWithNewTasks() {
    Set<String> goalIds = tasks
        .where((t) => t.goalId != null)
        .map((TaskModel t) => t.goalId!)
        .toSet();
    List<GoalModel> existingGoalsWithNewTasks = goals
        .where(
          (GoalModel goal) =>
              goal.keptForFutureSessions == true & goalIds.contains(goal.id),
        )
        .toList();

    return existingGoalsWithNewTasks;
  }
}
