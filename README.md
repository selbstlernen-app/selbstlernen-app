# Selbstlernen.app 2.0

**Selbstlernen.app 2.0** is a mobile application designed to support students in planning, conducting, and reflecting on their learning processes. The app enables users to create individual learning sessions, define specific goals and tasks, select suitable learning strategies, and organize their study time in a structured way.

During a learning session, features such as timers, reminders, and focus prompts help students stay attentive and engaged. After each session, the app provides an overview of what was achieved, including completed tasks, invested focus time, mood, and the perceived effectiveness of the learning strategies used. This feedback helps students not only understand what happened during a session, but also reflect on their learning behavior: What worked well? Where did the session differ from the plan? What could be improved next time?

By combining principles of self-regulated learning with accessible learning analytics, Selbstlernen.app 2.0 supports the development of sustainable learning routines — flexibly, mobile, and independent of the learning location.

The app was developed by [Marlene Dormeyer](https://github.com/madxox/) as part of her master’s thesis. An academic paper describing the application will soon be presented at the 21st International Conference on Design Science Research in Information Systems and Technology:

> Dormeyer, M., & Herwix, A. (2026). *Selbstlernen.app 2.0 – A Feedback-Oriented Mobile Application for Supporting Self-Regulated Learning in Higher Education*. The 21st International Conference on Design Science Research in Information Systems and Technology.

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
