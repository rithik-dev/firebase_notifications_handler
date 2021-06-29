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
    return FirebaseNotificationsHandler(
      onOpenNotificationArrive: (_, payload) {
        print("Notification received while app is open with payload $payload");
      },
      onTap: (navigatorState, appState, payload) {
        print("Notification tapped with $appState & payload $payload");

        final context = navigatorState.currentContext!;
        navigatorState.currentState!.pushNamed('newRouteName');
        // OR
        Navigator.pushNamed(context, 'newRouteName');
      },
      onFCMTokenInitialize: (_, token) => fcmToken = token,
      onFCMTokenUpdate: (_, token) {
        fcmToken = token;
        // await User.updateFCM(token);
      },
      child: MaterialApp(
        navigatorKey: FirebaseNotificationsHandler.navigatorKey,
      ),
    );
  }
}
