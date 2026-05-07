import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/settings/settings_repository.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/cubit/theme/theme_cubit.dart';
import '../../../../core/services/notification_service_enhanced.dart';

/// شاشة الإعدادات الكاملة
/// Complete Settings Screen
class ProductionSettingsScreen extends StatefulWidget {
  const ProductionSettingsScreen({super.key});

  @override
  State<ProductionSettingsScreen> createState() =>
      _ProductionSettingsScreenState();
}

class _ProductionSettingsScreenState extends State<ProductionSettingsScreen> {
  final NotificationServiceEnhanced _notificationService =
      NotificationServiceEnhanced();

  /// مشغل صوت معاينة الأذان
  /// Audio player for adhan preview
  final AudioPlayer _previewPlayer = AudioPlayer();

  /// الأذان قيد المعاينة حالياً
  /// Currently previewing adhan
  AdhanSound? _previewingAdhan;

  /// هل يتم تشغيل المعاينة
  /// Is preview playing
  bool _isPreviewPlaying = false;

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  /// تشغيل معاينة الأذان
  /// Play adhan preview
  Future<void> _playAdhanPreview(AdhanSound adhan) async {
    // إيقاف أي معاينة قيد التشغيل
    await _stopAdhanPreview();

    if (adhan == AdhanSound.system) {
      // صوت النظام - لا يمكن معاينته
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('سيتم استخدام صوت النظام الافتراضي'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _previewingAdhan = adhan;
      _isPreviewPlaying = true;
    });

    try {
      await _previewPlayer.setAsset(adhan.assetPath);
      // تشغيل 10 ثوانٍ فقط كمعاينة
      await _previewPlayer.setClip(
        start: Duration.zero,
        end: const Duration(seconds: 10),
      );
      await _previewPlayer.play();

      // إيقاف المعاينة بعد 10 ثوانٍ
      _previewPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _stopAdhanPreview();
        }
      });
    } catch (e) {
      setState(() {
        _previewingAdhan = null;
        _isPreviewPlaying = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تشغيل المعاينة: $e')),
        );
      }
    }
  }

  /// إيقاف معاينة الأذان
  /// Stop adhan preview
  Future<void> _stopAdhanPreview() async {
    await _previewPlayer.stop();
    if (mounted) {
      setState(() {
        _previewingAdhan = null;
        _isPreviewPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state is! SettingsLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final settings = state.settings;

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
            actions: [
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: () => _showResetDialog(context),
                tooltip: 'إعادة تعيين',
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // قسم المظهر
              _buildSection(
                title: 'المظهر',
                icon: Icons.palette_rounded,
                children: [
                  _buildThemeSelector(context, settings, isDark),
                  _buildDivider(),
                  _buildFontSelector(context, settings, isDark),
                ],
              ),

              SizedBox(height: 16.h),

              // قسم حساب أوقات الصلاة
              _buildSection(
                title: 'حساب أوقات الصلاة',
                icon: Icons.calculate_rounded,
                children: [
                  _buildCalculationMethodSelector(context, settings, isDark),
                  SizedBox(height: 12.h),
                  _buildMadhabSelector(context, settings, isDark),
                ],
              ),

              SizedBox(height: 16.h),

              // قسم الإشعارات
              _buildSection(
                title: 'الإشعارات',
                icon: Icons.notifications_rounded,
                children: [
                  _buildSwitchTile(
                    title: 'تفعيل الإشعارات',
                    subtitle: 'إشعارات أوقات الصلاة',
                    value: settings.notificationsEnabled,
                    onChanged: (v) {
                      context
                          .read<SettingsCubit>()
                          .updateNotificationsEnabled(v);
                    },
                    isDark: isDark,
                  ),
                  if (settings.notificationsEnabled) ...[
                    _buildDivider(),
                    _buildPerPrayerToggles(context, settings, isDark),
                    _buildDivider(),
                    _buildPrePrayerReminderSelector(context, settings, isDark),
                  ],
                ],
              ),

              SizedBox(height: 16.h),

              // قسم الأذان
              _buildSection(
                title: 'الأذان',
                icon: Icons.campaign_rounded,
                children: [
                  _buildSwitchTile(
                    title: 'وضع المؤذن',
                    subtitle: 'تشغيل صوت الأذان عند وقت الصلاة',
                    value: settings.muadhinMode,
                    onChanged: (v) async {
                      if (v) {
                        // طلب صلاحية تجاوز عدم الإزعاج
                        await _notificationService
                            .showDNDPermissionDialog(context);
                      }
                      if (mounted) {
                        context.read<SettingsCubit>().updateMuadhinMode(v);
                      }
                    },
                    isDark: isDark,
                  ),
                  if (settings.muadhinMode) ...[
                    _buildDivider(),
                    _buildAdhanSelector(context, settings, isDark),
                    _buildDivider(),
                    _buildVolumeSlider(context, settings, isDark),
                  ],
                ],
              ),

              SizedBox(height: 16.h),

              // قسم الصوت والاهتزاز
              _buildSection(
                title: 'الصوت واللمس',
                icon: Icons.vibration_rounded,
                children: [
                  _buildSwitchTile(
                    title: 'الاهتزاز',
                    subtitle: 'اهتزاز عند التسبيح والأذكار',
                    value: settings.vibrationEnabled,
                    onChanged: (v) {
                      context.read<SettingsCubit>().updateVibrationEnabled(v);
                    },
                    isDark: isDark,
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // قسم حول التطبيق
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
                    onTap: () =>
                        Navigator.pushNamed(context, '/privacy-policy'),
                  ),
                  _buildDivider(),
                  _buildListTile(
                    title: 'شروط الاستخدام',
                    icon: Icons.description_rounded,
                    isDark: isDark,
                    onTap: () =>
                        Navigator.pushNamed(context, '/terms-of-service'),
                  ),
                ],
              ),

              SizedBox(height: 32.h),
            ],
          ),
        );
      },
    );
  }

  /// بناء قسم
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
          // عنوان القسم
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
                  child: Icon(
                    icon,
                    color: AppColors.primaryGreen,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: AppTypography.h5Arabic.copyWith(
                    color: isDark
                        ? AppColors.textOnSurfaceDark
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  /// بناء محدد السمة
  Widget _buildThemeSelector(
    BuildContext context,
    AppSettings settings,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'وضع المظهر',
            style: AppTypography.bodyMediumArabic.copyWith(
              color:
                  isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildThemeOption(
                context: context,
                title: 'فاتح',
                icon: Icons.light_mode_rounded,
                isSelected: settings.themeMode == ThemeMode.light,
                onTap: () {
                  context
                      .read<SettingsCubit>()
                      .updateThemeMode(ThemeMode.light);
                  context.read<ThemeCubit>().changeTheme(ThemeMode.light);
                },
                isDark: isDark,
              ),
              SizedBox(width: 12.w),
              _buildThemeOption(
                context: context,
                title: 'داكن',
                icon: Icons.dark_mode_rounded,
                isSelected: settings.themeMode == ThemeMode.dark,
                onTap: () {
                  context.read<SettingsCubit>().updateThemeMode(ThemeMode.dark);
                  context.read<ThemeCubit>().changeTheme(ThemeMode.dark);
                },
                isDark: isDark,
              ),
              SizedBox(width: 12.w),
              _buildThemeOption(
                context: context,
                title: 'تلقائي',
                icon: Icons.brightness_auto_rounded,
                isSelected: settings.themeMode == ThemeMode.system,
                onTap: () {
                  context
                      .read<SettingsCubit>()
                      .updateThemeMode(ThemeMode.system);
                  context.read<ThemeCubit>().changeTheme(ThemeMode.system);
                },
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء خيار السمة
  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryGreen
                : (isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? AppColors.primaryGreen : AppColors.divider,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textOnSurfaceDark
                        : AppColors.textSecondary),
                size: 24.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                title,
                style: AppTypography.captionArabic.copyWith(
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.textOnSurfaceDark
                          : AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء محدد الخط العربي
  Widget _buildFontSelector(
    BuildContext context,
    AppSettings settings,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الخط العربي',
            style: AppTypography.bodyMediumArabic.copyWith(
              color:
                  isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          ...ArabicFont.values.map((font) {
            final isSelected = settings.arabicFont == font;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: GestureDetector(
                onTap: () {
                  context.read<SettingsCubit>().updateArabicFont(font);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGreen.withOpacity(0.1)
                        : (isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceLight),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // أيقونة التحديد
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primaryGreen
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : AppColors.divider,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16.sp,
                              )
                            : null,
                      ),
                      SizedBox(width: 12.w),
                      // اسم الخط
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              font.arabicName,
                              style: TextStyle(
                                fontFamily: font.fontFamily,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textOnSurfaceDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                              style: TextStyle(
                                fontFamily: font.fontFamily,
                                fontSize: 14.sp,
                                color: isDark
                                    ? AppColors.textOnSurfaceDark
                                        .withOpacity(0.7)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// بناء محدد طريقة الحساب
  Widget _buildCalculationMethodSelector(
    BuildContext context,
    AppSettings settings,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'طريقة الحساب',
            style: AppTypography.bodyMediumArabic.copyWith(
              color:
                  isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: DropdownButton<PrayerCalculationMethod>(
              value: settings.calculationMethod,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor:
                  isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              items: PrayerCalculationMethod.values.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(
                    method.arabicName,
                    style: AppTypography.bodySmallArabic.copyWith(
                      color: isDark
                          ? AppColors.textOnSurfaceDark
                          : AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (method) {
                if (method != null) {
                  context.read<SettingsCubit>().updateCalculationMethod(method);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// بناء محدد المذهب
  Widget _buildMadhabSelector(
    BuildContext context,
    AppSettings settings,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المذهب (لحساب العصر)',
            style: AppTypography.bodyMediumArabic.copyWith(
              color:
                  isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: Madhab.values.map((madhab) {
              final isSelected = settings.madhab == madhab;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.read<SettingsCubit>().updateMadhab(madhab);
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: madhab != Madhab.values.last ? 8.w : 0,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      madhab.arabicName,
                      textAlign: TextAlign.center,
                      style: AppTypography.captionArabic.copyWith(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.textOnSurfaceDark
                                : AppColors.textSecondary),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// بناء أزرار إشعارات كل صلاة
  Widget _buildPerPrayerToggles(
    BuildContext context,
    AppSettings settings,
    bool isDark,
  ) {
    final perPrayer = settings.perPrayerEnabled;
    final prayers = [
      ('الفجر', 'fajr', perPrayer.fajr),
      ('الظهر', 'dhuhr', perPrayer.dhuhr),
      ('العصر', 'asr', perPrayer.asr),
      ('المغرب', 'maghrib', perPrayer.maghrib),
      ('العشاء', 'isha', perPrayer.isha),
    ];

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إشعارات الصلوات',
            style: AppTypography.bodyMediumArabic.copyWith(
              color:
                  isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: prayers.map((prayer) {
              return FilterChip(
                label: Text(prayer.$1),
                selected: prayer.$3,
                onSelected: (selected) {
                  context
                      .read<SettingsCubit>()
                      .updatePrayerNotification(prayer.$2, selected);
                },
                selectedColor: AppColors.primaryGreen.withOpacity(0.2),
                checkmarkColor: AppColors.primaryGreen,
                labelStyle: AppTypography.captionArabic.copyWith(
                  color: prayer.$3
                      ? AppColors.primaryGreen
                      : (isDark
                          ? AppColors.textOnSurfaceDark
                          : AppColors.textSecondary),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// بناء محدد التذكير قبل الصلاة
  Widget _buildPrePrayerReminderSelector(
    BuildContext context,
    AppSettings settings,
    bool isDark,
  ) {
    final options = [0, 5, 10, 15, 30];

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التذكير قبل الصلاة (دقائق)',
            style: AppTypography.bodyMediumArabic.copyWith(
              color:
                  isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: options.map((minutes) {
              final isSelected = settings.prePrayerOffsetMinutes == minutes;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    context
                        .read<SettingsCubit>()
                        .updatePrePrayerOffset(minutes);
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: minutes != options.last ? 6.w : 0,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      minutes == 0 ? 'إيقاف' : '$minutes',
                      textAlign: TextAlign.center,
                      style: AppTypography.captionArabic.copyWith(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.textOnSurfaceDark
                                : AppColors.textSecondary),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// بناء محدد صوت الأذان
  Widget _buildAdhanSelector(
    BuildContext context,
    AppSettings settings,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'صوت الأذان',
                style: AppTypography.bodyMediumArabic.copyWith(
                  color: isDark
                      ? AppColors.textOnSurfaceDark
                      : AppColors.textPrimary,
                ),
              ),
              if (_isPreviewPlaying)
                TextButton.icon(
                  onPressed: _stopAdhanPreview,
                  icon: Icon(Icons.stop, color: AppColors.error, size: 18.sp),
                  label: Text(
                    'إيقاف',
                    style: AppTypography.captionArabic.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          ...AdhanSound.values.map((adhan) {
            final isSelected = settings.selectedAdhan == adhan;
            final isPreviewing = _previewingAdhan == adhan && _isPreviewPlaying;

            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primaryGreen : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                leading: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.divider.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    adhan == AdhanSound.system
                        ? Icons.phone_android
                        : Icons.mosque,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.textOnSurfaceDark
                            : AppColors.textSecondary),
                    size: 20.sp,
                  ),
                ),
                title: Text(
                  adhan.displayName,
                  style: AppTypography.bodyMediumArabic.copyWith(
                    color: isDark
                        ? AppColors.textOnSurfaceDark
                        : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: adhan != AdhanSound.system
                    ? Text(
                        'اضغط للاستماع',
                        style: AppTypography.captionArabic.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // زر تشغيل المعاينة
                    if (adhan != AdhanSound.system)
                      IconButton(
                        onPressed: () {
                          if (isPreviewing) {
                            _stopAdhanPreview();
                          } else {
                            _playAdhanPreview(adhan);
                          }
                        },
                        icon: Icon(
                          isPreviewing
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          color: isPreviewing
                              ? AppColors.error
                              : AppColors.primaryGreen,
                          size: 32.sp,
                        ),
                      ),
                    // أيقونة التحديد
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primaryGreen,
                        size: 24.sp,
                      ),
                  ],
                ),
                onTap: () {
                  context.read<SettingsCubit>().updateSelectedAdhan(adhan);
                  // تشغيل معاينة قصيرة عند التحديد
                  if (adhan != AdhanSound.system) {
                    _playAdhanPreview(adhan);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// بناء شريط تمرير مستوى الصوت
  Widget _buildVolumeSlider(
    BuildContext context,
    AppSettings settings,
    bool isDark,
  ) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مستوى صوت الأذان',
                style: AppTypography.bodyMediumArabic.copyWith(
                  color: isDark
                      ? AppColors.textOnSurfaceDark
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                '${(settings.adhanVolume * 100).toInt()}%',
                style: AppTypography.captionArabic.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: settings.adhanVolume,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            activeColor: AppColors.primaryGreen,
            inactiveColor: AppColors.divider,
            onChanged: (value) {
              context.read<SettingsCubit>().updateAdhanVolume(value);
            },
          ),
        ],
      ),
    );
  }

  /// بناء مفتاح تبديل
  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
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
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: AppTypography.captionArabic.copyWith(
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

  /// بناء عنصر قائمة
  Widget _buildListTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primaryGreen,
        size: 24.sp,
      ),
      title: Text(
        title,
        style: AppTypography.bodyMediumArabic.copyWith(
          color: isDark ? AppColors.textOnSurfaceDark : AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTypography.captionArabic.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            )
          : null,
      onTap: onTap,
    );
  }

  /// بناء فاصل
  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 16.w,
      endIndent: 16.w,
    );
  }

  /// عرض مربع حوار إعادة التعيين
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة تعيين الإعدادات'),
        content: const Text(
          'هل أنت متأكد من رغبتك في إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<SettingsCubit>().resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إعادة تعيين الإعدادات'),
                ),
              );
            },
            child: Text(
              'إعادة تعيين',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
