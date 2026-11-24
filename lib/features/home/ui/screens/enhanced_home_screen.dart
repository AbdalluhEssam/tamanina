import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/prayer_service_enhanced.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../../../prayer_times/ui/screens/prayer_times_screen.dart';
import '../../../statistics/data/worship_activity.dart';
import '../widgets/home_daily_inspiration.dart';
import '../widgets/home_hero_card.dart';
import '../widgets/home_prayer_timeline.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/home_worship_tracker.dart';
import '../widgets/worship_hub.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key, this.openTasbeeh});

  final VoidCallback? openTasbeeh;

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
  final _service = sl<PrayerServiceEnhanced>();
  late Future<({DailyPrayerTimes? today, PrayerTimeData? next})> _times;
  StreamSubscription<DailyPrayerTimes?>? _prayerSub;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _times = _loadTimes();
    _prayerSub = _service.prayerTimesStream.listen((_) => _refresh());
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _times = _loadTimes();
    });
  }

  Future<({DailyPrayerTimes? today, PrayerTimeData? next})> _loadTimes() async {
    final today = await _service.getTodayPrayerTimes();
    final next = today == null
        ? null
        : today.nextPrayer ?? await _service.nextPrayer();
    return (today: today, next: next);
  }

  Future<void> _openPrayerTimes() async {
    await Navigator.pushNamed(context, AppRoutes.prayerTimes);
    _refresh();
  }

  Future<void> _changeCity() async {
    await choosePrayerCity(context);
    _refresh();
  }

  @override
  void dispose() {
    _prayerSub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildContent() {
    return FutureBuilder<({DailyPrayerTimes? today, PrayerTimeData? next})>(
      future: _times,
      builder: (context, snapshot) {
        final today = DateTime.now();
        final schedule = snapshot.data?.today;
        final next = snapshot.data?.next;
        final loading =
            !snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting;

        return RefreshIndicator(
          onRefresh: () async {
            _service.refreshLocation();
            _refresh();
            await _times;
          },
          child: ContentFrame(
            maxWidth: 640,
            child: ListView(
              key: const PageStorageKey('today-home'),
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                WorshipHub(
                  onOpenNotifications: () => Navigator.pushNamed(
                    context,
                    AppRoutes.notificationSettings,
                  ),
                  prayerCard: HomeHeroCard(
                    prayerTimes: schedule,
                    nextPrayer: next,
                    loading: loading,
                    onChangeCity: _changeCity,
                    onOpenPrayerTimes: _openPrayerTimes,
                    onPrayerReached: _refresh,
                  ),
                ),
                const SizedBox(height: 12),
                HomeWorshipTracker(
                  today: today,
                  onOpenPrayerTimes: _openPrayerTimes,
                  onOpenQuran: () =>
                      Navigator.pushNamed(context, AppRoutes.mushafReader),
                  onOpenTasbeeh:
                      widget.openTasbeeh ??
                      () => Navigator.pushNamed(context, AppRoutes.sebha),
                  onOpenStatistics: () =>
                      Navigator.pushNamed(context, AppRoutes.statistics),
                ),
                const SizedBox(height: 9),
                HomePrayerTimeline(
                  today: today,
                  prayerTimes: schedule,
                  nextPrayer: next,
                  loading: loading,
                  onOpenAllPrayers: _openPrayerTimes,
                  onChooseCity: _changeCity,
                ),
                const SizedBox(height: 14),
                const HomeQuickActions(),
                const HomeDailyInspiration(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (_, _) => _refresh(),
      child: WorshipLog.isAvailable
          ? ValueListenableBuilder(
              valueListenable: WorshipLog.box.listenable(),
              builder: (context, _, _) => _buildContent(),
            )
          : _buildContent(),
    );
  }
}
