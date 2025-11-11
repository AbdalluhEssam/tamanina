import 'package:dio/dio.dart';
import '../model/prayer_time_model.dart';

/// خدمة جلب أوقات الصلاة من API
/// Prayer Times API Service
class PrayerTimesService {
  final Dio _dio;
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  PrayerTimesService({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetch prayer times by city
  /// جلب أوقات الصلاة حسب المدينة
  Future<PrayerTimeModel> getPrayerTimesByCity({
    required String city,
    required String country,
    int method = 4, // Umm al-Qura University, Makkah
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/timingsByCity',
        queryParameters: {
          'city': city,
          'country': country,
          'method': method,
        },
      );

      if (response.statusCode == 200) {
        return PrayerTimeModel.fromJson(response.data);
      } else {
        throw Exception('فشل في جلب أوقات الصلاة: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('خطأ في الاتصال. تحقق من اتصالك بالإنترنت');
      } else {
        throw Exception('حدث خطأ: ${e.message}');
      }
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  /// Fetch prayer times by coordinates
  /// جلب أوقات الصلاة حسب الإحداثيات
  Future<PrayerTimeModel> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    int method = 4, // Umm al-Qura University, Makkah
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/timings',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': method,
        },
      );

      if (response.statusCode == 200) {
        return PrayerTimeModel.fromJson(response.data);
      } else {
        throw Exception('فشل في جلب أوقات الصلاة: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('خطأ في الاتصال. تحقق من اتصالك بالإنترنت');
      } else {
        throw Exception('حدث خطأ: ${e.message}');
      }
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  /// Get prayer times for a specific date
  /// جلب أوقات الصلاة لتاريخ محدد
  Future<PrayerTimeModel> getPrayerTimesByDate({
    required String city,
    required String country,
    required String date, // Format: DD-MM-YYYY
    int method = 4,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/timingsByCity/$date',
        queryParameters: {
          'city': city,
          'country': country,
          'method': method,
        },
      );

      if (response.statusCode == 200) {
        return PrayerTimeModel.fromJson(response.data);
      } else {
        throw Exception('فشل في جلب أوقات الصلاة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('حدث خطأ: $e');
    }
  }
}
