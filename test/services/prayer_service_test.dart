import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tamanina/core/services/prayer_service.dart';

void main() {
  group('PrayerService', () {
    late PrayerService prayerService;

    setUp(() async {
      // Setup SharedPreferences mock
      SharedPreferences.setMockInitialValues({});
      prayerService = PrayerService();
      await prayerService.initialize();
    });

    group('Calculation Methods', () {
      test('should return default calculation method as Umm al-Qura', () {
        expect(
          prayerService.calculationMethod,
          PrayerCalculationMethod.ummAlQura,
        );
      });

      test('should set and get calculation method correctly', () async {
        await prayerService.setCalculationMethod(PrayerCalculationMethod.isna);
        expect(
          prayerService.calculationMethod,
          PrayerCalculationMethod.isna,
        );
      });

      test('should support all calculation methods', () {
        final allMethods = PrayerCalculationMethod.values;
        expect(allMethods.length, greaterThan(5));

        // Verify common methods exist
        expect(allMethods, contains(PrayerCalculationMethod.muslimWorldLeague));
        expect(allMethods, contains(PrayerCalculationMethod.isna));
        expect(allMethods, contains(PrayerCalculationMethod.egyptian));
        expect(allMethods, contains(PrayerCalculationMethod.ummAlQura));
        expect(allMethods, contains(PrayerCalculationMethod.karachi));
      });

      test('should get calculation method display name', () {
        final name = prayerService.getCalculationMethodName(
          PrayerCalculationMethod.ummAlQura,
        );
        expect(name, isNotEmpty);
        expect(name, contains('أم القرى'));
      });
    });

    group('Madhab Settings', () {
      test('should return default madhab as Shafi', () {
        expect(prayerService.madhab, AsrMadhab.shafi);
      });

      test('should set and get madhab correctly', () async {
        await prayerService.setMadhab(AsrMadhab.hanafi);
        expect(prayerService.madhab, AsrMadhab.hanafi);
      });
    });

    group('Location Settings', () {
      test('should return useManualLocation as false by default', () {
        expect(prayerService.useManualLocation, false);
      });

      test('should set manual location preference', () async {
        await prayerService.setUseManualLocation(true);
        expect(prayerService.useManualLocation, true);
      });

      test('should set manual location', () async {
        await prayerService.setManualLocation(
          city: 'Makkah',
          country: 'Saudi Arabia',
          latitude: 21.4225,
          longitude: 39.8262,
        );

        // After setting manual location, useManualLocation should be true
        expect(prayerService.useManualLocation, true);
      });
    });

    group('Time Formatting', () {
      test('should format duration with hours correctly', () {
        final duration = Duration(hours: 2, minutes: 30);
        final formatted = prayerService.formatDuration(duration);
        expect(formatted, contains('2'));
        expect(formatted, contains('30'));
        expect(formatted, contains('ساعة'));
      });

      test('should format duration with minutes only', () {
        final duration = Duration(minutes: 15, seconds: 30);
        final formatted = prayerService.formatDuration(duration);
        expect(formatted, contains('15'));
        expect(formatted, contains('دقيقة'));
      });

      test('should format duration with seconds only', () {
        final duration = Duration(seconds: 45);
        final formatted = prayerService.formatDuration(duration);
        expect(formatted, contains('45'));
        expect(formatted, contains('ثانية'));
      });
    });

    group('PrayerTimeData Model', () {
      test('should create PrayerTimeData correctly', () {
        final data = PrayerTimeData(
          name: 'fajr',
          nameArabic: 'الفجر',
          time: DateTime(2024, 3, 15, 5, 30),
          isNext: true,
          timeUntil: Duration(hours: 1),
        );

        expect(data.name, 'fajr');
        expect(data.nameArabic, 'الفجر');
        expect(data.isNext, true);
        expect(data.timeUntil!.inHours, 1);
      });

      test('should format time in 24-hour format', () {
        final data = PrayerTimeData(
          name: 'fajr',
          nameArabic: 'الفجر',
          time: DateTime(2024, 3, 15, 5, 30),
        );

        expect(data.formattedTime24, '05:30');
      });

      test('should support copyWith', () {
        final original = PrayerTimeData(
          name: 'fajr',
          nameArabic: 'الفجر',
          time: DateTime(2024, 3, 15, 5, 30),
          isNext: false,
        );

        final copied = original.copyWith(isNext: true);
        expect(copied.isNext, true);
        expect(copied.name, 'fajr');
      });
    });

    group('DailyPrayerTimes Model', () {
      test('should create DailyPrayerTimes correctly', () {
        final fajr = PrayerTimeData(
          name: 'fajr',
          nameArabic: 'الفجر',
          time: DateTime(2024, 3, 15, 5, 0),
          isNext: true,
        );
        final sunrise = PrayerTimeData(
          name: 'sunrise',
          nameArabic: 'الشروق',
          time: DateTime(2024, 3, 15, 6, 15),
        );
        final dhuhr = PrayerTimeData(
          name: 'dhuhr',
          nameArabic: 'الظهر',
          time: DateTime(2024, 3, 15, 12, 15),
        );
        final asr = PrayerTimeData(
          name: 'asr',
          nameArabic: 'العصر',
          time: DateTime(2024, 3, 15, 15, 30),
        );
        final maghrib = PrayerTimeData(
          name: 'maghrib',
          nameArabic: 'المغرب',
          time: DateTime(2024, 3, 15, 18, 15),
        );
        final isha = PrayerTimeData(
          name: 'isha',
          nameArabic: 'العشاء',
          time: DateTime(2024, 3, 15, 19, 45),
        );

        final daily = DailyPrayerTimes(
          fajr: fajr,
          sunrise: sunrise,
          dhuhr: dhuhr,
          asr: asr,
          maghrib: maghrib,
          isha: isha,
          date: DateTime(2024, 3, 15),
          hijriDate: '5 رمضان 1445',
          gregorianDate: '15 مارس 2024',
          cityName: 'مكة المكرمة',
          countryName: 'المملكة العربية السعودية',
          latitude: 21.4225,
          longitude: 39.8262,
        );

        expect(daily.hijriDate, '5 رمضان 1445');
        expect(daily.cityName, 'مكة المكرمة');
        expect(daily.allPrayers.length, 6);
        expect(daily.obligatoryPrayers.length, 5);
        expect(daily.nextPrayer, isNotNull);
        expect(daily.nextPrayer!.name, 'fajr');
      });

      test('should return all prayers list', () {
        final fajr = PrayerTimeData(
            name: 'fajr',
            nameArabic: 'الفجر',
            time: DateTime(2024, 3, 15, 5, 0));
        final sunrise = PrayerTimeData(
            name: 'sunrise',
            nameArabic: 'الشروق',
            time: DateTime(2024, 3, 15, 6, 15));
        final dhuhr = PrayerTimeData(
            name: 'dhuhr',
            nameArabic: 'الظهر',
            time: DateTime(2024, 3, 15, 12, 15));
        final asr = PrayerTimeData(
            name: 'asr',
            nameArabic: 'العصر',
            time: DateTime(2024, 3, 15, 15, 30));
        final maghrib = PrayerTimeData(
            name: 'maghrib',
            nameArabic: 'المغرب',
            time: DateTime(2024, 3, 15, 18, 15));
        final isha = PrayerTimeData(
            name: 'isha',
            nameArabic: 'العشاء',
            time: DateTime(2024, 3, 15, 19, 45));

        final daily = DailyPrayerTimes(
          fajr: fajr,
          sunrise: sunrise,
          dhuhr: dhuhr,
          asr: asr,
          maghrib: maghrib,
          isha: isha,
          date: DateTime(2024, 3, 15),
          hijriDate: '5 رمضان 1445',
          gregorianDate: '15 مارس 2024',
          cityName: 'مكة المكرمة',
          countryName: 'المملكة العربية السعودية',
          latitude: 21.4225,
          longitude: 39.8262,
        );

        final prayerNames = daily.allPrayers.map((p) => p.name).toList();
        expect(prayerNames, contains('fajr'));
        expect(prayerNames, contains('sunrise'));
        expect(prayerNames, contains('dhuhr'));
        expect(prayerNames, contains('asr'));
        expect(prayerNames, contains('maghrib'));
        expect(prayerNames, contains('isha'));
      });

      test('should return only obligatory prayers', () {
        final fajr = PrayerTimeData(
            name: 'fajr',
            nameArabic: 'الفجر',
            time: DateTime(2024, 3, 15, 5, 0));
        final sunrise = PrayerTimeData(
            name: 'sunrise',
            nameArabic: 'الشروق',
            time: DateTime(2024, 3, 15, 6, 15));
        final dhuhr = PrayerTimeData(
            name: 'dhuhr',
            nameArabic: 'الظهر',
            time: DateTime(2024, 3, 15, 12, 15));
        final asr = PrayerTimeData(
            name: 'asr',
            nameArabic: 'العصر',
            time: DateTime(2024, 3, 15, 15, 30));
        final maghrib = PrayerTimeData(
            name: 'maghrib',
            nameArabic: 'المغرب',
            time: DateTime(2024, 3, 15, 18, 15));
        final isha = PrayerTimeData(
            name: 'isha',
            nameArabic: 'العشاء',
            time: DateTime(2024, 3, 15, 19, 45));

        final daily = DailyPrayerTimes(
          fajr: fajr,
          sunrise: sunrise,
          dhuhr: dhuhr,
          asr: asr,
          maghrib: maghrib,
          isha: isha,
          date: DateTime(2024, 3, 15),
          hijriDate: '5 رمضان 1445',
          gregorianDate: '15 مارس 2024',
          cityName: 'مكة المكرمة',
          countryName: 'المملكة العربية السعودية',
          latitude: 21.4225,
          longitude: 39.8262,
        );

        final obligatoryNames =
            daily.obligatoryPrayers.map((p) => p.name).toList();
        expect(obligatoryNames, isNot(contains('sunrise')));
        expect(obligatoryNames.length, 5);
      });

      test('should have latitude and longitude', () {
        final fajr = PrayerTimeData(
            name: 'fajr',
            nameArabic: 'الفجر',
            time: DateTime(2024, 3, 15, 5, 0));
        final sunrise = PrayerTimeData(
            name: 'sunrise',
            nameArabic: 'الشروق',
            time: DateTime(2024, 3, 15, 6, 15));
        final dhuhr = PrayerTimeData(
            name: 'dhuhr',
            nameArabic: 'الظهر',
            time: DateTime(2024, 3, 15, 12, 15));
        final asr = PrayerTimeData(
            name: 'asr',
            nameArabic: 'العصر',
            time: DateTime(2024, 3, 15, 15, 30));
        final maghrib = PrayerTimeData(
            name: 'maghrib',
            nameArabic: 'المغرب',
            time: DateTime(2024, 3, 15, 18, 15));
        final isha = PrayerTimeData(
            name: 'isha',
            nameArabic: 'العشاء',
            time: DateTime(2024, 3, 15, 19, 45));

        final daily = DailyPrayerTimes(
          fajr: fajr,
          sunrise: sunrise,
          dhuhr: dhuhr,
          asr: asr,
          maghrib: maghrib,
          isha: isha,
          date: DateTime(2024, 3, 15),
          hijriDate: '5 رمضان 1445',
          gregorianDate: '15 مارس 2024',
          cityName: 'مكة المكرمة',
          countryName: 'المملكة العربية السعودية',
          latitude: 21.4225,
          longitude: 39.8262,
        );

        expect(daily.latitude, 21.4225);
        expect(daily.longitude, 39.8262);
      });
    });
  });
}
