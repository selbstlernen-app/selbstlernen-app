import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/models.dart';

part 'session_with_instance_model.freezed.dart';

@freezed
abstract class SessionWithInstanceModel with _$SessionWithInstanceModel {
  const SessionWithInstanceModel._();

  const factory SessionWithInstanceModel({
    required SessionModel session,
    SessionInstanceModel? todayInstance,
  }) = _SessionWithInstanceModel;

  // Helpers
  SessionStatus get todayStatus =>
      todayInstance?.status ?? SessionStatus.scheduled;
  bool get isCompletedToday => todayStatus == SessionStatus.completed;
  bool get isSkippedToday => todayStatus == SessionStatus.skipped;
  bool get canStartToday =>
      todayStatus == SessionStatus.scheduled ||
      todayStatus == SessionStatus.inProgress;
}
