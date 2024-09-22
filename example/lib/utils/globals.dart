import 'package:flutter/material.dart';

class Globals {
  const Globals._();

  static ValueNotifier<String?> fcmTokenNotifier = ValueNotifier(null);

  static final navigatorKey = GlobalKey<NavigatorState>();

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
}
