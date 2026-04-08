# SRL-App

Repository for the development of a mobile SRL application, also accessible at https://github.com/madxox/SRL-App.

## 📍 Getting started

To set up the application, and or develop it locally, following set up is needed:

1. Install [Flutter](https://docs.flutter.dev/get-started)
2. Install the Flutter extension for your IDE (I used the [VSCode extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter))
3. Install an emulator; either Android or iOS. A local device can also be used
4. Check per <code>flutter doctor</code> in the terminal, if all has been correctly installed
5. Clone the github repository
6. Run <code>flutter pub get</code> to install the dependencies
7. Run <code>dart pub run build_runner build --delete-conflicting-outputs</code> in terminal to build all auto-generated files locally
8. Open the emulator and run the app using <code>flutter run</code>

## 📦 Packages Used

The project uses various packages with the following marking the most important ones:

💻 General Packages

- drift and shared_preferences for database management
- permission_handler for permission handling
- riverpod for state management
- freezed for code generation of models
- async & rxdart for stream management
- intl for date formatting
- fl_chart for charts
- mocktail for writing tests
- very_good_analysis as linter

💄 UI Packages

- flutter_heatmap_calendar for visualizing learning intensity; forked version used (see https://github.com/madxox/flutter_heatmap_calendar.git)
- flutter_slidable for slidable tiles
- flutter_native_splash and flutter_launcher_icons for the splash screen and launcher icon
