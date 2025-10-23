import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/tables/session_table.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: [Sessions])
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
  Stream<Session?> getSessionById(int id) {
    return (select(
      sessions,
    )..where((s) => s.id.equals(id))).watchSingleOrNull();
  }

  // Update session
  Future<int> updateSession(int id, SessionsCompanion companion) async {
    return (update(
      sessions,
    )..where((tbl) => tbl.id.equals(id))).write(companion);
  }

  // Delete session
  Future<int> deleteSession(int id) async {
    return await (delete(sessions)..where((s) => s.id.equals(id))).go();
  }
}
