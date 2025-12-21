import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/view_models/general_statistics/ui_model/enriched_session_instance.dart';

part 'statistics_state.freezed.dart';

@freezed
abstract class StatisticsState with _$StatisticsState {
  const factory StatisticsState({
    GeneralStatistics? stats,
    List<SessionModel>? activeOrArchivedSessions,
    List<EnrichedSessionInstance>? enrichedInstances,
    @Default(true) bool isLoading,
    @Default(StatisticsFilter.running) filter,
    String? error,
  }) = _StatisticsState;

  const StatisticsState._();

  /// Returns any instance for the date, when status is NOT in progress
  /// i.e. any instances that are completed or skipped
  List<EnrichedSessionInstance> getInstancesByDateAndSorted(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    return enrichedInstances!.where((enrichedInstance) {
      if (enrichedInstance.instance.status == (SessionStatus.inProgress)) {
        return false;
      }

      final instanceDate = DateTime(
        enrichedInstance.instance.scheduledAt.year,
        enrichedInstance.instance.scheduledAt.month,
        enrichedInstance.instance.scheduledAt.day,
      );

      return instanceDate == normalizedDate;
    }).toList()..sort(
      (a, b) => a.instance.scheduledAt.compareTo(b.instance.scheduledAt),
    );
  }

  // Helper
  List<SessionModel> get activeSessions =>
      activeOrArchivedSessions!.where((s) => !s.isArchived).toList()
        ..sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));

  List<SessionModel> get archivedSessions =>
      activeOrArchivedSessions!.where((s) => s.isArchived).toList()
        ..sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
}

enum StatisticsFilter { archived, running }
