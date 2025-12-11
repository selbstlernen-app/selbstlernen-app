import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/reflection/reflection_state.dart';

part 'reflection_view_model.g.dart';

@riverpod
class ReflectionViewModel extends _$ReflectionViewModel {
  late final ManangeInstanceUseCase _updateInstanceUseCase;

  @override
  ReflectionState build(SessionInstanceModel instance) {
    _updateInstanceUseCase = ref.watch(manangeInstanceUseCaseProvider);

    return ReflectionState(instance: instance);
  }

  void selectMood(int mood) {
    state = state.copyWith(mood: mood);
  }

  Future<void> complete({required String notes, int? mood}) async {
    final updated = state.instance.copyWith(
      notes: state.notes,
      mood: state.mood,
    );

    await _updateInstanceUseCase.updateInstance(updated);
  }
}
