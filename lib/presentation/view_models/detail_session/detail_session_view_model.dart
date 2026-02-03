import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/presentation/view_models/detail_session/detail_session_state.dart';

part 'detail_session_view_model.g.dart';

@riverpod
Stream<FullSessionModel> fullSessionModel(Ref ref, int sessionId) {
  return ref.watch(fullSessionUseCaseProvider).watchFullSession(sessionId);
}

@riverpod
class DetailSessionViewModel extends _$DetailSessionViewModel {
  @override
  DetailSessionState build(
    int sessionId, {
    required DateTime targetDate,
    int? instanceId,
  }) {
    _listenToDataStreams(sessionId);

    unawaited(_initializeDetailSession(sessionId, targetDate, instanceId));

    return const DetailSessionState();
  }

  void _listenToDataStreams(int sessionId) {
    ref.listen(fullSessionModelProvider(sessionId), (prev, next) {
      next.whenData((fullSession) {
        state = state.copyWith(fullSession: fullSession);
      });
    });
  }

  Future<void> _initializeDetailSession(
    int sessionId,
    DateTime targetDate,
    int? instanceId,
  ) async {
    try {
      final getInstanceUseCase = ref.read(getInstanceUseCaseProvider);

      // Fetch specific instance if given
      SessionInstanceModel? instance;
      if (instanceId != null) {
        instance = await getInstanceUseCase.getInstanceById(instanceId);
      }

      // Fetch all instances from past
      final allInstances = await getInstanceUseCase.getInstancesBySessionId(
        sessionId,
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
    await ref.read(fullSessionUseCaseProvider).deleteFullModel(sessionId);
  }

  Future<void> deleteInstance(int instanceId) async {
    await ref
        .read(manangeInstanceUseCaseProvider)
        .deleteInstanceById(instanceId);
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

    await ref
        .read(manageSessionUseCaseProvider)
        .updateSession(sessionId, updated);
  }

  Future<SessionInstanceModel> startSession(int sessionId) async {
    final newInstance = await ref
        .read(getOrCreateInstanceUseCaseProvider)
        .call(
          sessionId: sessionId,
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
    final id = await ref
        .read(manangeInstanceUseCaseProvider)
        .createInstance(newInstance);
    return newInstance = newInstance.copyWith(id: id.toString());
  }
}
