import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/session/get_session_statistics_use_case.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/statistics/statistics_state.dart';

part 'statistics_view_model.g.dart';

@riverpod
class StatisticsViewModel extends _$StatisticsViewModel {
  late final GetSessionStatisticsUseCase _getSessionStatisticsUseCase;
  late final ManageSessionUseCase
  _manageSessionUseCase; // TODO CHECK If necessary
  late final GetInstanceUseCase _getInstanceUseCase;

  @override
  StatisticsState build() {
    _getSessionStatisticsUseCase = ref.watch(
      getSessionStatisticsUseCaseProvider,
    );

    _manageSessionUseCase = ref.watch(manageSessionUseCaseProvider);
    _getInstanceUseCase = ref.watch(getInstanceUseCaseProvider);

    _loadData();
    return const StatisticsState(isLoading: true);
  }

  Future<void> _loadData() async {
    try {
      final List<SessionInstanceModel> instances = await _getInstanceUseCase
          .getAllInstances();

      state = state.copyWith(instances: instances, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
