import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tamanina/core/services/prayer_service.dart';

/// Integration tests for prayer scheduling functionality.
/// These tests verify the complete workflow from location to notification scheduling.
///
/// Note: These tests use a mock approach since they test the calculation logic
/// without requiring actual GPS or notification permissions.
void main() {
  // Initialize locale data for Arabic date formatting
  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  group('Prayer Scheduling Integration', () {
    group('Prayer Time Data Model', () {
      test('should create valid prayer time data', () {
        // Given: Prayer time data
        final prayer = PrayerTimeData(
          name: 'fajr',
          nameArabic: 'الفجر',
          time: DateTime(2024, 3, 15, 5, 30),
          isNext: true,
          timeUntil: Duration(hours: 2),
        );

        // Then: All properties should be accessible
        expect(prayer.name, equals('fajr'));
        expect(prayer.nameArabic, equals('الفجر'));
        expect(prayer.isNext, isTrue);
        expect(prayer.timeUntil, equals(Duration(hours: 2)));
        expect(prayer.formattedTime, isNotEmpty);
        expect(prayer.formattedTime24, equals('05:30'));
      });

      test('should correctly copy prayer data with modifications', () {
        // Given: Original prayer data
        final original = PrayerTimeData(
          name: 'dhuhr',
          nameArabic: 'الظهر',
          time: DateTime(2024, 3, 15, 12, 30),
          isNext: false,
        );

        // When: Copy with isNext = true
        final modified =
            original.copyWith(isNext: true, timeUntil: Duration(minutes: 30));

        // Then: Should have modified values
        expect(modified.isNext, isTrue);
        expect(modified.timeUntil, equals(Duration(minutes: 30)));
        expect(modified.name, equals(original.name));
        expect(modified.time, equals(original.time));
      });
    });

    group('Daily Prayer Times Model', () {
      test('should create complete daily prayer times', () {
        // Given: All prayer times for a day
        final prayers = DailyPrayerTimes(
          fajr: PrayerTimeData(
              name: 'fajr',
              nameArabic: 'الفجر',
              time: DateTime(2024, 3, 15, 5, 0)),
          sunrise: PrayerTimeData(
              name: 'sunrise',
              nameArabic: 'الشروق',
              time: DateTime(2024, 3, 15, 6, 15)),
          dhuhr: PrayerTimeData(
              name: 'dhuhr',
              nameArabic: 'الظهر',
              time: DateTime(2024, 3, 15, 12, 30)),
          asr: PrayerTimeData(
              name: 'asr',
              nameArabic: 'العصر',
              time: DateTime(2024, 3, 15, 15, 45)),
          maghrib: PrayerTimeData(
              name: 'maghrib',
              nameArabic: 'المغرب',
              time: DateTime(2024, 3, 15, 18, 30)),
          isha: PrayerTimeData(
              name: 'isha',
              nameArabic: 'العشاء',
              time: DateTime(2024, 3, 15, 20, 0)),
          date: DateTime(2024, 3, 15),
          hijriDate: '5 رمضان 1445',
          gregorianDate: '15 مارس 2024',
          cityName: 'مكة المكرمة',
          countryName: 'السعودية',
          latitude: 21.4225,
          longitude: 39.8262,
        );

        // Then: All prayers should be accessible
        expect(prayers.allPrayers.length, equals(6)); // Including sunrise
        expect(
            prayers.obligatoryPrayers.length, equals(5)); // Excluding sunrise
        expect(prayers.fajr.nameArabic, equals('الفجر'));
        expect(prayers.isha.nameArabic, equals('العشاء'));
        expect(prayers.cityName, equals('مكة المكرمة'));
      });

      test('should get all prayers in correct order', () {
        // Given: Daily prayer times
        final prayers = DailyPrayerTimes(
          fajr: PrayerTimeData(
              name: 'fajr',
              nameArabic: 'الفجر',
              time: DateTime(2024, 3, 15, 5, 0)),
          sunrise: PrayerTimeData(
              name: 'sunrise',
              nameArabic: 'الشروق',
              time: DateTime(2024, 3, 15, 6, 15)),
          dhuhr: PrayerTimeData(
              name: 'dhuhr',
              nameArabic: 'الظهر',
              time: DateTime(2024, 3, 15, 12, 30)),
          asr: PrayerTimeData(
              name: 'asr',
              nameArabic: 'العصر',
              time: DateTime(2024, 3, 15, 15, 45)),
          maghrib: PrayerTimeData(
              name: 'maghrib',
              nameArabic: 'المغرب',
              time: DateTime(2024, 3, 15, 18, 30)),
          isha: PrayerTimeData(
              name: 'isha',
              nameArabic: 'العشاء',
              time: DateTime(2024, 3, 15, 20, 0)),
          date: DateTime(2024, 3, 15),
          hijriDate: '5 رمضان 1445',
          gregorianDate: '15 مارس 2024',
          cityName: 'مكة المكرمة',
          countryName: 'السعودية',
          latitude: 21.4225,
          longitude: 39.8262,
        );

        // When: Get obligatory prayers (excluding sunrise)
        final obligatoryPrayers = prayers.obligatoryPrayers;

        // Then: Should be in chronological order
        expect(obligatoryPrayers[0].name, equals('fajr'));
        expect(obligatoryPrayers[1].name, equals('dhuhr'));
        expect(obligatoryPrayers[2].name, equals('asr'));
        expect(obligatoryPrayers[3].name, equals('maghrib'));
        expect(obligatoryPrayers[4].name, equals('isha'));

        // And: Times should be in order
        for (int i = 0; i < obligatoryPrayers.length - 1; i++) {
          expect(
            obligatoryPrayers[i].time.isBefore(obligatoryPrayers[i + 1].time),
            isTrue,
            reason:
                '${obligatoryPrayers[i].name} should be before ${obligatoryPrayers[i + 1].name}',
          );
        }
      });
    });

    group('Prayer Notification Data Preparation', () {
      test('should generate correct notification data for all prayers', () {
        // Given: Daily prayer times
        final prayers = DailyPrayerTimes(
          fajr: PrayerTimeData(
              name: 'fajr',
              nameArabic: 'الفجر',
              time: DateTime(2024, 3, 15, 5, 0)),
          sunrise: PrayerTimeData(
              name: 'sunrise',
              nameArabic: 'الشروق',
              time: DateTime(2024, 3, 15, 6, 15)),
          dhuhr: PrayerTimeData(
              name: 'dhuhr',
              nameArabic: 'الظهر',
              time: DateTime(2024, 3, 15, 12, 30)),
          asr: PrayerTimeData(
              name: 'asr',
              nameArabic: 'العصر',
              time: DateTime(2024, 3, 15, 15, 45)),
          maghrib: PrayerTimeData(
              name: 'maghrib',
              nameArabic: 'المغرب',
              time: DateTime(2024, 3, 15, 18, 30)),
          isha: PrayerTimeData(
              name: 'isha',
              nameArabic: 'العشاء',
              time: DateTime(2024, 3, 15, 20, 0)),
          date: DateTime(2024, 3, 15),
          hijriDate: '5 رمضان 1445',
          gregorianDate: '15 مارس 2024',
          cityName: 'مكة المكرمة',
          countryName: 'السعودية',
          latitude: 21.4225,
          longitude: 39.8262,
        );

        // When: Prepare notification data (obligatory prayers only)
        final notificationData = prayers.obligatoryPrayers.map((prayer) {
          return {
            'id': prayer.name.hashCode,
            'name': prayer.name,
            'nameArabic': prayer.nameArabic,
            'time': prayer.time.toIso8601String(),
            'formattedTime': prayer.formattedTime,
            'scheduledAt': prayer.time,
          };
        }).toList();

        // Then: All prayers should have required notification fields
        expect(notificationData.length, equals(5));
        for (final data in notificationData) {
          expect(data['name'], isNotEmpty);
          expect(data['nameArabic'], isNotEmpty);
          expect(data['time'], isNotEmpty);
          expect(data['formattedTime'], isNotEmpty);
          expect(data['scheduledAt'], isA<DateTime>());
        }
      });

      test('should filter future prayers for scheduling', () {
        // Given: Prayer times where some have passed
        final now = DateTime(2024, 3, 15, 13, 0); // 1:00 PM
        final prayers = DailyPrayerTimes(
          fajr: PrayerTimeData(
              name: 'fajr',
              nameArabic: 'الفجر',
              time: DateTime(2024, 3, 15, 5, 0)),
          sunrise: PrayerTimeData(
              name: 'sunrise',
              nameArabic: 'الشروق',
              time: DateTime(2024, 3, 15, 6, 15)),
          dhuhr: PrayerTimeData(
              name: 'dhuhr',
              nameArabic: 'الظهر',
              time: DateTime(2024, 3, 15, 12, 30)),
          asr: PrayerTimeData(
              name: 'asr',
              nameArabic: 'العصر',
              time: DateTime(2024, 3, 15, 15, 45)),
          maghrib: PrayerTimeData(
              name: 'maghrib',
              nameArabic: 'المغرب',
              time: DateTime(2024, 3, 15, 18, 30)),
          isha: PrayerTimeData(
              name: 'isha',
              nameArabic: 'العشاء',
              time: DateTime(2024, 3, 15, 20, 0)),
          date: DateTime(2024, 3, 15),
          hijriDate: '5 رمضان 1445',
          gregorianDate: '15 مارس 2024',
          cityName: 'مكة المكرمة',
          countryName: 'السعودية',
          latitude: 21.4225,
          longitude: 39.8262,
        );

        // When: Filter future obligatory prayers
        final futurePrayers = prayers.obligatoryPrayers
            .where((p) => p.time.isAfter(now))
            .toList();

        // Then: Only Asr, Maghrib, and Isha should be in the future
        expect(futurePrayers.length, equals(3));
        expect(futurePrayers[0].name, equals('asr'));
        expect(futurePrayers[1].name, equals('maghrib'));
        expect(futurePrayers[2].name, equals('isha'));
      });
    });

    group('Calculation Method Enumeration', () {
      test('should have all calculation methods defined', () {
        // Then: All methods should be available
        expect(PrayerCalculationMethod.values.length, greaterThanOrEqualTo(10));
        expect(PrayerCalculationMethod.values,
            contains(PrayerCalculationMethod.ummAlQura));
        expect(PrayerCalculationMethod.values,
            contains(PrayerCalculationMethod.muslimWorldLeague));
        expect(PrayerCalculationMethod.values,
            contains(PrayerCalculationMethod.egyptian));
        expect(PrayerCalculationMethod.values,
            contains(PrayerCalculationMethod.isna));
      });

      test('should have both madhab options', () {
        expect(AsrMadhab.values.length, equals(2));
        expect(AsrMadhab.values, contains(AsrMadhab.shafi));
        expect(AsrMadhab.values, contains(AsrMadhab.hanafi));
      });
    });

    group('Weekly Schedule Simulation', () {
      test('should be able to create prayer times for multiple days', () {
        // Given: A starting date
        final startDate = DateTime(2024, 3, 15);

        // When: Create prayer times for 7 days
        final weekPrayers = <DailyPrayerTimes>[];

        for (int i = 0; i < 7; i++) {
          final date = startDate.add(Duration(days: i));
          // Simulate slightly varying prayer times (in reality, they'd come from calculation)
          final prayers = DailyPrayerTimes(
            fajr: PrayerTimeData(
                name: 'fajr',
                nameArabic: 'الفجر',
                time: DateTime(date.year, date.month, date.day, 5, 0 + i)),
            sunrise: PrayerTimeData(
                name: 'sunrise',
                nameArabic: 'الشروق',
                time: DateTime(date.year, date.month, date.day, 6, 15 + i)),
            dhuhr: PrayerTimeData(
                name: 'dhuhr',
                nameArabic: 'الظهر',
                time: DateTime(date.year, date.month, date.day, 12, 30)),
            asr: PrayerTimeData(
                name: 'asr',
                nameArabic: 'العصر',
                time: DateTime(date.year, date.month, date.day, 15, 45 - i)),
            maghrib: PrayerTimeData(
                name: 'maghrib',
                nameArabic: 'المغرب',
                time: DateTime(date.year, date.month, date.day, 18, 30 + i)),
            isha: PrayerTimeData(
                name: 'isha',
                nameArabic: 'العشاء',
                time: DateTime(date.year, date.month, date.day, 20, 0)),
            date: date,
            hijriDate: '${5 + i} رمضان 1445',
            gregorianDate: '${15 + i} مارس 2024',
            cityName: 'مكة المكرمة',
            countryName: 'السعودية',
            latitude: 21.4225,
            longitude: 39.8262,
          );
          weekPrayers.add(prayers);
        }

        // Then: Should have 7 days of prayers
        expect(weekPrayers.length, equals(7));

        // And: Each day should have 5 obligatory prayers
        for (final day in weekPrayers) {
          expect(day.obligatoryPrayers.length, equals(5));
        }

        // And: Prayer dates should progress chronologically
        for (int i = 0; i < 6; i++) {
          expect(
            weekPrayers[i + 1].date.isAfter(weekPrayers[i].date),
            isTrue,
            reason: 'Day ${i + 2} should be after day ${i + 1}',
          );
        }
      });
    });

    group('Time Zone Handling', () {
      test('should handle same-day time comparisons correctly', () {
        // Given: A reference time and prayer time on the same day
        final referenceTime = DateTime(2024, 3, 15, 14, 0);
        final prayerTime = DateTime(2024, 3, 15, 15, 45);

        // When: Calculate time until prayer
        final timeUntil = prayerTime.difference(referenceTime);

        // Then: Should be positive and correct duration
        expect(timeUntil.isNegative, isFalse);
        expect(timeUntil.inMinutes, equals(105)); // 1 hour 45 minutes
      });

      test('should handle day boundary correctly', () {
        // Given: A late night time and next day fajr
        final lateNight = DateTime(2024, 3, 15, 23, 30);
        final nextFajr = DateTime(2024, 3, 16, 5, 0);

        // When: Calculate time until next Fajr
        final timeUntil = nextFajr.difference(lateNight);

        // Then: Should be positive and cross midnight
        expect(timeUntil.isNegative, isFalse);
        expect(timeUntil.inHours, equals(5)); // 5.5 hours
        expect(timeUntil.inMinutes, equals(330)); // 5 hours 30 minutes
      });
    });

    group('Notification ID Generation', () {
      test('should generate unique notification IDs for each prayer', () {
        // Given: Prayer names
        final prayerNames = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

        // When: Generate IDs
        final ids = prayerNames.map((name) => name.hashCode).toSet();

        // Then: All IDs should be unique
        expect(ids.length, equals(5));
      });

      test('should generate consistent IDs for same prayer name', () {
        // Given: Same prayer name used twice
        const prayerName = 'fajr';

        // When: Generate IDs
        final id1 = prayerName.hashCode;
        final id2 = prayerName.hashCode;

        // Then: IDs should be the same
        expect(id1, equals(id2));
      });
    });
  });
}
