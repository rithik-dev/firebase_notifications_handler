<!-- Pending release notes. The release workflow moves these into CHANGELOG.md under the new version heading, then clears this file. Write them for the people who use this package, using the same `* entry` bullet style as CHANGELOG.md. This file lives under .github/ so it never ships to pub.dev. -->

* **BREAKING:** Minimum SDK is now Dart 3.10 / Flutter 3.38.1, raised from Dart 3.3 / Flutter 3.19.
* **BREAKING:** Updated `firebase_messaging` to ^16.4.3, which resolves the version conflict for apps already on `firebase_messaging` 16.x.
* **BREAKING:** Updated `flutter_local_notifications` to ^22.2.0. Removed the `uiLocalNotificationDateInterpretation` parameter from `sendLocalNotification`, as `UILocalNotificationDateInterpretation` no longer exists upstream. Remove the argument from your calls; no replacement is needed.
* **BREAKING:** This package re-exports `firebase_messaging` and `flutter_local_notifications`, so the breaking changes in those two major releases reach your code directly and not just this package's own API. Most notably, `flutter_local_notifications` moved `show`, `zonedSchedule` and `initialize` to named parameters.
* Updated `timezone` to ^0.11.1, `http` to ^1.6.0, `path` to ^1.9.1 and `path_provider` to ^2.1.6.
* Fixed notifications not being handled in the background or when terminated on release builds, which failed with "To access `_FirebaseNotificationsHandlerState` from native code, it must be annotated". The background message handler is now a top-level entry point, as FCM requires.
* Fixed `FirebaseNotificationsHandler.openedAppFromNotification` always returning false. It captured its value once at startup instead of reading the current state.
* Fixed a subscription leak in `initializeFcmToken`: calling it more than once registered an additional token-refresh listener each time, so `onFcmTokenUpdate` fired repeatedly for a single token change.
* Fixed a notification being dropped entirely when its image or icon failed to download. A failed or non-200 response now falls back to a notification without the image, instead of throwing.
* Fixed the handler being torn down on `deactivate` rather than `dispose`, which left it permanently inactive if the widget was moved within the widget tree.
* Added `titleGetter` and `bodyGetter` to `LocalNotificationsConfiguration`, so notifications sent with `title_loc_key` / `body_loc_key` can be resolved against your app's own localizations instead of showing up blank. A log now points this out when such a message arrives unresolved.
* Bounded the internal set used to de-duplicate notifications, which previously grew for the lifetime of the app.
