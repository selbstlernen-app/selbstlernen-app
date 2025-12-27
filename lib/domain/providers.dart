import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/services/add_session_service.dart';
import 'package:srl_app/domain/usecases/manage_notifications_use_case.dart';
import 'package:srl_app/domain/usecases/manage_settings_use_case.dart';
import 'package:srl_app/domain/usecases/session/get_general_statistics_use_case.dart';
import 'package:srl_app/domain/usecases/session/get_session_statistics_use_case.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';

part 'providers.g.dart';

/// --- Session ---
@riverpod
ManageSessionUseCase manageSessionUseCase(Ref ref) {
  return ManageSessionUseCase(ref.watch(sessionRepositoryProvider));
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
    ref.watch(sessionRepositoryProvider),
    ref.watch(goalRepositoryProvider),
    ref.watch(taskRepositoryProvider),
  );
}

@riverpod
GetGeneralStatisticsUseCase getGeneralStatisticsUseCase(Ref ref) {
  return GetGeneralStatisticsUseCase(
    sessionRepository: ref.watch(sessionRepositoryProvider),
    instanceRepository: ref.watch(sessionInstanceRepositoryProvider),
    goalRepository: ref.watch(goalRepositoryProvider),
    taskRepository: ref.watch(taskRepositoryProvider),
  );
}

/// --- Goals ---
@riverpod
ManageGoalUseCase manageGoalUseCase(Ref ref) {
  return ManageGoalUseCase(ref.watch(goalRepositoryProvider));
}

/// --- Tasks ---
@riverpod
ManageTasksUseCase manageTasksUseCase(Ref ref) {
  return ManageTasksUseCase(ref.watch(taskRepositoryProvider));
}

/// --- FullSession ---
@riverpod
FullSessionUseCase fullSessionUseCase(Ref ref) {
  return FullSessionUseCase(
    ref.watch(sessionRepositoryProvider),
    ref.watch(goalRepositoryProvider),
    ref.watch(taskRepositoryProvider),
    ref.watch(sessionInstanceRepositoryProvider),
  );
}

/// --- Instance ---
@riverpod
GetInstanceUseCase getInstanceUseCase(Ref ref) {
  return GetInstanceUseCase(ref.watch(sessionInstanceRepositoryProvider));
}

@riverpod
ManangeInstanceUseCase manangeInstanceUseCase(Ref ref) {
  return ManangeInstanceUseCase(
    ref.watch(sessionInstanceRepositoryProvider),
    ref.watch(sessionRepositoryProvider),
  );
}

@riverpod
CompleteInstanceUseCase completeInstanceUseCase(Ref ref) {
  return CompleteInstanceUseCase(
    ref.watch(sessionRepositoryProvider),
    ref.watch(sessionInstanceRepositoryProvider),
  );
}

@riverpod
GetOrCreateInstanceUseCase getOrCreateInstanceUseCase(Ref ref) {
  return GetOrCreateInstanceUseCase(
    ref.watch(sessionInstanceRepositoryProvider),
    ref.watch(manangeInstanceUseCaseProvider),
  );
}

/// --- Services ---
@riverpod
AddSessionService addSessionService(Ref ref) {
  return AddSessionService(
    manageSessionUseCase: ref.read(manageSessionUseCaseProvider),
    manageGoalUseCase: ref.read(manageGoalUseCaseProvider),
    manageTasksUseCase: ref.read(manageTasksUseCaseProvider),
  );
}

/// --- Settings ---
@riverpod
ManageSettingsUseCase manageSettingsUseCase(Ref ref) {
  return ManageSettingsUseCase(
    ref.watch(settingsRepositoryProvider),
  );
}

@riverpod
ManageNotificationsUseCase manageNotificationsUseCase(Ref ref) {
  return ManageNotificationsUseCase(
    ref.watch(notificationsRepositoryProvider),
  );
}
