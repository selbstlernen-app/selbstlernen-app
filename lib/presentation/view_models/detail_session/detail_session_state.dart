import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/full_session_model.dart';

part "detail_session_state.freezed.dart";

@freezed
abstract class DetailSessionState with _$DetailSessionState {
  const factory DetailSessionState({required FullSessionModel fullSession}) =
      _DetailSessionState;
}
