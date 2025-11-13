import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/domain/usecases/get_sessions_for_today_use_case.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/home/home_state.dart';

part 'home_view_model.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late final GetSessionsForTodayUseCase _useCase;
  late final CompleteInstanceUseCase _completeInstanceUseCase;
  late final StreamSubscription<dynamic> _subscription;

  @override
  HomeState build() {
    _useCase = ref.watch(getSessionsForTodayUseCaseProvider);
    _completeInstanceUseCase = ref.watch(completeInstanceUseCaseProvider);
    _subscribe();
    return const HomeState();
  }

  void _subscribe() {
    _subscription = _useCase
        .call(DateTime.now())
        .listen(
          (List<SessionWithInstanceModel> sessions) {
            state = state.copyWith(sessions: sessions, isLoading: false);
          },
          onError: (dynamic error) {
            state = state.copyWith(error: error.toString(), isLoading: false);
          },
        );
  }

  void setFilter(SessionFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> skipSession(SessionInstanceModel instance) async {
    final SessionInstanceModel sessionInstance = instance.copyWith(
      status: SessionStatus.skipped,
      completedAt: DateTime.now(),
    );

    await _completeInstanceUseCase.call(sessionInstance);
  }
}
