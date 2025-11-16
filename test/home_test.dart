import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';
import 'package:srl_app/domain/usecases/session/get_completed_sessions_for_today_use_case.dart';
import 'package:srl_app/domain/usecases/session/get_sessions_for_today_use_case.dart';

class MockSessionRepository extends Mock implements SessionRepository {}

class MockSessionInstanceRepository extends Mock
    implements SessionInstanceRepository {}

void main() {
  test(
    'GetCompletedSessionsForTodayUseCase returns completed sessions',
    () async {
      final MockSessionRepository sessionRepo = MockSessionRepository();
      final MockSessionInstanceRepository instanceRepo =
          MockSessionInstanceRepository();

      final GetCompletedSessionsForTodayUseCase useCase =
          GetCompletedSessionsForTodayUseCase(sessionRepo, instanceRepo);

      // ---- Test Data ----
      final SessionModel session = const SessionModel(
        id: '1',
        title: 'Mathe TEST-Vorlesung',
      );
      final SessionInstanceModel completedInstance = SessionInstanceModel(
        sessionId: '1',
        scheduledAt: DateTime.now(),
        status: SessionStatus.completed,
      );

      // ---- Mock streams ----
      when(() => sessionRepo.watchAllSessions()).thenAnswer(
        (_) => Stream<List<SessionModel>>.value(<SessionModel>[session]),
      );

      when(() => instanceRepo.watchAllInstancesForDate(any())).thenAnswer(
        (_) => Stream<List<SessionInstanceModel>>.value(<SessionInstanceModel>[
          completedInstance,
        ]),
      );

      // ---- Collect result ----
      final List<SessionWithInstanceModel> result = await useCase(
        DateTime.now(),
      ).first;

      expect(result.length, 1);
      expect(result.first.session, session);
      expect(result.first.instance, completedInstance);
    },
  );

  test('GetSessionsForTodayUseCase returns sessions occurring today', () async {
    final MockSessionRepository sessionRepo = MockSessionRepository();
    final MockSessionInstanceRepository instanceRepo =
        MockSessionInstanceRepository();

    final GetSessionsForTodayUseCase useCase = GetSessionsForTodayUseCase(
      sessionRepo,
      instanceRepo,
    );

    final DateTime now = DateTime(2025, 1, 1);

    // Session that should occur today
    final SessionModel session_1 = const SessionModel(
      id: '1',
      title: 'TEST EINHEIT 1',
      isRepeating: false,
    );

    final SessionModel session_2 = const SessionModel(
      id: '2',
      title: 'TEST EINHEIT 2',
      isRepeating: false,
    );

    // No instances should be found in repo for the sessions
    when(() => instanceRepo.watchAllInstancesForDate(any())).thenAnswer(
      (_) => Stream<List<SessionInstanceModel>>.value(<SessionInstanceModel>[]),
    );

    // When active session is watched, return both sessions
    when(() => sessionRepo.watchAllActiveSessions()).thenAnswer(
      (_) => Stream<List<SessionModel>>.value(<SessionModel>[
        session_1,
        session_2,
      ]),
    );

    final List<SessionWithInstanceModel> result = await useCase(now).first;

    expect(result.length, 2);
    expect(result.first.session, session_2);
    // Expect this to be a pending session; no instance linked to it yet
    expect(result.first.instance, null);
  });

  test('Skips repeating session on non-matching weekday', () async {
    final MockSessionRepository sessionRepo = MockSessionRepository();
    final MockSessionInstanceRepository instanceRepo =
        MockSessionInstanceRepository();

    final GetSessionsForTodayUseCase useCase = GetSessionsForTodayUseCase(
      sessionRepo,
      instanceRepo,
    );

    final DateTime wednesday = DateTime(2025, 11, 5); // Wednesday

    final SessionModel session = SessionModel(
      id: '1',
      title: 'TEST Sport machen',
      isRepeating: true,
      startDate: DateTime(2025, 11, 1),
      endDate: DateTime(2025, 11, 23),
      selectedDays: <int>[0, 1, 4],
    );

    when(() => sessionRepo.watchAllActiveSessions()).thenAnswer(
      (_) => Stream<List<SessionModel>>.value(<SessionModel>[session]),
    );

    when(() => instanceRepo.watchAllInstancesForDate(any())).thenAnswer(
      (_) => Stream<List<SessionInstanceModel>>.value(<SessionInstanceModel>[]),
    );

    final List<SessionWithInstanceModel> result = await useCase(
      wednesday,
    ).first;

    expect(result, isEmpty);
  });

  test('Repeating session is returned when the weekday matches', () async {
    final MockSessionRepository sessionRepo = MockSessionRepository();
    final MockSessionInstanceRepository instanceRepo =
        MockSessionInstanceRepository();

    final GetSessionsForTodayUseCase useCase = GetSessionsForTodayUseCase(
      sessionRepo,
      instanceRepo,
    );

    final DateTime monday = DateTime(2025, 11, 3);

    final SessionModel session = SessionModel(
      id: '1',
      title: 'TEST MONTAG',
      isRepeating: true,
      startDate: DateTime(2025, 11, 1),
      endDate: DateTime(2025, 31, 1),
      selectedDays: <int>[0],
    );

    when(() => instanceRepo.watchAllInstancesForDate(any())).thenAnswer(
      (_) => Stream<List<SessionInstanceModel>>.value(<SessionInstanceModel>[]),
    );

    when(() => sessionRepo.watchAllActiveSessions()).thenAnswer(
      (_) => Stream<List<SessionModel>>.value(<SessionModel>[session]),
    );

    final List<SessionWithInstanceModel> result = await useCase(monday).first;

    expect(result.length, 1);
    expect(result.first.session, session);
    expect(
      result.first.instance,
      null,
    ); // no instance; hence pending and displayed
  });
}
