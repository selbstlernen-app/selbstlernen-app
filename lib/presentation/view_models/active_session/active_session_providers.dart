import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/providers.dart';

part 'active_session_providers.g.dart';

@riverpod
Stream<SessionInstanceModel> activeInstance(Ref ref, int instanceId) {
  return ref
      .watch(getInstanceUseCaseProvider)
      .watchSessionInstanceById(instanceId);
}

@riverpod
Stream<SessionModel> activeSession(Ref ref, int instanceId) async* {
  // Get the first instance to extract sessionId
  final instance = await ref.watch(activeInstanceProvider(instanceId).future);
  final sessionId = int.parse(instance.sessionId);

  yield* ref.watch(manageSessionUseCaseProvider).watchSessionById(sessionId);
}

@riverpod
Stream<List<GoalModel>> activeGoals(Ref ref, int instanceId) async* {
  final instance = await ref.watch(activeInstanceProvider(instanceId).future);
  final sessionId = int.parse(instance.sessionId);

  yield* ref
      .watch(manageGoalUseCaseProvider)
      .watchGoalsBySessionIdAndDate(sessionId, DateTime.now());
}

@riverpod
Stream<List<TaskModel>> activeTasks(Ref ref, int instanceId) async* {
  final instance = await ref.watch(activeInstanceProvider(instanceId).future);
  final sessionId = int.parse(instance.sessionId);

  yield* ref
      .watch(manageTasksUseCaseProvider)
      .watchTasksBySessionIdAndDate(sessionId, DateTime.now());
}
