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
      isPomodoro: isPomodoro,
      totalTimeMin: totalTimeMin,
      focusTimeMin: focusTimeMin,
      breakTimeMin: breakTimeMin,
      longBreakTimeMin: longBreakTimeMin,
      cyclesBeforeLongBreak: cyclesBeforeLongBreak,
      hasFocusPrompt: hasFocusPrompt,
      hasMoodPrompt: hasMoodPrompt,
      hasFreetextPrompt: hasFreetextPrompt,
      createdAt: createdAt,
    );
  }

  static List<SessionModel> mapFromListOfEntity(List<Session> entities) {
    return entities.map((e) => e.toDomain()).toList();
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
      isPomodoro: Value<bool>(isPomodoro),
      totalTimeMin: Value<int?>(totalTimeMin),
      focusTimeMin: Value<int?>(focusTimeMin),
      breakTimeMin: Value<int?>(breakTimeMin),
      longBreakTimeMin: Value<int?>(longBreakTimeMin),
      cyclesBeforeLongBreak: Value<int?>(cyclesBeforeLongBreak),
      hasFocusPrompt: Value<bool>(hasFocusPrompt),
      hasMoodPrompt: Value<bool>(hasMoodPrompt),
      hasFreetextPrompt: Value<bool>(hasFreetextPrompt),
      createdAt: Value<DateTime>(createdAt ?? DateTime.now()),
    );
  }
}
