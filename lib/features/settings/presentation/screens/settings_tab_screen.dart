import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_typography.dart';

/// Settings Tab Screen Content
class SettingsTabScreen extends StatefulWidget {
  const SettingsTabScreen({super.key});

  @override
  State<SettingsTabScreen> createState() => _SettingsTabScreenState();
}

class _SettingsTabScreenState extends State<SettingsTabScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'العربية';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: AppSizing.appBarHeight + 40.h,
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        bottom: 100.h, // Space for BottomNav
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          AppSpacing.verticalSpaceXL,

          // Profile Section
          _buildProfileSection(),

          AppSpacing.verticalSpaceLG,

          // App Settings
          _buildAppSettings(),

          AppSpacing.verticalSpaceLG,

          // Prayer Settings
          _buildPrayerSettings(),

          AppSpacing.verticalSpaceLG,

          // About Section
          _buildAboutSection(),

          AppSpacing.verticalSpaceLG,

          // Support Section
          _buildSupportSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen.withOpacity(0.1),
            AppColors.goldAccent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: AppColors.goldAccent.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.2),
              borderRadius: AppRadius.md,
            ),
            child: Icon(
              Icons.settings_rounded,
              color: AppColors.primaryGreen,
              size: AppSizing.iconLG,
            ),
          ),
          AppSpacing.horizontalSpaceMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإعدادات',
                  style: AppTypography.h5Arabic.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.verticalSpaceXS,
                Text(
                  'تخصيص التطبيق حسب احتياجك',
                  style: AppTypography.bodyMediumArabic.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return _buildSection(
      title: 'الملف الشخصي',
      icon: Icons.person_rounded,
      children: [
        _buildSettingsItem(
          title: 'تعديل الملف الشخصي',
          subtitle: 'الاسم والصورة الشخصية',
          icon: Icons.edit_rounded,
          onTap: () {},
        ),
        _buildSettingsItem(
          title: 'النسخ الاحتياطي',
          subtitle: 'حفظ واستعادة البيانات',
          icon: Icons.backup_rounded,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAppSettings() {
    return _buildSection(
      title: 'إعدادات التطبيق',
      icon: Icons.tune_rounded,
      children: [
        _buildSwitchItem(
          title: 'الإشعارات',
          subtitle: 'تلقي إشعارات الصلاة والأذكار',
          icon: Icons.notifications_rounded,
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
        _buildSwitchItem(
          title: 'الأصوات',
          subtitle: 'تشغيل الأصوات في التطبيق',
          icon: Icons.volume_up_rounded,
          value: _soundEnabled,
          onChanged: (value) {
            setState(() {
              _soundEnabled = value;
            });
          },
        ),
        _buildSwitchItem(
          title: 'الاهتزاز',
          subtitle: 'اهتزاز عند التسبيح والأذكار',
          icon: Icons.vibration_rounded,
          value: _vibrationEnabled,
          onChanged: (value) {
            setState(() {
              _vibrationEnabled = value;
            });
          },
        ),
        _buildSwitchItem(
          title: 'الوضع الليلي',
          subtitle: 'تفعيل الثيم المظلم',
          icon: Icons.dark_mode_rounded,
          value: _darkModeEnabled,
          onChanged: (value) {
            setState(() {
              _darkModeEnabled = value;
            });
          },
        ),
        _buildSettingsItem(
          title: 'اللغة',
          subtitle: _selectedLanguage,
          icon: Icons.language_rounded,
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textSecondary,
            size: 16.w,
          ),
          onTap: () => _showLanguageSelector(),
        ),
      ],
    );
  }

  Widget _buildPrayerSettings() {
    return _buildSection(
      title: 'إعدادات الصلاة',
      icon: Icons.access_time_rounded,
      children: [
        _buildSettingsItem(
          title: 'مواقيت الصلاة',
          subtitle: 'تخصيص أوقات الصلاة والأذان',
          icon: Icons.schedule_rounded,
          onTap: () {},
        ),
        _buildSettingsItem(
          title: 'القبلة',
          subtitle: 'إعدادات اتجاه القبلة',
          icon: Icons.navigation_rounded,
          onTap: () {},
        ),
        _buildSettingsItem(
          title: 'الأذان',
          subtitle: 'اختيار صوت الأذان والمؤذن',
          icon: Icons.campaign_rounded,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'حول التطبيق',
      icon: Icons.info_rounded,
      children: [
        _buildSettingsItem(
          title: 'إصدار التطبيق',
          subtitle: 'النسخة 1.0.0',
          icon: Icons.phone_android_rounded,
          onTap: () {},
        ),
        _buildSettingsItem(
          title: 'شروط الاستخدام',
          subtitle: 'اقرأ شروط وأحكام الاستخدام',
          icon: Icons.description_rounded,
          onTap: () {},
        ),
        _buildSettingsItem(
          title: 'سياسة الخصوصية',
          subtitle: 'كيف نحمي بياناتك',
          icon: Icons.privacy_tip_rounded,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      title: 'الدعم والمساعدة',
      icon: Icons.help_rounded,
      children: [
        _buildSettingsItem(
          title: 'تواصل معنا',
          subtitle: 'أرسل ملاحظاتك واستفساراتك',
          icon: Icons.contact_support_rounded,
          onTap: () {},
        ),
        _buildSettingsItem(
          title: 'تقييم التطبيق',
          subtitle: 'قيم التطبيق في المتجر',
          icon: Icons.star_rate_rounded,
          onTap: () {},
        ),
        _buildSettingsItem(
          title: 'مشاركة التطبيق',
          subtitle: 'شارك التطبيق مع الأصدقاء',
          icon: Icons.share_rounded,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 24.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.goldAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            AppSpacing.horizontalSpaceMD,
            Icon(
              icon,
              color: AppColors.primaryGreen,
              size: AppSizing.iconMD,
            ),
            AppSpacing.horizontalSpaceSM,
            Text(
              title,
              style: AppTypography.h6Arabic.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.lg,
            border: Border.all(
              color: AppColors.goldAccent.withOpacity(0.2),
            ),
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
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: AppSpacing.paddingMD,
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.1),
          borderRadius: AppRadius.sm,
        ),
        child: Icon(
          icon,
          color: AppColors.primaryGreen,
          size: AppSizing.iconMD,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLargeArabic.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.captionArabic.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textSecondary,
            size: 16.w,
          ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: AppSpacing.paddingMD,
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.1),
          borderRadius: AppRadius.sm,
        ),
        child: Icon(
          icon,
          color: AppColors.primaryGreen,
          size: AppSizing.iconMD,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLargeArabic.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.captionArabic.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryGreen,
        activeTrackColor: AppColors.primaryGreen.withOpacity(0.3),
      ),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'اختر اللغة',
          style: AppTypography.h6Arabic.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('العربية'),
            _buildLanguageOption('English'),
            _buildLanguageOption('Français'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = _selectedLanguage == language;

    return ListTile(
      title: Text(language),
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: AppColors.primaryGreen,
            )
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.of(context).pop();
      },
    );
  }
}
