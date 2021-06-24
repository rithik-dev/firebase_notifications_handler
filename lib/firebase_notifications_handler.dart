library firebase_notifications_handler;

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  // ADD THIS IN ANDROID MANIFEST FOR DEFAULT CHANNEL (mandatory for custom sound when app closed)
  //
  // <meta-data
  //             android:name="com.google.firebase.messaging.default_notification_channel_id"
  //             android:value="<same as channelId in _notificationHandler>" />
  //
  // ADD AUDIO FILE in android/app/src/main/res/raw/____.mp3 FOR CUSTOM SOUND

  static final _fcm = FirebaseMessaging.instance;

  static String? get fcmToken => _fcmToken;
  static String? _fcmToken;

  static late bool _enableLog;

  static Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  static Future<String?> initialize({bool enableLogs = true}) async {
    _enableLog = enableLogs;

    // Firebase app not initialized.
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();

    /// Required only for iOS
    await _fcm.requestPermission();

    _fcmToken = await _fcm.getToken();

    if (_enableLog) print("FCM Token initialized: $fcmToken");

    _fcm.onTokenRefresh.listen((token) {
      _fcmToken = token;
      if (_enableLog) print("FCM Token updated: $fcmToken");
    });

    FirebaseMessaging.onMessage.listen(_appOpenNotificationHandler);
    FirebaseMessaging.onBackgroundMessage(_notificationHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_notificationHandler);

    return fcmToken;
  }

  static Future<FlutterLocalNotificationsPlugin>
      _initializeLocalNotifications() async {
    final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: IOSInitializationSettings(
          onDidReceiveLocalNotification: (id, title, body, payload) async {},
        ));
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    return _flutterLocalNotificationsPlugin;
  }

  static Future<void> _appOpenNotificationHandler(RemoteMessage message) =>
      _notificationHandler(message, showLocalNotification: true);

  static Future<void> _notificationHandler(
    RemoteMessage message, {
    bool showLocalNotification = false,
  }) async {
    if (_enableLog) print("""\n
    ******************************************************* 
                      NEW NOTIFICATION
    ******************************************************* 
    Title: ${message.notification?.title}
    Body: ${message.notification?.body}
    Payload: ${message.data}
    *******************************************************\n
""");

    // Firebase app not initialized.
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();

    final _androidSpecifics = AndroidNotificationDetails(
      message.notification?.android?.channelId ?? 'Notifications',
      'Notifications',
      'Notifications',
      importance: Importance.max,
      priority: Priority.high,
      groupKey: '',
      // sound: RawResourceAndroidNotificationSound('notification_sound'),
      playSound: true,
      enableLights: true,
      enableVibration: true,
    );

    final _iOsSpecifics = const IOSNotificationDetails();

    final notificationPlatformSpecifics = NotificationDetails(
      android: _androidSpecifics,
      iOS: _iOsSpecifics,
    );

    final _localNotifications = await _initializeLocalNotifications();

    if (showLocalNotification)
      await _localNotifications.show(
        message.notification?.hashCode ?? 0,
        message.notification?.title,
        message.notification?.body,
        notificationPlatformSpecifics,
        payload: jsonEncode(message.data),
      );
  }
}


/*
*    To send FCM notification using REST API:
*
*  ENDPOINT:
*     https://fcm.googleapis.com/fcm/send
*
*  HEADERS:
*       Content-Type: application/json
*       Authorization: key=<SERVER_KEY_FROM_FIREBASE_CLOUD_MESSAGING>
*
*  BODY:
*  {
      "to": <FCM_TOKEN>,
      "notification": {
          "title": "Title here",
          "body": "Body here",
      }
*  }
*
* */