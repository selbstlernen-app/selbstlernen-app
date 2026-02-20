import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/core/utils/date_time_utils.dart';
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
  Future<DetailSessionState> build(
    int sessionId, {
    required DateTime targetDate,
    int? instanceId,
  }) async {
    final fullSession = await ref.watch(
      fullSessionModelProvider(sessionId).future,
    );

    // Get instance if provided
    SessionInstanceModel? instance;
    if (instanceId != null) {
      try {
        instance = await ref
            .read(getInstanceUseCaseProvider)
            .getInstanceById(instanceId);
      } on Exception catch (e) {
        print('Instance $instanceId not found: $e');
        // Continue without instance
      }
    }

    final allInstances = await ref
        .read(getInstanceUseCaseProvider)
        .getInstancesBySessionId(sessionId);

    return DetailSessionState(
      fullSession: fullSession,
      instance: instance,
      pastInstancesLength: allInstances.length,
      isLoading: false,
    );
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
  Future<SessionInstanceModel?> redoSession() async {
    var newInstance = SessionInstanceModel(
      scheduledAt: targetDate,
      sessionId: sessionId.toString(),
      status: SessionStatus.inProgress,
    );
    final existingInstances = await ref
        .read(getInstanceUseCaseProvider)
        .getAllInstancesBySessionIdAndDate(
          sessionId,
          targetDate,
        );

    final hasInProgress = existingInstances!.any(
      (i) =>
          i.status == SessionStatus.inProgress &&
          DateTimeUtils.isSameDay(i.scheduledAt, targetDate),
    );

    if (hasInProgress) {
      // Already have an in-progress instance, don't create another
      return null;
    }

    final id = await ref
        .read(manangeInstanceUseCaseProvider)
        .createInstance(newInstance);
    return newInstance = newInstance.copyWith(id: id.toString());
  }
}
