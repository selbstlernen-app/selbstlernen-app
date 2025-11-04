import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/session_repository.dart';

class EditSessionUseCase {
  EditSessionUseCase(this.repository);
  final SessionRepository repository;

  Future<int> editSession(int sessionId, SessionModel updatedSession) {
    return repository.updateSession(sessionId, updatedSession);
  }

  Future<void> deleteSession(int sessionId) {
    return repository.deleteSession(sessionId);
  }
}
