import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zynzynzynsahur/app_config.dart';
import 'package:zynzynzynsahur/services/zynyo_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  Timer? _pollTimer;
  int _lastKnownCount = 0;

  Future<void> init() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Set up local notifications (mobile only)
    if (!kIsWeb) {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings();
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _localNotifications.initialize(initSettings);
    }

    final token = await _messaging.getToken(vapidKey: AppConfig.firebaseKey);
    print("FCM Token: $token");

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message: ${message.notification?.title}");
      _showLocalNotification(1, title: message.notification?.title, body: message.notification?.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleNotificationTap(initial);
    }

    print("init done");
  }

  void _handleNotificationTap(RemoteMessage message) {
    final documentUUID = message.data['documentUUID'];
    if (documentUUID != null) {
      print("Navigate to document: $documentUUID");
    }
  }

  Future<void> startPolling(ZynyoService zynyoService) async {
    _lastKnownCount = await zynyoService.getDocumentCount();

    _pollTimer = Timer.periodic(Duration(seconds: 60), (_) async {
      try {
        final newCount = await zynyoService.getDocumentCount();
        if (newCount > _lastKnownCount) {
          final diff = newCount - _lastKnownCount;
          _showLocalNotification(
            diff,
            title: "New Sign Request",
            body: "$diff new document(s) require your signature",
          );
          _lastKnownCount = newCount;
        }
      } catch (e) {
        print("Poll error: $e");
      }
    });
  }

  Future<void> _showLocalNotification(int count, {String? title, String? body}) async {
    if (kIsWeb) {
      // Web notifications are handled by the service worker
      // Firebase Console test messages will show via the SW automatically
      print("Web notification: $title - $body");
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'sign_requests',       // channel id
      'Sign Requests',       // channel name
      channelDescription: 'Notifications for new sign requests',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      0,
      title ?? 'New Sign Request',
      body ?? '$count new document(s) require your signature',
      details,
    );
  }

  void stopPolling() {
    _pollTimer?.cancel();
  }
}