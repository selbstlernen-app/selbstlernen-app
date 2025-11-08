import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/tables/session_instance_table.dart';

part 'session_instance_dao.g.dart';

@DriftAccessor(tables: <Type>[SessionInstances])
class SessionInstanceDao extends DatabaseAccessor<AppDatabase>
    with _$SessionInstanceDaoMixin {
  SessionInstanceDao(super.db);

  // Insert new session instance
  Future<int> createSessionInstance(SessionInstancesCompanion companion) {
    return into(sessionInstances).insert(companion);
  }

  // Get a single session instance by id
  Future<SessionInstance?> getSessionInstanceById(int id) {
    return (select(
      sessionInstances,
    )..where(($SessionInstancesTable s) => s.id.equals(id))).getSingleOrNull();
  }

  // Watch session instance by ID
  Stream<SessionInstance?> watchSessionInstanceById(int id) {
    return (select(sessionInstances)
          ..where(($SessionInstancesTable s) => s.id.equals(id)))
        .watchSingleOrNull();
  }

  // Watch all session instances for a specific session
  Stream<List<SessionInstance>> watchAllSessionsInstancesFor(int sessionId) {
    return (select(sessionInstances)
          ..where(($SessionInstancesTable t) => t.sessionId.equals(sessionId)))
        .watch();
  }

  // Get all instances for a specific session
  Future<List<SessionInstance>> getAllSessionInstancesFor(int sessionId) {
    return (select(sessionInstances)
          ..where(($SessionInstancesTable t) => t.sessionId.equals(sessionId)))
        .get();
  }

  // Update session instance
  Future<int> updateSessionInstance(
    int id,
    SessionInstancesCompanion companion,
  ) async {
    return (update(sessionInstances)
          ..where(($SessionInstancesTable tbl) => tbl.id.equals(id)))
        .write(companion);
  }

  // Delete a session instance
  Future<int> deleteSessionInstance(int id) {
    return (delete(
      sessionInstances,
    )..where(($SessionInstancesTable t) => t.id.equals(id))).go();
  }

  // Delete all instances for a session
  Future<int> deleteSessionInstances(int sessionId) {
    return (delete(
      sessionInstances,
    )..where(($SessionInstancesTable t) => t.sessionId.equals(sessionId))).go();
  }
}
