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
    final Stream<List<SessionModel>> sessionsStream = _sessionRepo
        .watchAllActiveSessions();

    // Stream instances for given date
    final Stream<List<SessionInstanceModel>> instancesStream = _instanceRepo
        .watchAllInstancesForDate(date);

    return Rx.combineLatest2(sessionsStream, instancesStream, (
      List<SessionModel> sessions,
      List<SessionInstanceModel> instances,
    ) {
      final List<SessionWithInstanceModel> occurrences =
          <SessionWithInstanceModel>[];

      for (final SessionModel session in sessions) {
        // Check if session should occur on this date
        if (_shouldOccurOnDate(session, date)) {
          final SessionInstanceModel? instance = instances.firstWhereOrNull(
            (SessionInstanceModel i) => i.sessionId == session.id,
          );

          // If it should occur and cannot be found in the db yet;
          // then show the session w/o instance (for pending list)
          if (instance == null) {
            occurrences.add(
              SessionWithInstanceModel(session: session, instance: null),
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
