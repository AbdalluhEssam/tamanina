part of 'prayer_times_cubit.dart';

/// حالات مواقيت الصلاة
/// Prayer Times States
abstract class PrayerTimesState extends Equatable {
  const PrayerTimesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
/// الحالة الأولية
class PrayerTimesInitial extends PrayerTimesState {
  const PrayerTimesInitial();
}

/// Loading state
/// حالة التحميل
class PrayerTimesLoading extends PrayerTimesState {
  const PrayerTimesLoading();
}

/// Loaded state
/// حالة البيانات المحملة
class PrayerTimesLoaded extends PrayerTimesState {
  final PrayerTimeModel prayerTimes;
  final String city;
  final String country;
  final String? nextPrayer;
  final Duration? timeUntilNextPrayer;

  const PrayerTimesLoaded({
    required this.prayerTimes,
    required this.city,
    required this.country,
    this.nextPrayer,
    this.timeUntilNextPrayer,
  });

  @override
  List<Object?> get props => [
        prayerTimes,
        city,
        country,
        nextPrayer,
        timeUntilNextPrayer,
      ];

  PrayerTimesLoaded copyWith({
    PrayerTimeModel? prayerTimes,
    String? city,
    String? country,
    String? nextPrayer,
    Duration? timeUntilNextPrayer,
  }) {
    return PrayerTimesLoaded(
      prayerTimes: prayerTimes ?? this.prayerTimes,
      city: city ?? this.city,
      country: country ?? this.country,
      nextPrayer: nextPrayer ?? this.nextPrayer,
      timeUntilNextPrayer: timeUntilNextPrayer ?? this.timeUntilNextPrayer,
    );
  }
}

/// Error state
/// حالة الخطأ
class PrayerTimesError extends PrayerTimesState {
  final String message;
  final PrayerTimeModel? cachedData;

  const PrayerTimesError({
    required this.message,
    this.cachedData,
  });

  @override
  List<Object?> get props => [message, cachedData];
}

/// Location permission denied state
/// حالة رفض إذن الموقع
class PrayerTimesLocationDenied extends PrayerTimesState {
  final String message;

  const PrayerTimesLocationDenied({
    this.message = 'يُرجى السماح بالوصول إلى الموقع لعرض أوقات الصلاة الدقيقة',
  });

  @override
  List<Object?> get props => [message];
}
