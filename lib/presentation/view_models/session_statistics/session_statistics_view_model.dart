import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_statistics.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/presentation/view_models/session_statistics/session_statistics_state.dart';

part 'session_statistics_view_model.g.dart';

@riverpod
class SessionStatisticsViewModel extends _$SessionStatisticsViewModel {
  @override
  SessionStatisticsState build(int sessionId) {
    final subscription = ref
        .watch(getInstanceUseCaseProvider)
        .watchInstancesBySessionId(
          sessionId,
        )
        .listen((_) {
          // Whenever the database changes, refetch full stats
          unawaited(_loadData());
        });

    ref.onDispose(subscription.cancel);

    unawaited(_loadData());

    return const SessionStatisticsState();
  }

  Future<void> _loadData() async {
    try {
      // Fetch everything at the same time in parallel
      final results = await Future.wait([
        ref.read(getSessionStatisticsUseCaseProvider).call(sessionId),
        ref.read(manageSessionUseCaseProvider).getSessionById(sessionId),
        ref.read(manageGoalUseCaseProvider).getAllGoalsBySessionId(sessionId),
        ref.read(manageTasksUseCaseProvider).getAllTasksBySessionId(sessionId),
        ref.read(getInstanceUseCaseProvider).getInstancesBySessionId(sessionId),
      ]);

      state = state.copyWith(
        stats: results[0] as SessionStatistics,
        session: results[1] as SessionModel,
        totalGoals: (results[2] as List).length,
        totalTasks: (results[3] as List).length,
        instances: results[4] as List<SessionInstanceModel>,
        isLoading: false,
        error: null,
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
