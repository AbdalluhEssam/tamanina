import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../data/model/prayer_time_model.dart';
import '../../data/repo/prayer_times_repository.dart';

part 'prayer_times_state.dart';

/// Cubit لإدارة حالة أوقات الصلاة
/// Prayer Times State Management Cubit
class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  final PrayerTimesRepository _repository;
  final FlutterLocalNotificationsPlugin _notifications;
  Timer? _timer;

  PrayerTimesCubit({
    required PrayerTimesRepository repository,
    required FlutterLocalNotificationsPlugin notifications,
  })  : _repository = repository,
        _notifications = notifications,
        super(const PrayerTimesInitial()) {
    _initializeNotifications();
    _initializeTimezone();
  }

  /// Initialize timezone
  void _initializeTimezone() {
    try {
      tz.initializeTimeZones();
    } catch (e) {
      // Timezone already initialized
    }
  }

  /// Initialize notifications
  Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  /// Load prayer times using location
  /// تحميل أوقات الصلاة باستخدام الموقع
  Future<void> loadPrayerTimesByLocation() async {
    emit(const PrayerTimesLoading());

    try {
      // Check location permission
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        emit(const PrayerTimesLocationDenied());
        // Load with default location
        await loadPrayerTimes();
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // Fetch prayer times
      final prayerTimes = await _repository.getPrayerTimesByLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Schedule notifications
      await _schedulePrayerNotifications(prayerTimes);

      // Calculate next prayer
      final nextPrayerInfo = _calculateNextPrayer(prayerTimes);

      emit(PrayerTimesLoaded(
        prayerTimes: prayerTimes,
        city: 'موقعي الحالي',
        country: '',
        nextPrayer: nextPrayerInfo['name'],
        timeUntilNextPrayer: nextPrayerInfo['duration'],
      ));

      // Start timer to update countdown
      _startCountdownTimer();
    } catch (e) {
      emit(PrayerTimesError(message: e.toString()));
    }
  }

  /// Load prayer times by city
  /// تحميل أوقات الصلاة حسب المدينة
  Future<void> loadPrayerTimes({
    String? city,
    String? country,
    bool forceRefresh = false,
  }) async {
    emit(const PrayerTimesLoading());

    try {
      // Get cached location if not provided
      final location = _repository.getCachedLocation();
      final selectedCity = city ?? location['city']!;
      final selectedCountry = country ?? location['country']!;

      // Fetch prayer times
      final prayerTimes = await _repository.getPrayerTimes(
        city: selectedCity,
        country: selectedCountry,
        forceRefresh: forceRefresh,
      );

      // Save location
      await _repository.saveLocation(selectedCity, selectedCountry);

      // Schedule notifications
      await _schedulePrayerNotifications(prayerTimes);

      // Calculate next prayer
      final nextPrayerInfo = _calculateNextPrayer(prayerTimes);

      emit(PrayerTimesLoaded(
        prayerTimes: prayerTimes,
        city: selectedCity,
        country: selectedCountry,
        nextPrayer: nextPrayerInfo['name'],
        timeUntilNextPrayer: nextPrayerInfo['duration'],
      ));

      // Start countdown timer
      _startCountdownTimer();
    } catch (e) {
      emit(PrayerTimesError(message: e.toString()));
    }
  }

  /// Refresh prayer times
  /// تحديث أوقات الصلاة
  Future<void> refreshPrayerTimes() async {
    final currentState = state;
    if (currentState is PrayerTimesLoaded) {
      await loadPrayerTimes(
        city: currentState.city,
        country: currentState.country,
        forceRefresh: true,
      );
    } else {
      await loadPrayerTimes(forceRefresh: true);
    }
  }

  /// Schedule notifications for all prayers
  /// جدولة الإشعارات لجميع الصلوات
  Future<void> _schedulePrayerNotifications(PrayerTimeModel prayerTimes) async {
    // Request notification permission
    await Permission.notification.request();

    // Cancel existing notifications
    await _notifications.cancelAll();

    final prayers = [
      {'name': 'الفجر', 'time': prayerTimes.fajr, 'id': 1},
      {'name': 'الظهر', 'time': prayerTimes.dhuhr, 'id': 2},
      {'name': 'العصر', 'time': prayerTimes.asr, 'id': 3},
      {'name': 'المغرب', 'time': prayerTimes.maghrib, 'id': 4},
      {'name': 'العشاء', 'time': prayerTimes.isha, 'id': 5},
    ];

    for (final prayer in prayers) {
      await _schedulePrayerNotification(
        id: prayer['id'] as int,
        prayerName: prayer['name'] as String,
        prayerTime: prayer['time'] as String,
      );
    }
  }

  /// Schedule single prayer notification
  /// جدولة إشعار صلاة واحدة
  Future<void> _schedulePrayerNotification({
    required int id,
    required String prayerName,
    required String prayerTime,
  }) async {
    try {
      final now = DateTime.now();
      final timeParts = prayerTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Create prayer datetime
      var prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If prayer time has passed today, schedule for tomorrow
      if (prayerDateTime.isBefore(now)) {
        prayerDateTime = prayerDateTime.add(const Duration(days: 1));
      }

      // Schedule 5 minutes before prayer time
      final notificationTime =
          prayerDateTime.subtract(const Duration(minutes: 5));

      const androidDetails = AndroidNotificationDetails(
        'prayer_times',
        'مواقيت الصلاة',
        channelDescription: 'إشعارات مواقيت الصلاة',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        sound: RawResourceAndroidNotificationSound('azan'),
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'azan.mp3',
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        '🕌 اقترب وقت صلاة $prayerName',
        'باقي 5 دقائق على صلاة $prayerName - الوقت: $prayerTime',
        tz.TZDateTime.from(notificationTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Error scheduling notification - log to debugging service if available
      // In production, this should be logged to a crash reporting service
    }
  }

  /// Calculate next prayer and time remaining
  /// حساب الصلاة القادمة والوقت المتبقي
  Map<String, dynamic> _calculateNextPrayer(PrayerTimeModel prayerTimes) {
    final now = DateTime.now();
    final prayers = [
      {'name': 'الفجر', 'time': prayerTimes.fajr},
      {'name': 'الظهر', 'time': prayerTimes.dhuhr},
      {'name': 'العصر', 'time': prayerTimes.asr},
      {'name': 'المغرب', 'time': prayerTimes.maghrib},
      {'name': 'العشاء', 'time': prayerTimes.isha},
    ];

    for (final prayer in prayers) {
      final prayerTime = prayer['time'] as String;
      final timeParts = prayerTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (prayerDateTime.isAfter(now)) {
        return {
          'name': prayer['name'],
          'duration': prayerDateTime.difference(now),
        };
      }
    }

    // If no prayer found today, return Fajr tomorrow
    final fajrTime = prayerTimes.fajr.split(':');
    final fajrDateTime = DateTime(
      now.year,
      now.month,
      now.day + 1,
      int.parse(fajrTime[0]),
      int.parse(fajrTime[1]),
    );

    return {
      'name': 'الفجر',
      'duration': fajrDateTime.difference(now),
    };
  }

  /// Start countdown timer
  /// بدء مؤقت العد التنازلي
  void _startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      final currentState = state;
      if (currentState is PrayerTimesLoaded) {
        final nextPrayerInfo = _calculateNextPrayer(currentState.prayerTimes);
        emit(currentState.copyWith(
          nextPrayer: nextPrayerInfo['name'],
          timeUntilNextPrayer: nextPrayerInfo['duration'],
        ));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
