import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/tables/session_table.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: <Type>[Sessions])
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

  Future<List<Session>> getAllActiveSessions() {
    return (select(
      sessions,
    )..where(($SessionsTable tbl) => tbl.isArchived.equals(false))).get();
  }

  // Watch all sessions which not archived yet
  Stream<List<Session>> watchAllActiveSessions() {
    return (select(
      sessions,
    )..where(($SessionsTable s) => s.isArchived.equals(false))).watch();
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
  Future<int> updateSession(int id, SessionsCompanion companion) async {
    return (update(
      sessions,
    )..where(($SessionsTable tbl) => tbl.id.equals(id))).write(companion);
  }

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
}
