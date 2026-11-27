import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tamanina/features/chatbot/ui/widgets/markdown_text.dart';

void main() {
  Future<void> show(WidgetTester tester, String text, {bool caret = false}) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownText(
              text,
              style: const TextStyle(fontSize: 14),
              caret: caret,
            ),
          ),
        ),
      );

  testWidgets('bold, bullets and numbers render without the markers', (
    tester,
  ) async {
    await show(tester, '## عنوان\nنص **مهم** هنا\n- الأول\n* الثاني\n1. خطوة');
    final text = tester
        .widgetList<RichText>(find.byType(RichText))
        .map((widget) => widget.text.toPlainText())
        .join('|');
    expect(text, contains('نص مهم هنا'));
    expect(text, isNot(contains('**')));
    expect(text, isNot(contains('##')));
    expect(find.text('•'), findsNWidgets(2));
    expect(find.text('1.'), findsOneWidget);
  });

  testWidgets('an unfinished marker while streaming stays plain text', (
    tester,
  ) async {
    await show(tester, 'نص **غير مكتمل', caret: true);
    final text = tester
        .widgetList<RichText>(find.byType(RichText))
        .map((widget) => widget.text.toPlainText())
        .join();
    expect(text, contains('**غير مكتمل'));
    expect(text, contains('▍'));
  });
}
