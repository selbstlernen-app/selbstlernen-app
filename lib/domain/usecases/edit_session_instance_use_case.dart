import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';

class EditSessionInstanceUseCase {
  EditSessionInstanceUseCase(this.repository, this.sessionRepository);
  final SessionInstanceRepository repository;
  final SessionRepository sessionRepository;

  Future<int> editSessionInstance(
    int sessionInstanceId,
    SessionInstanceModel updatedSession,
  ) async {
    final SessionInstanceModel oldInstance = await repository
        .getSessionInstanceById(sessionInstanceId);

    final bool wasCompleted = oldInstance.status == SessionStatus.completed;
    final bool isNowCompleted =
        updatedSession.status == SessionStatus.completed;
    // Ensure only once the session instance is getting updated
    if (!wasCompleted && isNowCompleted) {
      await sessionRepository.patchIncrementCompletedInstances(
        int.parse(updatedSession.sessionId),
      );
    }
    return repository.updateSessionInstance(sessionInstanceId, updatedSession);
  }

  Future<void> deleteSession(int sessionId) {
    return repository.deleteSessionInstance(sessionId);
  }
}
