import 'package:rxdart/rxdart.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';

class GetSessionsForTodayUseCase {
  GetSessionsForTodayUseCase(this.sessionRepo, this.instanceRepo);

  final SessionRepository sessionRepo;
  final SessionInstanceRepository instanceRepo;

  Stream<List<SessionWithInstanceModel>> call(DateTime today) {
    return sessionRepo.watchAllActiveSessions().switchMap((
      List<SessionModel> sessions,
    ) async* {
      final List<SessionModel> todaysSessions = sessions
          .where((SessionModel s) => s.isScheduledForDate(today))
          .toList();

      final List<SessionWithInstanceModel> sessionWithStatusList =
          <SessionWithInstanceModel>[];

      for (final SessionModel session in todaysSessions) {
        SessionInstanceModel? instance = await instanceRepo.getInstanceForDate(
          int.parse(session.id!),
          today,
        );

        instance ??= await instanceRepo.createInstance(
          sessionId: int.parse(session.id!),
          scheduledAt: DateTime.now(),
          status: SessionStatus.scheduled,
        );

        sessionWithStatusList.add(
          SessionWithInstanceModel(session: session, instance: instance),
        );
      }

      yield sessionWithStatusList;
    });
  }
}
