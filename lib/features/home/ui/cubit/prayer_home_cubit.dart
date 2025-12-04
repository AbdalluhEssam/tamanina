import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/prayer_service.dart';
import '../../../../core/services/location_service.dart';
import 'prayer_home_state.dart';

/// Cubit للشاشة الرئيسية مع أوقات الصلاة
/// Prayer Home Cubit - Manages prayer times state
class PrayerHomeCubit extends Cubit<PrayerHomeState> {
  PrayerHomeCubit() : super(PrayerHomeInitial());

  final PrayerService _prayerService = PrayerService();
  final LocationService _locationService = LocationService();

  /// تحميل أوقات الصلاة
  Future<void> loadPrayerTimes() async {
    emit(PrayerHomeLoading());

    try {
      // Initialize services
      await _prayerService.initialize();
      await _locationService.initialize();

      // Get prayer times
      final prayerTimes = await _prayerService.getTodayPrayerTimes();

      emit(PrayerHomeLoaded(
        prayerTimes: prayerTimes,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading prayer times: $e');
      }

      // Check if it's a location error
      final locationResult = await _locationService.getCurrentLocation();
      if (!locationResult.isSuccess && locationResult.errorType != null) {
        emit(PrayerHomeLocationDenied(
          message: locationResult.errorMessage ?? 'خطأ في الموقع',
          errorType: locationResult.errorType!,
        ));
      } else {
        emit(PrayerHomeError(message: e.toString()));
      }
    }
  }

  /// تحديث أوقات الصلاة
  Future<void> refreshPrayerTimes() async {
    try {
      final prayerTimes = await _prayerService.getTodayPrayerTimes();

      emit(PrayerHomeLoaded(
        prayerTimes: prayerTimes,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing prayer times: $e');
      }
      emit(PrayerHomeError(message: e.toString()));
    }
  }

  /// استخدام الموقع اليدوي
  Future<void> useManualLocation() async {
    emit(PrayerHomeSelectingLocation());

    // Default to Makkah for now
    await _prayerService.setManualLocation(
      city: 'مكة المكرمة',
      country: 'المملكة العربية السعودية',
      latitude: 21.4225,
      longitude: 39.8262,
    );

    await loadPrayerTimes();
  }

  /// تعيين موقع يدوي محدد
  Future<void> setManualLocation(PopularCity city) async {
    emit(PrayerHomeLoading());

    await _prayerService.setManualLocation(
      city: city.nameArabic,
      country: city.country,
      latitude: city.latitude,
      longitude: city.longitude,
    );

    await loadPrayerTimes();
  }

  /// تغيير طريقة الحساب
  Future<void> setCalculationMethod(PrayerCalculationMethod method) async {
    await _prayerService.setCalculationMethod(method);
    await refreshPrayerTimes();
  }

  /// تغيير المذهب
  Future<void> setMadhab(AsrMadhab madhab) async {
    await _prayerService.setMadhab(madhab);
    await refreshPrayerTimes();
  }

  /// الحصول على طريقة الحساب الحالية
  PrayerCalculationMethod get currentMethod => _prayerService.calculationMethod;

  /// الحصول على المذهب الحالي
  AsrMadhab get currentMadhab => _prayerService.madhab;
}
