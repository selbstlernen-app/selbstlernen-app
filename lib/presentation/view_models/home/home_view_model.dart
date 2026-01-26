import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/home/home_state.dart';

part 'home_view_model.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late final ManangeInstanceUseCase _manangeInstanceUseCase;

  @override
  HomeState build() {
    return HomeState(dateToFilterFor: DateTime.now());
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
        scheduledAt: DateTime.now(),
        status: SessionStatus.skipped,
        completedAt: DateTime.now(),
      );

      await _manangeInstanceUseCase.createInstance(newInstance);
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
