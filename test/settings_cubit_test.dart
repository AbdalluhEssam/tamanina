import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tamanina/core/settings/settings_repository.dart';
import 'package:tamanina/core/settings/settings_cubit.dart';

/// Mock SettingsRepository
class MockSettingsRepository extends Mock implements SettingsRepository {}

/// Fake PerPrayerSettings for matchers
class FakePerPrayerSettings extends Fake implements PerPrayerSettings {}

void main() {
  late MockSettingsRepository mockRepository;

  setUpAll(() {
    // Initialize Flutter binding for testing
    TestWidgetsFlutterBinding.ensureInitialized();
    // Register fallback values
    registerFallbackValue(FakePerPrayerSettings());
  });

  setUp(() {
    mockRepository = MockSettingsRepository();

    // Setup default mocks
    when(() => mockRepository.currentSettings).thenReturn(const AppSettings());
    when(() => mockRepository.settingsStream)
        .thenAnswer((_) => Stream.value(const AppSettings()));
  });

  group('SettingsCubit', () {
    blocTest<SettingsCubit, SettingsState>(
      'emits [SettingsLoading, SettingsLoaded] on initialization',
      build: () {
        when(() => mockRepository.currentSettings)
            .thenReturn(const AppSettings());
        return SettingsCubit(repository: mockRepository);
      },
      expect: () => [
        isA<SettingsLoading>(),
        isA<SettingsLoaded>(),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'calls repository.updateThemeMode when updateThemeMode is called',
      build: () {
        final settings = const AppSettings(themeMode: ThemeMode.light);
        when(() => mockRepository.currentSettings).thenReturn(settings);
        when(() => mockRepository.updateThemeMode(ThemeMode.dark))
            .thenAnswer((_) async {});
        when(() => mockRepository.settingsStream).thenAnswer(
            (_) => Stream.value(const AppSettings(themeMode: ThemeMode.dark)));
        return SettingsCubit(repository: mockRepository);
      },
      seed: () => const SettingsLoaded(AppSettings(themeMode: ThemeMode.light)),
      act: (cubit) => cubit.updateThemeMode(ThemeMode.dark),
      verify: (_) {
        verify(() => mockRepository.updateThemeMode(ThemeMode.dark)).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'calls repository.updateCalculationMethod when updateCalculationMethod is called',
      build: () {
        final settings = const AppSettings(
          calculationMethod: PrayerCalculationMethod.muslimWorldLeague,
        );
        when(() => mockRepository.currentSettings).thenReturn(settings);
        when(() => mockRepository.updateCalculationMethod(
            PrayerCalculationMethod.ummAlQura)).thenAnswer((_) async {});
        return SettingsCubit(repository: mockRepository);
      },
      seed: () => const SettingsLoaded(AppSettings(
        calculationMethod: PrayerCalculationMethod.muslimWorldLeague,
      )),
      act: (cubit) =>
          cubit.updateCalculationMethod(PrayerCalculationMethod.ummAlQura),
      verify: (_) {
        verify(() => mockRepository.updateCalculationMethod(
            PrayerCalculationMethod.ummAlQura)).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'calls repository.updateMadhab when updateMadhab is called',
      build: () {
        final settings = const AppSettings(madhab: Madhab.shafi);
        when(() => mockRepository.currentSettings).thenReturn(settings);
        when(() => mockRepository.updateMadhab(Madhab.hanafi))
            .thenAnswer((_) async {});
        return SettingsCubit(repository: mockRepository);
      },
      seed: () => const SettingsLoaded(AppSettings(madhab: Madhab.shafi)),
      act: (cubit) => cubit.updateMadhab(Madhab.hanafi),
      verify: (_) {
        verify(() => mockRepository.updateMadhab(Madhab.hanafi)).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'calls repository.updateNotificationsEnabled when updateNotificationsEnabled is called',
      build: () {
        final settings = const AppSettings(notificationsEnabled: false);
        when(() => mockRepository.currentSettings).thenReturn(settings);
        when(() => mockRepository.updateNotificationsEnabled(true))
            .thenAnswer((_) async {});
        return SettingsCubit(repository: mockRepository);
      },
      seed: () =>
          const SettingsLoaded(AppSettings(notificationsEnabled: false)),
      act: (cubit) => cubit.updateNotificationsEnabled(true),
      verify: (_) {
        verify(() => mockRepository.updateNotificationsEnabled(true)).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'calls repository.updateMuadhinMode when updateMuadhinMode is called',
      build: () {
        final settings = const AppSettings(muadhinMode: false);
        when(() => mockRepository.currentSettings).thenReturn(settings);
        when(() => mockRepository.updateMuadhinMode(true))
            .thenAnswer((_) async {});
        return SettingsCubit(repository: mockRepository);
      },
      seed: () => const SettingsLoaded(AppSettings(muadhinMode: false)),
      act: (cubit) => cubit.updateMuadhinMode(true),
      verify: (_) {
        verify(() => mockRepository.updateMuadhinMode(true)).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'calls repository.updateSelectedAdhan when updateSelectedAdhan is called',
      build: () {
        final settings = const AppSettings(selectedAdhan: AdhanSound.makkah);
        when(() => mockRepository.currentSettings).thenReturn(settings);
        when(() => mockRepository.updateSelectedAdhan(AdhanSound.madinah))
            .thenAnswer((_) async {});
        return SettingsCubit(repository: mockRepository);
      },
      seed: () =>
          const SettingsLoaded(AppSettings(selectedAdhan: AdhanSound.makkah)),
      act: (cubit) => cubit.updateSelectedAdhan(AdhanSound.madinah),
      verify: (_) {
        verify(() => mockRepository.updateSelectedAdhan(AdhanSound.madinah))
            .called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'calls repository.updatePrePrayerOffset when updatePrePrayerOffset is called',
      build: () {
        final settings = const AppSettings(prePrayerOffsetMinutes: 0);
        when(() => mockRepository.currentSettings).thenReturn(settings);
        when(() => mockRepository.updatePrePrayerOffset(15))
            .thenAnswer((_) async {});
        return SettingsCubit(repository: mockRepository);
      },
      seed: () => const SettingsLoaded(AppSettings(prePrayerOffsetMinutes: 0)),
      act: (cubit) => cubit.updatePrePrayerOffset(15),
      verify: (_) {
        verify(() => mockRepository.updatePrePrayerOffset(15)).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'calls repository.updateAdhanVolume when updateAdhanVolume is called',
      build: () {
        final settings = const AppSettings(adhanVolume: 1.0);
        when(() => mockRepository.currentSettings).thenReturn(settings);
        when(() => mockRepository.updateAdhanVolume(0.5))
            .thenAnswer((_) async {});
        return SettingsCubit(repository: mockRepository);
      },
      seed: () => const SettingsLoaded(AppSettings(adhanVolume: 1.0)),
      act: (cubit) => cubit.updateAdhanVolume(0.5),
      verify: (_) {
        verify(() => mockRepository.updateAdhanVolume(0.5)).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'calls repository.updatePerPrayerSettings when updatePrayerNotification is called',
      build: () {
        final settings = const AppSettings(
          perPrayerEnabled: PerPrayerSettings(
            fajr: true,
            sunrise: true,
            dhuhr: true,
            asr: true,
            maghrib: true,
            isha: true,
          ),
        );
        when(() => mockRepository.currentSettings).thenReturn(settings);
        when(() => mockRepository.updatePerPrayerSettings(any()))
            .thenAnswer((_) async {});
        return SettingsCubit(repository: mockRepository);
      },
      seed: () => const SettingsLoaded(AppSettings(
        perPrayerEnabled: PerPrayerSettings(
          fajr: true,
          sunrise: true,
          dhuhr: true,
          asr: true,
          maghrib: true,
          isha: true,
        ),
      )),
      act: (cubit) => cubit.updatePrayerNotification('fajr', false),
      verify: (_) {
        verify(() => mockRepository.updatePerPrayerSettings(any())).called(1);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'calls repository.resetToDefaults when resetToDefaults is called',
      build: () {
        when(() => mockRepository.currentSettings)
            .thenReturn(const AppSettings());
        when(() => mockRepository.resetToDefaults()).thenAnswer((_) async {});
        return SettingsCubit(repository: mockRepository);
      },
      seed: () => const SettingsLoaded(AppSettings(
        themeMode: ThemeMode.dark,
        notificationsEnabled: false,
        muadhinMode: true,
      )),
      act: (cubit) => cubit.resetToDefaults(),
      verify: (_) {
        verify(() => mockRepository.resetToDefaults()).called(1);
      },
    );
  });

  group('AppSettings', () {
    test('default values are correct', () {
      const settings = AppSettings();

      expect(settings.themeMode, ThemeMode.system);
      expect(settings.calculationMethod, PrayerCalculationMethod.ummAlQura);
      expect(settings.madhab, Madhab.shafi);
      expect(settings.notificationsEnabled, true);
      expect(settings.muadhinMode, false);
      expect(settings.selectedAdhan, AdhanSound.makkah);
      expect(settings.prePrayerOffsetMinutes, 0);
      expect(settings.adhanVolume, 1.0);
      expect(settings.vibrationEnabled, true);
    });

    test('copyWith creates correct copy', () {
      const original = AppSettings();
      final copy = original.copyWith(
        themeMode: ThemeMode.dark,
        notificationsEnabled: false,
        muadhinMode: true,
      );

      expect(copy.themeMode, ThemeMode.dark);
      expect(copy.notificationsEnabled, false);
      expect(copy.muadhinMode, true);
      // Unchanged values
      expect(copy.calculationMethod, original.calculationMethod);
      expect(copy.madhab, original.madhab);
    });

    test('equality works correctly', () {
      const settings1 = AppSettings();
      const settings2 = AppSettings();
      const settings3 = AppSettings(themeMode: ThemeMode.dark);

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
    });
  });

  group('PrayerCalculationMethod', () {
    test('has correct Arabic names', () {
      expect(PrayerCalculationMethod.ummAlQura.arabicName, 'أم القرى - مكة');
      expect(PrayerCalculationMethod.muslimWorldLeague.arabicName,
          'رابطة العالم الإسلامي');
      expect(PrayerCalculationMethod.egyptian.arabicName, 'الهيئة المصرية');
    });
  });

  group('Madhab', () {
    test('has correct Arabic names', () {
      expect(Madhab.shafi.arabicName, 'الشافعي/المالكي/الحنبلي');
      expect(Madhab.hanafi.arabicName, 'الحنفي');
    });
  });

  group('AdhanSound', () {
    test('has correct display names and asset paths', () {
      expect(AdhanSound.makkah.displayName, 'مكة المكرمة');
      expect(
          AdhanSound.makkah.assetPath, 'assets/audio/adhan/adhan_makkah.mp3');
      expect(AdhanSound.system.assetPath, 'system');
    });
  });

  group('PerPrayerSettings', () {
    test('default values are all true', () {
      const settings = PerPrayerSettings();

      expect(settings.fajr, true);
      expect(settings.sunrise, true);
      expect(settings.dhuhr, true);
      expect(settings.asr, true);
      expect(settings.maghrib, true);
      expect(settings.isha, true);
    });

    test('copyWith creates correct copy', () {
      const original = PerPrayerSettings();
      final copy = original.copyWith(fajr: false, isha: false);

      expect(copy.fajr, false);
      expect(copy.isha, false);
      // Unchanged values
      expect(copy.dhuhr, true);
      expect(copy.asr, true);
    });
  });
}
