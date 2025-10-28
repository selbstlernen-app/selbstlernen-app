import 'package:srl_app/domain/models/session_model.dart';

/// Abstract repository class for the session repository
/// Can be implemented for local/remote data access
abstract class SessionRepository {
  Stream<List<SessionModel>> getAllSessions();
  Future<int> addSession(SessionModel session);
  Future<void> deleteSession(int sessionId);
  Future<SessionModel> getSessionById(int sessionId);
  Future<int> updateSession(int sessionId, SessionModel updatedSession);
}
