import 'package:freezed_annotation/freezed_annotation.dart';

part 'general_statistics.freezed.dart';

@freezed
abstract class GeneralStatistics with _$GeneralStatistics {
  const factory GeneralStatistics({
    required int totalInstances,
    required int totalFocusMinutes,
    required int totalGoalsCompleted,
    required int totalTasksCompleted,
  }) = _GeneralStatistics;
}
