import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _productionUrl = 'https://nextstop-api-ua95.onrender.com/api';

  static BaseOptions _baseOptions() {
    String apiUrl = _productionUrl.trim();
    
    // Normalizes to ensure it ends with /api
    if (apiUrl.endsWith('/')) {
      apiUrl = apiUrl.substring(0, apiUrl.length - 1);
    }
    
    if (!apiUrl.endsWith('/api')) {
      apiUrl = '$apiUrl/api';
    }

    debugPrint('ApiClient: Final Base URL -> $apiUrl/');

    return BaseOptions(
      baseUrl: '$apiUrl/', 
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json', 
        'Accept': 'application/json'
      },
    );
  }

  ApiClient() {
    _dio = Dio(_baseOptions());
    
    // Interceptor to inject JWT token into every request
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Log errors for debugging
        debugPrint('API Error: ${e.response?.statusCode} - ${e.message}');
        return handler.next(e);
      },
    ));
  }

  Future<Response> post(String path, {dynamic data}) async => await _dio.post(path, data: data);
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async => await _dio.get(path, queryParameters: queryParameters);
}