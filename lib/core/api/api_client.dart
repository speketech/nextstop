import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  late final Dio _dio;
  late final Dio _tokenDio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Always use the Render production URL — both in debug and release.
  // This is safe because the URL itself is not a secret.
  static const String _productionUrl = 'https://nextstop-api-ua95.onrender.com/api';

  static BaseOptions _baseOptions() {
    // Sanitize the URL from .env: trim whitespace/newlines which cause DNS failures
    String apiUrl = (dotenv.env['API_URL'] ?? _productionUrl).trim().replaceAll('\r', '').replaceAll('\n', '');
    
    // Ensure it ends with /api if it's the production domain but missing it
    if (apiUrl.contains('onrender.com') && !apiUrl.endsWith('/api')) {
      apiUrl = apiUrl.endsWith('/') ? '${apiUrl}api' : '$apiUrl/api';
    }

    debugPrint('🚀 ApiClient: Using Base URL -> $apiUrl');

    return BaseOptions(
      baseUrl: apiUrl,
      // Render free-tier services sleep after 15 mins inactivity.
      // Cold start can take 30-60 seconds — give it time.
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  ApiClient() {
    _dio = Dio(_baseOptions());
    _tokenDio = Dio(_baseOptions());

    _dio.interceptors.add(QueuedInterceptorsWrapper(
      // Attach JWT access token to every request
      onRequest: (options, handler) async {
        final String? accessToken = await _storage.read(key: 'access_token');
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },

      // Handle server errors with user-friendly messages
      onError: (DioException error, handler) async {
        // ── Token expiry: refresh and retry ──────────────
        if (error.response?.statusCode == 401) {
          final bool isRefreshed = await _refreshToken();
          if (isRefreshed) {
            final String? newAccessToken = await _storage.read(key: 'access_token');
            error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            try {
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } on DioException catch (retryError) {
              return handler.next(retryError);
            }
          } else {
            await _logoutUser();
            return handler.next(error);
          }
        }

        // ── Network/DNS errors: wrap with friendly message ─
        if (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.unknown) {
          debugPrint('🌐 Network error: ${error.message}');
          // Re-throw with a friendlier message that the UI can display
          return handler.next(DioException(
            requestOptions: error.requestOptions,
            error: error.error,
            type: error.type,
            message: 'Cannot reach the server. '
                'The backend may be starting up (this can take ~30s on first use). '
                'Please try again in a moment.',
          ));
        }

        return handler.next(error);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final String? refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

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
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async =>
      await _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data}) async =>
      await _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) async =>
      await _dio.put(path, data: data);

  Future<Response> patch(String path, {dynamic data}) async =>
      await _dio.patch(path, data: data);

  Future<Response> delete(String path) async =>
      await _dio.delete(path);

  Dio get instance => _dio;
}