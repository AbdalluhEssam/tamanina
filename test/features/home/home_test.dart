import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../lib/features/home/data/repositories/home_repository_impl.dart';
import '../../../lib/features/home/domain/entities/home_feature.dart';
import '../../../lib/features/home/domain/usecases/home_usecases.dart';
import '../../../lib/features/home/presentation/cubit/home_cubit.dart';
import '../../../lib/features/home/presentation/cubit/home_state.dart';
import '../../../lib/features/home/presentation/view/home_screen.dart';

void main() {
  group('Home Screen Tests', () {
    late HomeCubit homeCubit;
    late HomeRepositoryImpl repository;

    setUp(() {
      repository = HomeRepositoryImpl();
      homeCubit = HomeCubit(
        getHomeFeaturesUseCase: GetHomeFeaturesUseCase(repository),
        getGreetingUseCase: GetGreetingUseCase(repository),
        getUserStatsUseCase: GetUserStatsUseCase(repository),
      );
    });

    tearDown(() {
      homeCubit.close();
    });

    testWidgets('Home screen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) {
            return MaterialApp(
              home: BlocProvider<HomeCubit>(
                create: (context) => homeCubit,
                child: const HomeScreen(),
              ),
            );
          },
        ),
      );

      // Wait for the initial build
      await tester.pump();

      // Trigger data loading
      homeCubit.loadHomeData();
      await tester.pump(const Duration(milliseconds: 500));

      // Check if home screen elements are present
      expect(find.byType(HomeScreen), findsOneWidget);

      // Check for Arabic greeting
      expect(find.text('السلام عليكم'), findsOneWidget);

      // Check for app name
      expect(find.text('طمأنينة'), findsOneWidget);
      expect(find.text('Tamanina'), findsOneWidget);
    });

    test('HomeCubit loads data correctly', () async {
      // Test initial state
      expect(homeCubit.state, isA<HomeInitial>());

      // Load data
      await homeCubit.loadHomeData();

      // Check loaded state
      expect(homeCubit.state, isA<HomeLoaded>());

      final loadedState = homeCubit.state as HomeLoaded;
      expect(loadedState.features, isNotEmpty);
      expect(loadedState.features.length, equals(6));
      expect(loadedState.greeting, isNotEmpty);
      expect(loadedState.stats, isNotEmpty);
    });

    test('Repository returns correct home features', () {
      final features = repository.getHomeFeatures();

      expect(features.length, equals(6));

      // Check first feature (Sebha)
      expect(features[0].id, equals('sebha'));
      expect(features[0].titleArabic, equals('عداد التسبيح'));
      expect(features[0].titleEnglish, equals('Sebha Counter'));
      expect(features[0].route, equals('/sebha'));

      // Check second feature (Azkar)
      expect(features[1].id, equals('azkar'));
      expect(features[1].titleArabic, equals('أذكار الصباح والمساء'));
      expect(features[1].titleEnglish, equals('Morning & Evening Azkar'));
      expect(features[1].route, equals('/azkar'));
    });

    test('Repository returns correct greeting based on time', () {
      final greeting = repository.getGreetingMessage();

      expect(greeting, isNotEmpty);

      // Check that greeting is one of the expected values
      const expectedGreetings = [
        'صباح الخير',
        'نهار مبارك',
        'مساء الخير',
        'ليلة مباركة'
      ];

      expect(expectedGreetings.contains(greeting), isTrue);
    });

    test('Repository returns user stats', () {
      final stats = repository.getUserStats();

      expect(stats, isNotEmpty);
      expect(stats.containsKey('todayAzkar'), isTrue);
      expect(stats.containsKey('todaySebha'), isTrue);
      expect(stats.containsKey('todayQuran'), isTrue);
      expect(stats.containsKey('streak'), isTrue);

      // Check that all values are numbers
      expect(stats['todayAzkar'], isA<int>());
      expect(stats['todaySebha'], isA<int>());
      expect(stats['todayQuran'], isA<int>());
      expect(stats['streak'], isA<int>());
    });

    testWidgets('Feature cards are tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) {
            return MaterialApp(
              home: BlocProvider<HomeCubit>(
                create: (context) => homeCubit,
                child: const HomeScreen(),
              ),
            );
          },
        ),
      );

      // Load data first
      homeCubit.loadHomeData();
      await tester.pump(const Duration(milliseconds: 500));

      // Find first feature card and tap it
      final featureCard = find.byType(GestureDetector).first;
      await tester.tap(featureCard);
      await tester.pump();

      // Check if snackbar appears
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('Home Feature Entity Tests', () {
    test('HomeFeature entity works correctly', () {
      const feature = HomeFeature(
        id: 'test',
        titleArabic: 'عنوان تجريبي',
        titleEnglish: 'Test Title',
        iconPath: 'assets/icons/test.svg',
        route: '/test',
        color: 'green',
        description: 'Test description',
        isActive: true,
      );

      expect(feature.id, equals('test'));
      expect(feature.titleArabic, equals('عنوان تجريبي'));
      expect(feature.titleEnglish, equals('Test Title'));
      expect(feature.isActive, isTrue);

      // Test copyWith
      final updatedFeature = feature.copyWith(isActive: false);
      expect(updatedFeature.isActive, isFalse);
      expect(updatedFeature.id, equals('test')); // Other fields remain same
    });
  });
}
