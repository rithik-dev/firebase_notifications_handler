import 'dart:ui';

import 'package:firebase_notifications_handler/firebase_notifications_handler.dart';
import 'package:firebase_notifications_handler/src/utils/types.dart';

// TODO: update docs to mention about the default fields

class AndroidNotificationsConfig {
  static String defaultChannelId = 'Notifications';
  static String defaultChannelName = 'Notifications';
  static String defaultChannelDescription = 'Notifications';
  static String defaultAppIcon = '@mipmap/ic_launcher';
  static String? defaultSound;
  static Importance defaultImportance = Importance.defaultImportance;
  static Priority defaultPriority = Priority.defaultPriority;
  static String? defaultGroupKey;
  static String? defaultIcon;
  static String? defaultImageUrl;
  static String? defaultSmallIcon;
  static Color? defaultColor;
  static String? defaultTag;
  static bool defaultHideExpandedLargeIcon = false;
  static bool defaultPlaySound = true;
  static bool defaultEnableVibration = true;
  static bool defaultEnableLights = true;

  AndroidNotificationsConfig({
    StringGetter? channelIdGetter,
    StringGetter? channelNameGetter,
    StringGetter? channelDescriptionGetter,
    StringGetter? appIconGetter,
    AndroidImportanceGetter? importanceGetter,
    AndroidPriorityGetter? priorityGetter,
    NullableStringGetter? imageUrlGetter,
    NullableStringGetter? tagGetter,
    NullableStringGetter? soundGetter,
    NullableColorGetter? colorGetter,
    NullableStringGetter? groupKeyGetter,
    NullableStringGetter? iconGetter,
    NullableStringGetter? smallIconUrlGetter,
    BoolGetter? hideExpandedLargeIconGetter,
    BoolGetter? playSoundGetter,
    BoolGetter? enableLightsGetter,
    BoolGetter? enableVibrationGetter,
  }) {
    this.channelIdGetter = channelIdGetter ??
        (msg) => msg.notification?.android?.channelId ?? defaultChannelId;
    this.channelNameGetter = channelNameGetter ?? (_) => defaultChannelName;
    this.channelDescriptionGetter =
        channelDescriptionGetter ?? (_) => defaultChannelDescription;
    this.appIconGetter = appIconGetter ?? (_) => defaultAppIcon;
    this.colorGetter = colorGetter ?? (_) => defaultColor;
    this.groupKeyGetter = groupKeyGetter ?? (_) => defaultGroupKey;
    this.tagGetter =
        tagGetter ?? (msg) => msg.notification?.android?.tag ?? defaultTag;
    this.smallIconUrlGetter = smallIconUrlGetter ??
        (msg) => msg.notification?.android?.smallIcon ?? defaultSmallIcon;
    this.importanceGetter = importanceGetter ?? (_) => defaultImportance;
    this.priorityGetter = priorityGetter ?? (_) => defaultPriority;
    this.soundGetter = soundGetter ??
        (msg) => msg.notification?.android?.sound ?? defaultSound;
    this.iconGetter = iconGetter ?? (_) => defaultIcon;
    this.imageUrlGetter = imageUrlGetter ??
        (msg) => msg.notification?.android?.imageUrl ?? defaultImageUrl;
    this.hideExpandedLargeIconGetter =
        hideExpandedLargeIconGetter ?? (_) => defaultHideExpandedLargeIcon;
    this.playSoundGetter = playSoundGetter ?? (_) => defaultPlaySound;
    this.enableLightsGetter = enableLightsGetter ?? (_) => defaultEnableLights;
    this.enableVibrationGetter =
        enableVibrationGetter ?? (_) => defaultEnableVibration;
  }

  /// {@template channelIdGetter}
  ///
  /// If [message.notification?.android?.channelId] exists in the map,
  /// then it is used, if not then the default value is used, else the value
  /// passed will be used.
  ///
  /// The notification channel's id. Defaults to 'Notifications'.
  ///
  /// Required for Android 8.0 or newer.
  ///
  /// {@endtemplate}
  late StringGetter channelIdGetter;

  /// {@template channelNameGetter}
  ///
  /// The notification channel's name. Defaults to 'Notifications'.
  ///
  /// Required for Android 8.0 or newer.
  ///
  /// {@endtemplate}
  late StringGetter channelNameGetter;

  /// {@template channelDescriptionGetter}
  ///
  /// The notification channel's description. Defaults to 'Notifications'.
  ///
  /// Required for Android 8.0 or newer.
  ///
  /// {@endtemplate}
  late StringGetter channelDescriptionGetter;

  /// {@template appIconGetter}
  ///
  /// The app icon to display in the notification.
  ///
  /// Defaults to '@mipmap/ic_launcher'.
  ///
  /// {@endtemplate}
  late StringGetter appIconGetter;

  /// {@template importanceGetter}
  ///
  /// The importance of the notification.
  ///
  /// {@endtemplate}
  late AndroidImportanceGetter importanceGetter;

  /// {@template priorityGetter}
  ///
  /// The priority of the notification.
  ///
  /// {@endtemplate}
  late AndroidPriorityGetter priorityGetter;

  /// {@template imageUrlGetter}
  ///
  /// Specifies the url of the image to display in the notification.
  ///
  /// {@endtemplate}
  late NullableStringGetter imageUrlGetter;

  /// {@template soundGetter}
  ///
  /// The sound to play for the notification.
  ///
  /// Pass in the name of the audio file as a string if you
  /// want a custom sound for the notification.
  ///
  /// Android: Add the audio file in android/app/src/main/res/raw/___audio-file-here___
  ///
  /// The string may not have an extension.
  ///
  /// The [playSoundGetter] callback should return true for this to work.
  /// If [playSoundGetter] returns true, but this is not specified then the default
  /// sound is played.
  ///
  /// Add the default channelId in the AndroidManifest file in your project.
  ///
  ///   <meta-data
  ///      android:name="com.google.firebase.messaging.default_notification_channel_id"
  ///      android:value="ID" />
  ///
  /// Pass in the same "ID" in the [channelId] parameter.
  ///
  /// For Android 8.0 or newer, this is tied to the specified channel and cannot
  /// be changed after the channel has been created for the first time.
  ///
  /// {@endtemplate}
  late NullableStringGetter soundGetter;

  /// {@template smallIconUrlGetter}
  ///
  /// Specifies the url of the small icon to display in the notification.
  ///
  /// {@endtemplate}
  late NullableStringGetter smallIconUrlGetter;

  /// {@template iconGetter}
  ///
  // The icon that should be used when displaying the notification.
  ///
  /// {@endtemplate}
  late NullableStringGetter iconGetter;

  /// {@template hideExpandedLargeIconGetter}
  ///
  /// Hides the large icon when showing the expanded notification.
  ///
  /// {@endtemplate}
  late BoolGetter hideExpandedLargeIconGetter;

  /// {@template playSoundGetter}
  ///
  /// Indicates if a sound should be played when the notification is displayed.
  ///
  /// For Android 8.0 or newer, this is tied to the specified channel and cannot
  /// be changed after the channel has been created for the first time.
  ///
  /// {@endtemplate}
  late BoolGetter playSoundGetter;

  /// {@template enableVibrationGetter}
  ///
  /// Indicates if vibration should be enabled when the notification is
  /// displayed.
  ///
  /// For Android 8.0 or newer, this is tied to the specified channel and cannot
  /// be changed after the channel has been created for the first time.
  ///
  /// {@endtemplate}
  late BoolGetter enableVibrationGetter;

  /// {@template enableLightsGetter}
  ///
  /// Indicates if lights should be enabled when the notification is displayed.
  ///
  /// For Android 8.0 or newer, this is tied to the specified channel and cannot
  /// be changed after the channel has been created for the first time.
  ///
  /// {@endtemplate}
  late BoolGetter enableLightsGetter;

  /// {@template groupKeyGetter}
  ///
  /// Specifies the group that this notification belongs to.
  ///
  /// For Android 7.0 or newer.
  ///
  /// {@endtemplate}
  late NullableStringGetter groupKeyGetter;

  /// {@template tagGetter}
  ///
  /// The notification tag.
  ///
  /// Showing notification with the same (tag, id) pair as a currently visible
  /// notification will replace the old notification with the new one, provided
  /// the old notification was one that was not one that was scheduled. In other
  /// words, the (tag, id) pair is only applicable for notifications that were
  /// requested to be shown immediately. This is because the Android
  /// AlarmManager APIs used for scheduling notifications only allow for using
  /// the id to uniquely identify alarms.
  ///
  /// {@endtemplate}
  late NullableStringGetter tagGetter;

  /// {@template colorGetter}
  ///
  /// Specifies the color.
  ///
  /// {@endtemplate}
  late NullableColorGetter colorGetter;

  AndroidNotificationDetails toSpecifics(
    RemoteMessage message, {
    StyleInformation? styleInformation,
  }) {
    final androidSound = soundGetter(message);
    return AndroidNotificationDetails(
      channelIdGetter(message),
      channelNameGetter(message),
      channelDescription: channelDescriptionGetter(message),
      styleInformation: styleInformation,
      importance: importanceGetter(message),
      color: colorGetter(message),
      tag: tagGetter(message),
      priority: priorityGetter(message),
      groupKey: groupKeyGetter(message),
      sound: androidSound == null
          ? null
          : RawResourceAndroidNotificationSound(androidSound),
      icon: iconGetter(message),
      playSound: playSoundGetter(message),
      enableLights: enableLightsGetter(message),
      enableVibration: enableVibrationGetter(message),
    );
  }
}
