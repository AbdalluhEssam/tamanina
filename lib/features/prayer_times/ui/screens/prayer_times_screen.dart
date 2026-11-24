import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/prayer_service_enhanced.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/settings/settings_repository.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../../../../core/theme/worship_palette.dart';
import '../widgets/next_prayer_panel.dart';
import '../../../../core/services/notification_service_enhanced.dart';
import '../../../statistics/data/worship_activity.dart';
import '../../../settings/ui/screens/production_settings_screen.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final _service = sl<PrayerServiceEnhanced>();
  late Future<({DailyPrayerTimes? today, PrayerTimeData? next})> _times;
  late final Timer _clock;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _times = _loadTimes();
    _clock = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  void _refresh() => setState(() {
    _times = _loadTimes();
  });

  Future<({DailyPrayerTimes? today, PrayerTimeData? next})> _loadTimes() async {
    final today = await _service.getTodayPrayerTimes();
    final next = today == null
        ? null
        : today.nextPrayer ?? await _service.nextPrayer();
    return (today: today, next: next);
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  Future<void> _useLocation() async {
    setState(() => _locating = true);
    final settings = context.read<SettingsCubit>();
    final result = await LocationService().getCurrentLocation(
      forceRefresh: true,
    );
    if (!mounted) return;
    setState(() => _locating = false);
    if (result.isSuccess) {
      await settings.useAutoLocation();
      _service.refreshLocation();
      if (mounted) _refresh();
      await sl<NotificationServiceEnhanced>().refresh();
      return;
    }
    final blocked =
        result.errorType == LocationErrorType.permissionDeniedForever ||
        result.errorType == LocationErrorType.serviceDisabled;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appText(
            context,
            'تعذّر تحديد موقعك. يمكنك اختيار المدينة يدويًا.',
            'Your location is unavailable. You can choose a city.',
          ),
        ),
        action: blocked
            ? SnackBarAction(
                label: appText(context, 'الإعدادات', 'Settings'),
                onPressed: result.errorType == LocationErrorType.serviceDisabled
                    ? Geolocator.openLocationSettings
                    : Geolocator.openAppSettings,
              )
            : null,
      ),
    );
  }

  Future<void> _chooseCity() => choosePrayerCity(context);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (_, _) => _refresh(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(appText(context, 'مواقيت الصلاة', 'Prayer times')),
          actions: [
            IconButton(
              tooltip: appText(
                context,
                'إعدادات التنبيهات',
                'Notification settings',
              ),
              icon: Icon(
                platformIcon(
                  context,
                  Icons.notifications_none,
                  CupertinoIcons.bell,
                ),
              ),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.notificationSettings),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: ContentFrame(
            maxWidth: 680,
            child: FutureBuilder(
              future: _times,
              builder: (context, snapshot) {
                final data = snapshot.hasError ? null : snapshot.data;
                final schedule = data?.today;
                if (data == null &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const ListSkeleton(rows: 5);
                }
                final locale = Localizations.localeOf(context).languageCode;
                final settings = context.read<SettingsCubit>();
                final theme = Theme.of(context);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                  children: [
                    if (schedule != null) ...[
                      NextPrayerPanel(prayer: data?.next, illustrated: true),
                      const SizedBox(height: 18),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 2,
                        children: [
                          Text(
                            appText(context, 'صلوات اليوم', "Today's prayers"),
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            DateFormat.MMMEd(locale).format(schedule.date),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (locale == 'ar')
                        Text(
                          schedule.hijriDate,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (final (index, prayer)
                                in schedule.allPrayers.indexed) ...[
                              if (index != 0)
                                const Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                              _prayerRow(context, prayer, schedule.date),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (schedule == null) ...[
                      Text(
                        snapshot.hasError
                            ? appText(
                                context,
                                'تعذّر عرض المواقيت',
                                'Prayer times unavailable',
                              )
                            : appText(
                                context,
                                'اضبط موقع الصلاة',
                                'Set your prayer location',
                              ),
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        snapshot.hasError
                            ? appText(
                                context,
                                'جرّب مدينة أخرى أو غيّر طريقة الحساب.',
                                'Try a different city or calculation method.',
                              )
                            : appText(
                                context,
                                'اختر مدينة أو استخدم موقعك لحساب المواقيت على جهازك.',
                                'Choose a city or use your location to calculate times on your device.',
                              ),
                      ),
                      const SizedBox(height: 14),
                    ] else
                      Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.place_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 19,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                schedule.cityName.isEmpty
                                    ? appText(
                                        context,
                                        'آخر موقع محفوظ',
                                        'Last saved location',
                                      )
                                    : localizedCityName(
                                        schedule.cityName,
                                        arabic: locale == 'ar',
                                      ),
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          icon: const Icon(Icons.location_city_outlined),
                          label: Text(
                            schedule == null
                                ? appText(
                                    context,
                                    'اختيار مدينة',
                                    'Choose a city',
                                  )
                                : appText(
                                    context,
                                    'تغيير المدينة',
                                    'Change city',
                                  ),
                          ),
                          onPressed: _locating ? null : _chooseCity,
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.my_location),
                          label: Text(
                            _locating
                                ? appText(
                                    context,
                                    'جارٍ تحديد الموقع',
                                    'Finding location',
                                  )
                                : appText(
                                    context,
                                    'استخدم موقعي',
                                    'Use my location',
                                  ),
                          ),
                          onPressed: _locating ? null : _useLocation,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    settingsChoice<PrayerCalculationMethod>(
                      context,
                      icon: Icons.calculate_outlined,
                      title: appText(
                        context,
                        'طريقة حساب المواقيت',
                        'Calculation method',
                      ),
                      current: settings.currentSettings.calculationMethod,
                      values: [
                        PrayerCalculationMethod.automatic,
                        ...PrayerCalculationMethod.values.where(
                          (method) =>
                              method != PrayerCalculationMethod.automatic,
                        ),
                      ],
                      label: (method) => appText(
                        context,
                        method.arabicName,
                        method.englishName,
                      ),
                      onSelected: settings.updateCalculationMethod,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _prayerRow(
    BuildContext context,
    PrayerTimeData prayer,
    DateTime date,
  ) {
    final theme = Theme.of(context);
    final label = appText(context, prayer.nameArabic, prayer.name);
    final active = prayer.isNext;
    final canLog =
        prayer.name != 'Sunrise' && !prayer.time.isAfter(DateTime.now());
    final completed = canLog && WorshipLog.prayerCompleted(prayer.name, date);
    final tone = active
        ? WorshipPalette.onTint(context)
        : theme.colorScheme.onSurface;

    return ColoredBox(
      color: active ? WorshipPalette.tint(context) : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 5, 8, 5),
        child: Row(
          children: [
            Icon(prayerIcon(prayer.name), color: tone, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(color: tone),
                  ),
                  if (active)
                    Text(
                      appText(context, 'الصلاة القادمة', 'Next prayer'),
                      style: theme.textTheme.labelSmall?.copyWith(color: tone),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                prayerClock(context, prayer.time),
                textAlign: TextAlign.end,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: tone,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            if (canLog)
              IconButton(
                tooltip: completed
                    ? appText(context, 'إلغاء تسجيل $label', 'Unlog $label')
                    : appText(context, 'سجّل $label', 'Log $label'),
                isSelected: completed,
                icon: const Icon(Icons.circle_outlined, size: 20),
                selectedIcon: const Icon(Icons.check_circle, size: 20),
                onPressed: () async {
                  await WorshipLog.setPrayerCompleted(
                    prayer.name,
                    date,
                    !completed,
                  );
                  if (mounted) setState(() {});
                },
              )
            else
              const SizedBox(width: 48, height: 48),
          ],
        ),
      ),
    );
  }
}

Future<void> choosePrayerCity(BuildContext context) async {
  final settings = context.read<SettingsCubit>();
  final current = settings.currentSettings.locationSettings;
  final city = await showModalBottomSheet<PopularCity>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => _PrayerCityPicker(
      selected: current.useAutoLocation ? null : current.cityName,
    ),
  );
  if (city == null || !context.mounted) return;
  await settings.setManualLocation(
    latitude: city.latitude,
    longitude: city.longitude,
    cityName: city.nameArabic,
    countryName: city.country,
  );
}

class _PrayerCityPicker extends StatefulWidget {
  const _PrayerCityPicker({this.selected});

  final String? selected;

  @override
  State<_PrayerCityPicker> createState() => _PrayerCityPickerState();
}

class _PrayerCityPickerState extends State<_PrayerCityPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filter = _normalize(_query);
    final cities = popularCities
        .where(
          (city) =>
              _normalize(city.nameArabic).contains(filter) ||
              _normalize(city.nameEnglish).contains(filter) ||
              city.country.toLowerCase().contains(filter),
        )
        .toList();
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: keyboard),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 180),
      child: FractionallySizedBox(
        heightFactor: .78,
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appText(
                        context,
                        'اختر مدينة الصلاة',
                        'Choose your prayer city',
                      ),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        labelText: appText(
                          context,
                          'ابحث باسم المدينة',
                          'Search for a city',
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: cities.isEmpty
                    ? Center(
                        child: Text(
                          appText(
                            context,
                            'لا توجد نتائج. جرّب اسمًا آخر.',
                            'No matches. Try another name.',
                          ),
                        ),
                      )
                    : ListView.builder(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: cities.length,
                        itemBuilder: (context, index) {
                          final city = cities[index];
                          final selected =
                              widget.selected == city.nameArabic ||
                              widget.selected == city.nameEnglish;
                          return ListTile(
                            leading: const Icon(Icons.location_on_outlined),
                            title: Text(
                              appText(
                                context,
                                city.nameArabic,
                                city.nameEnglish,
                              ),
                            ),
                            subtitle: Text(city.country),
                            selected: selected,
                            trailing: selected
                                ? const Icon(Icons.check_circle_outline)
                                : null,
                            onTap: () => Navigator.pop(context, city),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ى', 'ي');
}
