import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 1. User Registration
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role, // 'PASSENGER' or 'DRIVER'
  }) async {
    try {
      final response = await _apiClient.post('/auth/register', data: {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      });

      if (response.data['success'] == true) {
        // Save the tokens returned by the backend
        await _saveTokens(
          response.data['data']['accessToken'],
          response.data['data']['refreshToken'],
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Registration Failed: ${e.response?.data['message'] ?? e.message}');
      return false;
    }
  }

  // 2. User Login
  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await _apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success'] == true) {
        await _saveTokens(
          response.data['data']['accessToken'],
          response.data['data']['refreshToken'],
        );
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Login Failed: ${e.response?.data['message'] ?? e.message}');
      return false;
    }
  }

  // 3. Securely Save Tokens
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  // 4. Logout
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  // 5. Get Bank List
  Future<List<dynamic>> getBankList() async {
    try {
      final response = await _apiClient.get('/auth/bank-list');
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return [];
    } on DioException catch (e) {
      print('Fetch Bank List Failed: ${e.response?.data['message'] ?? e.message}');
      return [];
    }
  }

  // 6. Verify Bank Account
  Future<Map<String, dynamic>?> verifyBank({
    required String bankCode,
    required String accountNumber,
  }) async {
    try {
      final response = await _apiClient.post('/auth/verify-bank', data: {
        'bank_code': bankCode,
        'account_number': accountNumber,
      });

      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } on DioException catch (e) {
      print('Bank Verification Failed: ${e.response?.data['message'] ?? e.message}');
      return null;
    }
  }
}
