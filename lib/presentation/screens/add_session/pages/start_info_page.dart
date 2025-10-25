import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_button.dart';
import 'package:srl_app/common_widgets/custom_text_field.dart';
import 'package:srl_app/common_widgets/horizontal_space.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
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

    const Uuid uuid = Uuid();
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

    const Uuid uuid = Uuid();
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
                const VerticalSpace(size: SpaceSize.small),
                CustomTextField(
                  onChanged: ref
                      .read(addSessionViewModelProvider.notifier)
                      .setTitle,
                  controller: _titleController,
                  hintText: "z.B. Info 1 - Vorlesung 3...",
                  errorText: state.titleError,
                ),

                const VerticalSpace(size: SpaceSize.large),

                // Date and days
                Text(
                  "Art der Lerneinheit",
                  style: context.textTheme.headlineMedium,
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

                const VerticalSpace(size: SpaceSize.large),

                // Big/small goals
                Text(
                  "Ziele für diese Lerneinheit",
                  style: context.textTheme.headlineMedium,
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

                const VerticalSpace(size: SpaceSize.medium),

                InputList(
                  controller: state.setBigGoals
                      ? _bigGoalController
                      : _smallGoalController,
                  onEnter: state.setBigGoals ? _handleAddGoal : _handleAddTask,
                  isBigGoal: state.setBigGoals,
                  items: state.setBigGoals ? state.goals : state.tasks,
                  toolTip: state.setBigGoals
                      ? "Tipp: Halte deine Ziele so präzise und kurz wie möglich."
                      : "Tipp: Du kannst kleine Ziele später unter großen Zielen gruppieren.",
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
                ? widget.navigateForward()
                : null,
          ),
        ),
      ],
    );
  }
}
