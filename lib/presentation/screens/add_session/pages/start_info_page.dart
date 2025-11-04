import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/custom_error_text.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: ref.read(addSessionViewModelProvider).title,
    );
    _bigGoalController = TextEditingController();
    _smallGoalController = TextEditingController();

    // Initialize after build; if in edit mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AddSessionState state = ref.read(addSessionViewModelProvider);
      _titleController.text = state.title;
    });
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

    final AddSessionState state = ref.read(addSessionViewModelProvider);
    if (state.goals.any((GoalModel goal) => goal.title == text)) return;

    if (state.goals.length == 5) return;

    const Uuid uuid = Uuid();
    ref
        .read(addSessionViewModelProvider.notifier)
        // Temporary goalId
        .addGoal(GoalModel(title: text, isCompleted: false, id: uuid.v4()));

    _bigGoalController.clear();

    ref.read(addSessionViewModelProvider.notifier).validateAll();
    _scrollDown();
  }

  void _handleAddTask() {
    final String text = _smallGoalController.text.trim();
    if (text.isEmpty) return;

    final AddSessionState state = ref.read(addSessionViewModelProvider);
    if (state.tasks.any((TaskModel task) => task.title == text)) return;

    if (state.tasks.length == 10) return;

    const Uuid uuid = Uuid();
    ref
        .read(addSessionViewModelProvider.notifier)
        // Temporary taskId
        .addTask(TaskModel(title: text, isCompleted: false, id: uuid.v4()));

    _smallGoalController.clear();
    ref.read(addSessionViewModelProvider.notifier).validateAll();
    _scrollDown();
  }

  void _moveToSecondPage() {
    widget.navigateForward();
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
                  "Titel der Lerneinheit",
                  style: context.textTheme.headlineMedium,
                ),
                const VerticalSpace(size: SpaceSize.small),
                CustomTextField(
                  onChanged: ref
                      .read(addSessionViewModelProvider.notifier)
                      .setTitle,
                  controller: _titleController,
                  hintText: "z.B. Info 1 - Vorlesung 3...",
                  hasError: state.titleError != null,
                ),
                if (state.titleError != null)
                  CustomErrorText(errorText: state.titleError!),

                const VerticalSpace(size: SpaceSize.large),

                // Date and days
                Row(
                  children: <Widget>[
                    const Icon(Icons.event_repeat_rounded),
                    const HorizontalSpace(size: SpaceSize.small),
                    Text("Häufigkeit", style: context.textTheme.headlineSmall),
                  ],
                ),
                const VerticalSpace(size: SpaceSize.small),
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
                    const HorizontalSpace(size: SpaceSize.small),

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

                const VerticalSpace(size: SpaceSize.medium),

                // Set goals/tasks
                Text(
                  state.setGoals
                      ? "Ziele für diese Lerneinheit"
                      : "Aufgaben für diese Lerneinheit",
                  style: context.textTheme.headlineSmall,
                ),
                const VerticalSpace(size: SpaceSize.small),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        onPressed: () => ref
                            .read(addSessionViewModelProvider.notifier)
                            .setGoals(true),
                        label: "Ziele",
                        isActive: state.setGoals,
                        borderLeft: true,
                        verticalPadding: 8.0,
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        onPressed: () => ref
                            .read(addSessionViewModelProvider.notifier)
                            .setGoals(false),
                        label: "Aufgaben",
                        isActive: !state.setGoals,
                        borderRight: true,
                        verticalPadding: 8.0,
                      ),
                    ),
                  ],
                ),

                const VerticalSpace(size: SpaceSize.medium),

                InputList(
                  errorText: state.goalsError,
                  controller: state.setGoals
                      ? _bigGoalController
                      : _smallGoalController,
                  onEnter: state.setGoals ? _handleAddGoal : _handleAddTask,
                  isBigGoal: state.setGoals,
                  items: state.setGoals ? state.goals : state.tasks,
                  toolTip: state.setGoals
                      ? "Tipp: Halte deine Ziele so präzise und kurz wie möglich."
                      : "Tipp: Du kannst Aufgaben später unter Zielen gruppieren.",
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
                .watch(addSessionViewModelProvider.notifier)
                .isFormValid,
            onPressed: () =>
                ref.read(addSessionViewModelProvider.notifier).validateAll()
                ? _moveToSecondPage()
                : null,
          ),
        ),
      ],
    );
  }
}
