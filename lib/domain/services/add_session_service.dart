import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';

/// Service class to help centralize logic for mulitple use cases needed
/// for the creation or update of a session
class AddSessionService {
  final CreateSessionUseCase _createSessionUseCase;
  final CreateGoalsUseCase _createGoalsUseCase;
  final CreateTasksUseCase _createTasksUseCase;
  final EditSessionUseCase _editSessionUseCase;
  final EditGoalsUseCase _editGoalsUseCase;
  final EditTasksUseCase _editTasksUseCase;

  AddSessionService({
    required CreateSessionUseCase createSessionUseCase,
    required CreateGoalsUseCase createGoalsUseCase,
    required CreateTasksUseCase createTasksUseCase,
    required EditSessionUseCase editSessionUseCase,
    required EditGoalsUseCase editGoalsUseCase,
    required EditTasksUseCase editTasksUseCase,
  }) : _createSessionUseCase = createSessionUseCase,
       _createGoalsUseCase = createGoalsUseCase,
       _createTasksUseCase = createTasksUseCase,
       _editSessionUseCase = editSessionUseCase,
       _editGoalsUseCase = editGoalsUseCase,
       _editTasksUseCase = editTasksUseCase;

  /// Creates a new session with associated goals and tasks
  /// Returns the created session ID
  Future<int> createSessionWithGoalsAndTasks({
    required SessionModel session,
    required List<GoalModel> goals,
    required List<TaskModel> tasks,
  }) async {
    final int sessionId = await _createSessionUseCase.call(session);

    final Map<String, int> goalIdMapping = await _createGoals(goals, sessionId);
    await _createTasks(tasks, sessionId, goalIdMapping);

    return sessionId;
  }

  /// Updates an existing session with all changes
  Future<void> updateSessionWithChanges({
    required int sessionId,
    required SessionModel session,
    required List<GoalModel> goalsToUpdate,
    required List<TaskModel> tasksToUpdate,
    required List<String> goalIdsToDelete,
    required List<String> taskIdsToDelete,
  }) async {
    // Delete marked goals/tasks
    await _deleteGoals(goalIdsToDelete);
    await _deleteTasks(taskIdsToDelete);

    // Separate into existing and new goasl/tasks
    final ({List<GoalModel> existingGoals, List<GoalModel> newGoals}) goals =
        separateGoals(goalsToUpdate);
    final ({List<TaskModel> existingTasks, List<TaskModel> newTasks}) tasks =
        separateTasks(tasksToUpdate);

    // Update session and goals
    await _editSessionUseCase.editSession(sessionId, session);
    await _updateExistingGoals(goals.existingGoals);

    // Create new goals
    final Map<String, int> goalIdMapping = await _createGoals(
      goals.newGoals,
      sessionId,
    );

    // Update tasks and create new ones with corrected goal references
    await _updateExistingTasks(tasks.existingTasks);
    await _createTasks(tasks.newTasks, sessionId, goalIdMapping);
  }

  Future<Map<String, int>> _createGoals(
    List<GoalModel> goals,
    int sessionId,
  ) async {
    final Map<String, int> goalIdMapping = <String, int>{};

    for (final GoalModel goal in goals) {
      final GoalModel goalWithSession = goal.copyWith(
        sessionId: sessionId.toString(),
      );
      final int dbGoalId = await _createGoalsUseCase.call(goalWithSession);

      // Map temporary ID to actual DB ID
      if (goal.id != null) {
        goalIdMapping[goal.id!] = dbGoalId;
      }
    }

    return goalIdMapping;
  }

  Future<void> _createTasks(
    List<TaskModel> tasks,
    int sessionId,
    Map<String, int> goalIdMapping,
  ) async {
    for (final TaskModel task in tasks) {
      // Replace temporary goal ID with actual DB ID if needed
      String? actualGoalId = task.goalId;
      if (task.goalId != null && goalIdMapping.containsKey(task.goalId)) {
        actualGoalId = goalIdMapping[task.goalId].toString();
      }

      final TaskModel taskWithSession = task.copyWith(
        sessionId: sessionId.toString(),
        goalId: actualGoalId,
      );
      await _createTasksUseCase.call(taskWithSession);
    }
  }

  Future<void> _updateExistingGoals(List<GoalModel> goals) async {
    for (final GoalModel goal in goals) {
      await _editGoalsUseCase.updateGoal(goal);
    }
  }

  Future<void> _updateExistingTasks(List<TaskModel> tasks) async {
    for (final TaskModel task in tasks) {
      await _editTasksUseCase.updateTask(task);
    }
  }

  Future<void> _deleteGoals(List<String> goalIds) async {
    for (final String goalId in goalIds) {
      await _editGoalsUseCase.deleteGoal(int.parse(goalId));
    }
  }

  Future<void> _deleteTasks(List<String> taskIds) async {
    for (final String taskId in taskIds) {
      await _editTasksUseCase.deleteTask(int.parse(taskId));
    }
  }

  /// Helper to check if an ID is from the database (numeric) or temporary (UUID)
  static bool isExistingItem(String? id) {
    if (id == null) return false;
    return int.tryParse(id) != null;
  }

  /// Separate goals into existing and new based on ID type
  static ({List<GoalModel> existingGoals, List<GoalModel> newGoals})
  separateGoals(List<GoalModel> goals) {
    final List<GoalModel> existing = goals
        .where((GoalModel g) => isExistingItem(g.id))
        .toList();
    final List<GoalModel> newGoals = goals
        .where((GoalModel g) => !isExistingItem(g.id))
        .toList();
    return (existingGoals: existing, newGoals: newGoals);
  }

  /// Separate tasks into existing and new based on ID type
  static ({List<TaskModel> existingTasks, List<TaskModel> newTasks})
  separateTasks(List<TaskModel> tasks) {
    final List<TaskModel> existing = tasks
        .where((TaskModel t) => isExistingItem(t.id))
        .toList();
    final List<TaskModel> newTasks = tasks
        .where((TaskModel t) => !isExistingItem(t.id))
        .toList();
    return (existingTasks: existing, newTasks: newTasks);
  }
}
