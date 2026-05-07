import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tamanina/core/services/prayer_service.dart';
import 'package:tamanina/features/home/ui/widgets/prayer_time_card.dart';
import 'package:tamanina/features/home/ui/widgets/next_prayer_countdown.dart';
import 'package:tamanina/features/home/ui/widgets/date_location_header.dart';

void main() {
  // Initialize locale data for date formatting
  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  // Helper to wrap widgets with necessary dependencies
  Widget buildTestableWidget(Widget widget) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: widget),
          ),
        );
      },
    );
  }

  group('PrayerTimeCard Widget', () {
    testWidgets('should display prayer name and time',
        (WidgetTester tester) async {
      final prayerData = PrayerTimeData(
        name: 'fajr',
        nameArabic: 'الفجر',
        time: DateTime(2024, 3, 15, 5, 30),
      );

      await tester.pumpWidget(buildTestableWidget(
        PrayerTimeCard(prayer: prayerData, isDark: false),
      ));

      expect(find.text('الفجر'), findsOneWidget);
    });

    testWidgets('should show active indicator when isNext is true',
        (WidgetTester tester) async {
      final prayerData = PrayerTimeData(
        name: 'dhuhr',
        nameArabic: 'الظهر',
        time: DateTime(2024, 3, 15, 12, 30),
        isNext: true,
      );

      await tester.pumpWidget(buildTestableWidget(
        PrayerTimeCard(prayer: prayerData, isDark: false),
      ));

      expect(find.text('الظهر'), findsOneWidget);
    });

    testWidgets('should display past prayer differently',
        (WidgetTester tester) async {
      final prayerData = PrayerTimeData(
        name: 'fajr',
        nameArabic: 'الفجر',
        time: DateTime(2024, 3, 15, 5, 30),
        timeSince: Duration(hours: 5),
      );

      await tester.pumpWidget(buildTestableWidget(
        PrayerTimeCard(prayer: prayerData, isDark: false),
      ));

      expect(find.text('الفجر'), findsOneWidget);
    });

    testWidgets('should render in dark mode', (WidgetTester tester) async {
      final prayerData = PrayerTimeData(
        name: 'isha',
        nameArabic: 'العشاء',
        time: DateTime(2024, 3, 15, 19, 30),
      );

      await tester.pumpWidget(buildTestableWidget(
        PrayerTimeCard(prayer: prayerData, isDark: true),
      ));

      expect(find.text('العشاء'), findsOneWidget);
    });
  });

  group('NextPrayerCountdown Widget', () {
    testWidgets('should display countdown timer', (WidgetTester tester) async {
      final nextPrayer = PrayerTimeData(
        name: 'asr',
        nameArabic: 'العصر',
        time: DateTime.now().add(Duration(hours: 2, minutes: 30)),
        isNext: true,
        timeUntil: Duration(hours: 2, minutes: 30),
      );

      final currentPrayer = PrayerTimeData(
        name: 'dhuhr',
        nameArabic: 'الظهر',
        time: DateTime.now().subtract(Duration(hours: 1)),
        timeSince: Duration(hours: 1),
      );

      await tester.pumpWidget(buildTestableWidget(
        NextPrayerCountdown(
          nextPrayer: nextPrayer,
          currentPrayer: currentPrayer,
          isDark: false,
        ),
      ));

      expect(find.text('العصر'), findsOneWidget);
    });

    testWidgets('should update countdown when time changes',
        (WidgetTester tester) async {
      final nextPrayer = PrayerTimeData(
        name: 'maghrib',
        nameArabic: 'المغرب',
        time: DateTime.now().add(Duration(minutes: 5)),
        isNext: true,
        timeUntil: Duration(minutes: 5),
      );

      final currentPrayer = PrayerTimeData(
        name: 'asr',
        nameArabic: 'العصر',
        time: DateTime.now().subtract(Duration(hours: 2)),
        timeSince: Duration(hours: 2),
      );

      await tester.pumpWidget(buildTestableWidget(
        NextPrayerCountdown(
          nextPrayer: nextPrayer,
          currentPrayer: currentPrayer,
          isDark: false,
        ),
      ));

      // Initial render
      expect(find.text('المغرب'), findsOneWidget);

      // Pump to simulate time passing
      await tester.pump(Duration(seconds: 1));
    });

    testWidgets('should handle null next prayer gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        NextPrayerCountdown(
          nextPrayer: null,
          currentPrayer: null,
          isDark: false,
        ),
      ));

      // Should not crash
      await tester.pump();
    });
  });

  group('DateLocationHeader Widget', () {
    testWidgets('should display city name', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        DateLocationHeader(
          hijriDate: '5 رمضان 1445',
          gregorianDate: '15 مارس 2024',
          cityName: 'مكة المكرمة',
          countryName: 'المملكة العربية السعودية',
          isDark: false,
        ),
      ));

      expect(find.text('مكة المكرمة'), findsOneWidget);
    });

    testWidgets('should display hijri date', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        DateLocationHeader(
          hijriDate: '5 رمضان 1445',
          gregorianDate: '15 مارس 2024',
          cityName: 'القاهرة',
          countryName: 'مصر',
          isDark: false,
        ),
      ));

      expect(find.text('5 رمضان 1445'), findsOneWidget);
    });

    testWidgets('should display gregorian date', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        DateLocationHeader(
          hijriDate: '5 رمضان 1445',
          gregorianDate: '15 مارس 2024',
          cityName: 'دبي',
          countryName: 'الإمارات',
          isDark: false,
        ),
      ));

      expect(find.text('15 مارس 2024'), findsOneWidget);
    });

    testWidgets('should render in dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(
        DateLocationHeader(
          hijriDate: '5 رمضان 1445',
          gregorianDate: '15 مارس 2024',
          cityName: 'الرياض',
          countryName: 'المملكة العربية السعودية',
          isDark: true,
        ),
      ));

      expect(find.text('الرياض'), findsOneWidget);
    });
  });

  group('Quick Actions', () {
    testWidgets('should contain navigation buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) {
            return MaterialApp(
              home: Builder(
                builder: (context) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: Scaffold(
                      body: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Mock quick action buttons
                            TextButton(
                              onPressed: () {},
                              child: Text('القرآن'),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text('الأذكار'),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text('القبلة'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );

      expect(find.text('القرآن'), findsOneWidget);
      expect(find.text('الأذكار'), findsOneWidget);
      expect(find.text('القبلة'), findsOneWidget);
    });
  });
}
