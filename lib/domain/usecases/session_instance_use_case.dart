import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_instance_repository.dart';

class SessionInstanceUseCase {
  const SessionInstanceUseCase(this.repository);
  final SessionInstanceRepository repository;

  Stream<List<SessionInstanceModel>> watchAllSessionsInstancesFor(
    int sessionId,
  ) => repository.watchInstancesBySessionId(sessionId);

  Stream<SessionInstanceModel> watchSessionInstanceById(
    int sessionInstanceId,
  ) => repository.watchInstanceById(sessionInstanceId);

  Future<SessionInstanceModel> getSessionInstanceById(int sessionInstanceId) =>
      repository.getInstanceById(sessionInstanceId);

  Future<SessionInstanceModel> getInstanceBySessionIdAndDate(
    int sessionId,
    DateTime date,
  ) async {
    SessionInstanceModel? instance = await repository.getInstanceForDate(
      sessionId,
      date,
    );

    instance ??= await repository.createInstance(
      sessionId: sessionId,
      scheduledAt: DateTime.now(),
      status: SessionStatus.scheduled,
    );

    return instance;
  }
}
