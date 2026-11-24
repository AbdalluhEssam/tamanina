import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/settings/settings_repository.dart';
import '../../../../core/theme/worship_palette.dart';
import '../../../../core/services/app_update_service.dart';
import '../../../../core/services/home_widgets_service.dart';
import '../../../../core/services/notification_service_enhanced.dart';
import '../../../../core/services/prayer_service_enhanced.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/worship_shortcuts.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../../../quran/ui/screens/quran_tab_screen.dart';
import '../../../settings/ui/screens/production_settings_screen.dart';
import '../../../tasbeeh/ui/screens/tasbeeh_screen.dart';
import '../cubit/home_navigation_cubit.dart';
import '../widgets/home_visuals.dart';
import 'enhanced_home_screen.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  late final AppLifecycleListener _lifecycle;
  StreamSubscription<DailyPrayerTimes?>? _prayerUpdates;
  String? _language;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    if (sl.isRegistered<HomeWidgetsService>()) {
      _prayerUpdates = sl<PrayerServiceEnhanced>().prayerTimesStream.listen((
        _,
      ) {
        _publishWidgets();
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WorshipShortcuts.instance.setHomeReady(true);
      if (sl.isRegistered<HomeWidgetsService>()) {
        unawaited(AppUpdateService().checkForUpdates(context));
      }
      unawaited(_setUpHomePermissions());
    });
  }

  Future<void> _setUpHomePermissions() async {
    if (sl.isRegistered<PrayerServiceEnhanced>()) {
      await sl<PrayerServiceEnhanced>().requestAutoLocation(
        promptForPermission: true,
      );
    }
    if (!mounted || !sl.isRegistered<NotificationServiceEnhanced>()) return;
    if (!sl<SettingsRepository>().currentSettings.notificationsEnabled) return;
    try {
      await sl<NotificationServiceEnhanced>().requestPermissions();
    } catch (error) {
      debugPrint('Notification permission unavailable: ${error.runtimeType}');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (_language == language) return;
    final languageChanged = _language != null;
    _language = language;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _language != language) return;
      _publishWidgets();
      if (languageChanged && sl.isRegistered<NotificationServiceEnhanced>()) {
        unawaited(sl<NotificationServiceEnhanced>().refresh());
      }
    });
  }

  void _publishWidgets() {
    if (_language case final language?) {
      if (sl.isRegistered<HomeWidgetsService>()) {
        unawaited(sl<HomeWidgetsService>().refresh(language));
      }
    }
  }

  Future<void> _onResume() async {
    final prayers = sl.isRegistered<PrayerServiceEnhanced>()
        ? sl<PrayerServiceEnhanced>()
        : null;
    final changed = await prayers?.refreshDeviceTimeZone() ?? false;
    if (!mounted) return;
    if (changed) prayers?.refreshLocation();
    _publishWidgets();
    unawaited(prayers?.requestAutoLocation(promptForPermission: false));
    if (sl.isRegistered<NotificationServiceEnhanced>()) {
      final notifications = sl<NotificationServiceEnhanced>();
      await (changed
          ? notifications.refresh()
          : notifications.refreshOnResume());
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _prayerUpdates?.cancel();
    WorshipShortcuts.instance.setHomeReady(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => HomeNavigationCubit(),
    child: const _HomeNavigation(),
  );
}

class _HomeNavigation extends StatelessWidget {
  const _HomeNavigation();

  @override
  Widget build(BuildContext context) {
    final index = context.watch<HomeNavigationCubit>().state;
    final onSelect = context.read<HomeNavigationCubit>().navigateToTab;
    const assistantPosition = 2;
    final selectedDestination = index < assistantPosition ? index : index + 1;
    void navigate(int destination) {
      if (destination == assistantPosition) {
        Navigator.pushNamed(context, AppRoutes.chatbot);
        return;
      }
      onSelect(destination < assistantPosition ? destination : destination - 1);
    }

    final assistant = appText(context, 'المساعد', 'Assistant');
    final isHome = index == 0;
    final theme = Theme.of(context);
    final useHomePalette = isHome || theme.brightness == Brightness.dark;
    final colors = HomePalette.of(context);
    final labels = [
      appText(context, 'الرئيسية', 'Today'),
      appText(context, 'القرآن', 'Quran'),
      appText(context, 'السبحة', 'Tasbeeh'),
      appText(context, 'الإعدادات', 'Settings'),
    ];
    final icons = [
      platformIcon(context, Icons.home_outlined, CupertinoIcons.house),
      platformIcon(context, Icons.menu_book_outlined, CupertinoIcons.book),
      platformIcon(context, Icons.fingerprint, CupertinoIcons.hand_draw),
      platformIcon(context, Icons.settings_outlined, CupertinoIcons.gear_alt),
    ];
    final destinations = [
      for (var slot = 0; slot < labels.length + 1; slot++)
        if (slot == assistantPosition)
          (
            assistant,
            DecoratedBox(
              decoration: BoxDecoration(
                color: useHomePalette ? colors.raised : WorshipPalette.pine,
                shape: BoxShape.circle,
                border: useHomePalette
                    ? Border.all(color: colors.accent)
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  platformIcon(
                    context,
                    Icons.chat_bubble_outline,
                    CupertinoIcons.chat_bubble,
                  ),
                  color: useHomePalette ? colors.accent : WorshipPalette.ivory,
                  size: 22,
                ),
              ),
            ),
          )
        else
          (
            labels[slot < assistantPosition ? slot : slot - 1],
            Icon(icons[slot < assistantPosition ? slot : slot - 1]),
          ),
    ];
    final wide = MediaQuery.sizeOf(context).width >= 760;
    final pages = [
      EnhancedHomeScreen(openTasbeeh: () => onSelect(2)),
      const QuranTabScreen(),
      const TasbeehScreen(),
      const ProductionSettingsScreen(embedded: true),
    ];

    final bar = NavigationBar(
      selectedIndex: selectedDestination,
      onDestinationSelected: navigate,
      destinations: [
        for (final (label, icon) in destinations)
          NavigationDestination(icon: icon, label: label),
      ],
    );

    return Scaffold(
      backgroundColor: isHome ? colors.background : null,
      appBar: isHome ? null : AppBar(title: Text(labels[index])),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: SafeArea(
          top: isHome,
          bottom: wide,
          child: Row(
            children: [
              if (wide)
                NavigationRail(
                  backgroundColor: useHomePalette ? colors.surface : null,
                  selectedIndex: selectedDestination,
                  onDestinationSelected: navigate,
                  labelType: NavigationRailLabelType.all,
                  scrollable: true,
                  destinations: [
                    for (final (label, icon) in destinations)
                      NavigationRailDestination(icon: icon, label: Text(label)),
                  ],
                ),
              if (wide)
                VerticalDivider(
                  width: 1,
                  color: useHomePalette ? colors.border : null,
                ),
              Expanded(child: pages[index]),
            ],
          ),
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : useHomePalette
          ? _HomeNavigationBar(child: bar)
          : bar,
    );
  }
}

class _HomeNavigationBar extends StatelessWidget {
  const _HomeNavigationBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = Theme.of(context).textTheme;
    final bigText = MediaQuery.textScalerOf(context).scale(12) > 17;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.border,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(1, 1, 1, 0),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: bigText ? 76 : 66,
              backgroundColor: colors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              indicatorColor: HomePalette.gold,
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              iconTheme: WidgetStateProperty.resolveWith(
                (states) => IconThemeData(
                  size: 22,
                  color: states.contains(WidgetState.selected)
                      ? HomePalette.onGold
                      : colors.ink,
                ),
              ),
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => text.labelSmall?.copyWith(
                  color: states.contains(WidgetState.selected)
                      ? colors.accent
                      : colors.ink,
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
