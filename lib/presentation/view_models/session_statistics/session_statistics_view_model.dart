import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/session_statistics/session_statistics_state.dart';

part 'session_statistics_view_model.g.dart';

@riverpod
class SessionStatisticsViewModel extends _$SessionStatisticsViewModel {
  late final GetInstanceUseCase _getInstanceUseCase;
  StreamSubscription<dynamic>? _instanceSubscription;

  @override
  SessionStatisticsState build(int sessionId) {
    _getInstanceUseCase = ref.watch(getInstanceUseCaseProvider);

    ref.onDispose(() {
      unawaited(_instanceSubscription?.cancel());
    });

    _subscribe();

    unawaited(_loadData());

    return const SessionStatisticsState();
  }

  void _subscribe() {
    _instanceSubscription = _getInstanceUseCase
        .watchInstancesBySessionId(sessionId)
        .listen(
          (List<SessionInstanceModel> instances) {
            state = state.copyWith(
              instances: instances,
              isLoading: false,
              error: null,
            );
          },
          onError: (dynamic error) {
            state = state.copyWith(error: error.toString(), isLoading: false);
          },
        );
  }

  Future<void> _loadData() async {
    try {
      // Fetch everything at the same time in parallel
      final results = await Future.wait([
        ref.read(getSessionStatisticsUseCaseProvider).call(sessionId),
        ref.read(manageSessionUseCaseProvider).getSessionById(sessionId),
        ref.read(manageGoalUseCaseProvider).getAllGoalsBySessionId(sessionId),
        ref.read(manageTasksUseCaseProvider).getAllTasksBySessionId(sessionId),
      ]);

      state = state.copyWith(
        stats: results[0] as SessionStatistics,
        session: results[1] as SessionModel,
        totalGoals: (results[2] as List).length,
        totalTasks: (results[3] as List).length,
        isLoading: false,
        error: null,
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
