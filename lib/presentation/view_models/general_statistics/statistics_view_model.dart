import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/session/get_general_statistics_use_case.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/general_statistics/statistics_state.dart';
import 'package:srl_app/presentation/view_models/general_statistics/ui_model/enriched_session_instance.dart';

part 'statistics_view_model.g.dart';

@riverpod
class StatisticsViewModel extends _$StatisticsViewModel {
  late final GetInstanceUseCase _getInstanceUseCase;
  late final ManageSessionUseCase _manageSessionUseCase;
  late final GetGeneralStatisticsUseCase _getGeneralStatisticsUseCase;

  StreamSubscription<dynamic>? _sessionsSubscription;

  @override
  StatisticsState build() {
    _getInstanceUseCase = ref.watch(getInstanceUseCaseProvider);
    _manageSessionUseCase = ref.watch(manageSessionUseCaseProvider);
    _getGeneralStatisticsUseCase = ref.watch(
      getGeneralStatisticsUseCaseProvider,
    );

    unawaited(_loadData());
    return const StatisticsState();
  }

  Future<void> _loadData() async {
    try {
      final instances = await _getInstanceUseCase.getAllInstances();
      final enrichedInstances = <EnrichedSessionInstance>[];

      for (final instance in instances) {
        final session = await _manageSessionUseCase.getSessionById(
          int.parse(instance.sessionId),
        );
        enrichedInstances.add(
          EnrichedSessionInstance(
            instance: instance,
            sessionName: session.title,
          ),
        );
      }

      _sessionsSubscription = _manageSessionUseCase.watchAllSessions().listen(
        (List<SessionModel> sessions) {
          state = state.copyWith(
            activeOrArchivedSessions: sessions,
            isLoading: false,
          );
        },
        onError: (dynamic error) {
          state = state.copyWith(error: error.toString(), isLoading: false);
        },
      );

      final statistics = await _getGeneralStatisticsUseCase.call();

      state = state.copyWith(
        stats: statistics,
        enrichedInstances: enrichedInstances,

        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void setFilter(StatisticsFilter filter) {
    state = state.copyWith(filter: filter);
  }
}
