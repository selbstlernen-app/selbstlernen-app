import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/learning_strategy_model.dart';
import 'package:srl_app/domain/models/notification_type_setting.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/providers.dart';

part 'providers.g.dart';

@riverpod
Stream<List<LearningStrategyModel>> learningStrategiesStream(Ref ref) {
  return ref
      .watch(manageLearningStrategyUseCaseProvider)
      .watchLearningStrategies();
}

@riverpod
Stream<List<NotificationTypeSetting>> notificationSettingsStream(Ref ref) {
  return ref.watch(manageNotificationsUseCaseProvider).watchPreferences();
}

/// Returns a list of all active sessions currently running; to see active notifications
@riverpod
Stream<List<SessionModel>> activeSessions(Ref ref) {
  return ref.watch(manageSessionUseCaseProvider).watchAllActiveSessions();
}
