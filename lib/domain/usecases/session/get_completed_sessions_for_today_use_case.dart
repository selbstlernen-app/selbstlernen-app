import 'package:rxdart/rxdart.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';

class GetCompletedSessionsForTodayUseCase {
  const GetCompletedSessionsForTodayUseCase(
    this.sessionRepo,
    this.instanceRepo,
  );

  final SessionRepository sessionRepo;
  final SessionInstanceRepository instanceRepo;

  Stream<List<SessionWithInstanceModel>> call(DateTime date) {
    final Stream<List<SessionInstanceModel>> instances$ = instanceRepo
        .watchAllInstancesForDate(date);
    final Stream<List<SessionModel>> sessions$ = sessionRepo.watchAllSessions();

    return Rx.combineLatest2(sessions$, instances$, (
      List<SessionModel> sessions,
      List<SessionInstanceModel> instances,
    ) {
      final List<SessionInstanceModel> completedOrSkipped = instances
          .where(
            (SessionInstanceModel instance) =>
                instance.status == SessionStatus.completed ||
                instance.status == SessionStatus.skipped,
          )
          .toList();

      // Check if we have matching sessions
      final List<SessionWithInstanceModel> result = completedOrSkipped.map((
        SessionInstanceModel instance,
      ) {
        final SessionModel session = sessions.firstWhere(
          (SessionModel s) {
            return s.id == instance.sessionId;
          },
          orElse: () {
            throw Exception('Session ${instance.sessionId} not found');
          },
        );

        return SessionWithInstanceModel(session: session, instance: instance);
      }).toList();

      return result;
    });
  }
}
