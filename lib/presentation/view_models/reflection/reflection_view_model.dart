import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/usecases/instance/edit_session_instance_use_case.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/reflection/reflection_state.dart';

part 'reflection_view_model.g.dart';

@riverpod
class ReflectionViewModel extends _$ReflectionViewModel {
  late final SessionInstanceUseCase _sessionInstanceUseCase;
  late final EditSessionInstanceUseCase _editSessionInstanceUseCase;

  late int _instanceId;

  @override
  Future<ReflectionState> build(int instanceId) async {
    _instanceId = instanceId;

    _sessionInstanceUseCase = ref.watch(sessionInstanceUseCaseProvider);
    _editSessionInstanceUseCase = ref.watch(editSessionInstanceUseCaseProvider);

    final SessionInstanceModel instance = await _sessionInstanceUseCase
        .getSessionInstanceById(instanceId);

    return ReflectionState(sessionInstance: instance);
  }

  void selectMood(int mood) {
    state.whenData((ReflectionState current) {
      state = AsyncValue<ReflectionState>.data(current.copyWith(mood: mood));
    });
  }

  Future<void> submitReflection({required String notes}) async {
    final ReflectionState? current = state.value;
    if (current == null) return;
    state = AsyncValue<ReflectionState>.data(current.copyWith(isLoading: true));
    try {
      final SessionInstanceModel updatedInstance = current.sessionInstance
          .copyWith(mood: current.mood, notes: notes);

      await _editSessionInstanceUseCase.updateInstance(
        _instanceId,
        updatedInstance,
      );

      state = AsyncValue<ReflectionState>.data(
        current.copyWith(sessionInstance: updatedInstance, isLoading: false),
      );
    } catch (e, st) {
      state = AsyncValue<ReflectionState>.error(e, st);
    }
  }
}
