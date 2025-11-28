import 'dart:async';

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';

class GetSessionsForTodayUseCase {
  GetSessionsForTodayUseCase(this._sessionRepo, this._instanceRepo);

  final SessionRepository _sessionRepo;
  final SessionInstanceRepository _instanceRepo;

  Stream<List<SessionWithInstanceModel>> call(DateTime date) {
    // Stream active (non-archived) sessions
    final sessionsStream = _sessionRepo.watchAllActiveSessions();

    // Stream instances for given date
    final instancesStream = _instanceRepo.watchAllInstancesForDate(date);

    return Rx.combineLatest2(sessionsStream, instancesStream, (
      List<SessionModel> sessions,
      List<SessionInstanceModel> instances,
    ) {
      final occurrences = <SessionWithInstanceModel>[];

      for (final session in sessions) {
        // Check if session should occur on this date
        if (_shouldOccurOnDate(session, date)) {
          final instance = instances.firstWhereOrNull(
            (SessionInstanceModel i) => i.sessionId == session.id,
          );

          // Adds an instance if
          // 1. it should occur on the day, but cannot be found yet in the db
          // 2. it was created once, but not completed yet for the given date
          if (instance == null ||
              instance.status == SessionStatus.inProgress ||
              instance.status == SessionStatus.scheduled) {
            occurrences.add(
              SessionWithInstanceModel(session: session, instance: instance),
            );
          }
        }
      }

      return occurrences;
    });
  }

  /// Helper to check if a session should occur that day
  /// @returns true if its a one-time session
  /// @returns false if the dates are not matching
  bool _shouldOccurOnDate(SessionModel session, DateTime date) {
    if (session.isArchived) return false;

    if (!session.isRepeating) {
      return true;
    }

    // For scheduled sessions
    if (date.isBefore(session.startDate!)) return false;
    if (session.endDate != null && date.isAfter(session.endDate!)) return false;
    return session.selectedDays.contains(date.weekday - 1);
  }
}
