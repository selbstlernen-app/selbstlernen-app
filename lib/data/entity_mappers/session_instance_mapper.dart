import 'package:drift/drift.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';

extension SessionInstanceToModelMapper on SessionInstance {
  SessionInstanceModel toDomain() {
    return SessionInstanceModel(
      id: id.toString(),
      sessionId: sessionId.toString(),
      scheduledAt: scheduledAt,
      status: status,
      totalFocusPhases: (totalFocusPhases),
      totalCompletedBlocks: (totalCompletedBlocks),
      totalFocusSecondsElapsed: (totalFocusSecondsElapsed),
      totalBreakSecondsElapsed: totalBreakSecondsElapsed,
      totalCompletedGoals: totalCompletedGoals,
      totalCompletedTasks: totalCompletedTasks,
      mood: mood,
      notes: notes,
      completedAt: completedAt,
      createdAt: createdAt,
    );
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
      mood: mood != null ? Value<int>(mood!) : const Value<int>.absent(),
      notes: notes != null
          ? Value<String>(notes!)
          : const Value<String>.absent(),
      totalCompletedTasks: Value<int>(totalCompletedTasks),
      createdAt: Value<DateTime>(createdAt ?? DateTime.now()),
    );
  }
}
