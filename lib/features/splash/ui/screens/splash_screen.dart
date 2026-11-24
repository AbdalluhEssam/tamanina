import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _openingRoute = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SplashCubit>().startSplash();
    });
  }

  void _openDestination(SplashState state) {
    if (_openingRoute) return;
    final route = switch (state) {
      SplashNavigateToHome() => AppRoutes.home,
      SplashNavigateToOnboarding() => AppRoutes.onboarding,
      _ => null,
    };
    if (route == null) return;
    _openingRoute = true;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final markSize = (size.shortestSide * 0.56).clamp(116.0, 176.0);
    return BlocConsumer<SplashCubit, SplashState>(
      listener: (_, state) => _openDestination(state),
      builder: (context, state) => Scaffold(
        backgroundColor: AppTheme.night,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                BrandMark(size: markSize),
                Transform.translate(
                  offset: Offset(0, markSize * .47),
                  child: Text(
                    appText(
                      context,
                      AppConstants.appName,
                      AppConstants.appNameEnglish,
                    ),
                    style: const TextStyle(
                      color: AppTheme.gold,
                      fontFamily: 'Reem Kufi',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (state is SplashError)
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: FilledButton(
                      onPressed: context.read<SplashCubit>().startSplash,
                      child: Text(
                        appText(context, 'إعادة المحاولة', 'Try again'),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
