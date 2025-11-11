import 'package:equatable/equatable.dart';

/// Feature entity representing each main feature on the home screen
class HomeFeature extends Equatable {
  final String id;
  final String titleArabic;
  final String titleEnglish;
  final String iconPath;
  final String route;
  final String color;
  final String description;
  final bool isActive;

  const HomeFeature({
    required this.id,
    required this.titleArabic,
    required this.titleEnglish,
    required this.iconPath,
    required this.route,
    required this.color,
    required this.description,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        titleArabic,
        titleEnglish,
        iconPath,
        route,
        color,
        description,
        isActive,
      ];

  HomeFeature copyWith({
    String? id,
    String? titleArabic,
    String? titleEnglish,
    String? iconPath,
    String? route,
    String? color,
    String? description,
    bool? isActive,
  }) {
    return HomeFeature(
      id: id ?? this.id,
      titleArabic: titleArabic ?? this.titleArabic,
      titleEnglish: titleEnglish ?? this.titleEnglish,
      iconPath: iconPath ?? this.iconPath,
      route: route ?? this.route,
      color: color ?? this.color,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
