import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/view_models/settings/settings_view_model.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final notifier = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aussehen',
          style: context.textTheme.headlineLarge,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSection(
              context: context,
              title: 'Akzentfarbe',
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: AppPalette.themeColors.map((color) {
                  final isSelected =
                      state.primaryColor.toARGB32() == color.toARGB32();
                  return GestureDetector(
                    onTap: () => notifier.setPrimaryColor(color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: context.colorScheme.surface,
                                width: 4,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check_rounded,
                              color: context.colorScheme.surface,
                              size: 28,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),

            const VerticalSpace(
              size: SpaceSize.large,
            ),

            _buildSection(
              context: context,
              title: 'Darstellungsmodus',
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),

                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'System Modus',
                          style: context.textTheme.headlineSmall,
                        ),
                      ),
                      subtitle: Text(
                        state.followSystem
                            ? 'Geräte-Einstellung benutzen'
                            : 'Manuelle Einstellung benutzen',
                      ),

                      trailing: Switch(
                        value: state.followSystem,
                        onChanged: (_) => notifier.toggleFollowSystem(),
                      ),
                      onTap: notifier.toggleFollowSystem,
                    ),
                  ),

                  const VerticalSpace(
                    size: SpaceSize.small,
                  ),

                  Card(
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Dunkler Modus',
                          style: context.textTheme.headlineSmall,
                        ),
                      ),
                      subtitle: const Text('Dunkles Farbschema verwenden'),
                      trailing: Switch(
                        value: state.isDarkMode,
                        onChanged: state.followSystem
                            ? null
                            : (_) => notifier.toggleDarkMode(),
                      ),
                      onTap: state.followSystem
                          ? null
                          : notifier.toggleDarkMode,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.headlineSmall),

        const VerticalSpace(),

        child,
      ],
    );
  }
}
