import 'package:srl_app/core/utils/date_time_utils.dart';
import 'package:srl_app/domain/goal_repository.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';
import 'package:srl_app/domain/task_repository.dart';

/// Completes a session instance
/// Either because a session has been conducted; or because
/// it has been skipped/missed
class CompleteInstanceUseCase {
  const CompleteInstanceUseCase(
    this.sessionRepo,
    this.instanceRepo,
    this.taskRepository,
    this.goalRepository,
  );

  final SessionRepository sessionRepo;
  final SessionInstanceRepository instanceRepo;
  final TaskRepository taskRepository;
  final GoalRepository goalRepository;

  Future<void> call(
    SessionInstanceModel updatedInstance,
    Set<String> completedGoalIds,
    Set<String> completedTaskIds,
  ) async {
    await instanceRepo.updateInstance(
      int.parse(updatedInstance.id!),
      updatedInstance,
    );

    // Check if session should be archived
    await _checkAndArchiveIfComplete(
      updatedInstance.sessionId,
      completedGoalIds,
      completedTaskIds,
    );
  }

  Future<void> _checkAndArchiveIfComplete(
    String sessionId,
    Set<String> completedGoalIds,
    Set<String> completedTaskIds,
  ) async {
    final SessionModel session = await sessionRepo.getSessionById(
      int.parse(sessionId),
    );

    if (!session.isRepeating) {
      await sessionRepo.updateSession(
        int.parse(session.id!),
        session.copyWith(isArchived: true),
      );

      await _completeTasksAndGoals(completedGoalIds, completedTaskIds);

      return;
    }

    final int totalInstances = await instanceRepo
        .countTotalInstancesBySessionId(int.parse(session.id!));

    final int expectedCount = DateTimeUtils.countDaysBetweenDates(
      session.startDate!,
      session.endDate!,
      session.selectedDays,
    );

    if (totalInstances >= expectedCount) {
      await sessionRepo.updateSession(
        int.parse(session.id!),
        session.copyWith(isArchived: true),
      );

      await _completeTasksAndGoals(completedGoalIds, completedTaskIds);
    }
  }

  Future<void> _completeTasksAndGoals(
    Set<String> goalIds,
    Set<String> taskIds,
  ) async {
    for (String id in goalIds) {
      await goalRepository.updateGoalCompleted(int.parse(id), true);
    }

    for (String id in taskIds) {
      await taskRepository.updateTaskCompleted(int.parse(id), true);
    }
  }
}
