import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications_handler/src/app_state.dart';
import 'package:firebase_notifications_handler/src/constants.dart';
import 'package:firebase_notifications_handler/src/service.dart';
import 'package:flutter/material.dart';

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

  /// Returns the default FCM token for this device.
  final String? vapidKey;

  /// {@template customSound}
  /// Pass in the name of the audio file as a string if you
  /// want a custom sound for the notification.
  ///
  /// Add the custom audio file in android/app/src/main/res/raw/____.mp3
  ///
  /// Add the default channelId in the AndroidManifest file in your project.
  ///
  ///   <meta-data
  ///      android:name="com.google.firebase.messaging.default_notification_channel_id"
  ///      android:value="ID" />
  ///
  /// Pass in the same ID in the [channelId] parameter.
  /// {@endtemplate}
  final String? customSound;

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
    Map<String, dynamic> payload,
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
  ///   notification was tapped.
  ///
  ///   * [payload] is the payload passed to the notification in the 'data'
  ///   parameter when creating the notification.
  /// {@endtemplate}
  final void Function(
    GlobalKey<NavigatorState> navigatorKey,
    AppState,
    Map<String, dynamic> payload,
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
    this.channelId = Constants.channelId,
    this.channelName = Constants.channelName,
    this.channelDescription = Constants.channelDescription,
    this.groupKey,
    required this.child,
  }) : super(key: key);

  @override
  _FirebaseNotificationsHandlerState createState() =>
      _FirebaseNotificationsHandlerState();
}

class _FirebaseNotificationsHandlerState
    extends State<FirebaseNotificationsHandler> {
  @override
  void initState() {
    () async {
      final token = await PushNotificationService.initialize(
        vapidKey: this.widget.vapidKey,
        enableLogs: this.widget.enableLogs,
        onTap: this.widget.onTap,
        navigatorKey: this.widget.defaultNavigatorKey,
        customSound: this.widget.customSound,
        channelId: this.widget.channelId,
        channelName: this.widget.channelName,
        channelDescription: this.widget.channelDescription,
        groupKey: this.widget.groupKey,
        onOpenNotificationArrive: this.widget.onOpenNotificationArrive,
        notificationIdCallback: this.widget.notificationIdCallback,
      );
      this.widget.onFCMTokenInitialize?.call(context, token);

      PushNotificationService.onTokenRefresh.listen((token) {
        this.widget.onFCMTokenUpdate?.call(context, token);
      });
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => this.widget.child;
}
