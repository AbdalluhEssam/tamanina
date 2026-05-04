# تمانينة - Tamanina

A comprehensive Islamic companion app built with Flutter, providing prayer times, Quran, Azkar, Qibla direction, and more.

Created By **Abdalluh Essam** 🇪🇬  
📧 abdallhesam100@gmail.com

---

## 📱 Features

### 🕌 Prayer Times
- **Offline Calculation**: Uses the `adhan` package for accurate prayer time calculation
- **Multiple Calculation Methods**: Supports 12+ methods including:
  - رابطة العالم الإسلامي (Muslim World League)
  - أم القرى (Umm al-Qura)
  - الهيئة المصرية للمساحة (Egyptian)
  - ISNA (North America)
  - And more...
- **Madhab Selection**: Shafi or Hanafi for Asr time
- **Location Detection**: GPS-based with manual city selection fallback
- **Live Countdown**: Real-time countdown to next prayer

### 📖 Quran
- Paginated Mushaf view
- Surah and Juz index
- Verse search capability
- Bookmarking support
- Resume from last read position

### 📿 Azkar (أذكار)
- Morning and evening adhkar
- Various dhikr categories
- Counter functionality
- Favorites system

### 🧭 Qibla Direction
- Compass-based direction finding
- Distance to Kaaba calculation
- Works offline

### 🔔 Notifications
- Prayer time reminders with per-prayer toggle
- Pre-prayer reminders (5, 10, 15, 30 minutes)
- Adhan playback support (Makkah, Madinah, Al-Aqsa, Egypt)
- Do Not Disturb override capability
- Customizable volume control
- Auto-reschedule on boot

### ⚙️ Settings (Enhanced)
- **Theme Management**: Light/Dark/System modes with real-time app-wide updates
- **Prayer Calculation**: 10+ methods including Muslim World League, Umm al-Qura, ISNA
- **Madhab Selection**: Shafi/Hanafi for Asr calculation
- **Notification Controls**: 
  - Global enable/disable
  - Per-prayer toggles (Fajr, Dhuhr, Asr, Maghrib, Isha)
  - Pre-prayer reminder timing
- **Muadhin Mode**: Full adhan playback at prayer time
- **Adhan Selection**: Choose from multiple mu'adhin recordings
- **Volume Control**: Dedicated adhan volume slider
- **Vibration**: Haptic feedback toggle
- **Reset to Defaults**: One-tap settings reset

---

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
- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
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
