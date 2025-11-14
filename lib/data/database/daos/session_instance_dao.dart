import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/tables/session_instance_table.dart';

part 'session_instance_dao.g.dart';

@DriftAccessor(tables: <Type>[SessionInstances])
class SessionInstanceDao extends DatabaseAccessor<AppDatabase>
    with _$SessionInstanceDaoMixin {
  SessionInstanceDao(super.db);

  // Insert new session instance
  Future<int> createInstance(SessionInstancesCompanion companion) {
    return into(sessionInstances).insert(companion);
  }

  // Get an instance by its id
  Future<SessionInstance?> getInstanceById(int id) {
    return (select(
      sessionInstances,
    )..where(($SessionInstancesTable s) => s.id.equals(id))).getSingleOrNull();
  }

  // Get an instance by its session id
  Future<SessionInstance?> getInstanceBySessionId(int sessionId) {
    return (select(sessionInstances)
          ..where(($SessionInstancesTable s) => s.sessionId.equals(sessionId)))
        .getSingleOrNull();
  }

  // Watch session instance by ID
  Stream<SessionInstance?> watchSessionInstanceById(int id) {
    return (select(sessionInstances)
          ..where(($SessionInstancesTable s) => s.id.equals(id)))
        .watchSingleOrNull();
  }

  // Watch all session instances for a specific session
  Stream<List<SessionInstance>> watchInstancesBySessionId(int sessionId) {
    return (select(sessionInstances)
          ..where(($SessionInstancesTable t) => t.sessionId.equals(sessionId)))
        .watch();
  }

  /// Watch all session instances for a given date
  Stream<List<SessionInstance>> watchAllInstancesForDate(DateTime date) {
    final DateTime startOfDay = DateTime(date.year, date.month, date.day);
    final DateTime endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
    );

    return (select(sessionInstances)..where(
          ($SessionInstancesTable t) =>
              t.scheduledAt.isBetweenValues(startOfDay, endOfDay),
        ))
        .watch();
  }

  // Get all instances for a specific session
  Future<List<SessionInstance>> getInstancesBySessionId(int sessionId) {
    return (select(sessionInstances)
          ..where(($SessionInstancesTable t) => t.sessionId.equals(sessionId)))
        .get();
  }

  // Update session instance
  Future<int> updateInstance(
    int id,
    SessionInstancesCompanion companion,
  ) async {
    return (update(sessionInstances)
          ..where(($SessionInstancesTable tbl) => tbl.id.equals(id)))
        .write(companion);
  }

  // Delete a session instance
  Future<int> deleteInstance(int id) {
    return (delete(
      sessionInstances,
    )..where(($SessionInstancesTable t) => t.id.equals(id))).go();
  }

  // Delete all instances for a session
  Future<int> deleteInstances(int sessionId) {
    return (delete(
      sessionInstances,
    )..where(($SessionInstancesTable t) => t.sessionId.equals(sessionId))).go();
  }

  // Get scheduled instance if it exists
  Future<SessionInstance?> getInstancesBySessionIdAndDate(
    int sessionId,
    DateTime date,
  ) {
    final DateTime startOfDay = DateTime(date.year, date.month, date.day);
    final DateTime endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
    );

    return (select(sessionInstances)..where(
          ($SessionInstancesTable s) =>
              s.sessionId.equals(sessionId) &
              s.scheduledAt.isBetweenValues(startOfDay, endOfDay),
        ))
        .getSingleOrNull();
  }

  Future<int> countTotalInstancesBySessionId(int sessionId) async {
    List<SessionInstance> instances =
        await (select(sessionInstances)..where(
              ($SessionInstancesTable tbl) => tbl.sessionId.equals(sessionId),
            ))
            .get();
    return instances.length;
  }
}
