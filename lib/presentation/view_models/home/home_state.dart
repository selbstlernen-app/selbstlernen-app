import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';

part "home_state.freezed.dart";

@freezed
abstract class HomeState with _$HomeState {
  const HomeState._();

  const factory HomeState({
    @Default(<SessionWithInstanceModel>[])
    List<SessionWithInstanceModel> sessions,
    @Default(<SessionWithInstanceModel>[])
    List<SessionWithInstanceModel> completedSessionsForToday,
    @Default(SessionFilter.today) SessionFilter filter,
    @Default(false) bool isLoading,

    String? error,
  }) = _HomeState;
}

/// Enum for filtering the session according to
/// the buttons on the home screen
enum SessionFilter { today, thisWeek, all }
