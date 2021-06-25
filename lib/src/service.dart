import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications_handler/src/app_state.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  static void Function(AppState, Map<String, dynamic> payload)? _onTap;

  static bool _openedAppFromNotification = false;

  static bool get openedAppFromNotification => _openedAppFromNotification;

  static Future<String?> initialize({
    String? vapidKey,
    bool enableLogs = true,
    void Function(AppState, Map<String, dynamic> payload)? onTap,
  }) async {
    _onTap = onTap;
    _enableLog = enableLogs;

    // Firebase app not initialized.
    // if (Firebase.apps.isEmpty) await Firebase.initializeApp();

    /// Required only for iOS
    if (!kIsWeb && Platform.isIOS) await _fcm.requestPermission();

    _fcmToken = await _fcm.getToken(vapidKey: vapidKey);

    if (_enableLog) print("FCM Token initialized: $fcmToken");

    _fcm.onTokenRefresh.listen((token) {
      _fcmToken = token;
      if (_enableLog) print("FCM Token updated: $fcmToken");
    });

    final _bgMessage = await _fcm.getInitialMessage();
    if (_bgMessage != null) {
      _openedAppFromNotification = true;
      _onBackgroundMessage(_bgMessage);
    }

    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    return fcmToken;
  }

  static Future<void> _onMessage(RemoteMessage message) =>
      _notificationHandler(message, appState: AppState.open);

  static Future<void> _onBackgroundMessage(RemoteMessage message) =>
      _notificationHandler(message, appState: AppState.closed);

  static Future<void> _onMessageOpenedApp(RemoteMessage message) =>
      _notificationHandler(message, appState: AppState.background);

  static Future<FlutterLocalNotificationsPlugin>
      _initializeLocalNotifications() async {
    final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // iOS: IOSInitializationSettings(
      //   onDidReceiveLocalNotification: (id, title, body, payload) async {},
      // ),
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        if (_onTap != null)
          _onTap!(
            AppState.open,
            payload == null ? {} : jsonDecode(payload),
          );
      },
    );
    return _flutterLocalNotificationsPlugin;
  }

  static Future<void> _notificationHandler(
    RemoteMessage message, {
    AppState? appState,
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

    final id = DateTime.now().hashCode;

    if (appState == AppState.open)
      await _localNotifications.show(
        // message.notification?.hashCode ?? 0,
        id,
        message.notification?.title,
        message.notification?.body,
        notificationPlatformSpecifics,
        payload: jsonEncode(message.data),
      );

    /// if AppState is open, do not handle onTap here because it will trigger as soon as
    /// notification arrives, instead handle in initialize method in onSelectNotification callback.
    else if (_onTap != null) _onTap!(appState!, message.data);
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
