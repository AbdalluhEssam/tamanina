import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Background message handler - Must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('📨 Background Message: ${message.messageId}');
  }
}

/// Notification Service - Handles FCM & Local Notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'tamanina_channel';
  static const String _channelName = 'Tamanina Notifications';
  static const String _channelDescription = 'Daily reminders and updates';

  /// Initialize all notification services
  Future<void> initialize() async {
    try {
      await _requestPermissions();
      await _initializeLocalNotifications();
      await _initializeFCM();
      _setupMessageHandlers();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing notifications: $e');
      }
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {},
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
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
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data.toString());
    });
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(String? payload) {
    // Navigation logic here
  }

  /// Schedule daily notification
  Future<void> scheduleDailyNotification({
    int hour = 9,
    int minute = 0,
    String title = '🌞 صباح الخير!',
    String body = 'لا تنسَ مراجعة تحديثاتك اليوم! 📱',
  }) async {
    try {
      await _localNotifications.zonedSchedule(
        0,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling notification: $e');
      }
    }
  }

  /// Schedule periodic dhikr reminders (every 30 minutes)
  Future<void> schedulePeriodicDhikrReminders() async {
    try {
      final List<Map<String, String>> dhikrMessages = [
        {'title': '🤲 اذكر الله', 'body': 'اذكروا الله ذكراً كثيراً'},
        {'title': '🌟 سبحان الله', 'body': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ'},
        {
          'title': '💚 الحمد لله',
          'body': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'
        },
        {'title': '☝️ الله أكبر', 'body': 'اللَّهُ أَكْبَرُ كَبِيرًا'},
        {'title': '🕌 لا إله إلا الله', 'body': 'لَا إِلَهَ إِلَّا اللَّهُ'},
        {
          'title': '📿 استغفر الله',
          'body': 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ'
        },
        {
          'title': '✨ لا حول ولا قوة',
          'body': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ'
        },
        {
          'title': '🌙 حسبي الله',
          'body': 'حَسْبِيَ اللَّهُ وَنِعْمَ الْوَكِيلُ'
        },
      ];

      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

      // Schedule 48 notifications (24 hours of 30-min intervals)
      for (int i = 0; i < 48; i++) {
        final dhikr = dhikrMessages[i % dhikrMessages.length];
        final scheduledTime = now.add(Duration(minutes: 30 * (i + 1)));

        await _localNotifications.zonedSchedule(
          100 + i,
          dhikr['title']!,
          dhikr['body']!,
          scheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'dhikr_channel',
              'Dhikr Reminders',
              channelDescription: 'Remember Allah every 30 minutes',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scheduling dhikr reminders: $e');
      }
    }
  }

  /// Calculate next instance of time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
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

    return scheduledDate;
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Get FCM Token
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
