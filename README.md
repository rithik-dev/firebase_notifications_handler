# [FirebaseNotificationsHandler](https://pub.dev/packages/firebase_notifications_handler) For Flutter
[![pub package](https://img.shields.io/pub/v/firebase_notifications_handler.svg)](https://pub.dev/packages/firebase_notifications_handler)
[![likes](https://img.shields.io/pub/likes/firebase_notifications_handler)](https://pub.dev/packages/firebase_notifications_handler/score)
[![popularity](https://img.shields.io/pub/popularity/firebase_notifications_handler)](https://pub.dev/packages/firebase_notifications_handler/score)
[![pub points](https://img.shields.io/pub/points/firebase_notifications_handler)](https://pub.dev/packages/firebase_notifications_handler/score)
[![code size](https://img.shields.io/github/languages/code-size/rithik-dev/firebase_notifications_handler)](https://github.com/rithik-dev/firebase_notifications_handler)
[![license MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

**FirebaseNotificationsHandler** is a simple and easy-to-use notifications handler for Firebase Notifications. It includes built-in support for local notifications, allowing your app to display notifications even when it's in the foreground with no extra setup. With customization options available, you can manage notification behavior seamlessly.

The package uses a widget-based approach, and exposes a widget to handle the notifications. This makes it feel like home for Flutter developers, as it integrates seamlessly with Flutter’s UI-driven architecture. With easy-to-use callbacks such as `onTap`, you can effortlessly manage and respond to notification taps and customize the notification behavior, providing a smooth integration process for any Flutter project.

---

# 🗂️ Table of Contents

- **[📷 Screenshots](#-screenshots)**
- **[✨ Features](#-features)**
- **[🛫 Migration Guides](#-migration-guides)**  
  - [Migration Guide from v1.x to v2.x+](#migration-guide-from-v1x-to-v2x-full-changelog)
- **[🚀 Getting Started](#-getting-started)**
- **[🛠️ Platform-specific Setup](#%EF%B8%8F-platform-specific-setup)**  
  - [Android](#android)
  - [iOS](#ios)
- **[❓ Usage](#-usage)**  
  - [Creating notification channels for Android](#creating-notification-channels-for-android)
  - [Adding custom sound files in platform-specific folders](#adding-custom-sound-files-in-platform-specific-folders)  
    - [Android](#android-1)
    - [iOS](#ios-1)
- **[💡 Solutions to common issues](#-solutions-to-common-issues)**  
  - [Notification not showing as a pop up on Android device](#notification-not-showing-as-a-pop-up-on-android-device)
  - [Custom sound not playing when notification received on Android device](#custom-sound-not-playing-when-notification-received-on-android-device)
  - [Notification image not showing if app in background or terminated even when passed on Android device](#notification-image-not-showing-if-app-in-background-or-terminated-even-when-passed-on-android-device)
  - [Custom sounds in Android work in debug mode but not in release mode](#custom-sounds-in-android-work-in-debug-mode-but-not-in-release-mode)
- **[🎯 Sample Usage](#-sample-usage)**
- **[👤 Collaborators](#-collaborators)**



---

# 📷 Screenshots

| App In Foreground | App In Background | Expanded Notification |
|-----------------------------------|-------------------------------------|-------------------------------------|
| <img src="https://github.com/user-attachments/assets/9823e0df-1475-4bc4-ab1b-d755ec703b76" height="600"> | <img src="https://github.com/user-attachments/assets/3551f0da-5508-4fd0-83c8-d239e7062c7e" height="600"> | <img src="https://github.com/user-attachments/assets/e45e443b-cb55-483a-81f5-dc8b1d5b3dab" height="600"> |

---

# ✨ Features

- **Foreground Notification Handling:** The package allows you to manage notifications even when the app is in the foreground, without needing additional setup.
- **Easy-to-use Callbacks:** You can define custom callbacks when a notification is tapped (`onTap`), when a notification arrives when app open (`onOpenNotificationArrive`), etc., making the widget simple to use.
- **Custom Sounds:** The package supports custom notification sounds for both Android and iOS platforms.
- **Automatic FCM Token Handling:** Built-in functionality to automatically handle Firebase Cloud Messaging (FCM) token initialization and updates, ensuring seamless management of push notification tokens.
- **Cross-Platform Support:** It provides full support for both Android and iOS, ensuring a consistent experience across platforms.
- **Widget-Based Approach:** The package integrates well with Flutter’s UI-driven architecture, offering a widget-based solution for handling notifications.
- **Stream Subscription for Notifications:** Exposes various streams like `notificationTapsSubscription`, `notificationArrivesSubscription` allowing listening to important notification events and managing them easily with the provided NotificationInfo objects.
- **Deep Customization:** The package offers flexibility in customizing notification behavior, such as controlling which notifications are handled, defining custom actions for specific notifications, and setting platform-specific parameters for local notifications.
- **Solutions for Common Issues:** The README provides troubleshooting tips and solutions for commonly faced issues, such as notifications not appearing as pop-ups, custom sounds not working in release mode, and image handling limitations.

---

# 🛫 Migration Guides

## Migration Guide from v1.x to v2.x+ ([Full Changelog](https://github.com/rithik-dev/firebase_notifications_handler/blob/master/CHANGELOG.md#200---23092024))

* Numerous parameters were renamed to add clarity and consistency, and some were removed. Refer to the [CHANGELOG.md](https://github.com/rithik-dev/firebase_notifications_handler/blob/master/CHANGELOG.md#200---18032023) for more details.
* Removed Constants class and added LocalNotificationsConfiguration class which holds android and ios specific configs for local notifications, and takes default values from firebase message, but these parameters can be overwritten by passing in values in the function getters.
* NavigatorKey is no longer accepted/provided in the onTap, onOpenNotificationArrive callbacks. Instead, you'll have to create a key and maintain it in your app. Refer to the [example app](https://github.com/rithik-dev/firebase_notifications_handler/tree/master/example).
* Moved android-specific local notifications config params like channelId, channelName, sound etc. from Constants to localNotificationsConfiguration.androidConfig.
* Moved ios-specific local notifications config params like sound etc. to localNotificationsConfiguration.iosConfig.
* onFCMTokenRefresh is removed. Instead, you can use onFcmTokenUpdate callback. You can always maintain your own stream for tokens in your app if needed.
* NotificationTapDetails class is now called NotificationInfo, and NotificationInfo now also holds the firebase message as a parameter.
* onOpenNotificationArrive now provides an object of NotificationInfo instead of just the payload. The payload can be accessed simply by using `payload` property of this class.
* notificationArrivesSubscription now returns a Stream of NotificationInfo objects instead of just the payload.
* notificationIdGetter moved to localNotificationsConfiguration.notificationIdGetter

---

# 🚀 Getting Started

## Step 1: Create Firebase Project
Create a Firebase project. Learn more about Firebase projects [**here**](https://firebase.google.com/docs/projects/learn-more).

## Step 2: Register your apps and configure Firebase
Add your Android & iOS apps to your Firebase project and configure the Firebase the apps by following the setup instructions for [Android](https://firebase.google.com/docs/flutter/setup?platform=android) and [iOS](https://firebase.google.com/docs/flutter/setup?platform=ios) separately.

## Step 3: Add firebase_core dependency
Add [`firebase_core`](https://pub.dev/packages/firebase_core) as a dependency in your pubspec.yaml file.
```yaml
dependencies:
  flutter:
    sdk: flutter

  firebase_core:
```

## Step 4: Initialize Firebase
Call `Firebase.initializeApp()` in the `main()` method as shown to intialize Firebase in your project.

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}
```

---

# 🛠️ Platform-Specific Setup



## Android
> [!NOTE]
> Refer to the platform specific setup for local notifications [here](https://pub.dev/packages/flutter_local_notifications#-android-setup)
1. Add the following meta-data tags (if required) to define default values in `AndroidManifest.xml` under the `<application>` tag:
```xml
<!-- Can add a default notification channel (if not sending a channel id when sending notification) -->
<!-- If you don't specify a default channel id, and don't pass an id when sending notification, Android creates a default channel "Miscellaneous" -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="default" />

<!-- Use the following tags if you need to different icons or color for app icon -->
<!-- <meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/notification_icon" />

<meta-data
    android:name="com.google.firebase.messaging.default_notification_color"
    android:resource="@color/notification_color" /> -->
```

2. Add this `<intent-filter>` in the `<activity>` tag:
```xml
<intent-filter>
    <action android:name="FLUTTER_NOTIFICATION_CLICK" />
    <category android:name="android.intent.category.DEFAULT" />
</intent-filter>
```

## iOS
> [!NOTE]
> Refer to the platform specific setup for local notifications [here](https://pub.dev/packages/flutter_local_notifications#-ios-setup)


---

# ❓ Usage

1. Add [`firebase_notifications_handler`](https://pub.dev/packages/firebase_notifications_handler) as a dependency in your pubspec.yaml file.
```yaml
dependencies:
  flutter:
    sdk: flutter

  firebase_notifications_handler:
```

2. Wrap the `FirebaseNotificationsHandler` widget ideally as a parent widget on the `MaterialApp` to enable your application to receive notifications.
```dart
import 'package:firebase_notifications_handler/firebase_notifications_handler.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FirebaseNotificationsHandler(
      child: MaterialApp(),
    );
  }
}
```

Although, the widget automatically initializes the FCM token, but if the FCM token is needed before the widget is built, use the `FirebaseNotificationsHandler.initializeFcmToken()` function to initialize the token, which will initialize and return initialized token. This will also trigger the `onFCMTokenInitialize` callback.

3. Explore the widget [documentation](https://pub.dev/documentation/firebase_notifications_handler/latest/firebase_notifications_handler/FirebaseNotificationsHandler-class.html), and see the different configurations available, allowing you to customize each and every bit of your notifications.
```dart
FirebaseNotificationsHandler(
  localNotificationsConfiguration: LocalNotificationsConfiguration(
    androidConfig: AndroidNotificationsConfig(
      // ...
    ),
    iosConfig: IosNotificationsConfig(
      // ...
    ),
  ),
  onOpenNotificationArrive: (info) {
    log(
      id,
      msg: 'Notification received while app is open with payload ${info.payload}',
    );
  },
  onTap: (info) {
    final payload = info.payload;
    final appState = info.appState;
    final firebaseMessage = info.firebaseMessage;

    // If you want to push a screen on notification tap
    //
    // Globals.navigatorKey.currentState?.pushNamed(payload['screenId']);
    //
    // OR
    ///
    // Get current context
    // final context = Globals.navigatorKey.currentContext!;

    log(
      id,
      msg: 'Notification tapped with $appState & payload $payload. Firebase message: $firebaseMessage',
    );
  },
  onFcmTokenInitialize: (token) => Globals.fcmTokenNotifier.value = token,
  onFcmTokenUpdate: (token) => Globals.fcmTokenNotifier.value = token,
  // ...
);
```  
    
## Creating notification channels for Android
By default, if you send a notification, the device will automatically create a notification channel with the passed `channelId`, but the priority for that channel will be normal, and the notification will not show up as a popup.

Creating a default channel lets you set the priorty to `high` and also give you more customization of the channels like setting a custom notification sound, setting vibration patterns etc.
```dart
FirebaseNotificationsHandler.createAndroidNotificationChannel(
  const AndroidNotificationChannel(
    'marketing',
    'Marketing',
    description: 'Notification channel for marketing',
    playSound: true,
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('marketing'),
  ),
);
```

It is recommended to create notification channels as soon as the app starts, as the custom sounds will not play if the channel is not created for the first time, and it might cause issues with other parameters as well.
```dart
FirebaseNotificationsHandler.createAndroidNotificationChannels([
  const AndroidNotificationChannel(
    'promotions',
    'Promotions',
    description: 'Notification channel for promotions',
    playSound: true,
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('chime'),
  ),
  const AndroidNotificationChannel(
    'order-updates',
    'Order Updates',
    description: 'Notification channel for order updates',
    playSound: true,
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('elevator'),
  ),
  const AndroidNotificationChannel(
    'messages',
    'Messages',
    description: 'Notification channel for messages',
    playSound: true,
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound('bell'),
  ),
]);
```

## Adding custom sound files in platform-specific folders

### Android
> [!IMPORTANT]
> Add a [keep.xml](https://github.com/rithik-dev/firebase_notifications_handler/tree/master/example/android/app/src/main/res/raw/keep.xml) file in the `android/app/src/main/res/raw/` folder, as flutter strips off the `raw` folder when compiling app in release mode, and hence the custom sounds won't work in release mode.

* Add the audio file in the `android/app/src/main/res/raw/` folder.  

### iOS
- Add the audio file in the `ios/Runner/Resources/` folder.

---

# 💡 Solutions to common issues
## Notification not showing as a pop up on Android device: 
On Android devices, a notification channel by default when a notification arrives, but that might not have the priority set to high. The notification only shows up as a popup if the channel you're sending it to has priority set as "high". We can solve this issue by creating a notification channel on app start using:
```dart
FirebaseNotificationsHandler.createAndroidNotificationChannel(
  const AndroidNotificationChannel(
    'default',
    'Default',
    importance: Importance.high,
  ),
);
```

## Custom sound not playing when notification received on Android device:
On Android devices, a notification channel by default when a notification arrives, but that won't have the sound set to it by default. The sound will only play if the channel was creating while specifying the custom sound you want to play for that channel. 
> [!NOTE]
> You cannot modify a channel's sound after it's created. Only way is to either use a new channel id or delete an existing channel using `FirebaseNotificationsHandler.deleteAndroidNotificationChannel(String channelId);` and creating a new one with the new sound. Or try uninstalling the app and creating the channel again.  

We can solve this issue by creating a notification channel on app start and passing in the sound using:
```dart
FirebaseNotificationsHandler.createAndroidNotificationChannel(
  const AndroidNotificationChannel(
    'default',
    'Default',
    playSound: true,
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('pop'),
  ),
);
```

## Notification image not showing if app in background or terminated even when passed on Android device:
The max size for a notification to be displayed by firebase on an Android device is 1MB ([Source](https://firebase.google.com/docs/cloud-messaging/android/send-image#:~:text=Images%20for%20notifications%20are%20limited,by%20native%20Android%20image%20support.)). So, if an image exceeds this size, it is not shown in the notification. However, if the app is in foreground, then there is no size limitation as then it's handled by local notifications.

## Custom sounds in Android work in debug mode but not in release mode:
Flutter strips off the `raw` folder during compiling build for release mode. We can add a file [keep.xml](https://github.com/rithik-dev/firebase_notifications_handler/tree/master/example/android/app/src/main/res/raw/keep.xml) in the raw folder, which tells flutter to not strip off the raw folder, and hence fixing the issue.

---

# 🎯 Sample Usage

See the [example](https://github.com/rithik-dev/firebase_notifications_handler/blob/master/example) app for a complete app. Learn how to setup the example app for testing [here](https://github.com/rithik-dev/firebase_notifications_handler/blob/master/example/README.md).

```dart
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

  const _MainApp();

  @override
  Widget build(BuildContext context) {
    return FirebaseNotificationsHandler(
      localNotificationsConfiguration: LocalNotificationsConfiguration(
        androidConfig: AndroidNotificationsConfig(
            // ...
        ),
        iosConfig: IosNotificationsConfig(
            // ...
        ),
      ),
      shouldHandleNotification: (msg) {
        // add some logic and return bool on whether to handle a notif or not
        return true;
      },
      onOpenNotificationArrive: (info) {
        log(
          id,
          msg: 'Notification received while app is open with payload ${info.payload}',
        );
      },
      onTap: (info) {
        final payload = info.payload;
        final appState = info.appState;
        final firebaseMessage = info.firebaseMessage;

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

        log(
          id,
          msg: 'Notification tapped with $appState & payload $payload. Firebase messag: $firebaseMessage',
        );
      },
      onFcmTokenInitialize: (token) => Globals.fcmTokenNotifier.value = token,
      onFcmTokenUpdate: (token) => Globals.fcmTokenNotifier.value = token,
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
```

# 👤 Collaborators


| Name | GitHub | Linkedin |
|-----------------------------------|-------------------------------------|-------------------------------------|
| Rithik Bhandari | [github/rithik-dev](https://github.com/rithik-dev) | [linkedin/rithik-bhandari](https://www.linkedin.com/in/rithik-bhandari) |