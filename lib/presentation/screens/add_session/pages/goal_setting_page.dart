import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/custom_add_item_field.dart';
import 'package:srl_app/common_widgets/custom_error_text.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/goals_with_tasks_list.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';
import 'package:uuid/uuid.dart';

class GoalSettingPage extends ConsumerStatefulWidget {
  const GoalSettingPage({required this.navigateForward, super.key});
  final VoidCallback navigateForward;

  @override
  ConsumerState<GoalSettingPage> createState() => _GoalSettingPageState();
}

class _GoalSettingPageState extends ConsumerState<GoalSettingPage> {
  late TextEditingController _taskController;
  late TextEditingController _goalController;
  final ScrollController _scrollController = ScrollController();

  Set<String> expandedGoalIds = <String>{};
  static const String ungroupedTaskGoalId = '__ungrouped__';

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController();
    _taskController = TextEditingController();
  }

  @override
  void dispose() {
    _taskController.dispose();
    _goalController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleAddGoal() {
    final text = _goalController.text.trim();
    if (text.isEmpty) return;

    final state = ref.read(addSessionViewModelProvider);
    if (state.goals.any((GoalModel goal) => goal.title == text)) return;

    if (state.goals.length == 5) return;

    const uuid = Uuid();
    ref
        .read(addSessionViewModelProvider.notifier)
        // Temporary goalId
        .addGoal(
          GoalModel(
            title: text,
            id: uuid.v4(),
            keptForFutureSessions: true,
          ),
        );

    _goalController.clear();

    _scrollDown();
  }

  void _addTaskToGoal({required GoalModel goal}) {
    final taskText = _taskController.text.trim();
    if (taskText.isEmpty) return;

    final state = ref.read(addSessionViewModelProvider);

    // Check for duplicates
    if (state
        .tasksForGoal(goal.id!)
        .any((TaskModel task) => task.title == taskText)) {
      return;
    }

    ref
        .read(addSessionViewModelProvider.notifier)
        .addTaskToGoal(
          TaskModel(
            id: const Uuid().v4(),
            title: taskText,
            goalId: goal.id != ungroupedTaskGoalId ? goal.id : null,
            keptForFutureSessions: true,
          ),
          goal.id != ungroupedTaskGoalId ? goal.id : null,
        );

    _taskController.clear();

    setState(() {
      expandedGoalIds.add(goal.id!);
    });
  }

  void _toggleGoalExpansion(String goalId) {
    _taskController.clear();
    setState(() {
      if (expandedGoalIds.contains(goalId)) {
        expandedGoalIds.remove(goalId);
      } else {
        expandedGoalIds
          ..clear()
          ..add(goalId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addSessionViewModelProvider);

    final goalsToMap = [
      ...state.goals,
      const GoalModel(
        id: ungroupedTaskGoalId,
        title: 'Sonstige Aufgaben',
        keptForFutureSessions: false,
      ),
    ];

    return CustomScrollView(
      controller: _scrollController,
      physics: const ScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            Row(
              children: [
                const Icon(Icons.emoji_flags_rounded),
                const HorizontalSpace(size: SpaceSize.small),
                Text(
                  'Ziele festlegen',
                  style: context.textTheme.headlineMedium,
                ),
              ],
            ),
            const VerticalSpace(size: SpaceSize.xsmall),
            Text(
              '''Was möchtest du in dieser Einheit erreichen? Ziele helfen dir, den Fokus zu behalten.''',
              style: context.textTheme.bodyMedium,
            ),
            const VerticalSpace(
              size: SpaceSize.small,
            ),

            // Add button
            if (state.goals.length < 5)
              CustomAddItemField(
                onSubmitted: _handleAddGoal,
                onPressed: _handleAddGoal,
                controller: _goalController,
                hintText: 'Ich will...',
                hasError: state.goalError != null,
                markEditMode: state.isEditMode,
              ),
            const VerticalSpace(
              size: SpaceSize.xsmall,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                '''Tipp: Halte Ziele möglichst präzise.''',
                style: context.textTheme.bodySmall!.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            if (state.goalError != null)
              CustomErrorText(errorText: state.goalError!),

            const VerticalSpace(
              size: SpaceSize.small,
            ),

            ...goalsToMap.map((GoalModel goal) {
              final isUngrouped = goal.id == ungroupedTaskGoalId;
              final tasks = isUngrouped
                  ? state.ungroupedTasks
                  : state.tasksForGoal(goal.id!);

              return GoalWithTasksCard(
                key: ValueKey(goal.id),
                goal: goal,
                isExpanded: expandedGoalIds.contains(goal.id),
                onToggleExpand: () => _toggleGoalExpansion(goal.id!),
                onAddTask: () => _addTaskToGoal(goal: goal),
                tasksForGoal: tasks,
                taskController: _taskController,
              );
            }),
          ]),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    isActive: state.goalError == null,
                    label: 'Weiter',
                    onPressed: () => state.goalError == null
                        ? widget.navigateForward()
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
