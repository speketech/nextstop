import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Required for kReleaseMode
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  late final Dio _dio;
  late final Dio _tokenDio; // Dedicated instance for refreshing tokens
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static BaseOptions _baseOptions() {
    // 1. Dynamic Base URL Selection
    // If in Release mode (Render), use the production URL. 
    // Otherwise, check .env or fallback to localhost.
    const String productionUrl = 'https://nextstop-api-ua95.onrender.com/api';
    const String localUrl = 'http://localhost:3000/api';

    return BaseOptions(
      baseUrl: kReleaseMode ? productionUrl : (dotenv.env['API_URL'] ?? localUrl),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  ApiClient() {
    _dio = Dio(_baseOptions());
    _tokenDio = Dio(_baseOptions());

    // 2. The Interceptor Architecture
    _dio.interceptors.add(QueuedInterceptorsWrapper(
      // --- ON REQUEST: Attach the Access Token ---
      onRequest: (options, handler) async {
        final String? accessToken = await _storage.read(key: 'access_token');
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },

      // --- ON ERROR: Handle 401 Unauthorized (Token Expiry) ---
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          // Attempt to refresh the token
          final bool isRefreshed = await _refreshToken();

          if (isRefreshed) {
            // Retry the original request with the new token
            final String? newAccessToken = await _storage.read(key: 'access_token');
            error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            try {
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } on DioException catch (retryError) {
              return handler.next(retryError);
            }
          } else {
            // Refresh failed — clear storage and force logout
            await _logoutUser();
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
    ));
  }

  // 3. Token Refresh Logic (Server-to-Server)
  Future<bool> _refreshToken() async {
    try {
      final String? refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      // Use _tokenDio to avoid interceptor recursion
      final response = await _tokenDio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        await _storage.write(key: 'access_token', value: data['accessToken']);
        await _storage.write(key: 'refresh_token', value: data['refreshToken']);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('CRITICAL: Token refresh failed: $e');
      return false;
    }
  }

  Future<void> _logoutUser() async {
    await _storage.deleteAll();
    debugPrint('Session expired. User logged out.');
    // Navigation to Login should be handled by your AuthBloc/State management
  }

  // 4. Convenience Methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async =>
      await _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) async =>
      await _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) async =>
      await _dio.put(path, data: data);

  Future<Response> delete(String path) async =>
      await _dio.delete(path);

  Dio get instance => _dio;
}