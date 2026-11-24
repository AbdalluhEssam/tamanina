import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomePalette {
  const HomePalette._({
    required this.background,
    required this.surface,
    required this.raised,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.border,
  });

  static const night = AppColors.backgroundDark;
  static const deepGreen = Color(0xFF092A23);
  static const gold = AppColors.darkAccent;
  static const goldLight = Color(0xFFFFD591);
  static const onGold = AppColors.onDarkAccent;
  static const ivory = AppColors.textOnSurfaceDark;
  static const mist = AppColors.darkMuted;

  static const _dark = HomePalette._(
    background: night,
    surface: AppColors.surfaceDark,
    raised: AppColors.surfaceDarkRaised,
    ink: ivory,
    muted: mist,
    accent: gold,
    border: AppColors.dividerDark,
  );
  static const _light = HomePalette._(
    background: Color(0xFFF5F4EC),
    surface: Color(0xFFFFFEF8),
    raised: Color(0xFFE8EFE6),
    ink: Color(0xFF14362A),
    muted: Color(0xFF4B6658),
    accent: Color(0xFF80571C),
    border: Color(0xFFCEDACD),
  );

  final Color background;
  final Color surface;
  final Color raised;
  final Color ink;
  final Color muted;
  final Color accent;
  final Color border;

  static HomePalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;
}

class HomePanel extends StatelessWidget {
  const HomePanel({
    super.key,
    required this.child,
    this.artwork,
    this.onTap,
    this.background,
    this.border,
    this.radius = 19,
  });

  final Widget child;
  final Widget? artwork;
  final VoidCallback? onTap;
  final Color? background;
  final Color? border;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = HomePalette.of(context);
    final corners = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: corners,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: ColoredBox(color: background ?? palette.surface),
          ),
          if (artwork case final artwork?)
            Positioned.fill(child: IgnorePointer(child: artwork)),
          Material(
            type: MaterialType.transparency,
            child: onTap == null
                ? child
                : InkWell(onTap: onTap, borderRadius: corners, child: child),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: corners,
                  border: Border.all(color: border ?? palette.border),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeArt extends StatelessWidget {
  const HomeArt(
    this.asset, {
    super.key,
    this.alignment = Alignment.bottomCenter,
    this.mirrorInEnglish = false,
    this.fit = BoxFit.cover,
  });

  final String asset;
  final Alignment alignment;
  final bool mirrorInEnglish;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final mirror =
        mirrorInEnglish && Directionality.of(context) == TextDirection.ltr;
    return Transform.flip(
      flipX: mirror,
      child: Image.asset(
        asset,
        alignment: alignment,
        fit: fit,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}
