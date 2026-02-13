import 'package:srl_app/domain/models/learning_strategy/instance_strategy_with_details.dart';
import 'package:srl_app/domain/models/learning_strategy/strategy_usage_for_session.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

/// Abstract repository class for the session instance repository
abstract class SessionInstanceRepository {
  // CRUD operations
  Future<int> createInstance({required SessionInstanceModel instance});

  Future<SessionInstanceModel> getInstanceById(int instanceId);
  Future<List<SessionInstanceModel>> getAllInstancesBySessionId(int sessionId);
  Future<List<SessionInstanceModel>> getAllInstances();

  Stream<List<SessionInstanceModel>> watchInstancesBySessionId(int sessionId);
  Stream<List<SessionInstanceModel>> watchAllInstancesForTheWeek(DateTime date);
  Stream<List<SessionInstanceModel>> watchAllInstances();
  Stream<SessionInstanceModel> watchInstanceById(int sessionInstanceId);
  Stream<List<SessionInstanceModel>> watchAllInstancesForDate(DateTime date);

  Future<int> updateInstance(
    int sessionInstanceId,
    SessionInstanceModel updatedSessionInstance,
  );
  Future<void> deleteInstanceBySessionId(int sessionId);
  Future<void> deleteInstanceById(int instanceId);

  // Date-related queries
  Future<SessionInstanceModel?> getInstanceForDate(
    int sessionId,
    DateTime date,
  );

  Future<int> countTotalInstancesBySessionId(int sessionId);

  // Strategy related
  Stream<List<InstanceStrategyWithDetails>> watchStrategiesForInstance(
    int instanceId,
  );
  Future<bool> rateStrategy({
    required int instanceId,
    required int strategyId,
    required int effectivenessRating,
    String? userReflection,
  });
  // For session statistics card
  Stream<List<StrategyUsageForSession>> watchStrategyUsageForSession(
    int sessionId,
  );
}
