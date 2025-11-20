import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_statistics.dart';

part 'session_statistics_state.freezed.dart';

@freezed
abstract class SessionStatisticsState with _$SessionStatisticsState {
  const factory SessionStatisticsState({
    SessionStatistics? stats,
    List<SessionInstanceModel>? instances,
    List<double>? weekdayMinutes,
    @Default(true) bool isLoading,
    String? error,
  }) = _SessionStatisticsState;
}
