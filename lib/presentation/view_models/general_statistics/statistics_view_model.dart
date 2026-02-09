import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:srl_app/domain/models/general_statistics.dart';
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
Future<GeneralStatistics> generalStatistics(Ref ref) {
  return ref.watch(getGeneralStatisticsUseCaseProvider).call();
}

@riverpod
class StatisticsViewModel extends _$StatisticsViewModel {
  @override
  StatisticsState build() {
    _listenToDataStreams();
    return const StatisticsState();
  }

  void _listenToDataStreams() {
    ref
      ..listen(
        enrichedInstancesStreamProvider,
        (previous, next) {
          next.when(
            data: (instances) {
              state = state.copyWith(
                enrichedInstances: instances,
                isLoading: false,
              );
            },
            loading: () {},
            error: (error, stack) {
              state = state.copyWith(
                error: error.toString(),
                isLoading: false,
              );
            },
          );
        },
      )
      ..listen(
        allSessionsStreamProvider,
        (previous, next) {
          next.when(
            data: (sessions) {
              final active = sessions.where((s) => !s.isArchived).toList()
                ..sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
              final archived = sessions.where((s) => s.isArchived).toList()
                ..sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));

              state = state.copyWith(
                activeSessions: active,
                archivedSessions: archived,
                isLoading: false,
              );
            },
            loading: () {},
            error: (error, stack) {
              state = state.copyWith(
                error: error.toString(),
                isLoading: false,
              );
            },
          );
        },
      )
      ..listen(
        generalStatisticsProvider,
        (previous, next) {
          next.when(
            data: (statistics) {
              state = state.copyWith(
                stats: statistics,
                isLoading: false,
              );
            },
            loading: () {},
            error: (error, stack) {
              state = state.copyWith(
                error: error.toString(),
                isLoading: false,
              );
            },
          );
        },
      );
  }

  void setFilter(StatisticsFilter filter) {
    state = state.copyWith(filter: filter);
  }
}
