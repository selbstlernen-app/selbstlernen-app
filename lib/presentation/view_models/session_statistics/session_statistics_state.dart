import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/core/utils/session_utils.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_statistics.dart';

part 'session_statistics_state.freezed.dart';

@freezed
abstract class SessionStatisticsState with _$SessionStatisticsState {
  const factory SessionStatisticsState({
    /// Calculated statistics of the session and its instances
    SessionStatistics? stats,

    /// The session for the statistics
    SessionModel? session,

    /// All instances of the specific session
    /// (skipped, inProgress, or completed)
    List<SessionInstanceModel>? instances,

    /// The currently total goals and tasks associated with the session
    int? totalGoals,
    int? totalTasks,

    @Default(true) bool isLoading,
    String? error,
  }) = _SessionStatisticsState;

  const SessionStatisticsState._();

  /// Calculates a list of (temporary) session instances if any were
  /// missed and not done on a specified date
  List<SessionInstanceModel> get missedInstances {
    if (instances == null || session == null || !session!.isRepeating) {
      return [];
    }

    // Index existing instances by their date
    final instanceByDate = {
      for (final inst in instances!)
        if (inst.completedAt != null)
          DateTime(
            inst.completedAt!.year,
            inst.completedAt!.month,
            inst.completedAt!.day,
          ): inst,
    };

    final missed = <SessionInstanceModel>[];

    for (final date in generateScheduledDates(
      session!.startDate!,
      session!.selectedDays,
    )) {
      if (!instanceByDate.containsKey(date)) {
        // Create a fake instance for display purposes
        missed.add(
          SessionInstanceModel(
            sessionId: session!.id!,
            id: 'missed-${date.toIso8601String()}',
            completedAt: date,
            scheduledAt: date,
            status: SessionStatus.missed,
          ),
        );
      }
    }

    return missed;
  }

  List<SessionInstanceModel> get allInstances => [
    ...instances!,
    ...missedInstances,
  ];
}
