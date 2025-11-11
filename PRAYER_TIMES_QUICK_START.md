# Prayer Times - Quick Start Guide

## 🚀 Getting Started

### 1. Build and Run
```bash
flutter clean
flutter pub get
flutter run
```

### 2. Navigate to Prayer Times
Add a button or menu item that calls:
```dart
NavigationService.goToPrayerTimes();
```

### 3. Test the Feature
- Open the prayer times screen
- Grant location permission when prompted
- Verify prayer times are displayed
- Check that notifications are scheduled

---

## 📱 Usage Examples

### Navigate from Home Screen
```dart
ElevatedButton(
  onPressed: () => NavigationService.goToPrayerTimes(),
  child: Text('مواقيت الصلاة'),
)
```

### Navigate with Context
```dart
Navigator.pushNamed(context, AppRoutes.prayerTimes);
```

### Navigate from Menu
```dart
ListTile(
  leading: Icon(Icons.schedule),
  title: Text('مواقيت الصلاة'),
  onTap: () => NavigationService.goToPrayerTimes(),
)
```

---

## 🔔 Testing Notifications

### Enable Notifications
1. Grant notification permission when prompted
2. Grant exact alarm permission (Android 12+)
3. Keep the app open until prayer times load
4. Close the app
5. Wait for scheduled notification (5 min before prayer)

### Test Notification Immediately
To test without waiting, modify the notification time in `prayer_times_cubit.dart`:
```dart
// Change from 5 minutes to 1 minute for testing
final notificationTime = prayerDateTime.subtract(const Duration(minutes: 1));
```

---

## 📍 Location Setup

### Option 1: Use GPS (Recommended)
1. Grant location permission
2. App will auto-detect your location
3. Prayer times will be calculated for your area

### Option 2: Manual City Selection
Currently loads from cache with default:
- Default City: Makkah
- Default Country: Saudi Arabia

To add city selection UI, extend the screen with a settings dialog.

---

## 🎨 Customization

### Change Default Location
In `prayer_times_repository.dart`:
```dart
Map<String, String> getCachedLocation() {
  return {
    'city': _prefs.getString(_cachedCityKey) ?? 'Your City',
    'country': _prefs.getString(_cachedCountryKey) ?? 'Your Country',
  };
}
```

### Change Notification Timing
In `prayer_times_cubit.dart`:
```dart
// Default: 5 minutes before
final notificationTime = prayerDateTime.subtract(const Duration(minutes: 5));

// Change to 10 minutes before:
final notificationTime = prayerDateTime.subtract(const Duration(minutes: 10));
```

### Change Calculation Method
In `prayer_times_service.dart`:
```dart
// Current: Method 4 (Umm al-Qura)
int method = 4,

// Other options:
// 1 = University of Islamic Sciences, Karachi
// 2 = Islamic Society of North America
// 3 = Muslim World League
// 5 = Egyptian General Authority of Survey
```

### Add Custom Notification Sound
1. Add your sound file to `android/app/src/main/res/raw/azan.mp3`
2. Add to `ios/Runner/azan.mp3`
3. It's already configured in the code!

---

## 🐛 Troubleshooting

### Prayer Times Not Loading
**Check:**
- Internet connection
- API endpoint accessible: https://api.aladhan.com/v1/timingsByCity?city=Makkah&country=Saudi%20Arabia&method=4
- Flutter logs for errors

**Solution:**
- Cached data will be used if available
- Pull down to refresh once connected

### Notifications Not Appearing
**Check:**
- Notification permission granted
- Exact alarm permission granted (Android 12+)
- Prayer times have been loaded at least once

**Solution:**
```dart
// Request permissions manually
await Permission.notification.request();
```

### Location Permission Denied
**Check:**
- Permission in Android manifest
- Permission in iOS Info.plist
- Runtime permission prompt

**Solution:**
- App will use default location (Makkah)
- Or allow user to select city manually

---

## 📊 Monitoring

### Check Scheduled Notifications (Debug)
Add to your debug screen:
```dart
FutureBuilder(
  future: FlutterLocalNotificationsPlugin()
      .pendingNotificationRequests(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Text('Scheduled: ${snapshot.data!.length}');
    }
    return CircularProgressIndicator();
  },
)
```

### Check Cache Status
```dart
final prefs = await SharedPreferences.getInstance();
final cached = prefs.getString('cached_prayer_times');
print('Cached: ${cached != null}');
```

---

## 🎯 Integration Points

### Add to Home Screen
```dart
// In your home screen widgets list:
Card(
  child: ListTile(
    leading: Icon(Icons.access_time, color: AppColors.primaryGreen),
    title: Text('مواقيت الصلاة'),
    subtitle: Text('عرض أوقات الصلاة اليومية'),
    trailing: Icon(Icons.arrow_forward_ios),
    onTap: () => NavigationService.goToPrayerTimes(),
  ),
)
```

### Add to Drawer Menu
```dart
ListTile(
  leading: Icon(Icons.schedule),
  title: Text('مواقيت الصلاة'),
  onTap: () {
    Navigator.pop(context); // Close drawer
    NavigationService.goToPrayerTimes();
  },
)
```

### Add to Bottom Navigation
```dart
BottomNavigationBarItem(
  icon: Icon(Icons.access_time),
  label: 'الصلاة',
)
```

---

## ✅ Testing Checklist

- [ ] App builds without errors
- [ ] Can navigate to prayer times screen
- [ ] Loading indicator shows
- [ ] Prayer times display correctly
- [ ] Dates show in Hijri and Gregorian
- [ ] Next prayer is highlighted
- [ ] Countdown timer updates
- [ ] Pull-to-refresh works
- [ ] Dark mode looks good
- [ ] Light mode looks good
- [ ] Location permission flow works
- [ ] Notifications schedule successfully
- [ ] Cache persists after app restart

---

## 🎉 You're Ready!

The Prayer Times feature is fully integrated and ready to use. Simply navigate to it using:

```dart
NavigationService.goToPrayerTimes();
```

For questions or issues, refer to the main documentation at:
`lib/features/prayer_times/README.md`

**جزاك الله خيراً**
