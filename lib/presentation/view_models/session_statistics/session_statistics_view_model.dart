import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/session/get_focus_minutes_by_weekday_use_case.dart';
import 'package:srl_app/domain/usecases/session/get_session_statistics_use_case.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/session_statistics/session_statistics_state.dart';

part 'session_statistics_view_model.g.dart';

@riverpod
class SessionStatisticsViewModel extends _$SessionStatisticsViewModel {
  late final GetSessionStatisticsUseCase _getSessionStatisticsUseCase;
  late final GetFocusMinutesByWeekdayUseCase _getFocusMinutesByWeekdayUseCase;
  late final ManageSessionUseCase _manageSessionUseCase;
  late final GetInstanceUseCase _getInstanceUseCase;
  late final int _sessionId;

  @override
  SessionStatisticsState build(int sessionId) {
    _sessionId = sessionId;
    _getSessionStatisticsUseCase = ref.watch(
      getSessionStatisticsUseCaseProvider,
    );
    _getFocusMinutesByWeekdayUseCase = ref.watch(
      getFocusMinutesByWeekdayUseCaseProvider,
    );
    _manageSessionUseCase = ref.watch(manageSessionUseCaseProvider);
    _getInstanceUseCase = ref.watch(getInstanceUseCaseProvider);

    unawaited(_loadData());
    return const SessionStatisticsState();
  }

  Future<void> _loadData() async {
    try {
      final statistics = await _getSessionStatisticsUseCase.call(_sessionId);

      final weekdayMinutes = await _getFocusMinutesByWeekdayUseCase.call(
        _sessionId,
      );

      final session = await _manageSessionUseCase.getSessionById(
        _sessionId,
      );

      final instances = await _getInstanceUseCase.getInstancesBySessionId(
        sessionId,
      );

      state = state.copyWith(
        stats: statistics,
        session: session,
        instances: instances,
        weekdayMinutes: weekdayMinutes,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
