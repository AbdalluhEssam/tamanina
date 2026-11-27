import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamanina/core/audio/audio_catalog.dart';
import 'package:tamanina/core/audio/audio_library.dart';
import 'package:tamanina/features/prayer_times/ui/screens/adhan_screen.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.abdalluh.tamanina/adhan_alarms');
  late List<String> calls;
  late Map<String, Object> status;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Screen tests should not depend on loading the catalog.
    debugCatalog = AudioCatalog.fallback;
    calls = [];
    status = {'playing': true, 'positionMs': 20000, 'durationMs': 154000};
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call.method);
      return call.method == 'status' ? status : null;
    });
  });

  tearDown(() {
    debugCatalog = null;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  void scenario(String name, Future<void> Function(WidgetTester tester) body) {
    testWidgets(name, (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        await body(tester);
        await tester.pumpWidget(const SizedBox());
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdhanScreen(
          args: AdhanScreenArgs(
            prayerNameArabic: 'الفجر',
            prayerName: 'Fajr',
            isFajr: true,
            followNative: true,
          ),
        ),
      ),
    );
    // The screen loads the catalog first, which uses real asynchronous I/O.
    for (var i = 0; i < 40 && !calls.contains('status'); i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 400));
  }

  scenario('follows the Android playback without starting its own', (
    tester,
  ) async {
    await open(tester);
    expect(calls, contains('status'));
    expect(calls, isNot(contains('stop')));
    expect(find.byIcon(Icons.pause), findsOneWidget);
  });

  scenario('dismissing stops the service and leaves the lock screen', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 2400);
    addTearDown(tester.view.reset);
    await open(tester);
    await tester.tap(find.text('Dismiss Adhan'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(calls, containsAllInOrder(['stop', 'closeOverLockScreen']));
  });

  scenario('an adhan that already ended shows the completed state', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 2400);
    addTearDown(tester.view.reset);
    status = {'playing': false, 'positionMs': 0, 'durationMs': 0};
    AdhanScreen.followGrace = Duration.zero;
    addTearDown(() => AdhanScreen.followGrace = const Duration(seconds: 6));
    await open(tester);
    expect(find.byIcon(Icons.replay), findsWidgets);
  });
}
