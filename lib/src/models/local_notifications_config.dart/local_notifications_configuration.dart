import 'package:firebase_notifications_handler/src/models/local_notifications_config.dart/android_config.dart';
import 'package:firebase_notifications_handler/src/models/local_notifications_config.dart/ios_config.dart';
import 'package:firebase_notifications_handler/src/utils/types.dart';

/// {@template localNotificationsConfiguration}
///
/// Configuration for local notifications.
///
/// {@endtemplate}
class LocalNotificationsConfiguration {
  const LocalNotificationsConfiguration({
    this.androidConfig,
    this.iosConfig,
    this.notificationIdGetter,
    this.titleGetter,
    this.bodyGetter,
  });

  /// {@template androidConfig}
  ///
  /// Android specific configuration for local notifications.
  ///
  /// The config has some default values set based on fcm notification params,
  /// but they can be overrided if needed.
  ///
  /// Local notifications are only used when a notification arrives and the app is in foreground.
  ///
  /// {@endtemplate}
  final AndroidNotificationsConfig? androidConfig;

  /// {@template iosConfig}
  ///
  /// iOS specific configuration for local notifications.
  ///
  /// The config has some default values set based on fcm notification params,
  /// but they can be overrided if needed.
  ///
  /// Local notifications are only used when a notification arrives and the app is in foreground.
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

  /// {@template titleGetter}
  ///
  /// Resolves the title shown on the foreground local notification.
  ///
  /// Defaults to `message.notification?.title`.
  ///
  /// Override this to support localized notifications. A message sent with
  /// `title_loc_key` carries no `title` — the key is meant to be resolved
  /// against the app's own string resources, which only the app can do:
  ///
  /// ```dart
  /// titleGetter: (msg) {
  ///   final key = msg.notification?.titleLocKey;
  ///   if (key == null) return msg.notification?.title;
  ///   return myLocalizations.lookup(key, msg.notification!.titleLocArgs);
  /// },
  /// ```
  ///
  /// {@endtemplate}
  final NullableStringGetter? titleGetter;

  /// {@template bodyGetter}
  ///
  /// Resolves the body shown on the foreground local notification.
  ///
  /// Defaults to `message.notification?.body`.
  ///
  /// See [titleGetter] for how to use this with `body_loc_key` to support
  /// localized notifications.
  ///
  /// {@endtemplate}
  final NullableStringGetter? bodyGetter;
}
