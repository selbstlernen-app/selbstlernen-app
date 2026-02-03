import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/models/session_statistics.dart';

part 'detail_session_state.freezed.dart';

@freezed
abstract class DetailSessionState with _$DetailSessionState {
  const factory DetailSessionState({
    FullSessionModel? fullSession,
    SessionInstanceModel? instance,
    @Default(0) int pastInstancesLength,
    SessionStatistics? stats,
    @Default(true) bool isLoading,
    String? error,
  }) = _DetailSessionState;

  const DetailSessionState._();

  bool get hasSession => fullSession != null;
  bool get hasInstance => instance != null;
  bool get hasError => error != null;

  SessionModel? get session => fullSession?.session;
  List<GoalModel> get goals => fullSession?.goals ?? [];
  List<TaskModel> get tasks => fullSession?.tasks ?? [];

  bool get canArchive => hasSession && !(session?.isArchived ?? true);
  bool get canDelete => hasSession;
  bool get canRedoSession => hasInstance;
  bool get canStartSession => hasSession && !hasInstance;
  bool get hasPastSessions => pastInstancesLength > 0;
}
