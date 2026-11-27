import 'package:flutter/material.dart';

import '../../../../core/widgets/tamanina_ui.dart';
import '../../data/services/mushaf_geometry.dart';
import '../../data/services/mushaf_pages.dart';
import '../../../settings/ui/widgets/packs_sheet.dart';

class PrintedMushafPage extends StatelessWidget {
  const PrintedMushafPage({
    super.key,
    required this.page,
    required this.warmPaper,
    required this.onTap,
    this.activeVerse,
  });

  final int page;
  final bool warmPaper;
  final VoidCallback onTap;

  /// Verse being recited. It is highlighted on the page image.
  final int? activeVerse;

  // Round the decode bounds so small layout changes can reuse the cached image.
  static int _decodeBound(double extent, double devicePixelRatio) =>
      ((extent * devicePixelRatio / 128).ceil() * 128).clamp(128, 1440);

  // Map the original ink and frame to a light ink and a subdued green at night.
  // The alpha channel retains the original outlines and diacritics.
  static const _nightInk = ColorFilter.matrix([
    -.19,
    -.64,
    -.06,
    0,
    255,
    -.16,
    -.55,
    -.06,
    0,
    255,
    -.18,
    -.62,
    -.06,
    0,
    240,
    0,
    0,
    0,
    1,
    0,
  ]);

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: MushafPages.instance, builder: _build);

  Widget _build(BuildContext context, Widget? _) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final paper = dark
        ? scheme.surface
        : warmPaper
        ? const Color(0xFFFFF5DE)
        : const Color(0xFFFFFEF8);
    final seam = dark ? scheme.outlineVariant : const Color(0xFFE1DBCA);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: paper,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: seam),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final source = MushafPages.instance.provider(page);
                  if (source == null) {
                    return _MissingPage(page: page);
                  }
                  final width = constraints.hasBoundedWidth
                      ? _decodeBound(constraints.maxWidth, pixelRatio)
                      : null;
                  final height = constraints.hasBoundedHeight
                      ? _decodeBound(constraints.maxHeight, pixelRatio)
                      : null;
                  final artwork = Image(
                    image: width == null && height == null
                        ? source
                        : ResizeImage(
                            source,
                            width: width,
                            height: height,
                            policy: ResizeImagePolicy.fit,
                          ),
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                    semanticLabel: appText(
                      context,
                      'المصحف، صفحة $page',
                      'Mushaf, page $page',
                    ),
                  );
                  final art = dark
                      ? ColorFiltered(colorFilter: _nightInk, child: artwork)
                      : artwork;
                  final geometry = activeVerse == null
                      ? null
                      : MushafGeometry.instance.page(page);
                  final rects = geometry?.rectsFor(activeVerse!) ?? const [];
                  if (geometry == null || rects.isEmpty) return art;
                  return Stack(
                    fit: StackFit.passthrough,
                    children: [
                      art,
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _VerseHighlight(
                              rects: rects,
                              imageSize: Size(geometry.width, geometry.height),
                              color: dark
                                  ? const Color(0x66E7C26A)
                                  : const Color(0x55C79A2A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints translucent bars over [rects] given in the page image's pixels, using
/// the same `BoxFit.contain` placement as the artwork.
class _VerseHighlight extends CustomPainter {
  const _VerseHighlight({
    required this.rects,
    required this.imageSize,
    required this.color,
  });

  final List<Rect> rects;
  final Size imageSize;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fitted = applyBoxFit(BoxFit.contain, imageSize, size);
    final target = Alignment.center.inscribe(fitted.destination, Offset.zero & size);
    final scale = target.width / imageSize.width;
    final paint = Paint()..color = color;
    for (final rect in rects) {
      // The full line band, so tall letters and marks are covered.
      final shifted = Rect.fromLTRB(
        target.left + rect.left * scale,
        target.top + rect.top * scale,
        target.left + rect.right * scale,
        target.top + rect.bottom * scale,
      ).inflate(1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(shifted, const Radius.circular(5)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_VerseHighlight old) =>
      old.rects != rects || old.color != color || old.imageSize != imageSize;
}

class _MissingPage extends StatelessWidget {
  const _MissingPage({required this.page});

  final int page;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.menu_book_outlined, size: 48),
        const SizedBox(height: 12),
        Text(
          appText(
            context,
            'صفحة $page غير محمّلة بعد',
            'Page $page is not downloaded yet',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          appText(
            context,
            'حمّل صفحات المصحف مرة واحدة لتقرأ بدون إنترنت.',
            'Download the Mushaf pages once to read offline.',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => showPacksSheet(context),
          icon: const Icon(Icons.download),
          label: Text(appText(context, 'تحميل المصحف', 'Download Mushaf')),
        ),
      ],
    ),
  );
}

class MushafLayoutSwitch extends StatelessWidget {
  const MushafLayoutSwitch({
    super.key,
    required this.printLayout,
    required this.onChanged,
  });

  final bool printLayout;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
    title: Text(
      appText(context, 'صفحات المصحف المطبوع', 'Printed Mushaf pages'),
    ),
    subtitle: Text(
      appText(
        context,
        'أوقفه للقراءة بخط قابل للتكبير والتخصيص',
        'Turn off to read with adjustable text size and typeface',
      ),
    ),
    value: printLayout,
    onChanged: onChanged,
  );
}
