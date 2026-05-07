import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../settings/settings_repository.dart';
import 'prayer_service_enhanced.dart';

/// خدمة الإشعارات المحسنة - تدعم جدولة إشعارات الصلاة والأذان
/// Enhanced Notification Service - Supports prayer notifications and adhan
class NotificationServiceEnhanced {
  static final NotificationServiceEnhanced _instance =
      NotificationServiceEnhanced._internal();
  factory NotificationServiceEnhanced() => _instance;
  NotificationServiceEnhanced._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _adhanPlayer = AudioPlayer();

  SettingsRepository? _settingsRepository;
  StreamSubscription<AppSettings>? _settingsSubscription;

  bool _isInitialized = false;

  // قنوات الإشعارات
  static const String _prayerChannelId = 'prayer_notifications';
  static const String _prayerChannelName = 'إشعارات الصلاة';
  static const String _prayerChannelDesc = 'إشعارات أوقات الصلاة';

  static const String _adhanChannelId = 'adhan_notifications';
  static const String _adhanChannelName = 'الأذان';
  static const String _adhanChannelDesc = 'إشعارات الأذان مع الصوت';

  static const String _reminderChannelId = 'reminder_notifications';
  static const String _reminderChannelName = 'تذكيرات قبل الصلاة';
  static const String _reminderChannelDesc = 'تذكيرات قبل وقت الصلاة';

  static const String _dhikrChannelId = 'dhikr_notifications';
  static const String _dhikrChannelName = 'تذكيرات الذكر';
  static const String _dhikrChannelDesc = 'تذكيرات بأذكار';

  // معرفات الإشعارات
  static const int _fajrId = 1001;
  static const int _sunriseId = 1002;
  static const int _dhuhrId = 1003;
  static const int _asrId = 1004;
  static const int _maghribId = 1005;
  static const int _ishaId = 1006;

  static const int _fajrReminderId = 2001;
  static const int _dhuhrReminderId = 2003;
  static const int _asrReminderId = 2004;
  static const int _maghribReminderId = 2005;
  static const int _ishaReminderId = 2006;

  /// تهيئة الخدمة
  /// Initialize the service
  Future<void> initialize({SettingsRepository? settingsRepository}) async {
    if (_isInitialized) return;

    try {
      _settingsRepository = settingsRepository;

      await _requestPermissions();
      await _initializeLocalNotifications();
      await _initializeFCM();
      _setupMessageHandlers();

      // الاستماع لتغييرات الإعدادات
      if (_settingsRepository != null) {
        _settingsSubscription =
            _settingsRepository!.settingsStream.listen((settings) {
          _rescheduleNotifications();
        });
      }

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ NotificationServiceEnhanced initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing NotificationServiceEnhanced: $e');
      }
    }
  }

  /// ربط مستودع الإعدادات
  /// Attach settings repository
  void attachSettingsRepository(SettingsRepository repository) {
    _settingsRepository = repository;
    _settingsSubscription?.cancel();
    _settingsSubscription = repository.settingsStream.listen((settings) {
      _rescheduleNotifications();
    });
  }

  /// طلب صلاحيات الإشعارات
  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    bool granted = true;

    // طلب صلاحية FCM
    final fcmSettings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );
    granted = fcmSettings.authorizationStatus == AuthorizationStatus.authorized;

    // صلاحيات النظام
    if (Platform.isIOS) {
      final iosGranted = await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
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

  /// تهيئة الإشعارات المحلية
  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {},
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    // إنشاء قنوات Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// إنشاء قنوات إشعارات Android
  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // قناة إشعارات الصلاة
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

    // قناة الأذان
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _adhanChannelId,
        _adhanChannelName,
        description: _adhanChannelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );

    // قناة التذكيرات
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _reminderChannelId,
        _reminderChannelName,
        description: _reminderChannelDesc,
        importance: Importance.defaultImportance,
        playSound: true,
      ),
    );

    // قناة الأذكار
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _dhikrChannelId,
        _dhikrChannelName,
        description: _dhikrChannelDesc,
        importance: Importance.defaultImportance,
        playSound: true,
      ),
    );
  }

  /// تهيئة FCM
  /// Initialize FCM
  Future<void> _initializeFCM() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// إعداد معالجات الرسائل
  /// Setup message handlers
  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen((message) {
      _showFCMNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap(message.data);
    });
  }

  /// عرض إشعار FCM
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

  /// معالجة استجابة الإشعار
  /// Handle notification response
  void _handleNotificationResponse(NotificationResponse response) {
    _handleNotificationTap({'payload': response.payload});
  }

  /// معالجة النقر على الإشعار
  /// Handle notification tap
  void _handleNotificationTap(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('📱 Notification tapped: $data');
    }
  }

  /// جدولة إشعارات الصلاة اليومية
  /// Schedule daily prayer notifications
  Future<void> scheduleDailyPrayerNotifications(DailyPrayerTimes times) async {
    if (_settingsRepository == null) return;

    final settings = _settingsRepository!.currentSettings;

    if (!settings.notificationsEnabled) {
      await cancelAllPrayerNotifications();
      return;
    }

    final perPrayer = settings.perPrayerEnabled;
    final muadhinMode = settings.muadhinMode;

    // جدولة إشعار الفجر
    if (perPrayer.fajr) {
      await _schedulePrayerNotification(
        id: _fajrId,
        title: '🌙 حان وقت صلاة الفجر',
        body: 'الصلاة خير من النوم',
        time: times.fajr.time,
        playAdhan: muadhinMode,
      );
    }

    // جدولة إشعار الظهر
    if (perPrayer.dhuhr) {
      await _schedulePrayerNotification(
        id: _dhuhrId,
        title: '☀️ حان وقت صلاة الظهر',
        body: 'حي على الصلاة',
        time: times.dhuhr.time,
        playAdhan: muadhinMode,
      );
    }

    // جدولة إشعار العصر
    if (perPrayer.asr) {
      await _schedulePrayerNotification(
        id: _asrId,
        title: '🌤️ حان وقت صلاة العصر',
        body: 'حافظوا على الصلوات والصلاة الوسطى',
        time: times.asr.time,
        playAdhan: muadhinMode,
      );
    }

    // جدولة إشعار المغرب
    if (perPrayer.maghrib) {
      await _schedulePrayerNotification(
        id: _maghribId,
        title: '🌅 حان وقت صلاة المغرب',
        body: 'حي على الصلاة',
        time: times.maghrib.time,
        playAdhan: muadhinMode,
      );
    }

    // جدولة إشعار العشاء
    if (perPrayer.isha) {
      await _schedulePrayerNotification(
        id: _ishaId,
        title: '🌙 حان وقت صلاة العشاء',
        body: 'حي على الفلاح',
        time: times.isha.time,
        playAdhan: muadhinMode,
      );
    }

    if (kDebugMode) {
      print('✅ Prayer notifications scheduled');
    }
  }

  /// جدولة تذكيرات ما قبل الصلاة
  /// Schedule pre-prayer reminders
  Future<void> schedulePrePrayerReminders(
    DailyPrayerTimes times,
    int offsetMinutes,
  ) async {
    if (_settingsRepository == null || offsetMinutes <= 0) return;

    final settings = _settingsRepository!.currentSettings;
    if (!settings.notificationsEnabled) return;

    final perPrayer = settings.perPrayerEnabled;

    // تذكير الفجر
    if (perPrayer.fajr) {
      await _scheduleReminder(
        id: _fajrReminderId,
        title: '⏰ قريباً: صلاة الفجر',
        body: 'صلاة الفجر بعد $offsetMinutes دقيقة',
        time: times.fajr.time.subtract(Duration(minutes: offsetMinutes)),
      );
    }

    // تذكير الظهر
    if (perPrayer.dhuhr) {
      await _scheduleReminder(
        id: _dhuhrReminderId,
        title: '⏰ قريباً: صلاة الظهر',
        body: 'صلاة الظهر بعد $offsetMinutes دقيقة',
        time: times.dhuhr.time.subtract(Duration(minutes: offsetMinutes)),
      );
    }

    // تذكير العصر
    if (perPrayer.asr) {
      await _scheduleReminder(
        id: _asrReminderId,
        title: '⏰ قريباً: صلاة العصر',
        body: 'صلاة العصر بعد $offsetMinutes دقيقة',
        time: times.asr.time.subtract(Duration(minutes: offsetMinutes)),
      );
    }

    // تذكير المغرب
    if (perPrayer.maghrib) {
      await _scheduleReminder(
        id: _maghribReminderId,
        title: '⏰ قريباً: صلاة المغرب',
        body: 'صلاة المغرب بعد $offsetMinutes دقيقة',
        time: times.maghrib.time.subtract(Duration(minutes: offsetMinutes)),
      );
    }

    // تذكير العشاء
    if (perPrayer.isha) {
      await _scheduleReminder(
        id: _ishaReminderId,
        title: '⏰ قريباً: صلاة العشاء',
        body: 'صلاة العشاء بعد $offsetMinutes دقيقة',
        time: times.isha.time.subtract(Duration(minutes: offsetMinutes)),
      );
    }

    if (kDebugMode) {
      print('✅ Pre-prayer reminders scheduled with $offsetMinutes min offset');
    }
  }

  /// جدولة إشعار صلاة واحدة
  /// Schedule a single prayer notification
  Future<void> _schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    bool playAdhan = false,
  }) async {
    if (time.isBefore(DateTime.now())) {
      // الوقت مر، جدول ليوم غد
      time = time.add(const Duration(days: 1));
    }

    final tzTime = tz.TZDateTime.from(time, tz.local);

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          playAdhan ? _adhanChannelId : _prayerChannelId,
          playAdhan ? _adhanChannelName : _prayerChannelName,
          channelDescription:
              playAdhan ? _adhanChannelDesc : _prayerChannelDesc,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          fullScreenIntent: playAdhan,
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: playAdhan ? 'play_adhan' : null,
    );
  }

  /// جدولة تذكير
  /// Schedule a reminder
  Future<void> _scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    if (time.isBefore(DateTime.now())) return;

    final tzTime = tz.TZDateTime.from(time, tz.local);

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannelId,
          _reminderChannelName,
          channelDescription: _reminderChannelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// تشغيل الأذان
  /// Play adhan
  Future<void> playAdhan({AdhanSound? sound}) async {
    if (_settingsRepository == null) return;

    final settings = _settingsRepository!.currentSettings;
    final adhanSound = sound ?? settings.selectedAdhan;

    if (adhanSound == AdhanSound.system) {
      // استخدم صوت النظام
      return;
    }

    try {
      // التحقق من وضع عدم الإزعاج
      if (settings.muadhinMode) {
        // طلب تجاوز DND إذا لزم الأمر
        await _requestDNDOverride();
      }

      await _adhanPlayer.setVolume(settings.adhanVolume);
      await _adhanPlayer.setAsset(adhanSound.assetPath);
      await _adhanPlayer.play();

      if (kDebugMode) {
        print('🔊 Playing adhan: ${adhanSound.displayName}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error playing adhan: $e');
      }
    }
  }

  /// إيقاف الأذان
  /// Stop adhan
  Future<void> stopAdhan() async {
    await _adhanPlayer.stop();
  }

  /// طلب تجاوز وضع عدم الإزعاج
  /// Request DND override
  Future<bool> _requestDNDOverride() async {
    if (Platform.isAndroid) {
      final status = await Permission.accessNotificationPolicy.status;
      if (!status.isGranted) {
        final result = await Permission.accessNotificationPolicy.request();
        return result.isGranted;
      }
      return true;
    }
    return false;
  }

  /// عرض مربع حوار طلب DND للمستخدم
  /// Show DND permission dialog to user
  Future<void> showDNDPermissionDialog(BuildContext context) async {
    if (!Platform.isAndroid) return;

    final status = await Permission.accessNotificationPolicy.status;
    if (status.isGranted) return;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('السماح بتجاوز وضع عدم الإزعاج'),
        content: const Text(
          'لتشغيل الأذان في وضع عدم الإزعاج، يرجى السماح للتطبيق بتجاوز إعدادات الصوت.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لاحقاً'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Permission.accessNotificationPolicy.request();
            },
            child: const Text('السماح'),
          ),
        ],
      ),
    );
  }

  /// إعادة جدولة الإشعارات
  /// Reschedule notifications
  Future<void> _rescheduleNotifications() async {
    try {
      final prayerService = PrayerServiceEnhanced();
      final times = await prayerService.getTodayPrayerTimes();

      await cancelAllPrayerNotifications();
      await scheduleDailyPrayerNotifications(times);

      if (_settingsRepository != null) {
        final offset =
            _settingsRepository!.currentSettings.prePrayerOffsetMinutes;
        if (offset > 0) {
          await schedulePrePrayerReminders(times, offset);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error rescheduling notifications: $e');
      }
    }
  }

  /// إعادة جدولة الإشعارات عند إعادة تشغيل الجهاز
  /// Reschedule notifications on device boot
  /// Note: This should be called from a boot receiver on Android
  static Future<void> onBootComplete() async {
    final service = NotificationServiceEnhanced();
    await service.initialize();
    await service._rescheduleNotifications();
  }

  /// عرض إشعار عام
  /// Show a general notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = _prayerChannelId,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _prayerChannelName,
          channelDescription: _prayerChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  /// جدولة إشعار يومي
  /// Schedule a daily notification
  Future<void> scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _dhikrChannelId,
          _dhikrChannelName,
          channelDescription: _dhikrChannelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// إلغاء جميع إشعارات الصلاة
  /// Cancel all prayer notifications
  Future<void> cancelAllPrayerNotifications() async {
    await _localNotifications.cancel(_fajrId);
    await _localNotifications.cancel(_sunriseId);
    await _localNotifications.cancel(_dhuhrId);
    await _localNotifications.cancel(_asrId);
    await _localNotifications.cancel(_maghribId);
    await _localNotifications.cancel(_ishaId);

    await _localNotifications.cancel(_fajrReminderId);
    await _localNotifications.cancel(_dhuhrReminderId);
    await _localNotifications.cancel(_asrReminderId);
    await _localNotifications.cancel(_maghribReminderId);
    await _localNotifications.cancel(_ishaReminderId);
  }

  /// إلغاء جميع الإشعارات
  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// الحصول على رمز FCM
  /// Get FCM token
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// تنظيف الموارد
  /// Dispose resources
  void dispose() {
    _settingsSubscription?.cancel();
    _adhanPlayer.dispose();
  }
}

/// Background message handler - Must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('📨 Background Message: ${message.messageId}');
  }
}
