import 'dart:io';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'prayer_service.dart';

/// إعدادات الأذان
/// Adhan Settings
class AdhanSettings {
  final bool isEnabled;
  final String soundFile; // Asset path or 'system' or 'silent'
  final double volume;
  final bool vibrate;
  final bool fullScreenMode;
  final bool respectDND;

  const AdhanSettings({
    this.isEnabled = true,
    this.soundFile = 'system',
    this.volume = 1.0,
    this.vibrate = true,
    this.fullScreenMode = false,
    this.respectDND = true,
  });

  AdhanSettings copyWith({
    bool? isEnabled,
    String? soundFile,
    double? volume,
    bool? vibrate,
    bool? fullScreenMode,
    bool? respectDND,
  }) {
    return AdhanSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      soundFile: soundFile ?? this.soundFile,
      volume: volume ?? this.volume,
      vibrate: vibrate ?? this.vibrate,
      fullScreenMode: fullScreenMode ?? this.fullScreenMode,
      respectDND: respectDND ?? this.respectDND,
    );
  }

  Map<String, dynamic> toJson() => {
        'isEnabled': isEnabled,
        'soundFile': soundFile,
        'volume': volume,
        'vibrate': vibrate,
        'fullScreenMode': fullScreenMode,
        'respectDND': respectDND,
      };

  factory AdhanSettings.fromJson(Map<String, dynamic> json) => AdhanSettings(
        isEnabled: json['isEnabled'] ?? true,
        soundFile: json['soundFile'] ?? 'system',
        volume: (json['volume'] ?? 1.0).toDouble(),
        vibrate: json['vibrate'] ?? true,
        fullScreenMode: json['fullScreenMode'] ?? false,
        respectDND: json['respectDND'] ?? true,
      );
}

/// إعدادات إشعار الصلاة
/// Prayer Notification Settings
class PrayerNotificationSettings {
  final bool fajrEnabled;
  final bool sunriseEnabled;
  final bool dhuhrEnabled;
  final bool asrEnabled;
  final bool maghribEnabled;
  final bool ishaEnabled;
  final int reminderMinutesBefore; // 0 = disabled
  final bool muadhinModeEnabled;
  final AdhanSettings adhanSettings;
  final String? customFajrAdhan; // Different adhan for Fajr

  const PrayerNotificationSettings({
    this.fajrEnabled = true,
    this.sunriseEnabled = false,
    this.dhuhrEnabled = true,
    this.asrEnabled = true,
    this.maghribEnabled = true,
    this.ishaEnabled = true,
    this.reminderMinutesBefore = 15,
    this.muadhinModeEnabled = false,
    this.adhanSettings = const AdhanSettings(),
    this.customFajrAdhan,
  });

  bool isPrayerEnabled(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return fajrEnabled;
      case 'sunrise':
        return sunriseEnabled;
      case 'dhuhr':
        return dhuhrEnabled;
      case 'asr':
        return asrEnabled;
      case 'maghrib':
        return maghribEnabled;
      case 'isha':
        return ishaEnabled;
      default:
        return false;
    }
  }

  PrayerNotificationSettings copyWith({
    bool? fajrEnabled,
    bool? sunriseEnabled,
    bool? dhuhrEnabled,
    bool? asrEnabled,
    bool? maghribEnabled,
    bool? ishaEnabled,
    int? reminderMinutesBefore,
    bool? muadhinModeEnabled,
    AdhanSettings? adhanSettings,
    String? customFajrAdhan,
  }) {
    return PrayerNotificationSettings(
      fajrEnabled: fajrEnabled ?? this.fajrEnabled,
      sunriseEnabled: sunriseEnabled ?? this.sunriseEnabled,
      dhuhrEnabled: dhuhrEnabled ?? this.dhuhrEnabled,
      asrEnabled: asrEnabled ?? this.asrEnabled,
      maghribEnabled: maghribEnabled ?? this.maghribEnabled,
      ishaEnabled: ishaEnabled ?? this.ishaEnabled,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      muadhinModeEnabled: muadhinModeEnabled ?? this.muadhinModeEnabled,
      adhanSettings: adhanSettings ?? this.adhanSettings,
      customFajrAdhan: customFajrAdhan ?? this.customFajrAdhan,
    );
  }
}

/// خدمة الإشعارات المحسنة
/// Enhanced Notification Service with Prayer and Adhan support
class PrayerNotificationService {
  static final PrayerNotificationService _instance =
      PrayerNotificationService._internal();
  factory PrayerNotificationService() => _instance;
  PrayerNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  SharedPreferences? _prefs;
  PrayerNotificationSettings _settings = const PrayerNotificationSettings();

  // Notification channels
  static const String _prayerChannelId = 'prayer_notifications';
  static const String _prayerChannelName = 'إشعارات الصلاة';
  static const String _prayerChannelDesc = 'إشعارات أوقات الصلاة والأذان';

  static const String _adhanChannelId = 'adhan_notifications';
  static const String _adhanChannelName = 'الأذان';
  static const String _adhanChannelDesc = 'إشعارات الأذان مع الصوت';

  static const String _reminderChannelId = 'reminder_notifications';
  static const String _reminderChannelName = 'تذكيرات';
  static const String _reminderChannelDesc = 'تذكيرات قبل وقت الصلاة';

  // Settings keys
  static const String _keyNotificationSettings = 'prayer_notification_settings';

  // Notification IDs
  static const int _fajrNotificationId = 1001;
  static const int _sunriseNotificationId = 1002;
  static const int _dhuhrNotificationId = 1003;
  static const int _asrNotificationId = 1004;
  static const int _maghribNotificationId = 1005;
  static const int _ishaNotificationId = 1006;

  /// Initialize the notification service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadSettings();

      // Initialize timezone
      tz.initializeTimeZones();

      await _requestPermissions();
      await _initializeLocalNotifications();
      await _initializeFCM();
      _setupMessageHandlers();

      if (kDebugMode) {
        print('✅ PrayerNotificationService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing PrayerNotificationService: $e');
      }
    }
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    // Load settings from SharedPreferences
    // For now, use defaults
  }

  /// Get current settings
  PrayerNotificationSettings get settings => _settings;

  /// Update settings
  Future<void> updateSettings(PrayerNotificationSettings newSettings) async {
    _settings = newSettings;
    // Save to SharedPreferences
    // Re-schedule notifications with new settings
    await schedulePrayerNotifications();
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    bool granted = true;

    // Firebase Messaging permission
    final fcmSettings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true, // For adhan notifications
    );

    granted = fcmSettings.authorizationStatus == AuthorizationStatus.authorized;

    // Platform specific permissions
    if (Platform.isIOS) {
      final iosGranted = await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
              alert: true, badge: true, sound: true, critical: true);
      granted = granted && (iosGranted ?? false);
    }

    if (Platform.isAndroid) {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }

    return granted;
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {},
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _handleBackgroundNotificationResponse,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Prayer notification channel
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _prayerChannelId,
        _prayerChannelName,
        description: _prayerChannelDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    // Adhan notification channel (with sound)
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _adhanChannelId,
        _adhanChannelName,
        description: _adhanChannelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('adhan_default'),
      ),
    );

    // Reminder notification channel
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _reminderChannelId,
        _reminderChannelName,
        description: _reminderChannelDesc,
        importance: Importance.defaultImportance,
        playSound: true,
      ),
    );
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFCM() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showFCMNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data);
    });
  }

  /// Show FCM notification
  Future<void> _showFCMNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      await showNotification(
        id: notification.hashCode,
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle notification response
  void _handleNotificationResponse(NotificationResponse response) {
    _handleNotificationTap({'payload': response.payload});
  }

  /// Handle background notification response
  @pragma('vm:entry-point')
  static void _handleBackgroundNotificationResponse(
      NotificationResponse response) {
    // Handle background notification tap
  }

  /// Handle notification tap
  void _handleNotificationTap(Map<String, dynamic> data) {
    // Navigate to appropriate screen based on notification data
    if (kDebugMode) {
      print('📱 Notification tapped: $data');
    }
  }

  /// Show a notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = _prayerChannelId,
    bool playAdhan = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == _adhanChannelId ? _adhanChannelName : _prayerChannelName,
      channelDescription:
          channelId == _adhanChannelId ? _adhanChannelDesc : _prayerChannelDesc,
      importance:
          channelId == _adhanChannelId ? Importance.max : Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(body),
      category: channelId == _adhanChannelId
          ? AndroidNotificationCategory.alarm
          : AndroidNotificationCategory.reminder,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);

    // Play adhan if enabled
    if (playAdhan && _settings.muadhinModeEnabled) {
      await _playAdhan();
    }
  }

  /// Play adhan audio
  Future<void> _playAdhan({String? customSound}) async {
    try {
      final sound = customSound ?? _settings.adhanSettings.soundFile;

      if (sound == 'silent') return;

      if (sound == 'system') {
        // System notification sound is handled by the notification
        return;
      }

      // Play custom adhan audio from assets
      await _audioPlayer.setAsset('assets/audio/adhan/$sound');
      await _audioPlayer.setVolume(_settings.adhanSettings.volume);
      await _audioPlayer.play();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error playing adhan: $e');
      }
    }
  }

  /// Stop adhan audio
  Future<void> stopAdhan() async {
    await _audioPlayer.stop();
  }

  /// Schedule prayer notifications for today
  Future<void> schedulePrayerNotifications() async {
    try {
      // Cancel existing prayer notifications
      await cancelAllPrayerNotifications();

      final prayerService = PrayerService();
      final todayPrayers = await prayerService.getTodayPrayerTimes();
      final now = DateTime.now();

      // Schedule each prayer notification
      if (_settings.fajrEnabled && todayPrayers.fajr.time.isAfter(now)) {
        await _schedulePrayerNotification(
          id: _fajrNotificationId,
          prayer: todayPrayers.fajr,
          isFajr: true,
        );
      }

      if (_settings.sunriseEnabled && todayPrayers.sunrise.time.isAfter(now)) {
        await _schedulePrayerNotification(
          id: _sunriseNotificationId,
          prayer: todayPrayers.sunrise,
          isSunrise: true,
        );
      }

      if (_settings.dhuhrEnabled && todayPrayers.dhuhr.time.isAfter(now)) {
        await _schedulePrayerNotification(
          id: _dhuhrNotificationId,
          prayer: todayPrayers.dhuhr,
        );
      }

      if (_settings.asrEnabled && todayPrayers.asr.time.isAfter(now)) {
        await _schedulePrayerNotification(
          id: _asrNotificationId,
          prayer: todayPrayers.asr,
        );
      }

      if (_settings.maghribEnabled && todayPrayers.maghrib.time.isAfter(now)) {
        await _schedulePrayerNotification(
          id: _maghribNotificationId,
          prayer: todayPrayers.maghrib,
        );
      }

      if (_settings.ishaEnabled && todayPrayers.isha.time.isAfter(now)) {
        await _schedulePrayerNotification(
          id: _ishaNotificationId,
          prayer: todayPrayers.isha,
        );
      }

      if (kDebugMode) {
        print('✅ Prayer notifications scheduled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling prayer notifications: $e');
      }
    }
  }

  /// Schedule a single prayer notification
  Future<void> _schedulePrayerNotification({
    required int id,
    required PrayerTimeData prayer,
    bool isFajr = false,
    bool isSunrise = false,
  }) async {
    final scheduledDate = tz.TZDateTime.from(prayer.time, tz.local);

    final title = isSunrise
        ? '🌅 ${prayer.nameArabic}'
        : '🕌 حان وقت ${prayer.nameArabic}';

    final body = isSunrise
        ? 'وقت الشروق - ${prayer.formattedTime}'
        : 'حان الآن وقت صلاة ${prayer.nameArabic}\n${prayer.formattedTime}';

    final channelId =
        _settings.muadhinModeEnabled ? _adhanChannelId : _prayerChannelId;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == _adhanChannelId ? _adhanChannelName : _prayerChannelName,
      channelDescription:
          channelId == _adhanChannelId ? _adhanChannelDesc : _prayerChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(body),
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: _settings.adhanSettings.fullScreenMode,
      sound: _settings.muadhinModeEnabled && !isSunrise
          ? const RawResourceAndroidNotificationSound('adhan_default')
          : null,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload:
          '{"prayer": "${prayer.name}", "time": "${prayer.formattedTime}"}',
    );

    // Schedule reminder if enabled
    if (_settings.reminderMinutesBefore > 0 && !isSunrise) {
      await _scheduleReminderNotification(id: id + 100, prayer: prayer);
    }
  }

  /// Schedule a reminder notification before prayer time
  Future<void> _scheduleReminderNotification({
    required int id,
    required PrayerTimeData prayer,
  }) async {
    final reminderTime = prayer.time.subtract(
      Duration(minutes: _settings.reminderMinutesBefore),
    );

    if (reminderTime.isBefore(DateTime.now())) return;

    final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      _reminderChannelId,
      _reminderChannelName,
      channelDescription: _reminderChannelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      '⏰ تذكير بالصلاة',
      'باقي ${_settings.reminderMinutesBefore} دقيقة على صلاة ${prayer.nameArabic}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel all prayer notifications
  Future<void> cancelAllPrayerNotifications() async {
    final ids = [
      _fajrNotificationId,
      _sunriseNotificationId,
      _dhuhrNotificationId,
      _asrNotificationId,
      _maghribNotificationId,
      _ishaNotificationId,
      // Reminder IDs
      _fajrNotificationId + 100,
      _dhuhrNotificationId + 100,
      _asrNotificationId + 100,
      _maghribNotificationId + 100,
      _ishaNotificationId + 100,
    ];

    for (final id in ids) {
      await _localNotifications.cancel(id);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  /// Available adhan sounds
  static const List<Map<String, String>> availableAdhans = [
    {'id': 'system', 'name': 'صوت النظام', 'nameEn': 'System Sound'},
    {
      'id': 'adhan_makkah.mp3',
      'name': 'أذان الحرم المكي',
      'nameEn': 'Makkah Haram'
    },
    {
      'id': 'adhan_madinah.mp3',
      'name': 'أذان الحرم المدني',
      'nameEn': 'Madinah Haram'
    },
    {
      'id': 'adhan_default.mp3',
      'name': 'الأذان الافتراضي',
      'nameEn': 'Default Adhan'
    },
    {'id': 'silent', 'name': 'صامت', 'nameEn': 'Silent'},
  ];

  /// Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
