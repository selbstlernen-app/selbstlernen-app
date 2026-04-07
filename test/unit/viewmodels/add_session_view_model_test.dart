import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:srl_app/data/app_database.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/domain/models/full_session_model.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/providers.dart';
import 'package:srl_app/domain/services/add_session_service.dart';
import 'package:srl_app/domain/usecases/instance/get_or_create_instance_use_case.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';
import 'package:srl_app/presentation/view_models/providers.dart';

@GenerateMocks([AddSessionService, GetOrCreateInstanceUseCase, AppDatabase])
import 'add_session_view_model_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('AddSessionViewModel', () {
    late ProviderContainer container;
    late MockAddSessionService mockService;
    late MockGetOrCreateInstanceUseCase mockGetOrCreateInstance;

    setUp(() {
      mockService = MockAddSessionService();
      mockGetOrCreateInstance = MockGetOrCreateInstanceUseCase();
      container = ProviderContainer(
        overrides: [
          addSessionServiceProvider.overrideWithValue(mockService),
          getOrCreateInstanceUseCaseProvider.overrideWithValue(
            mockGetOrCreateInstance,
          ),
          learningStrategiesStreamProvider.overrideWith(
            (ref) => Stream.value([]),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Initial State', () {
      test('initializes with default values', () {
        final state = container.read(addSessionViewModelProvider);

        expect(state.title, '');
        expect(state.isRepeating, false);
        expect(state.sessionComplexity, SessionComplexity.simple);
        expect(state.selectedDays, isEmpty);
        expect(state.goals, isEmpty);
        expect(state.tasks, isEmpty);
        expect(state.learningStrategyIds, isEmpty);
        expect(state.enableNotifications, false);
        expect(state.isEditMode, false);
      });

      test('sets startDate to current date', () {
        final state = container.read(addSessionViewModelProvider);
        final now = DateTime.now();

        expect(state.startDate!.year, now.year);
        expect(state.startDate!.month, now.month);
        expect(state.startDate!.day, now.day);
      });

      test('sets endDate to tomorrow', () {
        final state = container.read(addSessionViewModelProvider);
        final tomorrow = DateTime.now().add(const Duration(days: 1));

        expect(state.endDate!.year, tomorrow.year);
        expect(state.endDate!.month, tomorrow.month);
        expect(state.endDate!.day, tomorrow.day);
      });
    });

    group('Setters', () {
      test('setUpWizard updates flags correctly', () {
        container.read(addSessionViewModelProvider.notifier)
          ..setTitle('Math Study Session')
          ..setIsRepeating(isRepeating: true)
          ..setSessionComplexity(
            complexity: SessionComplexity.advanced,
          );

        expect(
          container.read(addSessionViewModelProvider).title,
          'Math Study Session',
        );
        expect(
          container.read(addSessionViewModelProvider).isRepeating,
          true,
        );
        expect(
          container.read(addSessionViewModelProvider).sessionComplexity,
          SessionComplexity.advanced,
        );
      });

      test('setEndDate, setStartDate, setPlannedTime update correctly', () {
        container.read(addSessionViewModelProvider.notifier)
          ..setStartDate(DateTime(2024, 6, 15))
          ..setEndDate(DateTime(2024, 6, 30))
          ..setPlannedTime(const TimeOfDay(hour: 14, minute: 30));
        expect(
          container.read(addSessionViewModelProvider).startDate,
          DateTime(2024, 6, 15),
        );
        expect(
          container.read(addSessionViewModelProvider).endDate,
          DateTime(2024, 6, 30),
        );
        expect(
          container.read(addSessionViewModelProvider).plannedTime,
          const TimeOfDay(hour: 14, minute: 30),
        );
      });
    });

    group('toggleDay', () {
      test('adds day when not present', () {
        container.read(addSessionViewModelProvider.notifier).toggleDay(1);

        final selectedDays = container
            .read(addSessionViewModelProvider)
            .selectedDays;
        expect(selectedDays, contains(1));
        expect(selectedDays.length, 1);
      });

      test('removes day when already present', () {
        container.read(addSessionViewModelProvider.notifier)
          ..toggleDay(1)
          ..toggleDay(1);

        final selectedDays = container
            .read(addSessionViewModelProvider)
            .selectedDays;
        expect(selectedDays, isNot(contains(1)));
        expect(selectedDays, isEmpty);
      });

      test('can toggle multiple days', () {
        container.read(addSessionViewModelProvider.notifier)
          ..toggleDay(1)
          ..toggleDay(3)
          ..toggleDay(5);

        final selectedDays = container
            .read(addSessionViewModelProvider)
            .selectedDays;
        expect(selectedDays, containsAll([1, 3, 5]));
        expect(selectedDays.length, 3);
      });
    });

    group('toggleStrategy', () {
      test('adds strategy when not present', () {
        container.read(addSessionViewModelProvider.notifier).toggleStrategy(1);

        final strategies = container
            .read(addSessionViewModelProvider)
            .learningStrategyIds;
        expect(strategies, contains(1));
        expect(strategies.length, 1);
      });

      test('removes strategy when already present', () {
        container.read(addSessionViewModelProvider.notifier)
          ..toggleStrategy(1)
          ..toggleStrategy(1);

        final strategies = container
            .read(addSessionViewModelProvider)
            .learningStrategyIds;
        expect(strategies, isNot(contains(1)));
        expect(strategies, isEmpty);
      });

      test('can toggle multiple strategies', () {
        container.read(addSessionViewModelProvider.notifier)
          ..toggleStrategy(1)
          ..toggleStrategy(2)
          ..toggleStrategy(3);

        final strategies = container
            .read(addSessionViewModelProvider)
            .learningStrategyIds;
        expect(
          strategies,
          containsAll([1, 2, 3]),
        );
        expect(strategies.length, 3);
      });
    });

    group('setTimerSettings', () {
      test('updates focus time', () {
        container
            .read(addSessionViewModelProvider.notifier)
            .setTimerSettings(
              focusTime: 45,
              breakTime: 10,
              pomodoroPhases: 4,
            );

        final state = container.read(addSessionViewModelProvider);
        expect(state.focusTimeMin, 45);
        expect(state.breakTimeMin, 10);
        expect(state.pomodoroPhases, 4);
      });
    });

    group('setPrompts', () {
      test('updates showFocusPromptAlways', () {
        container
            .read(addSessionViewModelProvider.notifier)
            .setPrompts(showFocusPromptAlways: true);

        expect(
          container.read(addSessionViewModelProvider).showFocusPromptAlways,
          true,
        );
      });

      test('can update all prompt settings at once', () {
        container
            .read(addSessionViewModelProvider.notifier)
            .setPrompts(
              focus: true,
              focusPromptInterval: 20,
              showFocusPromptAlways: false,
            );

        final state = container.read(addSessionViewModelProvider);
        expect(state.hasFocusPrompt, true);
        expect(state.focusPromptInterval, 20);
        expect(state.showFocusPromptAlways, false);
      });
    });

    group('Goals Management', () {
      test('addGoal adds a goal to the list', () {
        final viewModel = container.read(addSessionViewModelProvider.notifier);
        const goal = GoalModel(
          id: '1',
          title: 'Learn Calculus',
          keptForFutureSessions: true,
        );

        viewModel.addGoal(goal);

        final goals = container.read(addSessionViewModelProvider).goals;
        expect(goals, contains(goal));
        expect(goals.length, 1);
      });

      test('addGoal can add multiple goals', () {
        final viewModel = container.read(addSessionViewModelProvider.notifier);
        const goal1 = GoalModel(
          id: '1',
          title: 'Goal 1',
          keptForFutureSessions: true,
        );
        const goal2 = GoalModel(
          id: '2',
          title: 'Goal 2',
          keptForFutureSessions: true,
        );

        viewModel
          ..addGoal(goal1)
          ..addGoal(goal2);

        final goals = container.read(addSessionViewModelProvider).goals;
        expect(goals, containsAll([goal1, goal2]));
        expect(goals.length, 2);
      });

      test('removeGoalById removes goal from list', () {
        final viewModel = container.read(addSessionViewModelProvider.notifier);
        const goal = GoalModel(
          id: '1',
          title: 'Goal 1',
          keptForFutureSessions: true,
        );

        viewModel
          ..addGoal(goal)
          ..removeGoalById('1');

        final goals = container.read(addSessionViewModelProvider).goals;
        expect(goals, isEmpty);
      });

      test(
        'removeGoalById with persistent id in edit mode adds to delete list',
        () {
          final viewModel = container.read(
            addSessionViewModelProvider.notifier,
          );

          // Initialize in edit mode
          const fullSession = FullSessionModel(
            session: SessionModel(
              id: '1',
              title: 'Test Session',
            ),
            goals: [
              GoalModel(
                id: '123',
                title: 'Existing Goal',
                keptForFutureSessions: true,
              ), // Persistent id
            ],
          );
          viewModel
            ..initializeState(fullSession)
            ..removeGoalById('123');

          final state = container.read(addSessionViewModelProvider);
          expect(state.goalIdsToDelete, contains('123'));
          expect(state.goals, isEmpty);
        },
      );

      test(
        'removeGoalById with UUID in edit mode does not add to delete list',
        () {
          final viewModel = container.read(
            addSessionViewModelProvider.notifier,
          );

          // Initialize in edit mode
          const fullSession = FullSessionModel(
            session: SessionModel(id: '1', title: 'Test Session'),
          );
          viewModel.initializeState(fullSession);

          // Add a new goal with UUID (not persisted yet)
          const goal = GoalModel(
            id: 'uuid-1234',
            title: 'New Goal',
            keptForFutureSessions: true,
          );
          viewModel
            ..addGoal(goal)
            ..removeGoalById('uuid-1234');

          final state = container.read(addSessionViewModelProvider);
          expect(state.goalIdsToDelete, isEmpty);
          expect(state.goals, isEmpty);
        },
      );
    });

    group('Tasks Management', () {
      test('addTaskToGoal adds task with goal reference', () {
        final viewModel = container.read(addSessionViewModelProvider.notifier);
        const task = TaskModel(
          id: '1',
          title: 'Read Chapter 5',
          keptForFutureSessions: true,
        );

        viewModel.addTaskToGoal(task, 'goal-123');

        final tasks = container.read(addSessionViewModelProvider).tasks;
        expect(tasks.length, 1);
        expect(tasks.first.id, '1');
        expect(tasks.first.goalId, 'goal-123');
      });

      test('addTaskToGoal can add task without goal reference', () {
        final viewModel = container.read(addSessionViewModelProvider.notifier);
        const task = TaskModel(
          id: '1',
          title: 'General Task',
          keptForFutureSessions: true,
        );

        viewModel.addTaskToGoal(task, null);

        final tasks = container.read(addSessionViewModelProvider).tasks;
        expect(tasks.length, 1);
        expect(tasks.first.goalId, null);
      });

      test('removeTask removes task from list', () {
        final viewModel = container.read(addSessionViewModelProvider.notifier);
        const task = TaskModel(
          id: '1',
          title: 'Task 1',
          keptForFutureSessions: true,
        );

        viewModel
          ..addTaskToGoal(task, null)
          ..removeTask('1');

        final tasks = container.read(addSessionViewModelProvider).tasks;
        expect(tasks, isEmpty);
      });

      test(
        'removeTask with persistent id in edit mode adds to delete list',
        () {
          final viewModel = container.read(
            addSessionViewModelProvider.notifier,
          );

          // Initialize in edit mode
          const fullSession = FullSessionModel(
            session: SessionModel(id: '1', title: 'Test Session'),

            tasks: [
              TaskModel(
                id: '456',
                title: 'Existing Task',
                keptForFutureSessions: true,
              ), // Persistent id
            ],
          );
          viewModel
            ..initializeState(fullSession)
            ..removeTask('456');

          final state = container.read(addSessionViewModelProvider);
          expect(state.taskIdsToDelete, contains('456'));
          expect(state.tasks, isEmpty);
        },
      );

      test('removeTask with UUID in edit mode does not add to delete list', () {
        final viewModel = container.read(addSessionViewModelProvider.notifier);

        // Initialize in edit mode
        const fullSession = FullSessionModel(
          session: SessionModel(id: '1', title: 'Test Session'),
        );
        viewModel.initializeState(fullSession);

        // Add a new task with UUID
        const task = TaskModel(
          id: 'uuid-5678',
          title: 'New Task',
          keptForFutureSessions: true,
        );
        viewModel
          ..addTaskToGoal(task, null)
          ..removeTask('uuid-5678');

        final state = container.read(addSessionViewModelProvider);
        expect(state.taskIdsToDelete, isEmpty);
        expect(state.tasks, isEmpty);
      });
    });

    group('_isPersistentId', () {
      test('returns true for numeric string ids', () {
        final viewModel = container.read(addSessionViewModelProvider.notifier);

        const fullSession = FullSessionModel(
          session: SessionModel(id: '1', title: 'Test'),
          goals: [
            GoalModel(id: '123', title: 'Goal', keptForFutureSessions: true),
          ],
        );
        viewModel
          ..initializeState(fullSession)
          ..removeGoalById('123');

        expect(
          container.read(addSessionViewModelProvider).goalIdsToDelete,
          contains('123'),
        );
      });

      test('returns false for UUID-like strings', () {
        final viewModel = container.read(addSessionViewModelProvider.notifier);

        const fullSession = FullSessionModel(
          session: SessionModel(id: '1', title: 'Test'),
        );
        viewModel.initializeState(fullSession);

        const goal = GoalModel(
          id: 'abc-123-def',
          title: 'Goal',
          keptForFutureSessions: true,
        );
        viewModel
          ..addGoal(goal)
          ..removeGoalById('abc-123-def');

        expect(
          container.read(addSessionViewModelProvider).goalIdsToDelete,
          isEmpty,
        );
      });
    });

    group('resetFields', () {
      test(
        'resets state to defaults while preserving available strategies',
        () {
          final viewModel =
              container.read(
                  addSessionViewModelProvider.notifier,
                )
                // Modify state
                ..setTitle('Test Session')
                ..setIsRepeating(isRepeating: true)
                ..toggleDay(1)
                ..addGoal(
                  const GoalModel(
                    id: '1',
                    title: 'Goal',
                    keptForFutureSessions: true,
                  ),
                );

          // Store available strategies
          final strategiesBefore = container
              .read(addSessionViewModelProvider)
              .availableStrategies;

          viewModel.resetFields();

          final state = container.read(addSessionViewModelProvider);
          expect(state.title, '');
          expect(state.isRepeating, false);
          expect(state.selectedDays, isEmpty);
          expect(state.goals, isEmpty);
          expect(state.availableStrategies, strategiesBefore);
        },
      );
    });

    group('initializeState', () {
      test('sets state to edit mode with session data', () {
        final viewModel = container.read(addSessionViewModelProvider.notifier);
        final startDate = DateTime(2024, 6);
        final endDate = DateTime(2024, 6, 30);

        final fullSession = FullSessionModel(
          session: SessionModel(
            id: '42',
            title: 'Study Session',
            isRepeating: true,
            startDate: startDate,
            endDate: endDate,
            selectedDays: [1, 3, 5],
            complexity: SessionComplexity.advanced,
            focusTimeMin: 50,
            breakTimeMin: 10,
          ),
          goals: [
            const GoalModel(
              id: '1',
              title: 'Goal 1',
              keptForFutureSessions: true,
            ),
            const GoalModel(
              id: '2',
              title: 'Goal 2',
              keptForFutureSessions: true,
            ),
          ],
          tasks: [
            const TaskModel(
              id: '1',
              title: 'Task 1',
              keptForFutureSessions: true,
            ),
          ],
        );

        viewModel.initializeState(fullSession);

        final state = container.read(addSessionViewModelProvider);
        expect(state.isEditMode, true);
        expect(state.sessionId, '42');
        expect(state.title, 'Study Session');
        expect(state.isRepeating, true);
        expect(state.startDate, startDate);
        expect(state.endDate, endDate);
        expect(state.selectedDays, [1, 3, 5]);
        expect(state.sessionComplexity, SessionComplexity.advanced);
        expect(state.focusTimeMin, 50);
        expect(state.breakTimeMin, 10);
        expect(state.goals.length, 2);
        expect(state.tasks.length, 1);
      });
    });

    group('handleSaveSession', () {
      test('creates new session when not in edit mode', () async {
        final viewModel = container.read(addSessionViewModelProvider.notifier)
          ..setTitle('New Session');
        const goal = GoalModel(
          id: '1',
          title: 'Goal',
          keptForFutureSessions: true,
        );
        viewModel.addGoal(goal);

        when(
          mockService.createSessionWithGoalsAndTasks(
            session: argThat(isA<SessionModel>(), named: 'session'),
            goals: argThat(isA<List<GoalModel>>(), named: 'goals'),
            tasks: argThat(isA<List<TaskModel>>(), named: 'tasks'),
          ),
        ).thenAnswer((_) async => 123);

        await viewModel.handleSaveSession();

        verify(
          mockService.createSessionWithGoalsAndTasks(
            session: argThat(isA<SessionModel>(), named: 'session'),
            goals: argThat(isA<List<GoalModel>>(), named: 'goals'),
            tasks: argThat(isA<List<TaskModel>>(), named: 'tasks'),
          ),
        ).called(1);

        // Verify state was reset
        final state = container.read(addSessionViewModelProvider);
        expect(state.title, '');
        expect(state.goals, isEmpty);
      });

      test('updates existing session when in edit mode', () async {
        final viewModel = container.read(addSessionViewModelProvider.notifier);

        // Initialize edit mode
        const fullSession = FullSessionModel(
          session: SessionModel(id: '99', title: 'Old Title'),
        );
        viewModel
          ..initializeState(fullSession)
          ..setTitle('Updated Title');

        when(
          mockService.updateSessionWithChanges(
            sessionId: anyNamed('sessionId'),
            session: argThat(isA<SessionModel>(), named: 'session'),
            goalsToUpdate: argThat(
              isA<List<GoalModel>>(),
              named: 'goalsToUpdate',
            ),
            tasksToUpdate: argThat(
              isA<List<TaskModel>>(),
              named: 'tasksToUpdate',
            ),
            goalIdsToDelete: argThat(
              isA<Set<String>>(),
              named: 'goalIdsToDelete',
            ),
            taskIdsToDelete: argThat(
              isA<Set<String>>(),
              named: 'taskIdsToDelete',
            ),
          ),
        ).thenAnswer((_) async => {});

        await viewModel.handleSaveSession();

        verify(
          mockService.updateSessionWithChanges(
            sessionId: 99,
            session: argThat(isA<SessionModel>(), named: 'session'),
            goalsToUpdate: argThat(
              isA<List<GoalModel>>(),
              named: 'goalsToUpdate',
            ),
            tasksToUpdate: argThat(
              isA<List<TaskModel>>(),
              named: 'tasksToUpdate',
            ),
            goalIdsToDelete: argThat(
              isA<Set<String>>(),
              named: 'goalIdsToDelete',
            ),
            taskIdsToDelete: argThat(
              isA<Set<String>>(),
              named: 'taskIdsToDelete',
            ),
          ),
        ).called(1);
      });

      test('passes deleted goal and task IDs when updating', () async {
        final viewModel = container.read(addSessionViewModelProvider.notifier);

        const fullSession = FullSessionModel(
          session: SessionModel(id: '50', title: 'Session'),
          goals: [
            GoalModel(id: '10', title: 'Goal', keptForFutureSessions: true),
          ],
          tasks: [
            TaskModel(id: '20', title: 'Task', keptForFutureSessions: true),
          ],
        );
        viewModel
          ..initializeState(fullSession)
          ..removeGoalById('10')
          ..removeTask('20');

        when(
          mockService.updateSessionWithChanges(
            sessionId: anyNamed('sessionId'),
            session: argThat(isA<SessionModel>(), named: 'session'),
            goalsToUpdate: argThat(
              isA<List<GoalModel>>(),
              named: 'goalsToUpdate',
            ),
            tasksToUpdate: argThat(
              isA<List<TaskModel>>(),
              named: 'tasksToUpdate',
            ),
            goalIdsToDelete: argThat(
              isA<Set<String>>(),
              named: 'goalIdsToDelete',
            ),
            taskIdsToDelete: argThat(
              isA<Set<String>>(),
              named: 'taskIdsToDelete',
            ),
          ),
        ).thenAnswer((_) async => {});

        await viewModel.handleSaveSession();

        final captured = verify(
          mockService.updateSessionWithChanges(
            sessionId: anyNamed('sessionId'),
            session: argThat(isA<SessionModel>(), named: 'session'),
            goalsToUpdate: argThat(
              isA<List<GoalModel>>(),
              named: 'goalsToUpdate',
            ),
            tasksToUpdate: argThat(
              isA<List<TaskModel>>(),
              named: 'tasksToUpdate',
            ),
            goalIdsToDelete: captureAnyNamed('goalIdsToDelete'),
            taskIdsToDelete: captureAnyNamed('taskIdsToDelete'),
          ),
        ).captured;

        expect(captured[0], contains('10')); // goalIdsToDelete
        expect(captured[1], contains('20')); // taskIdsToDelete
      });
    });

    group('handleStartSession', () {
      late MockAppDatabase mockDatabase;
      late MockGetOrCreateInstanceUseCase mockGetOrCreateInstance;

      setUp(() {
        mockService = MockAddSessionService();
        mockDatabase = MockAppDatabase();

        mockGetOrCreateInstance = MockGetOrCreateInstanceUseCase();
        container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(mockDatabase),
            addSessionServiceProvider.overrideWithValue(mockService),
            getOrCreateInstanceUseCaseProvider.overrideWithValue(
              mockGetOrCreateInstance,
            ),
            learningStrategiesStreamProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
        );
      });

      test(
        'creates session and returns instance when not in edit mode',
        () async {
          final viewModel = container.read(
            addSessionViewModelProvider.notifier,
          )..setTitle('Quick Session');

          final expectedInstance = SessionInstanceModel(
            id: '1',
            sessionId: '123',
            scheduledAt: DateTime.now(),
          );

          when(
            mockService.createSessionWithGoalsAndTasks(
              session: argThat(isA<SessionModel>(), named: 'session'),
              goals: argThat(isA<List<GoalModel>>(), named: 'goals'),
              tasks: argThat(isA<List<TaskModel>>(), named: 'tasks'),
            ),
          ).thenAnswer((_) async => 123);

          when(
            mockGetOrCreateInstance.call(
              sessionId: 123,
              date: argThat(isA<DateTime>(), named: 'date'),
            ),
          ).thenAnswer((_) async => expectedInstance);

          final instance = await viewModel.handleStartSession();

          expect(instance, expectedInstance);
          verify(
            mockService.createSessionWithGoalsAndTasks(
              session: argThat(isA<SessionModel>(), named: 'session'),
              goals: argThat(isA<List<GoalModel>>(), named: 'goals'),
              tasks: argThat(isA<List<TaskModel>>(), named: 'tasks'),
            ),
          ).called(1);
          verify(
            mockGetOrCreateInstance.call(
              sessionId: 123,
              date: argThat(isA<DateTime>(), named: 'date'),
            ),
          ).called(1);
        },
      );

      test('updates session and returns instance when in edit mode', () async {
        final viewModel = container.read(addSessionViewModelProvider.notifier);

        const fullSession = FullSessionModel(
          session: SessionModel(id: '99', title: 'Existing Session'),
        );
        viewModel.initializeState(fullSession);

        final expectedInstance = SessionInstanceModel(
          id: '1',
          sessionId: '99',
          scheduledAt: DateTime.now(),
        );

        when(
          mockService.updateSessionWithChanges(
            sessionId: 99,
            session: argThat(isA<SessionModel>(), named: 'session'),
            goalsToUpdate: argThat(
              isA<List<GoalModel>>(),
              named: 'goalsToUpdate',
            ),
            tasksToUpdate: argThat(
              isA<List<TaskModel>>(),
              named: 'tasksToUpdate',
            ),
            goalIdsToDelete: argThat(
              isA<Set<String>>(),
              named: 'goalIdsToDelete',
            ),
            taskIdsToDelete: argThat(
              isA<Set<String>>(),
              named: 'taskIdsToDelete',
            ),
          ),
        ).thenAnswer((_) async => {});

        when(
          mockGetOrCreateInstance.call(
            sessionId: 99,
            date: argThat(isA<DateTime>(), named: 'date'),
          ),
        ).thenAnswer((_) async => expectedInstance);

        final instance = await viewModel.handleStartSession();

        expect(instance, expectedInstance);
        verify(
          mockService.updateSessionWithChanges(
            sessionId: 99,
            session: argThat(isA<SessionModel>(), named: 'session'),
            goalsToUpdate: argThat(
              isA<List<GoalModel>>(),
              named: 'goalsToUpdate',
            ),
            tasksToUpdate: argThat(
              isA<List<TaskModel>>(),
              named: 'tasksToUpdate',
            ),
            goalIdsToDelete: argThat(
              isA<Set<String>>(),
              named: 'goalIdsToDelete',
            ),
            taskIdsToDelete: argThat(
              isA<Set<String>>(),
              named: 'taskIdsToDelete',
            ),
          ),
        ).called(1);
      });
    });

    group('_stateToSessionModel', () {
      test('converts state to SessionModel with simple complexity', () async {
        final viewModel = container.read(addSessionViewModelProvider.notifier)
          ..setTitle('Simple Session')
          ..setSessionComplexity(complexity: SessionComplexity.simple)
          ..setTimerSettings(
            focusTime: 25,
            breakTime: 5,
            pomodoroPhases: 4,
          );

        // Trigger save to access the converted model
        when(
          mockService.createSessionWithGoalsAndTasks(
            session: argThat(isA<SessionModel>(), named: 'session'),
            goals: argThat(isA<List<GoalModel>>(), named: 'goals'),
            tasks: argThat(isA<List<TaskModel>>(), named: 'tasks'),
          ),
        ).thenAnswer((_) async => 1);

        await viewModel.handleSaveSession();

        final captured =
            verify(
                  mockService.createSessionWithGoalsAndTasks(
                    session: captureAnyNamed('session'),
                    goals: argThat(isA<List<GoalModel>>(), named: 'goals'),
                    tasks: argThat(isA<List<TaskModel>>(), named: 'tasks'),
                  ),
                ).captured.first
                as SessionModel;

        // For simple sessions, break times and phases should be 0
        expect(captured.focusTimeMin, 25);
        expect(captured.breakTimeMin, 0);
        expect(captured.pomodoroPhases, 0);
      });

      test('converts state to SessionModel with advanced complexity', () async {
        final viewModel = container.read(addSessionViewModelProvider.notifier)
          ..setTitle('Advanced Session')
          ..setSessionComplexity(complexity: SessionComplexity.advanced)
          ..setTimerSettings(
            focusTime: 50,
            breakTime: 10,

            pomodoroPhases: 3,
          );

        when(
          mockService.createSessionWithGoalsAndTasks(
            session: argThat(isA<SessionModel>(), named: 'session'),
            goals: argThat(isA<List<GoalModel>>(), named: 'goals'),
            tasks: argThat(isA<List<TaskModel>>(), named: 'tasks'),
          ),
        ).thenAnswer((_) async => 1);

        await viewModel.handleSaveSession();

        final captured =
            verify(
                  mockService.createSessionWithGoalsAndTasks(
                    session: captureAnyNamed('session'),
                    goals: argThat(isA<List<GoalModel>>(), named: 'goals'),
                    tasks: argThat(isA<List<TaskModel>>(), named: 'tasks'),
                  ),
                ).captured.first
                as SessionModel;

        // For advanced sessions, all values should be preserved
        expect(captured.focusTimeMin, 50);
        expect(captured.breakTimeMin, 10);
        expect(captured.pomodoroPhases, 3);
      });

      test('includes all session properties', () async {
        final viewModel = container.read(addSessionViewModelProvider.notifier);
        final startDate = DateTime(2024, 7);
        final endDate = DateTime(2024, 7, 31);
        const plannedTime = TimeOfDay(hour: 9, minute: 0);

        viewModel
          ..setTitle('Complete Session')
          ..setIsRepeating(isRepeating: true)
          ..setStartDate(startDate)
          ..setEndDate(endDate)
          ..setPlannedTime(plannedTime)
          ..toggleDay(1)
          ..toggleDay(3)
          ..toggleStrategy(1)
          ..setPrompts(focus: true, focusPromptInterval: 10);

        when(
          mockService.createSessionWithGoalsAndTasks(
            session: argThat(isA<SessionModel>(), named: 'session'),
            goals: argThat(isA<List<GoalModel>>(), named: 'goals'),
            tasks: argThat(isA<List<TaskModel>>(), named: 'tasks'),
          ),
        ).thenAnswer((_) async => 1);

        await viewModel.handleSaveSession();

        final captured =
            verify(
                  mockService.createSessionWithGoalsAndTasks(
                    session: captureAnyNamed('session'),
                    goals: argThat(isA<List<GoalModel>>(), named: 'goals'),
                    tasks: argThat(isA<List<TaskModel>>(), named: 'tasks'),
                  ),
                ).captured.first
                as SessionModel;

        expect(captured.title, 'Complete Session');
        expect(captured.isRepeating, true);
        expect(captured.startDate, startDate);
        expect(captured.endDate, endDate);
        expect(captured.plannedTime, plannedTime);
        expect(captured.selectedDays, [1, 3]);
        expect(captured.learningStrategyIds, [1]);
        expect(captured.hasFocusPrompt, true);
        expect(captured.focusPromptInterval, 10);
      });
    });
  });
}
