import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/common_widgets.dart';
import 'package:srl_app/common_widgets/custom_error_text.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/models.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/date_input_fields.dart';
import 'package:srl_app/presentation/screens/add_session/widgets/input_list.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';
import 'package:uuid/uuid.dart';

class StartInfoPage extends ConsumerStatefulWidget {
  const StartInfoPage({required this.navigateForward, super.key});
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
      final state = ref.read(addSessionViewModelProvider);
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleAddGoal() {
    final text = _bigGoalController.text.trim();
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

    _bigGoalController.clear();

    ref.read(addSessionViewModelProvider.notifier).validateAll();
    _scrollDown();
  }

  void _handleAddTask() {
    final text = _smallGoalController.text.trim();
    if (text.isEmpty) return;

    final state = ref.read(addSessionViewModelProvider);
    if (state.tasks.any((TaskModel task) => task.title == text)) return;

    if (state.tasks.length == 10) return;

    const uuid = Uuid();
    ref
        .read(addSessionViewModelProvider.notifier)
        // Temporary taskId
        .addTask(
          TaskModel(
            title: text,
            id: uuid.v4(),
            keptForFutureSessions: true,
          ),
        );

    _smallGoalController.clear();
    ref.read(addSessionViewModelProvider.notifier).validateAll();
    _scrollDown();
  }

  void _moveToSecondPage() {
    widget.navigateForward();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addSessionViewModelProvider);
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (state.isEditMode) ...[
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppPalette.amber),
                      const HorizontalSpace(),
                      Expanded(
                        child: Text(
                          'Momentan befindest du dich im Editier-Modus',
                          style: context.textTheme.labelLarge!.copyWith(
                            color: AppPalette.amber,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const VerticalSpace(size: SpaceSize.xsmall),

                  Text(
                    'In diesem Modus kannst du nur beschränkt Elemente verändern',
                    style: context.textTheme.bodyMedium!.copyWith(
                      color: AppPalette.amber,
                    ),
                  ),
                  const VerticalSpace(),
                ],
                // Title
                Text(
                  'Titel der Lerneinheit',
                  style: context.textTheme.headlineMedium,
                ),
                const VerticalSpace(size: SpaceSize.small),
                CustomTextField(
                  readOnly: state.isEditMode,
                  onChanged: ref
                      .read(addSessionViewModelProvider.notifier)
                      .setTitle,
                  controller: _titleController,
                  hintText: 'z.B. Info 1 - Vorlesung 3...',
                  maxLength: 35,
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
                    Text('Häufigkeit', style: context.textTheme.headlineSmall),
                  ],
                ),
                const VerticalSpace(size: SpaceSize.small),
                Row(
                  children: <Widget>[
                    CustomButton(
                      onPressed: () => state.isEditMode
                          ? null
                          : ref
                                .read(addSessionViewModelProvider.notifier)
                                .setIsRepeating(isRepeating: false),
                      isActive: !state.isRepeating,
                      borderRadius: 10,
                      verticalPadding: 8,
                      label: 'Einmalig',
                    ),
                    const HorizontalSpace(size: SpaceSize.small),

                    CustomButton(
                      isActive: state.isRepeating,
                      onPressed: () => state.isEditMode
                          ? null
                          : ref
                                .read(addSessionViewModelProvider.notifier)
                                .setIsRepeating(isRepeating: true),
                      borderRadius: 10,
                      verticalPadding: 8,
                      label: 'Wiederholend',
                    ),
                  ],
                ),

                if (state.isRepeating) const DateInputFields(),

                const VerticalSpace(
                  size: SpaceSize.large,
                ),

                // Set goals/tasks
                Row(
                  children: <Widget>[
                    Icon(
                      state.setGoals
                          ? Icons.emoji_flags_rounded
                          : Icons.check_circle_rounded,
                    ),
                    const HorizontalSpace(size: SpaceSize.small),
                    Text(
                      state.setGoals
                          ? 'Ziele für diese Lerneinheit'
                          : 'Aufgaben für diese Lerneinheit',
                      style: context.textTheme.headlineSmall,
                    ),
                  ],
                ),

                const VerticalSpace(size: SpaceSize.small),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        onPressed: () => ref
                            .read(addSessionViewModelProvider.notifier)
                            .setGoals(setGoals: true),
                        label: 'Ziele',
                        isActive: state.setGoals,
                        borderLeft: true,
                        verticalPadding: 8,
                      ),
                    ),
                    Expanded(
                      child: CustomButton(
                        onPressed: () => ref
                            .read(addSessionViewModelProvider.notifier)
                            .setGoals(setGoals: false),
                        label: 'Aufgaben',
                        isActive: !state.setGoals,
                        borderRight: true,
                        verticalPadding: 8,
                      ),
                    ),
                  ],
                ),

                const VerticalSpace(),

                InputList(
                  markEditMode: state.isEditMode,
                  errorText: state.goalsError,
                  controller: state.setGoals
                      ? _bigGoalController
                      : _smallGoalController,
                  onEnter: state.setGoals ? _handleAddGoal : _handleAddTask,
                  onDelete: (index) {
                    final notifier = ref.read(
                      addSessionViewModelProvider.notifier,
                    );

                    if (state.setGoals) {
                      notifier.removeGoal(index);
                    } else {
                      notifier.removeTask(index);
                    }
                  },
                  isBigGoal: state.setGoals,
                  items: state.setGoals ? state.goals : state.tasks,
                  toolTip: state.setGoals
                      ? '''Tipp: Du kannst Ziele später in Aufgaben aufbrechen.'''
                      : '''Tipp: Du kannst Aufgaben später unter Zielen gruppieren.''',
                ),
              ],
            ),
          ),
        ),

        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: CustomButton(
            label: 'Weiter',
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
