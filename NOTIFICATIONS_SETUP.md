# Firebase Notifications & App Update Setup - Tamanina

## 📋 Overview

This project now includes:
- ✅ Firebase Cloud Messaging (FCM) for push notifications
- ✅ Local Notifications for daily reminders
- ✅ In-app update checker using Firebase Remote Config
- ✅ Complete notification handling (foreground, background, terminated)

## 🚀 Features Implemented

### 1. Firebase Cloud Messaging (FCM)
- **Foreground Notifications**: When app is open
- **Background Notifications**: When app is in background
- **Terminated Notifications**: When app is completely closed
- Automatic notification display using `flutter_local_notifications`

### 2. Local Daily Notifications
- Scheduled daily notification at 9:00 AM
- Customizable time, title, and message
- Repeats automatically every day
- Works even when app is closed

### 3. In-App Update System
- Checks for updates on app startup
- Uses Firebase Remote Config for version management
- Shows update dialog with "Update Now" button
- Supports force update feature
- Opens appropriate app store (Play Store/App Store)

## 📦 Dependencies Added

```yaml
firebase_core: ^2.24.2
firebase_messaging: ^14.7.10
flutter_local_notifications: ^17.2.2
firebase_remote_config: ^4.3.8
timezone: ^0.9.2
url_launcher: ^6.2.4
```

## 🔧 Setup Instructions

### Step 1: Install Dependencies

Run the following command to install all dependencies:

```bash
flutter pub get
```

### Step 2: Configure Firebase Remote Config

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `tamanina-624c9`
3. Navigate to **Remote Config**
4. Add the following parameters:

| Parameter | Type | Default Value |
|-----------|------|---------------|
| `latest_version_android` | String | `1.0.0` |
| `latest_version_ios` | String | `1.0.0` |
| `force_update` | Boolean | `false` |
| `update_message_ar` | String | `يتوفر تحديث جديد! يرجى التحديث إلى أحدث إصدار.` |
| `update_message_en` | String | `A new update is available! Please update to the latest version.` |
| `play_store_url` | String | `https://play.google.com/store/apps/details?id=com.abdalluh.tamanina` |
| `app_store_url` | String | `https://apps.apple.com/app/id123456789` |

5. Click **Publish changes**

### Step 3: Enable Cloud Messaging in Firebase

1. In Firebase Console, go to **Cloud Messaging**
2. Note your **Server Key** (for sending notifications from backend)
3. No additional setup needed - FCM is automatically configured

### Step 4: Run the App

```bash
flutter run
```

## 📱 Testing Notifications

### Test FCM (Push Notifications)

1. Get the FCM token from console logs (look for `🔑 FCM Token:`)
2. Use Firebase Console to send a test notification:
   - Go to **Cloud Messaging** > **Send test message**
   - Paste the FCM token
   - Enter title and body
   - Click **Test**

### Test Local Notifications

The app automatically schedules a daily notification at 9:00 AM. To test:

1. Modify the time in `main.dart`:
```dart
await NotificationService().scheduleDailyNotification(
  hour: 14,  // Change to current hour + 1 minute
  minute: 30, // Change to current minute + 1
  title: '🌞 Test Notification',
  body: 'This is a test!',
);
```

2. Hot restart the app
3. Wait for the notification to appear

### Test Update Dialog

1. In Firebase Remote Config, set `latest_version_android` to `2.0.0`
2. Publish changes
3. Restart the app
4. Update dialog should appear

## 🎯 Usage Examples

### Send a Custom Notification

```dart
// From anywhere in your app
await NotificationService().scheduleDailyNotification(
  hour: 18,
  minute: 0,
  title: '🌙 مساء الخير',
  body: 'وقت المراجعة المسائية!',
);
```

### Subscribe to FCM Topic

```dart
await NotificationService().subscribeToTopic('daily_reminders');
```

### Get FCM Token

```dart
String? token = await NotificationService().getFCMToken();
print('FCM Token: $token');
// Send this token to your backend
```

### Manual Update Check

```dart
await AppUpdateService().manualCheckForUpdates(context);
```

### Cancel All Notifications

```dart
await NotificationService().cancelAllNotifications();
```

## 🔐 Permissions

### Android
- `POST_NOTIFICATIONS` - Required for Android 13+
- `RECEIVE_BOOT_COMPLETED` - Reschedule notifications after reboot
- `SCHEDULE_EXACT_ALARM` - For precise notification timing

### iOS
- Automatically requested on first launch
- User can manage in Settings > Tamanina > Notifications

## 📝 File Structure

```
lib/
├── core/
│   └── services/
│       ├── notification_service.dart     # FCM & Local Notifications
│       └── app_update_service.dart       # Update checker
├── main.dart                              # Initialization
├── app.dart                               # Update check trigger
└── firebase_options.dart                  # Fixed Firebase config
```

## 🐛 Troubleshooting

### Notifications not appearing?

**Android:**
1. Check notification permissions in Settings
2. Ensure battery optimization is disabled for the app
3. Check Do Not Disturb mode

**iOS:**
1. Check notification permissions in Settings
2. Ensure notifications are allowed
3. Check Focus modes

### Update dialog not showing?

1. Verify Remote Config is published
2. Check version format (must be `x.y.z`)
3. Ensure internet connection
4. Check console logs for errors

### FCM token not received?

1. Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is present
2. Check Firebase project configuration
3. Ensure internet connection
4. Check console logs

## 🔄 Sending Notifications from Backend

### Using FCM HTTP API

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "مرحباً",
      "body": "رسالة جديدة من طمأنينة"
    },
    "data": {
      "screen": "home",
      "action": "open"
    }
  }'
```

### Using Firebase Admin SDK (Node.js)

```javascript
const admin = require('firebase-admin');

await admin.messaging().send({
  token: deviceToken,
  notification: {
    title: 'مرحباً',
    body: 'رسالة جديدة من طمأنينة',
  },
  data: {
    screen: 'home',
    action: 'open',
  },
  android: {
    priority: 'high',
  },
  apns: {
    headers: {
      'apns-priority': '10',
    },
  },
});
```

## 📊 Analytics

FCM automatically tracks:
- Notification delivery
- Notification opens
- Conversion events

View in Firebase Console > Cloud Messaging > Reports

## 🎨 Customization

### Change Notification Icon (Android)

Replace `android/app/src/main/res/mipmap-*/ic_launcher.png`

### Change Notification Sound

1. Add sound file to `android/app/src/main/res/raw/` or `ios/Runner/`
2. Update notification details:

```dart
AndroidNotificationDetails(
  'channel_id',
  'Channel Name',
  sound: RawResourceAndroidNotificationSound('notification_sound'),
)
```

### Customize Update Dialog

Edit `app_update_service.dart` > `_showUpdateDialog()` method

## ✅ What's Fixed

1. ✅ `firebase_options.dart` - Fixed macOS error (changed `return` to `throw`)
2. ✅ Added all Firebase dependencies
3. ✅ Configured Android manifest with all permissions
4. ✅ Configured iOS Info.plist with background modes
5. ✅ Implemented complete notification service
6. ✅ Implemented app update service
7. ✅ Integrated everything in main.dart

## 🚦 Next Steps

1. **Test on Real Device**: Notifications work best on physical devices
2. **Configure Backend**: Set up server to send notifications
3. **Update Store URLs**: Replace placeholder URLs in Remote Config
4. **Customize Messages**: Update notification titles and bodies
5. **Add Analytics**: Track notification engagement

## 📞 Support

If you encounter any issues:
1. Check the troubleshooting section
2. Review console logs (look for emoji prefixes: 🔔 📨 ✅ ❌)
3. Verify Firebase configuration

---

**Created by**: GitHub Copilot
**Date**: November 11, 2025
**Project**: Tamanina - طمأنينة
