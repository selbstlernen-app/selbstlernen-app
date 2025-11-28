import 'package:srl_app/domain/session_instance_repository.dart';

/// Use case for statistics; we want to display for every day,
/// the amount we learned
/// specific to the session itself
class GetFocusMinutesByWeekdayUseCase {
  const GetFocusMinutesByWeekdayUseCase(this.instanceRepository);

  final SessionInstanceRepository instanceRepository;

  Future<List<double>> call(int sessionId) async {
    final instances = await instanceRepository.getAllInstancesBySessionId(
      sessionId,
    );

    // Monday to Sunday (0–6)
    final weekdayMinutes = List<double>.filled(7, 0);

    for (final inst in instances) {
      if (inst.completedAt == null) continue;

      final weekdayIndex = inst.completedAt!.weekday - 1;
      final minutes = inst.totalFocusSecondsElapsed / 60.0;

      weekdayMinutes[weekdayIndex] += minutes;
    }

    return weekdayMinutes;
  }
}
