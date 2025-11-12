import 'package:srl_app/domain/models/session_instance_model.dart';

/// Abstract repository class for the session instance repository
abstract class SessionInstanceRepository {
  // CRUD operations
  Future<SessionInstanceModel> getInstanceById(int sessionId);
  Stream<List<SessionInstanceModel>> watchInstancesBySessionId(int sessionId);
  Stream<SessionInstanceModel> watchInstanceById(int sessionInstanceId);
  Stream<List<SessionInstanceModel>> watchAllInstancesForDate(DateTime date);
  // TODO: delete add Instance
  Future<int> addInstance(SessionInstanceModel sessionInstance);

  Future<int> updateInstance(
    int sessionInstanceId,
    SessionInstanceModel updatedSessionInstance,
  );
  Future<void> deleteInstanceBySessionId(int sessionId);

  // Date-related queries
  Future<SessionInstanceModel> createInstance({
    required int sessionId,
    required DateTime scheduledAt,
    required SessionStatus status,
  });
  Future<SessionInstanceModel?> getInstanceForDate(
    int sessionId,
    DateTime date,
  );
}
