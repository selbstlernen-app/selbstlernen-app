import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    required DateTime dateToFilterFor,
    @Default(SessionFilter.all) SessionFilter filter,
    @Default(true) bool isLoading,
    String? error,
  }) = _HomeState;

  const HomeState._();
}

/// Enum for filtering the session according to
/// the buttons on the home screen
enum SessionFilter { open, done, skipped, all }
