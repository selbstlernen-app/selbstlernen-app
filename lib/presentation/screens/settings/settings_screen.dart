import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/screens/settings/pages/theme_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Einstellungen',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineLarge,
              ),
              const VerticalSpace(),

              _buildSettingsSection(
                title: 'Aussehen',
                items: [
                  _SettingsItem(
                    icon: Icons.palette_outlined,
                    title: 'Aussehen',
                    subtitle: 'Farbe und Darstellung anpassen',
                    onTap: () => _navigateToThemeSettings(context),
                  ),
                ],
              ),
              const VerticalSpace(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.headlineSmall!.copyWith(
            color: context.colorScheme.primary,
          ),
        ),

        const VerticalSpace(
          size: SpaceSize.small,
        ),

        // Setting items
        Column(
          children: items.map((item) {
            return Column(
              children: [
                _buildSettingsTile(item),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(_SettingsItem item) {
    return ListTile(
      tileColor: context.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      leading: Icon(
        item.icon,
        color: context.colorScheme.primary,
      ),
      title: Text(
        item.title,
        style: context.textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: item.subtitle != null
          ? Text(
              item.subtitle!,
              style: context.textTheme.bodySmall,
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: context.colorScheme.onSurfaceVariant,
      ),
      onTap: item.onTap,
    );
  }

  void _navigateToThemeSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ThemeSettingsScreen(),
      ),
    );
  }
}

class _SettingsItem {
  _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
}
