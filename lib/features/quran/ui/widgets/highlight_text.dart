import 'package:flutter/material.dart';

/// Displays Quranic text and highlights the currently recited word.
class HighlightText extends StatelessWidget {
  const HighlightText({
    super.key,
    required this.text,
    required this.currentWordIndex,
    this.activeStyle,
    this.inactiveStyle,
  });

  /// Raw ayah text.
  final String text;

  /// Index of the word being highlighted.
  final int currentWordIndex;

  /// Style for the active (highlighted) word.
  final TextStyle? activeStyle;

  /// Style applied to non-highlighted words.
  final TextStyle? inactiveStyle;

  @override
  Widget build(BuildContext context) {
    final words = text.trim().split(RegExp(r'\s+'));
    final baseStyle =
        inactiveStyle ?? Theme.of(context).textTheme.headlineMedium;
    final highlight = activeStyle ??
        baseStyle?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: baseStyle,
          children: <InlineSpan>[
            for (var index = 0; index < words.length; index++)
              TextSpan(
                text: index == words.length - 1
                    ? words[index]
                    : '${words[index]} ',
                style: index == currentWordIndex ? highlight : baseStyle,
              ),
          ],
        ),
      ),
    );
  }
}
