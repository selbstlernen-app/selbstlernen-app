import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/daos/session_instance_dao.dart';
import 'package:srl_app/data/entity_mappers/session_instance_mapper.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/session_instance_repository.dart';

class SessionInstanceRepositoryImp implements SessionInstanceRepository {
  SessionInstanceRepositoryImp(this.sessionInstanceDao);

  final SessionInstanceDao sessionInstanceDao;

  @override
  Future<int> addSessionInstance(SessionInstanceModel sessionInstance) {
    return sessionInstanceDao.createSessionInstance(
      sessionInstance.toCompanion(),
    );
  }

  @override
  Future<void> deleteSessionInstance(int sessionId) {
    return sessionInstanceDao.deleteSessionInstance(sessionId);
  }

  @override
  Future<List<SessionInstanceModel>> getAllSessionInstancesFor(
    int sessionId,
  ) async {
    List<SessionInstance> sessionInstanceEntities = await sessionInstanceDao
        .getAllSessionInstancesFor(sessionId);
    List<SessionInstanceModel> instances =
        SessionInstanceToModelMapper.mapFromListOfEntity(
          sessionInstanceEntities,
        );
    return instances;
  }

  @override
  Future<SessionInstanceModel> getSessionInstanceById(int sessionId) async {
    SessionInstance? instance = await sessionInstanceDao.getSessionInstanceById(
      sessionId,
    );

    if (instance == null) {
      throw Exception('Session instance with ID $sessionId not found.');
    }

    return instance.toDomain();
  }
}
