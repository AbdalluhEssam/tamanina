import 'package:flutter/widgets.dart';

TextStyle fitMushafText({
  required TextStyle style,
  required TextScaler textScaler,
  required TextHeightBehavior? textHeightBehavior,
  required TextAlign textAlign,
  required List<TextSpan> paragraphs,
  required Size space,
  required bool opening,
}) {
  final painter = TextPainter(
    textDirection: TextDirection.rtl,
    textScaler: textScaler,
    textHeightBehavior: textHeightBehavior,
    textAlign: textAlign,
  );

  bool fits(TextStyle candidate) {
    var used = 0.0;
    for (final paragraph in paragraphs) {
      painter.text = TextSpan(style: candidate, children: [paragraph]);
      painter.layout(maxWidth: space.width);
      used += painter.height;
      if (used > space.height) return false;
    }
    return true;
  }

  double largestFitting(double min, double max, bool Function(double) fits) {
    if (fits(max)) return max;
    while (max - min > .12) {
      final middle = (min + max) / 2;
      if (fits(middle)) {
        min = middle;
      } else {
        max = middle;
      }
    }
    return min;
  }

  // Keep a readable size on short screens and let the reader scroll as needed.
  final minSize = (space.width / 18).clamp(16.0, 18.0);
  final maxSize = (space.width / (opening ? 11.0 : 10.0)).clamp(24.0, 48.0);
  final lineHeight = style.height!;
  try {
    final size = largestFitting(
      minSize,
      maxSize,
      (size) => fits(style.copyWith(fontSize: size)),
    );
    final sized = style.copyWith(fontSize: size);
    final spacing = largestFitting(
      lineHeight,
      lineHeight + (opening ? 1.35 : .5),
      (height) => fits(sized.copyWith(height: height)),
    );
    return sized.copyWith(height: spacing);
  } finally {
    painter.dispose();
  }
}
