import 'package:srl_app/domain/models/session_instance_model.dart';

/// Abstract repository class for the session instance repository
/// Can be implemented for local/remote data access
abstract class SessionInstanceRepository {
  Stream<List<SessionInstanceModel>> watchAllSessionsInstancesFor(
    int sessionId,
  );
  Future<int> addSessionInstance(SessionInstanceModel sessionInstance);
  Future<void> deleteSessionInstance(int sessionId);
  Future<SessionInstanceModel> getSessionInstanceById(int sessionId);
}
