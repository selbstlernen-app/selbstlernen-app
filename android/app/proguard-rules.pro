# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.provider.FirebaseInitProvider { *; }

# Flutter Background Service
-keep class id.flutter.flutter_background_service.** { *; }
-keep class id.flutter.flutter_background_service_android.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keeping the entry point for the background service
-keep class * extends io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
