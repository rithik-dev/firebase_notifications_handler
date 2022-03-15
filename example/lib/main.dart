import 'package:firebase_notifications_handler/firebase_notifications_handler.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: add firebase_core and call
  // await Firebase.initializeApp();
  runApp(_MainApp());
}

String? fcmToken;

class _MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: FirebaseNotificationsHandler.navigatorKey,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FirebaseNotificationsHandler(
      onOpenNotificationArrive: (_, payload) {
        debugPrint(
          "Notification received while app is open with payload $payload",
        );
      },
      onTap: (navigatorState, appState, payload) {
        debugPrint("Notification tapped with $appState & payload $payload");

        navigatorState.currentState!.pushNamed('newRouteName');
        // OR
        final context = navigatorState.currentContext!;
        Navigator.pushNamed(context, 'newRouteName');
      },
      onFCMTokenInitialize: (_, token) => fcmToken = token,
      onFCMTokenUpdate: (_, token) {
        fcmToken = token;
        // await User.updateFCM(token);
      },
      child: SafeArea(
        child: Scaffold(
          body: Center(
            child: Text(
              '_HomeScreen',
              style: Theme.of(context).textTheme.headline3,
            ),
          ),
        ),
      ),
    );
  }
}

void sendExampleNotification() async {
  await FirebaseNotificationsHandler.sendNotification(
    cloudMessagingServerKey: '<YOUR_CLOUD_MESSAGING_SERVER_KEY>',
    title: 'This is a test notification',
    body: 'This describes this notification',
    fcmTokens: [
      'fcmDeviceToken1',
      'fcmDeviceToken2',
    ],
    payload: {
      'key': 'value',
    },
  );
}
