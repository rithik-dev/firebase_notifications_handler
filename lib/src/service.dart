import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications_handler/src/app_state.dart';
import 'package:flutter/cupertino.dart'
    show GlobalKey, NavigatorState, debugPrint;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Internal implementation class
class PushNotificationService {
  /// Internal [FirebaseMessaging] instance
  static final _fcm = FirebaseMessaging.instance;

  /// {@macro navigatorKey}
  static GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// [_navigatorKey] getter.
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  /// [_fcmToken] getter
  static String? get fcmToken => _fcmToken;

  /// {@macro fcmToken}
  static String? _fcmToken;

  /// {@macro enableLogs}
  static late bool _enableLogs;

  /// {@macro customSound}
  static String? _customSound;

  /// {@macro channelId}
  static late String _channelId;

  /// {@macro channelName}
  static late String _channelName;

  /// {@macro channelDescription}
  static late String _channelDescription;

  /// {@macro groupKey}
  static late String _groupKey;

  /// Called when token is refreshed.
  static Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  /// {@macro onTap}
  static void Function(
    GlobalKey<NavigatorState>,
    AppState,
    Map<String, dynamic> payload,
  )? _onTap;

  /// {@macro openedAppFromNotification}
  static bool _openedAppFromNotification = false;

  /// [_openedAppFromNotification] getter.
  static bool get openedAppFromNotification => _openedAppFromNotification;

  /// {@macro notificationIdCallback}
  static late int Function(RemoteMessage) _notificationIdCallback;

  /// {@macro onOpenNotificationArrive}
  static late void Function(
    GlobalKey<NavigatorState> navigatorKey,
    Map<String, dynamic> payload,
  )? _onOpenNotificationArrive;

  /// Initialize the implementation class
  static Future<String?> initialize({
    String? vapidKey,
    bool enableLogs = true,
    void Function(
      GlobalKey<NavigatorState>,
      AppState,
      Map<String, dynamic> payload,
    )?
        onTap,
    GlobalKey<NavigatorState>? navigatorKey,
    String? customSound,
    required String channelId,
    required String channelName,
    required String channelDescription,
    required String groupKey,
    required final int Function(RemoteMessage) notificationIdCallback,
    required void Function(
      GlobalKey<NavigatorState> navigatorKey,
      Map<String, dynamic> payload,
    )?
        onOpenNotificationArrive,
  }) async {
    _onTap = onTap;
    _enableLogs = true;
    _customSound = customSound;
    _notificationIdCallback = notificationIdCallback;
    _onOpenNotificationArrive = onOpenNotificationArrive;

    _channelId = channelId;
    _channelName = channelName;
    _channelDescription = channelDescription;
    _groupKey = groupKey;

    if (navigatorKey != null) _navigatorKey = navigatorKey;

    /// Required only for iOS
    if (!kIsWeb && Platform.isIOS) await _fcm.requestPermission();

    _fcmToken = await _fcm.getToken(vapidKey: vapidKey);

    if (_enableLogs) debugPrint("FCM Token initialized: $fcmToken");

    _fcm.onTokenRefresh.listen((token) {
      _fcmToken = token;
      if (_enableLogs) debugPrint("FCM Token updated: $fcmToken");
    });

    final _bgMessage = await _fcm.getInitialMessage();
    if (_bgMessage != null) {
      _openedAppFromNotification = true;
      _onBackgroundMessage(_bgMessage);
    }

    /// Registering the listeners
    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    return fcmToken;
  }

  /// [_onMessage] callback for the notification
  static Future<void> _onMessage(RemoteMessage message) =>
      _notificationHandler(message, appState: AppState.open);

  /// [_onBackgroundMessage] callback for the notification
  static Future<void> _onBackgroundMessage(RemoteMessage message) =>
      _notificationHandler(message, appState: AppState.closed);

  /// [_onMessageOpenedApp] callback for the notification
  static Future<void> _onMessageOpenedApp(RemoteMessage message) =>
      _notificationHandler(message, appState: AppState.background);

  /// [_initializeLocalNotifications] function to initialize the local
  /// notifications to show a notification when the app is in foreground.
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
            navigatorKey,
            AppState.open,
            payload == null ? {} : jsonDecode(payload),
          );
      },
    );
    return _flutterLocalNotificationsPlugin;
  }

  /// [_notificationHandler] implementation
  static Future<void> _notificationHandler(
    RemoteMessage message, {
    AppState? appState,
  }) async {
    if (_enableLogs) debugPrint("""\n
    ******************************************************* 
                      NEW NOTIFICATION
    *******************************************************
    Title: ${message.notification?.title}
    Body: ${message.notification?.body}
    Payload: ${message.data}
    *******************************************************\n
""");

    final _androidSpecifics = AndroidNotificationDetails(
      message.notification?.android?.channelId ?? _channelId,
      _channelName,
      _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      groupKey: _groupKey,
      sound: _customSound == null
          ? null
          : RawResourceAndroidNotificationSound(_customSound),
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

    if (appState == AppState.open) {
      await _localNotifications.show(
        _notificationIdCallback(message),
        message.notification?.title,
        message.notification?.body,
        notificationPlatformSpecifics,
        payload: jsonEncode(message.data),
      );
      if (_onOpenNotificationArrive != null)
        _onOpenNotificationArrive!(_navigatorKey, message.data);
    }

    /// if AppState is open, do not handle onTap here because it will trigger as soon as
    /// notification arrives, instead handle in initialize method in onSelectNotification callback.
    else if (_onTap != null) _onTap!(navigatorKey, appState!, message.data);
  }
}
