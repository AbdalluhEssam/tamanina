import 'package:dio/dio.dart';

import '../constants/endpoint_constants.dart';
import 'interceptors.dart';

/// Provides a preconfigured Dio instance for REST calls.
class DioHelper {
  DioHelper._();

  /// Builds a Dio client with sensible defaults and shared interceptors.
  static Dio createClient() {
    final dio = Dio(
      BaseOptions(
        baseUrl: EndpointConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: const <String, dynamic>{
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.add(AppInterceptors());
    return dio;
  }
}
