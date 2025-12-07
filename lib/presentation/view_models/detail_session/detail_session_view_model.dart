import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/use_cases.dart';
import 'package:srl_app/presentation/view_models/detail_session/detail_session_state.dart';

part 'detail_session_view_model.g.dart';

@riverpod
class DetailSessionViewModel extends _$DetailSessionViewModel {
  late final FullSessionUseCase _fullSessionUseCase;
  late final ManageSessionUseCase _manageSessionUseCase;
  late final GetInstanceUseCase _getInstancesUseCase;
  late final GetOrCreateInstanceUseCase _getOrCreateInstanceUseCase;

  late final ManangeInstanceUseCase _manangeInstanceUseCase;
  late final int _sessionId;

  @override
  Stream<DetailSessionState> build(int sessionId) {
    _sessionId = sessionId;
    _fullSessionUseCase = ref.watch(fullSessionUseCaseProvider);
    _getInstancesUseCase = ref.watch(getInstanceUseCaseProvider);
    _getOrCreateInstanceUseCase = ref.watch(getOrCreateInstanceUseCaseProvider);
    _manageSessionUseCase = ref.watch(manageSessionUseCaseProvider);
    _manangeInstanceUseCase = ref.watch(manangeInstanceUseCaseProvider);

    final fullSession$ = _fullSessionUseCase.watchFullSession(sessionId);
    final instances$ = _getInstancesUseCase.watchInstancesBySessionId(
      sessionId,
    );

    return Rx.combineLatest2(fullSession$, instances$, (
      FullSessionModel fullSession,
      List<SessionInstanceModel> instances,
    ) {
      return DetailSessionState(
        fullSession: fullSession,
        pastInstances: instances,
        isLoading: false,
      );
    }).handleError((dynamic error) {
      return DetailSessionState(error: error.toString(), isLoading: false);
    });
  }

  Future<void> deleteSession() async {
    await _fullSessionUseCase.deleteFullModel(_sessionId);
  }

  Future<void> archiveSession() async {
    // Archive session, so that past session data still persists
    final currentFullSession = state.value?.fullSession;

    if (currentFullSession == null) {
      throw Exception('No session loaded');
    }

    final updated = currentFullSession.session.copyWith(
      isArchived: true,
    );

    await _manageSessionUseCase.updateSession(sessionId, updated);
  }

  Future<SessionInstanceModel> startSession(DateTime date) async {
    return _getOrCreateInstanceUseCase.call(
      sessionId: _sessionId,
      date: date,
    );
  }

  /// Creates a new session to be re-done
  Future<SessionInstanceModel> redoSession() async {
    var newInstance = SessionInstanceModel(
      scheduledAt: DateTime.now(),
      sessionId: sessionId.toString(),
      status: SessionStatus.inProgress,
    );
    final id = await _manangeInstanceUseCase.createInstance(newInstance);
    return newInstance = newInstance.copyWith(id: id.toString());
  }
}
