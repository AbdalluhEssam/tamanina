
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamanina/features/quran/data/services/mushaf_geometry.dart';
import 'package:tamanina/features/quran/ui/widgets/printed_mushaf_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every verse of the Quran has a position on its page', () async {
    await MushafGeometry.instance.load();
    final seen = <int>{};
    final problems = <String>[];
    for (var page = 1; page <= 604; page++) {
      final geometry = MushafGeometry.instance.page(page)!;
      for (final verse in geometry.verses) {
        seen.add(verse);
        for (final rect in geometry.rectsFor(verse)) {
          if (rect.width <= 0 ||
              rect.left < -1 ||
              rect.right > geometry.width + 1 ||
              rect.top < -1 ||
              rect.bottom > geometry.height + 1) {
            problems.add('page $page verse $verse $rect');
          }
        }
      }
    }
    expect(problems, isEmpty);
    expect(seen.length, 6236);
    expect(seen.contains(1) && seen.contains(6236), isTrue);
  });

  test('verses read right to left and stay in line order', () async {
    await MushafGeometry.instance.load();
    // Page 1: the seven verses of Al-Fatiha, one per line from top to bottom.
    final page = MushafGeometry.instance.page(1)!;
    final tops = [for (var v = 1; v <= 7; v++) page.rectsFor(v).first.top];
    expect(tops, orderedEquals([...tops]..sort()));
    // Page 300 verse 54 of Al-Kahf starts after verse 53 on the same page.
    final p300 = MushafGeometry.instance.page(300)!;
    expect(p300.verses, isNotEmpty);
    expect(MushafGeometry.instance.page(0), isNull);
  });

  setUpAll(() async {
    await MushafGeometry.instance.load();
  });

  testWidgets('the recited verse is highlighted on a bundled page', (
    tester,
  ) async {
    Widget app(int? verse) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 700,
          child: PrintedMushafPage(
            page: 1,
            warmPaper: false,
            onTap: () {},
            activeVerse: verse,
          ),
        ),
      ),
    );
    final highlight = find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint &&
          widget.painter.runtimeType.toString() == '_VerseHighlight',
    );
    await tester.pumpWidget(app(null));
    expect(highlight, findsNothing);
    await tester.pumpWidget(app(1));
    expect(highlight, findsOneWidget);
    await tester.pumpWidget(app(null));
    expect(highlight, findsNothing);
  });
}
