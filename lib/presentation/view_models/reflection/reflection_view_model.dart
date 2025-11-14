import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/reflection/reflection_state.dart';

part 'reflection_view_model.g.dart';

@riverpod
class ReflectionViewModel extends _$ReflectionViewModel {
  late final UpdateInstanceUseCase _updateInstanceUseCase;

  @override
  ReflectionState build(SessionInstanceModel instance) {
    _updateInstanceUseCase = ref.watch(updateInstanceUseCaseProvider);

    return ReflectionState(instance: instance);
  }

  void selectMood(int mood) {
    state = state.copyWith(mood: mood);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  Future<void> complete({required String notes, int? mood}) async {
    final updated = state.instance.copyWith(
      notes: state.notes,
      mood: state.mood,
    );

    await _updateInstanceUseCase(updated);
  }
}
