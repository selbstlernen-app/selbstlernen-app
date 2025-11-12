import 'package:srl_app/domain/models/session_instance_model.dart';

/// Abstract repository class for the session instance repository
abstract class SessionInstanceRepository {
  // CRUD operations
  Future<SessionInstanceModel> getInstanceById(int sessionId);
  Stream<List<SessionInstanceModel>> watchInstancesBySessionId(int sessionId);
  Stream<SessionInstanceModel> watchInstanceById(int sessionInstanceId);
  Future<int> addInstance(SessionInstanceModel sessionInstance);
  Future<void> deleteInstanceBySessionId(int sessionId);
  Future<int> updateInstance(
    int sessionInstanceId,
    SessionInstanceModel updatedSessionInstance,
  );
}
