import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
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

  late int _sessionId;
  StreamSubscription<FullSessionModel>? _fullSessionSubscription;

  @override
  DetailSessionState build(
    int sessionId, {
    required DateTime targetDate,
    int? instanceId,
  }) {
    _sessionId = sessionId;

    _fullSessionUseCase = ref.watch(fullSessionUseCaseProvider);
    _getInstancesUseCase = ref.watch(getInstanceUseCaseProvider);
    _getOrCreateInstanceUseCase = ref.watch(getOrCreateInstanceUseCaseProvider);
    _manageSessionUseCase = ref.watch(manageSessionUseCaseProvider);
    _manangeInstanceUseCase = ref.watch(manangeInstanceUseCaseProvider);

    unawaited(_initializeDetailSession(targetDate, instanceId));

    ref.onDispose(() async {
      unawaited(_fullSessionSubscription?.cancel());
    });

    return const DetailSessionState();
  }

  Future<void> _initializeDetailSession(DateTime? date, int? id) async {
    try {
      _fullSessionSubscription = _fullSessionUseCase
          .watchFullSession(_sessionId)
          .listen((fullSession) {
            state = state.copyWith(fullSession: fullSession);
          });

      // Fetch specific instance if given
      SessionInstanceModel? instance;
      if (id != null) {
        instance = await _getInstancesUseCase.getInstanceById(id);
      }

      // Fetch all instances from past
      final allInstances = await _getInstancesUseCase.getInstancesBySessionId(
        _sessionId,
      );

      state = state.copyWith(
        instance: instance,
        pastInstancesLength: allInstances.length,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> deleteSession() async {
    await _fullSessionUseCase.deleteFullModel(_sessionId);
  }

  Future<void> deleteInstance(int instanceId) async {
    await _manangeInstanceUseCase.deleteInstanceById(instanceId);
  }

  Future<void> archiveSession() async {
    // Archive session, so that past session data still persists
    final currentFullSession = state.fullSession;

    if (currentFullSession == null) {
      throw Exception('No session loaded');
    }

    final updated = currentFullSession.session.copyWith(
      isArchived: true,
    );

    await _manageSessionUseCase.updateSession(sessionId, updated);
  }

  Future<SessionInstanceModel> startSession() async {
    final newInstance = await _getOrCreateInstanceUseCase.call(
      sessionId: _sessionId,
      date: targetDate,
    );
    return newInstance;
  }

  /// Creates a new session instance that can be re-done
  Future<SessionInstanceModel> redoSession() async {
    var newInstance = SessionInstanceModel(
      scheduledAt: targetDate,
      sessionId: sessionId.toString(),
      status: SessionStatus.inProgress,
    );
    final id = await _manangeInstanceUseCase.createInstance(newInstance);
    return newInstance = newInstance.copyWith(id: id.toString());
  }
}
