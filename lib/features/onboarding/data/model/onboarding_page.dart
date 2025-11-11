import 'package:equatable/equatable.dart';

/// نموذج صفحة التعريف
/// Onboarding page model
class OnboardingPageModel extends Equatable {
  final String titleAr;
  final String titleEn;
  final String descriptionAr;
  final String descriptionEn;
  final String imagePath;
  final String lottieAnimation;
  final String iconEmoji;

  const OnboardingPageModel({
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.imagePath,
    required this.lottieAnimation,
    required this.iconEmoji,
  });

  @override
  List<Object?> get props => [
        titleAr,
        titleEn,
        descriptionAr,
        descriptionEn,
        imagePath,
        lottieAnimation,
        iconEmoji,
      ];
}
