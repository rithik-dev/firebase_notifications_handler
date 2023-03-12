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
  static StyleInformation? defaultStyleInformation;
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
    AndroidStyleInformationGetter? styleInformationGetter,
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
    this.styleInformationGetter =
        styleInformationGetter ?? (_) => defaultStyleInformation;
    this.imageUrlGetter = imageUrlGetter ??
        (msg) => msg.notification?.android?.imageUrl ?? defaultImageUrl;
    this.hideExpandedLargeIconGetter =
        hideExpandedLargeIconGetter ?? (_) => defaultHideExpandedLargeIcon;
    this.playSoundGetter = playSoundGetter ?? (_) => defaultPlaySound;
    this.enableLightsGetter = enableLightsGetter ?? (_) => defaultEnableLights;
    this.enableVibrationGetter =
        enableVibrationGetter ?? (_) => defaultEnableVibration;
  }

  /// If [message.notification?.android?.channelId] exists in the map,
  /// then it is used, if not then the default value is used, else the value
  /// passed will be used.
  ///
  /// The notification channel's id. Defaults to 'Notifications'.
  ///
  /// Required for Android 8.0 or newer.
  late StringGetter channelIdGetter;

  /// {@template channelName}
  /// The notification channel's name. Defaults to 'Notifications'.
  ///
  /// Required for Android 8.0 or newer.
  /// {@endtemplate}
  late StringGetter channelNameGetter;

  /// {@template channelDescription}
  /// The notification channel's description. Defaults to 'Notifications'.
  ///
  /// Required for Android 8.0 or newer.
  /// {@endtemplate}
  late StringGetter channelDescriptionGetter;

  late StringGetter appIconGetter;

  /// The importance of the notification.
  late AndroidImportanceGetter importanceGetter;

  /// The priority of the notification.
  late AndroidPriorityGetter priorityGetter;

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
  late NullableStringGetter imageUrlGetter;

  /// The sound to play for the notification.
  ///
  /// The [playSoundGetter] callback should return true for this to work.
  /// If [playSoundGetter] returns true, but this is not specified then the default
  /// sound is played.
  ///
  /// For Android 8.0 or newer, this is tied to the specified channel and cannot
  /// be changed after the channel has been created for the first time.
  late NullableStringGetter soundGetter;

  late AndroidStyleInformationGetter? styleInformationGetter;

  late NullableStringGetter smallIconUrlGetter;
  late NullableStringGetter iconGetter;
  late BoolGetter hideExpandedLargeIconGetter;

  /// Indicates if a sound should be played when the notification is displayed.
  ///
  /// For Android 8.0 or newer, this is tied to the specified channel and cannot
  /// be changed after the channel has been created for the first time.
  late BoolGetter playSoundGetter;

  /// Indicates if vibration should be enabled when the notification is
  /// displayed.
  ///
  /// For Android 8.0 or newer, this is tied to the specified channel and cannot
  /// be changed after the channel has been created for the first time.
  late BoolGetter enableVibrationGetter;

  /// Indicates if lights should be enabled when the notification is displayed.
  ///
  /// For Android 8.0 or newer, this is tied to the specified channel and cannot
  /// be changed after the channel has been created for the first time.
  late BoolGetter enableLightsGetter;

  /// {@template groupKey}
  /// Specifies the group that this notification belongs to.
  ///
  /// For Android 7.0 or newer.
  /// {@endtemplate}
  late NullableStringGetter groupKeyGetter;

  /// The notification tag.
  ///
  /// Showing notification with the same (tag, id) pair as a currently visible
  /// notification will replace the old notification with the new one, provided
  /// the old notification was one that was not one that was scheduled. In other
  /// words, the (tag, id) pair is only applicable for notifications that were
  /// requested to be shown immediately. This is because the Android
  /// AlarmManager APIs used for scheduling notifications only allow for using
  /// the id to uniquely identify alarms.
  late NullableStringGetter tagGetter;

  /// Specifies the color.
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
