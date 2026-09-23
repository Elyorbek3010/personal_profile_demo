import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final StreamController<void> _scheduleUpdateController = StreamController<void>.broadcast();

  Stream<void> get onScheduleUpdate => _scheduleUpdateController.stream;

  Future<void> init() async {
    // Request permission (iOS specific, but safe to call on Android)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    log('User granted permission: ${settings.authorizationStatus}');

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen to messages in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
      
      // Notify listeners (like TimetableScreen) to reload data
      _scheduleUpdateController.add(null);
    });
  }

  Future<String?> getToken() async {
    try {
      String? token = await _fcm.getToken();
      log("FCM Token: $token");
      return token;
    } catch (e) {
      log("Failed to get FCM token: $e");
      return null;
    }
  }

  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;
}
