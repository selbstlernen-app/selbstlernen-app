import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/home/home_state.dart';

part 'home_view_model.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late final GetSessionsForTodayUseCase _getSessionsUseCase;
  late final GetCompletedSessionsForTodayUseCase _getCompletedUseCase;
  late final ManangeInstanceUseCase _manangeInstanceUseCase;

  StreamSubscription<dynamic>? _sessionsSubscription;
  StreamSubscription<dynamic>? _completedSubscription;

  @override
  HomeState build() {
    _getSessionsUseCase = ref.watch(getSessionsForTodayUseCaseProvider);
    _getCompletedUseCase = ref.watch(
      getCompletedSessionsForTodayUseCaseProvider,
    );
    _manangeInstanceUseCase = ref.watch(manangeInstanceUseCaseProvider);

    ref.onDispose(() {
      unawaited(_sessionsSubscription?.cancel());
      unawaited(_completedSubscription?.cancel());
    });

    _subscribe();

    return const HomeState(isLoading: true);
  }

  void refresh() {
    state = state.copyWith(isLoading: true, error: null);
    _subscribe();
  }

  void _subscribe() {
    _sessionsSubscription?.cancel();
    _sessionsSubscription = _getSessionsUseCase
        .call(DateTime.now())
        .listen(
          (List<SessionWithInstanceModel> sessions) {
            state = state.copyWith(
              todaysSessions: sessions,
              isLoading: false,
              error: null,
            );
          },
          onError: (dynamic error) {
            state = state.copyWith(error: error.toString(), isLoading: false);
          },
        );

    _completedSubscription = _getCompletedUseCase
        .call(DateTime.now())
        .listen(
          (List<SessionWithInstanceModel> completedSessions) {
            state = state.copyWith(
              completedSessionsForToday: completedSessions,
            );
          },
          onError: (dynamic error) {
            state = state.copyWith(error: error.toString());
          },
        );
  }

  Future<void> skipSession({required String sessionId}) async {
    try {
      // Create the instance in the database with skipped status
      final newInstance = SessionInstanceModel(
        sessionId: sessionId,
        scheduledAt: DateTime.now(),
        status: SessionStatus.skipped,
        completedAt: DateTime.now(),
      );

      await _manangeInstanceUseCase.createInstance(newInstance);
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setFilter(SessionFilter filter) {
    state = state.copyWith(filter: filter);
  }
}
