import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications_handler/src/utils/types.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class IosNotificationsConfig {
  static String? defaultSound;
  static String? defaultSubtitle;
  static String? defaultImageUrl;
  static bool defaultPresentSound = true;
  static bool defaultPresentAlert = true;
  static bool defaultPresentBadge = true;

  IosNotificationsConfig({
    NullableStringGetter? soundGetter,
    NullableStringGetter? subtitleGetter,
    NullableStringGetter? imageUrlGetter,
    BoolGetter? presentSoundGetter,
    BoolGetter? presentAlertGetter,
    BoolGetter? presentBadgeGetter,
  }) {
    this.soundGetter = soundGetter ??
        (msg) => msg.notification?.apple?.sound?.name ?? defaultSound;
    this.subtitleGetter = subtitleGetter ??
        (msg) => msg.notification?.apple?.subtitle ?? defaultSubtitle;
    this.imageUrlGetter = imageUrlGetter ??
        (msg) => msg.notification?.apple?.imageUrl ?? defaultImageUrl;
    this.presentSoundGetter = presentSoundGetter ?? (_) => defaultPresentSound;
    this.presentAlertGetter = presentAlertGetter ?? (_) => defaultPresentAlert;
    this.presentBadgeGetter = presentBadgeGetter ?? (_) => defaultPresentBadge;
  }

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
  /// // FIXME: for ios, it is compulsory to add the audio file extension
  /// The string returned should not have an extension
  ///
  ///
  /// Add the default channelId in the AndroidManifest file in your project.
  ///
  ///   <meta-data
  ///      android:name="com.google.firebase.messaging.default_notification_channel_id"
  ///      android:value="ID" />
  ///
  /// Pass in the same "ID" in the [channelId] parameter.
  /// {@endtemplate}
  late NullableStringGetter soundGetter;
  late NullableStringGetter imageUrlGetter;
  late NullableStringGetter subtitleGetter;
  late BoolGetter presentSoundGetter;
  late BoolGetter presentAlertGetter;
  late BoolGetter presentBadgeGetter;

  DarwinNotificationDetails toSpecifics(RemoteMessage message) {
    return DarwinNotificationDetails(
      sound: soundGetter(message),
      subtitle: subtitleGetter(message),
      presentSound: presentSoundGetter(message),
      presentAlert: presentAlertGetter(message),
      presentBadge: presentBadgeGetter(message),
    );
  }
}
