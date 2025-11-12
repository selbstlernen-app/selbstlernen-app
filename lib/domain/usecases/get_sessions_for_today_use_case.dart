import 'dart:async';

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

  Stream<List<SessionWithInstanceModel>> call(DateTime today) async* {
    await for (final List<SessionWithInstanceModel> list
        in _watchSessionsWithInstancesForDate(today)) {
      // Detect sessions that don't have a persisted instance
      for (final SessionWithInstanceModel item in list) {
        if (item.instance!.id == "-1") {
          // Fire and forget — don't block the stream
          unawaited(
            instanceRepo.createInstance(
              sessionId: int.parse(item.session.id!),
              scheduledAt: today,
              status: SessionStatus.scheduled,
            ),
          );
        }
      }

      yield list;
    }
  }

  Stream<List<SessionWithInstanceModel>> _watchSessionsWithInstancesForDate(
    DateTime today,
  ) {
    return sessionRepo.watchAllActiveSessions().switchMap((
      List<SessionModel> sessions,
    ) {
      final List<SessionModel> todaysSessions = sessions
          .where((SessionModel s) => s.isScheduledForDate(today))
          .toList();

      if (todaysSessions.isEmpty) {
        return Stream<List<SessionWithInstanceModel>>.value(
          <SessionWithInstanceModel>[],
        );
      }

      return instanceRepo.watchAllInstancesForDate(today).map((
        List<SessionInstanceModel> instances,
      ) {
        return todaysSessions.map((SessionModel session) {
          final SessionInstanceModel instance = instances.firstWhere(
            (SessionInstanceModel i) =>
                int.parse(i.sessionId) == int.parse(session.id!),
            orElse: () => SessionInstanceModel(
              id: "-1",
              sessionId: session.id!,
              scheduledAt: today,
              status: SessionStatus.scheduled,
            ),
          );
          return SessionWithInstanceModel(session: session, instance: instance);
        }).toList();
      });
    });
  }
}
