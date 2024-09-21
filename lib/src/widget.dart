import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications_handler/src/enums/app_state.dart';
import 'package:firebase_notifications_handler/src/models/android_config.dart';
import 'package:firebase_notifications_handler/src/models/ios_config.dart';
import 'package:firebase_notifications_handler/src/models/notification_tap_details.dart';
import 'package:firebase_notifications_handler/src/utils/generics.dart';
import 'package:firebase_notifications_handler/src/utils/logger.dart';
import 'package:firebase_notifications_handler/src/utils/types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart';

// TODO: add docs to update about the variables that are applicable only for local notifs? i.e. when the app is open

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

  /// {@template androidConfig}
  ///
  /// Android specific configuration.
  ///
  /// {@endtemplate}
  final AndroidNotificationsConfig? androidConfig;

  /// {@template iosConfig}
  ///
  /// iOS specific configuration.
  ///
  /// {@endtemplate}
  final IosNotificationsConfig? iosConfig;

  /// {@template notificationIdGetter}
  ///
  /// Can be passed to modify the id used by the local
  /// notification when app is in foreground
  ///
  /// {@endtemplate}
  final NotificationIdGetter? notificationIdGetter;

  /// {@template shouldHandleNotification}
  ///
  /// Can be passed to determine whether the notification should be handled or not.
  ///
  /// If [messageModifier] is not null, then the message is first modified
  /// and then this callback is called, with the modified message.
  ///
  /// {@endtemplate}
  final BoolGetter? shouldHandleNotification;

  /// {@template messageModifier}
  ///
  /// Can be passed to modify the [RemoteMessage] before it is handled.
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
  /// See also:
  ///   * [onTap] parameter.
  ///
  /// {@endtemplate}
  final OnOpenNotificationArrive? onOpenNotificationArrive;

  /// {@template onTap}
  ///
  /// This callback provides an instance of [NotificationTapDetails]
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
    this.androidConfig,
    this.iosConfig,
    this.notificationIdGetter,
    this.handleInitialMessage = true,
    this.requestPermissionsOnInitialize = true,
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

  /// {@template getInitialMessage}
  ///
  /// Get the initial message if the app was opened from a notification tap
  /// when the app was terminated.
  ///
  /// {@endtemplate}
  static const getInitialMessage = _FirebaseNotificationsHandlerState.getInitialMessage;

  /// {@template notificationTapsSubscription}
  ///
  /// Stream of [NotificationTapDetails] which is triggered whenever a
  /// notification is tapped.
  ///
  /// {@endtemplate}
  static Stream<NotificationTapDetails> get notificationTapsSubscription =>
      _FirebaseNotificationsHandlerState._notificationTapsSubscription.stream;

  /// {@template notificationArrivesSubscription}
  ///
  /// Stream of [Map] which is triggered whenever a
  /// notification arrives, provided the app is in foreground.
  ///
  /// {@endtemplate}
  static Stream<Map<String, dynamic>> get notificationArrivesSubscription =>
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
  static final _notificationTapsSubscription = StreamController<NotificationTapDetails>.broadcast();
  static final _notificationArriveSubscription = StreamController<Map<String, dynamic>>.broadcast();
  static StreamSubscription<RemoteMessage>? _onMessageSubscription;
  static StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  static Future<void> _createAndroidNotificationChannel(
    AndroidNotificationChannel channel,
  ) async {
    await _flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> createAndroidNotificationChannel(
    AndroidNotificationChannel channel,
  ) async {
    if (!Platform.isAndroid) return;

    await _initializeLocalNotifications();

    await _createAndroidNotificationChannel(channel);
  }

  static Future<void> createAndroidNotificationChannels(
    List<AndroidNotificationChannel> channels,
  ) async {
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

  static Future<void> createAndroidNotificationChannelGroup(
    AndroidNotificationChannelGroup group,
  ) async {
    if (!Platform.isAndroid) return;

    await _initializeLocalNotifications();

    await _flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannelGroup(group);
  }

  static Future<void> deleteAndroidNotificationChannel(
    String channelId,
  ) async {
    if (!Platform.isAndroid) return;

    await _initializeLocalNotifications();

    await _flutterLocalNotificationsPlugin
        ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannel(channelId);
  }

  static Future<void> deleteAndroidNotificationChannelGroup(
    String groupId,
  ) async {
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
        await _flutterLocalNotificationsPlugin?.zonedSchedule(
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
      // FIXME: accept params...
      iOS: const DarwinInitializationSettings(),
    );

    try {
      await _flutterLocalNotificationsPlugin!.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          if (details.notificationResponseType != NotificationResponseType.selectedNotification) {
            return;
          }

          // TODO: add support for notification actions?

          final payload = details.payload == null
              ? <String, dynamic>{}
              : jsonDecode(details.payload!).cast<String, dynamic>();

          final tapDetails = NotificationTapDetails(
            appState: AppState.open,
            payload: payload,
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

  // TODO: add platform checks??

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

      final androidSpecifics = _androidConfig!.toSpecifics(
        message,
        styleInformation: androidStyleInformation,
        largeIcon: notificationIconRes == null ? null : FilePathAndroidBitmap(notificationIconRes!),
      );

      List<DarwinNotificationAttachment>? attachments;

      if (notificationImageRes != null) {
        attachments = [
          DarwinNotificationAttachment(
            notificationImageRes!,
            hideThumbnail: _iosConfig!.hideThumbnailGetter(message),
            thumbnailClippingRect: _iosConfig!.thumbnailClippingRectGetter?.call(message),
          ),
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
        payload: message.data,
        shouldForceInitNotifications: false,
        notificationDetails: notificationPlatformSpecifics,
      );

      _onOpenNotificationArrive?.call(message.data);
      _notificationArriveSubscription.add(message.data);
    }

    // if AppState is open, do not handle onTap here because it will
    // trigger as soon as notification arrives, instead handle in
    // initialize method in onSelectNotification callback.
    else {
      final tapDetails = NotificationTapDetails(
        appState: appState,
        payload: message.data,
      );

      _onTap?.call(tapDetails);
      _notificationTapsSubscription.add(tapDetails);
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
          return RemoteMessage(
            messageId: details?.notificationResponse?.id?.toString(),
            data: <String, dynamic>{
              if (details?.notificationResponse?.payload != null)
                ...jsonDecode(details!.notificationResponse!.payload!),
            },
          );
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

    _androidConfig = widget.androidConfig ?? AndroidNotificationsConfig();
    _iosConfig = widget.iosConfig ?? IosNotificationsConfig();

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

    _notificationIdGetter = widget.notificationIdGetter ?? (_) => DateTime.now().hashCode;
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
      // TODO: accept fn params?
      if (widget.requestPermissionsOnInitialize) await _fcm.requestPermission();

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
