import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  late final Dio _dio;

  // Separate Dio instance for token refresh to avoid interceptor loop
  late final Dio _tokenDio;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static BaseOptions _baseOptions() {
    return BaseOptions(
      baseUrl: dotenv.env['API_URL'] ?? 'https://nextstop-api-ua95.onrender.com/api',
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

    // QueuedInterceptorsWrapper: if 5 requests fire simultaneously with an expired
    // token, only one refresh occurs. All pending requests resume with the new token.
    _dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        String? accessToken = await _storage.read(key: 'access_token');
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },

      onError: (DioException error, handler) async {
        // If we get a 401 Unauthorized, the access token is likely expired
        if (error.response?.statusCode == 401) {
          final bool isRefreshed = await _refreshToken();

          if (isRefreshed) {
            // Success! Grab the new token and retry the original failed request
            final String? newAccessToken = await _storage.read(key: 'access_token');
            error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            try {
              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } on DioException catch (retryError) {
              return handler.next(retryError);
            }
          } else {
            // Refresh failed — session expired. Clear tokens and signal logout.
            await _logoutUser();
            return handler.next(error);
          }
        }

        return handler.next(error);
      },
    ));
  }

  // ─── Token Refresh Logic ─────────────────────────────────────────────────────
  Future<bool> _refreshToken() async {
    try {
      final String? refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      // Use _tokenDio (no interceptors) to avoid looping on 401
      final response = await _tokenDio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.data['success'] == true) {
        await _storage.write(key: 'access_token', value: response.data['data']['accessToken']);
        await _storage.write(key: 'refresh_token', value: response.data['data']['refreshToken']);
        return true;
      }
      return false;
    } catch (e) {
      print('Token refresh failed: $e');
      return false;
    }
  }

  Future<void> _logoutUser() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    // NOTE: Use your AuthBloc's LogoutRequested event in the UI layer to
    // navigate the user back to the login screen when this happens.
    print('User logged out due to expired session.');
  }

  Dio get instance => _dio;

  // ─── Convenience Methods ─────────────────────────────────────────────────────
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
