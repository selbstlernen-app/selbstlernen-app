import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/daos/session_dao.dart';
import 'package:srl_app/data/entity_mappers/session_mapper.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/session_repository.dart';

class SessionRepositoryImp implements SessionRepository {
  SessionRepositoryImp(this.sessionDao);

  final SessionDao sessionDao;

  @override
  Future<int> addSession(SessionModel session) {
    return sessionDao.addSession(session.toCompanion());
  }

  @override
  Future<void> deleteSession(int sessionId) {
    print("In repo session delete call rn!");
    return sessionDao.deleteSession(sessionId);
  }

  @override
  Future<List<SessionModel>> getAllSessions() async {
    final sessions = await sessionDao.getAllSessions();
    return SessionToModelMapper.mapFromListOfEntity(sessions);
  }

  @override
  Stream<List<SessionModel>> watchAllActiveSessions() {
    return sessionDao.watchAllActiveSessions().map(
      SessionToModelMapper.mapFromListOfEntity,
    );
  }

  @override
  Stream<List<SessionModel>> watchAllActiveSessionsForDate(DateTime day) {
    return sessionDao
        .watchAllActiveSessionsForDate(day)
        .map(
          SessionToModelMapper.mapFromListOfEntity,
        );
  }

  @override
  Stream<List<SessionModel>> watchAllSessions() {
    return sessionDao.watchAllSessions().map(
      SessionToModelMapper.mapFromListOfEntity,
    );
  }

  @override
  Future<SessionModel> getSessionById(int sessionId) async {
    final sessionEntity = await sessionDao.getSessionById(sessionId);

    if (sessionEntity == null) {
      throw Exception('Session with ID $sessionId not found.');
    }

    return sessionEntity.toDomain();
  }

  @override
  Stream<SessionModel> watchSessionById(int sessionId) {
    return sessionDao.watchSessionById(sessionId).map((Session? session) {
      if (session == null) {
        throw Exception('Session with ID $sessionId not found.');
      }
      return session.toDomain();
    });
  }

  @override
  Future<int> updateSession(int sessionId, SessionModel updatedSession) {
    return sessionDao.updateSession(
      sessionId,
      updatedSession.toUpdateCompanion(),
    );
  }

  @override
  Future<int> touchSession(int sessionId) {
    return sessionDao.touchSession(sessionId);
  }
}
