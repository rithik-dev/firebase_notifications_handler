# Firebase Notifications Handler Demo

To test the example app, clone the project and add the `firebase_options.dart` with your firebase options file in `lib/firebase_options.dart`.

Then, build the app and run it. The app is set to receive notifications.

## How to send notifications test notifications to the app

- ### Using Firebase Console
    1. Open the [Firebase Console](https://console.firebase.google.com/), and then go to Build > Messaging from the left panel. Choose Create first campaign, and then Firebase notification message.
    2. Set the title, body and image (if any), and then press Send test message, paste the FCM token which you can get by running the example app and copy it, and then send the notification.

- ### Using Node Project
    1. Clone this [notification-sender](https://github.com/rithik-dev/notification-sender) project,
    2. Download the service account key file by visiting the [Google Cloud Service Accounts Panel](https://console.cloud.google.com/iam-admin/serviceaccounts) and select the correct project, and add a new key or use an existing one if you already have.
    3. Create a `.env` file in the [root folder](https://github.com/rithik-dev/notification-sender/tree/main). Add keys `FIREBASE_PROJECT_ID`, `CLIENT_EMAIL` and `PRIVATE_KEY` in the .env file.
    4. Get the FCM token by running the example app, and pass it to the `fcm_tokens` property of `sendNotification` function in the [index.ts](https://github.com/rithik-dev/notification-sender/blob/main/src/index.ts) file.
    5. Run `npm start`.