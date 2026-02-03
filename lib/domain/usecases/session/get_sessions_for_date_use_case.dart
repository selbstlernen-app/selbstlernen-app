import 'dart:async';

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';

class GetSessionsForDateUseCase {
  GetSessionsForDateUseCase(this._sessionRepo, this._instanceRepo);

  final SessionRepository _sessionRepo;
  final SessionInstanceRepository _instanceRepo;

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Stream<List<SessionWithInstanceModel>> call(DateTime date) {
    // Stream all active (non-archived) sessions
    final sessionsStream = _sessionRepo.watchAllActiveSessionsForDate(date);

    // Stream instances for given date
    final instancesStream = _instanceRepo.watchAllInstancesForTheWeek(date);

    return Rx.combineLatest2(sessionsStream, instancesStream, (
      List<SessionModel> sessions,
      List<SessionInstanceModel> instances,
    ) {
      final occurrences = <SessionWithInstanceModel>[];

      for (final session in sessions) {
        // Check if session should occur on given date
        if (_shouldOccurOnDate(session, date)) {
          // Find instances for the date
          final sessionInstances = instances
              .where(
                (i) => i.sessionId == session.id,
              )
              .toList();

          // Look for any instances either completed or already scheduled for the date
          final relevantInstance = sessionInstances.firstWhereOrNull(
            (i) =>
                _isSameDay(i.completedAt, date) ||
                _isSameDay(i.scheduledAt, date),
          );

          // Check the status of the instance;
          // if its completed or skipped, then mark as done
          final isDone =
              relevantInstance?.status == SessionStatus.completed ||
              relevantInstance?.status == SessionStatus.skipped;

          // Add a pending instance, if it is not done or null (no instance recorded yet)
          if (!isDone) {
            occurrences.add(
              SessionWithInstanceModel(
                session: session,
                instance: relevantInstance,
              ),
            );
          }
        }
      }
      return occurrences;
    }).distinct();
  }

  /// Helper to check if a session should occur that day
  /// @returns true if its a one-time session
  /// @returns false if the dates are not matching
  bool _shouldOccurOnDate(SessionModel session, DateTime date) {
    if (session.isArchived) return false;

    if (!session.isRepeating) {
      return true;
    }

    if (date.isBefore(session.startDate!)) return false;
    if (session.endDate != null && date.isAfter(session.endDate!)) return false;
    return session.selectedDays.contains(date.weekday - 1);
  }
}
