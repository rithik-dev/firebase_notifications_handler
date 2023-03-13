import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications_handler/src/models/notification_tap_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef OnTapGetter = void Function(NotificationTapDetails details);

typedef OnOpenNotificationArrive = void Function(Map<String, dynamic> payload);

typedef FcmInitializeGetter = void Function(String?);
typedef FcmUpdateGetter = void Function(String);
typedef NotificationIdGetter = int Function(RemoteMessage);

typedef NullableIntGetter = int? Function(RemoteMessage);
typedef NullableStringGetter = String? Function(RemoteMessage);
typedef StringGetter = String Function(RemoteMessage);
typedef BoolGetter = bool Function(RemoteMessage);
typedef RemoteMessageGetter = RemoteMessage Function(RemoteMessage);
typedef NullableColorGetter = Color? Function(RemoteMessage);

typedef AndroidImportanceGetter = Importance Function(RemoteMessage);
typedef AndroidPriorityGetter = Priority Function(RemoteMessage);

typedef IosInterruptionLevelGetter = InterruptionLevel? Function(RemoteMessage);
typedef IosNotificationAttachmentClippingRectGetter
    = DarwinNotificationAttachmentThumbnailClippingRect? Function(
  RemoteMessage,
);
