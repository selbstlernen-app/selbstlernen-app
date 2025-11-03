import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:srl_app/domain/models/models.dart';

part "home_state.freezed.dart";

@freezed
abstract class HomeState with _$HomeState {
  const HomeState._();

  const factory HomeState({
    @Default(<SessionModel>[]) List<SessionModel> sessions,
    @Default(SessionFilter.today) SessionFilter filter,
    @Default(false) bool isLoading,
    String? error,
  }) = _HomeState;

  // Getter for filter on home screen
  List<SessionModel> get filteredSessions {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime endOfWeek = today.add(Duration(days: 7 - today.weekday));

    switch (filter) {
      // Return any session
      case SessionFilter.all:
        return sessions;

      case SessionFilter.today:
        return sessions.where((SessionModel session) {
          if (session.isRepeating) {
            // Check if session occurs today
            return session.selectedDays.contains(today.weekday) &&
                (session.startDate?.isBefore(
                      today.add(const Duration(days: 1)),
                    ) ??
                    false) &&
                (session.endDate?.isAfter(today) ?? false);
          } else {
            // If one-time session always show
            return true;
          }
        }).toList();

      case SessionFilter.thisWeek:
        return sessions.where((SessionModel session) {
          if (session.isRepeating) {
            // Check if session occurs this week
            return (session.startDate?.isBefore(
                      endOfWeek.add(const Duration(days: 1)),
                    ) ??
                    false) &&
                (session.endDate?.isAfter(today) ?? false);
          } else {
            // If one-time session always show
            return true;
          }
        }).toList();
    }
  }
}

/// Enum for filtering the session according to
/// the buttons on the home screen
enum SessionFilter { today, thisWeek, all }
