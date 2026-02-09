import 'package:srl_app/domain/models/session_model.dart';

/// Abstract repository class for the session repository
abstract class SessionRepository {
  // CRUD operations
  Future<List<SessionModel>> getAllSessions();

  Stream<List<SessionModel>> watchAllActiveSessions();
  Stream<List<SessionModel>> watchAllActiveSessionsForDate(DateTime day);
  Stream<List<SessionModel>> watchAllSessions();
  Stream<SessionModel> watchSessionById(int sessionId);

  Future<SessionModel> getSessionById(int sessionId);
  Future<int> addSession(SessionModel session);
  Future<void> deleteSession(int sessionId);
  Future<int> updateSession(int sessionId, SessionModel updatedSession);

  /// "Touches" the session, to solely udpating the updatedAt attribute
  Future<int> touchSession(int sessionId);
}
