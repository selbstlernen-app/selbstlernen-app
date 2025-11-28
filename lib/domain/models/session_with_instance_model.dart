import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/models.dart';

part 'session_with_instance_model.freezed.dart';

@freezed
abstract class SessionWithInstanceModel with _$SessionWithInstanceModel {

  const factory SessionWithInstanceModel({
    required SessionModel session,
    // Instance; if any was created yet
    SessionInstanceModel? instance,
  }) = _SessionWithInstanceModel;
  const SessionWithInstanceModel._();

  // Helpers
  SessionStatus get todayStatus => instance?.status ?? SessionStatus.scheduled;
  bool get isCompleted => todayStatus == SessionStatus.completed;
  bool get isSkipped => todayStatus == SessionStatus.skipped;
  bool get canStartToday =>
      todayStatus == SessionStatus.scheduled ||
      todayStatus == SessionStatus.inProgress;
}
