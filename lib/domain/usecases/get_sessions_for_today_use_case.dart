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
      for (final SessionWithInstanceModel item in list) {
        if (item.instance!.id == "-1") {
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

      // Split list into non-repeating and repeating sessions
      final List<SessionModel> oneTimeSessions = todaysSessions
          .where((SessionModel s) => !s.isRepeating)
          .toList();
      final List<SessionModel> repeatingSessions = todaysSessions
          .where((SessionModel s) => s.isRepeating)
          .toList();

      final Stream<List<SessionInstanceModel>> oneTimeInstancesStream =
          oneTimeSessions.isEmpty
          ? Stream.value(<SessionInstanceModel>[])
          : Rx.combineLatestList(
              oneTimeSessions.map(
                (s) => instanceRepo.watchInstancesBySessionId(int.parse(s.id!)),
              ),
            ).map((listOfLists) => listOfLists.expand((e) => e).toList());

      // Get the stream of repeating instances - watch which ones we have scheduled for the day
      final Stream<List<SessionInstanceModel>> repeatingInstancesStream =
          repeatingSessions.isEmpty
          ? Stream.value(<SessionInstanceModel>[])
          : instanceRepo.watchAllInstancesForDate(today);

      return Rx.combineLatest2(
        repeatingInstancesStream,
        oneTimeInstancesStream,
        (
          List<SessionInstanceModel> repeatingInstances,
          List<SessionInstanceModel> oneTimeInstances,
        ) {
          final List<SessionInstanceModel> allInstances = [
            ...repeatingInstances,
            ...oneTimeInstances,
          ];

          return todaysSessions.map((SessionModel session) {
            final SessionInstanceModel instance = allInstances.firstWhere(
              (SessionInstanceModel i) =>
                  int.parse(i.sessionId) == int.parse(session.id!),
              orElse: () => SessionInstanceModel(
                id: "-1",
                sessionId: session.id!,
                scheduledAt: today,
                status: SessionStatus.scheduled,
              ),
            );
            return SessionWithInstanceModel(
              session: session,
              instance: instance,
            );
          }).toList();
        },
      );
    });
  }
}
