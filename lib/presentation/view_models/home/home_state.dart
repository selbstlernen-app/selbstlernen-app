import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(<SessionWithInstanceModel>[])
    List<SessionWithInstanceModel> todaysSessions,

    @Default(<SessionWithInstanceModel>[])
    List<SessionWithInstanceModel> completedSessionsForToday,

    @Default(SessionFilter.all) SessionFilter filter,
    @Default(false) bool isLoading,

    String? error,
  }) = _HomeState;

  const HomeState._();

  List<SessionWithInstanceModel> get skippedSessionsForToday =>
      completedSessionsForToday.where((i) => i.isSkipped).toList();
}

/// Enum for filtering the session according to
/// the buttons on the home screen
enum SessionFilter { open, done, skipped, all }
