import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_statistics.dart';

part 'detail_session_state.freezed.dart';

@freezed
abstract class DetailSessionState with _$DetailSessionState {
  const factory DetailSessionState({
    FullSessionModel? fullSession,
    List<SessionInstanceModel>? pastInstances,
    SessionStatistics? stats,
    @Default(true) bool isLoading,
    String? error,
  }) = _DetailSessionState;
}
