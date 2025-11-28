import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/domain/models/session_model.dart';

extension SessionToModelMapper on Session {
  SessionModel toDomain() {
    return SessionModel(
      id: id.toString(),
      title: title,
      isRepeating: isRepeating,
      startDate: startDate,
      endDate: endDate,
      selectedDays: selectedDays?.split(',').map(int.parse).toList() ?? <int>[],
      learningStrategies: learningStrategies?.split(',').toList() ?? <String>[],
      focusTimeMin: focusTimeMin,
      breakTimeMin: breakTimeMin,
      longBreakTimeMin: longBreakTimeMin,
      focusPhases: focusPhases,
      hasFocusPrompt: hasFocusPrompt,
      focusPromptInterval: focusPromptInterval,
      showFocusPromptAlways: showFocusPromptAlways,
      hasFreetextPrompt: hasFreetextPrompt,
      isArchived: isArchived,
      createdAt: createdAt,
    );
  }

  static List<SessionModel> mapFromListOfEntity(List<Session> entities) {
    return entities.map((Session e) => e.toDomain()).toList();
  }
}

extension SessionToCompanionMapper on SessionModel {
  SessionsCompanion toCompanion() {
    return SessionsCompanion(
      title: Value<String>(title),
      isRepeating: Value<bool>(isRepeating),
      startDate: Value<DateTime?>(startDate),
      endDate: Value<DateTime?>(endDate),
      selectedDays: Value<String?>(
        selectedDays.isNotEmpty ? selectedDays.join(',') : null,
      ),
      learningStrategies: Value<String?>(
        learningStrategies.isNotEmpty ? learningStrategies.join(',') : null,
      ),
      focusTimeMin: Value<int>(focusTimeMin),
      breakTimeMin: Value<int>(breakTimeMin),
      longBreakTimeMin: Value<int>(longBreakTimeMin),
      focusPhases: Value<int>(focusPhases),
      hasFocusPrompt: Value<bool>(hasFocusPrompt),
      focusPromptInterval: Value<int>(focusPromptInterval),
      showFocusPromptAlways: Value<bool>(showFocusPromptAlways),
      hasFreetextPrompt: Value<bool>(hasFreetextPrompt),
      isArchived: Value<bool>(isArchived),
      createdAt: Value<DateTime>(createdAt ?? DateTime.now()),
    );
  }

  // Used when updating a session (in edit mode)
  SessionsCompanion toUpdateCompanion() {
    return SessionsCompanion(
      title: Value<String>(title),
      isRepeating: Value<bool>(isRepeating),
      startDate: Value<DateTime?>(startDate),
      endDate: Value<DateTime?>(endDate),
      selectedDays: Value<String?>(
        selectedDays.isNotEmpty ? selectedDays.join(',') : null,
      ),
      learningStrategies: Value<String?>(
        learningStrategies.isNotEmpty ? learningStrategies.join(',') : null,
      ),
      focusTimeMin: Value<int>(focusTimeMin),
      breakTimeMin: Value<int>(breakTimeMin),
      longBreakTimeMin: Value<int>(longBreakTimeMin),
      focusPhases: Value<int>(focusPhases),
      hasFocusPrompt: Value<bool>(hasFocusPrompt),
      focusPromptInterval: Value<int>(focusPromptInterval),
      showFocusPromptAlways: Value<bool>(showFocusPromptAlways),
      hasFreetextPrompt: Value<bool>(hasFreetextPrompt),
      isArchived: Value<bool>(isArchived),
    );
  }
}
