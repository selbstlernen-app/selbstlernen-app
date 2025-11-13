import 'package:srl_app/core/utils/date_time_utils.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';

/// "Completes" a session instance this can be either because a session has been conducted
/// or a session has been skipped/missed
class CompleteInstanceUseCase {
  const CompleteInstanceUseCase(this.sessionRepo, this.instanceRepo);

  final SessionRepository sessionRepo;
  final SessionInstanceRepository instanceRepo;

  Future<void> call(SessionInstanceModel updatedInstance) async {
    print("update instance w id: ");
    print(updatedInstance.id);
    print("session id: ");
    print(updatedInstance.sessionId);
    await instanceRepo.updateInstance(
      int.parse(updatedInstance.id!),
      updatedInstance,
    );

    // Get parent session
    final session = await sessionRepo.getSessionById(
      int.parse(updatedInstance.sessionId),
    );

    if (!session.isRepeating) {
      // Archive if non-repeating (one-time)
      await sessionRepo.updateSession(
        int.parse(session.id!),
        session.copyWith(isArchived: true),
      );
      return;
    }

    // If repeating, count all instances and check if it matches expected instances
    final int totalInstances = await instanceRepo
        .countTotalInstancesBySessionId(int.parse(session.id!));

    print("did total instance schange? ");
    print(totalInstances);

    final int expectedCount = DateTimeUtils.countDaysBetweenDates(
      session.startDate!,
      session.endDate!,
      session.selectedDays,
    );

    print("did any change? ");
    print(expectedCount);

    // Archive if all expected ones are present in db
    if (totalInstances >= expectedCount) {
      await sessionRepo.updateSession(
        int.parse(session.id!),
        session.copyWith(isArchived: true),
      );
    }
  }
}
