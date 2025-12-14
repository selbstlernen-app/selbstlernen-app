import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/session/get_session_statistics_use_case.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/session_statistics/session_statistics_state.dart';

part 'session_statistics_view_model.g.dart';

@riverpod
class SessionStatisticsViewModel extends _$SessionStatisticsViewModel {
  late final GetSessionStatisticsUseCase _getSessionStatisticsUseCase;
  late final ManageSessionUseCase _manageSessionUseCase;
  late final ManageGoalUseCase _manageGoalUseCase;
  late final ManageTasksUseCase _manageTasksUseCase;
  late final GetInstanceUseCase _getInstanceUseCase;
  late final int _sessionId;

  @override
  SessionStatisticsState build(int sessionId) {
    _sessionId = sessionId;
    _getSessionStatisticsUseCase = ref.watch(
      getSessionStatisticsUseCaseProvider,
    );
    _manageSessionUseCase = ref.watch(manageSessionUseCaseProvider);
    _manageGoalUseCase = ref.watch(manageGoalUseCaseProvider);
    _manageTasksUseCase = ref.watch(manageTasksUseCaseProvider);

    _getInstanceUseCase = ref.watch(getInstanceUseCaseProvider);

    unawaited(_loadData());
    return const SessionStatisticsState();
  }

  Future<void> _loadData() async {
    try {
      final statistics = await _getSessionStatisticsUseCase.call(_sessionId);

      final session = await _manageSessionUseCase.getSessionById(
        _sessionId,
      );

      final goals = await _manageGoalUseCase.getAllGoalsBySessionId(sessionId);
      final tasks = await _manageTasksUseCase.getAllTasksBySessionId(sessionId);

      final instances = await _getInstanceUseCase.getInstancesBySessionId(
        sessionId,
      );

      state = state.copyWith(
        stats: statistics,
        session: session,
        instances: instances,

        goals: goals,
        tasks: tasks,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
