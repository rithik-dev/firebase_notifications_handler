import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications_handler/src/utils/types.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class IosNotificationsConfig {
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
    BoolGetter? presentBannerGetter,
    BoolGetter? presentListGetter,
    BoolGetter? hideThumbnailGetter,
    IosNotificationAttachmentClippingRectGetter? thumbnailClippingRectGetter,
  }) {
    final soundGetterRef = soundGetter ??
        (msg) => msg.notification?.apple?.sound?.name ?? defaultSound;

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

    this.subtitleGetter = subtitleGetter ??
        (msg) => msg.notification?.apple?.subtitle ?? defaultSubtitle;
    this.imageUrlGetter = imageUrlGetter ??
        (msg) => msg.notification?.apple?.imageUrl ?? defaultImageUrl;
    this.badgeNumberGetter = badgeNumberGetter ?? (_) => defaultBadgeNumber;
    this.categoryIdentifierGetter =
        categoryIdentifierGetter ?? (_) => defaultCategoryIdentifier;
    this.threadIdentifierGetter =
        threadIdentifierGetter ?? (_) => defaultThreadIdentifier;
    this.interruptionLevelGetter =
        interruptionLevelGetter ?? (_) => defaultInterruptionLevel;
    this.hideThumbnailGetter =
        hideThumbnailGetter ?? (_) => defaultHideThumbnail;
    this.thumbnailClippingRectGetter = thumbnailClippingRectGetter ??
        (_) => defaultThumbnailClippingRectGetter;
    this.presentSoundGetter = presentSoundGetter ?? (_) => defaultPresentSound;
    this.presentAlertGetter = presentAlertGetter ?? (_) => defaultPresentAlert;
    this.presentBadgeGetter = presentBadgeGetter ?? (_) => defaultPresentBadge;
    this.presentBannerGetter =
        presentBannerGetter ?? (_) => defaultPresentBanner;
    this.presentListGetter = presentListGetter ?? (_) => defaultPresentList;
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
  static String? defaultSound;

  /// {@template subtitleGetter}
  ///
  /// Specifies the secondary description.
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this This property is only applicable to macOS 10.14 or newer.
  ///
  /// {@endtemplate}
  static String? defaultSubtitle;

  /// {@template imageUrlGetter}
  ///
  /// Specifies the url of the image to display in the notification.
  ///
  /// {@endtemplate}
  static String? defaultImageUrl;

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
  static int? defaultBadgeNumber;

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
  static String? defaultCategoryIdentifier;

  /// {@template threadIdentifierGetter}
  ///
  /// Specifies the thread identifier that can be used to group
  /// notifications together.
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this This property is only applicable to macOS 10.14 or newer.
  ///
  /// {@endtemplate}
  static String? defaultThreadIdentifier;

  /// {@template interruptionLevelGetter}
  ///
  /// The interruption level that indicates the priority and
  /// delivery timing of a notification.
  ///
  /// This property is only applicable to iOS 15.0 and macOS 12.0 or newer.
  /// https://developer.apple.com/documentation/usernotifications/unnotificationcontent/3747256-interruptionlevel
  ///
  /// {@endtemplate}
  static InterruptionLevel? defaultInterruptionLevel;

  /// {@template presentSoundGetter}
  ///
  /// Play a sound when the notification is triggered while app is in
  /// the foreground.
  ///
  /// This property is only applicable to iOS 10 or newer.
  ///
  /// {@endtemplate}
  static bool defaultPresentSound = true;

  /// {@template presentAlertGetter}
  ///
  /// Display an alert when the notification is triggered while app is
  /// in the foreground.
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this This property is only applicable to macOS 10.14 or newer.
  ///
  /// {@endtemplate}
  static bool defaultPresentAlert = true;

  /// {@template presentBadgeGetter}
  ///
  /// Apply the badge value when the notification is triggered while app is in
  /// the foreground.
  ///
  /// On iOS, this property is only applicable to iOS 10 or newer.
  /// On macOS, this This property is only applicable to macOS 10.14 or newer.
  ///
  /// {@endtemplate}
  static bool defaultPresentBadge = true;

  /// {@template hideThumbnailGetter}
  ///
  /// Should the attachment be considered for the notification thumbnail?
  ///
  /// {@endtemplate}
  static bool defaultHideThumbnail = false;

  /// {@template presentListGetter}
  ///
  /// Configures the default setting on if the notification should be
  /// in the notification centre when notification is triggered while app is in
  /// the foreground.
  ///
  /// Corresponds to https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptions/3564813-list
  ///
  /// Default value is true.
  ///
  /// On iOS, this property is only applicable to iOS 14 or newer.
  /// On macOS, this property is only applicable to macOS 11 or newer.
  ///
  /// {@endtemplate}
  static bool defaultPresentList = true;

  /// {@template presentBannerGetter}
  ///
  /// Configures the default setting on if the notification should be
  /// presented as a banner when a notification is triggered while app is in
  /// the foreground.
  ///
  /// Corresponds to https://developer.apple.com/documentation/usernotifications/unnotificationpresentationoptions/3564812-banner
  ///
  /// Default value is true.
  ///
  /// On iOS, this property is only applicable to iOS 14 or newer.
  /// On macOS, this property is only applicable to macOS 11 or newer.
  ///
  /// {@endtemplate}
  static bool defaultPresentBanner = true;

  /// Request permission to display an alert.
  ///
  /// Default value is true.
  static bool requestAlertPermission = true;

  /// Request permission to play a sound.
  ///
  /// Default value is true.
  static bool requestSoundPermission = true;

  /// Request permission to badge app icon.
  ///
  /// Default value is true.
  static bool requestBadgePermission = true;

  /// Request permission to send provisional notification for iOS 12+
  ///
  /// Subject to specific approval from Apple: https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications#3544375
  ///
  /// Default value is false.
  ///
  /// On iOS, this property is only applicable to iOS 12 or newer.
  /// On macOS, this property is only applicable to macOS 10.14 or newer.
  static bool requestProvisionalPermission = false;

  /// Request permission to show critical notifications.
  ///
  /// Subject to specific approval from Apple:
  /// https://developer.apple.com/contact/request/notifications-critical-alerts-entitlement/
  ///
  /// Default value is 'false'.
  static bool requestCriticalPermission = false;

  /// {@template thumbnailClippingRectGetter}
  ///
  /// The clipping rectangle for the thumbnail image.
  ///
  /// {@endtemplate}
  static DarwinNotificationAttachmentThumbnailClippingRect?
      defaultThumbnailClippingRectGetter;

  /// {@macro soundGetter}
  late NullableStringGetter soundGetter;

  /// {@macro subtitleGetter}
  late NullableStringGetter subtitleGetter;

  /// {@macro imageUrlGetter}
  late NullableStringGetter imageUrlGetter;

  /// {@macro badgeNumberGetter}
  late NullableIntGetter badgeNumberGetter;

  /// {@macro categoryIdentifierGetter}
  late NullableStringGetter categoryIdentifierGetter;

  /// {@macro threadIdentifierGetter}
  late NullableStringGetter threadIdentifierGetter;

  /// {@macro interruptionLevelGetter}
  late IosInterruptionLevelGetter interruptionLevelGetter;

  /// {@macro presentSoundGetter}
  late BoolGetter presentSoundGetter;

  /// {@macro presentAlertGetter}
  late BoolGetter presentAlertGetter;

  /// {@macro presentBadgeGetter}
  late BoolGetter presentBadgeGetter;

  /// {@macro hideThumbnailGetter}
  late BoolGetter hideThumbnailGetter;

  /// {@macro presentListGetter}
  late BoolGetter presentListGetter;

  /// {@macro presentBannerGetter}
  late BoolGetter presentBannerGetter;

  /// {@macro thumbnailClippingRectGetter}
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
      presentBanner: presentBannerGetter(message),
      presentList: presentListGetter(message),
    );
  }
}
