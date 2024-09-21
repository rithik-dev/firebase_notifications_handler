import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications_handler/src/utils/types.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// TODO: update docs to mention about the default fields

class IosNotificationsConfig {
  static String? defaultSound;
  static String? defaultSubtitle;
  static String? defaultImageUrl;
  static int? defaultBadgeNumber;
  static String? defaultCategoryIdentifier;
  static String? defaultThreadIdentifier;
  static InterruptionLevel? defaultInterruptionLevel;
  static bool defaultPresentSound = true;
  static bool defaultPresentAlert = true;
  static bool defaultPresentBadge = true;
  static bool defaultHideThumbnail = false;
  static DarwinNotificationAttachmentThumbnailClippingRect? defaultThumbnailClippingRectGetter;

  IosNotificationsConfig({
    NullableStringGetter? soundGetter,
    NullableStringGetter? subtitleGetter,
    NullableStringGetter? imageUrlGetter,
    NullableIntGetter? badgeNumberGetter,
    NullableStringGetter? categoryIdentifierGetter,
    NullableStringGetter? threadIdentifierGetter,
    IosInterruptionLevelGetter? interruptionLevelGetter,
    BoolGetter? presentSoundGetter,
    BoolGetter? presentAlertGetter,
    BoolGetter? presentBadgeGetter,
    BoolGetter? hideThumbnailGetter,
    IosNotificationAttachmentClippingRectGetter? thumbnailClippingRectGetter,
  }) {
    final soundGetterRef = soundGetter ?? (msg) => msg.notification?.apple?.sound?.name ?? defaultSound;

    this.soundGetter = (msg) {
      final sound = soundGetterRef(msg);

      if (sound != null) {
        assert(
          sound.contains('.'),
          'The sound name must contain the extension',
        );
      }

      return sound;
    };

    this.subtitleGetter = subtitleGetter ?? (msg) => msg.notification?.apple?.subtitle ?? defaultSubtitle;
    this.imageUrlGetter = imageUrlGetter ?? (msg) => msg.notification?.apple?.imageUrl ?? defaultImageUrl;
    this.badgeNumberGetter = badgeNumberGetter ?? (_) => defaultBadgeNumber;
    this.categoryIdentifierGetter = categoryIdentifierGetter ?? (_) => defaultCategoryIdentifier;
    this.threadIdentifierGetter = threadIdentifierGetter ?? (_) => defaultThreadIdentifier;
    this.interruptionLevelGetter = interruptionLevelGetter ?? (_) => defaultInterruptionLevel;
    this.hideThumbnailGetter = hideThumbnailGetter ?? (_) => defaultHideThumbnail;
    this.thumbnailClippingRectGetter =
        thumbnailClippingRectGetter ?? (_) => defaultThumbnailClippingRectGetter;
    this.presentSoundGetter = presentSoundGetter ?? (_) => defaultPresentSound;
    this.presentAlertGetter = presentAlertGetter ?? (_) => defaultPresentAlert;
    this.presentBadgeGetter = presentBadgeGetter ?? (_) => defaultPresentBadge;
  }

  /// {@template soundGetter}
  ///
  /// Specifies the name of the file to play for the notification.
  ///
  /// The [presentSoundGetter] callback should return true for this to work.
  /// If [presentSoundGetter] returns true, but this is not specified then the default
  /// sound is played.
  ///
  /// Add the audio file in Runner/Resources/___audio-file-here___
  ///
  /// Make sure to pass the file extension in the string here.
  /// Extension is required for audio files on iOS
  ///
  /// {@endtemplate}
  late NullableStringGetter soundGetter;

  /// {@template imageUrlGetter}
  ///
  /// Specifies the url of the image to display in the notification.
  ///
  /// {@endtemplate}
  late NullableStringGetter imageUrlGetter;

  /// {@template badgeNumberGetter}
  ///
  /// Specify the number to display as the app icon's badge when the
  /// notification arrives.
  ///
  /// Specify the number `0` to remove the current badge, if present. Greater
  /// than `0` to display a badge with that number.
  /// Specify `null` to leave the current badge unchanged.
  ///
  /// {@endtemplate}
  late NullableIntGetter badgeNumberGetter;

  /// {@template categoryIdentifierGetter}
  ///
  /// The identifier of the app-defined category object.
  ///
  /// This must refer to a [DarwinNotificationCategory] identifier configured
  /// via [InitializationSettings].
  ///
  /// On iOS, this is only applicable to iOS 10 or newer.
  /// On macOS, this is only applicable to macOS 10.14 or newer.
  ///
  /// {@endtemplate}
  late NullableStringGetter categoryIdentifierGetter;

  /// {@template threadIdentifierGetter}
  ///
  /// Specifies the thread identifier that can be used to group
  /// notifications together.
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this This property is only applicable to macOS 10.14 or newer.
  ///
  /// {@endtemplate}
  late NullableStringGetter threadIdentifierGetter;

  /// {@template interruptionLevelGetter}
  ///
  /// The interruption level that indicates the priority and
  /// delivery timing of a notification.
  ///
  /// This property is only applicable to iOS 15.0 and macOS 12.0 or newer.
  /// https://developer.apple.com/documentation/usernotifications/unnotificationcontent/3747256-interruptionlevel
  ///
  /// {@endtemplate}
  late IosInterruptionLevelGetter interruptionLevelGetter;

  /// {@template subtitleGetter}
  ///
  /// Specifies the secondary description.
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this This property is only applicable to macOS 10.14 or newer.
  ///
  /// {@endtemplate}
  late NullableStringGetter subtitleGetter;

  /// {@template presentSoundGetter}
  ///
  /// Play a sound when the notification is triggered while app is in
  /// the foreground.
  ///
  /// This property is only applicable to iOS 10 or newer.
  ///
  /// {@endtemplate}
  late BoolGetter presentSoundGetter;

  /// {@template presentAlertGetter}
  ///
  /// Display an alert when the notification is triggered while app is
  /// in the foreground.
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this This property is only applicable to macOS 10.14 or newer.
  ///
  /// {@endtemplate}
  late BoolGetter presentAlertGetter;

  /// {@template presentBadgeGetter}
  ///
  /// Apply the badge value when the notification is triggered while app is in
  /// the foreground.
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this This property is only applicable to macOS 10.14 or newer.
  ///
  /// {@endtemplate}
  late BoolGetter presentBadgeGetter;

  /// {@template hideThumbnailGetter}
  ///
  /// Should the attachment be considered for the notification thumbnail?
  ///
  /// {@endtemplate}
  late BoolGetter hideThumbnailGetter;

  /// {@template thumbnailClippingRectGetter}
  ///
  /// The clipping rectangle for the thumbnail image.
  ///
  /// {@endtemplate}
  late IosNotificationAttachmentClippingRectGetter? thumbnailClippingRectGetter;

  DarwinNotificationDetails toSpecifics(
    RemoteMessage message, {
    List<DarwinNotificationAttachment>? attachments,
  }) {
    return DarwinNotificationDetails(
      attachments: attachments,
      sound: soundGetter(message),
      subtitle: subtitleGetter(message),
      badgeNumber: badgeNumberGetter(message),
      interruptionLevel: interruptionLevelGetter(message),
      threadIdentifier: threadIdentifierGetter(message),
      categoryIdentifier: categoryIdentifierGetter(message),
      presentSound: presentSoundGetter(message),
      presentAlert: presentAlertGetter(message),
      presentBadge: presentBadgeGetter(message),
    );
  }
}
