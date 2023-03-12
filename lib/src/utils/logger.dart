import 'dart:developer' as devtools show log;

import 'package:firebase_notifications_handler/firebase_notifications_handler.dart';

void log<T>({
  dynamic msg,
  dynamic error,
  String? id,
  StackTrace? stackTrace,
}) {
  if (!FirebaseNotificationsHandler.enableLogs) return;

  id = id ?? T.toString();

  final time = DateTime.now().toString();

  devtools.log(
    msg.toString(),
    error: error,
    name: '$id(${time.split(' ').last})',
    stackTrace: stackTrace,
  );
}
