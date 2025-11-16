import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/domain/services/add_session_service.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class MockAddSessionService extends Mock implements AddSessionService {}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  test('setPrompts updates state fields correctly', () {
    final AddSessionViewModel vm = container.read(
      addSessionViewModelProvider.notifier,
    );

    vm.setPrompts(focus: true, focusPromptInterval: 10);

    final AddSessionState state = container.read(addSessionViewModelProvider);

    expect(state.hasFocusPrompt, true);
    expect(state.focusPromptInterval, 10);
  });

  test('validateAll returns false and sets error messages', () {
    final AddSessionViewModel vm = container.read(
      addSessionViewModelProvider.notifier,
    );

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

    final bool isValid = vm.validateAll();

    expect(isValid, false);

    expect(vm.state.titleError, isNotNull);
    expect(vm.state.dateError, "Startdatum muss gegeben sein.");
    expect(vm.state.selectedDaysError, isNotNull);
    expect(vm.state.goalsError, "Es muss mind. 1 Aufgabe festgelegt werden.");
  });

  test('isFormValid returns true when all fields valid', () {
    final AddSessionViewModel vm = container.read(
      addSessionViewModelProvider.notifier,
    );

    vm.state = vm.state.copyWith(
      title: 'My session',
      goals: <GoalModel>[
        const GoalModel(title: 'Test Goal', isCompleted: false),
      ],
      setGoals: true,
    );

    expect(vm.isFormValid, true);
  });

  test('createSession calls service and sets sessionId', () async {
    final MockAddSessionService mockService = MockAddSessionService();

    when(
      () => mockService.createSessionWithGoalsAndTasks(
        session: const SessionModel(title: "Session"),
        goals: <GoalModel>[
          const GoalModel(title: 'Test Goal', isCompleted: false),
        ],
        tasks: <TaskModel>[
          const TaskModel(title: 'Test Task', isCompleted: false),
        ],
      ),
    ).thenAnswer((_) async => 123);

    when(
      () => mockService.updateSessionWithChanges(
        sessionId: 123,
        session: const SessionModel(title: "Session2"),
        goalsToUpdate: <GoalModel>[
          const GoalModel(title: 'Test Goal', isCompleted: false),
        ],
        tasksToUpdate: <TaskModel>[
          const TaskModel(title: 'Test Task', isCompleted: true),
        ],
        goalIdsToDelete: <String>[],
        taskIdsToDelete: <String>[],
      ),
    ).thenAnswer((_) async => <dynamic, dynamic>{});
  });
}
