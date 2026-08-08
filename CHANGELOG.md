## 3.0.3 - 2026-08-08

* Maintenance release; no user-facing changes.

## 3.0.2 - 2026-08-08

* Maintenance release; no user-facing changes.

## 3.0.1 - 2026-08-08

* Added a screenshot to the package listing, so pub.dev now shows a thumbnail in search results and a gallery on the package page.
* README: dropped a badge that had stopped rendering, swapped in monthly downloads, and added links to the author's portfolio and other packages.
* README: the screenshots are now served from this repository instead of GitHub's attachment CDN, which was outside the repo's control and could have gone stale.

## 3.0.0 - 2026-08-07

* **BREAKING:** Minimum SDK is now Dart 3.10 / Flutter 3.38.1, raised from Dart 3.3 / Flutter 3.19.
* **BREAKING:** Updated `firebase_messaging` to ^16.4.3, which resolves the version conflict for apps already on `firebase_messaging` 16.x.
* **BREAKING:** Updated `flutter_local_notifications` to ^22.2.0. Removed the `uiLocalNotificationDateInterpretation` parameter from `sendLocalNotification`, as `UILocalNotificationDateInterpretation` no longer exists upstream. Remove the argument from your calls; no replacement is needed.
* **BREAKING:** This package re-exports `firebase_messaging` and `flutter_local_notifications`, so the breaking changes in those two major releases reach your code directly and not just this package's own API. Most notably, `flutter_local_notifications` moved `show`, `zonedSchedule` and `initialize` to named parameters.
* **BREAKING:** Android apps must now enable core library desugaring and compile against Java 17, which `flutter_local_notifications` 22 requires of the consuming app. Without it the build fails with "Dependency ':flutter_local_notifications' requires core library desugaring to be enabled". In `android/app/build.gradle` set `coreLibraryDesugaringEnabled = true` with `sourceCompatibility`/`targetCompatibility` of `JavaVersion.VERSION_17`, and add `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")` to your dependencies. Android `minSdk` must be at least 24.
* Updated `timezone` to ^0.11.1, `http` to ^1.6.0, `path` to ^1.9.1 and `path_provider` to ^2.1.6.
* Fixed notifications not being handled in the background or when terminated on release builds, which failed with "To access `_FirebaseNotificationsHandlerState` from native code, it must be annotated". The background message handler is now a top-level entry point, as FCM requires.
* Fixed `FirebaseNotificationsHandler.openedAppFromNotification` always returning false. It captured its value once at startup instead of reading the current state.
* Fixed a subscription leak in `initializeFcmToken`: calling it more than once registered an additional token-refresh listener each time, so `onFcmTokenUpdate` fired repeatedly for a single token change.
* Fixed a notification being dropped entirely when its image or icon failed to download. A failed or non-200 response now falls back to a notification without the image, instead of throwing.
* Fixed the handler being torn down on `deactivate` rather than `dispose`, which left it permanently inactive if the widget was moved within the widget tree.
* Added `titleGetter` and `bodyGetter` to `LocalNotificationsConfiguration`, so notifications sent with `title_loc_key` / `body_loc_key` can be resolved against your app's own localizations instead of showing up blank. A log now points this out when such a message arrives unresolved.
* Bounded the internal set used to de-duplicate notifications, which previously grew for the lifetime of the app.

## 2.0.4 - 2026-07-28

* Maintenance release; no user-facing changes.

## 2.0.3 - 2026-07-28

* Declared `timezone` and `path` as direct dependencies; both were imported by the package but resolved only transitively.
* Added GitHub Actions CI to automate version bumps, changelog updates, tagging and pub.dev publishing.

## 2.0.2+1 - 2025-01-25

* Updated dependency to latest release
* Fix dart static analysis warnings

## 2.0.2 - 2024-10-06

* Added web documentation in README
* Updated SDK constraints

## 2.0.1+2 - 2024-09-28

* Update API reference link in README

## 2.0.1+1 - 2024-09-28

* Updated package description

## 2.0.1 - 2024-09-28

* Default android notification channel id is now "default" instead of "Notifications"
* Updated example app with more custom sounds
* Updated README.md
* Updated package description and added additional tags

## 2.0.0+1 - 2024-09-23

* Formatted files
* Updated scripts in pubspec.yaml

## 2.0.0 - 2024-09-23

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

## 1.1.0 - 2022-10-25

* Updated example app
* Updated documentation
* Updated some dependencies to latest release

## 1.0.9 - 2022-08-03

* Updated dependencies

## 1.0.8 - 2022-06-07

* Updated dependencies
* Fixed linter warnings
* Added handleInitialMessage attribute
* Exported firebase_messaging package
* Updated README.md

## 1.0.7 - 2022-05-02

* Updated example app to a fully functional app...
* Updated dependencies
* Updated README.md

## 1.0.6 - 2022-03-15

* Fixed sendNotification bug

## 1.0.5 - 2022-03-15

* Fixed null check error in main widget.
* Updated README.md

## 1.0.4 - 2022-03-15

* Updated payload type.
* Added notificationMeta in sendNotification.

## 1.0.3 - 2022-03-15

* Minor fix in sendNotification.
* Updated example app
* Updated README.md

## 1.0.2 - 2022-03-14

* Added sendNotification function to trigger FCM notification.
* Updated dependencies
* Updated README.md

## 1.0.1 - 2022-01-26

* Updated license
* Updated README.md

## 1.0.0 - 2022-01-26

* Added linter and updated code accordingly
* Updated example app
* Updated dependencies
* Updated README.md

## 0.0.8 - 2021-10-28

* Exposed initializeFCMToken & onFCMTokenRefresh callbacks
* Updated dependencies
* Updated example app
* Updated README.md

## 0.0.7 - 2021-08-02

* Updated README.md

## 0.0.6

* Updated README.md

## 0.0.5 - 2021-08-01

* Added custom sound support for iOS
* Added images support in notifications
* Updated dependencies
* Updated README.md

## 0.0.4 - 2021-07-04

* Updated README.md

## 0.0.3 - 2021-07-01

* Bug fix

## 0.0.2 - 2021-06-30

* Updated README.md

## 0.0.1 - 2021-04-17

* Simple notifications handler which provides callbacks like onTap which really make it easy to
  handle notification taps and a lot more.
