import 'package:firebase_notifications_handler/src/app_state.dart';
import 'package:firebase_notifications_handler/src/service.dart';
import 'package:flutter/material.dart';

class FirebaseNotificationsHandler extends StatefulWidget {
  static String? get fcmToken => PushNotificationService.fcmToken;

  static bool get openedAppFromNotification =>
      PushNotificationService.openedAppFromNotification;

  final String? vapidKey;
  final bool enableLogs;
  final void Function(BuildContext, String?)? onFCMTokenInitialize;
  final void Function(BuildContext, String?)? onFCMTokenUpdate;
  final void Function(AppState, Map<String, dynamic> payload)? onTap;
  final Widget child;

  const FirebaseNotificationsHandler({
    Key? key,
    this.vapidKey,
    this.enableLogs = true,
    this.onTap,
    this.onFCMTokenInitialize,
    this.onFCMTokenUpdate,
    required this.child,
  }) : super(key: key);

  @override
  _FirebaseNotificationsHandlerState createState() =>
      _FirebaseNotificationsHandlerState();
}

class _FirebaseNotificationsHandlerState
    extends State<FirebaseNotificationsHandler> {
  @override
  void initState() {
    () async {
      final token = await PushNotificationService.initialize(
        vapidKey: this.widget.vapidKey,
        enableLogs: this.widget.enableLogs,
        onTap: this.widget.onTap,
      );
      this.widget.onFCMTokenInitialize?.call(context, token);

      PushNotificationService.onTokenRefresh.listen((token) {
        this.widget.onFCMTokenUpdate?.call(context, token);
      });
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => this.widget.child;
}
