# Tamanina App - Quick Developer Reference

## 🚀 Running the App

```bash
# Clean and get dependencies
flutter clean && flutter pub get

# Run on emulator/device
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release

# Run analyzer
flutter analyze

# Format code
flutter format lib
```

---

## 📂 Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Main app widget
├── app_bloc_observer.dart       # Bloc debugging
├── firebase_options.dart        # Firebase config
├── core/                        # Core utilities
│   ├── services/
│   │   ├── service_locator.dart         # Dependency injection ⭐
│   │   ├── notification_service.dart    # Notifications & dhikr
│   │   └── app_update_service.dart      # Update checker
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_theme.dart
│   │   └── app_typography.dart
│   └── routing/
│       └── app_router.dart
└── features/                    # Feature modules
    ├── adhkar/                  # ✅ Offline (JSON)
    ├── quran/                   # ✅ Offline (package)
    ├── tasbeeh/                 # ✅ Offline (local)
    ├── chatbot/                 # 🌐 Online + offline fallback
    ├── home/                    # ✅ UI only
    ├── settings/                # ✅ Local preferences
    ├── splash/                  # ✅ Initial screen
    └── onboarding/              # ✅ First-time setup
```

---

## 🎯 Adding a New Feature

### 1. Create Feature Structure
```bash
mkdir -p lib/features/my_feature/data/models
mkdir -p lib/features/my_feature/data/repo
mkdir -p lib/features/my_feature/ui/cubit
mkdir -p lib/features/my_feature/ui/screens
mkdir -p lib/features/my_feature/ui/widgets
```

### 2. Create Export File
**File**: `lib/features/my_feature/my_feature.dart`
```dart
/// My Feature
///
/// Description of what this feature does

// Export models
export 'data/models/my_model.dart';

// Export repositories (if needed)
export 'data/repo/my_repository.dart';

// Export UI
export 'ui/cubit/my_cubit.dart';
export 'ui/screens/my_screen.dart';
```

### 3. Implement Data Layer (if needed)

**Model** (`data/models/my_model.dart`):
```dart
import 'package:equatable/equatable.dart';

class MyModel extends Equatable {
  final int id;
  final String title;
  
  const MyModel({required this.id, required this.title});
  
  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
  
  @override
  List<Object?> get props => [id, title];
}
```

**Repository Interface** (`data/repo/my_repository.dart`):
```dart
abstract class MyRepository {
  Future<List<MyModel>> fetchData();
}
```

**Repository Implementation** (`data/repo/my_repository_impl.dart`):
```dart
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyRepositoryImpl implements MyRepository {
  final SharedPreferences prefs;
  
  MyRepositoryImpl(this.prefs);
  
  @override
  Future<List<MyModel>> fetchData() async {
    // Offline: Load from local JSON
    final String jsonString = await rootBundle.loadString('assets/data/my_data.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => MyModel.fromJson(json)).toList();
    
    // OR Online: Fetch from API
    // final response = await http.get(Uri.parse('https://api.example.com/data'));
    // if (response.statusCode == 200) {
    //   final List<dynamic> jsonList = json.decode(response.body);
    //   return jsonList.map((json) => MyModel.fromJson(json)).toList();
    // }
  }
}
```

### 4. Implement State Management

**States** (`ui/cubit/my_state.dart`):
```dart
part of 'my_cubit.dart';

abstract class MyState extends Equatable {
  const MyState();
  @override
  List<Object> get props => [];
}

class MyInitial extends MyState {}
class MyLoading extends MyState {}
class MyLoaded extends MyState {
  final List<MyModel> data;
  const MyLoaded(this.data);
  @override
  List<Object> get props => [data];
}
class MyError extends MyState {
  final String message;
  const MyError(this.message);
  @override
  List<Object> get props => [message];
}
```

**Cubit** (`ui/cubit/my_cubit.dart`):
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'my_state.dart';

class MyCubit extends Cubit<MyState> {
  final MyRepository repository;
  
  MyCubit(this.repository) : super(MyInitial());
  
  Future<void> loadData() async {
    emit(MyLoading());
    try {
      final data = await repository.fetchData();
      emit(MyLoaded(data));
    } catch (e) {
      emit(MyError('فشل تحميل البيانات: ${e.toString()}'));
    }
  }
}
```

### 5. Implement UI

**Screen** (`ui/screens/my_screen.dart`):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/service_locator.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../cubit/my_cubit.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<MyCubit>()..loadData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Feature'),
          centerTitle: true,
        ),
        body: BlocBuilder<MyCubit, MyState>(
          builder: (context, state) {
            if (state is MyLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              );
            }
            
            if (state is MyError) {
              return Center(child: Text(state.message));
            }
            
            if (state is MyLoaded) {
              return ListView.builder(
                itemCount: state.data.length,
                itemBuilder: (context, index) {
                  final item = state.data[index];
                  return ListTile(
                    title: Text(item.title),
                  );
                },
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
```

### 6. Register in Service Locator
**File**: `lib/core/services/service_locator.dart`
```dart
// Add import
import '../../features/my_feature/data/repo/my_repository.dart';
import '../../features/my_feature/data/repo/my_repository_impl.dart';
import '../../features/my_feature/ui/cubit/my_cubit.dart';

// In init() function:
// Repository
sl.registerLazySingleton<MyRepository>(
  () => MyRepositoryImpl(sl()),
);

// Cubit
sl.registerFactory(
  () => MyCubit(sl()),
);
```

### 7. Add Navigation
In `lib/features/home/ui/screens/home_screen.dart`:
```dart
// Add import
import '../../../my_feature/ui/screens/my_screen.dart';

// In _navigateToFeature method:
if (feature.id == 'my_feature') {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MyScreen()),
  );
  return;
}
```

---

## 🎨 Theme Usage

### Colors
```dart
import '../../../../core/theme/app_colors.dart';

// Primary colors
AppColors.primaryGreen
AppColors.goldAccent
AppColors.primaryBlue

// Background colors
AppColors.backgroundLight
AppColors.surfaceLight

// Text colors
AppColors.textPrimary
AppColors.textSecondary

// Semantic colors
AppColors.success
AppColors.error
AppColors.warning
AppColors.info

// With opacity (deprecated, but still works)
AppColors.primaryGreen.withOpacity(0.1)
```

### Typography
```dart
import '../../../../core/theme/app_typography.dart';

// Arabic text
AppTypography.bodyLargeArabic
AppTypography.bodyMediumArabic
AppTypography.labelLargeArabic

// Regular text
AppTypography.bodyLarge
AppTypography.bodyMedium
AppTypography.titleLarge
```

### Spacing
```dart
import '../../../../core/theme/app_dimensions.dart';

// Vertical spacing
AppSpacing.verticalSpaceSM
AppSpacing.verticalSpaceMD
AppSpacing.verticalSpaceLG
AppSpacing.verticalSpaceXL

// Horizontal spacing
AppSpacing.horizontalSpaceSM
AppSpacing.horizontalSpaceMD
AppSpacing.horizontalSpaceLG

// Padding
AppSpacing.paddingSM
AppSpacing.paddingMD
AppSpacing.paddingLG

// Border radius
AppRadius.sm
AppRadius.md
AppRadius.lg
```

---

## 📦 Working with Assets

### Adding JSON Data
1. Create JSON file in `assets/data/`
2. Add to `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/data/my_data.json
```
3. Load in code:
```dart
import 'dart:convert';
import 'package:flutter/services.dart';

final String jsonString = await rootBundle.loadString('assets/data/my_data.json');
final data = json.decode(jsonString);
```

### Adding Images
```yaml
flutter:
  assets:
    - assets/images/
```

---

## 🔔 Notifications

### Scheduling a Notification
```dart
import '../../core/services/notification_service.dart';

final notificationService = NotificationService();

// Schedule single notification
await notificationService.scheduleNotification(
  id: 1,
  title: 'Reminder',
  body: 'Time to pray!',
  scheduledTime: DateTime.now().add(Duration(hours: 1)),
);

// Cancel notification
await notificationService.cancelNotification(1);

// Cancel all
await notificationService.cancelAllNotifications();
```

---

## 🌐 Online vs Offline

### Offline-Only Feature (like Adhkar)
✅ **When to use**: Static data, no server needed
```dart
// 1. Store data in assets/data/
// 2. Load with rootBundle.loadString()
// 3. No API calls needed
// 4. Fast, works offline always
```

### Online-Only Feature
🌐 **When to use**: Real-time data, server processing
```dart
import 'package:http/http.dart' as http;

final response = await http.get(Uri.parse('https://api.example.com/data'));
if (response.statusCode == 200) {
  final data = json.decode(response.body);
  // Process data
}
```

### Hybrid Feature
🔄 **When to use**: Online preferred, offline fallback
```dart
try {
  // Try online first
  final response = await http.get(Uri.parse('https://api.example.com/data'));
  final data = json.decode(response.body);
  
  // Cache for offline
  await prefs.setString('cached_data', response.body);
  
  return data;
} catch (e) {
  // Fallback to cached data
  final cached = prefs.getString('cached_data');
  if (cached != null) {
    return json.decode(cached);
  }
  throw Exception('No internet and no cache');
}
```

---

## 🧪 Testing

### Unit Test
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Model fromJson works correctly', () {
    final json = {'id': 1, 'title': 'Test'};
    final model = MyModel.fromJson(json);
    
    expect(model.id, 1);
    expect(model.title, 'Test');
  });
}
```

### Widget Test
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('MyScreen displays title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MyScreen()),
    );
    
    expect(find.text('My Feature'), findsOneWidget);
  });
}
```

---

## 📱 Common Tasks

### Add a New Home Feature Card
1. Edit `lib/features/home/data/repo/home_repository_impl.dart`
2. Add feature to `getHomeFeatures()` list
3. Set `isActive: true` when ready
4. Add navigation in `home_screen.dart`

### Add a Bottom Navigation Item
1. Edit `lib/features/home/ui/widgets/modern_bottom_nav_bar.dart`
2. Add icon and label
3. Update `_buildBody()` in `home_layout.dart`
4. Add corresponding screen

### Change App Theme
1. Edit `lib/core/theme/app_colors.dart` for colors
2. Edit `lib/core/theme/app_theme.dart` for overall theme
3. Hot reload will apply changes

---

## 🐛 Debugging

### Enable Debug Prints
```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  print('Debug message');
}
```

### BLoC Observer
Already configured in `app_bloc_observer.dart`
- Logs all state changes
- Logs all events
- Logs errors

### Flutter DevTools
```bash
flutter run
# Then press 'v' in terminal to open DevTools
```

---

## 📚 Useful Packages

### Currently Installed:
- `flutter_bloc` - State management
- `equatable` - Value equality
- `get_it` - Dependency injection
- `shared_preferences` - Local storage
- `dartz` - Functional programming (Either)
- `firebase_core` - Firebase
- `firebase_messaging` - Push notifications
- `flutter_local_notifications` - Local notifications
- `share_plus` - Social sharing
- `easy_localization` - Internationalization
- `cached_network_image` - Image caching
- `flutter_svg` - SVG support

---

## 🎯 Best Practices

1. **Always use Cubit** (not Bloc) for consistency
2. **Register all dependencies** in service_locator.dart
3. **Follow folder structure** exactly
4. **Use AppColors** instead of hardcoded colors
5. **Support RTL** for Arabic text
6. **Add loading states** for all async operations
7. **Handle errors** gracefully with user-friendly messages
8. **Export features** properly in <feature>.dart
9. **Comment complex logic** in Arabic or English
10. **Test on real devices** before release

---

## 📞 Quick Commands Reference

```bash
# Dependencies
flutter pub get               # Get packages
flutter pub outdated          # Check updates
flutter pub upgrade           # Upgrade packages

# Building
flutter clean                 # Clean build
flutter build apk             # Debug APK
flutter build apk --release   # Release APK
flutter build appbundle       # App Bundle for Play Store

# Analysis
flutter analyze               # Static analysis
flutter format lib            # Format code
flutter doctor                # Check setup

# Running
flutter run                   # Run on connected device
flutter run -d emulator-5554  # Run on specific device
flutter run --release         # Run in release mode

# Testing
flutter test                  # Run all tests
flutter test test/my_test.dart # Run specific test
```

---

**Last Updated**: December 2024  
**App**: Tamanina v1.0.0  
**Flutter**: 3.29.3
