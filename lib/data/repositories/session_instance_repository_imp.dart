import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/daos/session_instance_dao.dart';
import 'package:srl_app/data/entity_mappers/session_instance_mapper.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/session_instance_repository.dart';

class SessionInstanceRepositoryImp implements SessionInstanceRepository {
  SessionInstanceRepositoryImp(this.sessionInstanceDao);

  final SessionInstanceDao sessionInstanceDao;

  @override
  Future<int> addInstance(SessionInstanceModel sessionInstance) {
    return sessionInstanceDao.createInstance(sessionInstance.toCompanion());
  }

  @override
  Future<SessionInstanceModel> createInstance({
    required int sessionId,
    required DateTime scheduledAt,
    required SessionStatus status,
  }) async {
    SessionInstanceModel sessionInstanceModel = SessionInstanceModel(
      sessionId: sessionId.toString(),
      scheduledAt: scheduledAt,
      status: status,
    );
    int id = await sessionInstanceDao.createInstance(
      sessionInstanceModel.toCompanion(),
    );
    return sessionInstanceModel.copyWith(id: id.toString());
  }

  @override
  Future<void> deleteInstanceBySessionId(int sessionId) {
    return sessionInstanceDao.deleteInstance(sessionId);
  }

  @override
  Stream<List<SessionInstanceModel>> watchInstancesBySessionId(int sessionId) {
    return sessionInstanceDao
        .watchInstancesBySessionId(sessionId)
        .map(
          (List<SessionInstance> sessionList) =>
              SessionInstanceToModelMapper.mapFromListOfEntity(sessionList),
        );
  }

  @override
  Stream<SessionInstanceModel> watchInstanceById(int sessionInstanceId) {
    return sessionInstanceDao.watchSessionInstanceById(sessionInstanceId).map((
      SessionInstance? sessionInstance,
    ) {
      if (sessionInstance == null) {
        throw Exception('Session with ID $sessionInstanceId not found.');
      }
      return sessionInstance.toDomain();
    });
  }

  @override
  Future<SessionInstanceModel> getInstanceById(int instanceId) async {
    SessionInstance? instance = await sessionInstanceDao.getInstanceById(
      instanceId,
    );

    if (instance == null) {
      throw Exception('Session instance with ID $instanceId not found.');
    }

    return instance.toDomain();
  }

  @override
  Future<int> updateInstance(
    int sessionInstanceId,
    SessionInstanceModel updatedSession,
  ) {
    return sessionInstanceDao.updateInstance(
      sessionInstanceId,
      updatedSession.toCompanion(),
    );
  }

  @override
  Future<SessionInstanceModel?> getInstanceForDate(
    int sessionId,
    DateTime date,
  ) async {
    SessionInstance? instance = await sessionInstanceDao
        .getInstancesBySessionIdAndDate(sessionId, date);

    return instance?.toDomain();
  }
}
