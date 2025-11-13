import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/detail_session/detail_session_state.dart';

part 'detail_session_view_model.g.dart';

@riverpod
class DetailSessionViewModel extends _$DetailSessionViewModel {
  late final FullSessionUseCase _fullSessionUseCase;
  late final SessionInstanceUseCase _getInstancesUseCase;
  late final EditSessionUseCase _editSessionUseCase;
  // TODO: Add stats later on...
  late final int _sessionId;

  @override
  Stream<DetailSessionState> build(int sessionId) {
    _sessionId = sessionId;
    _fullSessionUseCase = ref.watch(fullSessionUseCaseProvider);
    _editSessionUseCase = ref.watch(editSessionUseCaseProvider);
    _getInstancesUseCase = ref.watch(sessionInstanceUseCaseProvider);

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
    // Archive instead of delete (safer)
    // final currentSession = (await state.first).fullSession?.session;
    // if (currentSession != null) {
    //   await _fullSessionUseCase.updateSession(
    //     currentSession.copyWith(isArchived: true),
    //   );
    // }
  }
}
