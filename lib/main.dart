import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srl_app/core/routing/app_routes.dart';
import 'package:srl_app/core/services/notification_service.dart';
import 'package:srl_app/core/services/timer_background_service.dart';
import 'package:srl_app/core/theme/theme_provider.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/data/repositories/settings_repository_imp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  await NotificationService().init();
  await initializeDateFormatting('de_DE');

  // Initialize background service for timer
  await initializeBackgroundService();

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          SettingsRepositoryImp(sharedPreferences),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// Root of the application
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'SRL-App',
      supportedLocales: const <Locale>[Locale('de')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: theme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
