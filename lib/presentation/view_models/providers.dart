import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/goal_model.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
import 'package:srl_app/domain/models/notification_type_setting.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/domain/models/task_model.dart';
import 'package:srl_app/domain/providers.dart';

part 'providers.g.dart';

/// Returns a stream of all learning strategies
@riverpod
Stream<List<LearningStrategyModel>> learningStrategiesStream(Ref ref) {
  return ref
      .watch(manageLearningStrategyUseCaseProvider)
      .watchLearningStrategies();
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
