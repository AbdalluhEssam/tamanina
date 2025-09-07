// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:io';
//
// class NotificationService {
//   static final FirebaseMessaging _firebaseMessaging =
//       FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();
//
//   static Future<void> initialize() async {
//     // Request notification permissions
//     await requestPermission();
//
//     // Initialize local notifications
//     const initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initializationSettingsIOS = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     const initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//
//     await _localNotifications.initialize(initializationSettings);
//
//     // Handle background messages
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       _showNotification(message);
//     });
//
//     // Handle notification taps
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       _handleNotificationTap(message);
//     });
//   }
//
//   static Future<void> requestPermission() async {
//     if (Platform.isIOS) {
//       await _firebaseMessaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//     }
//
//     await Permission.notification.request();
//   }
//
//   static Future<void> schedulePrayerNotifications({
//     required String prayerName,
//     required String arabicName,
//     required DateTime prayerTime,
//   }) async {
//     final id = prayerName.hashCode;
//
//     await _localNotifications.zonedSchedule(
//       id,
//       'حان موعد صلاة $arabicName',
//       'حان الآن موعد صلاة $arabicName، تقبل الله منكم',
//       _convertToTZDateTime(prayerTime),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'prayer_channel',
//           'Prayer Times',
//           channelDescription: 'Notifications for prayer times',
//           importance: Importance.high,
//           priority: Priority.high,
//           sound: RawResourceAndroidNotificationSound('azan'),
//         ),
//         iOS: DarwinNotificationDetails(
//           sound: 'azan.wav',
//         ),
//       ),
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }
//
//   static Future<void> cancelAllNotifications() async {
//     await _localNotifications.cancelAll();
//   }
//
//   static Future<void> _showNotification(RemoteMessage message) async {
//     const notificationDetails = NotificationDetails(
//       android: AndroidNotificationDetails(
//         'default_channel',
//         'Default',
//         channelDescription: 'Default notification channel',
//         importance: Importance.high,
//         priority: Priority.high,
//       ),
//     );
//
//     await _localNotifications.show(
//       message.hashCode,
//       message.notification?.title,
//       message.notification?.body,
//       notificationDetails,
//     );
//   }
//
//   static void _handleNotificationTap(RemoteMessage message) {
//     // Handle notification tap - navigate to specific screen if needed
//     print('Notification tapped: ${message.data}');
//   }
//
//   static _convertToTZDateTime(DateTime dateTime) {
//     // Convert DateTime to TZDateTime for timezone support
//     // For now, just return the DateTime as is
//     return dateTime;
//   }
// }
//
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print('Handling a background message: ${message.messageId}');
// }
