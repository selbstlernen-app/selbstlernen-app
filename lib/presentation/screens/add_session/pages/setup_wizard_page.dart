import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_button.dart';
import 'package:srl_app/common_widgets/custom_error_text.dart';
import 'package:srl_app/common_widgets/custom_filter_chip.dart';
import 'package:srl_app/common_widgets/custom_text_field.dart';
import 'package:srl_app/common_widgets/segmented_toggle_button.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/view_models/add_session/add_session_view_model.dart';

class SetupWizardPage extends ConsumerStatefulWidget {
  const SetupWizardPage({super.key});

  @override
  ConsumerState<SetupWizardPage> createState() => _$SetupWizardPageState();
}

class _$SetupWizardPageState extends ConsumerState<SetupWizardPage> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();

    // Initialize after build; if in edit mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(addSessionViewModelProvider);
      _titleController.text = state.title;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editMode = ref.watch(
      addSessionViewModelProvider.select((s) => s.isEditMode),
    );
    final titleError = ref.watch(
      addSessionViewModelProvider.select((s) => s.titleError),
    );

    final isRepeating = ref.watch(
      addSessionViewModelProvider.select((s) => s.isRepeating),
    );

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Titel der Lerneinheit',
                  style: context.textTheme.headlineMedium,
                ),
                const VerticalSpace(size: SpaceSize.small),
                CustomTextField(
                  readOnly: editMode,
                  onChanged: ref
                      .read(addSessionViewModelProvider.notifier)
                      .setTitle,
                  controller: _titleController,
                  hintText: 'z.B. Info 1 - Vorlesung 3...',
                  maxLength: 35,
                  hasError: titleError != null,
                ),
                if (titleError != null) CustomErrorText(errorText: titleError!),

                const VerticalSpace(),

                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.event_repeat_rounded,
                    ),
                    const HorizontalSpace(size: SpaceSize.small),
                    Text('Häufigkeit', style: context.textTheme.headlineSmall),
                  ],
                ),
                const VerticalSpace(),
                Row(
                  children: <Widget>[
                    CustomFilterChip(
                      label: 'Einmalig',
                      isActive: !isRepeating,
                      onPressed: () => editMode
                          ? null
                          : ref
                                .read(addSessionViewModelProvider.notifier)
                                .setIsRepeating(isRepeating: false),
                    ),

                    const HorizontalSpace(size: SpaceSize.small),

                    CustomFilterChip(
                      label: 'Wiederholend',
                      isActive: isRepeating,
                      onPressed: () => editMode
                          ? null
                          : ref
                                .read(addSessionViewModelProvider.notifier)
                                .setIsRepeating(isRepeating: true),
                    ),
                  ],
                ),

                // Info Text
                const VerticalSpace(size: SpaceSize.small),
                AnimatedSwitcher(
                  switchInCurve: Curves.easeIn,
                  duration: const Duration(milliseconds: 300),
                  child: isRepeating
                      ? const Text(
                          key: ValueKey('habit_text'),
                          '''Etabliere feste Gewohnheiten. Plane deine Tage und schaffe eine Routine.''',
                        )
                      : const Text(
                          key: ValueKey('once_text'),
                          '''Einmalige Einheit ohne festen Zeitplan, geeignet für gezielte Aufgaben oder Projekte.''',
                        ),
                ),

                const VerticalSpace(
                  size: SpaceSize.xlarge,
                ),

                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.timer_outlined,
                    ),
                    const HorizontalSpace(size: SpaceSize.small),
                    Text(
                      'Einheiten-Art',
                      style: context.textTheme.headlineSmall,
                    ),
                  ],
                ),
                const VerticalSpace(),
                Wrap(
                  runSpacing: 8,
                  children: <Widget>[
                    CustomFilterChip(
                      label: 'Lerntagebuch',
                      isActive: !isRepeating,
                      onPressed: () => editMode
                          ? null
                          : ref
                                .read(addSessionViewModelProvider.notifier)
                                .setIsRepeating(isRepeating: false),
                    ),

                    const HorizontalSpace(size: SpaceSize.xsmall),

                    CustomFilterChip(
                      label: 'Lernzeit',
                      isActive: isRepeating,
                      onPressed: () => editMode
                          ? null
                          : ref
                                .read(addSessionViewModelProvider.notifier)
                                .setIsRepeating(isRepeating: true),
                    ),

                    const HorizontalSpace(size: SpaceSize.xsmall),
                    CustomFilterChip(
                      label: 'Fortgeschrittene Lernzeit',
                      isActive: isRepeating,
                      onPressed: () => editMode
                          ? null
                          : ref
                                .read(addSessionViewModelProvider.notifier)
                                .setIsRepeating(isRepeating: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
