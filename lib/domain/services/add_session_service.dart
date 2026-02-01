import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/core/services/notification_service.dart';

/// Service class to help centralize logic for mulitple use cases needed
/// for the creation or update of a session
class AddSessionService {
  AddSessionService({
    required ManageSessionUseCase manageSessionUseCase,
    required ManageGoalUseCase manageGoalUseCase,
    required ManageTasksUseCase manageTasksUseCase,
  }) : _manageSessionUseCase = manageSessionUseCase,
       _manageGoalUseCase = manageGoalUseCase,
       _manageTasksUseCase = manageTasksUseCase;
  final ManageSessionUseCase _manageSessionUseCase;
  final ManageGoalUseCase _manageGoalUseCase;
  final ManageTasksUseCase _manageTasksUseCase;

  /// Creates a new session with associated goals and tasks
  /// Returns the created session ID
  Future<int> createSessionWithGoalsAndTasks({
    required SessionModel session,
    required List<GoalModel> goals,
    required List<TaskModel> tasks,
  }) async {
    final sessionId = await _manageSessionUseCase.createSession(session);

    final goalIdMapping = await _createGoals(goals, sessionId);
    await _createTasks(tasks, sessionId, goalIdMapping);

    // (Re-)Schedule notifications
    await NotificationService().scheduleSessionNotification(
      sessionId: sessionId,
      hasNotification: session.hasNotification,
      isRepeating: session.isRepeating,
      plannedTime: session.plannedTime,
      sessionTitle: session.title,
      selectedDays: session.selectedDays,
      startDate: session.startDate,
      endDate: session.endDate,
    );

    return sessionId;
  }

  /// Updates an existing session with all changes
  Future<void> updateSessionWithChanges({
    required int sessionId,
    required SessionModel session,
    required List<GoalModel> goalsToUpdate,
    required List<TaskModel> tasksToUpdate,
    required Set<String> goalIdsToDelete,
    required Set<String> taskIdsToDelete,
  }) async {
    // Delete marked goals/tasks
    await _deleteGoals(goalIdsToDelete);
    await _deleteTasks(taskIdsToDelete);

    // Separate into existing and new goasl/tasks
    final goals = separateGoals(goalsToUpdate);
    final tasks = separateTasks(tasksToUpdate);

    // Update session and goals
    await _manageSessionUseCase.updateSession(sessionId, session);
    await _updateExistingGoals(goals.existingGoals);

    // (Re-)Schedule notifications
    await NotificationService().scheduleSessionNotification(
      sessionId: sessionId,
      hasNotification: session.hasNotification,
      isRepeating: session.isRepeating,
      plannedTime: session.plannedTime,
      sessionTitle: session.title,
      selectedDays: session.selectedDays,
      startDate: session.startDate,
      endDate: session.endDate,
    );

    // Create new goals
    final goalIdMapping = await _createGoals(
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
    final goalIdMapping = <String, int>{};

    for (final goal in goals) {
      final goalWithSession = goal.copyWith(
        sessionId: sessionId.toString(),
      );
      final dbGoalId = await _manageGoalUseCase.createGoal(goalWithSession);

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
    for (final task in tasks) {
      // Replace temporary goal ID with actual DB ID if needed
      var actualGoalId = task.goalId;
      if (task.goalId != null && goalIdMapping.containsKey(task.goalId)) {
        actualGoalId = goalIdMapping[task.goalId].toString();
      }

      final taskWithSession = task.copyWith(
        sessionId: sessionId.toString(),
        goalId: actualGoalId,
      );
      await _manageTasksUseCase.createTask(taskWithSession);
    }
  }

  Future<void> _updateExistingGoals(List<GoalModel> goals) async {
    for (final goal in goals) {
      await _manageGoalUseCase.updateGoal(goal);
    }
  }

  Future<void> _updateExistingTasks(List<TaskModel> tasks) async {
    for (final task in tasks) {
      await _manageTasksUseCase.updateTask(task);
    }
  }

  Future<void> _deleteGoals(Set<String> goalIds) async {
    for (final goalId in goalIds) {
      await _manageGoalUseCase.deleteGoal(int.parse(goalId));
    }
  }

  Future<void> _deleteTasks(Set<String> taskIds) async {
    for (final taskId in taskIds) {
      await _manageTasksUseCase.deleteTask(int.parse(taskId));
    }
  }

  /// Helper to check if an ID is from the database (numeric) or
  /// temporary (UUID)
  static bool isExistingItem(String? id) {
    if (id == null) return false;
    return int.tryParse(id) != null;
  }

  /// Separate goals into existing and new based on ID type
  static ({List<GoalModel> existingGoals, List<GoalModel> newGoals})
  separateGoals(List<GoalModel> goals) {
    final existing = goals
        .where((GoalModel g) => isExistingItem(g.id))
        .toList();
    final newGoals = goals
        .where((GoalModel g) => !isExistingItem(g.id))
        .toList();
    return (existingGoals: existing, newGoals: newGoals);
  }

  /// Separate tasks into existing and new based on ID type
  static ({List<TaskModel> existingTasks, List<TaskModel> newTasks})
  separateTasks(List<TaskModel> tasks) {
    final existing = tasks
        .where((TaskModel t) => isExistingItem(t.id))
        .toList();
    final newTasks = tasks
        .where((TaskModel t) => !isExistingItem(t.id))
        .toList();
    return (existingTasks: existing, newTasks: newTasks);
  }
}
