import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/usecases/session_use_case.dart';
import 'package:srl_app/presentation/view_models/home/home_state.dart';

part 'home_view_model.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late final SessionUseCase _sessionUseCase;

  late final StreamSubscription _subscription;

  @override
  HomeState build() {
    _sessionUseCase = ref.watch(sessionUseCaseProvider);
    _subscribe();
    return const HomeState();
  }

  void _subscribe() {
    _subscription = _sessionUseCase.getAllUncompletedSessions().listen(
      (List<SessionModel> sessions) {
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
}
