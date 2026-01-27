import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/home/home_state.dart';

part 'home_view_model.g.dart';

// Watch the stream of sessions for a specific date
@riverpod
Stream<List<SessionWithInstanceModel>> sessionsForDate(Ref ref, DateTime date) {
  return ref.watch(getSessionsForDateUseCaseProvider).call(date);
}

// Watch the stream of completed sessions for a specific date
@riverpod
Stream<List<SessionWithInstanceModel>> completedSessionsForDate(
  Ref ref,
  DateTime date,
) {
  return ref.watch(getCompletedSessionsForTodayUseCaseProvider).call(date);
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late final ManangeInstanceUseCase _manangeInstanceUseCase;

  @override
  HomeState build() {
    return HomeState(
      dateToFilterFor: DateTime.now(),
      isLoading: false,
    );
  }

  void updateDate(DateTime newDate) {
    state = state.copyWith(dateToFilterFor: newDate);
  }

  void setFilter(SessionFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> skipSession({required String sessionId}) async {
    try {
      // Create the instance in the database with skipped status
      final newInstance = SessionInstanceModel(
        sessionId: sessionId,
        scheduledAt: state.dateToFilterFor,
        status: SessionStatus.skipped,
        completedAt: DateTime.now(),
      );

      await ref
          .watch(manangeInstanceUseCaseProvider)
          .createInstance(newInstance);
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
