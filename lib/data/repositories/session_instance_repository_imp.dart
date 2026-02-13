import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/database/daos/session_dao.dart';
import 'package:srl_app/data/database/daos/session_instance_dao.dart';
import 'package:srl_app/data/database/daos/session_instance_strategy_dao.dart';
import 'package:srl_app/data/entity_mappers/session_instance_mapper.dart';
import 'package:srl_app/data/entity_mappers/strategy_mapper.dart';
import 'package:srl_app/domain/models/learning_strategy/instance_strategy_with_details.dart';
import 'package:srl_app/domain/models/learning_strategy/strategy_usage_for_session.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/repositories/session_instance_repository.dart';

class SessionInstanceRepositoryImp implements SessionInstanceRepository {
  SessionInstanceRepositoryImp(
    this.sessionInstanceDao,
    this.strategyDao,
    this.sessionDao,
  );

  final SessionInstanceDao sessionInstanceDao;
  final SessionInstanceStrategyDao strategyDao;
  final SessionDao sessionDao;

  @override
  Future<int> createInstance({required SessionInstanceModel instance}) async {
    final strategyIds = await sessionDao.getStrategyIdsForSession(
      int.parse(instance.sessionId),
    );

    final id = await sessionInstanceDao.createInstance(instance.toCompanion());
    for (final strategyId in strategyIds) {
      await strategyDao.addStrategyToInstance(
        instanceId: id,
        strategyId: strategyId,
      );
    }

    return id;
  }

  @override
  Future<void> deleteInstanceBySessionId(int sessionId) {
    return sessionInstanceDao.deleteInstancesBySessionId(sessionId);
  }

  @override
  Future<void> deleteInstanceById(int instanceId) {
    return sessionInstanceDao.deleteInstance(instanceId);
  }

  @override
  Stream<List<SessionInstanceModel>> watchInstancesBySessionId(int sessionId) {
    return sessionInstanceDao
        .watchInstancesBySessionId(sessionId)
        .map(
          SessionInstanceToModelMapper.mapFromListOfEntity,
        );
  }

  @override
  Stream<List<SessionInstanceModel>> watchAllInstancesForDate(DateTime date) {
    return sessionInstanceDao
        .watchAllInstancesForDate(date)
        .map(
          SessionInstanceToModelMapper.mapFromListOfEntity,
        );
  }

  @override
  Stream<List<SessionInstanceModel>> watchAllInstances() {
    return sessionInstanceDao.watchAllInstances().map(
      SessionInstanceToModelMapper.mapFromListOfEntity,
    );
  }

  @override
  Stream<List<SessionInstanceModel>> watchAllInstancesForTheWeek(
    DateTime date,
  ) {
    return sessionInstanceDao
        .watchAllInstancesForTheWeek(date)
        .map(
          SessionInstanceToModelMapper.mapFromListOfEntity,
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
    final instance = await sessionInstanceDao.getInstanceById(
      instanceId,
    );
    if (instance == null) {
      throw Exception('Session instance with ID $instanceId not found.');
    }
    return instance.toDomain();
  }

  @override
  Future<List<SessionInstanceModel>> getAllInstancesBySessionId(
    int sessionId,
  ) async {
    final instances = await sessionInstanceDao.getInstancesBySessionId(
      sessionId,
    );

    return SessionInstanceToModelMapper.mapFromListOfEntity(instances);
  }

  @override
  Future<int> updateInstance(
    int sessionInstanceId,
    SessionInstanceModel updatedSession,
  ) {
    return sessionInstanceDao.updateInstance(
      sessionInstanceId,
      updatedSession.toUpdateCompanion(),
    );
  }

  @override
  Future<SessionInstanceModel?> getLatestInstanceBySessionIdAndDate(
    int sessionId,
    DateTime date,
  ) async {
    final instance = await sessionInstanceDao
        .getLatestInstanceBySessionIdAndDate(
          sessionId,
          date,
        );

    return instance?.toDomain();
  }

  @override
  Future<List<SessionInstanceModel>?> getAllInstancesBySessionIdAndDate(
    int sessionId,
    DateTime date,
  ) async {
    final instances = await sessionInstanceDao
        .getAllInstancesBySessionIdAndDate(
          sessionId,
          date,
        );

    if (instances != null) {
      return SessionInstanceToModelMapper.mapFromListOfEntity(instances);
    } else {
      return null;
    }
  }

  @override
  Future<List<SessionInstanceModel>> getAllInstances() async {
    return SessionInstanceToModelMapper.mapFromListOfEntity(
      await sessionInstanceDao.getAllInstances(),
    );
  }

  @override
  Future<int> countTotalInstancesBySessionId(int sessionId) {
    return sessionInstanceDao.countTotalInstancesBySessionId(sessionId);
  }

  // -- Strategy related --

  @override
  Stream<List<InstanceStrategyWithDetails>> watchStrategiesForInstance(
    int instanceId,
  ) {
    return strategyDao
        .watchStrategyLinksForInstance(instanceId)
        .map((links) => links.toDomainList());
  }

  @override
  Future<bool> rateStrategy({
    required int instanceId,
    required int strategyId,
    required int effectivenessRating,
    String? userReflection,
  }) {
    return strategyDao.rateStrategy(
      instanceId: instanceId,
      strategyId: strategyId,
      effectivenessRating: effectivenessRating,
      userReflection: userReflection,
    );
  }

  @override
  Stream<List<StrategyUsageForSession>> watchStrategyUsageForSession(
    int sessionId,
  ) {
    return strategyDao
        .watchStrategyUsageForSession(sessionId)
        .map((entities) => entities.toDomainList());
  }
}
