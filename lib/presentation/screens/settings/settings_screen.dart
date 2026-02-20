import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srl_app/common_widgets/spacing/spacing.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/presentation/screens/settings/pages/learning_strategy_settings_screen.dart';
import 'package:srl_app/presentation/screens/settings/pages/notification_settings_screen.dart';
import 'package:srl_app/presentation/screens/settings/pages/theme_settings_screen.dart';
import 'package:srl_app/presentation/screens/settings/pages/timer_settings_screen.dart';

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

  Future<void> _navigateToTimerSettings(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (context) => const TimerSettingsScreen(),
      ),
    );
  }

  Future<void> _navigateToLearningStrategiesSettings(
    BuildContext context,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (context) => const LearningStrategySettingsScreen(),
      ),
    );
  }

  Future<void> _navigateToIntroScreen(BuildContext context) async {
    await Navigator.pushNamed(context, AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const ScrollPhysics(),
          slivers: [
            SliverAppBar(
              centerTitle: true,
              title: Text(
                'Einstellungen',
                style: context.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              automaticallyImplyLeading: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSectionTile(
                      title: 'Aussehen',
                      icon: Icons.palette_outlined,
                      subtitle: 'Farbe und Darstellung anpassen',
                      onTap: () => _navigateToThemeSettings(context),
                    ),

                    const VerticalSpace(
                      size: SpaceSize.xsmall,
                    ),

                    _buildSectionTile(
                      title: 'Benachrichtigungen',
                      icon: Icons.notifications_active_outlined,
                      subtitle: 'Benachrichtigungen anpassen und konfigurieren',
                      onTap: () => _navigateToNotificationSettings(context),
                    ),

                    const VerticalSpace(
                      size: SpaceSize.xsmall,
                    ),

                    _buildSectionTile(
                      title: 'Lernstrategien',
                      icon: Icons.document_scanner_outlined,
                      subtitle: 'Lernstrategien anpassen und konfigurieren',
                      onTap: () =>
                          _navigateToLearningStrategiesSettings(context),
                    ),

                    const VerticalSpace(
                      size: SpaceSize.xsmall,
                    ),

                    _buildSectionTile(
                      title: 'Timer',
                      icon: Icons.timer_outlined,
                      subtitle:
                          'Timer-Einstellungen anpassen und konfigurieren',
                      onTap: () => _navigateToTimerSettings(context),
                    ),

                    const VerticalSpace(
                      size: SpaceSize.xsmall,
                    ),

                    _buildSectionTile(
                      title: 'Hilfe',
                      icon: Icons.question_mark_rounded,
                      subtitle: 'Wiederhole das Onboarding',
                      onTap: () => _navigateToIntroScreen(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
          style: context.textTheme.bodyMedium,
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
