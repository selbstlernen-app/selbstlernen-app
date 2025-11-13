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
    // Get instances for today that are completed OR skipped
    final Stream<List<SessionInstanceModel>> instances$ = instanceRepo
        .watchAllInstancesForDate(date);

    // Get all sessions (can also be archived)
    final Stream<List<SessionModel>> sessions$ = sessionRepo.watchAllSessions();

    return Rx.combineLatest2(sessions$, instances$, (
      List<SessionModel> sessions,
      List<SessionInstanceModel> instances,
    ) {
      return instances
          .where(
            // Get only skipped or completed instances to display
            (SessionInstanceModel instance) =>
                instance.status == SessionStatus.completed ||
                instance.status == SessionStatus.skipped,
          )
          .map((SessionInstanceModel instance) {
            final SessionModel session = sessions.firstWhere(
              (SessionModel s) => s.id == instance.sessionId,
            );
            return SessionWithInstanceModel(
              session: session,
              instance: instance,
            );
          })
          .toList();
    });
  }
}
