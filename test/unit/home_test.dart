import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';
import 'package:srl_app/domain/usecases/session/get_completed_sessions_for_today_use_case.dart';
import 'package:srl_app/domain/usecases/session/get_sessions_for_date_use_case.dart';

class MockSessionRepository extends Mock implements SessionRepository {}

class MockSessionInstanceRepository extends Mock
    implements SessionInstanceRepository {}

void main() {
  test(
    'GetCompletedSessionsForTodayUseCase returns completed sessions',
    () async {
      final sessionRepo = MockSessionRepository();
      final instanceRepo = MockSessionInstanceRepository();

      final useCase = GetCompletedSessionsForTodayUseCase(
        sessionRepo,
        instanceRepo,
      );

      // ---- Test Data ----
      const session = SessionModel(
        id: '1',
        title: 'Mathe TEST-Vorlesung',
      );
      final completedInstance = SessionInstanceModel(
        sessionId: '1',
        scheduledAt: DateTime.now(),
        status: SessionStatus.completed,
      );

      // ---- Mock streams ----
      when(sessionRepo.watchAllSessions).thenAnswer(
        (_) => Stream<List<SessionModel>>.value(<SessionModel>[session]),
      );

      when(() => instanceRepo.watchAllInstancesForDate(any())).thenAnswer(
        (_) => Stream<List<SessionInstanceModel>>.value(<SessionInstanceModel>[
          completedInstance,
        ]),
      );

      // ---- Collect result ----
      final result = await useCase(
        DateTime.now(),
      ).first;

      expect(result.length, 1);
      expect(result.first.session, session);
      expect(result.first.instance, completedInstance);
    },
  );

  test('GetSessionsForDayUseCase returns sessions occurring today', () async {
    final sessionRepo = MockSessionRepository();
    final instanceRepo = MockSessionInstanceRepository();

    final useCase = GetSessionsForDateUseCase(
      sessionRepo,
      instanceRepo,
    );

    final now = DateTime(2025);

    // Session that should occur today
    const session_1 = SessionModel(
      id: '1',
      title: 'TEST EINHEIT 1',
    );

    const session_2 = SessionModel(
      id: '2',
      title: 'TEST EINHEIT 2',
    );

    // No instances should be found in repo for the sessions
    when(() => instanceRepo.watchAllInstancesForDate(any())).thenAnswer(
      (_) => Stream<List<SessionInstanceModel>>.value(<SessionInstanceModel>[]),
    );

    // When active session is watched, return both sessions
    // when(sessionRepo.watchAllActiveSessionsForDate(now)).thenAnswer(
    //   (_) => Stream<List<SessionModel>>.value(<SessionModel>[
    //     session_1,
    //     session_2,
    //   ]),
    // );

    final result = await useCase(now).first;

    expect(result.length, 2);
    // We expect first session; first in line
    expect(result.first.session, session_1);
    // Expect this to be a pending session; no instance linked to it yet
    expect(result.first.instance, null);
  });

  test('Skips repeating session on non-matching weekday', () async {
    final sessionRepo = MockSessionRepository();
    final instanceRepo = MockSessionInstanceRepository();

    final useCase = GetSessionsForDateUseCase(
      sessionRepo,
      instanceRepo,
    );

    final wednesday = DateTime(2025, 11, 5); // Wednesday

    final session = SessionModel(
      id: '1',
      title: 'TEST Sport machen',
      isRepeating: true,
      startDate: DateTime(2025, 11),
      endDate: DateTime(2025, 11, 23),
      selectedDays: <int>[0, 1, 4],
    );

    // when(sessionRepo.watchAllActiveSessions).thenAnswer(
    //   (_) => Stream<List<SessionModel>>.value(<SessionModel>[session]),
    // );

    when(() => instanceRepo.watchAllInstancesForDate(any())).thenAnswer(
      (_) => Stream<List<SessionInstanceModel>>.value(<SessionInstanceModel>[]),
    );

    final result = await useCase(
      wednesday,
    ).first;

    expect(result, isEmpty);
  });

  test('Repeating session is returned when the weekday matches', () async {
    final sessionRepo = MockSessionRepository();
    final instanceRepo = MockSessionInstanceRepository();

    final useCase = GetSessionsForDateUseCase(
      sessionRepo,
      instanceRepo,
    );

    final monday = DateTime(2025, 11, 3);

    final session = SessionModel(
      id: '1',
      title: 'TEST MONTAG',
      isRepeating: true,
      startDate: DateTime(2025, 11),
      endDate: DateTime(2025, 31),
      selectedDays: <int>[0],
    );

    when(() => instanceRepo.watchAllInstancesForDate(any())).thenAnswer(
      (_) => Stream<List<SessionInstanceModel>>.value(<SessionInstanceModel>[]),
    );

    // when(sessionRepo.watchAllActiveSessionsForDate()).thenAnswer(
    //   (_) => Stream<List<SessionModel>>.value(<SessionModel>[session]),
    // );

    final result = await useCase(monday).first;

    expect(result.length, 1);
    expect(result.first.session, session);
    expect(
      result.first.instance,
      null,
    ); // no instance; hence pending and displayed
  });
}
