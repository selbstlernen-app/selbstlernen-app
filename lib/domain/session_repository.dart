import 'package:srl_app/domain/models/session_model.dart';

/// Abstract repository class for the session repository
abstract class SessionRepository {
  // CRUD operations
  Stream<List<SessionModel>> getAllSessions();
  Future<List<SessionModel>> getAllActiveSessions();
  Stream<List<SessionModel>> watchAllActiveSessions();
  Future<SessionModel> getSessionById(int sessionId);
  Stream<SessionModel> watchSessionById(int sessionId);
  Future<int> addSession(SessionModel session);
  Future<void> deleteSession(int sessionId);
  Future<int> updateSession(int sessionId, SessionModel updatedSession);
}
