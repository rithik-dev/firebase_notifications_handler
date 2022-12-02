import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications_handler/src/app_state.dart';
import 'package:firebase_notifications_handler/src/constants.dart';
import 'package:firebase_notifications_handler/src/image_downloader.dart';
import 'package:flutter/cupertino.dart'
    show GlobalKey, NavigatorState, debugPrint;
import 'package:flutter/material.dart';
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
  static bool? _enableLogs;

  /// {@macro customSound}
  static String? _customSound;

  /// {@macro channelId}
  static String? _channelId;

  /// {@macro channelName}
  static String? _channelName;

  static late String _notificationIcon;

  /// {@macro channelDescription}
  static String? _channelDescription;

  /// {@macro groupKey}
  static String? _groupKey;

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

  /// {@macro openedAppFromNotification}
  static bool get openedAppFromNotification => _openedAppFromNotification;

  /// {@macro notificationIdCallback}
  static int Function(RemoteMessage)? _notificationIdCallback;

  /// {@macro onOpenNotificationArrive}
  static late void Function(
    GlobalKey<NavigatorState> navigatorKey,
    Map<String, dynamic> payload,
  )? _onOpenNotificationArrive;

  /// Initialize the implementation class
  static Future<String?> initialize({
    String? vapidKey,
    bool enableLogs = Constants.enableLogs,
    void Function(
      GlobalKey<NavigatorState>,
      AppState,
      Map<String, dynamic> payload,
    )?
        onTap,
    GlobalKey<NavigatorState>? navigatorKey,
    String? customSound,
    required bool handleInitialMessage,
    required String notificationIcon,
    required String channelId,
    required String channelName,
    required String channelDescription,
    required String? groupKey,
    int Function(RemoteMessage)? notificationIdCallback,
    required void Function(
      GlobalKey<NavigatorState> navigatorKey,
      Map<String, dynamic> payload,
    )?
        onOpenNotificationArrive,
  }) async {
    _onTap = onTap;
    _enableLogs = enableLogs;
    _customSound = customSound;
    _notificationIdCallback = notificationIdCallback;
    _onOpenNotificationArrive = onOpenNotificationArrive;
    _notificationIcon = notificationIcon;

    _channelId = channelId;
    _channelName = channelName;
    _channelDescription = channelDescription;
    _groupKey = groupKey;

    if (navigatorKey != null) _navigatorKey = navigatorKey;

    await _fcm.requestPermission();

    _fcmToken = await initializeFCMToken(vapidKey: vapidKey);

    if (handleInitialMessage) {
      final bgMessage = await _fcm.getInitialMessage();
      if (bgMessage != null) {
        _openedAppFromNotification = true;
        _onBackgroundMessage(bgMessage);
      }
    }

    /// Registering the listeners
    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    return fcmToken;
  }

  static Future<String?> initializeFCMToken({
    String? vapidKey,
    bool log = true,
  }) async {
    _fcmToken ??= await _fcm.getToken(vapidKey: vapidKey);

    if (_enableLogs ?? log) debugPrint("FCM Token initialized: $_fcmToken");

    _fcm.onTokenRefresh.listen((token) {
      _fcmToken = token;
      if (_enableLogs ?? log) debugPrint("FCM Token updated: $_fcmToken");
    });

    return _fcmToken;
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

  static FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  static FlutterLocalNotificationsPlugin? get flutterLocalNotificationsPlugin =>
      _flutterLocalNotificationsPlugin;

  /// [initializeLocalNotifications] function to initialize the local
  /// notifications to show a notification when the app is in foreground.
  static Future<FlutterLocalNotificationsPlugin>
      initializeLocalNotifications() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings(_notificationIcon),
      iOS: const DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin?.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;

        if (_onTap != null) {
          _onTap!(
            navigatorKey,
            AppState.open,
            payload == null ? {} : jsonDecode(payload),
          );
        }
      },
    );

    return _flutterLocalNotificationsPlugin!;
  }

  /// [_notificationHandler] implementation
  static Future<void> _notificationHandler(
    RemoteMessage message, {
    required AppState appState,
  }) async {
    _enableLogs ??= Constants.enableLogs;
    if (_enableLogs!) {
      debugPrint("""\n
    ******************************************************* 
                      NEW NOTIFICATION
    *******************************************************
    Title: ${message.notification?.title}
    Body: ${message.notification?.body}
    Payload: ${message.data}
    *******************************************************\n
""");
    }

    _channelId ??= Constants.channelId;
    _channelName ??= Constants.channelName;
    _channelDescription ??= Constants.channelDescription;

    StyleInformation? styleInformation;

    String? imageUrl;
    if (message.notification?.android?.imageUrl != null) {
      imageUrl = message.notification?.android?.imageUrl;
    } else if (message.notification?.apple?.imageUrl != null) {
      imageUrl = message.notification?.apple?.imageUrl;
    }

    if (appState == AppState.open && imageUrl != null) {
      final notificationImage = await ImageDownloaderService.downloadImage(
        url: imageUrl,
        fileName: 'notificationImage',
      );

      if (notificationImage != null) {
        styleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(notificationImage),
          largeIcon: FilePathAndroidBitmap(notificationImage),
          hideExpandedLargeIcon: true,
        );
      }
    }

    final androidSound = message.notification?.android?.sound ?? _customSound;

    final androidSpecifics = AndroidNotificationDetails(
      message.notification?.android?.channelId ?? _channelId!,
      _channelName!,
      channelDescription: _channelDescription!,
      importance: Importance.max,
      styleInformation: styleInformation,
      priority: Priority.high,
      groupKey: _groupKey,
      sound: androidSound == null
          ? null
          : RawResourceAndroidNotificationSound(androidSound),
      playSound: true,
      enableLights: true,
      enableVibration: true,
    );

    final iosSound = message.notification?.apple?.sound?.name ?? _customSound;
    final iOsSpecifics = DarwinNotificationDetails(
      sound: iosSound,
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationPlatformSpecifics = NotificationDetails(
      android: androidSpecifics,
      iOS: iOsSpecifics,
    );

    _flutterLocalNotificationsPlugin ??= await initializeLocalNotifications();

    _notificationIdCallback ??= (_) => DateTime.now().hashCode;

    if (appState == AppState.open) {
      await _flutterLocalNotificationsPlugin!.show(
        _notificationIdCallback!(message),
        message.notification?.title,
        message.notification?.body,
        notificationPlatformSpecifics,
        payload: jsonEncode(message.data),
      );

      if (_onOpenNotificationArrive != null) {
        _onOpenNotificationArrive!(_navigatorKey, message.data);
      }
    }

    /// if AppState is open, do not handle onTap here because it will trigger as soon as
    /// notification arrives, instead handle in initialize method in onSelectNotification callback.
    else if (_onTap != null) {
      _onTap!(_navigatorKey, appState, message.data);
    }
  }
}
