import 'package:firebase_notifications_handler/src/enums/app_state.dart';

class NotificationOnTapDetails {
  const NotificationOnTapDetails({
    required this.appState,
    required this.payload,
  });

  /// The app state when the notification was tapped.
  final AppState appState;

  /// The payload of the notification.
  final Map<String, dynamic> payload;
}
