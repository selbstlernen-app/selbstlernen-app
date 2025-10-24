import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_button.dart';
import 'package:srl_app/common_widgets/custom_text_field.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/goal_model.dart';
import 'package:srl_app/domain/models/task_model.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/date_input_fields.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/input_list.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_state.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';
import 'package:uuid/uuid.dart';

class StartInfoPage extends ConsumerStatefulWidget {
  const StartInfoPage({super.key, required this.navigateForward});
  final VoidCallback navigateForward;

  @override
  ConsumerState<StartInfoPage> createState() => _StartInfoPageState();
}

class _StartInfoPageState extends ConsumerState<StartInfoPage> {
  late TextEditingController _titleController;
  late TextEditingController _bigGoalController;
  late TextEditingController _smallGoalController;
  final ScrollController _scrollController = ScrollController();
  final Uuid uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: ref.read(addSessionViewModelProvider).title,
    );
    _bigGoalController = TextEditingController();
    _smallGoalController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bigGoalController.dispose();
    _smallGoalController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleAddGoal() {
    final String text = _bigGoalController.text.trim();
    if (text.isEmpty) return;

    ref
        .read(addSessionViewModelProvider.notifier)
        // Temporary goalId
        .addGoal(GoalModel(title: text, isCompleted: false, id: uuid.v4()));

    _bigGoalController.clear();
    _scrollDown();
  }

  void _handleAddTask() {
    final String text = _smallGoalController.text.trim();
    if (text.isEmpty) return;

    ref
        .read(addSessionViewModelProvider.notifier)
        // Temporary taskId
        .addTask(TaskModel(title: text, isCompleted: false, id: uuid.v4()));

    _smallGoalController.clear();
    _scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    final AddSessionState state = ref.watch(addSessionViewModelProvider);
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Title
                Text(
                  "Name der Lerneinheit",
                  style: context.textTheme.headlineMedium,
                ),
                CustomTextField(
                  onChanged: ref
                      .read(addSessionViewModelProvider.notifier)
                      .setTitle,
                  controller: _titleController,
                  hintText: "z.B. Info 1 - Vorlesung 3...",
                  errorText: ref
                      .read(addSessionViewModelProvider.notifier)
                      .validateTitle(),
                ),

                // Date and days
                Text(
                  "Art der Lerneinheit",
                  style: context.textTheme.headlineMedium,
                ),
                Row(
                  children: <Widget>[
                    CustomButton(
                      onPressed: () => ref
                          .read(addSessionViewModelProvider.notifier)
                          .setIsRepeating(false),
                      isActive: !state.isRepeating,
                      borderRadius: 10.0,
                      verticalPadding: 8.0,
                      label: "Einmalig",
                    ),
                    CustomButton(
                      isActive: state.isRepeating,
                      onPressed: () => ref
                          .read(addSessionViewModelProvider.notifier)
                          .setIsRepeating(true),
                      borderRadius: 10.0,
                      verticalPadding: 8.0,
                      label: "Wiederholend",
                    ),
                  ],
                ),
                if (state.isRepeating) const DateInputFields(),

                // Big/small goals
                Text(
                  "Ziele für diese Lerneinheit",
                  style: context.textTheme.headlineMedium,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        onPressed: () => ref
                            .read(addSessionViewModelProvider.notifier)
                            .setBigGoals(true),
                        label: "Große Ziele",
                        isActive: state.setBigGoals,
                        borderLeft: true,
                        verticalPadding: 8.0,
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        onPressed: () => ref
                            .read(addSessionViewModelProvider.notifier)
                            .setBigGoals(false),
                        label: "Kleine Ziele",
                        isActive: !state.setBigGoals,
                        borderRight: true,
                        verticalPadding: 8.0,
                      ),
                    ),
                  ],
                ),

                // Goal input fields
                InputList(
                  controller: state.setBigGoals
                      ? _bigGoalController
                      : _smallGoalController,
                  onEnter: state.setBigGoals ? _handleAddGoal : _handleAddTask,
                  isBigGoal: state.setBigGoals,
                  items: state.setBigGoals ? state.goals : state.tasks,
                  toolTip: state.setBigGoals
                      ? "Tipp: Halte deine Ziele so präzise und kurz wie möglich."
                      : "Du kannst kleinere Ziele später gruppieren.",
                ),
              ],
            ),
          ),
        ),

        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: CustomButton(
            label: "Weiter",
            isActive: ref
                .read(addSessionViewModelProvider.notifier)
                .canSubmit(),
            onPressed: () =>
                ref.read(addSessionViewModelProvider.notifier).canSubmit()
                ? widget.navigateForward()
                : null,
          ),
        ),
      ],
    );
  }
}
