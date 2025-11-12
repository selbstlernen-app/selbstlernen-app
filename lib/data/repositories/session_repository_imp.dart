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
    return sessionDao.deleteSession(sessionId);
  }

  @override
  Stream<List<SessionModel>> getAllSessions() {
    return sessionDao.watchAllSessions().map(
      (List<Session> sessionList) =>
          SessionToModelMapper.mapFromListOfEntity(sessionList),
    );
  }

  @override
  Stream<List<SessionModel>> watchAllActiveSessions() {
    return sessionDao.watchAllActiveSessions().map(
      (List<Session> sessionList) =>
          SessionToModelMapper.mapFromListOfEntity(sessionList),
    );
  }

  @override
  Future<SessionModel> getSessionById(int sessionId) async {
    final Session? sessionEntity = await sessionDao.getSessionById(sessionId);

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
}
