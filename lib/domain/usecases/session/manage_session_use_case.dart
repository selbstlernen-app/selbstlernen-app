import 'package:srl_app/core/services/notification_service.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/repositories/session_repository.dart';

/// Use case handling all CRUD operations for session repository
class ManageSessionUseCase {
  const ManageSessionUseCase(this.repository);

  final SessionRepository repository;

  // Create
  Future<int> createSession(SessionModel session) async {
    final sessionId = await repository.addSession(session);

    // (Re-)Schedule notifications
    await NotificationService().scheduleSessionNotification(
      sessionId: sessionId,
      hasNotification: session.hasNotification,
      isRepeating: session.isRepeating,
      plannedTime: session.plannedTime,
      sessionTitle: session.title,
      selectedDays: session.selectedDays,
      startDate: session.startDate,
      endDate: session.endDate,
    );

    return sessionId;
  }

  Stream<SessionModel> watchSessionById(int sessionId) =>
      repository.watchSessionById(sessionId);

  Stream<List<SessionModel>> watchAllSessions() =>
      repository.watchAllSessions();

  Stream<List<SessionModel>> watchAllActiveSessions() =>
      repository.watchAllActiveSessions();

  Future<SessionModel> getSessionById(int sessionId) =>
      repository.getSessionById(sessionId);

  // Update
  Future<int> updateSession(int sessionId, SessionModel updatedSession) async {
    await NotificationService().scheduleSessionNotification(
      sessionId: sessionId,
      hasNotification: updatedSession.hasNotification,
      isRepeating: updatedSession.isRepeating,
      plannedTime: updatedSession.plannedTime,
      sessionTitle: updatedSession.title,
      selectedDays: updatedSession.isRepeating
          ? updatedSession.selectedDays
          : null,
      startDate: updatedSession.isRepeating ? updatedSession.startDate : null,
      endDate: updatedSession.isRepeating ? updatedSession.endDate : null,
    );

    return repository.updateSession(sessionId, updatedSession);
  }
}
