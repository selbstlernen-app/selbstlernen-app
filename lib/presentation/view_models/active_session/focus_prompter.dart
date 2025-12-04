import 'dart:async';

import 'package:srl_app/domain/models/session_model.dart';

/// Prompter class holding all methods for the focus prompter appearing during
/// an active session
class FocusPrompter {
  FocusPrompter({required this.session, required this.onPromptTrigger});

  Timer? _promptTimer;
  DateTime? _lastInteractionTime;
  final SessionModel session;
  final void Function() onPromptTrigger;

  void startPrompting() {
    if (!session.hasFocusPrompt) return;

    _lastInteractionTime = DateTime.now();
    _scheduleNextPrompt();
  }

  void stopPrompting() {
    _promptTimer?.cancel();
    _promptTimer = null;
  }

  void recordInteraction() {
    _lastInteractionTime = DateTime.now();
  }

  void _scheduleNextPrompt() {
    _promptTimer?.cancel();
    _promptTimer = Timer(
      Duration(minutes: session.focusPromptInterval),
      _handlePromptTrigger,
    );
  }

  void _handlePromptTrigger() {
    if (session.showFocusPromptAlways || _isUserInactive()) {
      onPromptTrigger();
    }
    _scheduleNextPrompt();
  }

  /// Checks the duration a user has been last active
  /// Turns true when half the focus prompt duration
  /// no interaction has been recorded
  bool _isUserInactive() {
    if (_lastInteractionTime == null) return true;
    final inactiveDuration = DateTime.now().difference(_lastInteractionTime!);

    return inactiveDuration.inMinutes >= (session.focusPromptInterval / 2);
  }

  void dispose() {
    stopPrompting();
  }
}
