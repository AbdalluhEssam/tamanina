import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

String appText(BuildContext context, String arabic, String english) =>
    Localizations.localeOf(context).languageCode == 'ar' ? arabic : english;

IconData platformIcon(BuildContext context, IconData material, IconData ios) =>
    Theme.of(context).platform == TargetPlatform.iOS ? ios : material;

IconData appChevron(BuildContext context, {bool backwards = false}) {
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    final pointsLeft =
        (Directionality.of(context) == TextDirection.rtl) != backwards;
    return pointsLeft
        ? CupertinoIcons.chevron_left
        : CupertinoIcons.chevron_right;
  }
  // Material chevron_*_rounded sets matchTextDirection: true, so Icon mirrors
  // chevron_right_rounded into a left-pointing chevron in RTL automatically.
  return backwards ? Icons.chevron_left_rounded : Icons.chevron_right_rounded;
}

class ContentFrame extends StatelessWidget {
  const ContentFrame({super.key, required this.child, this.maxWidth = 760});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/brand_mark.png',
    width: size,
    height: size,
    excludeFromSemantics: true,
  );
}

class AppSkeleton extends StatelessWidget {
  const AppSkeleton({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    label: appText(context, 'جارٍ التحميل', 'Loading'),
    liveRegion: true,
    child: ExcludeSemantics(
      child: TickerMode(
        enabled: !MediaQuery.disableAnimationsOf(context),
        child: SkeletonizerConfig(
          data: SkeletonizerConfigData(
            brightness: Theme.of(context).brightness,
          ),
          child: Skeletonizer(child: child),
        ),
      ),
    ),
  );
}

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.rows = 5});

  final int rows;

  @override
  Widget build(BuildContext context) => ContentFrame(
    child: AppSkeleton(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rows,
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: ListTile(
              leading: const CircleAvatar(),
              title: Text(BoneMock.words(2 + index % 3)),
              subtitle: Text(BoneMock.words(4)),
            ),
          ),
        ),
      ),
    ),
  );
}
