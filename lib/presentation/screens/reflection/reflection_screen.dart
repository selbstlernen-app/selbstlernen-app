import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/custom_button.dart';
import 'package:srl_app/common_widgets/custom_text_field.dart';
import 'package:srl_app/common_widgets/loading_indicator.dart';
import 'package:srl_app/common_widgets/main_layout.dart';
import 'package:srl_app/common_widgets/vertical_space.dart';
import 'package:srl_app/core/constants/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/main_navigation.dart';
import 'package:srl_app/presentation/view_models/reflection/reflection_state.dart';
import 'package:srl_app/presentation/view_models/reflection/reflection_view_model.dart';

class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key, required this.sessionInstanceId});

  final int sessionInstanceId;

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final TextEditingController notesController = TextEditingController();

  List<String> emojiMoods = <String>["😥", '😡', '😐', "🙂", '🥳'];

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> submitReflection() async {
    final ReflectionViewModel viewModel = ref.read(
      reflectionViewModelProvider(widget.sessionInstanceId).notifier,
    );

    await viewModel.submitReflection(notes: notesController.text);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 2),
        content: Text("Einheit erfolgreich abgeschlossen!"),
      ),
    );

    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => const MainNavigation(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ReflectionState> state = ref.watch(
      reflectionViewModelProvider(widget.sessionInstanceId),
    );
    final ReflectionViewModel viewModel = ref.read(
      reflectionViewModelProvider(widget.sessionInstanceId).notifier,
    );

    return state.when(
      loading: () => const LoadingIndicator(),
      error: (Object error, StackTrace stack) =>
          Center(child: Text('Error: $error')),
      data: (ReflectionState reflectionState) {
        return MainLayout(
          navigateBack: () => Navigator.of(context).pop(),
          appBarTitle: "Reflexion",
          content: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Session Summary
                      Text(
                        'Lerneinheit abgeschlossen!',
                        style: context.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),

                      const VerticalSpace(size: SpaceSize.medium),

                      // Stats Card
                      Column(
                        children: <Widget>[
                          _StatRow(
                            label: 'Gesamte Fokuszeit:',
                            value: reflectionState.totalTimeFocused,
                          ),
                          _StatRow(
                            label: 'Gesamte Pausenzeit:',
                            value: reflectionState.totalTimeInBreak,
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
                        children: emojiMoods.asMap().entries.map((
                          MapEntry<int, String> entry,
                        ) {
                          final int emojiIndex = entry.key;
                          final String emoji = entry.value;

                          final bool isSelected =
                              reflectionState.mood == emojiIndex;

                          return InkWell(
                            onTap: () => viewModel.selectMood(emojiIndex),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? context.colorScheme.secondary
                                    : context.colorScheme.tertiary,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 16.0,
                                ),
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 28.0),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const VerticalSpace(size: SpaceSize.large),

                      // Notes Field
                      Text('Notizen', style: context.textTheme.headlineSmall),
                      const VerticalSpace(size: SpaceSize.small),
                      CustomTextField(
                        controller: notesController,
                        maxLines: 5,
                        hintText: "Was hast du gelernt? Wie lief die Einheit?",
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: context.mediaQuery.size.width,
                child: CustomButton(
                  label: 'Abschließen',
                  // TODO: instead of home navigate to LAD later
                  onPressed: submitReflection,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: context.textTheme.bodyLarge),
          Text(value, style: context.textTheme.titleMedium),
        ],
      ),
    );
  }
}
