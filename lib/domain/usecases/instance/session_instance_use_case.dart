import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_instance_repository.dart';

class SessionInstanceUseCase {
  const SessionInstanceUseCase(this.repository);
  final SessionInstanceRepository repository;

  Stream<List<SessionInstanceModel>> watchInstancesBySessionId(int sessionId) =>
      repository.watchInstancesBySessionId(sessionId);

  Stream<SessionInstanceModel> watchSessionInstanceById(
    int sessionInstanceId,
  ) => repository.watchInstanceById(sessionInstanceId);

  Future<SessionInstanceModel> getInstanceById(int sessionInstanceId) =>
      repository.getInstanceById(sessionInstanceId);

  Future<SessionInstanceModel?> getInstanceBySessionIdAndDate(
    int sessionId,
    DateTime date,
  ) => repository.getInstanceForDate(sessionId, date);
}
