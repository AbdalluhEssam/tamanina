import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState, WidgetsBinding;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../audio/audio_library.dart';
import '../constants/app_constants.dart';
import '../settings/settings_repository.dart';
import 'prayer_service_enhanced.dart';
import 'reminder_schedule.dart';
import 'worship_shortcuts.dart';

/// Files of the adhan voice the user chose. Null means the bundled adhan.
class _AdhanSounds {
  const _AdhanSounds({
    this.path,
    this.fajrPath,
    this.iosName,
    this.iosFajrName,
  });

  final String? path;
  final String? fajrPath;
  final String? iosName;
  final String? iosFajrName;

  String? pathFor(bool isFajr) => isFajr ? fajrPath : path;
  String? iosNameFor(bool isFajr) => isFajr ? iosFajrName : iosName;

  String get key => '$path|$fajrPath|$iosName|$iosFajrName';
}

bool _isFajrAlert(String route) => route.contains('fajr=true');

typedef _Alert = ({
  int id,
  tz.TZDateTime at,
  String title,
  String? body,
  String channel,
  String channelLabel,
  String route,
  bool sound,
  bool vibrate,
  bool adhan,
  DateTimeComponents? repeat,
});

class NotificationServiceEnhanced {
  factory NotificationServiceEnhanced() => _instance;
  NotificationServiceEnhanced._();
  static final _instance = NotificationServiceEnhanced._();

  static const _prayerId = 20000;
  static const _prayerDays = 30;
  static const _prayerSlots = _prayerDays * 12;
  static const _nativeAdhan = MethodChannel(
    'com.abdalluh.tamanina/adhan_alarms',
  );
  static const _iosPrayerQueue = MethodChannel(
    'com.abdalluh.tamanina/prayer_queue',
  );
  static const _reminderId = 21000;
  static const _dhikrId = 21100;
  static const _dhikrSlots = 12;
  static const _reminders = [
    (key: 'morning', hour: 6, title: 'أذكار الصباح'),
    (key: 'evening', hour: 17, title: 'أذكار المساء'),
    (key: 'sleep', hour: 22, title: 'أذكار النوم'),
  ];

  final _local = FlutterLocalNotificationsPlugin();
  late SettingsRepository _settings;
  Future<void>? _initialization;
  Future<void>? _scheduled;
  Future<bool>? _permissionRequest;
  DateTime? _lastAuthorizedSync;
  Timer? _foregroundAdhan;
  bool? _lastExact;
  final _scheduledAlerts = <int, _Alert>{};
  bool _needsRefresh = false;

  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  IOSFlutterLocalNotificationsPlugin? get _ios => _local
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  AndroidFlutterLocalNotificationsPlugin? get _android => _local
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  Future<void> initialize({required SettingsRepository settingsRepository}) {
    return _initialization ??= _initialize(settingsRepository);
  }

  Future<void> _initialize(SettingsRepository repository) async {
    _settings = repository;
    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        WorshipShortcuts.instance.open(response.payload);
      },
    );
    final launch = await _local.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      WorshipShortcuts.instance.open(launch?.notificationResponse?.payload);
    }
    _settings.settingsStream.listen((_) => refresh());
    PrayerServiceEnhanced().prayerTimesStream.listen((_) => refresh());
    // Retire reminders that used fixed clock times or an unconditional interval.
    for (final id in [
      1,
      2,
      100,
      101,
      102,
      103,
      1001,
      1002,
      1003,
      1004,
      1005,
      1006,
      2001,
      2003,
      2004,
      2005,
      2006,
    ]) {
      await _local.cancel(id);
    }
    unawaited(refresh());
  }

  Future<void> connectPushNotifications() async {
    await _initialization;
    if (_isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else {
      try {
        await _android?.createNotificationChannel(
          const AndroidNotificationChannel(
            'tamanina_channel',
            'Tamanina notifications',
            importance: Importance.high,
          ),
        );
      } catch (_) {}
      FirebaseMessaging.onMessage.listen((message) async {
        final notification = message.notification;
        if (notification == null ||
            !_settings.currentSettings.notificationsEnabled) {
          return;
        }
        try {
          if (!await _canDeliverNotifications()) return;
          await _local.show(
            notification.hashCode,
            notification.title,
            notification.body,
            _details('updates', 'App updates', sound: true, vibrate: true),
            payload: message.data['route'] as String?,
          );
        } catch (error) {
          if (kDebugMode) debugPrint('Could not show app update: $error');
        }
      });
    }
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      WorshipShortcuts.instance.open(message.data['route'] as String?);
    });
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      WorshipShortcuts.instance.open(initial.data['route'] as String?);
    }
  }

  /// Whether the system currently lets the app post notifications.
  Future<bool> notificationsAllowed() async {
    await _initialization;
    return _canDeliverNotifications();
  }

  Future<bool> requestPermissions() => _permissionRequest ??=
      _requestPermissions().whenComplete(() => _permissionRequest = null);

  Future<bool> _requestPermissions() async {
    await _initialization;
    final granted = _isIOS
        ? await _ios?.requestPermissions(alert: true, badge: true, sound: true)
        : await _android?.requestNotificationsPermission();
    final canDeliver = granted == true || await _canDeliverNotifications();
    if (canDeliver) unawaited(refresh());
    return canDeliver;
  }

  Future<bool> _canDeliverNotifications() async {
    if (_isIOS) {
      final permissions = await _ios?.checkPermissions();
      return permissions?.isEnabled == true ||
          permissions?.isProvisionalEnabled == true;
    }
    return _isAndroid && await _android?.areNotificationsEnabled() == true;
  }

  bool _isAuthorizationError(Object error) =>
      _isIOS &&
      error is PlatformException &&
      error.details == 'UNErrorDomain' &&
      (error.code == 'Error 2003' || error.code == 'Error 1');

  Future<bool> requestExactPrayerAlarms() async {
    await _initialization;
    final android = _android;
    if (android == null) return false;
    final granted =
        await android.canScheduleExactNotifications() == true ||
        await android.requestExactAlarmsPermission() == true;
    if (granted) await refresh();
    return granted;
  }

  Future<void> refreshOnResume() async {
    try {
      await _initialization;
      if (!_settings.currentSettings.notificationsEnabled) return;
      if (!await _canDeliverNotifications()) {
        _lastAuthorizedSync = null;
        return;
      }
      final last = _lastAuthorizedSync;
      final exact = await _android?.canScheduleExactNotifications() ?? false;
      if (last == null ||
          exact != _lastExact ||
          DateTime.now().difference(last) >= const Duration(minutes: 10)) {
        await refresh();
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Could not read notification permission: $error');
      }
    }
  }

  Future<void> refresh() {
    _needsRefresh = true;
    return _scheduled ??= Future<void>.microtask(() async {
      try {
        while (_needsRefresh) {
          _needsRefresh = false;
          try {
            await _initialization;
            await _sync();
          } catch (error) {
            _lastAuthorizedSync = null;
            if (kDebugMode && !_isAuthorizationError(error)) {
              debugPrint('Local notification sync notice: $error');
            }
          }
        }
      } finally {
        _scheduled = null;
      }
    });
  }

  bool _isManaged(int id) =>
      (id >= _prayerId && id < _prayerId + _prayerSlots) ||
      (id >= _reminderId && id <= _reminderId + 3) ||
      (id >= _dhikrId && id < _dhikrId + _dhikrSlots);

  _AdhanSounds _sounds = const _AdhanSounds();

  Future<_AdhanSounds> _adhanSounds(AppSettings settings) async {
    try {
      final voice = (await loadAudioCatalog(network: false)).voice(settings.adhanVoiceId);
      if (voice.isBundled) return const _AdhanSounds();
      final library = await AudioLibrary.open();
      return _AdhanSounds(
        path: (await library.installedAdhan(voice, isFajr: false))?.path,
        fajrPath: (await library.installedAdhan(voice, isFajr: true))?.path,
        iosName: await library.iosSoundName(voice, isFajr: false),
        iosFajrName: await library.iosSoundName(voice, isFajr: true),
      );
    } catch (_) {
      return const _AdhanSounds();
    }
  }

  Future<Set<int>> _syncNativeAdhan(
    Iterable<_Alert> alerts, {
    required double volume,
    required bool arabic,
  }) async {
    if (!_isAndroid) return {};
    final payload = [
      if (volume > 0)
        for (final alert in alerts)
          if (alert.adhan)
            {
              'id': alert.id,
              'at': alert.at.millisecondsSinceEpoch,
              'title': alert.title,
              'stopLabel': arabic ? 'إيقاف الأذان' : 'Stop adhan',
              'volume': volume,
              'vibrate': alert.vibrate,
              'route': alert.route,
              'soundPath': ?_sounds.pathFor(_isFajrAlert(alert.route)),
            },
    ];
    try {
      return (await _nativeAdhan.invokeListMethod<int>(
                'replace',
                jsonEncode(payload),
              ) ??
              const <int>[])
          .toSet();
    } on PlatformException catch (error) {
      if (kDebugMode) {
        debugPrint('Native adhan schedule unavailable: ${error.code}');
      }
      return {};
    } on MissingPluginException {
      return {};
    }
  }

  Future<void> _sync() async {
    final settings = _settings.currentSettings;
    if (settings.notificationsEnabled && !await _canDeliverNotifications()) {
      _lastAuthorizedSync = null;
      return;
    }

    final pending = await _local.pendingNotificationRequests();
    final available = _isIOS
        ? 64 - pending.where((request) => !_isManaged(request.id)).length
        : null;
    final prefs = await SharedPreferences.getInstance();
    final arabic = (prefs.getString('locale') ?? 'ar').startsWith('ar');
    final exact =
        settings.notificationsEnabled &&
        (await _android?.canScheduleExactNotifications() ?? false);
    final planned = settings.notificationsEnabled
        ? await _planAlerts(settings, prefs, arabic, available)
        : const <_Alert>[];
    if (_needsRefresh) return;
    final sounds = await _adhanSounds(settings);
    if (_sounds.key != sounds.key) {
      // A different voice: reschedule everything so the new sound is used.
      _scheduledAlerts.clear();
    }
    _sounds = sounds;
    _armForegroundAdhan(planned);
    if (_isIOS) await _saveIOSPrayerQueue(planned);
    final alerts = available == null
        ? planned
        : planned.take(available.clamp(0, 64)).toList();
    final nativeIds = await _syncNativeAdhan(
      alerts,
      volume: settings.adhanVolume,
      arabic: arabic,
    );
    final local = {
      for (final alert in alerts)
        if (!nativeIds.contains(alert.id)) alert.id: alert,
    };
    for (final request in pending) {
      final id = request.id;
      if (_isManaged(id) && !local.containsKey(id)) {
        await _local.cancel(id);
        _scheduledAlerts.remove(id);
      }
    }

    final pendingIds = pending.map((request) => request.id).toSet();
    var effectiveExact = exact;
    for (final alert in local.values) {
      if (pendingIds.contains(alert.id) &&
          _scheduledAlerts[alert.id] == alert &&
          exact == _lastExact) {
        continue;
      }
      if (alert.repeat == null &&
          !alert.at.isAfter(tz.TZDateTime.now(tz.local))) {
        continue;
      }
      final isExact = effectiveExact && alert.repeat == null;
      try {
        await _schedule(alert, exact: isExact);
      } on PlatformException catch (error) {
        if (!isExact || error.code != 'exact_alarms_not_permitted') rethrow;
        await _schedule(alert, exact: false);
        effectiveExact = false;
      }
      _scheduledAlerts[alert.id] = alert;
    }
    _scheduledAlerts.removeWhere((id, _) => !local.containsKey(id));
    _lastExact = effectiveExact;
    _lastAuthorizedSync = settings.notificationsEnabled ? DateTime.now() : null;
  }

  /// Opens the full-screen adhan when prayer time arrives while the app is
  /// open. Background delivery is handled by the notification (iOS) or by the
  /// native alarm service (Android).
  void _armForegroundAdhan(Iterable<_Alert> alerts) {
    _foregroundAdhan?.cancel();
    _foregroundAdhan = null;
    final now = DateTime.now();
    final upcoming =
        alerts.where((alert) => alert.adhan && alert.at.isAfter(now)).toList()
          ..sort((a, b) => a.at.compareTo(b.at));
    if (upcoming.isEmpty) return;
    final next = upcoming.first;
    _foregroundAdhan = Timer(next.at.difference(now), () {
      final late = DateTime.now().difference(next.at);
      if (late > const Duration(minutes: 2) ||
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
        return;
      }
      // On Android the native service already plays the adhan, so the screen
      // only follows it.
      WorshipShortcuts.instance.open(
        _isAndroid ? '${next.route}&follow=1' : next.route,
      );
    });
  }

  Future<void> _saveIOSPrayerQueue(Iterable<_Alert> alerts) async {
    final queue = [
      for (final alert in alerts)
        if (alert.channel == 'prayer')
          {
            'id': alert.id,
            'at': alert.at.millisecondsSinceEpoch,
            'title': alert.title,
            'route': alert.route,
            'sound': alert.sound,
            'adhan': alert.adhan,
            if (alert.adhan)
              'soundName': ?_sounds.iosNameFor(_isFajrAlert(alert.route)),
          },
    ];
    try {
      await _iosPrayerQueue.invokeMethod<void>('replace', jsonEncode(queue));
    } on PlatformException catch (error) {
      if (kDebugMode) debugPrint('iOS prayer queue unavailable: ${error.code}');
    } on MissingPluginException {
      // The foreground scheduler works independently of background refresh.
    }
  }

  Future<void> _schedule(_Alert alert, {required bool exact}) =>
      _local.zonedSchedule(
        alert.id,
        alert.title,
        alert.body,
        alert.at,
        _details(
          alert.channel,
          alert.channelLabel,
          sound: alert.sound,
          vibrate: alert.vibrate,
          adhan: alert.adhan,
          iosSoundName: alert.adhan
              ? _sounds.iosNameFor(_isFajrAlert(alert.route))
              : null,
        ),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: alert.repeat,
        payload: alert.route,
      );

  Future<List<_Alert>> _planAlerts(
    AppSettings settings,
    SharedPreferences prefs,
    bool arabic,
    int? available,
  ) async {
    final sound = prefs.getBool('notification_sound') ?? true;
    final vibrate = prefs.getBool('notification_vibration') ?? true;
    final now = tz.TZDateTime.now(tz.local);
    final quietStart = settings.quietHoursEnabled
        ? settings.quietHoursStart
        : null;
    final quietEnd = settings.quietHoursEnabled ? settings.quietHoursEnd : null;
    bool quiet(int hour) => isQuietHour(hour, quietStart, quietEnd);
    final reminders = <_Alert>[];
    final reminderTimes = <(int, int)>{};

    void addReminder(
      int id,
      String title,
      String? body,
      int hour,
      int minute, {
      bool weekly = false,
      String route = AppRoutes.azkar,
    }) {
      if ((available != null && reminders.length >= available) ||
          quiet(hour) ||
          !reminderTimes.add((hour, minute))) {
        return;
      }
      final offset = weekly ? (DateTime.friday - now.weekday + 7) % 7 : 0;
      var next = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + offset,
        hour,
        minute,
      );
      if (!next.isAfter(now)) {
        next = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + offset + (weekly ? 7 : 1),
          hour,
          minute,
        );
      }
      reminders.add((
        id: id,
        at: next,
        title: title,
        body: body,
        channel: 'adhkar',
        channelLabel: 'Adhkar reminders',
        route: route,
        sound: sound,
        vibrate: vibrate,
        adhan: false,
        repeat: weekly
            ? DateTimeComponents.dayOfWeekAndTime
            : DateTimeComponents.time,
      ));
    }

    const english = ['Morning adhkar', 'Evening adhkar', 'Bedtime adhkar'];
    for (final (i, reminder) in _reminders.indexed) {
      if (prefs.getBool('${reminder.key}_adhkar_reminder') == false) continue;
      addReminder(
        _reminderId + i,
        arabic ? reminder.title : english[i],
        null,
        prefs.getInt('${reminder.key}_reminder_hour') ?? reminder.hour,
        prefs.getInt('${reminder.key}_reminder_minute') ?? 0,
        route: switch (reminder.key) {
          'morning' => AppRoutes.morningAdhkar,
          'evening' => AppRoutes.eveningAdhkar,
          _ => AppRoutes.azkar,
        },
      );
    }
    if (prefs.getBool('friday_reminder') != false) {
      addReminder(
        _reminderId + 3,
        arabic ? 'تذكير يوم الجمعة' : 'Friday reminder',
        arabic ? 'اقرأ من سورة الكهف' : 'Read from Surah Al-Kahf',
        12,
        0,
        weekly: true,
        route: AppRoutes.alKahfReader,
      );
    }
    final interval = prefs.getInt('dhikr_interval_minutes') ?? 0;
    for (final (index, hour) in dhikrReminderHours(
      interval,
      quietStart: quietStart,
      quietEnd: quietEnd,
    ).indexed) {
      final message = dhikrMessages[index % dhikrMessages.length];
      addReminder(
        _dhikrId + index,
        arabic ? 'لحظة للذِّكر' : 'A moment for dhikr',
        arabic ? message.ar : message.en,
        hour,
        0,
      );
    }

    if (prefs.getBool('prayer_time_notifications') == false) return reminders;
    final prayerService = PrayerServiceEnhanced();
    final zone = prayerService.locationTimeZone;
    final today = tz.TZDateTime.from(now, zone);
    final prayers = <_Alert>[];
    for (var day = 0; day < _prayerDays; day++) {
      final date = tz.TZDateTime(
        zone,
        today.year,
        today.month,
        today.day + day,
      );
      final times = await prayerService.getPrayerTimes(date);
      if (times == null) break;
      final civilDay =
          DateTime.utc(
            date.year,
            date.month,
            date.day,
          ).millisecondsSinceEpoch ~/
          Duration.millisecondsPerDay;
      for (final (index, prayer) in times.allPrayers.indexed) {
        if (!settings.perPrayerEnabled.isEnabled(prayer.name)) continue;
        final name = arabic ? prayer.nameArabic : prayer.name;
        final id = _prayerId + (civilDay % _prayerDays) * 12 + index * 2;
        for (final (reminder, minutes) in [
          (false, 0),
          (true, settings.prePrayerOffsetMinutes),
        ]) {
          if (reminder && minutes == 0) continue;
          final at = tz.TZDateTime.from(
            prayer.time.subtract(Duration(minutes: minutes)),
            tz.local,
          );
          if (!at.isAfter(now)) continue;
          final muted = quiet(at.hour);
          final adhanSelected =
              !reminder &&
              settings.muadhinMode &&
              settings.selectedAdhan != AdhanSound.system &&
              prayer.name != 'Sunrise';
          final audible =
              sound && !muted && (!adhanSelected || settings.adhanVolume > 0);
          final useAdhan = adhanSelected && audible;
          prayers.add((
            id: reminder ? id + 1 : id,
            at: at,
            title: reminder
                ? arabic
                      ? '$name بعد $minutes دقيقة'
                      : '$name in $minutes minutes'
                : arabic
                ? 'حان وقت $name'
                : 'It’s time for $name',
            body: null,
            channel: 'prayer',
            channelLabel: 'Prayer alerts',
            route: useAdhan
                ? '${AppRoutes.adhan}?prayer=${prayer.name}&arabic=${Uri.encodeComponent(name)}&fajr=${prayer.name == 'Fajr'}'
                : AppRoutes.prayerTimes,
            sound: audible,
            vibrate: vibrate && !muted,
            adhan: useAdhan,
            repeat: null,
          ));
        }
      }
    }
    prayers.sort((a, b) => a.at.compareTo(b.at));
    return [...reminders, ...prayers];
  }

  NotificationDetails _details(
    String channel,
    String label, {
    required bool sound,
    required bool vibrate,
    bool adhan = false,
    String? iosSoundName,
  }) => NotificationDetails(
    android: AndroidNotificationDetails(
      'tamanina_${channel}_${adhan
          ? 'adhan2'
          : sound
          ? 'sound'
          : 'silent'}_${vibrate ? 'vibration' : 'still'}',
      label,
      importance: Importance.high,
      priority: Priority.high,
      playSound: sound,
      enableVibration: vibrate,
      // The adhan clip plays on the alarm stream so silent mode does not mute it.
      audioAttributesUsage: adhan
          ? AudioAttributesUsage.alarm
          : AudioAttributesUsage.notification,
      sound: adhan
          ? const RawResourceAndroidNotificationSound('adhan_alert')
          : null,
    ),
    iOS: DarwinNotificationDetails(
      // When the app is open the full-screen adhan plays the recording, so the
      // notification stays silent in the foreground (it still plays its sound
      // in the background).
      presentSound: sound && !adhan,
      sound: adhan && sound ? (iosSoundName ?? 'adhan_alert.caf') : null,
      interruptionLevel: adhan ? InterruptionLevel.timeSensitive : null,
    ),
  );
}
