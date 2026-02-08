import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:srl_app/domain/models/session_with_instance_model.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/usecases/instance/manange_instance_use_case.dart';
import 'package:srl_app/domain/usecases/session/get_completed_sessions_for_today_use_case.dart';
import 'package:srl_app/domain/usecases/session/get_sessions_for_date_use_case.dart';
import 'package:srl_app/presentation/view_models/home/home_state.dart';
import 'package:srl_app/presentation/view_models/home/home_view_model.dart';

@GenerateMocks([
  GetSessionsForDateUseCase,
  GetCompletedSessionsForTodayUseCase,
  ManangeInstanceUseCase,
])
import 'home_view_model_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeViewModel', () {
    late ProviderContainer container;
    late MockGetSessionsForDateUseCase mockGetSessions;
    late MockGetCompletedSessionsForTodayUseCase mockGetCompleted;
    late MockManangeInstanceUseCase mockManageInstance;

    setUp(() {
      mockGetSessions = MockGetSessionsForDateUseCase();
      mockGetCompleted = MockGetCompletedSessionsForTodayUseCase();
      mockManageInstance = MockManangeInstanceUseCase();

      container = ProviderContainer(
        overrides: [
          getSessionsForDateUseCaseProvider.overrideWithValue(mockGetSessions),
          getCompletedSessionsForTodayUseCaseProvider.overrideWithValue(
            mockGetCompleted,
          ),
          manangeInstanceUseCaseProvider.overrideWithValue(mockManageInstance),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('build', () {
      test('returns initial state with current date and not loading', () {
        final state = container.read(homeViewModelProvider);
        final now = DateTime.now();

        expect(state.isLoading, false);
        expect(state.dateToFilterFor.year, now.year);
        expect(state.dateToFilterFor.month, now.month);
        expect(state.dateToFilterFor.day, now.day);
        expect(state.filter, SessionFilter.all);
      });
    });

    group('updateDate', () {
      test('sets loading to true immediately with new date', () {
        final newDate = DateTime(2026, 12, 25);
        final notifier = container.read(homeViewModelProvider.notifier);

        // Start the update but don't await
        notifier.updateDate(newDate);

        // Check immediate state
        final state = container.read(homeViewModelProvider);
        expect(state.isLoading, true);
        expect(state.dateToFilterFor, newDate);
      });
    });

    group('setFilter', () {
      test('updates filter in state', () {
        container
            .read(homeViewModelProvider.notifier)
            .setFilter(SessionFilter.done);

        final state = container.read(homeViewModelProvider);
        expect(state.filter, SessionFilter.done);
      });

      test('preserves other state properties when setting filter', () {
        final notifier = container.read(homeViewModelProvider.notifier);
        final initialDate = container
            .read(homeViewModelProvider)
            .dateToFilterFor;

        notifier.setFilter(SessionFilter.open);

        final state = container.read(homeViewModelProvider);
        expect(state.filter, SessionFilter.open);
        expect(state.dateToFilterFor, initialDate);
        expect(state.isLoading, false);
      });
    });
  });

  group('Stream Providers', () {
    late MockGetSessionsForDateUseCase mockGetSessions;
    late MockGetCompletedSessionsForTodayUseCase mockGetCompleted;

    setUp(() {
      mockGetSessions = MockGetSessionsForDateUseCase();
      mockGetCompleted = MockGetCompletedSessionsForTodayUseCase();
    });

    group('sessionsForDate', () {
      test('calls usecase with correct date', () {
        final testDate = DateTime(2026);
        final testSessions = <SessionWithInstanceModel>[];

        when(
          mockGetSessions.call(testDate),
        ).thenAnswer((_) => Stream.value(testSessions));

        final container = ProviderContainer(
          overrides: [
            getSessionsForDateUseCaseProvider.overrideWithValue(
              mockGetSessions,
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(sessionsForDateProvider(testDate));

        verify(mockGetSessions.call(testDate)).called(1);
      });

      group('completedSessionsForDate', () {
        test('calls usecase with correct date', () {
          final testDate = DateTime(2026);
          final testSessions = <SessionWithInstanceModel>[];

          when(
            mockGetCompleted.call(testDate),
          ).thenAnswer((_) => Stream.value(testSessions));

          final container = ProviderContainer(
            overrides: [
              getCompletedSessionsForTodayUseCaseProvider.overrideWithValue(
                mockGetCompleted,
              ),
            ],
          );
          addTearDown(container.dispose);

          container.read(completedSessionsForDateProvider(testDate));

          verify(mockGetCompleted.call(testDate)).called(1);
        });
      });
    });
  });
}
