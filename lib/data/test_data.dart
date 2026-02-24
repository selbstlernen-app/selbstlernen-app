import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/focus_check.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';

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
      title: 'Vorlesung Nacharbeit - Informatik 1',
      isRepeating: true,
      startDate: DateTime(2026, 2),
      endDate: DateTime(2026, 2, 28),
      selectedDays: <int>[0, 1, 2, 3, 4, 5, 6],
      learningStrategyIds: <int>[1, 4],
      focusTimeMin: 30,
      complexity: SessionComplexity.advanced,
      createdAt: DateTime(2025, 11, 20),
    );

    final sessionId = await sessionRepo.addSession(testSession);

    final testInstances = <SessionInstanceModel>[
      // Completed sessions
      ...List<SessionInstanceModel>.generate(10, (int i) {
        final date = DateTime(
          2026,
          2,
          Random().nextInt(29),
          6 + Random().nextInt(12),
          Random().nextInt(61),
        ).add(Duration(days: i));

        final randomStatus = Random().nextInt(3);
        final levels = [
          FocusLevel.distracted,
          FocusLevel.okay,
          FocusLevel.good,
        ];

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
              atElapsedSeconds: 60,
              level: levels[randomStatus],
            ),
            FocusCheck(
              atElapsedSeconds: 120,
              level: levels[randomStatus],
            ),
            FocusCheck(
              atElapsedSeconds: 180,
              level: levels[randomStatus],
            ),
            FocusCheck(
              atElapsedSeconds: 240,
              level: levels[randomStatus],
            ),
            FocusCheck(
              atElapsedSeconds: 300,
              level: levels[randomStatus],
            ),
          ],
          completedGoalsRate: Random().nextDouble() * 100,
          completedTasksRate: Random().nextDouble() * 100,
          mood: Random().nextInt(5),
          notes: 'Completed successfully',
          completedAt: date,
          createdAt: date,
        );
      }),

      // Skipped sessions
      ...List<SessionInstanceModel>.generate(5, (int i) {
        final date = DateTime(2026, 2).add(Duration(days: i * 3));
        return SessionInstanceModel(
          sessionId: sessionId.toString(),
          status: SessionStatus.skipped,
          scheduledAt: date,
          completedAt: date,
          createdAt: DateTime(2026, 11, 20),
        );
      }),
    ];

    for (final instance in testInstances) {
      await instanceRepo.createInstance(instance: instance);
    }

    print('🎉 Test data insertion complete!');
  }
}
