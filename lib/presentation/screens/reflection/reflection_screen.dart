import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_button.dart';
import 'package:srl_app/common_widgets/custom_text_field.dart';
import 'package:srl_app/common_widgets/main_layout.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/common_widgets/time_break_down_item.dart';
import 'package:srl_app/core/constants/constants.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/session_instance_model.dart';
import 'package:srl_app/presentation/view_models/reflection/reflection_view_model.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({required this.instance, super.key});

  final SessionInstanceModel instance;

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final TextEditingController notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> submitReflection() async {
    final viewModel = ref.read(
      reflectionViewModelProvider(widget.instance).notifier,
    );

    await viewModel.complete(
      notes: notesController.text,
      mood: ref.read(reflectionViewModelProvider(widget.instance)).mood,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(Constants.successCompleted),
      ),
    );

    await Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.stats,
      arguments: SessionStatisticsArgs(
        sessionId: int.parse(widget.instance.sessionId),
        showGeneralStatsOnly: false,
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reflectionState = ref.watch(
      reflectionViewModelProvider(widget.instance),
    );
    final viewModel = ref.read(
      reflectionViewModelProvider(widget.instance).notifier,
    );

    print(reflectionState.totalTimeInBreak);

    return MainLayout(
      appBarTitle: 'Reflexion',
      content: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Lerneinheit abgeschlossen!',
                    style: context.textTheme.headlineMedium,
                  ),

                  const VerticalSpace(),

                  // Focus and break time
                  Column(
                    children: <Widget>[
                      TimeBreakdownItem(
                        icon: Icons.psychology,
                        label: 'Fokuszeit',
                        value: '${reflectionState.totalTimeFocused} Min',
                        color: AppPalette.pink,
                      ),

                      if (reflectionState.totalTimeInBreak != '00:00')
                        TimeBreakdownItem(
                          icon: Icons.coffee,
                          label: 'Pausenzeit',
                          value: '${reflectionState.totalTimeInBreak} Min',
                          color: AppPalette.orange,
                        ),

                      const VerticalSpace(size: SpaceSize.small),
                      Divider(
                        color: context.colorScheme.tertiary,
                        thickness: 4,
                        radius: BorderRadius.circular(10),
                      ),
                      const VerticalSpace(size: SpaceSize.small),

                      TimeBreakdownItem(
                        icon: Icons.timelapse_outlined,
                        label: 'Gesamte Zeit',
                        value: '${reflectionState.totalTimeSpent} Min',
                        color: AppPalette.sky,
                      ),
                    ],
                  ),

                  const VerticalSpace(size: SpaceSize.large),

                  // Mood Selection
                  Text(
                    'Wie fühlst du dich?',
                    style: context.textTheme.headlineSmall,
                  ),
                  const VerticalSpace(size: SpaceSize.small),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: Constants.emojiMoods.asMap().entries.map((
                      MapEntry<int, String> entry,
                    ) {
                      final emojiIndex = entry.key;
                      final emoji = entry.value;

                      final isSelected = reflectionState.mood == emojiIndex;

                      return InkWell(
                        onTap: () => viewModel.selectMood(emojiIndex),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.colorScheme.secondary
                                : context.colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const VerticalSpace(),

                  // Notes Field
                  Text('Notizen', style: context.textTheme.headlineSmall),
                  const VerticalSpace(size: SpaceSize.small),
                  CustomTextField(
                    controller: notesController,
                    maxLines: 5,
                    hintText: 'Was hast du gelernt? Wie lief die Einheit?',
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            width: context.mediaQuery.size.width,
            child: CustomButton(
              label: 'Abschließen',
              onPressed: submitReflection,
            ),
          ),
        ],
      ),
    );
  }
}
