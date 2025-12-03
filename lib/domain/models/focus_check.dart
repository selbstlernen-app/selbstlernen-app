import 'package:freezed_annotation/freezed_annotation.dart';

part 'focus_check.freezed.dart';

@freezed
abstract class FocusCheck with _$FocusCheck {
  const factory FocusCheck({
    required DateTime timestamp,
    required FocusLevel level,
  }) = _FocusCheck;
}

enum FocusLevel {
  // Gut
  good,
  // Geht so
  okay,
  // Abgelenkt
  distracted,
  // User clicked on "Weiter arbeiten" without clicking any of the three options
  skipped,
}
