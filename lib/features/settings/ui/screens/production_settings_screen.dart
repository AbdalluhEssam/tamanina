import 'package:easy_localization/easy_localization.dart'
    show BuildContextEasyLocalizationExtension;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/app_update_service.dart';
import '../../../../core/services/home_widgets_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/settings/settings_repository.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../widgets/packs_sheet.dart';

class ProductionSettingsScreen extends StatelessWidget {
  const ProductionSettingsScreen({super.key, this.embedded = false});

  final bool embedded;

  Future<void> _showHomeWidgets(BuildContext context) async {
    final android = Theme.of(context).platform == TargetPlatform.android;
    if (android && sl.isRegistered<HomeWidgetsService>()) {
      final selected = await showDialog<HomeWidgetKind>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: Text(appText(context, 'اختر الويدجت', 'Choose a widget')),
          children: [
            for (final (kind, ar, en) in const [
              (HomeWidgetKind.prayer, 'مواقيت الصلاة', 'Prayer times'),
              (HomeWidgetKind.dhikr, 'لحظة للذِّكر', 'Moment of dhikr'),
              (HomeWidgetKind.tasbeeh, 'السبحة', 'Tasbeeh'),
              (HomeWidgetKind.morning, 'أذكار الصباح', 'Morning adhkar'),
              (HomeWidgetKind.evening, 'أذكار المساء', 'Evening adhkar'),
              (HomeWidgetKind.quran, 'القرآن', 'Quran'),
            ])
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, kind),
                child: Text(appText(context, ar, en)),
              ),
          ],
        ),
      );
      if (selected == null || !context.mounted) return;
      if (await sl<HomeWidgetsService>().requestAndroidPin(selected)) return;
    }
    if (!context.mounted) return;
    await showAdaptiveDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog.adaptive(
        title: Text(
          appText(context, 'ويدجت الشاشة الرئيسية', 'Home-screen widgets'),
        ),
        content: Text(
          android
              ? appText(
                  context,
                  'اضغط مطولًا على شاشة الجهاز الرئيسية، وافتح الويدجت، ثم اختر طمأنينة. اختر المواقيت أو الذكر أو السبحة أو أذكار الصباح والمساء أو القرآن.',
                  'Touch and hold your Home Screen, open Widgets, then choose Tamanina. Choose Prayer, Dhikr, Tasbeeh, Morning Adhkar, Evening Adhkar or Quran.',
                )
              : appText(
                  context,
                  'اضغط مطولًا على شاشة الجهاز الرئيسية واختر إضافة ويدجت. ابحث عن طمأنينة وأضف الويدجت اللي يناسبك. يمكنك تجميع الويدجت بالسحب فوق بعض.',
                  'Touch and hold your Home Screen and choose Add Widget. Search for Tamanina and choose a widget. Drag one onto another to make a stack.',
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(appText(context, 'تم', 'Done')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = ContentFrame(
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is SettingsError) {
            return Center(
              child: Text(
                appText(
                  context,
                  'تعذّر تحميل الإعدادات.',
                  'Settings could not be loaded.',
                ),
              ),
            );
          }
          if (state is! SettingsLoaded) return const ListSkeleton();
          final cubit = context.read<SettingsCubit>();
          final settings = state.settings;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _SettingsSection(
                title: appText(
                  context,
                  'المظهر واللغة',
                  'Appearance and language',
                ),
                children: [
                  settingsChoice<ThemeMode>(
                    context,
                    icon: Icons.contrast,
                    title: appText(context, 'المظهر', 'Theme'),
                    current: settings.themeMode,
                    values: ThemeMode.values,
                    label: (mode) => switch (mode) {
                      ThemeMode.system => appText(
                        context,
                        'حسب الجهاز',
                        'System',
                      ),
                      ThemeMode.light => appText(context, 'فاتح', 'Light'),
                      ThemeMode.dark => appText(context, 'داكن', 'Dark'),
                    },
                    optionIcon: (mode) => switch (mode) {
                      ThemeMode.system => Icons.phone_iphone_rounded,
                      ThemeMode.light => Icons.light_mode_outlined,
                      ThemeMode.dark => Icons.dark_mode_outlined,
                    },
                    onSelected: cubit.updateThemeMode,
                  ),
                  settingsChoice<Locale>(
                    context,
                    icon: Icons.language,
                    title: appText(context, 'اللغة', 'Language'),
                    current: Localizations.localeOf(context),
                    values: AppConstants.supportedLocales,
                    label: (locale) =>
                        locale.languageCode == 'ar' ? 'العربية' : 'English',
                    optionTextStyle: (locale) => TextStyle(
                      fontFamily: locale.languageCode == 'ar'
                          ? 'Cairo'
                          : 'Poppins',
                      height: 1.5,
                    ),
                    onSelected: context.setLocale,
                  ),
                  settingsChoice<ArabicFont>(
                    context,
                    icon: Icons.text_fields,
                    title: appText(context, 'الخط العربي', 'Arabic font'),
                    current: settings.arabicFont,
                    values: ArabicFont.values,
                    label: (font) =>
                        appText(context, font.arabicName, font.fontFamily),
                    optionTextStyle: (font) =>
                        TextStyle(fontFamily: font.fontFamily),
                    onSelected: cubit.updateArabicFont,
                  ),
                ],
              ),
              _SettingsSection(
                title: appText(
                  context,
                  'الصلاة والتنبيهات',
                  'Prayer and reminders',
                ),
                children: [
                  ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(
                      appText(context, 'موقع الصلاة', 'Prayer location'),
                    ),
                    trailing: Icon(appChevron(context)),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.prayerTimes),
                  ),
                  settingsChoice<PrayerCalculationMethod>(
                    context,
                    icon: Icons.calculate_outlined,
                    title: appText(
                      context,
                      'طريقة حساب المواقيت',
                      'Calculation method',
                    ),
                    current: settings.calculationMethod,
                    values: PrayerCalculationMethod.values,
                    label: (method) =>
                        appText(context, method.arabicName, method.englishName),
                    onSelected: cubit.updateCalculationMethod,
                  ),
                  settingsChoice<Madhab>(
                    context,
                    icon: Icons.schedule_outlined,
                    title: appText(context, 'حساب العصر', 'Asr calculation'),
                    current: settings.madhab,
                    values: Madhab.values,
                    label: (madhab) =>
                        appText(context, madhab.arabicName, madhab.englishName),
                    onSelected: cubit.updateMadhab,
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications_none),
                    title: Text(
                      appText(
                        context,
                        'إعدادات التنبيهات',
                        'Notification settings',
                      ),
                    ),
                    trailing: Icon(appChevron(context)),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.notificationSettings,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.download_for_offline_outlined),
                    title: Text(
                      appText(context, 'التحميلات', 'Downloads'),
                    ),
                    subtitle: Text(
                      appText(
                        context,
                        'المصحف، أصوات الأذان، المساعد على الجهاز',
                        'Mushaf pages, adhan voices, on-device assistant',
                      ),
                    ),
                    trailing: Icon(appChevron(context)),
                    onTap: () => showPacksSheet(context),
                  ),
                  SwitchListTile.adaptive(
                    secondary: const Icon(Icons.vibration),
                    title: Text(
                      appText(
                        context,
                        'اهتزاز أثناء التسبيح والذكر',
                        'Haptics during remembrance',
                      ),
                    ),
                    value: settings.vibrationEnabled,
                    onChanged: cubit.updateVibrationEnabled,
                  ),
                ],
              ),
              _SettingsSection(
                title: appText(context, 'عن طمأنينة', 'About Tamanina'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(
                      appText(context, 'تحديث التطبيق', 'App update'),
                    ),
                    onTap: () =>
                        AppUpdateService().manualCheckForUpdates(context),
                    subtitle: Text(
                      appText(
                        context,
                        'التحقق من التحديثات',
                        'Check for updates',
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.widgets_outlined),
                    title: Text(
                      appText(
                        context,
                        'ويدجت الشاشة الرئيسية',
                        'Home-screen widgets',
                      ),
                    ),
                    trailing: Icon(appChevron(context)),
                    onTap: () => _showHomeWidgets(context),
                  ),
                  for (final (label, route) in [
                    (
                      appText(context, 'سياسة الخصوصية', 'Privacy policy'),
                      AppRoutes.privacyPolicy,
                    ),
                    (
                      appText(context, 'شروط الاستخدام', 'Terms of service'),
                      AppRoutes.termsOfService,
                    ),
                  ])
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text(label),
                      trailing: Icon(appChevron(context)),
                      onTap: () => Navigator.pushNamed(context, route),
                    ),
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: Text(
                      appText(context, 'إعادة ضبط الإعدادات', 'Reset settings'),
                    ),
                    onTap: () async {
                      final reset = await showAdaptiveDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog.adaptive(
                          title: Text(
                            appText(
                              context,
                              'استعادة الإعدادات الافتراضية؟',
                              'Restore default settings?',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(appText(context, 'إلغاء', 'Cancel')),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                appText(context, 'استعادة', 'Restore'),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (reset == true && context.mounted) {
                        await cubit.resetToDefaults();
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    return embedded
        ? content
        : Scaffold(
            appBar: AppBar(
              title: Text(appText(context, 'الإعدادات', 'Settings')),
            ),
            body: SafeArea(top: false, child: content),
          );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 6, bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Card(child: Column(children: children)),
      ],
    ),
  );
}

Widget settingsChoice<T>(
  BuildContext context, {
  required IconData icon,
  required String title,
  required T current,
  required Iterable<T> values,
  required String Function(T) label,
  required ValueChanged<T> onSelected,
  IconData Function(T)? optionIcon,
  TextStyle Function(T)? optionTextStyle,
}) => ListTile(
  leading: Icon(icon),
  title: Text(title),
  subtitle: Text(label(current)),
  trailing: Icon(appChevron(context)),
  onTap: () async {
    final value = await showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final scheme = theme.colorScheme;
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * .72,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 12),
                    child: Text(title, style: theme.textTheme.titleLarge),
                  ),
                  for (final item in values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        leading: optionIcon == null
                            ? null
                            : Icon(optionIcon(item)),
                        title: Text(
                          label(item),
                          style: optionTextStyle?.call(item),
                        ),
                        selected: item == current,
                        selectedTileColor: scheme.secondaryContainer,
                        selectedColor: scheme.onSecondaryContainer,
                        trailing: Icon(
                          item == current
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 22,
                        ),
                        onTap: () => Navigator.pop(sheetContext, item),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (context.mounted && value != null) onSelected(value);
  },
);
