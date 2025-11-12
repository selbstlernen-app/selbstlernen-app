import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';

class EditSessionInstanceUseCase {
  EditSessionInstanceUseCase(this.repository, this.sessionRepository);
  final SessionInstanceRepository repository;
  final SessionRepository sessionRepository;

  Future<int> updateInstance(
    int sessionInstanceId,
    SessionInstanceModel updatedSession,
  ) async {
    return repository.updateSessionInstance(sessionInstanceId, updatedSession);
  }

  Future<void> deleteSession(int sessionId) {
    return repository.deleteSessionInstance(sessionId);
  }
}
