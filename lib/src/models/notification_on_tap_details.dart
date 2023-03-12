import 'package:firebase_notifications_handler/src/enums/app_state.dart';

class NotificationOnTapDetails {
  NotificationOnTapDetails({
    required this.appState,
    required this.payload,
  });

  final Map<dynamic, dynamic> payload;
  final AppState appState;
}
