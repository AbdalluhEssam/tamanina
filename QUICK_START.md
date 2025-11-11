# 🚀 Quick Start Guide - Notifications & Updates

## 🎯 What Was Implemented

✅ **Firebase Cloud Messaging (FCM)** - Push notifications from server
✅ **Local Notifications** - Daily scheduled reminders  
✅ **App Update Checker** - Automatic version checking with dialog
✅ **Complete notification handling** - Foreground, background, and terminated states

---

## 📦 Step 1: Verify Installation

```bash
cd /Users/abdalluh/StudioProjects/tamanina
flutter pub get
```

**Expected**: All dependencies installed ✅

---

## 🔧 Step 2: Configure Firebase Remote Config

### Go to Firebase Console
1. Open: https://console.firebase.google.com
2. Select project: **tamanina-624c9**
3. Navigate to: **Remote Config**
4. Click: **Add parameter**
5. Add these 7 parameters:

| Parameter | Type | Value |
|-----------|------|-------|
| `latest_version_android` | String | `1.0.0` |
| `latest_version_ios` | String | `1.0.0` |
| `force_update` | Boolean | `false` |
| `update_message_ar` | String | `يتوفر تحديث جديد! يرجى التحديث إلى أحدث إصدار.` |
| `update_message_en` | String | `A new update is available! Please update to the latest version.` |
| `play_store_url` | String | `https://play.google.com/store/apps/details?id=com.abdalluh.tamanina` |
| `app_store_url` | String | `https://apps.apple.com/app/id123456789` |

6. Click: **Publish changes**

---

## 🧪 Step 3: Test the Implementation

### Test 1: Run the App
```bash
flutter run
```

**Look for these logs:**
```
✅ Notification Service initialized successfully
✅ Remote Config initialized successfully
🔑 FCM Token: [your_token_here]
⏰ Daily notification scheduled for 9:00
```

### Test 2: Test FCM Push Notification
1. Copy FCM token from console
2. Go to Firebase Console > Cloud Messaging
3. Click "Send your first message"
4. Fill in:
   - **Title**: "Test Notification"
   - **Body**: "This is a test!"
   - Click "Send test message"
   - Paste FCM token
   - Click "Test"

**Expected**: Notification appears ✅

### Test 3: Test Local Notification (Quick)
Add this test screen to your app:

```dart
import 'package:flutter/material.dart';
import 'package:tamanina/core/services/notification_service.dart';

class QuickTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quick Test')),
      body: Center(
        child: ElevatedButton(
          child: Text('Schedule Test Notification (1 min)'),
          onPressed: () async {
            final now = DateTime.now();
            await NotificationService().scheduleDailyNotification(
              hour: now.hour,
              minute: now.minute + 1,
              title: '🧪 Test',
              body: 'This is a test notification!',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Notification in 1 minute!')),
            );
          },
        ),
      ),
    );
  }
}
```

**Expected**: Notification appears after 1 minute ✅

### Test 4: Test Update Dialog
1. In Firebase Remote Config:
   - Change `latest_version_android` to `2.0.0`
   - Click "Publish changes"
2. Restart your app
3. Wait 2 seconds

**Expected**: Update dialog appears ✅

---

## 📱 Step 4: Test on Real Device

### Android
```bash
flutter run --release
```

### iOS
```bash
flutter run --release
```

**Note**: Notifications work better on physical devices

---

## 🎨 Customization

### Change Daily Notification Time
Edit `lib/main.dart`:

```dart
await NotificationService().scheduleDailyNotification(
  hour: 18,     // ← Change to 6 PM
  minute: 30,   // ← Change to 30 minutes
  title: '🌙 مساء الخير',
  body: 'وقت المراجعة المسائية!',
);
```

### Change Notification Channel Name
Edit `lib/core/services/notification_service.dart`:

```dart
static const String _channelId = 'my_custom_channel';
static const String _channelName = 'My Custom Notifications';
```

### Disable Update Check
Edit `lib/app.dart`:

```dart
// Comment out this line
// _checkForUpdates();
```

---

## 📊 Monitoring & Analytics

### View FCM Statistics
1. Firebase Console > Cloud Messaging
2. Click on "Reports"
3. View:
   - Delivery rate
   - Open rate
   - Conversion

### View Remote Config Usage
1. Firebase Console > Remote Config
2. Click on "Analytics"
3. View fetch counts and success rates

---

## 🐛 Troubleshooting

### Problem: No FCM Token
**Solution**: 
- Check internet connection
- Verify `google-services.json` exists in `android/app/`
- Verify Firebase is initialized in `main.dart`

### Problem: Notifications Not Appearing
**Solution**:
- Check notification permissions in device settings
- Disable battery optimization for the app
- Check Do Not Disturb mode

### Problem: Update Dialog Not Showing
**Solution**:
- Verify Remote Config is published
- Check internet connection
- Restart the app
- Check console for errors

### Problem: Daily Notification Not Repeating
**Solution**:
- Ensure `SCHEDULE_EXACT_ALARM` permission in AndroidManifest.xml
- Check device battery settings
- Re-schedule the notification

---

## 📞 Send Notifications from Backend

### Using cURL
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
    "priority": "high"
  }'
```

### Using Node.js
```javascript
const admin = require('firebase-admin');

admin.messaging().send({
  token: 'DEVICE_FCM_TOKEN',
  notification: {
    title: 'مرحباً',
    body: 'رسالة جديدة من طمأنينة',
  },
  android: {
    priority: 'high',
  },
});
```

---

## ✅ Checklist

Before going to production:

- [ ] Test FCM on real Android device
- [ ] Test FCM on real iOS device
- [ ] Test local notifications on both platforms
- [ ] Configure Remote Config with real values
- [ ] Update Play Store URL
- [ ] Update App Store URL
- [ ] Test update dialog
- [ ] Test force update mode
- [ ] Set up backend notification sending
- [ ] Configure notification icons
- [ ] Test notification sounds
- [ ] Test background message handling
- [ ] Test notification click actions
- [ ] Document notification payload structure

---

## 🎯 Key Files Modified

| File | Status | Purpose |
|------|--------|---------|
| `pubspec.yaml` | ✅ Modified | Added dependencies |
| `lib/main.dart` | ✅ Modified | Initialize services |
| `lib/app.dart` | ✅ Modified | Trigger update check |
| `lib/firebase_options.dart` | ✅ Fixed | Fix macOS error |
| `lib/core/services/notification_service.dart` | ✅ Created | FCM & Local notifications |
| `lib/core/services/app_update_service.dart` | ✅ Created | Update checker |
| `android/app/src/main/AndroidManifest.xml` | ✅ Modified | Permissions & config |
| `ios/Runner/Info.plist` | ✅ Modified | Background modes |

---

## 📚 Documentation Files

- `NOTIFICATIONS_SETUP.md` - Detailed setup guide
- `IMPLEMENTATION_SUMMARY.md` - What was implemented
- `QUICK_START.md` - This file

---

## 🎉 You're All Set!

The notification system is fully implemented and ready to use. Just:
1. Configure Remote Config ✅
2. Test on device ✅
3. Send test notifications ✅
4. Enjoy! 🎊

---

**Created**: November 11, 2025  
**Project**: Tamanina - طمأنينة  
**Status**: ✅ READY TO USE
