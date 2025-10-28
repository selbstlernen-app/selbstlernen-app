import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/models.dart';

part "home_state.freezed.dart";

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(<SessionModel>[]) List<SessionModel> sessions,
    @Default(false) bool isLoading,
    String? error,
  }) = _HomeState;
}
