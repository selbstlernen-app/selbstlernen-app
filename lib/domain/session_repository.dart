import 'package:srl_app/domain/models/session_model.dart';

/// Abstract repository class for the session repository
/// Can be implemented for local/remote data access
abstract class SessionRepository {
  Stream<List<SessionModel>> getAllSessions();
  Future<int> addSession(SessionModel session);
  Future deleteSession(int sessionId);
  Stream<SessionModel?> getSession(int sessionId);
  Future<int> updateSession(int sessionId, SessionModel updatedSession);
}
