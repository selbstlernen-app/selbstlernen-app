import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_instance_repository.dart';

class SessionInstanceUseCase {
  const SessionInstanceUseCase(this.repository);
  final SessionInstanceRepository repository;

  Stream<List<SessionInstanceModel>> watchAllSessionsInstancesFor(
    int sessionId,
  ) => repository.watchAllSessionsInstancesFor(sessionId);
}
