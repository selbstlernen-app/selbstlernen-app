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

    // The time stamp marking the last time app was on actively on foreground
    DateTime? lastActiveTimestamp,

    // Goals and tasks that are displayed in the session
    @Default(<GoalModel>[]) List<GoalModel> goals,
    @Default(<TaskModel>[]) List<TaskModel> tasks,

    // Original goals and tasks to be compared at the end of a session
    @Default(<GoalModel>[]) List<GoalModel> allOriginalGoals,
    @Default(<TaskModel>[]) List<TaskModel> allOriginalTasks,

    // Current session phase
    @Default(SessionPhase.focus) SessionPhase currentPhase,

    // Current timer status
    @Default(TimerStatus.initial) TimerStatus timerStatus,

    // Remaining seconds of the current phase
    @Default(0) int remainingSeconds,

    // Total focus seconds that have currently elapsed
    @Default(0) int totalFocusSecondsElapsed,

    // Total short break seconds that have currently elapsed
    @Default(0) int totalBreakSecondsElapsed,

    // Total long break seconds that have currently elapsed
    @Default(0) int totalLongBreakSecondsElapsed,

    // Total focus phases that were completed
    @Default(0) int totalFocusPhases,

    // Total blocks that were completed
    @Default(0) int completedBlocks,

    // The current phase seconds elaphsed; used for counting upwards
    @Default(0) int currentPhaseElapsed,

    // Index of a current phase; used for visual display
    @Default(0) int currentPhaseIndex,

    // Check which goal is currently expanded if any
    @Default(null) String? expandedGoalId,

    // Goal and task completion tracking
    @Default(<String>{}) Set<String> completedGoalIds,
    @Default(<String>{}) Set<String> completedTaskIds,

    // Keep track of ids to delete
    @Default(<String>[]) List<String> goalIdsToDelete,
    @Default(<String>[]) List<String> taskIdsToDelete,

    // Flag to enable edit mode
    @Default(false) bool isEditMode,

    // Flag to change the visual timer count
    @Default(false) bool countUpwards,

    // Toggle focus prompt
    @Default(false) bool showFocusPrompt,

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

  List<TaskModel> get deleteTasks => allOriginalTasks
      .where((TaskModel task) => taskIdsToDelete.contains(task.id))
      .toList();

  List<GoalModel> get deleteGoals => allOriginalGoals
      .where((GoalModel goal) => goalIdsToDelete.contains(goal.id))
      .toList();
}
