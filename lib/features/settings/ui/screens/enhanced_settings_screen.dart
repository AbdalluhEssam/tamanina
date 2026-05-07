import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/cubit/theme/theme_cubit.dart';
import '../../../../core/services/prayer_service.dart';
import '../../../../core/services/location_service.dart';

/// شاشة الإعدادات المحسنة
/// Enhanced Settings Screen
class EnhancedSettingsScreen extends StatefulWidget {
  const EnhancedSettingsScreen({super.key});

  @override
  State<EnhancedSettingsScreen> createState() => _EnhancedSettingsScreenState();
}

class _EnhancedSettingsScreenState extends State<EnhancedSettingsScreen> {
  final PrayerService _prayerService = PrayerService();

  // Settings state
  bool _notificationsEnabled = true;
  bool _adhanEnabled = true;
  bool _muadhinMode = false;
  bool _vibrationEnabled = true;
  int _reminderMinutes = 15;
  PrayerCalculationMethod _calculationMethod =
      PrayerCalculationMethod.ummAlQura;
  AsrMadhab _madhab = AsrMadhab.shafi;
  String _selectedAdhan = 'adhan_makkah.mp3';

  // Prayer notification toggles
  bool _fajrNotification = true;
  bool _sunriseNotification = false;
  bool _dhuhrNotification = true;
  bool _asrNotification = true;
  bool _maghribNotification = true;
  bool _ishaNotification = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _prayerService.initialize();
    setState(() {
      _calculationMethod = _prayerService.calculationMethod;
      _madhab = _prayerService.madhab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: AppTypography.appBarTitle.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Theme Settings
          _buildSection(
            title: 'المظهر',
            icon: Icons.palette_rounded,
            children: [
              _buildThemeSelector(isDark),
            ],
          ),

          SizedBox(height: 16.h),

          // Prayer Calculation Settings
          _buildSection(
            title: 'حساب أوقات الصلاة',
            icon: Icons.calculate_rounded,
            children: [
              _buildCalculationMethodSelector(isDark),
              SizedBox(height: 12.h),
              _buildMadhabSelector(isDark),
            ],
          ),

          SizedBox(height: 16.h),

          // Location Settings
          _buildSection(
            title: 'الموقع',
            icon: Icons.location_on_rounded,
            children: [
              _buildLocationSettings(isDark),
            ],
          ),

          SizedBox(height: 16.h),

          // Notification Settings
          _buildSection(
            title: 'الإشعارات',
            icon: Icons.notifications_rounded,
            children: [
              _buildSwitchTile(
                title: 'تفعيل الإشعارات',
                subtitle: 'إشعارات أوقات الصلاة',
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
                isDark: isDark,
              ),
              if (_notificationsEnabled) ...[
                _buildDivider(),
                _buildPrayerNotificationToggles(isDark),
                _buildDivider(),
                _buildReminderSelector(isDark),
              ],
            ],
          ),

          SizedBox(height: 16.h),

          // Adhan Settings
          _buildSection(
            title: 'الأذان',
            icon: Icons.campaign_rounded,
            children: [
              _buildSwitchTile(
                title: 'تشغيل الأذان',
                subtitle: 'تشغيل صوت الأذان عند وقت الصلاة',
                value: _adhanEnabled,
                onChanged: (v) => setState(() => _adhanEnabled = v),
                isDark: isDark,
              ),
              if (_adhanEnabled) ...[
                _buildDivider(),
                _buildSwitchTile(
                  title: 'وضع المؤذن',
                  subtitle: 'شاشة كاملة عند الأذان',
                  value: _muadhinMode,
                  onChanged: (v) => setState(() => _muadhinMode = v),
                  isDark: isDark,
                ),
                _buildDivider(),
                _buildAdhanSelector(isDark),
              ],
            ],
          ),

          SizedBox(height: 16.h),

          // Sound & Haptics
          _buildSection(
            title: 'الصوت واللمس',
            icon: Icons.vibration_rounded,
            children: [
              _buildSwitchTile(
                title: 'الاهتزاز',
                subtitle: 'اهتزاز عند التسبيح والأذكار',
                value: _vibrationEnabled,
                onChanged: (v) => setState(() => _vibrationEnabled = v),
                isDark: isDark,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // About Section
          _buildSection(
            title: 'حول التطبيق',
            icon: Icons.info_rounded,
            children: [
              _buildListTile(
                title: 'النسخة',
                subtitle: '1.0.0',
                icon: Icons.info_outline_rounded,
                isDark: isDark,
              ),
              _buildDivider(),
              _buildListTile(
                title: 'سياسة الخصوصية',
                icon: Icons.privacy_tip_rounded,
                isDark: isDark,
                onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
              ),
              _buildDivider(),
              _buildListTile(
                title: 'شروط الاستخدام',
                icon: Icons.description_rounded,
                isDark: isDark,
                onTap: () => Navigator.pushNamed(context, '/terms-of-service'),
              ),
            ],
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: AppColors.primaryGreen, size: 20.w),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: AppTypography.labelLargeArabic.copyWith(
                    color: isDark
                        ? AppColors.textOnSurfaceDark
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider.withOpacity(0.3)),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر المظهر',
          style: AppTypography.bodyMediumArabic.copyWith(
            color: isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildThemeOption(
                title: 'فاتح',
                icon: Icons.light_mode_rounded,
                isSelected: !isDark,
                onTap: () =>
                    context.read<ThemeCubit>().changeTheme(ThemeMode.light),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildThemeOption(
                title: 'داكن',
                icon: Icons.dark_mode_rounded,
                isSelected: isDark,
                onTap: () =>
                    context.read<ThemeCubit>().changeTheme(ThemeMode.dark),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildThemeOption(
                title: 'النظام',
                icon: Icons.settings_brightness_rounded,
                isSelected: false, // TODO: Check system mode
                onTap: () =>
                    context.read<ThemeCubit>().changeTheme(ThemeMode.system),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
              size: 24.w,
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationMethodSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة الحساب',
          style: AppTypography.bodyMediumArabic.copyWith(
            color: isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButton<PrayerCalculationMethod>(
            value: _calculationMethod,
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryGreen),
            items: PrayerCalculationMethod.values.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(
                  _prayerService.getCalculationMethodName(method),
                  style: TextStyle(fontSize: 14.sp),
                ),
              );
            }).toList(),
            onChanged: (value) async {
              if (value != null) {
                setState(() => _calculationMethod = value);
                await _prayerService.setCalculationMethod(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMadhabSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مذهب حساب العصر',
          style: AppTypography.bodyMediumArabic.copyWith(
            color: isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: AsrMadhab.values.map((madhab) {
            final isSelected = _madhab == madhab;
            return Expanded(
              child: GestureDetector(
                onTap: () async {
                  setState(() => _madhab = madhab);
                  await _prayerService.setMadhab(madhab);
                },
                child: Container(
                  margin: EdgeInsets.only(
                    left: madhab == AsrMadhab.hanafi ? 12.w : 0,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGreen.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.divider,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _prayerService.getMadhabName(madhab),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isSelected
                            ? AppColors.primaryGreen
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSettings(bool isDark) {
    return Column(
      children: [
        _buildListTile(
          title: 'استخدام الموقع التلقائي',
          subtitle: 'تحديد الموقع عبر GPS',
          icon: Icons.gps_fixed_rounded,
          isDark: isDark,
          trailing: Switch(
            value: !_prayerService.useManualLocation,
            activeColor: AppColors.primaryGreen,
            onChanged: (v) async {
              await _prayerService.setUseManualLocation(!v);
              setState(() {});
            },
          ),
        ),
        if (_prayerService.useManualLocation) ...[
          _buildDivider(),
          _buildListTile(
            title: 'اختيار المدينة',
            subtitle: 'تحديد المدينة يدوياً',
            icon: Icons.location_city_rounded,
            isDark: isDark,
            onTap: () => _showCitySelector(isDark),
          ),
        ],
      ],
    );
  }

  void _showCitySelector(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اختر المدينة',
              style: AppTypography.h6Arabic.copyWith(
                color: isDark
                    ? AppColors.textOnSurfaceDark
                    : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: popularCities.length,
                itemBuilder: (context, index) {
                  final city = popularCities[index];
                  return ListTile(
                    leading: Icon(Icons.location_city_rounded,
                        color: AppColors.primaryGreen),
                    title: Text(city.nameArabic),
                    subtitle: Text(city.nameEnglish),
                    onTap: () async {
                      await _prayerService.setManualLocation(
                        city: city.nameArabic,
                        country: city.country,
                        latitude: city.latitude,
                        longitude: city.longitude,
                      );
                      Navigator.pop(context);
                      setState(() {});
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerNotificationToggles(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إشعارات الصلوات',
          style: AppTypography.bodyMediumArabic.copyWith(
            color: isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildPrayerChip('الفجر', _fajrNotification,
                (v) => setState(() => _fajrNotification = v)),
            _buildPrayerChip('الشروق', _sunriseNotification,
                (v) => setState(() => _sunriseNotification = v)),
            _buildPrayerChip('الظهر', _dhuhrNotification,
                (v) => setState(() => _dhuhrNotification = v)),
            _buildPrayerChip('العصر', _asrNotification,
                (v) => setState(() => _asrNotification = v)),
            _buildPrayerChip('المغرب', _maghribNotification,
                (v) => setState(() => _maghribNotification = v)),
            _buildPrayerChip('العشاء', _ishaNotification,
                (v) => setState(() => _ishaNotification = v)),
          ],
        ),
      ],
    );
  }

  Widget _buildPrayerChip(String label, bool value, Function(bool) onChanged) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      selectedColor: AppColors.primaryGreen.withOpacity(0.2),
      checkmarkColor: AppColors.primaryGreen,
      labelStyle: TextStyle(
        color: value ? AppColors.primaryGreen : AppColors.textSecondary,
        fontWeight: value ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildReminderSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التذكير قبل الصلاة',
          style: AppTypography.bodyMediumArabic.copyWith(
            color: isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [0, 5, 10, 15, 30].map((minutes) {
            final isSelected = _reminderMinutes == minutes;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _reminderMinutes = minutes),
                child: Container(
                  margin: EdgeInsets.only(left: minutes != 0 ? 8.w : 0),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGreen.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.divider,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      minutes == 0 ? 'لا' : '$minutes د',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isSelected
                            ? AppColors.primaryGreen
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdhanSelector(bool isDark) {
    final adhans = [
      {'id': 'adhan_makkah.mp3', 'name': 'أذان الحرم المكي'},
      {'id': 'adhan_madinah.mp3', 'name': 'أذان الحرم المدني'},
      {'id': 'adhan_default.mp3', 'name': 'الأذان الافتراضي'},
      {'id': 'system', 'name': 'صوت النظام'},
      {'id': 'silent', 'name': 'صامت'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'صوت الأذان',
          style: AppTypography.bodyMediumArabic.copyWith(
            color: isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        ...adhans.map((adhan) {
          return RadioListTile<String>(
            title: Text(adhan['name']!),
            value: adhan['id']!,
            groupValue: _selectedAdhan,
            activeColor: AppColors.primaryGreen,
            contentPadding: EdgeInsets.zero,
            dense: true,
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedAdhan = v);
              }
            },
          );
        }),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMediumArabic.copyWith(
                  color: isDark
                      ? AppColors.textOnSurfaceDark
                      : AppColors.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: AppTypography.captionArabic.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: AppColors.primaryGreen,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool isDark,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 22.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMediumArabic.copyWith(
                      color: isDark
                          ? AppColors.textOnSurfaceDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppTypography.captionArabic.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSecondary, size: 16.w),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Divider(height: 1, color: AppColors.divider.withOpacity(0.3)),
    );
  }
}
