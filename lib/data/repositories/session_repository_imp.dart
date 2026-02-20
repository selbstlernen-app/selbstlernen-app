import 'package:srl_app/data/database/daos/learning_strategy_dao.dart';
import 'package:srl_app/data/database/daos/session_dao.dart';
import 'package:srl_app/data/entity_mappers/session_mapper.dart';
import 'package:srl_app/data/entity_mappers/strategy_mapper.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/repositories/session_repository.dart';

class SessionRepositoryImp implements SessionRepository {
  SessionRepositoryImp(
    this.sessionDao,
    this.learningStrategyDao,
  );

  final SessionDao sessionDao;
  final LearningStrategyDao learningStrategyDao;

  @override
  Future<int> addSession(SessionModel session) {
    if (session.learningStrategyIds.isNotEmpty) {
      return sessionDao.createSessionWithLinks(
        session.toCompanion(),
        session.learningStrategyIds,
      );
    }
    return sessionDao.addSession(session.toCompanion());
  }

  @override
  Future<void> deleteSession(int sessionId) {
    return sessionDao.deleteSession(sessionId);
  }

  @override
  Future<List<SessionModel>> getAllSessions() async {
    final sessions = await sessionDao.getAllSessions();

    // Get strategy IDs for each session
    final result = <SessionModel>[];
    for (final session in sessions) {
      final strategyIds = await sessionDao.getStrategyIdsForSession(session.id);
      result.add(session.toDomain(strategyIds));
    }

    return SessionToModelMapper.mapFromListOfEntity(sessions);
  }

  @override
  Stream<List<SessionModel>> watchAllActiveSessions() {
    return sessionDao.watchAllActiveSessions().asyncMap((sessions) async {
      final result = <SessionModel>[];
      for (final session in sessions) {
        final strategyIds = await sessionDao.getStrategyIdsForSession(
          session.id,
        );
        result.add(session.toDomain(strategyIds));
      }
      return result;
    });
  }

  @override
  Stream<List<SessionModel>> watchAllActiveSessionsForDate(DateTime day) {
    return sessionDao.watchAllActiveSessionsForDate(day).asyncMap((
      sessions,
    ) async {
      final result = <SessionModel>[];
      for (final session in sessions) {
        final strategyIds = await sessionDao.getStrategyIdsForSession(
          session.id,
        );
        result.add(session.toDomain(strategyIds));
      }
      return result;
    });
  }

  @override
  Stream<List<SessionModel>> watchAllSessions() {
    return sessionDao.watchAllSessions().asyncMap((sessions) async {
      final result = <SessionModel>[];
      for (final session in sessions) {
        final strategyIds = await sessionDao.getStrategyIdsForSession(
          session.id,
        );
        result.add(session.toDomain(strategyIds));
      }
      return result;
    });
  }

  @override
  Future<SessionModel> getSessionById(int sessionId) async {
    final session = await sessionDao.getSessionById(sessionId);
    if (session == null) {
      throw Exception('Session with ID $sessionId not found.');
    }

    final strategyIds = await sessionDao.getStrategyIdsForSession(sessionId);
    return session.toDomain(strategyIds);
  }

  @override
  Stream<SessionModel> watchSessionById(int sessionId) {
    return sessionDao.watchSessionById(sessionId).asyncMap((session) async {
      if (session == null) {
        throw Exception('Session with ID $sessionId not found.');
      }

      final strategyIds = await sessionDao.getStrategyIdsForSession(sessionId);
      return session.toDomain(strategyIds);
    });
  }

  @override
  Future<int> updateSession(int sessionId, SessionModel updatedSession) async {
    final validStrategies = await learningStrategyDao.getAllStrats();
    final validIds = validStrategies.map((s) => s.id).toSet();

    // Filter strategy IDs to ensure they still exist
    final filteredIds = updatedSession.learningStrategyIds
        .where(validIds.contains)
        .toList();

    return sessionDao
        .updateSessionWithLinks(
          sessionId,
          updatedSession.toUpdateCompanion(),
          filteredIds,
        )
        .then((success) => success ? 1 : 0);
  }

  @override
  Future<int> touchSession(int sessionId) {
    return sessionDao.touchSession(sessionId);
  }

  @override
  Stream<List<LearningStrategyModel>> watchLearningStrategiesForSession(
    int sessionId,
  ) {
    return sessionDao
        .watchStrategiesForSession(sessionId)
        .map(
          LearningStrategyToModel.mapFromListOfEntity,
        );
  }
}
