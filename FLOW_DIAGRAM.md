# 🔄 Notification Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         APP STARTUP FLOW                                 │
└─────────────────────────────────────────────────────────────────────────┘

main.dart
   │
   ├─► Firebase.initializeApp() ────────────────► ✅ Firebase Ready
   │
   ├─► timezone.initializeTimeZones() ──────────► ✅ Timezone Ready
   │
   ├─► FirebaseMessaging.onBackgroundMessage() ─► ✅ Background Handler
   │
   ├─► NotificationService().initialize()
   │   │
   │   ├─► Request Permissions ──────────────────► 🔔 Android/iOS
   │   ├─► Initialize Local Notifications ──────► 📱 Flutter Local
   │   ├─► Initialize FCM ─────────────────────► 🔑 Get Token
   │   └─► Setup Message Handlers ─────────────► 📬 Listeners
   │
   ├─► AppUpdateService().initialize() ─────────► ⚙️ Remote Config
   │
   ├─► NotificationService().scheduleDailyNotification()
   │   └─► Schedule 9:00 AM notification ───────► ⏰ Daily Reminder
   │
   └─► runApp() ─────────────────────────────────► 🚀 App Starts


┌─────────────────────────────────────────────────────────────────────────┐
│                      NOTIFICATION SCENARIOS                              │
└─────────────────────────────────────────────────────────────────────────┘

SCENARIO 1: App is OPEN (Foreground)
─────────────────────────────────────
FCM Server → Firebase → onMessage
                          │
                          ▼
              _showLocalNotification()
                          │
                          ▼
              FlutterLocalNotifications
                          │
                          ▼
                   📱 User sees notification


SCENARIO 2: App is BACKGROUNDED
─────────────────────────────────
FCM Server → Firebase → System Tray
                          │
                          ▼
              User taps notification
                          │
                          ▼
                  onMessageOpenedApp
                          │
                          ▼
              _handleNotificationTap()
                          │
                          ▼
                Navigate to screen


SCENARIO 3: App is KILLED (Terminated)
──────────────────────────────────────
FCM Server → Firebase → System Tray
                          │
                          ▼
              User taps notification
                          │
                          ▼
                 App starts + getInitialMessage()
                          │
                          ▼
              _handleNotificationTap()
                          │
                          ▼
                Navigate to screen


SCENARIO 4: Daily Local Notification
─────────────────────────────────────
scheduleDailyNotification()
         │
         ▼
  _nextInstanceOfTime(9, 0)
         │
         ▼
  zonedSchedule() with repeat
         │
         ▼
  Every day at 9:00 AM
         │
         ▼
  📱 Notification appears
         │
         ▼
  User taps → onDidReceiveNotificationResponse
         │
         ▼
  _handleNotificationTap()


┌─────────────────────────────────────────────────────────────────────────┐
│                      UPDATE CHECK FLOW                                   │
└─────────────────────────────────────────────────────────────────────────┘

App Starts (app.dart)
       │
       ▼
initState()
       │
       ▼
WidgetsBinding.instance.addPostFrameCallback()
       │
       ▼
Wait 2 seconds (app loads)
       │
       ▼
AppUpdateService().checkForUpdates()
       │
       ├─► Get current version from PackageInfo
       │
       ├─► Get latest version from Remote Config
       │
       ├─► Compare versions
       │
       └─► If update available:
           │
           ▼
      _showUpdateDialog()
           │
           ├─► Show title & message
           │
           ├─► Show "Later" button (if not force update)
           │
           ├─► Show "Update Now" button
           │
           └─► User taps "Update Now"
               │
               ▼
          _openStore()
               │
               ▼
          Play Store / App Store


┌─────────────────────────────────────────────────────────────────────────┐
│                      SERVICE ARCHITECTURE                                │
└─────────────────────────────────────────────────────────────────────────┘

NotificationService (Singleton)
├── FirebaseMessaging instance
├── FlutterLocalNotificationsPlugin instance
│
├── Methods:
│   ├── initialize()
│   ├── scheduleDailyNotification()
│   ├── getFCMToken()
│   ├── subscribeToTopic()
│   ├── unsubscribeFromTopic()
│   └── cancelAllNotifications()
│
└── Private Methods:
    ├── _requestPermissions()
    ├── _initializeLocalNotifications()
    ├── _initializeFCM()
    ├── _setupMessageHandlers()
    ├── _showLocalNotification()
    ├── _handleNotificationTap()
    └── _nextInstanceOfTime()


AppUpdateService (Singleton)
├── FirebaseRemoteConfig instance
│
├── Methods:
│   ├── initialize()
│   ├── checkForUpdates()
│   ├── manualCheckForUpdates()
│   ├── getConfigValue()
│   ├── getConfigBool()
│   └── getConfigInt()
│
└── Private Methods:
    ├── _isUpdateAvailable()
    ├── _showUpdateDialog()
    └── _openStore()


┌─────────────────────────────────────────────────────────────────────────┐
│                      PERMISSION FLOW                                     │
└─────────────────────────────────────────────────────────────────────────┘

ANDROID:
  AndroidManifest.xml permissions
         │
         ▼
  Runtime permission request (Android 13+)
         │
         ▼
  NotificationManager.areNotificationsEnabled()
         │
         ▼
  ✅ Allowed / ❌ Denied


iOS:
  Info.plist configuration
         │
         ▼
  UNUserNotificationCenter.requestAuthorization()
         │
         ▼
  User prompt: Allow / Don't Allow
         │
         ▼
  ✅ Allowed / ❌ Denied


┌─────────────────────────────────────────────────────────────────────────┐
│                      DATA FLOW                                           │
└─────────────────────────────────────────────────────────────────────────┘

Firebase Console
       │
       ├─► Cloud Messaging
       │   │
       │   ├─► Send to Device (FCM Token)
       │   │        │
       │   │        ▼
       │   │   📱 App receives
       │   │
       │   └─► Send to Topic
       │            │
       │            ▼
       │   📱 All subscribed devices receive
       │
       └─► Remote Config
           │
           ├─► latest_version_android
           ├─► latest_version_ios
           ├─► force_update
           ├─► update_message_ar
           ├─► update_message_en
           ├─► play_store_url
           └─► app_store_url
                    │
                    ▼
           AppUpdateService fetches
                    │
                    ▼
           Compare with current version
                    │
                    ▼
           Show update dialog if needed


┌─────────────────────────────────────────────────────────────────────────┐
│                      FILE STRUCTURE                                      │
└─────────────────────────────────────────────────────────────────────────┘

lib/
├── main.dart ──────────────────────────► Entry point, initialization
├── app.dart ───────────────────────────► App widget, update check
├── firebase_options.dart ──────────────► Firebase configuration
│
├── core/
│   ├── services/
│   │   ├── notification_service.dart ──► FCM & Local Notifications
│   │   └── app_update_service.dart ────► Update checker
│   │
│   └── testing/
│       └── notification_test_screen.dart → Test UI
│
android/
├── app/
│   └── src/
│       └── main/
│           └── AndroidManifest.xml ────► Permissions & config
│
ios/
└── Runner/
    └── Info.plist ─────────────────────► iOS configuration


┌─────────────────────────────────────────────────────────────────────────┐
│                      TESTING WORKFLOW                                    │
└─────────────────────────────────────────────────────────────────────────┘

1. Development Testing
   └─► flutter run
       └─► Check console for ✅ initialization logs
           └─► Copy FCM token
               └─► Send test from Firebase Console

2. Local Notification Testing
   └─► Schedule test notification (1 min)
       └─► Close app
           └─► Wait 1 minute
               └─► Notification appears

3. Update Dialog Testing
   └─► Firebase Console → Remote Config
       └─► Change latest_version to "2.0.0"
           └─► Publish changes
               └─► Restart app
                   └─► Dialog appears after 2 seconds

4. Topic Testing
   └─► Subscribe to topic
       └─► Send message to topic from Firebase Console
           └─► All subscribed devices receive

5. Production Testing
   └─► flutter build apk --release
       └─► Install on device
           └─► Test all scenarios
               └─► Monitor analytics in Firebase


┌─────────────────────────────────────────────────────────────────────────┐
│                      ERROR HANDLING                                      │
└─────────────────────────────────────────────────────────────────────────┘

All services use try-catch blocks:

try {
  // Operation
  print('✅ Success');
} catch (e) {
  if (kDebugMode) {
    print('❌ Error: $e');
  }
}

Look for emoji prefixes in logs:
✅ = Success
❌ = Error
🔔 = Permission
⏰ = Scheduled
📬 = Message received
etc.


┌─────────────────────────────────────────────────────────────────────────┐
│                      BACKEND INTEGRATION                                 │
└─────────────────────────────────────────────────────────────────────────┘

Your Backend Server
       │
       ├─► Store FCM tokens in database
       │   (when user logs in or opens app)
       │
       ├─► Send notification via FCM API
       │   │
       │   ├─► To specific user (use FCM token)
       │   │        │
       │   │        ▼
       │   │   POST https://fcm.googleapis.com/fcm/send
       │   │   Header: Authorization: key=SERVER_KEY
       │   │   Body: { to: "FCM_TOKEN", notification: {...} }
       │   │
       │   └─► To topic (broadcast)
       │            │
       │            ▼
       │   POST https://fcm.googleapis.com/fcm/send
       │   Body: { to: "/topics/TOPIC_NAME", notification: {...} }
       │
       └─► Update Remote Config values
           (to trigger update dialogs)


═══════════════════════════════════════════════════════════════════════════
                           END OF FLOW DIAGRAM
═══════════════════════════════════════════════════════════════════════════
```

## 🎨 Visual Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Success / Ready |
| ❌ | Error / Denied |
| 🔔 | Permissions |
| 📱 | Mobile Device |
| 🔑 | Token |
| ⏰ | Scheduled |
| 📬 | Foreground Message |
| 📭 | Background Message |
| 📪 | Terminated Message |
| 🔄 | Refresh |
| ⚙️ | Configuration |
| 🚀 | Launch |
| 📌 | Topic |
| 🧪 | Test |

## 📖 How to Read This Diagram

1. **Start from top**: Follow the flow from `main.dart`
2. **Branch paths**: Shows different scenarios
3. **Arrows (→)**: Indicate flow direction
4. **Boxes**: Major components
5. **Indentation**: Shows hierarchy

## 🎯 Quick Reference

- **Initialization**: Check "APP STARTUP FLOW"
- **How notifications work**: Check "NOTIFICATION SCENARIOS"
- **Update process**: Check "UPDATE CHECK FLOW"
- **File locations**: Check "FILE STRUCTURE"
- **Testing steps**: Check "TESTING WORKFLOW"

---

**Created**: November 11, 2025
**Project**: Tamanina - طمأنينة
