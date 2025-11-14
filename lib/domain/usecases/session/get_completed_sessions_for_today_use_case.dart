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
    print('🎯 GetCompletedSessionsForTodayUseCase called for date: $date');

    final instances$ = instanceRepo.watchAllInstancesForDate(date);
    final sessions$ = sessionRepo.watchAllSessions();

    return Rx.combineLatest2(sessions$, instances$, (
      List<SessionModel> sessions,
      List<SessionInstanceModel> instances,
    ) {
      print('📦 Total sessions: ${sessions.length}');
      print('📦 Total instances for date: ${instances.length}');

      final completedOrSkipped = instances
          .where(
            (instance) =>
                instance.status == SessionStatus.inProgress ||
                instance.status == SessionStatus.skipped,
          )
          .toList();

      print('✅ Completed/Skipped instances: ${completedOrSkipped.length}');

      // Check if we have matching sessions
      final result = completedOrSkipped.map((instance) {
        print('🔍 Looking for session with ID: ${instance.sessionId}');

        final session = sessions.firstWhere(
          (s) {
            print(
              '  Comparing: session.id=${s.id} with instance.sessionId=${instance.sessionId}',
            );
            return s.id == instance.sessionId;
          },
          orElse: () {
            print('  ⚠️ Session not found for instance ${instance.id}!');
            throw Exception('Session ${instance.sessionId} not found');
          },
        );

        print('  ✅ Found session: ${session.title}');

        return SessionWithInstanceModel(session: session, instance: instance);
      }).toList();

      print('🎉 Returning ${result.length} completed sessions');
      return result;
    });
  }
}
