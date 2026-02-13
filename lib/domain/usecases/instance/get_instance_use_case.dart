import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/repositories/session_instance_repository.dart';

/// Gets instances by different measures
class GetInstanceUseCase {
  const GetInstanceUseCase(this.repository);

  final SessionInstanceRepository repository;

  Stream<List<SessionInstanceModel>> watchInstancesBySessionId(int sessionId) =>
      repository.watchInstancesBySessionId(sessionId);

  Stream<List<SessionInstanceModel>> watchAllInstances() =>
      repository.watchAllInstances();

  Stream<SessionInstanceModel> watchSessionInstanceById(
    int sessionInstanceId,
  ) => repository.watchInstanceById(sessionInstanceId);

  Future<List<SessionInstanceModel>> getAllInstances() =>
      repository.getAllInstances();

  Future<SessionInstanceModel> getInstanceById(int sessionInstanceId) =>
      repository.getInstanceById(sessionInstanceId);

  Future<SessionInstanceModel?> getInstanceBySessionIdAndDate(
    int sessionId,
    DateTime date,
  ) => repository.getInstanceForDate(sessionId, date);

  Future<List<SessionInstanceModel>> getInstancesBySessionId(int sessionId) =>
      repository.getAllInstancesBySessionId(sessionId);
}
