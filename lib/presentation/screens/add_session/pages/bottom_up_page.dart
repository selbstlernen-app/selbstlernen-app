import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_button.dart';
import 'package:srl_app/common_widgets/custom_item_tile.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/goal_model.dart';
import 'package:srl_app/domain/models/task_model.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/input_list.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';
import 'package:uuid/uuid.dart';

class BottomUpPage extends ConsumerStatefulWidget {
  const BottomUpPage({super.key, required this.navigateForward});
  final VoidCallback navigateForward;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BottomUpPageState();
}

class _BottomUpPageState extends ConsumerState<BottomUpPage> {
  final TextEditingController _goalController = TextEditingController();
  final List<TaskModel> _selectedTasks = <TaskModel>[];

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _groupTasksTo() {
    final String goalTitle = _goalController.text.trim();
    if (goalTitle.isEmpty || _selectedTasks.isEmpty) return;

    const Uuid uuid = Uuid();

    final GoalModel newGoal = GoalModel(
      title: goalTitle,
      isCompleted: false,
      id: uuid.v4(),
    );

    ref.read(addSessionViewModelProvider.notifier).addGoal(newGoal);

    // Link tasks to newly created goal
    for (final TaskModel task in _selectedTasks) {
      ref
          .read(addSessionViewModelProvider.notifier)
          .linkTaskToGoal(
            ref.read(addSessionViewModelProvider).tasks.indexOf(task),
            // Link to temporary id of this goal
            newGoal.id!,
          );
    }

    // Clear selections
    setState(() {
      _selectedTasks.clear();
    });
    _goalController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final AddSessionState state = ref.watch(addSessionViewModelProvider);

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Kleine Ziele gruppieren",
                  style: context.textTheme.headlineMedium,
                ),
                const VerticalSpace(size: SpaceSize.small),
                Text(
                  "Gruppiere kleine Ziele unter einem Großen zusammen. Du kannst diesen Schritt auch vorerst überspringen.",
                  style: context.textTheme.bodyMedium,
                ),

                const VerticalSpace(size: SpaceSize.large),

                // Select tasks
                if (state.ungroupedTasks.isNotEmpty) ...<Widget>[
                  Text(
                    "Verfügbare kleine Ziele",
                    style: context.textTheme.headlineSmall,
                  ),

                  const VerticalSpace(size: SpaceSize.small),

                  ...state.ungroupedTasks.map((TaskModel task) {
                    final bool isSelected = _selectedTasks.any(
                      (TaskModel t) => t.id == task.id,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Material(
                        color: isSelected
                            ? context.colorScheme.secondary
                            : context.colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(10.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          onTap: () => setState(() {
                            if (isSelected) {
                              _selectedTasks.removeWhere(
                                (TaskModel t) => t.id == task.id,
                              );
                            } else {
                              _selectedTasks.add(task);
                            }
                          }),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: CustomItemTile(
                              isLargeGoal: false,
                              text: task.title,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],

                if (_selectedTasks.isNotEmpty) ...<Widget>[
                  const VerticalSpace(size: SpaceSize.large),

                  Text(
                    "Großes Ziel formulieren (${_selectedTasks.length} ausgewählt)",
                    style: context.textTheme.headlineSmall,
                  ),

                  const VerticalSpace(size: SpaceSize.small),

                  InputList<TaskModel>(
                    controller: _goalController,
                    onEnter: _groupTasksTo,
                    isBigGoal: true,
                    items: const <TaskModel>[],
                    hideHeadline: true, // Empty, showing input only
                  ),
                ],

                // Grouped tasks and their goal
                if (state.goals.isNotEmpty) ...<Widget>[
                  const VerticalSpace(size: SpaceSize.large),

                  Text(
                    "Gruppierte Ziele",
                    style: context.textTheme.headlineMedium,
                  ),
                  const VerticalSpace(size: SpaceSize.small),
                  ...state.goals.map((GoalModel goal) {
                    final List<TaskModel> tasksForGoal = state.tasks
                        .where((TaskModel t) => t.goalId == goal.id)
                        .toList();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CustomItemTile(isLargeGoal: true, text: goal.title),
                          ...tasksForGoal.map(
                            (TaskModel task) => Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                top: 8.0,
                              ),
                              child: CustomItemTile(
                                isLargeGoal: false,
                                text: task.title,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),

        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: CustomButton(
            label: "not",
            onPressed: () => widget.navigateForward(),
          ),
        ),
      ],
    );
  }
}
