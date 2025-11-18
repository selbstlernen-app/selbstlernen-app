import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/usecases/session/get_session_statistics_use_case.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/domain/services/add_session_service.dart';

part 'providers.g.dart';

/// --- Session ---
@riverpod
CreateSessionUseCase createSessionUseCase(Ref ref) {
  return CreateSessionUseCase(ref.watch(sessionRepositoryProvider));
}

@riverpod
EditSessionUseCase editSessionUseCase(Ref ref) {
  return EditSessionUseCase(ref.watch(sessionRepositoryProvider));
}

@riverpod
SessionUseCase sessionUseCase(Ref ref) {
  return SessionUseCase(ref.watch(sessionRepositoryProvider));
}

@riverpod
GetSessionsForTodayUseCase getSessionsForTodayUseCase(Ref ref) {
  return GetSessionsForTodayUseCase(
    ref.watch(sessionRepositoryProvider),
    ref.watch(sessionInstanceRepositoryProvider),
  );
}

@riverpod
GetCompletedSessionsForTodayUseCase getCompletedSessionsForTodayUseCase(
  Ref ref,
) {
  return GetCompletedSessionsForTodayUseCase(
    ref.watch(sessionRepositoryProvider),
    ref.watch(sessionInstanceRepositoryProvider),
  );
}

@riverpod
GetSessionStatisticsUseCase getSessionStatisticsUseCase(Ref ref) {
  return GetSessionStatisticsUseCase(
    ref.watch(sessionInstanceRepositoryProvider),
  );
}

/// --- Goals ---
@riverpod
CreateGoalsUseCase createGoalsUseCase(Ref ref) {
  return CreateGoalsUseCase(ref.watch(goalRepositoryProvider));
}

@riverpod
EditGoalsUseCase editGoalsUseCase(Ref ref) {
  return EditGoalsUseCase(ref.watch(goalRepositoryProvider));
}

/// --- Tasks ---
@riverpod
CreateTasksUseCase createTasksUseCase(Ref ref) {
  return CreateTasksUseCase(ref.watch(taskRepositoryProvider));
}

@riverpod
EditTasksUseCase editTasksUseCase(Ref ref) {
  return EditTasksUseCase(ref.watch(taskRepositoryProvider));
}

/// --- FullSession ---
@riverpod
FullSessionUseCase fullSessionUseCase(Ref ref) {
  return FullSessionUseCase(
    ref.watch(sessionRepositoryProvider),
    ref.watch(goalRepositoryProvider),
    ref.watch(taskRepositoryProvider),
  );
}

/// --- Instance ---
@riverpod
GetInstanceUseCase getInstanceUseCase(Ref ref) {
  return GetInstanceUseCase(ref.watch(sessionInstanceRepositoryProvider));
}

@riverpod
UpdateInstanceUseCase updateInstanceUseCase(Ref ref) {
  return UpdateInstanceUseCase(ref.watch(sessionInstanceRepositoryProvider));
}

@riverpod
CompleteInstanceUseCase completeInstanceUseCase(Ref ref) {
  return CompleteInstanceUseCase(
    ref.watch(sessionRepositoryProvider),
    ref.watch(sessionInstanceRepositoryProvider),
  );
}

@riverpod
CreateInstanceUseCase createInstanceUseCase(Ref ref) {
  return CreateInstanceUseCase(
    ref.watch(sessionInstanceRepositoryProvider),
    ref.watch(sessionRepositoryProvider),
  );
}

@riverpod
GetOrCreateInstanceUseCase getOrCreateInstanceUseCase(Ref ref) {
  return GetOrCreateInstanceUseCase(
    ref.watch(sessionInstanceRepositoryProvider),
    ref.watch(createInstanceUseCaseProvider),
  );
}

/// --- Services ---
@riverpod
AddSessionService addSessionService(Ref ref) {
  return AddSessionService(
    createSessionUseCase: ref.read(createSessionUseCaseProvider),
    createGoalsUseCase: ref.read(createGoalsUseCaseProvider),
    createTasksUseCase: ref.read(createTasksUseCaseProvider),
    editSessionUseCase: ref.read(editSessionUseCaseProvider),
    editGoalsUseCase: ref.read(editGoalsUseCaseProvider),
    editTasksUseCase: ref.read(editTasksUseCaseProvider),
  );
}
