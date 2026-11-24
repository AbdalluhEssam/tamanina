import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/notification_service_enhanced.dart';
import '../../../../core/services/reminder_schedule.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/settings/settings_repository.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../../../prayer_times/ui/screens/adhan_screen.dart';
import 'production_settings_screen.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _prefs = sl<SharedPreferences>();
  final _notifications = sl<NotificationServiceEnhanced>();
  AudioPlayer? _preview;
  bool _busy = false;
  bool _playing = false;

  Future<void> _toggle(bool enabled) async {
    final settings = context.read<SettingsCubit>();
    setState(() => _busy = true);
    try {
      if (enabled && !await _notifications.requestPermissions()) {
        if (mounted) {
          _status(
            'اسمح بالإشعارات من إعدادات الجهاز.',
            'Allow notifications in your device settings.',
          );
        }
        return;
      }
      await settings.updateNotificationsEnabled(enabled);
    } catch (_) {
      if (mounted) {
        _status(
          'تعذّر ضبط التنبيهات.',
          'Notifications could not be configured.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _status(String ar, String en) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(appText(context, ar, en))));

  Future<void> _previewAdhan(double volume) async {
    final player = _preview ??= AudioPlayer();
    if (_playing) {
      setState(() => _playing = false);
      await player.stop();
      return;
    }
    setState(() => _playing = true);
    try {
      await player.setAsset(AdhanSound.local.assetPath);
      await player.setVolume(volume);
      if (mounted && _playing) await player.play();
    } catch (_) {
      if (mounted && _playing) {
        _status('تعذّر تشغيل المعاينة.', 'The preview could not play.');
      }
    } finally {
      if (mounted && _playing) setState(() => _playing = false);
    }
  }

  Future<void> _store(String key, bool value) async {
    await _prefs.setBool(key, value);
    if (mounted) setState(() {});
    await _notifications.refresh();
  }

  Future<void> _time(String key, TimeOfDay initial) async {
    final value = await showTimePicker(context: context, initialTime: initial);
    if (value == null || !mounted) return;
    await _prefs.setInt('${key}_reminder_hour', value.hour);
    await _prefs.setInt('${key}_reminder_minute', value.minute);
    if (mounted) setState(() {});
    await _notifications.refresh();
  }

  @override
  void dispose() {
    _preview?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SettingsCubit>();
    final settings = cubit.currentSettings;
    final prayers = _prefs.getBool('prayer_time_notifications') ?? true;
    final adhan = settings.selectedAdhan == AdhanSound.system
        ? AdhanSound.system
        : AdhanSound.local;
    final names = [
      ('Fajr', 'الفجر'),
      ('Sunrise', 'الشروق'),
      ('Dhuhr', 'الظهر'),
      ('Asr', 'العصر'),
      ('Maghrib', 'المغرب'),
      ('Isha', 'العشاء'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(appText(context, 'التنبيهات', 'Notifications')),
      ),
      body: SafeArea(
        top: false,
        child: ContentFrame(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: SwitchListTile.adaptive(
                  title: Text(
                    appText(context, 'تفعيل التنبيهات', 'Enable notifications'),
                  ),
                  value: settings.notificationsEnabled,
                  onChanged: _busy ? null : _toggle,
                ),
              ),
              if (settings.notificationsEnabled) ...[
                const SizedBox(height: 14),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        title: Text(
                          appText(context, 'مواقيت الصلاة', 'Prayer alerts'),
                        ),
                        value: prayers,
                        onChanged: (value) =>
                            _store('prayer_time_notifications', value),
                      ),
                      if (prayers) ...[
                        if (Platform.isAndroid)
                          ListTile(
                            leading: const Icon(Icons.alarm),
                            title: Text(
                              appText(
                                context,
                                'دقة موعد التنبيه',
                                'Exact prayer alerts',
                              ),
                            ),
                            subtitle: Text(
                              appText(
                                context,
                                'اضبط إذن المنبّه في إعدادات الجهاز.',
                                'Manage exact alarm access in device settings.',
                              ),
                            ),
                            trailing: Icon(appChevron(context)),
                            onTap: () async {
                              try {
                                final granted = await _notifications
                                    .requestExactPrayerAlarms();
                                if (!mounted) return;
                                if (granted) {
                                  _status(
                                    'التنبيهات الدقيقة متاحة.',
                                    'Exact alerts are available.',
                                  );
                                } else {
                                  _status(
                                    'هيستمر التنبيه في أقرب وقت يسمح به النظام.',
                                    'Alerts will use the nearest time the system allows.',
                                  );
                                }
                              } catch (_) {
                                if (mounted) {
                                  _status(
                                    'تعذّر ضبط دقة التنبيه.',
                                    'Could not change exact alerts.',
                                  );
                                }
                              }
                            },
                          ),
                        for (final (name, arabic) in names)
                          SwitchListTile.adaptive(
                            title: Text(appText(context, arabic, name)),
                            value: settings.perPrayerEnabled.isEnabled(name),
                            onChanged: (value) =>
                                cubit.updatePrayerNotification(name, value),
                          ),
                        settingsChoice<int>(
                          context,
                          icon: Icons.timer_outlined,
                          title: appText(
                            context,
                            'تذكير قبل الصلاة',
                            'Before-prayer reminder',
                          ),
                          current: settings.prePrayerOffsetMinutes,
                          values: const [0, 5, 10, 15, 20, 30, 45, 60],
                          label: (minutes) => minutes == 0
                              ? appText(context, 'متوقف', 'Off')
                              : appText(
                                  context,
                                  '$minutes دقيقة',
                                  '$minutes min',
                                ),
                          onSelected: cubit.updatePrePrayerOffset,
                        ),
                        SwitchListTile.adaptive(
                          title: Text(
                            appText(
                              context,
                              'صوت الأذان مع التنبيه',
                              'Adhan sound for prayer alerts',
                            ),
                          ),
                          subtitle: Text(
                            Platform.isAndroid
                                ? appText(
                                    context,
                                    'فعّل دقة التنبيه لتشغيل الأذان الكامل في الخلفية.',
                                    'Enable exact alerts for the full adhan in the background.',
                                  )
                                : appText(
                                    context,
                                    'اضغط على التنبيه لسماع التسجيل الكامل بعد المقطع القصير.',
                                    'Tap the short alert to hear the full recording.',
                                  ),
                          ),
                          value: settings.muadhinMode,
                          onChanged: cubit.updateMuadhinMode,
                        ),
                        if (settings.muadhinMode) ...[
                          settingsChoice<AdhanSound>(
                            context,
                            icon: Icons.music_note_outlined,
                            title: appText(
                              context,
                              'صوت التنبيه',
                              'Alert sound',
                            ),
                            current: adhan,
                            values: const [AdhanSound.local, AdhanSound.system],
                            label: (sound) => appText(
                              context,
                              sound.displayName,
                              sound == AdhanSound.local
                                  ? 'Tamanina adhan'
                                  : 'System sound',
                            ),
                            onSelected: cubit.updateSelectedAdhan,
                          ),
                          if (adhan == AdhanSound.local && settings.muadhinMode)
                            ListTile(
                              leading: Icon(
                                _playing ? Icons.stop : Icons.play_arrow,
                              ),
                              title: Text(
                                _playing
                                    ? appText(
                                        context,
                                        'إيقاف المعاينة',
                                        'Stop preview',
                                      )
                                    : appText(
                                        context,
                                        'معاينة الأذان',
                                        'Preview adhan',
                                      ),
                              ),
                              onTap: () => _previewAdhan(settings.adhanVolume),
                            ),
                          if (adhan == AdhanSound.local && settings.muadhinMode)
                            ListTile(
                              leading: const Icon(Icons.fullscreen),
                              title: Text(
                                appText(
                                  context,
                                  'شاشة الأذان الكاملة التفاعلية',
                                  'Interactive full-screen Adhan',
                                ),
                              ),
                              subtitle: Text(
                                appText(
                                  context,
                                  'عرض الأذان مع تتبع الكلمات والتكبير التلقائي',
                                  'Word-by-word tracking with audio recitation',
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.adhan,
                                  arguments: const AdhanScreenArgs(
                                    prayerNameArabic: 'العصر',
                                    prayerName: 'Asr',
                                  ),
                                );
                              },
                            ),
                          if (adhan == AdhanSound.local)
                            ListTile(
                              title: Text(
                                appText(
                                  context,
                                  'مستوى صوت المعاينة',
                                  'Preview volume',
                                ),
                              ),
                              subtitle: Slider(
                                value: settings.adhanVolume.clamp(0, 1),
                                onChanged: (value) {
                                  cubit.updateAdhanVolume(value);
                                  _preview?.setVolume(value);
                                },
                              ),
                            ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Column(
                    children: [
                      settingsChoice<int>(
                        context,
                        icon: Icons.wb_sunny_outlined,
                        title: appText(
                          context,
                          'تذكير بالذِّكر خلال اليوم',
                          'Dhikr throughout the day',
                        ),
                        current: _prefs.getInt('dhikr_interval_minutes') ?? 0,
                        values: dhikrIntervals,
                        label: (minutes) {
                          if (minutes == 0) {
                            return appText(context, 'متوقف', 'Off');
                          }
                          if (minutes == 60) {
                            return appText(context, 'كل ساعة', 'Every hour');
                          }
                          if (minutes == 120) {
                            return appText(
                              context,
                              'كل ساعتين',
                              'Every 2 hours',
                            );
                          }
                          return appText(
                            context,
                            'كل ${minutes ~/ 60} ساعات',
                            'Every ${minutes ~/ 60} hours',
                          );
                        },
                        onSelected: (minutes) async {
                          await _prefs.setInt(
                            'dhikr_interval_minutes',
                            minutes,
                          );
                          if (mounted) setState(() {});
                          await _notifications.refresh();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16,
                          0,
                          16,
                          8,
                        ),
                        child: Text(
                          appText(
                            context,
                            'بين التاسعة صباحًا والتاسعة مساءً، حسب ساعات الهدوء.',
                            'Between 9 AM and 9 PM, outside your quiet hours.',
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      for (final (key, hour, arabic, english) in const [
                        ('morning', 6, 'أذكار الصباح', 'Morning adhkar'),
                        ('evening', 17, 'أذكار المساء', 'Evening adhkar'),
                        ('sleep', 22, 'أذكار النوم', 'Bedtime adhkar'),
                      ])
                        _reminder(key, hour, appText(context, arabic, english)),
                      SwitchListTile.adaptive(
                        title: Text(
                          appText(context, 'تذكير الجمعة', 'Friday reminder'),
                        ),
                        value: _prefs.getBool('friday_reminder') ?? false,
                        onChanged: (value) => _store('friday_reminder', value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Column(
                    children: [
                      for (final (key, ar, en) in const [
                        (
                          'notification_sound',
                          'صوت التنبيهات',
                          'Notification sound',
                        ),
                        (
                          'notification_vibration',
                          'اهتزاز التنبيهات',
                          'Notification vibration',
                        ),
                      ])
                        SwitchListTile.adaptive(
                          title: Text(appText(context, ar, en)),
                          value: _prefs.getBool(key) ?? true,
                          onChanged: (value) => _store(key, value),
                        ),
                      SwitchListTile.adaptive(
                        title: Text(
                          appText(context, 'ساعات الهدوء', 'Quiet hours'),
                        ),
                        subtitle: Text(
                          appText(
                            context,
                            'تنبيهات الصلاة صامتة، وتذكيرات الذِّكر تتوقف خلالها.',
                            'Prayer alerts are silent and dhikr reminders pause.',
                          ),
                        ),
                        value: settings.quietHoursEnabled,
                        onChanged: (value) =>
                            cubit.updateQuietHours(enabled: value),
                      ),
                      if (settings.quietHoursEnabled)
                        for (final (isStart, hour) in [
                          (true, settings.quietHoursStart),
                          (false, settings.quietHoursEnd),
                        ])
                          settingsChoice<int>(
                            context,
                            icon: Icons.bedtime_outlined,
                            title: isStart
                                ? appText(context, 'تبدأ', 'Starts')
                                : appText(context, 'تنتهي', 'Ends'),
                            current: hour,
                            values: List.generate(24, (hour) => hour),
                            label: (hour) => TimeOfDay(
                              hour: hour,
                              minute: 0,
                            ).format(context),
                            onSelected: (hour) => cubit.updateQuietHours(
                              start: isStart ? hour : null,
                              end: isStart ? null : hour,
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _reminder(String key, int defaultHour, String title) {
    final preference = '${key}_adhkar_reminder';
    final enabled = _prefs.getBool(preference) ?? false;
    final time = TimeOfDay(
      hour: _prefs.getInt('${key}_reminder_hour') ?? defaultHour,
      minute: _prefs.getInt('${key}_reminder_minute') ?? 0,
    );
    return Column(
      children: [
        SwitchListTile.adaptive(
          title: Text(title),
          value: enabled,
          onChanged: (value) => _store(preference, value),
        ),
        if (enabled)
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: Text(appText(context, 'موعد التذكير', 'Reminder time')),
            trailing: Text(time.format(context)),
            onTap: () => _time(key, time),
          ),
      ],
    );
  }
}
