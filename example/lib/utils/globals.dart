import 'package:flutter/material.dart';

class Globals {
  const Globals._();

  static String? fcmToken;

  static final navigatorKey = GlobalKey<NavigatorState>();

  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
}
