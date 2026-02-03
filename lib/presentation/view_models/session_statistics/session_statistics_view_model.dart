import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/presentation/view_models/providers.dart';
import 'package:srl_app/presentation/view_models/session_statistics/session_statistics_state.dart';

part 'session_statistics_view_model.g.dart';

@riverpod
class SessionStatisticsViewModel extends _$SessionStatisticsViewModel {
  @override
  SessionStatisticsState build(int sessionId) {
    _listenToDataStreams(sessionId);

    return const SessionStatisticsState();
  }

  void _listenToDataStreams(int sessionId) {
    // Listen to statistics stream
    ref
      ..listen(
        sessionStatisticsStreamProvider(sessionId),
        (previous, next) {
          next.when(
            data: (statistics) {
              state = state.copyWith(
                stats: statistics,
                isLoading: false,
                error: null,
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
      // Listen to instances stream
      ..listen(
        sessionInstanceStreamProvider(sessionId),
        (previous, next) {
          next.when(
            data: (instances) {
              state = state.copyWith(
                instances: instances,
                isLoading: false,
                error: null,
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
      // Listen to session stream
      ..listen(
        sessionStreamProvider(sessionId),
        (previous, next) {
          next.when(
            data: (session) {
              state = state.copyWith(
                session: session,
                isLoading: false,
                error: null,
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
      // Listen to goals stream
      ..listen(
        sessionGoalsStreamProvider(sessionId),
        (previous, next) {
          next.when(
            data: (goals) {
              state = state.copyWith(
                totalGoals: goals.length,
                isLoading: false,
                error: null,
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
      // Listen to tasks stream
      ..listen(
        sessionTasksStreamProvider(sessionId),
        (previous, next) {
          next.when(
            data: (tasks) {
              state = state.copyWith(
                totalTasks: tasks.length,
                isLoading: false,
                error: null,
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
}
