import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_statistics.dart';

part 'statistics_state.freezed.dart';

@freezed
abstract class StatisticsState with _$StatisticsState {
  const factory StatisticsState({
    SessionStatistics? stats,
    List<double>? weekdayMinutes,
    List<SessionInstanceModel>? instances,
    @Default(true) bool isLoading,
    String? error,
  }) = _StatisticsState;
}
