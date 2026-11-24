import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamanina/core/constants/app_constants.dart';
import 'package:tamanina/core/routing/app_router.dart';
import 'package:tamanina/core/services/prayer_service_enhanced.dart';
import 'package:tamanina/core/services/service_locator.dart';
import 'package:tamanina/core/services/navigation_service.dart';
import 'package:tamanina/core/services/worship_shortcuts.dart';
import 'package:tamanina/core/settings/settings_cubit.dart';
import 'package:tamanina/core/settings/settings_repository.dart';
import 'package:tamanina/core/theme/app_colors.dart';
import 'package:tamanina/core/theme/app_theme.dart';
import 'package:tamanina/features/adhkar/ui/cubit/adhkar_cubit.dart';
import 'package:tamanina/features/adhkar/ui/screens/adhkar_detail_screen.dart';
import 'package:tamanina/features/home/ui/screens/home_layout.dart';
import 'package:tamanina/features/home/ui/widgets/home_prayer_timeline.dart';
import 'package:tamanina/features/home/ui/widgets/home_worship_tracker.dart';
import 'package:tamanina/features/onboarding/ui/cubit/onboarding_cubit.dart';
import 'package:tamanina/features/prayer_times/ui/widgets/next_prayer_panel.dart';
import 'package:tamanina/features/splash/ui/cubit/splash_cubit.dart';
import 'package:tamanina/features/splash/ui/screens/splash_screen.dart';
import 'package:tamanina/features/quran/data/services/mushaf_library.dart';
import 'package:tamanina/features/quran/data/services/reading_position_manager.dart';
import 'package:tamanina/features/quran/ui/screens/simple_mushaf_page_screen.dart';
import 'package:tamanina/features/quran/ui/screens/quran_tab_screen.dart';
import 'package:tamanina/features/quran/ui/widgets/printed_mushaf_page.dart';
import 'package:tamanina/features/tasbeeh/ui/screens/tasbeeh_tab_screen.dart';
import 'package:tamanina/features/statistics/data/worship_activity.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late SharedPreferences preferences;
  late SettingsRepository settings;
  late PrayerServiceEnhanced prayers;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('tamanina_widget_test');
    Hive.init(directory.path);
    await Hive.openBox('app_settings');
    await Hive.openBox('statistics');
    await Hive.openBox('bookmarks');
    await Hive.openBox('prayer_settings');
    SharedPreferences.setMockInitialValues({
      'last_mushaf_page': 3,
      'mushaf_bookmarks':
          '[{"page":3,"title":"Saved","timestamp":"2025-01-01"}]',
    });
    preferences = await SharedPreferences.getInstance();
    await init();
    settings = SettingsRepository();
    await settings.initialize();
    await settings.updateLocationSettings(
      const LocationSettings(
        useAutoLocation: false,
        cityName: 'Cairo',
        countryName: 'EG',
        manualLatitude: 30.0444,
        manualLongitude: 31.2357,
      ),
    );
    tz.initializeTimeZones();
    await initializeDateFormatting('ar');
    prayers = PrayerServiceEnhanced();
    await prayers.initialize(settingsRepository: settings);
    sl.registerSingleton(prayers);
  });

  tearDownAll(() async {
    await sl.reset();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'the bundled mushaf has 114 surahs, 6236 verses and 604 pages',
    () async {
      expect(MushafLibrary.surahs, hasLength(114));
      expect(MushafLibrary.juzStarts, hasLength(30));
      expect(
        MushafLibrary.searchVerses(
          MushafLibrary.normalize('بسم الله'),
        ).first.verse.number,
        1,
      );
      expect(
        MushafLibrary.pages.keys,
        orderedEquals(List.generate(604, (index) => index + 1)),
      );
      final assets = await AssetManifest.loadFromAssetBundle(rootBundle);
      expect(
        assets.listAssets().where(
          (path) => path.startsWith('assets/mushaf/') && path.endsWith('.webp'),
        ),
        unorderedEquals([
          for (final page in MushafLibrary.pages.keys)
            'assets/mushaf/${page.toString().padLeft(3, '0')}.webp',
        ]),
      );
      expect(
        MushafLibrary.pages.values.expand((page) => page),
        hasLength(6236),
      );
      expect(MushafLibrary.normalize('سُورَةُ ٱلْفَاتِحَةِ'), 'الفاتحة');
      expect(
        await ReadingPositionManager.getCurrentPage(),
        MushafLibrary.migratePage(3),
      );
      expect(
        (await ReadingPositionManager.getBookmarks()).single.page,
        MushafLibrary.migratePage(3),
      );
    },
  );

  test(
    'prayer times calculate for a selected city without a network service',
    () async {
      final times = (await prayers.getPrayerTimes(DateTime(2026, 11, 23)))!;
      expect(times.cityName, 'Cairo');
      expect(times.fajr.time.timeZoneOffset, const Duration(hours: 2));
      expect(times.allPrayers, hasLength(6));
      expect(times.fajr.time.isBefore(times.sunrise.time), isTrue);
      expect(times.asr.time.isBefore(times.maghrib.time), isTrue);
      expect(times.maghrib.time.isBefore(times.isha.time), isTrue);
    },
  );

  test('an unset prayer location is a normal offline state', () async {
    final original = settings.currentSettings.locationSettings;
    addTearDown(() => settings.updateLocationSettings(original));
    await settings.updateLocationSettings(
      const LocationSettings(useAutoLocation: false),
    );
    expect(await prayers.getTodayPrayerTimes(), isNull);
    expect(await prayers.nextPrayer(), isNull);
  });

  testWidgets('home timeline highlights tomorrow’s Fajr after Isha', (
    tester,
  ) async {
    final schedule = (await prayers.getPrayerTimes(DateTime(2026, 11, 24)))!;
    final tomorrow = (await prayers.getPrayerTimes(DateTime(2026, 11, 25)))!;
    final nextFajr = tomorrow.fajr.copyWith(
      time: tomorrow.fajr.time.add(const Duration(minutes: 10)),
    );
    var openedSchedule = false;

    Future<void> showTimeline(DateTime now, PrayerTimeData next) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            body: HomePrayerTimeline(
              today: now,
              prayerTimes: schedule,
              nextPrayer: next,
              onOpenAllPrayers: () => openedSchedule = true,
              onChooseCity: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await showTimeline(
      schedule.isha.time.subtract(const Duration(minutes: 1)),
      schedule.isha,
    );
    expect(find.text('القادمة'), findsOneWidget);

    await showTimeline(
      schedule.isha.time.add(const Duration(hours: 3)),
      nextFajr,
    );
    final context = tester.element(find.byType(HomePrayerTimeline));
    expect(find.text('الآن'), findsNothing);
    expect(find.text('غدًا'), findsOneWidget);
    expect(find.text(prayerClock(context, nextFajr.time)), findsOneWidget);
    expect(find.text(prayerClock(context, schedule.fajr.time)), findsNothing);
    await tester.tap(find.text('الفجر'));
    expect(openedSchedule, isTrue);
    expect(tester.takeException(), isNull);
  });

  test(
    'activity counts persist without duplicating an opened Quran page',
    () async {
      final statistics = await Hive.openBox('statistics');
      addTearDown(statistics.close);
      await WorshipLog.record(WorshipActivity.tasbeeh);
      await WorshipLog.openQuranPage(604);
      await WorshipLog.openQuranPage(604);
      final today = DateTime.now();
      expect(WorshipLog.count(WorshipActivity.tasbeeh, today), 1);
      expect(WorshipLog.count(WorshipActivity.quran, today), 1);
    },
  );

  testWidgets('first launch saves onboarding completion locally', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(preferences, settings, startAtSplash: true));
    await tester.pumpAndSettle();
    expect(find.text('Every day begins with peace'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Pray on time, wherever you are'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Your companion for daily dhikr'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Your space for stillness'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(
      preferences.getBool(AppConstants.prefKeyOnboardingCompleted),
      isTrue,
    );
    expect(find.byType(HomeLayout), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(_app(preferences, settings, startAtSplash: true));
    await tester.pumpAndSettle();
    expect(find.byType(HomeLayout), findsOneWidget);
    expect(find.text('Every day begins with peace'), findsNothing);
  });

  testWidgets('compact Arabic onboarding supports RTL swipe, back and skip', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 580);
    addTearDown(tester.view.reset);
    await preferences.remove(AppConstants.prefKeyOnboardingCompleted);

    await tester.pumpWidget(
      _app(
        preferences,
        settings,
        startAtSplash: true,
        locale: const Locale('ar'),
        scale: 1.6,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('كل يوم يبدأ بطمأنينة').hitTestable(), findsOneWidget);
    await tester.flingFrom(const Offset(35, 235), const Offset(250, 0), 850);
    await tester.pumpAndSettle();
    final pageView = find.byType(PageView);
    expect(Directionality.of(tester.element(pageView)), TextDirection.rtl);
    expect(tester.widget<PageView>(pageView).controller?.page, 1);
    expect(
      find.text('صلاتك في وقتها، أينما كنت').hitTestable(),
      findsOneWidget,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('كل يوم يبدأ بطمأنينة').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('تخطّي'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeLayout), findsOneWidget);
    expect(
      preferences.getBool(AppConstants.prefKeyOnboardingCompleted),
      isTrue,
    );
  });

  testWidgets('phone layout keeps tasbeeh progress when changing tabs', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 660);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(preferences, settings, scale: 1.35));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Tasbeeh'),
      ),
    );
    await tester.pumpAndSettle();
    final button = find.widgetWithText(FilledButton, 'Count');
    final originalPosition = tester.getCenter(button);
    await tester.drag(button, const Offset(-105, -100));
    await tester.pumpAndSettle();
    final movedPosition = tester.getCenter(button);
    expect(movedPosition.dx, lessThan(originalPosition.dx));
    expect(movedPosition.dy, lessThan(originalPosition.dy));
    expect(find.text('0 of 33'), findsOneWidget);
    expect(preferences.getDouble('tasbeeh_button_x'), isNotNull);
    await tester.tap(find.text('Count'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 33'), findsOneWidget);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tasbeeh'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 33'), findsOneWidget);
    expect(tester.getCenter(button), movedPosition);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings changes refresh Today and the assistant opens', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(preferences, settings));
    await tester.pumpAndSettle();
    final homeContext = tester.element(find.byType(HomeLayout));
    await tester.runAsync(
      () => homeContext.read<SettingsCubit>().updateThemeMode(ThemeMode.dark),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(
      (navigation.destinations[2] as NavigationDestination).label,
      'Assistant',
    );
    await tester.tap(find.text('Assistant'));
    await tester.pumpAndSettle();
    expect(find.text('Tamanina assistant'), findsOneWidget);
    await tester.tap(find.textContaining('Find a verse:'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ash-Sharh'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark theme matches Today across tabs and the Mushaf', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    await preferences.setString('mushaf_reading_theme', 'cream');
    addTearDown(() => preferences.remove('mushaf_reading_theme'));

    await tester.pumpWidget(
      _app(preferences, settings, themeMode: ThemeMode.dark),
    );
    await tester.pumpAndSettle();

    for (final tab in ['Today', 'Quran', 'Tasbeeh', 'Settings']) {
      final navigation = find.byType(NavigationBar);
      await tester.tap(
        find.descendant(of: navigation, matching: find.text(tab)),
      );
      await tester.pumpAndSettle();
      final scaffold = find.byType(Scaffold).first;
      final theme = Theme.of(tester.element(scaffold));
      expect(
        tester.widget<Scaffold>(scaffold).backgroundColor ??
            theme.scaffoldBackgroundColor,
        AppColors.backgroundDark,
      );
      final barTheme = NavigationBarTheme.of(tester.element(navigation));
      expect(barTheme.backgroundColor, AppColors.surfaceDark);
      expect(barTheme.indicatorColor, AppColors.darkAccent);
    }

    NavigationService.navigatorKey.currentState!.pushNamed(
      AppRoutes.alKahfReader,
    );
    await tester.pumpAndSettle();
    final appBarTheme = Theme.of(tester.element(find.byType(AppBar).last));
    expect(appBarTheme.appBarTheme.backgroundColor, AppColors.backgroundDark);
    expect(appBarTheme.colorScheme.onSurface, AppColors.textOnSurfaceDark);

    await tester.tap(find.byTooltip('Appearance & font'));
    await tester.pumpAndSettle();
    final layoutSwitch = find.text('Printed Mushaf pages');
    expect(layoutSwitch, findsOneWidget);
    expect(Theme.of(tester.element(layoutSwitch)).brightness, Brightness.dark);
    expect(find.text('Warm paper'), findsNothing);
    expect(preferences.getString('mushaf_reading_theme'), 'cream');
    expect(tester.takeException(), isNull);
  });

  for (final arabic in [false, true]) {
    testWidgets(
      'reader buttons and swipe follow ${arabic ? 'Arabic' : 'English'}',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = arabic
            ? const Size(320, 660)
            : const Size(393, 852);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          _app(
            preferences,
            settings,
            locale: Locale(arabic ? 'ar' : 'en'),
            scale: arabic ? 1.4 : 1,
          ),
        );
        await tester.pumpAndSettle();
        NavigationService.navigatorKey.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => const SimpleMushafPageScreen(initialPage: 2),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('﴾'), findsOneWidget);

        final previous = find.byTooltip(
          arabic ? 'الصفحة السابقة' : 'Previous page',
        );
        final next = find.byTooltip(arabic ? 'الصفحة التالية' : 'Next page');
        expect(
          tester.getCenter(next).dx - tester.getCenter(previous).dx,
          arabic ? lessThan(0) : greaterThan(0),
        );
        expect(tester.getCenter(next).dy, tester.getCenter(previous).dy);
        final icon = tester.widget<Icon>(
          find.descendant(of: next, matching: find.byType(Icon)),
        );
        expect(
          icon.icon,
          arabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
        );
        await tester.tap(next);
        await tester.pumpAndSettle();
        expect(
          find.text(arabic ? 'صفحة 3 من 604' : 'Page 3 of 604'),
          findsOneWidget,
        );
        expect(find.textContaining('﴾'), findsOneWidget);
        await tester.fling(
          find.byType(SingleChildScrollView),
          Offset(arabic ? 250 : -250, 0),
          850,
        );
        await tester.pumpAndSettle();
        expect(
          find.text(arabic ? 'صفحة 4 من 604' : 'Page 4 of 604'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Mushaf fills the viewport and keeps manual text enlargement', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    addTearDown(() => preferences.remove('mushaf_font_size'));

    await tester.runAsync(() async {
      await (FontLoader('Amiri')
            ..addFont(rootBundle.load('assets/fonts/amiri-400.ttf'))
            ..addFont(rootBundle.load('assets/fonts/amiri-700.ttf')))
          .load();
    });
    await tester.pumpWidget(_app(preferences, settings));
    await tester.pumpAndSettle();
    NavigationService.navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const SimpleMushafPageScreen(initialPage: 1),
      ),
    );
    await tester.pumpAndSettle();

    final verses = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          (widget.textSpan?.toPlainText().contains('﴾') ?? false),
    );
    final readingArea = find.byType(SingleChildScrollView);
    final firstPage = tester.getRect(verses);
    expect(firstPage.top, lessThan(tester.getRect(readingArea).top + 90));
    expect(
      firstPage.bottom,
      greaterThan(tester.getRect(readingArea).bottom - 40),
    );

    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    final baseSize = tester.widget<Text>(verses).style!.fontSize!;
    final baseHeight = tester.getSize(verses).height;

    await tester.tap(verses);
    await tester.pumpAndSettle();
    expect(find.text('Show bars'), findsOneWidget);
    expect(tester.getSize(verses).height, greaterThan(baseHeight + 25));
    await tester.tap(find.text('Show bars'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Appearance & font'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('A+'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(verses).style!.fontSize, greaterThan(baseSize));
    expect(
      tester.getSize(verses).height,
      greaterThan(tester.getSize(readingArea).height),
    );
    await tester.drag(readingArea, const Offset(0, -240));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(verses).top,
      lessThan(tester.getRect(readingArea).top),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'worship focus is visible before the timetable and tracks activity',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 660);
      addTearDown(tester.view.reset);
      await tester.runAsync(() async {
        if (!Hive.isBoxOpen('statistics')) await Hive.openBox('statistics');
      });
      final count = WorshipLog.count(WorshipActivity.adhkar, DateTime.now());

      await tester.pumpWidget(
        _app(preferences, settings, locale: const Locale('ar'), scale: 1.25),
      );
      await tester.pumpAndSettle();
      final title = find.text('تركيز اليوم والعبادات');
      final tracker = find.byType(HomeWorshipTracker);
      final countBefore = find.descendant(
        of: tracker,
        matching: find.text('$count/2'),
      );
      expect(title.hitTestable(), findsOneWidget);
      expect(countBefore, findsOneWidget);

      await tester.runAsync(() => WorshipLog.record(WorshipActivity.adhkar));
      await tester.pumpAndSettle();
      expect(countBefore, findsNothing);
      expect(
        find.descendant(of: tracker, matching: find.text('${count + 1}/2')),
        findsOneWidget,
      );
      final list = tester.widget<ListView>(
        find.byKey(const PageStorageKey('today-home')),
      );
      final sections =
          (list.childrenDelegate as SliverChildListDelegate).children;
      final focusIndex = sections.indexWhere(
        (section) => section is HomeWorshipTracker,
      );
      final timetableIndex = sections.indexWhere(
        (section) => section is HomePrayerTimeline,
      );
      expect(timetableIndex, greaterThan(focusIndex));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('the home hub shows dhikr after switching pages', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(preferences, settings));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Dhikr'));
    await tester.pumpAndSettle();
    expect(find.text('A moment for dhikr'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('widget and notification shortcuts open the intended content', (
    tester,
  ) async {
    WorshipShortcuts.instance.open(AppRoutes.azkar);
    await tester.pumpWidget(_app(preferences, settings));
    await tester.pumpAndSettle();
    expect(find.text('Choose a collection'), findsOneWidget);

    for (final (route, category) in [
      (AppRoutes.morningAdhkar, AdhkarCategory.morning),
      (AppRoutes.eveningAdhkar, AdhkarCategory.evening),
    ]) {
      WorshipShortcuts.instance.open(route);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AdhkarDetailScreen>(find.byType(AdhkarDetailScreen))
            .category,
        category,
      );
    }

    WorshipShortcuts.instance.open(AppRoutes.sebha);
    await tester.pumpAndSettle();
    expect(find.byType(TasbeehTabScreen), findsOneWidget);

    WorshipShortcuts.instance.open(AppRoutes.quran);
    await tester.pumpAndSettle();
    expect(find.byType(QuranTabScreen), findsOneWidget);

    WorshipShortcuts.instance.open(AppRoutes.alKahfReader);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SimpleMushafPageScreen>(find.byType(SimpleMushafPageScreen))
          .initialSurah,
      18,
    );
  });

  testWidgets('tablet layout opens the locally indexed Quran by surah', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1100, 820);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(preferences, settings));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    await tester.tap(find.text('Quran'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'الناس');
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('An-Naas'));
    await tester.pumpAndSettle();
    expect(find.text('Page 604 of 604'), findsOneWidget);
    expect(find.textContaining('﴾'), findsWidgets);

    await tester.tap(find.byTooltip('Appearance & font'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Printed Mushaf pages'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(PrintedMushafPage),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is ResizeImage &&
              (widget.image as ResizeImage).imageProvider ==
                  const AssetImage('assets/mushaf/604.webp'),
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('Page 604 of 604'), findsOneWidget);
    expect(preferences.getBool('mushaf_print_layout'), isTrue);
    await preferences.remove('mushaf_print_layout');
    expect(tester.takeException(), isNull);
  });
}

Widget _app(
  SharedPreferences preferences,
  SettingsRepository settings, {
  double scale = 1,
  bool startAtSplash = false,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) => MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => SettingsCubit(repository: settings)),
    BlocProvider(create: (_) => sl<SplashCubit>()),
    BlocProvider(create: (_) => sl<OnboardingCubit>()),
  ],
  child: MaterialApp(
    navigatorKey: NavigationService.navigatorKey,
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('ar')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: AppTheme.lightThemeWithFont(null),
    darkTheme: AppTheme.darkThemeWithFont(null),
    themeMode: themeMode,
    onGenerateRoute: AppRouter(preferences).generateRoute,
    initialRoute: startAtSplash ? AppRoutes.splash : AppRoutes.home,
    onGenerateInitialRoutes: (_) => [
      MaterialPageRoute<void>(
        builder: (_) =>
            startAtSplash ? const SplashScreen() : const HomeLayout(),
      ),
    ],
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
  ),
);
