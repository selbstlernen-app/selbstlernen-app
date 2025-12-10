import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/focus_check.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';

part 'test_data.g.dart';

@riverpod
class TestData extends _$TestData {
  @override
  void build() {}

  Future<void> insertTestData() async {
    final sessionRepo = ref.read(sessionRepositoryProvider);
    final instanceRepo = ref.read(
      sessionInstanceRepositoryProvider,
    );

    final testSession = SessionModel(
      title: 'fds Learning / Fokus Block',
      isRepeating: true,
      startDate: DateTime(2025, 11),
      endDate: DateTime(2026, 1, 15),
      selectedDays: <int>[0, 1, 2, 3, 4, 5, 6],
      learningStrategies: <String>['Pomodoro', 'Active Recall', 'Feynman'],
      focusTimeMin: 50,
      breakTimeMin: 10,
      longBreakTimeMin: 20,
      createdAt: DateTime(2025, 11, 20),
    );

    final sessionId = await sessionRepo.addSession(testSession);

    final testInstances = <SessionInstanceModel>[
      // Completed sessions
      ...List<SessionInstanceModel>.generate(10, (int i) {
        final date = DateTime(
          2025,
          11,
          1,
          6 + Random().nextInt(12),
          0 + Random().nextInt(60),
        ).add(Duration(days: i));
        return SessionInstanceModel(
          sessionId: sessionId.toString(),
          status: SessionStatus.completed,
          scheduledAt: date,
          totalFocusPhases: 4,
          totalCompletedBlocks: 4,
          totalFocusSecondsElapsed: 50 * 60,
          totalBreakSecondsElapsed: 10 * 60,
          totalCompletedGoals: 2,
          totalCompletedTasks: 4,
          focusChecks: [
            FocusCheck(
              timestamp: date.add(const Duration(minutes: 5)),
              level: FocusLevel.good,
            ),
            FocusCheck(
              timestamp: date.add(const Duration(minutes: 10)),
              level: FocusLevel.good,
            ),
            FocusCheck(
              timestamp: date.add(const Duration(minutes: 15)),
              level: FocusLevel.okay,
            ),
            FocusCheck(
              timestamp: date.add(const Duration(minutes: 20)),
              level: FocusLevel.okay,
            ),
            FocusCheck(
              timestamp: date.add(const Duration(minutes: 25)),
              level: FocusLevel.distracted,
            ),
            FocusCheck(
              timestamp: date.add(const Duration(minutes: 30)),
              level: FocusLevel.okay,
            ),
            FocusCheck(
              timestamp: date.add(const Duration(minutes: 35)),
              level: FocusLevel.good,
            ),
            FocusCheck(
              timestamp: date.add(const Duration(minutes: 40)),
              level: FocusLevel.good,
            ),
            FocusCheck(
              timestamp: date.add(const Duration(minutes: 45)),
              level: FocusLevel.good,
            ),
            FocusCheck(
              timestamp: date.add(const Duration(minutes: 50)),
              level: FocusLevel.good,
            ),
          ],
          completedGoalsRate: Random().nextDouble() * 100,
          completedTasksRate: Random().nextDouble() * 100,
          mood: Random().nextInt(5),
          notes: 'Completed successfully',
          completedAt: DateTime(
            2025,
            11,
            1,
            6 + Random().nextInt(12),
            Random().nextInt(61),
          ).add(Duration(days: i)),
          createdAt: DateTime(2025, 11, 20),
        );
      }),

      // Skipped sessions
      ...List<SessionInstanceModel>.generate(5, (int i) {
        final date = DateTime(2025, 10, 5).add(Duration(days: i * 3));
        return SessionInstanceModel(
          sessionId: sessionId.toString(),
          status: SessionStatus.skipped,
          scheduledAt: date,
          completedAt: date,
          createdAt: DateTime(2025, 11, 20),
        );
      }),
    ];

    for (final instance in testInstances) {
      await instanceRepo.createInstance(instance: instance);
    }

    print('🎉 Test data insertion complete!');
  }
}
