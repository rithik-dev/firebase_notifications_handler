import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications_handler/src/enums/app_state.dart';
import 'package:firebase_notifications_handler/src/models/android_config.dart';
import 'package:firebase_notifications_handler/src/models/ios_config.dart';
import 'package:firebase_notifications_handler/src/models/notification_on_tap_details.dart';
import 'package:firebase_notifications_handler/src/utils/generics.dart';
import 'package:firebase_notifications_handler/src/utils/logger.dart';
import 'package:firebase_notifications_handler/src/utils/types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart';

/// Wrap this widget on the [MaterialApp] to enable receiving notifications.
class FirebaseNotificationsHandler extends StatefulWidget {
  static bool enableLogs = true;

  /// {@template fcmToken}
  /// Firebase messaging token
  /// {@endtemplate}
  static String? get fcmToken => _FirebaseNotificationsHandlerState._fcmToken;

  // /// {@template navigatorKey}
  // /// Default [GlobalKey] navigator of type [NavigatorState].
  // ///
  // /// Can be passed to the material app and can be used in [onTap] callback
  // /// to get the current navigator state or the current context etc.
  // ///
  // /// If you already have a navigator key initiated in the app,
  // /// pass the same key in the [defaultNavigatorKey].
  // ///
  // /// See also:
  // ///   * [onTap] parameter.
  // ///   * [defaultNavigatorKey] parameter.
  // /// {@endtemplate}
  // static GlobalKey<NavigatorState>? get navigatorKey =>
  //     _FirebaseNotificationsHandlerState._navigatorKey;

  /// {@template openedAppFromNotification}
  /// A boolean that can be used to see whether the app was initially
  /// opened from a notification.
  /// {@endtemplate}
  static final openedAppFromNotification =
      _FirebaseNotificationsHandlerState._openedAppFromNotification;

  /// On web, a [vapidKey] is required to fetch the default FCM token for the device.
  /// The fcm token can be accessed from the [onFcmTokenInitialize] or [onFcmTokenUpdate] callbacks.
  final String? vapidKey;

  // add notes that payload is modified before, and then should handle notif is called etc..
  final BoolGetter? shouldHandleNotification;

  /// {@template handleInitialMessage}
  ///
  /// Whether to check if the application has been opened
  /// from a terminated state via a [RemoteMessage].
  ///
  /// If false, then [openedAppFromNotification] will always be false.
  ///
  /// If true, then checks for the initial message, and
  /// if it exists, [onTap] is called with [AppState.terminated].
  ///
  /// {@endtemplate}
  final bool handleInitialMessage;

  final bool requestPermissionsOnInit;

  final AndroidNotificationsConfig? androidConfig;
  final IosNotificationsConfig? iosConfig;

  // /// {@template enableLogs}
  // /// Whether to enable logs on certain events like new notification or
  // /// [fcmToken] updates etc.
  // /// {@endtemplate}
  // final bool enableLogs;

  // /// If you have a navigator key initialized in your app, then pass the
  // /// key here, this will be sent back in the onTap callback which can be
  // /// used to see the currentState of the navigator, current context etc.
  // ///
  // /// If yoy don't have a key already initialized, you can use
  // /// the getter [navigatorKey]. Don't forget to pass the key in the
  // /// [MaterialApp]'s navigatorKey parameter to register it for your app.
  // final GlobalKey<NavigatorState>? defaultNavigatorKey;

  // final BoolGetter? shouldForceReInitializeLocalNotifications;

  /// {@template notificationIdCallback}
  /// Can be passed to modify the id used by the local notification when app is in foreground
  /// {@endtemplate}
  final NotificationIdGetter? notificationIdGetter;

  // add notes that payload is modified before, and then should handle notif is called etc..
  final RemoteMessageGetter? messageModifier;

  /// {@template onFCMTokenInitialize}
  /// This callback is triggered when the [fcmToken] initializes.
  /// {@endtemplate}
  final FcmInitializeGetter? onFcmTokenInitialize;

  /// {@template onFCMTokenUpdate}
  /// This callback is triggered when the [fcmToken] updates.
  /// {@endtemplate}
  final FcmUpdateGetter? onFcmTokenUpdate;

  /// {@template onOpenNotificationArrive}
  /// This callback is triggered when the a new notification arrives
  /// when the app is open i.e. appState is [AppState.open].
  ///
  /// When the notification is tapped on, [onTap] is called.
  ///
  /// See also:
  ///   * [onTap] parameter.
  /// {@endtemplate}
  final OnOpenNotificationArrive? onOpenNotificationArrive;

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
  final OnTapGetter? onTap;

  /// The child of the widget. Typically a [MaterialApp].
  final Widget child;

  const FirebaseNotificationsHandler({
    Key? key,
    this.vapidKey,
    // this.enableLogs = _enableLogsDefault,
    this.onTap,
    this.onFcmTokenInitialize,
    this.messageModifier,
    this.shouldHandleNotification,
    // this.shouldForceReInitializeLocalNotifications,
    this.onFcmTokenUpdate,
    this.onOpenNotificationArrive,
    // this.defaultNavigatorKey,
    this.androidConfig,
    this.iosConfig,
    this.notificationIdGetter,
    this.handleInitialMessage = true,
    this.requestPermissionsOnInit = true,
    required this.child,
  }) : super(key: key);

  static final requestPermission =
      _FirebaseNotificationsHandlerState._fcm.requestPermission;
  static const initializeFCMToken =
      _FirebaseNotificationsHandlerState.initializeFCMToken;
  static final onFCMTokenRefresh =
      _FirebaseNotificationsHandlerState.onFCMTokenRefresh;
  static const sendLocalNotification =
      _FirebaseNotificationsHandlerState.sendLocalNotification;

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
  static Future<http.Response> sendFcmNotification({
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
  static Stream<String> get onFCMTokenRefresh => _fcm.onTokenRefresh;

  /// Internal [FirebaseMessaging] instance
  static final _fcm = FirebaseMessaging.instance;

  /// {@macro fcmToken}
  static String? _fcmToken;

  static FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  static Future<void> sendLocalNotification(
    int id, {
    required NotificationDetails notificationDetails,
    String? title,
    String? body,
    Map? payload,
    TZDateTime? scheduledDateTime,
    bool shouldForceInitNotifications = false,
    UILocalNotificationDateInterpretation?
        uiLocalNotificationDateInterpretation,
    bool? androidAllowWhileIdle,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    await _initializeLocalNotifications(
      forceInit: shouldForceInitNotifications,
    );

    final payloadStr = payload == null ? null : jsonEncode(payload);

    if (scheduledDateTime == null) {
      try {
        await _flutterLocalNotificationsPlugin!.show(
          id,
          title,
          body,
          notificationDetails,
          payload: payloadStr,
        );
      } catch (e, s) {
        log<FirebaseNotificationsHandler>(error: e, stackTrace: s);
        rethrow;
      }
    } else {
      assert(
        uiLocalNotificationDateInterpretation != null,
        'uiLocalNotificationDateInterpretation cannot be null when scheduledDateTime is not null',
      );

      assert(
        androidAllowWhileIdle != null,
        'androidAllowWhileIdle cannot be null when scheduledDateTime is not null',
      );

      try {
        await _flutterLocalNotificationsPlugin?.zonedSchedule(
          id,
          title,
          body,
          scheduledDateTime,
          notificationDetails,
          payload: payloadStr,
          matchDateTimeComponents: matchDateTimeComponents,
          uiLocalNotificationDateInterpretation:
              uiLocalNotificationDateInterpretation!,
          androidAllowWhileIdle: androidAllowWhileIdle!,
        );
      } catch (e, s) {
        log<FirebaseNotificationsHandler>(error: e, stackTrace: s);
        rethrow;
      }
    }
  }

  static Future<String?> initializeFCMToken({
    String? vapidKey,
    bool logsEnabled = true,
  }) async {
    final isInitialized = _fcmToken != null;

    try {
      _fcmToken ??= await _fcm.getToken(vapidKey: vapidKey);
    } catch (e, s) {
      log<FirebaseNotificationsHandler>(error: e, stackTrace: s);
      rethrow;
    }

    if (!isInitialized) {
      // FIXME
      // if (_navigatorKey?.currentContext != null) {
      _onFCMTokenInitialize?.call(
        /*_navigatorKey!.currentContext!, */
        _fcmToken,
      );
      // }
      if (logsEnabled) {
        log<FirebaseNotificationsHandler>(
          msg: "FCM Token Initialized: $_fcmToken",
        );
      }
    }

    _fcm.onTokenRefresh.listen((token) {
      if (_fcmToken == token) return;

      _fcmToken = token;
      // FIXME
      // if (_navigatorKey?.currentContext != null) {
      _onFCMTokenUpdate?.call(/*_navigatorKey!.currentContext!, */ token);
      // }
      if (logsEnabled) {
        log<FirebaseNotificationsHandler>(
          msg: "FCM Token Updated: $_fcmToken",
        );
      }
    });

    return _fcmToken;
  }

  /// [_onMessage] callback for the notification
  static Future<void> _onMessage(RemoteMessage message) =>
      _notificationHandler(message, appState: AppState.open);

  /// [_onBackgroundMessage] callback for the notification
  static Future<void> _onBackgroundMessage(RemoteMessage message) =>
      _notificationHandler(message, appState: AppState.terminated);

  /// [_onMessageOpenedApp] callback for the notification
  static Future<void> _onMessageOpenedApp(RemoteMessage message) =>
      _notificationHandler(message, appState: AppState.background);

  /// [_initializeLocalNotifications] function to initialize the local
  /// notifications to show a notification when the app is in foreground.
  static Future<void> _initializeLocalNotifications({
    String? androidNotificationIcon,
    bool forceInit = false,
  }) async {
    if (!forceInit && _flutterLocalNotificationsPlugin != null) return;

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings(
        androidNotificationIcon ?? AndroidNotificationsConfig.defaultAppIcon,
      ),
      iOS: const DarwinInitializationSettings(),
    );

    try {
      await _flutterLocalNotificationsPlugin!.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          if (details.notificationResponseType !=
              NotificationResponseType.selectedNotification) {
            return;
          }

          // TODO: add support for notification actions?

          final payload = details.payload;

          // FIXME
          // if (_navigatorKey != null) {
          _onTap?.call(
            // _navigatorKey!,
            NotificationOnTapDetails(
              appState: AppState.open,
              payload: payload == null ? {} : jsonDecode(payload),
            ),
          );
          // }
        },
      );
    } catch (e, s) {
      log<FirebaseNotificationsHandler>(error: e, stackTrace: s);
      rethrow;
    }
  }

  /// [_notificationHandler] implementation
  @pragma('vm:entry-point')
  static Future<void> _notificationHandler(
    RemoteMessage message, {
    required AppState appState,
  }) async {
    final receivedMsg = message;

    // FIXME: create android channel ??

    if (_messageModifier != null) {
      message = _messageModifier!(message);
    }

    bool shouldIgnoreNotification = false;

    if (_shouldHandleNotification != null &&
        !_shouldHandleNotification!(message)) {
      shouldIgnoreNotification = true;
    }

    // if (shouldLog) {
    String logMsg = '''\n
    ************************************************************************ 
      NEW NOTIFICATION   ${shouldIgnoreNotification ? '[IGNORED]' : ''}
    ************************************************************************ 
      Title: ${message.notification?.title}
      Body: ${message.notification?.body}
      App State: ${appState.name}''';

    if (_messageModifier == null) {
      logMsg += '\nMessage: ${receivedMsg.toMap()}';
    } else {
      logMsg += '\nMessage[MODIFIED]: ${message.toMap()}';
      logMsg += '\nMessage[RAW]: ${receivedMsg.toMap()}';
    }

    logMsg += '''
    ************************************************************************ 
''';

    log<FirebaseNotificationsHandler>(msg: logMsg);
    // }

    if (shouldIgnoreNotification) return;

    if (appState == AppState.open) {
      StyleInformation? styleInformation;

      final iconUrl = _androidConfig!.smallIconUrlGetter(message);

      String? imageUrl;
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          imageUrl = _androidConfig!.imageUrlGetter(message);
        } else if (Platform.isIOS) {
          imageUrl = _iosConfig!.imageUrlGetter(message);
        }
      }

      final notificationId = _notificationIdGetter!(message);

      if (appState == AppState.open) {
        final data = await Future.wait<String?>([
          if (imageUrl != null)
            downloadImage(
              url: imageUrl,
              fileName: '_image__${notificationId}_.png',
            )
          else
            Future.value(null),
          if (iconUrl != null)
            downloadImage(
              url: iconUrl,
              fileName: '_icon__${notificationId}_.png',
            )
          else
            Future.value(null),
        ]);

        final notificationImage = data[0];
        final notificationIcon = data[1];

        // TODO: explore other style infos
        // BigPictureStyleInformation();
        // BigTextStyleInformation();
        // MessagingStyleInformation();
        // InboxStyleInformation();
        // MediaStyleInformation();

        if (_androidConfig!.styleInformationGetter == null) {
          if (notificationImage != null) {
            styleInformation = BigPictureStyleInformation(
              FilePathAndroidBitmap(notificationImage),
              largeIcon: notificationIcon == null
                  ? null
                  : FilePathAndroidBitmap(notificationIcon),
              hideExpandedLargeIcon:
                  _androidConfig!.hideExpandedLargeIconGetter(message),
            );
          } else if (message.notification?.body != null) {
            // FIXME: test this.
            styleInformation =
                BigTextStyleInformation(message.notification!.body!);
          }
        } else {
          styleInformation =
              await _androidConfig!.styleInformationGetter!(message);
        }
      }

      final androidSpecifics = _androidConfig!.toSpecifics(
        message,
        styleInformation: styleInformation,
      );
      final iOsSpecifics = _iosConfig!.toSpecifics(message);

      final notificationPlatformSpecifics = NotificationDetails(
        android: androidSpecifics,
        iOS: iOsSpecifics,
      );

      final currAndroidAppIcon = _androidConfig!.appIconGetter(message);

      bool shouldForceInit =
          /*_shouldForceReInitLocalNotifications?.call(message) ?? */ false;

      if (!shouldForceInit) {
        shouldForceInit =
            currAndroidAppIcon != AndroidNotificationsConfig.defaultAppIcon;
      }

      await _initializeLocalNotifications(
        forceInit: shouldForceInit,
        androidNotificationIcon: currAndroidAppIcon,
      );

      await sendLocalNotification(
        notificationId,
        title: message.notification?.title,
        body: message.notification?.body,
        payload: message.data,
        shouldForceInitNotifications: false,
        notificationDetails: notificationPlatformSpecifics,
      );

      _onOpenNotificationArrive?.call(/*_navigatorKey!, */ message.data);
    }

    /// if AppState is open, do not handle onTap here because it will
    /// trigger as soon as notification arrives, instead handle in
    /// initialize method in onSelectNotification callback.
    else {
      // FIXME:
      // if (_navigatorKey != null) {
      _onTap?.call(
        /*_navigatorKey!, */
        NotificationOnTapDetails(appState: appState, payload: message.data),
      );
      // }
    }
  }

  static const _handledNotifications = <String>{};

  static bool _openedAppFromNotification = false;

  // static bool? _enableLogs;

  // static GlobalKey<NavigatorState>? _navigatorKey;
  static AndroidNotificationsConfig? _androidConfig;
  static IosNotificationsConfig? _iosConfig;

  static BoolGetter? _shouldHandleNotification;

  // static BoolGetter? _shouldForceReInitLocalNotifications;

  static NotificationIdGetter? _notificationIdGetter;

  static OnTapGetter? _onTap;
  static RemoteMessageGetter? _messageModifier;
  static FcmInitializeGetter? _onFCMTokenInitialize;
  static FcmUpdateGetter? _onFCMTokenUpdate;

  static OnOpenNotificationArrive? _onOpenNotificationArrive;

  void _initVariables() {
    // _enableLogs = widget.enableLogs;
    _onTap = widget.onTap;
    // _navigatorKey = widget.defaultNavigatorKey ?? GlobalKey<NavigatorState>();

    _shouldHandleNotification = widget.shouldHandleNotification;
    // _shouldForceReInitLocalNotifications =
    //     widget.shouldForceReInitializeLocalNotifications;

    _messageModifier = widget.messageModifier;

    _onFCMTokenInitialize = widget.onFcmTokenInitialize;
    _onFCMTokenUpdate = widget.onFcmTokenUpdate;

    _androidConfig = widget.androidConfig ?? AndroidNotificationsConfig();
    _iosConfig = widget.iosConfig ?? IosNotificationsConfig();

    _onOpenNotificationArrive = widget.onOpenNotificationArrive;

    _notificationIdGetter =
        widget.notificationIdGetter ?? (_) => DateTime.now().hashCode;
  }

  @override
  void initState() {
    _initVariables();

    () async {
      if (widget.requestPermissionsOnInit) await _fcm.requestPermission();

      _fcmToken = await initializeFCMToken(vapidKey: widget.vapidKey);

      if (widget.handleInitialMessage) {
        Future<void> handleFcmInitialMsg() async {
          final bgMessage = await _fcm.getInitialMessage();
          if (bgMessage != null) {
            _openedAppFromNotification = true;
            _onBackgroundMessage(bgMessage);
          }
        }

        Future<void> handleLocalInitialMsg() async {
          final details = await _flutterLocalNotificationsPlugin
              ?.getNotificationAppLaunchDetails();
          if (details?.didNotificationLaunchApp ?? false) {
            _openedAppFromNotification = true;

            if (details?.notificationResponse?.notificationResponseType ==
                NotificationResponseType.selectedNotification) {
              _onBackgroundMessage(
                RemoteMessage(
                  messageId: details?.notificationResponse?.id?.toString(),
                  data: {
                    if (details?.notificationResponse?.payload != null)
                      ...jsonDecode(details!.notificationResponse!.payload!),
                  },
                ),
              );
            }
          }
        }

        await Future.wait([
          handleFcmInitialMsg(),
          handleLocalInitialMsg(),
        ]);
      }

      /// _handledNotifications used to prevent
      /// multiple calls to the same notification.
      void onMessageListener(RemoteMessage msg) {
        // TODO: test this.
        if (msg.messageId == null) return;

        if (!_handledNotifications.contains(msg.messageId)) return;

        _handledNotifications.add(msg.messageId!);

        _onMessage(msg);
      }

      /// Registering the listeners
      FirebaseMessaging.onMessage.listen(onMessageListener);
      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    }();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) _initVariables();

    return widget.child;
  }
}
