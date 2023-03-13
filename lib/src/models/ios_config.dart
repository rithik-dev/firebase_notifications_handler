import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications_handler/src/utils/types.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class IosNotificationsConfig {
  static String? _defaultSound;

  static String? get defaultSound => _defaultSound;

  static set defaultSound(String? value) {
    if (value != null) {
      assert(
        value.contains('.'),
        'The sound name must contain the extension',
      );
    }

    _defaultSound = value;
  }

  static String? defaultSubtitle;
  static String? defaultImageUrl;
  static bool defaultPresentSound = true;
  static bool defaultPresentAlert = true;
  static bool defaultPresentBadge = true;
  static bool defaultHideThumbnail = false;
  static DarwinNotificationAttachmentThumbnailClippingRect?
      defaultThumbnailClippingRectGetter;

  IosNotificationsConfig({
    NullableStringGetter? soundGetter,
    NullableStringGetter? subtitleGetter,
    NullableStringGetter? imageUrlGetter,
    BoolGetter? presentSoundGetter,
    BoolGetter? presentAlertGetter,
    BoolGetter? presentBadgeGetter,
    BoolGetter? hideThumbnailGetter,
    IosDarwinNotificationAttachmentThumbnailClippingRectGetter?
        thumbnailClippingRectGetter,
  }) {
    // TODO: add assert for filename extension
    this.soundGetter = soundGetter ??
        (msg) => msg.notification?.apple?.sound?.name ?? defaultSound;
    this.subtitleGetter = subtitleGetter ??
        (msg) => msg.notification?.apple?.subtitle ?? defaultSubtitle;
    this.imageUrlGetter = imageUrlGetter ??
        (msg) => msg.notification?.apple?.imageUrl ?? defaultImageUrl;
    this.hideThumbnailGetter =
        hideThumbnailGetter ?? (_) => defaultHideThumbnail;
    this.thumbnailClippingRectGetter = thumbnailClippingRectGetter ??
        (_) => defaultThumbnailClippingRectGetter;
    this.presentSoundGetter = presentSoundGetter ?? (_) => defaultPresentSound;
    this.presentAlertGetter = presentAlertGetter ?? (_) => defaultPresentAlert;
    this.presentBadgeGetter = presentBadgeGetter ?? (_) => defaultPresentBadge;
  }

  /// {@template customSound}
  /// Pass in the name of the audio file as a string if you
  /// want a custom sound for the notification.
  ///
  /// Add the audio file in Runner/Resources/___audio-file-here___
  ///
  /// Make sure to pass the file extension in the string here.
  /// Extension is required for audio files on iOS
  /// {@endtemplate}
  late NullableStringGetter soundGetter;
  late NullableStringGetter imageUrlGetter;
  late NullableStringGetter subtitleGetter;
  late BoolGetter presentSoundGetter;
  late BoolGetter presentAlertGetter;
  late BoolGetter presentBadgeGetter;

  /// Should the attachment be considered for the notification thumbnail?
  late BoolGetter hideThumbnailGetter;

  /// The clipping rectangle for the thumbnail image.
  late IosDarwinNotificationAttachmentThumbnailClippingRectGetter?
      thumbnailClippingRectGetter;

  DarwinNotificationDetails toSpecifics(
    RemoteMessage message, {
    List<DarwinNotificationAttachment>? attachments,
  }) {
    return DarwinNotificationDetails(
      attachments: attachments,
      sound: soundGetter(message),
      subtitle: subtitleGetter(message),
      presentSound: presentSoundGetter(message),
      presentAlert: presentAlertGetter(message),
      presentBadge: presentBadgeGetter(message),
    );
  }
}
