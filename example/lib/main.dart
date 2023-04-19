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
      androidConfig: AndroidNotificationsConfig(
        channelIdGetter: (msg) =>
            msg.notification?.android?.channelId ?? 'default',
      ),
      iosConfig: IosNotificationsConfig(
        soundGetter: (_) => 'ios_sound.caf',
      ),
      shouldHandleNotification: (msg) {
        // add some logic and return bool on whether to handle a notif or not
        return true;
      },
      onOpenNotificationArrive: (payload) {
        // final context = Globals.navigatorKey.currentContext!;

        log(
          id,
          msg: "Notification received while app is open with payload $payload",
        );
      },
      onTap: (details) {
        final payload = details.payload;
        final appState = details.appState;

        /// If you want to push a screen on notification tap
        ///
        // Globals.navigatorKey.currentState?.pushNamed(
        //   payload['screenId'],
        // );
        ///
        /// or
        ///
        /// Get current context
        // final context = Globals.navigatorKey.currentContext!;

        showSnackBar('appState: $appState\npayload: $payload');
        log(
          id,
          msg: "Notification tapped with $appState & payload $payload",
        );
      },
      onFcmTokenInitialize: (token) => Globals.fcmToken = token,
      onFcmTokenUpdate: (token) => Globals.fcmToken = token,
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
