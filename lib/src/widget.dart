import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications_handler/src/app_state.dart';
import 'package:firebase_notifications_handler/src/constants.dart';
import 'package:firebase_notifications_handler/src/service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Wrap this widget on the [MaterialApp] to enable receiving notifications.
class FirebaseNotificationsHandler extends StatefulWidget {
  /// {@template fcmToken}
  /// Firebase messaging token
  /// {@endtemplate}
  static String? get fcmToken => PushNotificationService.fcmToken;

  /// {@template navigatorKey}
  /// Default [GlobalKey] navigator of type [NavigatorState].
  ///
  /// Can be passed to the material app and can be used in [onTap] callback
  /// to get the current navigator state or the current context etc.
  ///
  /// If you already have a navigator key initiated in the app,
  /// pass the same key in the [defaultNavigatorKey].
  ///
  /// See also:
  ///   * [onTap] parameter.
  ///   * [defaultNavigatorKey] parameter.
  /// {@endtemplate}
  static GlobalKey<NavigatorState>? get navigatorKey =>
      PushNotificationService.navigatorKey;

  /// {@template openedAppFromNotification}
  /// A boolean that can be used to see whether the app was initially
  /// opened from a notification.
  /// {@endtemplate}
  static bool get openedAppFromNotification =>
      PushNotificationService.openedAppFromNotification;

  /// On web, a [vapidKey] is required to fetch the default FCM token for the device.
  /// The fcm token can be accessed from the [onFCMTokenInitialize] or [onFCMTokenUpdate] callbacks.
  final String? vapidKey;

  /// {@template customSound}
  /// Pass in the name of the audio file as a string if you
  /// want a custom sound for the notification.
  ///
  /// .
  ///
  /// Android: Add the audio file in android/app/src/main/res/raw/___audio-file-here___
  ///
  /// iOS: Add the audio file in Runner/Resources/___audio-file-here___
  ///
  /// .
  ///
  /// Add the default channelId in the AndroidManifest file in your project.
  ///
  ///   <meta-data
  ///      android:name="com.google.firebase.messaging.default_notification_channel_id"
  ///      android:value="ID" />
  ///
  /// Pass in the same "ID" in the [channelId] parameter.
  /// {@endtemplate}
  final String? customSound;

  /// {@template handleInitialMessage}
  ///
  /// Whether to check if the application has been opened
  /// from a terminated state via a [RemoteMessage].
  ///
  /// If false, then [openedAppFromNotification] will always be false.
  ///
  /// If true, then checks for the initial message, and
  /// if it exists, [onTap] is called with [AppState.closed].
  ///
  /// {@endtemplate}
  final bool handleInitialMessage;

  /// {@template channelId}
  /// If message.notification?.android?.channelId exists in the map,
  /// then it is used, if not then the default value is used, else the value
  /// passed will be used.
  ///
  /// The notification channel's id. Defaults to 'Notifications'.
  ///
  /// Required for Android 8.0 or newer.
  /// {@endtemplate}
  final String channelId;

  /// {@template channelName}
  /// The notification channel's name. Defaults to 'Notifications'.
  ///
  /// Required for Android 8.0 or newer.
  /// {@endtemplate}
  final String channelName;

  /// {@template channelDescription}
  /// The notification channel's description. Defaults to 'Notifications'.
  ///
  /// Required for Android 8.0 or newer.
  /// {@endtemplate}
  final String channelDescription;

  /// {@template groupKey}
  /// Specifies the group that this notification belongs to.
  ///
  /// For Android 7.0 or newer.
  /// {@endtemplate}
  final String? groupKey;

  /// {@template enableLogs}
  /// Whether to enable logs on certain events like new notification or
  /// [fcmToken] updates etc.
  /// {@endtemplate}
  final bool enableLogs;

  /// If you have a navigator key initialized in your app, then pass the
  /// key here, this will be sent back in the onTap callback which can be
  /// used to see the currentState of the navigator, current context etc.
  ///
  /// If yoy don't have a key already initialized, you can use
  /// the getter [navigatorKey]. Don't forget to pass the key in the
  /// [MaterialApp]'s navigatorKey parameter to register it for your app.
  final GlobalKey<NavigatorState>? defaultNavigatorKey;

  /// {@template notificationIdCallback}
  /// Can be passed to modify the id used by the local notification when app is in foreground
  /// {@endtemplate}
  final int Function(RemoteMessage)? notificationIdCallback;

  /// {@template onFCMTokenInitialize}
  /// This callback is triggered when the [fcmToken] initializes.
  /// {@endtemplate}
  final void Function(BuildContext, String?)? onFCMTokenInitialize;

  /// {@template onFCMTokenUpdate}
  /// This callback is triggered when the [fcmToken] updates.
  /// {@endtemplate}
  final void Function(BuildContext, String?)? onFCMTokenUpdate;

  /// {@template onOpenNotificationArrive}
  /// This callback is triggered when the a new notification arrives
  /// when the app is open i.e. appState is [AppState.open].
  ///
  /// When the notification is tapped on, [onTap] is called.
  ///
  /// See also:
  ///   * [onTap] parameter.
  /// {@endtemplate}
  final void Function(
    GlobalKey<NavigatorState> navigatorKey,
    Map payload,
  )? onOpenNotificationArrive;

  /// {@template onTap}
  /// This callback is triggered when the notification is tapped.
  /// It provides 3 values namely:
  ///
  ///   * [navigatorKey] which can be used to push
  /// or pop routes by extracting the [navigatorKey.currentContext] or
  /// the [navigatorKey.currentState] of the navigator.
  ///
  ///   * [AppState] is an enum which provides the app state when the
  ///   notification arrived.
  ///
  ///   * [payload] is the payload passed to the notification in the 'data'
  ///   parameter when creating the notification.
  /// {@endtemplate}
  final void Function(
    GlobalKey<NavigatorState> navigatorKey,
    AppState appState,
    Map payload,
  )? onTap;

  /// The child of the widget. Typically a [MaterialApp].
  final Widget child;

  const FirebaseNotificationsHandler({
    Key? key,
    this.vapidKey,
    this.enableLogs = true,
    this.onTap,
    this.onFCMTokenInitialize,
    this.onFCMTokenUpdate,
    this.onOpenNotificationArrive,
    this.defaultNavigatorKey,
    this.customSound,
    this.notificationIdCallback,
    this.handleInitialMessage = true,
    this.channelId = Constants.channelId,
    this.channelName = Constants.channelName,
    this.channelDescription = Constants.channelDescription,
    this.groupKey,
    required this.child,
  }) : super(key: key);

  static const initializeFCMToken = PushNotificationService.initializeFCMToken;
  static final onFCMTokenRefresh = PushNotificationService.onTokenRefresh;

  /// Trigger FCM notification.
  ///
  /// [cloudMessagingServerKey] : The server key from the cloud messaging console.
  /// This key is required to trigger the notification.
  ///
  /// [title] : The notification's title.
  ///
  /// [body] : The notification's body.
  ///
  /// [imageUrl] : The notification's image URL.
  ///
  /// [fcmTokens] : List of the registered devices' tokens.
  ///
  /// [payload] : Notification payload, is provided in the [onTap] callback.
  ///
  /// [additionalHeaders] : Additional headers,
  /// other than 'Content-Type' and 'Authorization'.
  ///
  /// [notificationMeta] : Additional content that you might want to pass
  /// in the "notification" attribute, apart from title, body, image.
  static Future<http.Response> sendNotification({
    required String cloudMessagingServerKey,
    required String title,
    required List<String> fcmTokens,
    String? body,
    String? imageUrl,
    Map? payload,
    Map? additionalHeaders,
    Map? notificationMeta,
  }) async {
    return await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$cloudMessagingServerKey',
        ...?additionalHeaders,
      },
      body: jsonEncode({
        if (fcmTokens.length == 1)
          "to": fcmTokens.first
        else
          "registration_ids": fcmTokens,
        "notification": {
          "title": title,
          "body": body,
          "image": imageUrl,
          ...?notificationMeta,
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          ...?payload,
        },
      }),
    );
  }

  @override
  // ignore: library_private_types_in_public_api
  _FirebaseNotificationsHandlerState createState() =>
      _FirebaseNotificationsHandlerState();
}

class _FirebaseNotificationsHandlerState
    extends State<FirebaseNotificationsHandler> {
  @override
  void initState() {
    () async {
      final token = await PushNotificationService.initialize(
        vapidKey: widget.vapidKey,
        enableLogs: widget.enableLogs,
        onTap: widget.onTap,
        navigatorKey: widget.defaultNavigatorKey,
        customSound: widget.customSound,
        handleInitialMessage: widget.handleInitialMessage,
        channelId: widget.channelId,
        channelName: widget.channelName,
        channelDescription: widget.channelDescription,
        groupKey: widget.groupKey,
        onOpenNotificationArrive: widget.onOpenNotificationArrive,
        notificationIdCallback: widget.notificationIdCallback,
      );

      if (!mounted) return;

      final navKey =
          widget.defaultNavigatorKey ?? PushNotificationService.navigatorKey;

      widget.onFCMTokenInitialize?.call(
        navKey.currentContext ?? context,
        token,
      );

      PushNotificationService.onTokenRefresh.listen((token) {
        widget.onFCMTokenUpdate?.call(
          navKey.currentContext ?? context,
          token,
        );
      });
    }();

    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
