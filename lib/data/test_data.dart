import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';

part 'test_data.g.dart';

@riverpod
class TestData extends _$TestData {
  @override
  void build() {}

  Future<void> insertTestData() async {
    final SessionRepository sessionRepo = ref.read(sessionRepositoryProvider);
    final SessionInstanceRepository instanceRepo = ref.read(
      sessionInstanceRepositoryProvider,
    );

    print("Inserting test data");

    final SessionModel testSession = SessionModel(
      title: "Deep Learning / Fokus Block",
      isRepeating: true,
      startDate: DateTime(2024, 12, 1),
      endDate: DateTime(2025, 1, 15),
      selectedDays: <int>[0, 2, 4], // Monday, Wednesday, Friday
      learningStrategies: <String>["Pomodoro", "Active Recall", "Feynman"],
      focusTimeMin: 50,
      breakTimeMin: 10,
      longBreakTimeMin: 20,
      focusPhases: 4,
      hasFocusPrompt: true,
      hasFreetextPrompt: true,
      createdAt: DateTime(2024, 11, 20),
    );

    int sessionId = await sessionRepo.addSession(testSession);

    print("✔ Inserted SessionModel");

    final List<SessionInstanceModel> testInstances = <SessionInstanceModel>[
      // Completed sessions
      ...List<SessionInstanceModel>.generate(30, (int i) {
        return SessionInstanceModel(
          sessionId: sessionId.toString(),
          status: SessionStatus.completed,
          scheduledAt: DateTime(2024, 12, 1).add(Duration(days: i)),
          totalFocusPhases: 4,
          totalCompletedBlocks: 4,
          totalFocusSecondsElapsed: 50 * 60,
          totalBreakSecondsElapsed: 10 * 60,
          totalCompletedGoals: 2,
          totalCompletedTasks: 4,
          mood: (3 + (i % 3)),
          notes: "Completed successfully",
          completedAt: DateTime(2024, 12, 1).add(Duration(days: i, hours: 2)),
          createdAt: DateTime(2024, 11, 20),
        );
      }),

      // Skipped sessions
      ...List<SessionInstanceModel>.generate(5, (int i) {
        return SessionInstanceModel(
          sessionId: sessionId.toString(),
          status: SessionStatus.skipped,
          scheduledAt: DateTime(2024, 12, 5).add(Duration(days: i * 3)),
          notes: "Skipped due to lack of time",
          createdAt: DateTime(2024, 11, 20),
        );
      }),

      // In-progress sessions
      ...List<SessionInstanceModel>.generate(7, (int i) {
        return SessionInstanceModel(
          sessionId: sessionId.toString(),
          status: SessionStatus.inProgress,
          scheduledAt: DateTime(2024, 12, 10).add(Duration(days: i * 2)),
          totalFocusPhases: 1,
          totalFocusSecondsElapsed: 10 * 60,
          totalBreakSecondsElapsed: 2 * 60,
          notes: "Currently working",
          createdAt: DateTime(2024, 11, 20),
        );
      }),
    ];

    for (final SessionInstanceModel instance in testInstances) {
      await instanceRepo.createInstance(instance: instance);
    }

    print(
      "✔ Inserted ${testInstances.length} SessionInstanceModels for session with id $sessionId",
    );

    print("🎉 Test data insertion complete!");
  }
}
