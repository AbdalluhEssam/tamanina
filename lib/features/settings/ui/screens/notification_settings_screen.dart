import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// صفحة إعدادات الإشعارات
/// Notification Settings Screen
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // إعدادات الإشعارات
  bool _notificationsEnabled = true;
  bool _prayerTimeNotifications = true;
  bool _morningAdhkarReminder = true;
  bool _eveningAdhkarReminder = true;
  bool _sleepAdhkarReminder = false;
  bool _fridayReminder = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // أوقات التذكير
  TimeOfDay _morningReminderTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _eveningReminderTime = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay _sleepReminderTime = const TimeOfDay(hour: 22, minute: 0);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _prayerTimeNotifications =
          prefs.getBool('prayer_time_notifications') ?? true;
      _morningAdhkarReminder = prefs.getBool('morning_adhkar_reminder') ?? true;
      _eveningAdhkarReminder = prefs.getBool('evening_adhkar_reminder') ?? true;
      _sleepAdhkarReminder = prefs.getBool('sleep_adhkar_reminder') ?? false;
      _fridayReminder = prefs.getBool('friday_reminder') ?? true;
      _soundEnabled = prefs.getBool('notification_sound') ?? true;
      _vibrationEnabled = prefs.getBool('notification_vibration') ?? true;

      // تحميل أوقات التذكير
      final morningHour = prefs.getInt('morning_reminder_hour') ?? 6;
      final morningMinute = prefs.getInt('morning_reminder_minute') ?? 0;
      _morningReminderTime =
          TimeOfDay(hour: morningHour, minute: morningMinute);

      final eveningHour = prefs.getInt('evening_reminder_hour') ?? 17;
      final eveningMinute = prefs.getInt('evening_reminder_minute') ?? 0;
      _eveningReminderTime =
          TimeOfDay(hour: eveningHour, minute: eveningMinute);

      final sleepHour = prefs.getInt('sleep_reminder_hour') ?? 22;
      final sleepMinute = prefs.getInt('sleep_reminder_minute') ?? 0;
      _sleepReminderTime = TimeOfDay(hour: sleepHour, minute: sleepMinute);

      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('prayer_time_notifications', _prayerTimeNotifications);
    await prefs.setBool('morning_adhkar_reminder', _morningAdhkarReminder);
    await prefs.setBool('evening_adhkar_reminder', _eveningAdhkarReminder);
    await prefs.setBool('sleep_adhkar_reminder', _sleepAdhkarReminder);
    await prefs.setBool('friday_reminder', _fridayReminder);
    await prefs.setBool('notification_sound', _soundEnabled);
    await prefs.setBool('notification_vibration', _vibrationEnabled);

    // حفظ أوقات التذكير
    await prefs.setInt('morning_reminder_hour', _morningReminderTime.hour);
    await prefs.setInt('morning_reminder_minute', _morningReminderTime.minute);
    await prefs.setInt('evening_reminder_hour', _eveningReminderTime.hour);
    await prefs.setInt('evening_reminder_minute', _eveningReminderTime.minute);
    await prefs.setInt('sleep_reminder_hour', _sleepReminderTime.hour);
    await prefs.setInt('sleep_reminder_minute', _sleepReminderTime.minute);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حفظ الإعدادات بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    }
  }

  Future<void> _selectTime(
      TimeOfDay initialTime, Function(TimeOfDay) onSelect) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              surface: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : Colors.white,
              onSurface: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onSelect(picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'ص' : 'م';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'إعدادات الإشعارات',
          style: AppTypography.appBarTitle.copyWith(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined, color: Colors.white),
            onPressed: _saveSettings,
            tooltip: 'حفظ الإعدادات',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // التحكم الرئيسي في الإشعارات
                  _buildMainSwitch(isDark),
                  SizedBox(height: 24.h),

                  // إشعارات أوقات الصلاة
                  if (_notificationsEnabled) ...[
                    _buildSectionHeader(
                        'أوقات الصلاة', Icons.access_time, isDark),
                    SizedBox(height: 12.h),
                    _buildSettingCard(
                      children: [
                        _buildSwitchTile(
                          title: 'تنبيهات أوقات الصلاة',
                          subtitle: 'إشعار عند دخول وقت كل صلاة',
                          icon: Icons.mosque_outlined,
                          value: _prayerTimeNotifications,
                          onChanged: (value) {
                            setState(() => _prayerTimeNotifications = value);
                          },
                          isDark: isDark,
                        ),
                      ],
                      isDark: isDark,
                    ),
                    SizedBox(height: 24.h),

                    // تذكيرات الأذكار
                    _buildSectionHeader('تذكيرات الأذكار',
                        Icons.notifications_active_outlined, isDark),
                    SizedBox(height: 12.h),
                    _buildSettingCard(
                      children: [
                        _buildSwitchTile(
                          title: 'أذكار الصباح',
                          subtitle: 'تذكير يومي بأذكار الصباح',
                          icon: Icons.wb_sunny_outlined,
                          value: _morningAdhkarReminder,
                          onChanged: (value) {
                            setState(() => _morningAdhkarReminder = value);
                          },
                          isDark: isDark,
                        ),
                        if (_morningAdhkarReminder)
                          _buildTimePicker(
                            label: 'وقت التذكير',
                            time: _morningReminderTime,
                            onTap: () =>
                                _selectTime(_morningReminderTime, (time) {
                              setState(() => _morningReminderTime = time);
                            }),
                            isDark: isDark,
                          ),
                        const Divider(),
                        _buildSwitchTile(
                          title: 'أذكار المساء',
                          subtitle: 'تذكير يومي بأذكار المساء',
                          icon: Icons.nights_stay_outlined,
                          value: _eveningAdhkarReminder,
                          onChanged: (value) {
                            setState(() => _eveningAdhkarReminder = value);
                          },
                          isDark: isDark,
                        ),
                        if (_eveningAdhkarReminder)
                          _buildTimePicker(
                            label: 'وقت التذكير',
                            time: _eveningReminderTime,
                            onTap: () =>
                                _selectTime(_eveningReminderTime, (time) {
                              setState(() => _eveningReminderTime = time);
                            }),
                            isDark: isDark,
                          ),
                        const Divider(),
                        _buildSwitchTile(
                          title: 'أذكار النوم',
                          subtitle: 'تذكير بأذكار قبل النوم',
                          icon: Icons.bedtime_outlined,
                          value: _sleepAdhkarReminder,
                          onChanged: (value) {
                            setState(() => _sleepAdhkarReminder = value);
                          },
                          isDark: isDark,
                        ),
                        if (_sleepAdhkarReminder)
                          _buildTimePicker(
                            label: 'وقت التذكير',
                            time: _sleepReminderTime,
                            onTap: () =>
                                _selectTime(_sleepReminderTime, (time) {
                              setState(() => _sleepReminderTime = time);
                            }),
                            isDark: isDark,
                          ),
                      ],
                      isDark: isDark,
                    ),
                    SizedBox(height: 24.h),

                    // تذكيرات خاصة
                    _buildSectionHeader(
                        'تذكيرات خاصة', Icons.star_outline, isDark),
                    SizedBox(height: 12.h),
                    _buildSettingCard(
                      children: [
                        _buildSwitchTile(
                          title: 'تذكير يوم الجمعة',
                          subtitle:
                              'تذكير بقراءة سورة الكهف والإكثار من الصلاة على النبي ﷺ',
                          icon: Icons.calendar_today_outlined,
                          value: _fridayReminder,
                          onChanged: (value) {
                            setState(() => _fridayReminder = value);
                          },
                          isDark: isDark,
                        ),
                      ],
                      isDark: isDark,
                    ),
                    SizedBox(height: 24.h),

                    // إعدادات الصوت والاهتزاز
                    _buildSectionHeader(
                        'الصوت والاهتزاز', Icons.volume_up_outlined, isDark),
                    SizedBox(height: 12.h),
                    _buildSettingCard(
                      children: [
                        _buildSwitchTile(
                          title: 'صوت الإشعارات',
                          subtitle: 'تشغيل صوت عند وصول الإشعار',
                          icon: Icons.music_note_outlined,
                          value: _soundEnabled,
                          onChanged: (value) {
                            setState(() => _soundEnabled = value);
                          },
                          isDark: isDark,
                        ),
                        const Divider(),
                        _buildSwitchTile(
                          title: 'الاهتزاز',
                          subtitle: 'اهتزاز الجهاز عند وصول الإشعار',
                          icon: Icons.vibration,
                          value: _vibrationEnabled,
                          onChanged: (value) {
                            setState(() => _vibrationEnabled = value);
                          },
                          isDark: isDark,
                        ),
                      ],
                      isDark: isDark,
                    ),
                  ],

                  SizedBox(height: 32.h),

                  // معلومات إضافية
                  _buildInfoCard(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildMainSwitch(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _notificationsEnabled
              ? [
                  AppColors.primaryGreen,
                  AppColors.primaryGreen.withOpacity(0.8)
                ]
              : [Colors.grey, Colors.grey.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color:
                (_notificationsEnabled ? AppColors.primaryGreen : Colors.grey)
                    .withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإشعارات',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _notificationsEnabled ? 'مفعّلة' : 'معطّلة',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.white.withOpacity(0.3),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryGreen,
          size: 20.sp,
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: (value ? AppColors.primaryGreen : Colors.grey)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.primaryGreen : Colors.grey,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 56.w, bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: AppColors.primaryGreen.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                color: AppColors.primaryGreen,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '$label: ${_formatTime(time)}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.edit,
                color: AppColors.primaryGreen,
                size: 14.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.info,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملاحظة',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'تأكد من السماح للتطبيق بإرسال الإشعارات في إعدادات جهازك. قد تختلف دقة التذكيرات حسب نظام التشغيل وإعدادات توفير الطاقة.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
