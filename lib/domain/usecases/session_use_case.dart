import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_repository.dart';

class SessionUseCase {
  const SessionUseCase(this.repository);
  final SessionRepository repository;

  Stream<List<SessionModel>> getAllSessions() {
    return repository.getAllSessions();
  }

  Stream<List<SessionModel>> getAllUncompletedSessions() {
    return repository.getAllSessionsNotCompletedYet();
  }
}
