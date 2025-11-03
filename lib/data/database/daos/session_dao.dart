import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/tables/session_table.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: <Type>[Sessions])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  // Insert session
  Future<int> addSession(SessionsCompanion session) async {
    return await into(sessions).insert(session);
  }

  // Watch all sessions
  Stream<List<Session>> watchAllSessions() {
    return select(sessions).watch();
  }

  // Get session by ID
  Future<Session?> getSessionById(int id) {
    return (select(
      sessions,
    )..where(($SessionsTable s) => s.id.equals(id))).getSingleOrNull();
  }

  // Update session
  Future<int> updateSession(int id, SessionsCompanion companion) async {
    return (update(
      sessions,
    )..where(($SessionsTable tbl) => tbl.id.equals(id))).write(companion);
  }

  // Patch completed instances
  Future<void> incrementCompletedInstances(int id) async {
    await customUpdate(
      'UPDATE sessions SET completed_instances = completed_instances + 1 WHERE id = ?',
      variables: <Variable<int>>[Variable<int>(id)],
      updates: <$SessionsTable>{sessions},
    );
  }

  // Delete session
  Future<int> deleteSession(int id) async {
    return await (delete(
      sessions,
    )..where(($SessionsTable s) => s.id.equals(id))).go();
  }
}
