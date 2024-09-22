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
}
