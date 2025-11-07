import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/reflection/reflection_state.dart';

part 'reflection_view_model.g.dart';

@riverpod
class ReflectionViewModel extends _$ReflectionViewModel {
  late final SessionInstanceUseCase _sessionInstanceUseCase;

  @override
  Stream<ReflectionState> build(int instanceId) {
    _sessionInstanceUseCase = ref.watch(sessionInstanceUseCaseProvider);

    return _sessionInstanceUseCase
        .watchSessionInstanceById(instanceId)
        .map(
          (SessionInstanceModel instance) =>
              ReflectionState(sessionInstance: instance),
        );
  }

  void selectMood(int mood) {}

  void updateNotes(String notes) {}
}
