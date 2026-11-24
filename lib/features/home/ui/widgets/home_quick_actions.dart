import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import 'home_visuals.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _AdhkarTile(
                title: appText(context, 'أذكار الصباح', 'Morning adhkar'),
                icon: Icons.wb_twilight_rounded,
                route: AppRoutes.morningAdhkar,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _AdhkarTile(
                title: appText(context, 'أذكار المساء', 'Evening adhkar'),
                icon: Icons.nights_stay_rounded,
                route: AppRoutes.eveningAdhkar,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _QuranBanner(),
        const SizedBox(height: 6),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: colors.accent),
            icon: const Icon(Icons.explore_outlined, size: 18),
            label: Text(appText(context, 'اتجاه القبلة', 'Qibla direction')),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.qibla),
          ),
        ),
      ],
    );
  }
}

class _AdhkarTile extends StatelessWidget {
  const _AdhkarTile({
    required this.title,
    required this.icon,
    required this.route,
  });

  final String title;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return HomePanel(
      background: HomePalette.deepGreen,
      border: const Color(0xFF3B5747),
      artwork: const HomeArt('assets/images/home_horizon.webp'),
      onTap: () => Navigator.pushNamed(context, route),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 12, 7, 13),
        child: Column(
          children: [
            Icon(icon, size: 26, color: HomePalette.gold),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: HomePalette.ivory,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuranBanner extends StatelessWidget {
  const _QuranBanner();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return HomePanel(
      background: HomePalette.deepGreen,
      border: const Color(0xFF3C5448),
      artwork: const HomeArt(
        'assets/images/home_quran.webp',
        mirrorInEnglish: true,
        fit: BoxFit.fill,
      ),
      onTap: () => Navigator.pushNamed(context, AppRoutes.mushafReader),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
          final fraction = scale >= 1.45 ? .82 : .58;
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              width: constraints.maxWidth * fraction,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(13, 14, 0, 13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appText(context, 'المصحف الشريف', 'The Holy Quran'),
                      style: text.titleLarge?.copyWith(
                        color: HomePalette.ivory,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      appText(
                        context,
                        'واصل قراءة وردك',
                        'Continue your reading',
                      ),
                      style: text.bodySmall?.copyWith(color: HomePalette.mist),
                    ),
                    const SizedBox(height: 7),
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        color: HomePalette.gold,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          appChevron(context),
                          size: 15,
                          color: HomePalette.onGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
