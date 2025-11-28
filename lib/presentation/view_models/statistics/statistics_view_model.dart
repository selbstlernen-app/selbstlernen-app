import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/statistics/statistics_state.dart';

part 'statistics_view_model.g.dart';

@riverpod
class StatisticsViewModel extends _$StatisticsViewModel {
  late final GetInstanceUseCase _getInstanceUseCase;

  @override
  StatisticsState build() {
    _getInstanceUseCase = ref.watch(getInstanceUseCaseProvider);

    unawaited(_loadData());
    return const StatisticsState();
  }

  Future<void> _loadData() async {
    try {
      final instances = await _getInstanceUseCase.getAllInstances();

      state = state.copyWith(instances: instances, isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
