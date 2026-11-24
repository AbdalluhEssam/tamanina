import 'package:flutter/material.dart';

import '../../../../core/widgets/tamanina_ui.dart';

class PrintedMushafPage extends StatelessWidget {
  const PrintedMushafPage({
    super.key,
    required this.page,
    required this.warmPaper,
    required this.onTap,
  });

  final int page;
  final bool warmPaper;
  final VoidCallback onTap;

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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final paper = dark
        ? scheme.surface
        : warmPaper
        ? const Color(0xFFFFF5DE)
        : const Color(0xFFFFFEF8);
    final seam = dark ? scheme.outlineVariant : const Color(0xFFE1DBCA);
    final file = page.toString().padLeft(3, '0');

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
                  final source = AssetImage('assets/mushaf/$file.webp');
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
                  return dark
                      ? ColorFiltered(colorFilter: _nightInk, child: artwork)
                      : artwork;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
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
