import 'package:srl_app/domain/models/session_instance_model.dart';

/// Abstract repository class for the session instance repository
abstract class SessionInstanceRepository {
  // CRUD operations
  Future<int> createInstance({required SessionInstanceModel instance});

  Future<SessionInstanceModel> getInstanceById(int instanceId);
  Future<SessionInstanceModel?> getInstanceBySessionId(int sessionId);
  Future<List<SessionInstanceModel>> getAllInstancesBySessionId(int sessionId);
  Future<List<SessionInstanceModel>> getAllInstances();

  Stream<List<SessionInstanceModel>> watchInstancesBySessionId(int sessionId);
  Stream<SessionInstanceModel> watchInstanceById(int sessionInstanceId);
  Stream<List<SessionInstanceModel>> watchAllInstancesForDate(DateTime date);

  Future<int> updateInstance(
    int sessionInstanceId,
    SessionInstanceModel updatedSessionInstance,
  );
  Future<void> deleteInstanceBySessionId(int sessionId);
  Future<void> deleteInstanceById(int instanceId);

  // Date-related queries
  Future<SessionInstanceModel?> getInstanceForDate(
    int sessionId,
    DateTime date,
  );

  Future<int> countTotalInstancesBySessionId(int sessionId);
}
