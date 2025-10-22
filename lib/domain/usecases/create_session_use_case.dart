import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/session_repository.dart';

class CreateSessionUseCase {
  CreateSessionUseCase(this.repository);
  final SessionRepository repository;

  Future<int> createSession(SessionModel session) {
    if (session.title.isEmpty) {
      throw Exception('Session title cannot be empty');
    }
    return repository.addSession(session);
  }
}
