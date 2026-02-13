import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/tables/learning_strategy/learning_strategy_table.dart';
import 'package:srl_app/data/database/tables/learning_strategy/session_strategy_table.dart';
import 'package:srl_app/data/database/tables/session_table.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: <Type>[Sessions, SessionStrategies, LearningStrategies])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.attachedDatabase);

  // Insert session
  Future<int> addSession(SessionsCompanion session) async {
    return into(sessions).insert(session);
  }

  // Get all sessions
  Future<List<Session>> getAllSessions() {
    return select(sessions).get();
  }

  // Watch all sessions
  Stream<List<Session>> watchAllSessions() {
    return select(sessions).watch();
  }

  // Watch all active sessions
  Stream<List<Session>> watchAllActiveSessions() {
    return (select(
          sessions,
        )..where(
          ($SessionsTable s) =>
              // Session is not archived
              (s.isArchived.equals(false)),
        ))
        .watch();
  }

  // Watch all sessions which not archived yet
  Stream<List<Session>> watchAllActiveSessionsForDate(DateTime today) {
    return (select(
          sessions,
        )..where(
          ($SessionsTable s) =>
              // Session is not archived
              (s.isArchived.equals(false))
              // Start date is not given (one-time session)
              // or smaller than today
              &
              (s.startDate.isNull() | s.startDate.isSmallerOrEqualValue(today))
              // End date is not given (one-time session) or larger than today
              &
              (s.endDate.isNull() | s.endDate.isBiggerOrEqualValue(today)),
        ))
        .watch();
  }

  // Get session by ID
  Future<Session?> getSessionById(int id) {
    return (select(
      sessions,
    )..where(($SessionsTable s) => s.id.equals(id))).getSingleOrNull();
  }

  // Watch session by ID
  Stream<Session?> watchSessionById(int id) {
    return (select(
      sessions,
    )..where(($SessionsTable s) => s.id.equals(id))).watchSingleOrNull();
  }

  // Update session
  // Future<int> updateSession(int id, SessionsCompanion companion) async {
  //   return (update(
  //     sessions,
  //   )..where(($SessionsTable tbl) => tbl.id.equals(id))).write(companion);
  // }

  // Delete session
  Future<int> deleteSession(int id) async {
    return (delete(
      sessions,
    )..where(($SessionsTable s) => s.id.equals(id))).go();
  }

  Future<int> touchSession(int id) async {
    return (update(sessions)..where((s) => s.id.equals(id))).write(
      SessionsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  // Get strategy IDs for a session
  Future<List<int>> getStrategyIdsForSession(int sessionId) async {
    final links = await (select(
      sessionStrategies,
    )..where((s) => s.sessionId.equals(sessionId))).get();
    return links.map((link) => link.strategyId).toList();
  }

  // Watch a learning strategy for a session
  Stream<List<LearningStrategy>> watchStrategiesForSession(int sessionId) {
    final query = select(learningStrategies).join([
      innerJoin(
        sessionStrategies,
        sessionStrategies.strategyId.equalsExp(learningStrategies.id),
      ),
    ])..where(sessionStrategies.sessionId.equals(sessionId));

    return query.watch().map((rows) {
      return rows.map((row) => row.readTable(learningStrategies)).toList();
    });
  }

  // Clear all strategy links for a session
  Future<void> clearStrategyLinksForSession(int sessionId) async {
    await (delete(
      sessionStrategies,
    )..where((s) => s.sessionId.equals(sessionId))).go();
  }

  // Batch insert strategy links
  Future<void> insertStrategyLinks(
    int sessionId,
    List<int> strategyIds,
  ) async {
    if (strategyIds.isEmpty) return;

    await batch((batch) {
      batch.insertAll(
        sessionStrategies,
        strategyIds.map(
          (strategyId) => SessionStrategiesCompanion.insert(
            sessionId: sessionId,
            strategyId: strategyId,
          ),
        ),
      );
    });
  }

  // Transaction: Create session with strategy links
  Future<int> createSessionWithLinks(
    SessionsCompanion session,
    List<int> strategyIds,
  ) async {
    return transaction(() async {
      final sessionId = await into(sessions).insert(session);

      if (strategyIds.isNotEmpty) {
        await insertStrategyLinks(sessionId, strategyIds);
      }

      return sessionId;
    });
  }

  // Transaction: Update session with strategy links
  Future<bool> updateSessionWithLinks(
    int sessionId,
    SessionsCompanion session,
    List<int> strategyIds,
  ) async {
    return transaction(() async {
      final updated = await (update(
        sessions,
      )..where((s) => s.id.equals(sessionId))).write(session);

      if (updated == 0) return false;

      // Clear old links
      await clearStrategyLinksForSession(sessionId);

      // Insert new links
      if (strategyIds.isNotEmpty) {
        await insertStrategyLinks(sessionId, strategyIds);
      }

      return true;
    });
  }
}

// Helper classes for DAO results
class SessionStrategyLink {
  SessionStrategyLink({
    required this.instanceStrategy,
    required this.learningStrategy,
  });
  final SessionInstanceStrategy instanceStrategy;
  final LearningStrategy learningStrategy;
}
