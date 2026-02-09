import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/domain/models/session_model.dart';
import 'package:srl_app/domain/session_instance_repository.dart';
import 'package:srl_app/domain/session_repository.dart';
import 'package:srl_app/domain/usecases/session/get_completed_sessions_for_today_use_case.dart';

class MockSessionRepository extends Mock implements SessionRepository {}

class MockSessionInstanceRepository extends Mock
    implements SessionInstanceRepository {}

void main() {
  group('GetCompletedSessionsForTodayUseCase', () {
    late MockSessionRepository sessionRepo;
    late MockSessionInstanceRepository instanceRepo;
    late GetCompletedSessionsForTodayUseCase useCase;

    setUp(() {
      sessionRepo = MockSessionRepository();
      instanceRepo = MockSessionInstanceRepository();
      useCase = GetCompletedSessionsForTodayUseCase(
        sessionRepo,
        instanceRepo,
      );
    });

    test('returns completed sessions for given date', () async {
      final testDate = DateTime(2026, 1, 15);

      const session = SessionModel(
        id: '1',
        title: 'Mathe TEST-Vorlesung',
      );

      final completedInstance = SessionInstanceModel(
        sessionId: '1',
        scheduledAt: testDate,
        status: SessionStatus.completed,
      );

      // Mock the repositories
      when(() => sessionRepo.watchAllSessions()).thenAnswer(
        (_) => Stream.value([session]),
      );

      when(() => instanceRepo.watchAllInstancesForDate(testDate)).thenAnswer(
        (_) => Stream.value([completedInstance]),
      );

      // Get the result
      final result = await useCase(testDate).first;

      expect(result.length, 1);
      expect(result.first.session, session);
      expect(result.first.instance, completedInstance);
    });

    test('filters out non-completed sessions', () async {
      final testDate = DateTime(2026, 1, 15);

      const session1 = SessionModel(id: '1', title: 'Session 1');
      const session2 = SessionModel(id: '2', title: 'Session 2');

      final completedInstance = SessionInstanceModel(
        sessionId: '1',
        scheduledAt: testDate,
        status: SessionStatus.completed,
      );

      final skippedInstance = SessionInstanceModel(
        sessionId: '2',
        scheduledAt: testDate,
        status: SessionStatus.inProgress,
      );

      when(() => sessionRepo.watchAllSessions()).thenAnswer(
        (_) => Stream.value([session1, session2]),
      );

      when(() => instanceRepo.watchAllInstancesForDate(testDate)).thenAnswer(
        (_) => Stream.value([completedInstance, skippedInstance]),
      );

      final result = await useCase(testDate).first;

      expect(result.length, 1);
      expect(result.first.session.id, '1');
      expect(result.first.instance?.status, SessionStatus.completed);
    });

    test('returns empty list when no completed sessions', () async {
      final testDate = DateTime(2026, 1, 15);

      when(() => sessionRepo.watchAllSessions()).thenAnswer(
        (_) => Stream.value([]),
      );

      when(() => instanceRepo.watchAllInstancesForDate(testDate)).thenAnswer(
        (_) => Stream.value([]),
      );

      final result = await useCase(testDate).first;

      expect(result, isEmpty);
    });
  });
}
