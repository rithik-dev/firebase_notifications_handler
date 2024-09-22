import 'dart:async';

import 'package:easy_container/easy_container.dart';
import 'package:firebase_notifications_handler/firebase_notifications_handler.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notifications_handler_demo/utils/globals.dart';
import 'package:notifications_handler_demo/utils/helpers.dart';
import 'package:notifications_handler_demo/widgets/custom_loader.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeScreen extends StatefulWidget {
  static const id = 'HomeScreen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _projectLink = 'https://pub.dev/packages/firebase_notifications_handler';

  final _notificationTaps = <NotificationInfo>[];
  final _notificationArrives = <NotificationInfo>[];

  late StreamSubscription<NotificationInfo> _notificationArriveSubscription;
  late StreamSubscription<NotificationInfo> _notificationTapsSubscription;

  void _addNotificationTap(NotificationInfo notificationTap) {
    _notificationTaps.insert(0, notificationTap);
    setState(() {});
  }

  void _addNotificationArrive(NotificationInfo notificationArrive) {
    _notificationArrives.insert(0, notificationArrive);
    setState(() {});
  }

  final _linkTapRecognizer = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();

    FirebaseNotificationsHandler.createAndroidNotificationChannel(
      const AndroidNotificationChannel(
        'Notifications',
        'Notifications',
        playSound: true,
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('custom_sound'),
      ),
    );

    _notificationTapsSubscription =
        FirebaseNotificationsHandler.notificationTapsSubscription.listen(_addNotificationTap);

    _notificationArriveSubscription =
        FirebaseNotificationsHandler.notificationArrivesSubscription.listen(_addNotificationArrive);
  }

  @override
  void dispose() {
    _notificationTapsSubscription.cancel();
    _notificationArriveSubscription.cancel();
    _linkTapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            EasyContainer(
              child: ValueListenableBuilder(
                valueListenable: Globals.fcmTokenNotifier,
                builder: (context, value, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'FCM Token',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (value != null) ...{
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: value));
                                showSnackBar('FCM token copied to clipboard!');
                              },
                              icon: const Icon(Icons.copy),
                            ),
                          },
                        ],
                      ),
                      const SizedBox(height: 5),
                      if (value != null) Text(value) else const CustomLoader(),
                      const SizedBox(height: 5),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Please refer to the docs at '),
                  TextSpan(
                    text: _projectLink,
                    style: const TextStyle(color: Colors.blue),
                    recognizer: _linkTapRecognizer..onTap = () => launchUrlString(_projectLink),
                  ),
                  const TextSpan(text: ' to see how to send notifications'),
                ],
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Notification Taps History',
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (_notificationTaps.isNotEmpty) ...{
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _notificationTaps.clear();
                      setState(() {});
                    },
                    child: const Text('Clear'),
                  ),
                },
              ],
            ),
            if (_notificationTaps.isEmpty)
              const Center(child: Text('No Items'))
            else
              ..._notificationTaps.map((notificationTap) {
                return EasyContainer(
                  child: _buildNotificationInfo(notificationTap),
                );
              }),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Notification Arrive History',
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (_notificationArrives.isNotEmpty) ...{
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _notificationArrives.clear();
                      setState(() {});
                    },
                    child: const Text('Clear'),
                  ),
                },
              ],
            ),
            if (_notificationArrives.isEmpty)
              const Center(child: Text('No Items'))
            else
              ..._notificationArrives.map((notificationArrive) {
                return EasyContainer(
                  child: _buildNotificationInfo(notificationArrive),
                );
              })
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationInfo(NotificationInfo notificationInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Title: ${notificationInfo.firebaseMessage.notification?.title!}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          'Body: ${notificationInfo.firebaseMessage.notification?.body!}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          'Sent Time: ${notificationInfo.firebaseMessage.sentTime}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          'App State: ${notificationInfo.appState.name}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          'Payload: ${notificationInfo.payload}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
