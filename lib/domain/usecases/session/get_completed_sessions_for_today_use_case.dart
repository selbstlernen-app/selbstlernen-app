import 'package:rxdart/rxdart.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/domain/repositories/session_instance_repository.dart';
import 'package:srl_app/domain/repositories/session_repository.dart';

class GetCompletedSessionsForTodayUseCase {
  const GetCompletedSessionsForTodayUseCase(
    this.sessionRepo,
    this.instanceRepo,
  );

  final SessionRepository sessionRepo;
  final SessionInstanceRepository instanceRepo;

  Stream<List<SessionWithInstanceModel>> call(DateTime date) {
    final instances$ = instanceRepo.watchAllInstancesForDate(date);
    final sessions$ = sessionRepo.watchAllSessions();

    return Rx.combineLatest2(sessions$, instances$, (
      List<SessionModel> sessions,
      List<SessionInstanceModel> instances,
    ) {
      final completedOrSkipped = instances
          .where(
            (SessionInstanceModel instance) =>
                instance.status == SessionStatus.completed ||
                instance.status == SessionStatus.skipped,
          )
          .toList();

      // Map instances to session id in case more than one instance responds
      // In case a session was re-done
      final latestInstancesBySession = <String, SessionInstanceModel>{};

      for (final instance in completedOrSkipped) {
        final key = instance.sessionId;

        if (!latestInstancesBySession.containsKey(key)) {
          latestInstancesBySession[key] = instance;
        } else {
          final existing = latestInstancesBySession[key]!;

          // pick newest by completedAt
          if ((instance.completedAt ?? DateTime(0)).isAfter(
            existing.completedAt ?? DateTime(0),
          )) {
            latestInstancesBySession[key] = instance;
          }
        }
      }

      final latestInstances = latestInstancesBySession.values.toList();

      return latestInstances.map((instance) {
        final session = sessions.firstWhere(
          (s) => s.id == instance.sessionId,
          orElse: () => throw Exception(
            'Session ${instance.sessionId} not found',
          ),
        );

        return SessionWithInstanceModel(
          session: session,
          instance: instance,
        );
      }).toList();
    });
  }
}
