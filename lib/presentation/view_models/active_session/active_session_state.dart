import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/models.dart';

part 'active_session_state.freezed.dart';

enum SessionPhase {
  focus,
  shortBreak,
}

enum TimerStatus { initial, running, paused, completed }

@freezed
abstract class ActiveSessionState with _$ActiveSessionState {
  const factory ActiveSessionState({
    SessionModel? session,
    SessionInstanceModel? instance,

    // The time stamp marking the last time app was on actively on foreground
    DateTime? lastActiveTimestamp,

    // -- GOALS & TASKS
    // Currently displayed goals and tasks
    @Default(<GoalModel>[]) List<GoalModel> goals,
    @Default(<TaskModel>[]) List<TaskModel> tasks,

    @Default(<GoalModel>[]) List<GoalModel> allOriginalGoals,
    @Default(<TaskModel>[]) List<TaskModel> allOriginalTasks,

    @Default(<String>{}) Set<String> goalIdsToDelete,
    @Default(<String>{}) Set<String> taskIdsToDelete,
    @Default(<String>{}) Set<String> completedGoalIds,
    @Default(<String>{}) Set<String> completedTaskIds,

    // Check which goal is currently expanded if any
    @Default(null) String? expandedGoalId,

    // Current session phase
    @Default(SessionPhase.focus) SessionPhase currentPhase,

    // Current timer status
    @Default(TimerStatus.initial) TimerStatus timerStatus,

    // Remaining seconds of the current phase
    @Default(0) int remainingSeconds,

    // Total focus seconds that have currently elapsed
    @Default(0) int totalFocusSecondsElapsed,

    // Total short break seconds that have currently elapsed (short + long)
    @Default(0) int totalBreakSecondsElapsed,

    // Total focus phases that were completed
    @Default(0) int totalFocusPhases,

    // Total blocks that were completed
    @Default(0) int completedBlocks,

    // The current phase seconds elaphsed; used for counting upwards
    @Default(0) int currentPhaseElapsed,

    // Index of a current phase; used for visual display
    @Default(0) int currentPhaseIndex,

    // Flag to enable edit mode
    @Default(false) bool isEditMode,

    // Flag to change the visual timer count
    @Default(false) bool countUpwards,

    // Toggle focus prompt
    @Default(false) bool showFocusPrompt,
    // Toggle timer end prompt
    @Default(false) bool showTimerEndPrompt,

    @Default(true) bool isLoading,
    String? error,
  }) = _ActiveSessionState;
  const ActiveSessionState._();

  List<TaskModel> get ungroupedTasks =>
      tasks.where((TaskModel task) => task.goalId == null).toList();

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

  List<TaskModel> get deleteTasks {
    return allOriginalTasks.where((task) {
      return taskIdsToDelete.contains(task.id.toString());
    }).toList();
  }

  List<GoalModel> get deleteGoals {
    return allOriginalGoals.where((goal) {
      return goalIdsToDelete.contains(goal.id.toString());
    }).toList();
  }
}
