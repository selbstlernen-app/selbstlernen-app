import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/general_statistics.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/presentation/view_models/statistics/ui_model/enriched_session_instance.dart';

part 'statistics_state.freezed.dart';

@freezed
abstract class StatisticsState with _$StatisticsState {
  const factory StatisticsState({
    GeneralStatistics? stats,
    List<double>? weekdayMinutes,
    List<EnrichedSessionInstance>? enrichedInstances,
    @Default(true) bool isLoading,
    String? error,
  }) = _StatisticsState;
  const StatisticsState._();

  List<EnrichedSessionInstance> getInstancesByDateAndSorted(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    return enrichedInstances!.where((enrichedInstance) {
      if (enrichedInstance.instance.status != SessionStatus.completed) {
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
}
