// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tamanina/core/services/prayer_service.dart';
import 'package:tamanina/features/home/ui/widgets/prayer_time_card.dart';

void main() {
  // Ensure Flutter bindings are initialized
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize locale data for date formatting
  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  group('Basic Widget Tests', () {
    testWidgets('PrayerTimeCard should render prayer name',
        (WidgetTester tester) async {
      final prayerData = PrayerTimeData(
        name: 'fajr',
        nameArabic: 'الفجر',
        time: DateTime(2024, 3, 15, 5, 30),
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) {
            return MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  body: PrayerTimeCard(prayer: prayerData, isDark: false),
                ),
              ),
            );
          },
        ),
      );

      // Prayer name should be displayed
      expect(find.text('الفجر'), findsOneWidget);
    });

    testWidgets('MaterialApp structure test', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('تطبيق طمأنينة'),
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('تطبيق طمأنينة'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
