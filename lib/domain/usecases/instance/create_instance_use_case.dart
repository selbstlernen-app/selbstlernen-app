import 'package:srl_app/core/utils/date_time_utils.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';

/// Use case for when creating a session (when completing a session; or when skipped)
class CreateInstanceUseCase {
  const CreateInstanceUseCase(this.repository, this.sessionRepo);

  final SessionInstanceRepository repository;
  final SessionRepository sessionRepo;

  Future<void> call(SessionInstanceModel instance) async {
    await repository.createInstance(instance: instance);

    // Check if session should be archived
    await _checkAndArchiveIfComplete(instance.sessionId);
  }

  Future<void> _checkAndArchiveIfComplete(String sessionId) async {
    final SessionModel session = await sessionRepo.getSessionById(
      int.parse(sessionId),
    );

    // One-time sessions: archive immediately
    if (!session.isRepeating) {
      await sessionRepo.updateSession(
        int.parse(session.id!),
        session.copyWith(isArchived: true),
      );
      return;
    }

    // Repeating sessions: check if all instances are done
    final int totalInstances = await repository.countTotalInstancesBySessionId(
      int.parse(session.id!),
    );

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
    }
  }
}
