import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/usecases/session_instance_use_case.dart';
import 'package:srl_app/domain/usecases/session_use_case.dart';
import 'package:srl_app/presentation/view_models/home/home_state.dart';

part 'home_view_model.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late final SessionUseCase _sessionUseCase;
  late final SessionInstanceUseCase _sessionInstanceUseCase;

  late final StreamSubscription _subscription;

  @override
  HomeState build() {
    _sessionUseCase = ref.watch(sessionUseCaseProvider);
    _sessionInstanceUseCase = ref.watch(sessionInstanceUseCaseProvider);
    _subscribe();
    return const HomeState();
  }

  void _subscribe() {
    _subscription = _sessionUseCase.getAllSessions().listen((
      List<SessionModel> sessions,
    ) async {
      final List<SessionModel> enriched = await Future.wait(
        sessions.map((SessionModel s) async {
          final List<SessionInstanceModel> instances =
              await _sessionInstanceUseCase
                  .watchAllSessionsInstancesFor(int.parse(s.id!))
                  .first;
          final int completedCount = instances
              .where(
                (SessionInstanceModel i) => i.status == SessionStatus.completed,
              )
              .length;
          return s.copyWith(
            totalInstances: instances.length,
            completedInstances: completedCount,
          );
        }),
      );
      state = state.copyWith(sessions: enriched, isLoading: false);
    });
  }

  void setFilter(SessionFilter filter) {
    state = state.copyWith(filter: filter);
  }
}
