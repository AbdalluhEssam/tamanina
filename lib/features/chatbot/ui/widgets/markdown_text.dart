import 'package:flutter/material.dart';

/// Renders the small subset of Markdown that chat answers use: headings,
/// bullet and numbered lists, **bold**, *italic* and `code`. Unfinished markers
/// (while an answer is still streaming) are shown as plain text.
class MarkdownText extends StatelessWidget {
  const MarkdownText(
    this.text, {
    required this.style,
    this.caret = false,
    this.selectable = false,
    super.key,
  });

  final String text;
  final TextStyle style;

  /// Shows a blinking-style caret at the end, for text that is still arriving.
  final bool caret;
  final bool selectable;

  static final _heading = RegExp(r'^\s{0,3}(#{1,4})\s+(.*)$');
  static final _bullet = RegExp(r'^\s*[-*•]\s+(.*)$');
  static final _number = RegExp(r'^\s*(\d{1,2})[.)]\s+(.*)$');
  static final _inline = RegExp(
    r'(\*\*[^*\n]+\*\*|`[^`\n]+`|(?<![*\w])\*[^*\s][^*\n]*?\*(?![*\w]))',
  );

  List<InlineSpan> _spans(String line, TextStyle base, Color codeBackground) {
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _inline.allMatches(line)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: line.substring(cursor, match.start)));
      }
      final token = match.group(0)!;
      if (token.startsWith('**')) {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      } else if (token.startsWith('`')) {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: TextStyle(
              fontFamily: 'monospace',
              backgroundColor: codeBackground,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      }
      cursor = match.end;
    }
    if (cursor < line.length) spans.add(TextSpan(text: line.substring(cursor)));
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lines = text.split('\n');
    final blocks = <Widget>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final last = i == lines.length - 1;
      final tail = caret && last
          ? [const TextSpan(text: ' ▍')]
          : const <InlineSpan>[];
      if (line.trim().isEmpty) {
        if (!last) blocks.add(const SizedBox(height: 6));
        continue;
      }
      final heading = _heading.firstMatch(line);
      final bullet = _bullet.firstMatch(line);
      final number = _number.firstMatch(line);
      Widget block;
      if (heading != null) {
        block = _rich(
          context,
          [
            ..._spans(heading.group(2)!, style, scheme.surfaceContainerHighest),
            ...tail,
          ],
          style.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: (style.fontSize ?? 14) * 1.12,
          ),
        );
      } else if (bullet != null || number != null) {
        final marker = bullet != null ? '•' : '${number!.group(1)}.';
        final body = bullet != null ? bullet.group(1)! : number!.group(2)!;
        block = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: bullet != null ? 18 : 26,
              child: Text(marker, style: style),
            ),
            Expanded(
              child: _rich(context, [
                ..._spans(body, style, scheme.surfaceContainerHighest),
                ...tail,
              ], style),
            ),
          ],
        );
      } else {
        block = _rich(context, [
          ..._spans(line, style, scheme.surfaceContainerHighest),
          ...tail,
        ], style);
      }
      blocks.add(
        Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: block),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: blocks,
    );
  }

  Widget _rich(BuildContext context, List<InlineSpan> spans, TextStyle base) {
    final span = TextSpan(style: base, children: spans);
    return selectable ? SelectableText.rich(span) : Text.rich(span);
  }
}
