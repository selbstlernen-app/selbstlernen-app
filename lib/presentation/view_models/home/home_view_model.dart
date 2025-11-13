import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/domain/usecases/get_completed_sessions_for_today_use_case.dart';
import 'package:srl_app/domain/usecases/get_sessions_for_today_use_case.dart';
import 'package:srl_app/domain/usecases/instance/create_instance_use_case.dart';

import 'package:srl_app/presentation/view_models/home/home_state.dart';

part 'home_view_model.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late final GetSessionsForTodayUseCase _getSessionsUseCase;
  late final GetCompletedSessionsForTodayUseCase _getCompletedUseCase;
  late final CreateInstanceUseCase _createInstanceUseCase;

  @override
  HomeState build() {
    _getSessionsUseCase = ref.watch(getSessionsForTodayUseCaseProvider);
    _getCompletedUseCase = ref.watch(
      getCompletedSessionsForTodayUseCaseProvider,
    );
    _createInstanceUseCase = ref.watch(createInstanceUseCaseProvider);

    _subscribe();
    return const HomeState();
  }

  void _subscribe() {
    _getSessionsUseCase
        .call(DateTime.now())
        .listen(
          (List<SessionWithInstanceModel> sessions) {
            state = state.copyWith(sessions: sessions, isLoading: false);
          },
          onError: (dynamic error) {
            state = state.copyWith(error: error.toString(), isLoading: false);
          },
        );

    _getCompletedUseCase
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

  void setFilter(SessionFilter filter) {
    state = state.copyWith(filter: filter);
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

      await _createInstanceUseCase.call(newInstance);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
