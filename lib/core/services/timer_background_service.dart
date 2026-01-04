import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:srl_app/core/utils/time_utils.dart';

/// Service to run the app in the background, when a session has been started
/// This is needed to see the time one has left in a phase without having to stay
/// on the app necessesarily
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  // Create notification channel for Android
  const channel = AndroidNotificationChannel(
    'timer_service',
    'Timer Service',
    description: 'Keep the timer running in background',
    importance: Importance.low,
  );

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'timer_service',
      initialNotificationTitle: '',
      initialNotificationContent: '',

      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.specialUse],
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
  );
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Check if app is open or not
  if (service is AndroidServiceInstance) {
    // On start of app force the initial notification to go into background
    await service.setAsBackgroundService();

    // When the app is closed, promote to foreground
    service.on('showNotification').listen((event) async {
      await service.setAsForegroundService();
    });

    // When the app is opened, demote to background
    service.on('hideNotification').listen((event) async {
      await service.setAsBackgroundService();
    });
  }

  Timer? timer;
  var remainingSeconds = 0;
  var currentPhaseTitle = '🧠 Fokuszeit';
  var currentSubtitle = 'Bleib fokussiert!';

  // Listen to remaining seconds left
  // Set the total seconds on phase start
  service.on('setTimer').listen((event) {
    remainingSeconds = event?['seconds'] as int;
  });

  // Listen for phase changes
  service.on('updatePhase').listen((event) {
    currentPhaseTitle = event?['title'] as String;
    currentSubtitle = event?['subtitle'] as String;
  });

  service.on('start').listen((event) {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (remainingSeconds > 0) {
        remainingSeconds--;

        // Send data back so UI is in sync
        service.invoke('update', {'remainingSeconds': remainingSeconds});

        // Update notification (Android)
        if (service is AndroidServiceInstance) {
          if (await service.isForegroundService()) {
            await service.setForegroundNotificationInfo(
              title: currentPhaseTitle,
              content:
                  '$currentSubtitle • ${TimeUtils.formatTime(remainingSeconds)}',
            );
          }
        }
      } else {
        service.invoke('finished');
        timer?.cancel();
      }
    });
  });

  service.on('stop').listen((event) async {
    timer?.cancel();
    await service.stopSelf();
  });
}
