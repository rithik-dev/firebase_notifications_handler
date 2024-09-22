import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications_handler/src/enums/app_state.dart';
import 'package:firebase_notifications_handler/src/models/local_notifications_config.dart/android_config.dart';
import 'package:firebase_notifications_handler/src/models/local_notifications_config.dart/ios_config.dart';
import 'package:firebase_notifications_handler/src/models/local_notifications_config.dart/local_notifications_configuration.dart';
import 'package:firebase_notifications_handler/src/models/notification_info.dart';
import 'package:firebase_notifications_handler/src/utils/generics.dart';
import 'package:firebase_notifications_handler/src/utils/logger.dart';
import 'package:firebase_notifications_handler/src/utils/types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart';

/// Wrap this widget on the [MaterialApp] to enable receiving notifications.
class FirebaseNotificationsHandler extends StatefulWidget {
  /// {@template enableLogs}
  ///
  /// Whether to enable logs on certain events like new notification or
  /// fcmToken updates etc.
  ///
  /// {@endtemplate}
  static bool enableLogs = !kReleaseMode;

  /// {@template fcmToken}
  ///
  /// Firebase messaging token
  ///
  /// {@endtemplate}
  static String? get fcmToken => _FirebaseNotificationsHandlerState._fcmToken;

  /// {@template openedAppFromNotification}
  ///
  /// A boolean that can be used to see whether the app was initially
  /// opened from a notification.
  ///
  /// {@endtemplate}
  static final openedAppFromNotification = _FirebaseNotificationsHandlerState._openedAppFromNotification;

  /// {@template vapidKey}
  ///
  /// On web, a [vapidKey] is required to fetch the default FCM token for the device.
  /// The fcm token can be accessed from the [onFcmTokenInitialize] or [onFcmTokenUpdate] callbacks.
  ///
  /// {@endtemplate}
  final String? vapidKey;

  /// {@template handleInitialMessage}
  ///
  /// Whether to check if the application has been opened
  /// from a terminated state via a [RemoteMessage].
  ///
  /// If false, then [openedAppFromNotification] will be false, unless
  /// [FirebaseNotificationsHandler.getInitialMessage] is called, and the
  /// returned [RemoteMessage] is not null.
  ///
  /// If true, then checks for the initial message, and
  /// if it exists, [onTap] is called with [AppState.terminated].
  ///
  /// {@endtemplate}
  final bool handleInitialMessage;

  /// {@template requestPermissionsOnInitialize}
  ///
  /// Whether to request permissions on initialization.
  ///
  /// {@endtemplate}
  final bool requestPermissionsOnInitialize;

  /// {@template permissionGetter}
  ///
  /// A function that can be used to request permissions during initialization.
  ///
  /// If [requestPermissionsOnInitialize] is set to true, this function will be called instead of
  /// the default `fcm.requestPermissions`.
  ///
  /// - If a [permissionGetter] function is provided and is not null, `fcm.requestPermissions` will be
  /// bypassed.
  /// - If [permissionGetter] is null and [requestPermissionsOnInitialize] is true, the default
  /// `fcm.requestPermissions` will be called.
  ///
  /// {@endtemplate}
  final Future<void> Function(FirebaseMessaging)? permissionGetter;

  /// {@template localNotificationsConfiguration}
  ///
  /// Configuration for local notifications.
  ///
  /// {@endtemplate}
  final LocalNotificationsConfiguration localNotificationsConfiguration;

  /// {@template shouldHandleNotification}
  ///
  /// Can be passed to determine whether the local notification should be handled or not.
  ///
  /// If [messageModifier] is not null, then the message is first modified
  /// and then this callback is called, with the modified message.
  ///
  /// If [shouldHandleNotification] returns false, and it's a local notification i.e. notification
  /// was received if app is in foreground, then the notification will not be shown.
  ///
  /// If [shouldHandleNotification] returns false, and if the notification was received when the app was in background or terminated,
  /// then the notification will show up in the notification panel, but callbacks like [onTap] will not be called.
  ///
  /// {@endtemplate}
  final BoolGetter? shouldHandleNotification;

  /// {@template messageModifier}
  ///
  /// Can be passed to modify the [RemoteMessage] before it is handled.
  ///
  /// If [messageModifier] is null, then the message is not modified.
  ///
  /// If the app is in background or is terminated when the notification is received,
  /// the [RemoteMessage] is handled by Firebase directly, and any modifications
  /// made by [messageModifier] won't affect the notification shown in the device's notification panel.
  /// However, after tapping the notification, the [RemoteMessage] object will reflect the modified values, and
  /// callbacks like [onTap] will receive the modified [RemoteMessage].
  ///
  /// For example, if you receive a notification with title "A" when app is terminated, and the message
  /// modifier is set to modify title from "A" to "B" the notification title,
  /// then the notification in the device's notification will not modify the title, so it will show "A".
  /// However, if you tap the notification, callbacks like [onTap] will receive
  /// the modified [RemoteMessage] object with title "B".
  ///
  /// If the app is in foreground when the notification is received, the contents of the notification like the title and body will be modified,
  /// and the notification in the device notification panel will also be modified.
  ///
  /// Given that, this could ideally be used to modify the payload based on some condition specific to your app.
  ///
  /// {@endtemplate}
  final RemoteMessageGetter? messageModifier;

  /// {@template onFcmTokenInitialize}
  ///
  /// This callback is triggered when the [fcmToken] initializes.
  ///
  /// {@endtemplate}
  final FcmInitializeGetter? onFcmTokenInitialize;

  /// {@template onFcmTokenUpdate}
  ///
  /// This callback is triggered when the [fcmToken] updates.
  ///
  /// {@endtemplate}
  final FcmUpdateGetter? onFcmTokenUpdate;

  /// {@template onOpenNotificationArrive}
  ///
  /// This callback is triggered when the a new notification arrives
  /// when the app is open i.e. appState is [AppState.open].
  ///
  /// When the notification is tapped on, [onTap] is called.
  ///
  /// This callback provides an instance of [NotificationInfo]
  /// which provides essential information about the notification.
  ///
  /// See also:
  ///   * [onTap] parameter.
  ///
  /// {@endtemplate}
  final OnOpenNotificationArrive? onOpenNotificationArrive;

  /// {@template onTap}
  ///
  /// This callback provides an instance of [NotificationInfo]
  /// which provides essential information about the notification.
  ///
  /// {@endtemplate}
  final OnTapGetter? onTap;

  /// The child of the widget. Typically a [MaterialApp].
  final Widget child;

  const FirebaseNotificationsHandler({
    super.key,
    this.vapidKey,
    this.onTap,
    this.onFcmTokenInitialize,
    this.messageModifier,
    this.shouldHandleNotification,
    this.onFcmTokenUpdate,
    this.onOpenNotificationArrive,
    this.handleInitialMessage = true,
    this.requestPermissionsOnInitialize = true,
    this.permissionGetter,
    this.localNotificationsConfiguration = const LocalNotificationsConfiguration(),
    required this.child,
  });

  static void setOnTap(OnTapGetter? onTap) => _FirebaseNotificationsHandlerState._onTap = onTap;

  static void setOnOpenNotificationArrive(
    OnOpenNotificationArrive? onOpenNotificationArrive,
  ) =>
      _FirebaseNotificationsHandlerState._onOpenNotificationArrive = onOpenNotificationArrive;

  static void setShouldHandleNotification(
    BoolGetter? shouldHandleNotification,
  ) =>
      _FirebaseNotificationsHandlerState._shouldHandleNotification = shouldHandleNotification;

  static void setOnFcmTokenInitialize(
    FcmInitializeGetter? onFcmTokenInitialize,
  ) =>
      _FirebaseNotificationsHandlerState._onFCMTokenInitialize = onFcmTokenInitialize;

  static void setOnFcmTokenUpdate(
    FcmUpdateGetter? onFcmTokenUpdate,
  ) =>
      _FirebaseNotificationsHandlerState._onFCMTokenUpdate = onFcmTokenUpdate;

  static void setNotificationIdGetter(
    NotificationIdGetter? notificationIdGetter,
  ) =>
      _FirebaseNotificationsHandlerState._notificationIdGetter = notificationIdGetter;

  static void setMessageModifier(
    RemoteMessageGetter? messageModifier,
  ) =>
      _FirebaseNotificationsHandlerState._messageModifier = messageModifier;

  static void setAndroidConfig(
    AndroidNotificationsConfig? androidConfig,
  ) =>
      _FirebaseNotificationsHandlerState._androidConfig = androidConfig;

  static void setIosConfig(
    IosNotificationsConfig? iosConfig,
  ) =>
      _FirebaseNotificationsHandlerState._iosConfig = iosConfig;

  // ignore: library_private_types_in_public_api
  static GlobalKey<_FirebaseNotificationsHandlerState> get stateKeyGetter =>
      GlobalKey<_FirebaseNotificationsHandlerState>();

  static bool _initialMessageHandled = false;

  static FlutterLocalNotificationsPlugin? get flutterLocalNotificationsPlugin =>
      _FirebaseNotificationsHandlerState._flutterLocalNotificationsPlugin;

  /// {@template requestPermission}
  ///
  /// Request permission to show notifications.
  ///
  /// {@endtemplate}
  static final requestPermission = _FirebaseNotificationsHandlerState._fcm.requestPermission;

  /// {@template initializeFcmToken}
  ///
  /// Initialize the FCM token.
  ///
  /// {@endtemplate}
  static const initializeFcmToken = _FirebaseNotificationsHandlerState.initializeFcmToken;

  /// {@template sendLocalNotification}
  ///
  /// Send/schedule local notification.
  ///
  /// {@endtemplate}
  static const sendLocalNotification = _FirebaseNotificationsHandlerState.sendLocalNotification;

  /// Creates a notification channel.
  ///
  /// This method is only applicable to Android versions 8.0 or newer.
  static const createAndroidNotificationChannel =
      _FirebaseNotificationsHandlerState.createAndroidNotificationChannel;

  /// Deletes the notification channel and creates a new one.
  ///
  /// This method is only applicable to Android versions 8.0 or newer.
  static const deleteAndCreateAndroidNotificationChannel =
      _FirebaseNotificationsHandlerState.deleteAndCreateAndroidNotificationChannel;

  /// Creates the provided notification channels.
  ///
  /// This method is only applicable to Android versions 8.0 or newer.
  static const createAndroidNotificationChannels =
      _FirebaseNotificationsHandlerState.createAndroidNotificationChannels;

  /// Creates a notification channel group.
  ///
  /// This method is only applicable to Android versions 8.0 or newer.
  static const createAndroidNotificationChannelGroup =
      _FirebaseNotificationsHandlerState.createAndroidNotificationChannelGroup;

  /// Deletes the notification channel with the specified [channelId].
  ///
  /// This method is only applicable to Android versions 8.0 or newer.
  static const deleteAndroidNotificationChannel =
      _FirebaseNotificationsHandlerState.deleteAndroidNotificationChannel;

  /// Deletes all notification channels
  ///
  /// This method is only applicable to Android versions 8.0 or newer.
  static const deleteAllAndroidNotificationChannels =
      _FirebaseNotificationsHandlerState.deleteAllAndroidNotificationChannels;

  /// Deletes the notification channel group with the specified [groupId]
  /// as well as all of the channels belonging to the group.
  ///
  /// This method is only applicable to Android versions 8.0 or newer.
  static const deleteAndroidNotificationChannelGroup =
      _FirebaseNotificationsHandlerState.deleteAndroidNotificationChannelGroup;

  /// Returns the list of all notification channels.
  ///
  /// This method is only applicable on Android 8.0 or newer. On older versions,
  /// it will return an empty list.
  static const getAndroidNotificationChannels =
      _FirebaseNotificationsHandlerState.getAndroidNotificationChannels;

  /// Re-initializes local notifications.
  static const reInitializeLocalNotifications =
      _FirebaseNotificationsHandlerState.reInitializeLocalNotifications;

  /// {@template getInitialMessage}
  ///
  /// Get the initial message if the app was opened from a notification tap
  /// when the app was terminated.
  ///
  /// {@endtemplate}
  static const getInitialMessage = _FirebaseNotificationsHandlerState.getInitialMessage;

  /// {@template notificationTapsSubscription}
  ///
  /// Stream of [NotificationInfo] which is triggered whenever a
  /// notification is tapped.
  ///
  /// {@endtemplate}
  static Stream<NotificationInfo> get notificationTapsSubscription =>
      _FirebaseNotificationsHandlerState._notificationTapsSubscription.stream;

  /// {@template notificationArrivesSubscription}
  ///
  /// Stream of [NotificationInfo] which is triggered whenever a
  /// notification arrives, provided the app is in foreground.
  ///
  /// {@endtemplate}
  static Stream<NotificationInfo> get notificationArrivesSubscription =>
      _FirebaseNotificationsHandlerState._notificationArriveSubscription.stream;

  // removed as this API is deprecated
  // /// Trigger FCM notification.
  // ///
  // /// [cloudMessagingServerKey] : The server key from the cloud messaging console.
  // /// This key is required to trigger the notification.
  // ///
  // /// [title] : The notification's title.
  // ///
  // /// [body] : The notification's body.
  // ///
  // /// [imageUrl] : The notification's image URL.
  // ///
  // /// [fcmTokens] : List of the registered devices' tokens.
  // ///
  // /// [payload] : Notification payload, is provided in the [onTap] callback.
  // ///
  // /// [additionalHeaders] : Additional headers,
  // /// other than 'Content-Type' and 'Authorization'.
  // ///
  // /// [notificationMeta] : Additional content that you might want to pass
  // /// in the 'notification' attribute, apart from title, body, image.
  // static Future<http.Response> sendFcmNotification({
  //   required String cloudMessagingServerKey,
  //   required String title,
  //   required List<String> fcmTokens,
  //   String? body,
  //   String? imageUrl,
  //   Map<String, dynamic>? payload,
  //   Map<String, dynamic>? additionalHeaders,
  //   Map<String, dynamic>? notificationMeta,
  // }) async {
  //   return await http.post(
  //     Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'key=$cloudMessagingServerKey',
  //       ...?additionalHeaders,
  //     },
  //     body: jsonEncode({
  //       if (fcmTokens.length == 1) 'to': fcmTokens.first else 'registration_ids': fcmTokens,
  //       'notification': {
  //         'title': title,
  //         'body': body,
  //         'image': imageUrl,
  //         ...?notificationMeta,
  //       },
  //       'data': {
  //         'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //         ...?payload,
  //       },
  //     }),
  //   );
  // }

  @override
  State<FirebaseNotificationsHandler> createState() => _FirebaseNotificationsHandlerState();
}

class _FirebaseNotificationsHandlerState extends State<FirebaseNotificationsHandler> {
  /// Internal [FirebaseMessaging] instance
  static final _fcm = FirebaseMessaging.instance;

  /// {@macro fcmToken}
  static String? _fcmToken;

  static FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  static StreamSubscription<String>? _fcmTokenStreamSubscription;
  static final _notificationTapsSubscription = StreamController<NotificationInfo>.broadcast();
  static final _notificationArriveSubscription = StreamController<NotificationInfo>.broadcast();
  static StreamSubscription<RemoteMessage>? _onMessageSubscription;
  static StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  static Future<void> _createAndroidNotificationChannel(AndroidNotificationChannel channel) async {
    await _flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _deleteAndroidNotificationChannel(String channelId) async {
    await _flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannel(channelId);
  }

  static Future<void> createAndroidNotificationChannel(AndroidNotificationChannel channel) async {
    if (!Platform.isAndroid) return;

    await _initializeLocalNotifications();

    await _createAndroidNotificationChannel(channel);
  }

  static Future<void> deleteAndCreateAndroidNotificationChannel(AndroidNotificationChannel channel) async {
    if (!Platform.isAndroid) return;

    await _initializeLocalNotifications();

    await _deleteAndroidNotificationChannel(channel.id);
    await _createAndroidNotificationChannel(channel);
  }

  static Future<void> createAndroidNotificationChannels(List<AndroidNotificationChannel> channels) async {
    if (!Platform.isAndroid) return;

    await _initializeLocalNotifications();

    final currChannels = await getAndroidNotificationChannels();

    final currChannelIds = currChannels?.map((e) => e.id).toSet() ?? {};

    final futures = channels
        .where((channel) => !currChannelIds.contains(channel.id))
        .map((channel) => _createAndroidNotificationChannel(channel))
        .toList();

    await Future.wait(futures);
  }

  static Future<void> createAndroidNotificationChannelGroup(AndroidNotificationChannelGroup group) async {
    if (!Platform.isAndroid) return;

    await _initializeLocalNotifications();

    await _flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannelGroup(group);
  }

  static Future<void> deleteAndroidNotificationChannel(String channelId) async {
    if (!Platform.isAndroid) return;

    await _initializeLocalNotifications();

    await _deleteAndroidNotificationChannel(channelId);
  }

  static Future<void> deleteAllAndroidNotificationChannels() async {
    if (!Platform.isAndroid) return;

    await _initializeLocalNotifications();

    final currChannels = await getAndroidNotificationChannels();
    final currChannelIds = currChannels?.map((e) => e.id).toSet() ?? {};

    final futures = currChannelIds.map(_deleteAndroidNotificationChannel);
    await Future.wait(futures);
  }

  static Future<void> deleteAndroidNotificationChannelGroup(String groupId) async {
    if (!Platform.isAndroid) return;

    await _initializeLocalNotifications();

    await _flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannelGroup(groupId);
  }

  static Future<List<AndroidNotificationChannel>?> getAndroidNotificationChannels() async {
    if (!Platform.isAndroid) return null;

    await _initializeLocalNotifications();

    return await _flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.getNotificationChannels();
  }

  static Future<void> reInitializeLocalNotifications() async {
    await _initializeLocalNotifications(forceInit: true);
  }

  static Future<void> sendLocalNotification(
    int id, {
    required NotificationDetails notificationDetails,
    String? title,
    String? body,
    Map<String, dynamic>? payload,
    TZDateTime? scheduledDateTime,
    bool shouldForceInitNotifications = false,
    UILocalNotificationDateInterpretation? uiLocalNotificationDateInterpretation,
    AndroidScheduleMode? androidScheduleMode,
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

      try {
        await _flutterLocalNotificationsPlugin!.zonedSchedule(
          id,
          title,
          body,
          scheduledDateTime,
          notificationDetails,
          payload: payloadStr,
          androidScheduleMode: androidScheduleMode,
          matchDateTimeComponents: matchDateTimeComponents,
          uiLocalNotificationDateInterpretation: uiLocalNotificationDateInterpretation!,
        );
      } catch (e, s) {
        log<FirebaseNotificationsHandler>(error: e, stackTrace: s);
        rethrow;
      }
    }
  }

  static Future<String?> initializeFcmToken({String? vapidKey}) async {
    final isInitialized = _fcmToken != null;

    try {
      _fcmToken ??= await _fcm.getToken(vapidKey: vapidKey);
    } catch (e, s) {
      log<FirebaseNotificationsHandler>(error: e, stackTrace: s);
      rethrow;
    }

    if (!isInitialized) {
      _onFCMTokenInitialize?.call(_fcmToken);
      if (FirebaseNotificationsHandler.enableLogs) {
        log<FirebaseNotificationsHandler>(
          msg: 'FCM Token Initialized: $_fcmToken',
        );
      }
    }

    _fcmTokenStreamSubscription = _fcm.onTokenRefresh.listen((token) {
      if (_fcmToken == token) return;

      _fcmToken = token;
      _onFCMTokenUpdate?.call(token);
      if (FirebaseNotificationsHandler.enableLogs) {
        log<FirebaseNotificationsHandler>(
          msg: 'FCM Token Updated: $_fcmToken',
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
      iOS: DarwinInitializationSettings(
        defaultPresentAlert: IosNotificationsConfig.defaultPresentAlert,
        defaultPresentBadge: IosNotificationsConfig.defaultPresentBadge,
        defaultPresentSound: IosNotificationsConfig.defaultPresentSound,
        defaultPresentBanner: IosNotificationsConfig.defaultPresentBanner,
        defaultPresentList: IosNotificationsConfig.defaultPresentList,
        requestAlertPermission: IosNotificationsConfig.requestAlertPermission,
        requestBadgePermission: IosNotificationsConfig.requestBadgePermission,
        requestSoundPermission: IosNotificationsConfig.requestSoundPermission,
        requestProvisionalPermission: IosNotificationsConfig.requestProvisionalPermission,
        requestCriticalPermission: IosNotificationsConfig.requestCriticalPermission,
        // TODO: test this callback
        // onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) {},
        // TODO: add support for categories
        // notificationCategories: [],
      ),
    );

    try {
      await _flutterLocalNotificationsPlugin!.initialize(
        initializationSettings,
        // TODO: onDidReceiveBackgroundNotificationResponse
        // onDidReceiveBackgroundNotificationResponse: ,
        onDidReceiveNotificationResponse: (details) {
          if (details.notificationResponseType != NotificationResponseType.selectedNotification) {
            return;
          }

          // TODO: add support for notification actions?

          final tapDetails = NotificationInfo(
            appState: AppState.open,
            firebaseMessage: RemoteMessage.fromMap(jsonDecode(details.payload!)),
          );

          _onTap?.call(tapDetails);
          _notificationTapsSubscription.add(tapDetails);
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

    if (_messageModifier != null) {
      message = _messageModifier!(message);
    }

    bool shouldIgnoreNotification = false;

    if (_shouldHandleNotification != null && !_shouldHandleNotification!(message)) {
      shouldIgnoreNotification = true;
    }

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

    if (shouldIgnoreNotification) return;

    final notifInfo = NotificationInfo(
      appState: appState,
      firebaseMessage: message,
    );

    if (appState == AppState.open) {
      StyleInformation? androidStyleInformation;

      final notificationId = _notificationIdGetter!(message);

      String? notificationImageRes;
      String? notificationIconRes;

      Future<void> initNotificationImageRes() async {
        String? imageUrl;

        if (!kIsWeb) {
          if (Platform.isAndroid) {
            imageUrl = _androidConfig!.imageUrlGetter(message);
          } else if (Platform.isIOS) {
            imageUrl = _iosConfig!.imageUrlGetter(message);
          }
        }

        if (imageUrl == null) return;

        notificationImageRes = await downloadImage(
          url: imageUrl,
          fileName: '_image__${notificationId}_.png',
        );
      }

      Future<void> initNotificationIconRes() async {
        final iconUrl = _androidConfig!.smallIconUrlGetter(message);

        if (iconUrl == null) return;

        notificationIconRes = await downloadImage(
          url: iconUrl,
          fileName: '_icon__${notificationId}_.png',
        );
      }

      await Future.wait([
        initNotificationImageRes(),
        initNotificationIconRes(),
      ]);

      notificationIconRes ??= notificationImageRes;

      if (notificationImageRes != null) {
        androidStyleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(notificationImageRes!),
          largeIcon: notificationIconRes == null ? null : FilePathAndroidBitmap(notificationIconRes!),
          hideExpandedLargeIcon: _androidConfig!.hideExpandedLargeIconGetter(message),
        );
      } else if (message.notification?.body != null) {
        androidStyleInformation = BigTextStyleInformation(message.notification!.body!);
      }

      final largeIcon = notificationIconRes == null ? null : FilePathAndroidBitmap(notificationIconRes!);

      final androidSpecifics = _androidConfig!.toSpecifics(
        message,
        largeIcon: largeIcon,
        styleInformation: androidStyleInformation,
      );

      List<DarwinNotificationAttachment>? attachments;

      if (notificationImageRes != null) {
        attachments = [
          DarwinNotificationAttachment(
            notificationImageRes!,
            hideThumbnail: _iosConfig!.hideThumbnailGetter(message),
            thumbnailClippingRect: _iosConfig!.thumbnailClippingRectGetter?.call(message),
          ),
          // TODO: add support for multiple attachments
        ];
      }

      final iOsSpecifics = _iosConfig!.toSpecifics(
        message,
        attachments: attachments,
      );

      final notificationPlatformSpecifics = NotificationDetails(
        android: androidSpecifics,
        iOS: iOsSpecifics,
      );

      final currAndroidAppIcon = _androidConfig!.appIconGetter(message);

      await _initializeLocalNotifications(
        forceInit: currAndroidAppIcon != AndroidNotificationsConfig.defaultAppIcon,
        androidNotificationIcon: currAndroidAppIcon,
      );

      await sendLocalNotification(
        notificationId,
        title: message.notification?.title,
        body: message.notification?.body,
        payload: message.toMap(),
        shouldForceInitNotifications: false,
        notificationDetails: notificationPlatformSpecifics,
      );

      _onOpenNotificationArrive?.call(notifInfo);
      _notificationArriveSubscription.add(notifInfo);
    }

    // if AppState is open, do not handle onTap here because it will
    // trigger as soon as notification arrives, instead handle in
    // initialize method in onSelectNotification callback.
    else {
      _onTap?.call(notifInfo);
      _notificationTapsSubscription.add(notifInfo);
    }
  }

  static Future<RemoteMessage?> getInitialMessage({
    bool runMessageModifier = true,
    bool checkShouldHandleNotification = true,
    bool updateOpenedAppFromNotification = true,
  }) async {
    if (FirebaseNotificationsHandler._initialMessageHandled) return null;

    FirebaseNotificationsHandler._initialMessageHandled = true;

    Future<RemoteMessage?> handleFcmInitialMsg() async {
      final bgMessage = await _fcm.getInitialMessage();
      if (bgMessage != null) {
        if (updateOpenedAppFromNotification) _openedAppFromNotification = true;
        return bgMessage;
      }

      return null;
    }

    Future<RemoteMessage?> handleLocalInitialMsg() async {
      await _initializeLocalNotifications();

      final details = await _flutterLocalNotificationsPlugin?.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp ?? false) {
        if (updateOpenedAppFromNotification) _openedAppFromNotification = true;

        if (details?.notificationResponse?.notificationResponseType ==
            NotificationResponseType.selectedNotification) {
          return RemoteMessage.fromMap(jsonDecode(details!.notificationResponse!.payload!));
        }
      }

      return null;
    }

    final res = await Future.wait([
      handleFcmInitialMsg(),
      handleLocalInitialMsg(),
    ]);

    RemoteMessage? initialMessage;
    initialMessage = res.firstWhere((e) => e != null, orElse: () => null);

    if (initialMessage != null) {
      if (runMessageModifier && _messageModifier != null) {
        initialMessage = _messageModifier!(initialMessage);
      }

      if (checkShouldHandleNotification &&
          _shouldHandleNotification != null &&
          !_shouldHandleNotification!(initialMessage)) {
        log<FirebaseNotificationsHandler>(
          msg: 'Initial message ignored because shouldHandleNotification returned false',
        );

        return null;
      }
    }

    return initialMessage;
  }

  static final _handledNotifications = <String>{};

  static bool _openedAppFromNotification = false;

  static AndroidNotificationsConfig? _androidConfig;
  static IosNotificationsConfig? _iosConfig;

  static BoolGetter? _shouldHandleNotification;

  static NotificationIdGetter? _notificationIdGetter;

  static OnTapGetter? _onTap;
  static RemoteMessageGetter? _messageModifier;
  static FcmInitializeGetter? _onFCMTokenInitialize;
  static FcmUpdateGetter? _onFCMTokenUpdate;

  static OnOpenNotificationArrive? _onOpenNotificationArrive;

  void _initVariables() {
    _onFCMTokenInitialize = widget.onFcmTokenInitialize;
    _onFCMTokenUpdate = widget.onFcmTokenUpdate;

    _androidConfig = widget.localNotificationsConfiguration.androidConfig ?? AndroidNotificationsConfig();
    _iosConfig = widget.localNotificationsConfiguration.iosConfig ?? IosNotificationsConfig();

    _onTap = widget.onTap;
    _onOpenNotificationArrive = widget.onOpenNotificationArrive;

    _messageModifier = widget.messageModifier == null
        ? null
        : (msg) {
            final newMessage = widget.messageModifier!(msg);

            log<FirebaseNotificationsHandler>(
              msg: 'Message modified: $newMessage',
            );

            return newMessage;
          };

    _shouldHandleNotification = widget.shouldHandleNotification;

    _notificationIdGetter =
        widget.localNotificationsConfiguration.notificationIdGetter ?? (_) => DateTime.now().hashCode;
  }

  void _deactivate() {
    _fcmToken = null;

    _onFCMTokenInitialize = null;
    _onFCMTokenUpdate = null;
    _androidConfig = null;
    _iosConfig = null;
    _onTap = null;
    _onOpenNotificationArrive = null;
    _messageModifier = null;
    _shouldHandleNotification = null;
    _notificationIdGetter = null;

    _fcmTokenStreamSubscription?.cancel();
    _fcmTokenStreamSubscription = null;

    _onMessageSubscription?.cancel();
    _onMessageSubscription = null;

    _onMessageOpenedAppSubscription?.cancel();
    _onMessageOpenedAppSubscription = null;

    _handledNotifications.clear();

    _flutterLocalNotificationsPlugin = null;
  }

  @override
  void initState() {
    _initVariables();

    /// _handledNotifications used to prevent
    /// multiple calls to the same notification.
    void onMessageListener(RemoteMessage msg) {
      if (msg.messageId == null) return;

      if (_handledNotifications.contains(msg.messageId)) return;

      _handledNotifications.add(msg.messageId!);

      _onMessage(msg);
    }

    /// Registering the listeners
    _onMessageSubscription = FirebaseMessaging.onMessage.listen(onMessageListener);
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    (() async {
      if (widget.requestPermissionsOnInitialize) {
        await (widget.permissionGetter?.call(_fcm) ?? _fcm.requestPermission());
      }

      try {
        _fcmToken = await initializeFcmToken(vapidKey: widget.vapidKey);
      } catch (e, s) {
        log<FirebaseNotificationsHandler>(error: e, stackTrace: s);
      }

      if (widget.handleInitialMessage) {
        final initialMessage = await getInitialMessage();

        if (initialMessage != null) {
          _onBackgroundMessage(initialMessage);
        }
      } else {
        await _initializeLocalNotifications();
      }
    })();

    super.initState();
  }

  @override
  void deactivate() {
    _deactivate();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
