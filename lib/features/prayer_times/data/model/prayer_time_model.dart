import 'package:equatable/equatable.dart';

/// نموذج بيانات أوقات الصلاة
/// Prayer Times Data Model
class PrayerTimeModel extends Equatable {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;
  final String hijriDate;
  final String readableDate;
  final String hijriMonth;
  final String hijriYear;
  final String gregorianMonth;
  final String gregorianYear;

  const PrayerTimeModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.hijriDate,
    required this.readableDate,
    required this.hijriMonth,
    required this.hijriYear,
    required this.gregorianMonth,
    required this.gregorianYear,
  });

  /// Create from JSON
  factory PrayerTimeModel.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'] as Map<String, dynamic>;
    final dateInfo = json['data']['date'];
    final hijri = dateInfo['hijri'];
    final gregorian = dateInfo['gregorian'];

    return PrayerTimeModel(
      fajr: _cleanTime(timings['Fajr']),
      sunrise: _cleanTime(timings['Sunrise']),
      dhuhr: _cleanTime(timings['Dhuhr']),
      asr: _cleanTime(timings['Asr']),
      maghrib: _cleanTime(timings['Maghrib']),
      isha: _cleanTime(timings['Isha']),
      date: dateInfo['readable'] ?? '',
      hijriDate: '${hijri['day']} ${hijri['month']['ar']} ${hijri['year']}',
      readableDate: dateInfo['readable'] ?? '',
      hijriMonth: hijri['month']['ar'] ?? '',
      hijriYear: hijri['year'] ?? '',
      gregorianMonth: gregorian['month']['en'] ?? '',
      gregorianYear: gregorian['year'] ?? '',
    );
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'date': date,
      'hijriDate': hijriDate,
      'readableDate': readableDate,
      'hijriMonth': hijriMonth,
      'hijriYear': hijriYear,
      'gregorianMonth': gregorianMonth,
      'gregorianYear': gregorianYear,
    };
  }

  /// Create from cached JSON
  factory PrayerTimeModel.fromCachedJson(Map<String, dynamic> json) {
    return PrayerTimeModel(
      fajr: json['fajr'] ?? '',
      sunrise: json['sunrise'] ?? '',
      dhuhr: json['dhuhr'] ?? '',
      asr: json['asr'] ?? '',
      maghrib: json['maghrib'] ?? '',
      isha: json['isha'] ?? '',
      date: json['date'] ?? '',
      hijriDate: json['hijriDate'] ?? '',
      readableDate: json['readableDate'] ?? '',
      hijriMonth: json['hijriMonth'] ?? '',
      hijriYear: json['hijriYear'] ?? '',
      gregorianMonth: json['gregorianMonth'] ?? '',
      gregorianYear: json['gregorianYear'] ?? '',
    );
  }

  /// Clean time string (remove timezone info)
  static String _cleanTime(String time) {
    return time.split(' ').first;
  }

  /// Get prayer time by name
  String getPrayerTime(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
      case 'الفجر':
        return fajr;
      case 'dhuhr':
      case 'الظهر':
        return dhuhr;
      case 'asr':
      case 'العصر':
        return asr;
      case 'maghrib':
      case 'المغرب':
        return maghrib;
      case 'isha':
      case 'العشاء':
        return isha;
      default:
        return '';
    }
  }

  @override
  List<Object?> get props => [
        fajr,
        sunrise,
        dhuhr,
        asr,
        maghrib,
        isha,
        date,
        hijriDate,
        readableDate,
        hijriMonth,
        hijriYear,
        gregorianMonth,
        gregorianYear,
      ];

  PrayerTimeModel copyWith({
    String? fajr,
    String? sunrise,
    String? dhuhr,
    String? asr,
    String? maghrib,
    String? isha,
    String? date,
    String? hijriDate,
    String? readableDate,
    String? hijriMonth,
    String? hijriYear,
    String? gregorianMonth,
    String? gregorianYear,
  }) {
    return PrayerTimeModel(
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      date: date ?? this.date,
      hijriDate: hijriDate ?? this.hijriDate,
      readableDate: readableDate ?? this.readableDate,
      hijriMonth: hijriMonth ?? this.hijriMonth,
      hijriYear: hijriYear ?? this.hijriYear,
      gregorianMonth: gregorianMonth ?? this.gregorianMonth,
      gregorianYear: gregorianYear ?? this.gregorianYear,
    );
  }
}

/// Prayer model for individual prayers
class Prayer {
  final String nameAr;
  final String nameEn;
  final String time;
  final String emoji;

  const Prayer({
    required this.nameAr,
    required this.nameEn,
    required this.time,
    required this.emoji,
  });
}
