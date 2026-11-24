import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/onboarding_journey_art.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish({bool skipped = false}) async {
    if (_saving) return;
    setState(() => _saving = true);
    final cubit = context.read<OnboardingCubit>();
    if (skipped) {
      await cubit.skipOnboarding();
    } else {
      await cubit.completeOnboarding();
    }
    if (mounted) setState(() => _saving = false);
  }

  void _goTo(int step) {
    if (_saving || !_controller.hasClients) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(step);
    } else {
      _controller.animateToPage(
        step,
        duration: const Duration(milliseconds: 390),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<OnboardingCubit>();
    final pages = cubit.onboardingPages;
    final page = cubit.currentPageIndex;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';

    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingCompleted || state is OnboardingSkipped) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (_) => false,
          );
        } else if (state is OnboardingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                appText(
                  context,
                  'تعذّر حفظ التقدّم. حاول مرة أخرى.',
                  'Progress could not be saved. Try again.',
                ),
              ),
            ),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: PopScope(
          canPop: page == 0 && !_saving,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && page > 0) _goTo(page - 1);
          },
          child: Scaffold(
            backgroundColor: JourneyColors.background,
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          24,
                          2,
                          14,
                          0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: JourneyColors.brandSurface,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const BrandMark(size: 26),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                appText(context, 'طمأنينة', 'Tamanina'),
                                style: TextStyle(
                                  color: JourneyColors.ivory,
                                  fontFamily: arabic ? 'Reem Kufi' : 'Poppins',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _saving
                                  ? null
                                  : () => _finish(skipped: true),
                              style: TextButton.styleFrom(
                                foregroundColor: JourneyColors.muted,
                                minimumSize: const Size(48, 48),
                              ),
                              child: Text(appText(context, 'تخطّي', 'Skip')),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _controller,
                          onPageChanged: cubit.onPageChanged,
                          allowImplicitScrolling: true,
                          itemCount: pages.length,
                          itemBuilder: (context, index) {
                            final data = pages[index];
                            return LayoutBuilder(
                              builder: (context, viewport) {
                                final width = viewport.maxWidth;
                                final height = viewport.maxHeight;
                                final compact = height < 555;
                                final scale =
                                    MediaQuery.textScalerOf(context).scale(16) /
                                    16;
                                final textAllowance =
                                    64 * (scale - 1).clamp(0.0, 2.0);
                                final artHeight = math.min(
                                  width * 1.08,
                                  math.max(
                                    166.0,
                                    height * (compact ? .66 : .73) -
                                        textAllowance,
                                  ),
                                );
                                return SingleChildScrollView(
                                  key: PageStorageKey<int>(index),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: height,
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: math.max(
                                            0.0,
                                            (height - artHeight - 155) * .40,
                                          ),
                                        ),
                                        SizedBox(
                                          height: artHeight,
                                          width: width,
                                          child: ExcludeSemantics(
                                            child: OnboardingJourneyArt(
                                              index: index,
                                              asset: data.imagePath,
                                              controller: _controller,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: compact ? 12 : 23),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                            20,
                                            0,
                                            20,
                                            compact ? 12 : 20,
                                          ),
                                          child: Column(
                                            children: [
                                              Semantics(
                                                header: true,
                                                child: Text(
                                                  arabic
                                                      ? data.titleAr
                                                      : data.titleEn,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: JourneyColors.ivory,
                                                    fontFamily: arabic
                                                        ? 'Reem Kufi'
                                                        : 'Poppins',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: width < 350
                                                        ? 23
                                                        : 27,
                                                    height: 1.35,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                      maxWidth: 330,
                                                    ),
                                                child: Text(
                                                  arabic
                                                      ? data.descriptionAr
                                                      : data.descriptionEn,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: JourneyColors.muted,
                                                    fontFamily: arabic
                                                        ? 'Cairo'
                                                        : 'Poppins',
                                                    fontSize: arabic
                                                        ? 15.5
                                                        : 14,
                                                    height: 1.58,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      _JourneyNavigation(
                        current: page,
                        total: pages.length,
                        saving: _saving,
                        canGoBack: page > 0,
                        onBack: () => _goTo(page - 1),
                        onNext: () =>
                            cubit.isLastPage ? _finish() : _goTo(page + 1),
                        onSelect: _goTo,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JourneyNavigation extends StatelessWidget {
  const _JourneyNavigation({
    required this.current,
    required this.total,
    required this.saving,
    required this.canGoBack,
    required this.onBack,
    required this.onNext,
    required this.onSelect,
  });

  final int current;
  final int total;
  final bool saving;
  final bool canGoBack;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final last = current == total - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (last)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(44, 54),
                  backgroundColor: JourneyColors.gold,
                  foregroundColor: JourneyColors.buttonInk,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                onPressed: saving ? null : onNext,
                child: Row(
                  children: [
                    const SizedBox(width: 22),
                    Expanded(
                      child: Text(
                        appText(context, 'ابدأ الآن', 'Get started'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, size: 22),
                  ],
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 54),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (canGoBack)
                    IconButton(
                      onPressed: saving ? null : onBack,
                      color: JourneyColors.muted,
                      tooltip: appText(context, 'السابق', 'Back'),
                      icon: const Icon(Icons.arrow_back_rounded),
                    )
                  else
                    const SizedBox(width: 48),
                  TextButton.icon(
                    onPressed: saving ? null : onNext,
                    style: TextButton.styleFrom(
                      foregroundColor: JourneyColors.gold,
                      minimumSize: const Size(48, 48),
                    ),
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 19),
                    label: Text(appText(context, 'التالي', 'Next')),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < total; index++)
                Semantics(
                  label: appText(
                    context,
                    'الصفحة ${index + 1} من $total',
                    'Page ${index + 1} of $total',
                  ),
                  selected: current == index,
                  child: IconButton(
                    onPressed: saving ? null : () => onSelect(index),
                    constraints: const BoxConstraints.tightFor(
                      width: 44,
                      height: 44,
                    ),
                    padding: EdgeInsets.zero,
                    icon: DecoratedBox(
                      decoration: BoxDecoration(
                        color: current == index
                            ? JourneyColors.gold
                            : JourneyColors.dot,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox.square(
                        dimension: current == index ? 9 : 6,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
