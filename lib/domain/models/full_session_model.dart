import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/models.dart';

part 'full_session_model.freezed.dart';

@freezed
abstract class FullSessionModel with _$FullSessionModel {
  const factory FullSessionModel({
    required SessionModel session,
    @Default(<GoalModel>[]) List<GoalModel> goals,
    @Default(<TaskModel>[]) List<TaskModel> tasks,
  }) = _FullSessionModel;
}
