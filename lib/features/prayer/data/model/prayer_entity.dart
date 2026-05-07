import 'package:equatable/equatable.dart';

/// نموذج البيانات الخاص بأوقات الصلاة
/// Prayer Times Data Model
class PrayerTimesEntity extends Equatable {
  final DateTime date; // التاريخ
  final PrayerTimeDetails fajr; // صلاة الفجر
  final PrayerTimeDetails sunrise; // الشروق
  final PrayerTimeDetails dhuhr; // صلاة الظهر
  final PrayerTimeDetails asr; // صلاة العصر
  final PrayerTimeDetails maghrib; // صلاة المغرب
  final PrayerTimeDetails isha; // صلاة العشاء
  final LocationEntity location; // الموقع الجغرافي
  final String calculationMethod; // طريقة الحساب
  final int? hijriDateDay; // التاريخ الهجري - اليوم
  final int? hijriDateMonth; // التاريخ الهجري - الشهر
  final int? hijriDateYear; // التاريخ الهجري - السنة
  final String? hijriMonthName; // اسم الشهر الهجري

  const PrayerTimesEntity({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.location,
    required this.calculationMethod,
    this.hijriDateDay,
    this.hijriDateMonth,
    this.hijriDateYear,
    this.hijriMonthName,
  });

  PrayerTimesEntity copyWith({
    DateTime? date,
    PrayerTimeDetails? fajr,
    PrayerTimeDetails? sunrise,
    PrayerTimeDetails? dhuhr,
    PrayerTimeDetails? asr,
    PrayerTimeDetails? maghrib,
    PrayerTimeDetails? isha,
    LocationEntity? location,
    String? calculationMethod,
    int? hijriDateDay,
    int? hijriDateMonth,
    int? hijriDateYear,
    String? hijriMonthName,
  }) {
    return PrayerTimesEntity(
      date: date ?? this.date,
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      location: location ?? this.location,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      hijriDateDay: hijriDateDay ?? this.hijriDateDay,
      hijriDateMonth: hijriDateMonth ?? this.hijriDateMonth,
      hijriDateYear: hijriDateYear ?? this.hijriDateYear,
      hijriMonthName: hijriMonthName ?? this.hijriMonthName,
    );
  }

  /// الحصول على جميع أوقات الصلاة
  List<PrayerTimeDetails> get allPrayers => [fajr, dhuhr, asr, maghrib, isha];

  /// الحصول على وقت الصلاة الحالي أو القادم
  PrayerTimeDetails? get currentOrNextPrayer {
    final now = DateTime.now();
    final todayPrayers = allPrayers;

    // البحث عن الصلاة الحالية أو القادمة
    for (final prayer in todayPrayers) {
      if (now.isBefore(prayer.time)) {
        return prayer;
      }
    }

    // إذا انتهت جميع الصلوات، إرجاع الفجر من اليوم التالي
    return fajr;
  }

  /// الحصول على الصلاة السابقة
  PrayerTimeDetails? get previousPrayer {
    final now = DateTime.now();
    PrayerTimeDetails? lastPrayer;

    for (final prayer in allPrayers) {
      if (now.isAfter(prayer.time)) {
        lastPrayer = prayer;
      } else {
        break;
      }
    }

    return lastPrayer;
  }

  /// الوقت المتبقي للصلاة القادمة
  Duration? get timeUntilNextPrayer {
    final nextPrayer = currentOrNextPrayer;
    if (nextPrayer == null) return null;

    final now = DateTime.now();
    if (now.isBefore(nextPrayer.time)) {
      return nextPrayer.time.difference(now);
    }

    return null;
  }

  /// التاريخ الهجري كنص
  String get hijriDateString {
    if (hijriDateDay == null ||
        hijriDateMonth == null ||
        hijriDateYear == null) {
      return '';
    }
    return '$hijriDateDay ${hijriMonthName ?? ''} $hijriDateYear هـ';
  }

  @override
  List<Object?> get props => [
        date,
        fajr,
        sunrise,
        dhuhr,
        asr,
        maghrib,
        isha,
        location,
        calculationMethod,
        hijriDateDay,
        hijriDateMonth,
        hijriDateYear,
        hijriMonthName,
      ];
}

/// تفاصيل وقت الصلاة
class PrayerTimeDetails extends Equatable {
  final PrayerType prayerType; // نوع الصلاة
  final DateTime time; // وقت الصلاة
  final bool isNotificationEnabled; // هل التنبيه مفعل
  final int notificationMinutesBefore; // عدد الدقائق قبل التنبيه
  final bool isCompleted; // هل تم أداء الصلاة
  final DateTime? completedAt; // وقت أداء الصلاة
  final bool isMissed; // هل فاتت الصلاة
  final String customAdhan; // الأذان المخصص (اختياري)

  const PrayerTimeDetails({
    required this.prayerType,
    required this.time,
    this.isNotificationEnabled = true,
    this.notificationMinutesBefore = 15,
    this.isCompleted = false,
    this.completedAt,
    this.isMissed = false,
    this.customAdhan = '',
  });

  PrayerTimeDetails copyWith({
    PrayerType? prayerType,
    DateTime? time,
    bool? isNotificationEnabled,
    int? notificationMinutesBefore,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isMissed,
    String? customAdhan,
  }) {
    return PrayerTimeDetails(
      prayerType: prayerType ?? this.prayerType,
      time: time ?? this.time,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      notificationMinutesBefore:
          notificationMinutesBefore ?? this.notificationMinutesBefore,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isMissed: isMissed ?? this.isMissed,
      customAdhan: customAdhan ?? this.customAdhan,
    );
  }

  /// تحديد الصلاة كمكتملة
  PrayerTimeDetails markAsCompleted() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
      isMissed: false,
    );
  }

  /// تحديد الصلاة كفائتة
  PrayerTimeDetails markAsMissed() {
    return copyWith(
      isMissed: true,
      isCompleted: false,
    );
  }

  /// تفعيل/إلغاء تفعيل التنبيه
  PrayerTimeDetails toggleNotification() {
    return copyWith(isNotificationEnabled: !isNotificationEnabled);
  }

  /// الوقت المتبقي لهذه الصلاة
  Duration? get timeRemaining {
    final now = DateTime.now();
    if (now.isBefore(time)) {
      return time.difference(now);
    }
    return null;
  }

  /// هل حان وقت الصلاة الآن
  bool get isCurrentTime {
    final now = DateTime.now();
    final prayerTime = time;
    return now.isAfter(prayerTime.subtract(const Duration(minutes: 5))) &&
        now.isBefore(prayerTime.add(const Duration(minutes: 30)));
  }

  /// هل وقت التنبيه
  bool get isNotificationTime {
    if (!isNotificationEnabled) return false;

    final now = DateTime.now();
    final notificationTime =
        time.subtract(Duration(minutes: notificationMinutesBefore));
    return now.isAfter(notificationTime) && now.isBefore(time);
  }

  @override
  List<Object?> get props => [
        prayerType,
        time,
        isNotificationEnabled,
        notificationMinutesBefore,
        isCompleted,
        completedAt,
        isMissed,
        customAdhan,
      ];
}

/// أنواع الصلوات
enum PrayerType {
  fajr('الفجر', 'Fajr', 'Dawn'),
  sunrise('الشروق', 'Sunrise', 'Sunrise'),
  dhuhr('الظهر', 'Dhuhr', 'Noon'),
  asr('العصر', 'Asr', 'Afternoon'),
  maghrib('المغرب', 'Maghrib', 'Sunset'),
  isha('العشاء', 'Isha', 'Night');

  const PrayerType(this.arabicName, this.englishName, this.meaning);

  final String arabicName;
  final String englishName;
  final String meaning;

  /// هل هذه صلاة (وليس مجرد توقيت)
  bool get isPrayer => this != PrayerType.sunrise;
}

/// نموذج الموقع الجغرافي
class LocationEntity extends Equatable {
  final double latitude; // خط العرض
  final double longitude; // خط الطول
  final String city; // المدينة
  final String country; // البلد
  final String timezone; // المنطقة الزمنية
  final int elevation; // الارتفاع عن سطح البحر

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    required this.timezone,
    this.elevation = 0,
  });

  LocationEntity copyWith({
    double? latitude,
    double? longitude,
    String? city,
    String? country,
    String? timezone,
    int? elevation,
  }) {
    return LocationEntity(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
      timezone: timezone ?? this.timezone,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  List<Object> get props =>
      [latitude, longitude, city, country, timezone, elevation];
}

/// إحصائيات الصلوات
class PrayerStats {
  final int totalPrayersCount; // إجمالي عدد الصلوات
  final int completedPrayersCount; // عدد الصلوات المؤداة
  final int missedPrayersCount; // عدد الصلوات الفائتة
  final double completionRate; // معدل الإنجاز
  final Map<PrayerType, int> prayerTypeStats; // إحصائيات حسب نوع الصلاة
  final DateTime? lastPrayerTime; // آخر وقت صلاة
  final int currentStreak; // السلسلة الحالية من الصلوات المؤداة

  const PrayerStats({
    required this.totalPrayersCount,
    required this.completedPrayersCount,
    required this.missedPrayersCount,
    required this.completionRate,
    required this.prayerTypeStats,
    this.lastPrayerTime,
    required this.currentStreak,
  });

  const PrayerStats.empty()
      : totalPrayersCount = 0,
        completedPrayersCount = 0,
        missedPrayersCount = 0,
        completionRate = 0.0,
        prayerTypeStats = const {},
        lastPrayerTime = null,
        currentStreak = 0;
}
