import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/presentation/view_models/general_statistics/statistics_state.dart';
import 'package:srl_app/presentation/view_models/general_statistics/ui_model/enriched_session_instance.dart';

part 'statistics_view_model.g.dart';

@riverpod
Stream<List<EnrichedSessionInstance>> enrichedInstancesStream(Ref ref) {
  final instanceUseCase = ref.watch(getInstanceUseCaseProvider);
  final sessionUseCase = ref.watch(manageSessionUseCaseProvider);

  return Rx.combineLatest2(
    instanceUseCase.watchAllInstances(),
    sessionUseCase.watchAllSessions(),
    (instances, sessions) {
      final sessionMap = {for (final s in sessions) s.id.toString(): s.title};
      return instances
          .map(
            (instance) => EnrichedSessionInstance(
              instance: instance,
              sessionName: sessionMap[instance.sessionId] ?? 'Unknown',
            ),
          )
          .toList();
    },
  );
}

@riverpod
Stream<List<SessionModel>> allSessionsStream(Ref ref) {
  final useCase = ref.watch(manageSessionUseCaseProvider);
  return useCase.watchAllSessions();
}

@riverpod
class StatisticsViewModel extends _$StatisticsViewModel {
  @override
  StatisticsState build() {
    final instancesAsync = ref.watch(enrichedInstancesStreamProvider);
    final sessionsAsync = ref.watch(
      allSessionsStreamProvider,
    );

    final allSessions = sessionsAsync.value ?? [];

    // Sort and filter all sessions once on build
    final active = allSessions.where((s) => !s.isArchived).toList()
      ..sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));

    final archived = allSessions.where((s) => s.isArchived).toList()
      ..sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));

    unawaited(_loadStats());

    return StatisticsState(
      enrichedInstances: instancesAsync.value ?? [],
      activeSessions: active,
      archivedSessions: archived,
      isLoading: instancesAsync.isLoading || sessionsAsync.isLoading,
      error: instancesAsync.hasError ? instancesAsync.error.toString() : null,
    );
  }

  Future<void> _loadStats() async {
    try {
      final statistics = await ref
          .watch(getGeneralStatisticsUseCaseProvider)
          .call();

      state = state.copyWith(
        stats: statistics,
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
