import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/detail_session/detail_session_state.dart';

part 'detail_session_view_model.g.dart';

@riverpod
class DetailSessionViewModel extends _$DetailSessionViewModel {
  late final FullSessionUseCase _fullSessionUseCase;
  late final GetInstanceUseCase _getInstancesUseCase;
  late final EditSessionUseCase _editSessionUseCase;
  late final GetOrCreateInstanceUseCase _getOrCreateInstanceUseCase;
  // TODO: Add stats later on...
  late final int _sessionId;

  @override
  Stream<DetailSessionState> build(int sessionId) {
    _sessionId = sessionId;
    _fullSessionUseCase = ref.watch(fullSessionUseCaseProvider);
    _editSessionUseCase = ref.watch(editSessionUseCaseProvider);
    _getInstancesUseCase = ref.watch(getInstanceUseCaseProvider);
    _getOrCreateInstanceUseCase = ref.watch(getOrCreateInstanceUseCaseProvider);

    final Stream<FullSessionModel> fullSession$ = _fullSessionUseCase
        .watchFullSession(sessionId);
    final Stream<List<SessionInstanceModel>> instances$ = _getInstancesUseCase
        .watchInstancesBySessionId(sessionId);

    return Rx.combineLatest2(fullSession$, instances$, (
      FullSessionModel fullSession,
      List<SessionInstanceModel> instances,
    ) {
      //TODO:  Calculate stats from instances

      return DetailSessionState(
        fullSession: fullSession,
        pastInstances: instances,
        // TODO: stats here
        isLoading: false,
      );
    }).handleError((error) {
      return DetailSessionState(error: error.toString(), isLoading: false);
    });
  }

  Future<void> deleteSession() async {
    await _fullSessionUseCase.deleteFullModel(_sessionId);
  }

  Future<void> archiveSession() async {
    // Archive instead of delete? // Past session data still persists
  }

  Future<SessionInstanceModel> startSession(DateTime date) async {
    return await _getOrCreateInstanceUseCase.call(
      sessionId: _sessionId,
      date: date,
    );
  }
}
