# طمأنينة - Tamanina

A comprehensive Islamic companion app built with Flutter, providing prayer times, Quran, Azkar, Qibla direction, and more.

Created By **Abdalluh Essam** 🇪🇬  
📧 abdallhesam100@gmail.com

---

For store metadata, signing, and release builds, see the [production release guide](PRODUCTION_RELEASE.md).

## Features

- Read the full offline Quran in the standard 604-page order. The reader includes surah and juz indexes, verse search, bookmarks, and reading history. Download a page's recitation once for offline playback. Recitation can continue with the screen locked and is controllable from the system media controls.
- Count tasbeeh, complete adhkar collections, and view your activity. Your progress and favorites are stored on the device.
- Calculate prayer times and a Qibla bearing on the device using GPS or a selected city. Live direction depends on the device's compass.
- Enable device notifications for prayer and adhkar alerts. Set morning, evening, bedtime, and Friday reminders, or choose daytime dhikr every one to four hours. Quiet hours mute prayer alerts and pause dhikr reminders. The app prepares up to 30 days of prayer times on the device. Android schedules them locally and plays the full bundled adhan with exact alarm access. iOS schedules the nearest alerts within its pending-notification limit and refills from the saved plan when iOS permits background refresh. Its short adhan alert opens the full recording when tapped.
- Use the Tamanina assistant to find verses and get help with the app offline. Enable on-device AI for open-ended questions after downloading its model.
- The interface supports Arabic and English, system theme, larger system text, phone and tablet navigation, and native Android and iOS app icons.

The offline adhan recording is credited in [assets/audio/adhan/README.md](assets/audio/adhan/README.md).

## AI assistant

Open the phone icon in the assistant to download the [Qwen2.5 0.5B model](https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF) (491 MB). Tamanina verifies the model's SHA-256 checksum before making it available. The downloaded model processes questions on the device and can be removed from the same screen. Responses are general guidance. Quran verse search uses the bundled text.

Android builds use SDK CMake 3.31.6 for the local inference plugin. The optional test in `integration_test/local_assistant_smoke_test.dart` needs a simulator with the model already installed and `--dart-define=VERIFY_ON_DEVICE_ASSISTANT=true`. Use a dedicated simulator for this test because the Flutter test runner removes the test app and its local data.

An HTTPS assistant service can also be configured for builds where the on-device model has not been installed.

Run the Node 22+ service with `GROQ_API_KEY` set in the server environment and `node server/guide.mjs`. The service listens on `127.0.0.1:8080` by default and supports `PORT` and `GROQ_MODEL`. Publish `POST /guide` through your HTTPS reverse proxy with request rate limits, then build Flutter with `--dart-define=TAMANINA_GUIDE_URL=https://your-server.example/guide`. The request contains `message`, `language`, `model`, and up to six recent `history` turns. The endpoint returns `{"answer":"..."}`. The service chooses the model on the server and holds the provider key there.

## Updates and Home Screen widgets

- **Updates** — Tamanina checks the stores with `new_version_plus` from Settings and at most once per day after the home screen opens. A published store listing is required. The iOS lookup defaults to Egypt. Build overrides are `TAMANINA_IOS_STORE_BUNDLE_ID`, `TAMANINA_ANDROID_STORE_PACKAGE`, and `TAMANINA_STORE_COUNTRY` (iOS lookup region).
- **Android** — Add Tamanina via Settings → Home-screen widgets, or from the launcher’s widget list. Tap the Dhikr or Prayer button to switch, and tap the content to open its screen. Exact prayer-alert timing can be enabled separately under Notifications.
- **iOS** — Add Tamanina Prayer or Tamanina Dhikr in the Home Screen widget gallery. Both support small and medium sizes and can be stacked. For device and distribution builds, provision the App Group `group.com.abdalluh.tamanina` for both Runner and the `com.abdalluh.tamanina.Widgets` extension in the same Apple Developer team.
- Widget prayer data is calculated on the device and shared for the next 35 days. Open Tamanina after selecting a city or if the widget asks to refresh. The system may adjust the exact timing of Home Screen refreshes.

## 🏗️ Architecture

This project follows **Clean Architecture** with the BLoC pattern:

```
lib/
├── core/
│   ├── constants/      # App constants and route names
│   ├── cubit/          # Global cubits (theme, locale)
│   ├── extensions/     # Dart extensions
│   ├── routing/        # App router configuration
│   ├── services/       # Core services (prayer, location, notifications)
│   ├── settings/       # Settings repository and cubit
│   ├── theme/          # Colors, typography, dimensions
│   └── utils/          # Utility classes
├── features/
│   ├── adhkar/         # Azkar feature
│   ├── chatbot/        # AI assistant
│   ├── home/           # Home screen with prayer times
│   ├── onboarding/     # First-time user onboarding
│   ├── prayer_times/   # Prayer times detail
│   ├── qibla/          # Qibla compass
│   ├── quran/          # Quran reader
│   ├── settings/       # App settings
│   ├── splash/         # Splash screen
│   └── tasbeeh/        # Digital tasbih counter
├── app.dart            # App widget
├── main.dart           # Entry point
└── app_bloc_observer.dart
```

### Settings Architecture

The settings module uses a reactive architecture:

```
SettingsRepository (Hive persistence)
        ↓
    Stream<AppSettings>
        ↓
SettingsCubit (State Management)
        ↓
    SettingsState
        ↓
ProductionSettingsScreen (UI)
```

**Key Files:**
- `lib/core/settings/settings_repository.dart` - Persistence layer with Hive
- `lib/core/settings/settings_cubit.dart` - BLoC state management
- `lib/core/services/prayer_service_enhanced.dart` - Prayer calculations with settings integration
- `lib/core/services/notification_service_enhanced.dart` - Notification scheduling with adhan

---

## 🚀 Getting Started

### Prerequisites
- Flutter and Dart SDKs compatible with the lockfile. Verified tooling uses Flutter 3.47.2.
- JDK 17 for Android and Xcode with CocoaPods for iOS. The iOS deployment target is 15.0.
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/tamanina.git
cd tamanina
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Setup Firebase** (Optional but recommended)
- Create a Firebase project
- Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Place them in the respective directories

4. **Run the app**
```bash
flutter run
```

---

## 📋 Permissions Required

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<!-- Location for prayer times -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<!-- Notifications and Alarms -->
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Adhan playback over DND -->
<uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY"/>

<!-- Wake device for adhan -->
<uses-permission android:name="android.permission.WAKE_LOCK"/>

<!-- Foreground service for adhan playback -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to calculate accurate prayer times</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to provide prayer time notifications</string>
```

---

## 🧪 Testing

### Run all tests
```bash
flutter test
```

### Run specific test files
```bash
# Prayer service tests
flutter test test/services/prayer_service_test.dart

# Widget tests
flutter test test/widgets/home_screen_test.dart
```

### Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management |
| `adhan` | Prayer time calculation |
| `geolocator` | Location services |
| `geocoding` | Reverse geocoding |
| `flutter_compass` | Compass for Qibla |
| `hive_flutter` | Local storage |
| `just_audio` | Adhan playback |
| `flutter_local_notifications` | Prayer notifications |
| `quran_sharif` | Quran data |
| `easy_localization` | Internationalization |
| `firebase_core` | Firebase services |

---

## 🎨 Design System

### Colors
- **Primary Green**: `#2E7D32` - Main brand color
- **Gold Accent**: `#D4AF37` - Islamic decorative elements
- **Background Light**: `#F5F5F5`
- **Background Dark**: `#121212`

### Typography
- Arabic: Custom Arabic typography
- English: Default system fonts

---

## 🔧 Configuration

### Prayer Calculation Methods
Configure in `lib/core/services/prayer_service.dart`:
```dart
enum PrayerCalculationMethod {
  muslimWorldLeague,
  isna,
  egyptian,
  ummAlQura,
  karachi,
  tehran,
  kuwait,
  qatar,
  singapore,
  turkey,
  dubai,
  morocco,
}
```

### Adhan Settings
Configure in `lib/core/services/prayer_notification_service.dart`:
```dart
class AdhanSettings {
  final bool isEnabled;
  final String soundFile;
  final double volume;
  final bool vibrate;
  final bool fullScreenMode;
  final bool respectDND;
}
```

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Adhan Package](https://pub.dev/packages/adhan) for prayer time calculations
- [Quran Sharif](https://pub.dev/packages/quran_sharif) for Quran data
- The Muslim developer community

---

**Made with ❤️ and تقوى**

---

Created By **Abdalluh Essam** 🇪🇬
