// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tamanina/core/services/prayer_service.dart';
import 'package:tamanina/core/widgets/tamanina_ui.dart';
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

    testWidgets('appChevron points forward correctly in RTL and LTR on Android and iOS',
        (WidgetTester tester) async {
      Future<({IconData? icon, bool mirrored})> pumpChevron({
        required TargetPlatform platform,
        required TextDirection direction,
        bool backwards = false,
      }) async {
        late IconData resolved;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: platform),
            home: Directionality(
              textDirection: direction,
              child: Builder(
                builder: (context) {
                  resolved = appChevron(context, backwards: backwards);
                  return Icon(resolved);
                },
              ),
            ),
          ),
        );
        final hasTransform = find
            .descendant(of: find.byType(Icon), matching: find.byType(Transform))
            .evaluate()
            .isNotEmpty;
        return (icon: resolved, mirrored: hasTransform);
      }

      // Android uses Material chevrons (matchTextDirection: true) and lets Icon mirror in RTL.
      final androidRtl = await pumpChevron(
        platform: TargetPlatform.android,
        direction: TextDirection.rtl,
      );
      expect(androidRtl.icon, Icons.chevron_right_rounded);
      expect(androidRtl.mirrored, isTrue);

      final androidLtr = await pumpChevron(
        platform: TargetPlatform.android,
        direction: TextDirection.ltr,
      );
      expect(androidLtr.icon, Icons.chevron_right_rounded);
      expect(androidLtr.mirrored, isFalse);

      final androidRtlBack = await pumpChevron(
        platform: TargetPlatform.android,
        direction: TextDirection.rtl,
        backwards: true,
      );
      expect(androidRtlBack.icon, Icons.chevron_left_rounded);
      expect(androidRtlBack.mirrored, isTrue);

      // iOS uses Cupertino chevrons (matchTextDirection: false) and picks left/right explicitly.
      final iosRtl = await pumpChevron(
        platform: TargetPlatform.iOS,
        direction: TextDirection.rtl,
      );
      expect(iosRtl.icon, CupertinoIcons.chevron_left);
      expect(iosRtl.mirrored, isFalse);

      final iosLtr = await pumpChevron(
        platform: TargetPlatform.iOS,
        direction: TextDirection.ltr,
      );
      expect(iosLtr.icon, CupertinoIcons.chevron_right);
      expect(iosLtr.mirrored, isFalse);
    });
  });
}
