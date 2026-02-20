import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/goal_model.dart';
import 'package:srl_app/domain/models/learning_strategy/instance_strategy_with_details.dart';
import 'package:srl_app/domain/models/learning_strategy/learning_strategy_with_stats.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
import 'package:srl_app/domain/models/notification_type_setting.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/domain/models/task_model.dart';
import 'package:srl_app/domain/providers.dart';

part 'providers.g.dart';

/// Returns a stream of all learning strategies (rated across all sessions)
@riverpod
Stream<List<LearningStrategyWithStats>> learningStrategiesStream(Ref ref) {
  return ref
      .watch(manageLearningStrategyUseCaseProvider)
      .watchAllStrategiesWithStats();
}

/// Returns a stream of all strategies for a session
@riverpod
Stream<List<LearningStrategyModel>> sessionStrategies(
  Ref ref,
  int sessionId,
) {
  return ref
      .watch(manageLearningStrategyUseCaseProvider)
      .watchLearningStrategiesForSession(sessionId);
}

/// Returns a straem of all strategies specific to an instance
@riverpod
Stream<List<InstanceStrategyWithDetails>> instanceStrategies(
  Ref ref,
  int instanceId,
) {
  return ref
      .watch(manageLearningStrategyUseCaseProvider)
      .watchStrategiesForInstance(instanceId);
}

/// Returns a stream of notification settings
@riverpod
Stream<List<NotificationTypeSetting>> notificationSettingsStream(Ref ref) {
  return ref.watch(manageNotificationsUseCaseProvider).watchPreferences();
}

/// Returns a list of all active sessions currently running; to see active notifications
@riverpod
Stream<List<SessionModel>> activeSessions(Ref ref) {
  return ref.watch(manageSessionUseCaseProvider).watchAllActiveSessions();
}

/// Returns a stream of the session statistics
@riverpod
Stream<SessionStatistics> sessionStatisticsStream(
  Ref ref,
  int sessionId,
) {
  return ref
      .watch(getSessionStatisticsUseCaseProvider)
      .watchStatistics(sessionId);
}

/// Returns the streamed session instances by session id
@riverpod
Stream<List<SessionInstanceModel>> sessionInstanceStream(
  Ref ref,
  int sessionId,
) {
  return ref
      .watch(getInstanceUseCaseProvider)
      .watchInstancesBySessionId(sessionId);
}

/// Returns the session by its id
@riverpod
Stream<SessionModel> sessionStream(Ref ref, int sessionId) {
  return ref.watch(manageSessionUseCaseProvider).watchSessionById(sessionId);
}

/// Returns all goals associated with given session
@riverpod
Stream<List<GoalModel>> sessionGoalsStream(Ref ref, int sessionId) {
  return ref.watch(manageGoalUseCaseProvider).watchGoalsBySessionId(sessionId);
}

/// Returns all tasks associated with given session
@riverpod
Stream<List<TaskModel>> sessionTasksStream(Ref ref, int sessionId) {
  return ref.watch(manageTasksUseCaseProvider).watchTasksBySessionId(sessionId);
}
