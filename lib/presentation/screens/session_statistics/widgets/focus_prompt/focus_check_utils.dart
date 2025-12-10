import 'package:srl_app/domain/models/focus_check.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

// Helper class for focus check calculation
class FocusCheckWithMinutes {
  FocusCheckWithMinutes(this.check, this.minutesIntoSession);
  final FocusCheck check;
  final int minutesIntoSession;
}

// Helper to convert focus checks to chart data
List<FocusCheckWithMinutes> prepareFocusCheckData(
  SessionInstanceModel instance,
) {
  if (instance.focusChecks.isEmpty) return [];

  final sessionStart = instance.scheduledAt;

  return instance.focusChecks.map((check) {
      final elapsed = check.timestamp.difference(sessionStart).inMinutes;
      return FocusCheckWithMinutes(check, elapsed);
    }).toList()
    ..sort((a, b) => a.minutesIntoSession.compareTo(b.minutesIntoSession));
}

double focusLevelToValue(FocusLevel level) {
  switch (level) {
    case FocusLevel.good:
      return 3;
    case FocusLevel.okay:
      return 2;
    case FocusLevel.distracted:
      return 1;
  }
}
