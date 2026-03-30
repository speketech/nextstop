import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _productionUrl = 'https://nextstop-api-ua95.onrender.com/api';

  static BaseOptions _baseOptions() {
    String apiUrl = _productionUrl.trim();
    
    // Normalizes to .../api/ to prevent 404
    if (!apiUrl.endsWith('/api')) {
      if (apiUrl.endsWith('/')) apiUrl = apiUrl.substring(0, apiUrl.length - 1);
      apiUrl = '$apiUrl/api';
    }

    debugPrint('ApiClient: Final Base URL -> $apiUrl/');

    return BaseOptions(
      baseUrl: '$apiUrl/', 
      connectTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    );
  }

  ApiClient() {
    _dio = Dio(_baseOptions());
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
    ));
  }

  Future<Response> post(String path, {dynamic data}) async => await _dio.post(path, data: data);
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async => await _dio.get(path, queryParameters: queryParameters);
}