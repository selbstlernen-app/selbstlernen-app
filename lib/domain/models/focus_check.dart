import 'package:freezed_annotation/freezed_annotation.dart';

part 'focus_check.freezed.dart';

@freezed
abstract class FocusCheck with _$FocusCheck {
  const factory FocusCheck({
    // Tracks the time that has elapsed when the prompt appeared
    required int atElapsedSeconds,

    // The focus level
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
}
