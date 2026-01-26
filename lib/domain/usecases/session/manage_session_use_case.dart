import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/session_repository.dart';

/// Use case handling all CRUD operations for session repository
class ManageSessionUseCase {
  const ManageSessionUseCase(this.repository);

  final SessionRepository repository;

  // Create
  Future<int> createSession(SessionModel task) => repository.addSession(task);

  // Read
  Future<List<SessionModel>> getAllSessions() => repository.getAllSessions();

  Stream<List<SessionModel>> watchAllSessions() =>
      repository.watchAllSessions();

  Stream<List<SessionModel>> watchAllActiveSessionsForDate(DateTime day) =>
      repository.watchAllActiveSessionsForDate(day);

  Future<SessionModel> getSessionById(int sessionId) =>
      repository.getSessionById(sessionId);

  // Update
  Future<int> updateSession(int sessionId, SessionModel updatedSession) =>
      repository.updateSession(sessionId, updatedSession);

  // Delete
  Future<void> deleteSession(int sessionId) =>
      repository.deleteSession(sessionId);
}
