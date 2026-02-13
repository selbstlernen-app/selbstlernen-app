import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';

extension SessionToModelMapper on Session {
  SessionModel toDomain(List<int>? strategyIds) {
    return SessionModel(
      id: id.toString(),
      title: title,
      isRepeating: isRepeating,
      plannedTime: plannedTime,
      complexity: complexity,
      hasNotification: hasNotification,
      startDate: startDate,
      endDate: endDate,
      selectedDays: selectedDays?.split(',').map(int.parse).toList() ?? <int>[],
      learningStrategyIds: strategyIds ?? <int>[],
      focusTimeMin: focusTimeMin,
      breakTimeMin: breakTimeMin,
      pomodoroPhases: pomodoroPhases,
      hasFocusPrompt: hasFocusPrompt,
      focusPromptInterval: focusPromptInterval,
      showFocusPromptAlways: showFocusPromptAlways,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static List<SessionModel> mapFromListOfEntity(
    List<Session> entities, [
    Map<int, List<int>>? sessionStrategyMap,
  ]) {
    return entities.map((Session e) {
      final strategyIds = sessionStrategyMap?[e.id] ?? <int>[];
      return e.toDomain(strategyIds);
    }).toList();
  }
}

extension SessionToCompanionMapper on SessionModel {
  SessionsCompanion toCompanion() {
    return SessionsCompanion(
      title: Value<String>(title),
      isRepeating: Value<bool>(isRepeating),

      plannedTime: Value<TimeOfDay>(plannedTime),
      hasNotification: Value<bool>(hasNotification),
      complexity: Value<SessionComplexity>(complexity),

      startDate: Value<DateTime?>(startDate),
      endDate: Value<DateTime?>(endDate),
      selectedDays: Value<String?>(
        selectedDays.isNotEmpty ? selectedDays.join(',') : null,
      ),

      focusTimeMin: Value<int>(focusTimeMin),
      breakTimeMin: Value<int>(breakTimeMin),
      pomodoroPhases: Value<int>(pomodoroPhases),
      hasFocusPrompt: Value<bool>(hasFocusPrompt),
      focusPromptInterval: Value<int>(focusPromptInterval),
      showFocusPromptAlways: Value<bool>(showFocusPromptAlways),
      isArchived: Value<bool>(isArchived),
      createdAt: Value<DateTime>(createdAt ?? DateTime.now()),
      updatedAt: Value<DateTime>(updatedAt ?? DateTime.now()),
    );
  }

  // Used when updating a session (in edit mode)
  SessionsCompanion toUpdateCompanion() {
    return SessionsCompanion(
      title: Value<String>(title),
      isRepeating: Value<bool>(isRepeating),

      plannedTime: Value<TimeOfDay>(plannedTime),
      hasNotification: Value<bool>(hasNotification),

      startDate: Value<DateTime?>(startDate),
      endDate: Value<DateTime?>(endDate),
      selectedDays: Value<String?>(
        selectedDays.isNotEmpty ? selectedDays.join(',') : null,
      ),

      focusTimeMin: Value<int>(focusTimeMin),
      breakTimeMin: Value<int>(breakTimeMin),
      pomodoroPhases: Value<int>(pomodoroPhases),
      hasFocusPrompt: Value<bool>(hasFocusPrompt),
      focusPromptInterval: Value<int>(focusPromptInterval),
      showFocusPromptAlways: Value<bool>(showFocusPromptAlways),
      isArchived: Value<bool>(isArchived),
      updatedAt: Value<DateTime>(DateTime.now()),
    );
  }
}

class TimeOfDayConverter extends TypeConverter<TimeOfDay, int> {
  const TimeOfDayConverter();
  @override
  TimeOfDay fromSql(int fromDb) =>
      TimeOfDay(hour: fromDb ~/ 60, minute: fromDb % 60);
  @override
  int toSql(TimeOfDay value) => value.hour * 60 + value.minute;
}
