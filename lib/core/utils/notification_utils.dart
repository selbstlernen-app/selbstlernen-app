import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';

class NotificationUtils {
  static String getPhaseLabel(SessionPhase phase) {
    switch (phase) {
      case SessionPhase.focus:
        return '🧠 Fokuszeit';
      case SessionPhase.shortBreak:
        return '☕️ Kurze Pause';
      case SessionPhase.longBreak:
        return '😌 Lange Pause';
    }
  }

  static String getSubtitle(SessionPhase phase) {
    switch (phase) {
      case SessionPhase.focus:
        return 'Bleib fokussiert!';
      case SessionPhase.shortBreak:
        return 'Zeit zum Aufstehen und kurz Durchatmen';
      case SessionPhase.longBreak:
        return 'Lass die Arbeit kurz hinter dir und entspann dich';
    }
  }
}
