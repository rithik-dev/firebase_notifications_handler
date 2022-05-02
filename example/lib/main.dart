import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_notifications_handler/firebase_notifications_handler.dart';
import 'package:flutter/material.dart';
import 'package:notifications_handler_demo/firebase_options.dart';
import 'package:notifications_handler_demo/screens/splash_screen.dart';
import 'package:notifications_handler_demo/utils/app_theme.dart';
import 'package:notifications_handler_demo/utils/globals.dart';
import 'package:notifications_handler_demo/utils/helpers.dart';
import 'package:notifications_handler_demo/utils/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const _MainApp());
}

class _MainApp extends StatelessWidget {
  static const id = '_MainApp';

  const _MainApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FirebaseNotificationsHandler(
      defaultNavigatorKey: Globals.navigatorKey,
      onOpenNotificationArrive: (_, payload) {
        log(
          id,
          msg: "Notification received while app is open with payload $payload",
        );
      },
      onTap: (navigatorState, appState, payload) {
        showSnackBar('appState: $appState\npayload: $payload');
        log(
          id,
          msg: "Notification tapped with $appState & payload $payload",
        );
      },
      onFCMTokenInitialize: (_, token) => Globals.fcmToken = token,
      onFCMTokenUpdate: (_, token) => Globals.fcmToken = token,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FirebaseNotificationsHandler Demo',
        navigatorKey: Globals.navigatorKey,
        scaffoldMessengerKey: Globals.scaffoldMessengerKey,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: SplashScreen.id,
      ),
    );
  }
}
