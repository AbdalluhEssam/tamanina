import 'package:equatable/equatable.dart';
import '../../../../core/services/prayer_service.dart';
import '../../../../core/services/location_service.dart';

/// حالات شاشة الصلاة الرئيسية
/// Prayer Home Screen States
abstract class PrayerHomeState extends Equatable {
  const PrayerHomeState();

  @override
  List<Object?> get props => [];
}

/// الحالة الابتدائية
class PrayerHomeInitial extends PrayerHomeState {}

/// جاري التحميل
class PrayerHomeLoading extends PrayerHomeState {}

/// تم التحميل بنجاح
class PrayerHomeLoaded extends PrayerHomeState {
  final DailyPrayerTimes prayerTimes;
  final DateTime lastUpdated;

  const PrayerHomeLoaded({
    required this.prayerTimes,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [prayerTimes, lastUpdated];
}

/// حدث خطأ
class PrayerHomeError extends PrayerHomeState {
  final String message;
  final String? errorCode;

  const PrayerHomeError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// تم رفض إذن الموقع
class PrayerHomeLocationDenied extends PrayerHomeState {
  final String message;
  final LocationErrorType errorType;

  const PrayerHomeLocationDenied({
    required this.message,
    required this.errorType,
  });

  @override
  List<Object?> get props => [message, errorType];
}

/// جاري اختيار الموقع يدوياً
class PrayerHomeSelectingLocation extends PrayerHomeState {}
