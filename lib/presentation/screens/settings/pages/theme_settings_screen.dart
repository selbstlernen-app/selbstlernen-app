import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/theme/app_palette.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/screens/settings/widgets/build_section.dart';
import 'package:srl_app/presentation/screens/settings/widgets/settings_tile.dart';
import 'package:srl_app/presentation/view_models/settings/settings_view_model.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final notifier = ref.read(settingsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          textAlign: TextAlign.center,
          'Aussehen',
          style: context.textTheme.headlineLarge,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            buildSection(
              context: context,
              title: 'Akzentfarbe',
              child: Wrap(
                spacing: 20,
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
              size: SpaceSize.xlarge,
            ),

            buildSection(
              context: context,
              title: 'Darstellungsmodus',
              child: Column(
                children: [
                  SettingsTile(
                    title: 'System Modus',
                    subtitle: state.followSystem
                        ? 'Geräte-Einstellung benutzen'
                        : 'Manuelle Einstellung benutzen',
                    isEnabled: state.followSystem,
                    onToggle: notifier.toggleFollowSystem,
                  ),

                  SettingsTile(
                    title: 'Dunkler Modus',
                    subtitle: 'Dunkles Farbschema verwenden',
                    isEnabled: !state.followSystem && state.isDarkMode,
                    onToggle: notifier.toggleDarkMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
