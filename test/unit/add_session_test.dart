import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/services/add_session_service.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class MockAddSessionService extends Mock implements AddSessionService {}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  test('setPrompts updates state fields correctly', () {
    container
        .read(
          addSessionViewModelProvider.notifier,
        )
        .setPrompts(focus: true, focusPromptInterval: 10);

    final state = container.read(addSessionViewModelProvider);

    expect(state.hasFocusPrompt, true);
    expect(state.focusPromptInterval, 10);
  });

  test('validateAll returns false and sets date error messages', () {
    final vm = container.read(
      addSessionViewModelProvider.notifier,
    );

    // 1) Initial invalid state
    vm.state = vm.state.copyWith(
      title: '',
      isRepeating: true,
      startDate: null,
      endDate: DateTime.now(),
      selectedDays: <int>[],
      setGoals: false,
      tasks: <TaskModel>[],
      goals: <GoalModel>[],
    );

    var isValid = vm.validateAll();

    expect(isValid, false);
    expect(vm.state.titleError, 'Titel kann nicht leer sein.');
    expect(vm.state.dateError, 'Startdatum muss gegeben sein.');
    expect(vm.state.selectedDaysError, isNotNull);
    expect(vm.state.goalsError, 'Es muss mind. 1 Aufgabe festgelegt werden.');

    // 2) Enddate missing
    vm.state = vm.state.copyWith(
      title: 'Titel',
      startDate: DateTime(2025, 11),
      endDate: null,
      selectedDays: <int>[1, 2, 3],
    );

    isValid = vm.validateAll();

    expect(isValid, false);
    expect(vm.state.dateError, 'Enddatum muss gegeben sein.');
    expect(vm.state.selectedDaysError, isNull);

    // 3) Same date (invalid)
    vm.state = vm.state.copyWith(endDate: DateTime(2025, 11));

    isValid = vm.validateAll();

    expect(isValid, false);
    expect(
      vm.state.dateError,
      'Start- und Enddatum können nicht am selben Tag sein. Wähle einmalig stattdessen.',
    );

    // 4) End before start (invalid)
    vm.state = vm.state.copyWith(endDate: DateTime(2025, 10));

    isValid = vm.validateAll();

    expect(isValid, false);
    expect(vm.state.dateError, 'Startdatum muss vor dem Enddatum liegen.');
  });

  test('validateAll returns false and sets error messages', () {
    final vm = container.read(
      addSessionViewModelProvider.notifier,
    );

    vm.state = vm.state.copyWith(
      title: '12',
      isRepeating: false,
      setGoals: false,
      tasks: <TaskModel>[],
      goals: <GoalModel>[],
    );

    final isValid = vm.validateAll();

    expect(isValid, false);

    expect(vm.state.titleError, isNotNull);
    expect(vm.state.titleError, 'Titel muss mind. 3 Charaktere lang sein.');
    expect(vm.state.goalsError, 'Es muss mind. 1 Aufgabe festgelegt werden.');
  });

  test('isFormValid returns true when all fields valid', () {
    final vm = container.read(
      addSessionViewModelProvider.notifier,
    );

    vm.state = vm.state.copyWith(
      title: 'My session',
      goals: <GoalModel>[
        const GoalModel(
          title: 'Test Goal',
          keptForFutureSessions: true,
        ),
      ],
      setGoals: true,
    );

    expect(vm.isFormValid, true);
  });

  test('createSession calls service and sets sessionId', () async {
    final mockService = MockAddSessionService();

    when(
      () => mockService.createSessionWithGoalsAndTasks(
        session: const SessionModel(title: 'Session'),
        goals: <GoalModel>[
          const GoalModel(
            title: 'Test Goal',
            keptForFutureSessions: true,
          ),
        ],
        tasks: <TaskModel>[
          const TaskModel(
            title: 'Test Task',
            keptForFutureSessions: true,
          ),
        ],
      ),
    ).thenAnswer((_) async => 123);

    when(
      () => mockService.updateSessionWithChanges(
        sessionId: 123,
        session: const SessionModel(title: 'Session2'),
        goalsToUpdate: <GoalModel>[
          const GoalModel(
            title: 'Test Goal',
            keptForFutureSessions: true,
          ),
        ],
        tasksToUpdate: <TaskModel>[
          const TaskModel(
            title: 'Test Task',
            keptForFutureSessions: true,
          ),
        ],
        goalIdsToDelete: <String>[],
        taskIdsToDelete: <String>[],
      ),
    ).thenAnswer((_) async => <dynamic, dynamic>{});
  });
}
