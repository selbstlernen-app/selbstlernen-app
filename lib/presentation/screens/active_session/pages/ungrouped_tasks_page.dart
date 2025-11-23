import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/task_model.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_state.dart';
import 'package:srl_app/presentation/view_models/active_session/active_session_view_model.dart';
import 'package:srl_app/common_widgets/custom_add_item_field.dart';

class UngroupedTasksPage extends ConsumerStatefulWidget {
  const UngroupedTasksPage({super.key, required this.instanceId});

  final int instanceId;

  @override
  ConsumerState<UngroupedTasksPage> createState() => _UngroupedTasksPageState();
}

class _UngroupedTasksPageState extends ConsumerState<UngroupedTasksPage> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _addTask() async {
    if (_controller.text.trim().isEmpty) return;

    await ref
        .read(activeSessionViewModelProvider(widget.instanceId).notifier)
        .addTask(_controller.text.trim(), goalId: null);

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final ActiveSessionState state = ref.watch(
      activeSessionViewModelProvider(widget.instanceId),
    );

    final ActiveSessionViewModel viewModel = ref.read(
      activeSessionViewModelProvider(widget.instanceId).notifier,
    );

    final List<TaskModel> ungroupedTasks = state.fullSession!.ungroupedTasks;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Sonstige Aufgaben',
                  style: context.textTheme.headlineMedium,
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: state.isEditMode
                      ? context.colorScheme.onTertiary
                      : context.colorScheme.primary,
                  child: IconButton(
                    onPressed: viewModel.toggleEditMode,
                    icon: state.isEditMode
                        ? const Icon(Icons.edit_off_outlined)
                        : const Icon(Icons.edit_outlined),
                  ),
                ),
              ],
            ),

            const VerticalSpace(size: SpaceSize.medium),

            // if empty tasks
            if (ungroupedTasks.isEmpty)
              const Expanded(
                child: Text(
                  "Noch keine sonstigen Aufgaben hinzugefügt. Berühre den Stift rechts oben und tippe eine Aufgabe ein.",
                ),
              ),

            // Ungrouped tasks listed
            if (ungroupedTasks.isNotEmpty)
              Expanded(
                child: ListView(
                  children: ungroupedTasks.map((TaskModel task) {
                    final bool isCompleted = state.completedTaskIds.contains(
                      task.id,
                    );

                    return Row(
                      children: <Widget>[
                        Checkbox(
                          value: isCompleted,
                          onChanged: (_) =>
                              viewModel.toggleTaskCompletion(task.id!),
                        ),

                        Expanded(
                          child: Text(
                            task.title,
                            style: context.textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w500,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),

                        if (state.isEditMode)
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: context.colorScheme.error,
                            ),
                            onPressed: () =>
                                viewModel.deleteTask(taskId: task.id!),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),

            if (state.isEditMode)
              CustomAddItemField(
                controller: _controller,
                hintText: "Neue Aufgabe...",
                onSubmitted: _addTask,
                onPressed: _addTask,
              ),
          ],
        ),
      ),
    );
  }
}
