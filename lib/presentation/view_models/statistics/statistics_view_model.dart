import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/statistics/statistics_state.dart';
import 'package:srl_app/presentation/view_models/statistics/ui_model/enriched_session_instance.dart';

part 'statistics_view_model.g.dart';

@riverpod
class StatisticsViewModel extends _$StatisticsViewModel {
  late final GetInstanceUseCase _getInstanceUseCase;
  late final ManageSessionUseCase _manageSessionUseCase;

  @override
  StatisticsState build() {
    _getInstanceUseCase = ref.watch(getInstanceUseCaseProvider);
    _manageSessionUseCase = ref.watch(manageSessionUseCaseProvider);

    unawaited(_loadData());
    return const StatisticsState();
  }

  Future<void> _loadData() async {
    try {
      final instances = await _getInstanceUseCase.getAllInstances();
      final enrichedInstances = <EnrichedSessionInstance>[];

      for (final instance in instances) {
        final session = await _manageSessionUseCase.getSessionById(
          int.parse(instance.sessionId),
        );
        enrichedInstances.add(
          EnrichedSessionInstance(
            instance: instance,
            sessionName: session.title,
          ),
        );
      }

      state = state.copyWith(
        enrichedInstances: enrichedInstances,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
