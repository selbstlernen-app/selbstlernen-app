import 'dart:async';

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:srl_app/core/utils/date_time_utils.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/domain/repositories/session_instance_repository.dart';
import 'package:srl_app/domain/repositories/session_repository.dart';

class GetSessionsForDateUseCase {
  GetSessionsForDateUseCase(this._sessionRepo, this._instanceRepo);

  final SessionRepository _sessionRepo;
  final SessionInstanceRepository _instanceRepo;

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

          // Look for instances for this date
          final dateInstances = sessionInstances
              .where(
                (i) =>
                    DateTimeUtils.isSameDay(i.completedAt, date) ||
                    DateTimeUtils.isSameDay(i.scheduledAt, date),
              )
              .toList();

          final relevantInstance =
              dateInstances.firstWhereOrNull(
                (i) => i.status == SessionStatus.inProgress,
              ) ??
              dateInstances.firstWhereOrNull(
                (i) =>
                    i.status != SessionStatus.completed &&
                    i.status != SessionStatus.skipped,
              ) ??
              dateInstances.firstOrNull;

          // Show if there's an in-progress instance OR no instances are done yet
          final hasInProgress = dateInstances.any(
            (i) => i.status == SessionStatus.inProgress,
          );

          final allCompleted =
              dateInstances.isNotEmpty &&
              dateInstances.every(
                (i) =>
                    i.status == SessionStatus.completed ||
                    i.status == SessionStatus.skipped,
              );

          // Show if there's an in-progress instance
          // OR no completed instance exists
          final shouldShow = hasInProgress || !allCompleted;

          // Add a pending instance, if it is not done
          // or null (no instance recorded yet)
          if (shouldShow) {
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
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final checkDate = DateTime(date.year, date.month, date.day);

      return checkDate.isAtSameMomentAs(today) || checkDate.isAfter(today);
    }

    if (date.isBefore(session.startDate!)) return false;

    if (session.endDate != null && date.isAfter(session.endDate!)) return false;
    return session.selectedDays.contains(date.weekday - 1);
  }
}
