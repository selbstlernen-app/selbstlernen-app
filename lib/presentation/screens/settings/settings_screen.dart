import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/screens/settings/pages/notification_settings_screen.dart';
import 'package:srl_app/presentation/screens/settings/pages/theme_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _navigateToThemeSettings(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (context) => const ThemeSettingsScreen(),
      ),
    );
  }

  Future<void> _navigateToNotificationSettings(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (context) => const NotificationSettingsScreen(),
      ),
    );
  }

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

              _buildSectionTile(
                title: 'Aussehen',
                icon: Icons.palette_outlined,
                subtitle: 'Farbe und Darstellung anpassen',
                onTap: () => _navigateToThemeSettings(context),
              ),

              // const VerticalSpace(
              //   size: SpaceSize.xsmall,
              // ),

              // _buildSectionTile(
              //   title: 'Benachrichtigungen',
              //   icon: Icons.notifications_active_outlined,
              //   subtitle: 'Benachrichtigungen anpassen und konfigurieren',
              //   onTap: () => _navigateToNotificationSettings(context),
              // ),
              // const VerticalSpace(),
            ],
          ),
        ),
      ),
    );
  }

  // Tile for all settings leading to their respective page
  Widget _buildSectionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required String subtitle,
  }) {
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        leading: Icon(
          icon,
          color: context.colorScheme.primary,
        ),
        title: Text(
          title,
          style: context.textTheme.headlineSmall,
        ),
        subtitle: Text(
          subtitle,
          style: context.textTheme.bodySmall,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: context.colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}
