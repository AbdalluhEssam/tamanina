# Prayer Times Feature (مواقيت الصلاة)

## Overview
A complete prayer times feature for the Tamanina app that provides accurate prayer schedules with notifications, following Islamic design principles and the app's existing architecture.

## Features ✨

### Core Functionality
- ✅ **Fetch Prayer Times** - Get accurate prayer times from Aladhan API
- ✅ **Location Support** - Automatic prayer times based on GPS location
- ✅ **Manual Location** - Choose city and country manually
- ✅ **Local Caching** - Offline support with SharedPreferences
- ✅ **Prayer Notifications** - Scheduled notifications 5 minutes before each prayer
- ✅ **Hijri & Gregorian Dates** - Display both calendar systems
- ✅ **Next Prayer Countdown** - Real-time countdown to next prayer
- ✅ **Dark/Light Mode** - Full theme support

### Prayer Times Displayed
1. 🌅 **Fajr** (الفجر) - Dawn Prayer
2. ☀️ **Dhuhr** (الظهر) - Noon Prayer  
3. 🌤️ **Asr** (العصر) - Afternoon Prayer
4. 🌇 **Maghrib** (المغرب) - Sunset Prayer
5. 🌙 **Isha** (العشاء) - Night Prayer

## Architecture 🏗️

### Folder Structure
```
lib/features/prayer_times/
├── data/
│   ├── model/
│   │   └── prayer_time_model.dart      # Prayer times data model
│   ├── repo/
│   │   └── prayer_times_repository.dart # Data layer with caching
│   └── services/
│       └── prayer_times_service.dart    # API service (Aladhan)
│
├── ui/
│   ├── cubit/
│   │   ├── prayer_times_cubit.dart      # State management
│   │   └── prayer_times_state.dart      # State definitions
│   ├── screens/
│   │   └── prayer_times_screen.dart     # Main UI screen
│   └── widgets/
│       └── prayer_card.dart             # Individual prayer card widget
│
└── prayer_times.dart                     # Feature barrel file
```

## Navigation 🧭

### Route
- Route Name: `/prayer-times`
- Constant: `AppRoutes.prayerTimes`

### Navigate to Prayer Times
```dart
// Using NavigationService
NavigationService.goToPrayerTimes();

// Or using route name
Navigator.pushNamed(context, AppRoutes.prayerTimes);
```

## API Integration 🌐

### Aladhan API
- Base URL: `https://api.aladhan.com/v1`
- Method: Umm al-Qura University, Makkah (Method 4)

### Endpoints Used
1. **By City**: `GET /timingsByCity?city={city}&country={country}&method=4`
2. **By Coordinates**: `GET /timings?latitude={lat}&longitude={lng}&method=4`

## State Management 🔄

### States
- `PrayerTimesInitial` - Initial state
- `PrayerTimesLoading` - Loading prayer times
- `PrayerTimesLoaded` - Successfully loaded with data
- `PrayerTimesError` - Error occurred
- `PrayerTimesLocationDenied` - Location permission denied

### Cubit Methods
```dart
// Load prayer times by location
await context.read<PrayerTimesCubit>().loadPrayerTimesByLocation();

// Load by city
await context.read<PrayerTimesCubit>().loadPrayerTimes(
  city: 'Makkah',
  country: 'Saudi Arabia',
);

// Refresh prayer times
await context.read<PrayerTimesCubit>().refreshPrayerTimes();
```

## Notifications 🔔

### Features
- Notifications scheduled 5 minutes before each prayer
- Persist through app restarts
- Work when app is closed
- Custom Islamic notification sound support
- Vibration enabled

### Notification Format
```
Title: 🕌 اقترب وقت صلاة الفجر
Body: باقي 5 دقائق على صلاة الفجر - الوقت: 05:07
```

### Permissions Required

#### Android (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### iOS (`Info.plist`)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>نحتاج إلى موقعك لتحديد أوقات الصلاة الدقيقة لمنطقتك</string>
```

## Caching Strategy 💾

### SharedPreferences Keys
- `cached_prayer_times` - Prayer times JSON data
- `cached_prayer_times_date` - Cache timestamp
- `cached_city` - Last used city
- `cached_country` - Last used country

### Cache Validity
- Cache expires daily (midnight)
- Auto-refresh on new day
- Fallback to cache on network error

## UI Components 🎨

### PrayerTimesScreen
Main screen displaying:
- Hijri and Gregorian dates
- Next prayer countdown timer
- List of all 5 daily prayers
- Pull-to-refresh functionality
- Location display

### PrayerCard
Individual prayer display card showing:
- Prayer name in Arabic
- Prayer emoji icon
- Prayer time
- Highlight for next prayer
- Color-coded by prayer time

### Colors
Each prayer has a unique color:
- Fajr: Soft Indigo (Dawn)
- Dhuhr: Warm Yellow (Noon)
- Asr: Soft Orange (Afternoon)
- Maghrib: Warm Orange-Red (Sunset)
- Isha: Deep Purple (Night)

## Testing 🧪

### Manual Testing Checklist
- [ ] Prayer times load correctly
- [ ] Location permission works
- [ ] Manual city selection works
- [ ] Cache persists after app restart
- [ ] Notifications schedule correctly
- [ ] Countdown timer updates
- [ ] Dark mode displays correctly
- [ ] Light mode displays correctly
- [ ] Pull-to-refresh works
- [ ] Error states display properly

## Dependencies 📦

```yaml
dependencies:
  flutter_bloc: # State management
  equatable: # Value equality
  dio: # HTTP client
  shared_preferences: # Local storage
  flutter_local_notifications: # Notifications
  timezone: # Timezone support
  geolocator: # Location services
  permission_handler: # Permission management
  flutter_screenutil: # Responsive UI
  animate_do: # Animations
```

## Future Enhancements 🚀

- [ ] Qibla direction indicator
- [ ] Prayer time calculation methods selection
- [ ] Custom notification sounds
- [ ] Prayer completion tracking
- [ ] Monthly prayer times calendar
- [ ] Widget for home screen
- [ ] Apple Watch / WearOS support

## Troubleshooting 🔧

### Notifications Not Working
1. Check permissions are granted
2. Verify timezone initialization
3. Ensure exact alarm permission (Android 12+)
4. Check notification channel setup

### Location Not Working
1. Request location permission
2. Enable GPS on device
3. Check network connectivity for API
4. Verify AndroidManifest.xml permissions

### API Errors
1. Check internet connection
2. Verify API endpoint is accessible
3. Review API rate limits
4. Check cached data as fallback

## Credits 📚

- **API**: [Aladhan Prayer Times API](https://aladhan.com/prayer-times-api)
- **Design**: Following Tamanina app's Islamic soft color palette
- **Architecture**: Clean Architecture with BLoC pattern

---

**Made with ❤️ for the Muslim community**
