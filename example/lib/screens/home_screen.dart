import 'package:easy_container/easy_container.dart';
import 'package:firebase_notifications_handler/firebase_notifications_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notifications_handler_demo/utils/constants.dart';
import 'package:notifications_handler_demo/utils/globals.dart';
import 'package:notifications_handler_demo/utils/helpers.dart';

class HomeScreen extends StatefulWidget {
  static const id = 'HomeScreen';

  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    await FirebaseNotificationsHandler.sendNotification(
      cloudMessagingServerKey: Constants.cloudMessagingServerKey,
      title: 'AppLifecycleState',
      body: state.toString(),
      fcmTokens: [Globals.fcmToken!],
    );
    super.didChangeAppLifecycleState(state);
  }

  bool showNotificationsOnLifecycleChange = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            if (Globals.fcmToken != null) Text(Globals.fcmToken!),
            const SizedBox(height: 15),
            EasyContainer(
              onTap: () async {
                Clipboard.setData(ClipboardData(text: Globals.fcmToken));
              },
              child: const Text('Copy FCM Token'),
            ),
            const SizedBox(height: 15),
            EasyContainer(
              child: SwitchListTile(
                title: const Text(
                  'Send notifications on app lifecycle change!',
                ),
                onChanged: (value) {
                  setState(() => showNotificationsOnLifecycleChange = value);
                  if (showNotificationsOnLifecycleChange) {
                    WidgetsBinding.instance.addObserver(this);
                  } else {
                    WidgetsBinding.instance.removeObserver(this);
                  }
                },
                value: showNotificationsOnLifecycleChange,
              ),
            ),
            const SizedBox(height: 15),
            _SendSampleNotification(),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class _SendSampleNotification extends StatelessWidget {
  String? notificationTitle;
  String? notificationBody;
  String? notificationImageUrl;

  _SendSampleNotification({
    Key? key,
  }) : super(key: key);

  Future<void> _sendNotification() async {
    await FirebaseNotificationsHandler.sendNotification(
      cloudMessagingServerKey: Constants.cloudMessagingServerKey,
      fcmTokens: [Globals.fcmToken!],
      title: notificationTitle!,
      body: notificationBody,
      imageUrl:
          isNullOrBlank(notificationImageUrl) ? null : notificationImageUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return EasyContainer(
      child: Column(
        children: [
          const Text('Send sample FCM notification'),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Title'),
            onChanged: (v) => notificationTitle = v,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Body'),
            onChanged: (v) => notificationBody = v,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Image URL'),
            onChanged: (v) => notificationImageUrl = v,
          ),
          const SizedBox(height: 15),
          EasyContainer(
            onTap: () async {
              if (isNullOrBlank(notificationTitle)) {
                return showSnackBar('Title cannot be empty!');
              }

              await _sendNotification();
            },
            color: Theme.of(context).colorScheme.primary,
            child: const Text('Send Notification'),
          ),
          EasyContainer(
            onTap: () async {
              if (isNullOrBlank(notificationTitle)) {
                return showSnackBar('Title cannot be empty!');
              }

              await Future.delayed(const Duration(seconds: 5));
              await _sendNotification();
            },
            color: Theme.of(context).colorScheme.primary,
            child: const Text('Send Notification after 5s'),
          ),
        ],
      ),
    );
  }
}
