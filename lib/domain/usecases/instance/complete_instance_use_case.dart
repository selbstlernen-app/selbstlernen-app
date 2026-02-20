import 'package:srl_app/core/services/notification_service.dart';
import 'package:srl_app/core/utils/date_time_utils.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/repositories/session_instance_repository.dart';
import 'package:srl_app/domain/repositories/session_repository.dart';

/// Completes a session instance
/// Either because a session has been conducted; or because
/// it has been skipped/missed
class CompleteInstanceUseCase {
  const CompleteInstanceUseCase(this.sessionRepo, this.instanceRepo);

  final SessionRepository sessionRepo;
  final SessionInstanceRepository instanceRepo;

  Future<void> call(SessionInstanceModel updatedInstance) async {
    await instanceRepo.updateInstance(
      int.parse(updatedInstance.id!),
      updatedInstance,
    );

    // Check if session should be archived
    await _checkAndArchiveIfComplete(updatedInstance.sessionId);
  }

  Future<void> _checkAndArchiveIfComplete(String sessionId) async {
    final session = await sessionRepo.getSessionById(
      int.parse(sessionId),
    );

    if (!session.isRepeating) {
      await sessionRepo.updateSession(
        int.parse(sessionId),
        session.copyWith(isArchived: true),
      );

      await NotificationService().cancelSpecificSessionNotifications(
        int.parse(sessionId),
      );

      return;
    }

    final totalInstances = await instanceRepo.countTotalInstancesBySessionId(
      int.parse(session.id!),
    );

    final expectedCount = DateTimeUtils.countDaysBetweenDates(
      session.startDate!,
      session.endDate!,
      session.selectedDays,
    );

    if (totalInstances >= expectedCount) {
      await sessionRepo.updateSession(
        int.parse(session.id!),
        session.copyWith(isArchived: true),
      );

      await NotificationService().cancelSpecificSessionNotifications(
        int.parse(sessionId),
      );
    }
  }
}
