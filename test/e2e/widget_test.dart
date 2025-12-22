// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srl_app/data/providers.dart';
import 'package:srl_app/data/repositories/settings_repository_imp.dart';

import 'package:srl_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Find home on navigation', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    final sharedPreferences = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          SettingsRepositoryImp(sharedPreferences),
        ),
      ],
    );

    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MyApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Home'), findsAtLeast(1));
  });
}
