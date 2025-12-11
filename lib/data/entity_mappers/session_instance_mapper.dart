import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/domain/models/focus_check.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

extension SessionInstanceToModelMapper on SessionInstance {
  SessionInstanceModel toDomain() {
    return SessionInstanceModel(
      id: id.toString(),
      sessionId: sessionId.toString(),
      scheduledAt: scheduledAt,
      status: status,
      totalFocusPhases: totalFocusPhases,
      totalCompletedBlocks: totalCompletedBlocks,
      totalFocusSecondsElapsed: totalFocusSecondsElapsed,
      totalBreakSecondsElapsed: totalBreakSecondsElapsed,
      totalCompletedGoals: totalCompletedGoals,
      totalCompletedTasks: totalCompletedTasks,
      completedGoalsRate: completedGoalsRate,
      completedTasksRate: completedTasksRate,
      currentPhaseIndex: currentPhaseIndex,
      remainingSeconds: remainingSeconds,
      mood: mood,
      notes: notes,
      completedAt: completedAt,
      createdAt: createdAt,
      focusChecks: _focusChecksFromJson(focusChecksJson),
    );
  }

  static List<FocusCheck> _focusChecksFromJson(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return [];
      final list = decoded;

      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return FocusCheck(
          atElapsedSeconds: map['atElapsedSeconds'] as int,
          level: FocusLevel.values.firstWhere(
            (e) => e.name == map['level'],
          ),
        );
      }).toList();
    } on Exception catch (_) {
      return []; // Return empty list if JSON is invalid
    }
  }

  static List<SessionInstanceModel> mapFromListOfEntity(
    List<SessionInstance> entities,
  ) {
    return entities.map((SessionInstance e) => e.toDomain()).toList();
  }
}

extension SessionInstanceToCompanion on SessionInstanceModel {
  SessionInstancesCompanion toCompanion() {
    return SessionInstancesCompanion(
      sessionId: Value<int>(int.parse(sessionId)),
      completedAt: completedAt != null
          ? Value<DateTime>(completedAt!)
          : const Value<DateTime>.absent(),
      status: Value<SessionStatus>(status),
      scheduledAt: Value<DateTime>(scheduledAt),
      totalFocusPhases: Value<int>(totalFocusPhases),
      totalCompletedBlocks: Value<int>(totalCompletedBlocks),
      totalFocusSecondsElapsed: Value<int>(totalFocusSecondsElapsed),
      totalBreakSecondsElapsed: Value<int>(totalBreakSecondsElapsed),
      totalCompletedGoals: Value<int>(totalCompletedGoals),
      totalCompletedTasks: Value<int>(totalCompletedTasks),
      completedGoalsRate: Value<double>(completedGoalsRate),
      completedTasksRate: Value<double>(completedTasksRate),
      currentPhaseIndex: Value<int>(currentPhaseIndex),
      remainingSeconds: Value<int?>(remainingSeconds),
      mood: mood != null ? Value<int>(mood!) : const Value<int>.absent(),
      notes: notes != null
          ? Value<String>(notes!)
          : const Value<String>.absent(),

      focusChecksJson: Value<String>(_focusChecksToJson(focusChecks)),
      createdAt: Value<DateTime>(createdAt ?? DateTime.now()),
    );
  }

  SessionInstancesCompanion toUpdateCompanion() {
    return SessionInstancesCompanion(
      completedAt: completedAt != null
          ? Value<DateTime>(completedAt!)
          : const Value<
              DateTime
            >.absent(), // should not update; only when passed
      status: Value<SessionStatus>(status),
      totalFocusPhases: Value<int>(totalFocusPhases),
      totalCompletedBlocks: Value<int>(totalCompletedBlocks),
      totalFocusSecondsElapsed: Value<int>(totalFocusSecondsElapsed),
      totalBreakSecondsElapsed: Value<int>(totalBreakSecondsElapsed),
      totalCompletedGoals: Value<int>(totalCompletedGoals),
      totalCompletedTasks: Value<int>(totalCompletedTasks),
      completedGoalsRate: Value<double>(completedGoalsRate),
      completedTasksRate: Value<double>(completedTasksRate),
      currentPhaseIndex: Value<int>(currentPhaseIndex),
      remainingSeconds: Value<int?>(remainingSeconds),
      mood: mood != null ? Value<int>(mood!) : const Value<int>.absent(),
      notes: notes != null
          ? Value<String>(notes!)
          : const Value<String>.absent(),

      focusChecksJson: Value<String>(_focusChecksToJson(focusChecks)),
    );
  }

  static String _focusChecksToJson(List<FocusCheck> focusChecks) {
    return jsonEncode(
      focusChecks
          .map(
            (check) => {
              'atElapsedSeconds': check.atElapsedSeconds,
              'level': check.level.name,
            },
          )
          .toList(),
    );
  }
}
