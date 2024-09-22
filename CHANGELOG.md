## [2.0.0+1] - 23/09/2024

* Formatted files
* Updated scripts in pubspec.yaml

## [2.0.0] - 23/09/2024

* **BREAKING:** No navigator key param in handler, and in callbacks onTap, onOpenNotificationArrive
* **BREAKING:** No context in callbacks onFcmTokenInitialize, onFcmTokenUpdate
* **BREAKING:** Renamed AppState.closed to AppState.terminated
* **BREAKING:** onTap now gives an object of NotificationInfo
* **BREAKING:** enableLogs is now available as a static variable in FirebaseNotificationsHandler
* **BREAKING:** Renamed onFCMTokenInitialize to onFcmTokenInitialize
* **BREAKING:** Renamed onFCMTokenUpdate to onFcmTokenUpdate
* **BREAKING:** Renamed initializeFCMToken to initializeFcmToken
* **BREAKING:** Removed onFCMTokenRefresh
* **BREAKING:** Renamed requestPermissionsOnInit to requestPermissionsOnInitialize
* **BREAKING:** Removed sendFcmNotification as API has been deprecated to send notifications from client side.
* Introduced a new sendLocalNotification function which can be used to send/schedule local notifications.
* **BREAKING:** Added androidConfig and iosConfig in  and moved platform specific configs there like channelId, channelName etc. which was in the root before, and these values are getters, which can be modified for every incoming message.
* **BREAKING:** Renamed `NotificationTapDetails` to `NotificationInfo`. NotificationInfo now also holds `firebaseMessage`.
* **BREAKING:** Callbacks onTap and onOpenNotificationArrive callbacks now give `NotificationInfo` param which contains info about the notification.
* Added notificationTapsSubscription, notificationArrivesSubscription streams.
* Added android notification channel create, read, delete methods.
* Added `permissionGetter` function to override permission request getter.
* Added notification handling / modifying callbacks like `shouldHandleNotification`, `messageModifier` etc.
* Added `stateKeyGetter` getter to generate widget key, allowing to call internal methods using keys.
* Added `getInitialMessage` callback to get initial notification details if app was opened from a notification.
* Added logs in debug mode.
* Fixed issues with images not showing in notifications.
* Updated example app with latest SDKs
* Updated documentation
* Updated dependencies to latest release
* Added issue tracker link
* Updated README.md and badges

## [1.1.0] - 25/10/2022

* Updated example app
* Updated documentation
* Updated some dependencies to latest release

## [1.0.9] - 04/08/2022

* Updated dependencies

## [1.0.8] - 07/06/2022

* Updated dependencies
* Fixed linter warnings
* Added handleInitialMessage attribute
* Exported firebase_messaging package
* Updated README.md

## [1.0.7] - 02/05/2022

* Updated example app to a fully functional app...
* Updated dependencies
* Updated README.md

## [1.0.6] - 15/03/2022

* Fixed sendNotification bug

## [1.0.5] - 15/03/2022

* Fixed null check error in main widget.
* Updated README.md

## [1.0.4] - 15/03/2022

* Updated payload type.
* Added notificationMeta in sendNotification.

## [1.0.3] - 15/03/2022

* Minor fix in sendNotification.
* Updated example app
* Updated README.md

## [1.0.2] - 14/03/2022

* Added sendNotification function to trigger FCM notification.
* Updated dependencies
* Updated README.md

## [1.0.1] - 26/01/2022

* Updated license
* Updated README.md

## [1.0.0] - 26/01/2022

* Added linter and updated code accordingly
* Updated example app
* Updated dependencies
* Updated README.md

## [0.0.8] - 28/10/2021

* Exposed initializeFCMToken & onFCMTokenRefresh callbacks
* Updated dependencies
* Updated example app
* Updated README.md

## [0.0.7] - 01/08/2021

* Updated README.md

## [0.0.6] - 01/08/2021

* Updated README.md

## [0.0.5] - 01/08/2021

* Added custom sound support for iOS
* Added images support in notifications
* Updated dependencies
* Updated README.md

## [0.0.4] - 04/07/2021

* Updated README.md

## [0.0.3] - 30/06/2021

* Bug fix

## [0.0.2] - 30/06/2021

* Updated README.md

## [0.0.1] - 30/06/2021

* Simple notifications handler which provides callbacks like onTap which really make it easy to
  handle notification taps and a lot more.
