import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/api/auth_service.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/api/api_client.dart';

class RealAuthRepository implements AuthRepository {
  final ApiClient apiClient;
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  RealAuthRepository({required this.apiClient});

  @override
  Future<void> sendOtp(String emailOrPhone) async {
    await apiClient.post('/auth/send-otp', data: {
      'identity': emailOrPhone,
    });
  }

  @override
  Future<void> requestWhatsAppOTP(String phoneNumber) async {
    await apiClient.post('/auth/send-otp', data: {
      'phone': phoneNumber,
    });
  }

  @override
  Future<UserModel> login({required String email, required String password}) async {
    final response = await apiClient.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    
    if (response.data['success'] == true) {
      final userData = response.data['data']['user'];
      final token = response.data['data']['accessToken'];
      final refreshToken = response.data['data']['refreshToken'];

      await _storage.write(key: 'access_token', value: token);
      await _storage.write(key: 'refresh_token', value: refreshToken);

      return UserModel.fromJson(userData);
    } else {
      throw Exception(response.data['message'] ?? 'Login failed');
    }
  }

  @override
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final response = await apiClient.post('/auth/register', data: {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phone,
      'password': password,
      // Schema stores lowercase: 'passenger' | 'driver'
      'user_type': role.toLowerCase(),
    });

    if (response.data['success'] == true) {
      final userData = response.data['data']['user'];
      final token = response.data['data']['accessToken'];
      final refreshToken = response.data['data']['refreshToken'];

      await _storage.write(key: 'access_token', value: token);
      await _storage.write(key: 'refresh_token', value: refreshToken);

      return UserModel.fromJson(userData);
    } else {
      throw Exception(response.data['message'] ?? 'Registration failed');
    }
  }

  @override
  Future<UserModel> verifyOtp(String emailOrPhone, String otp) async {
    final response = await apiClient.post('/auth/verify-otp', data: {
      'identity': emailOrPhone,
      'otp': otp,
    });

    final userData = response.data['data']['user'];
    final token = response.data['data']['accessToken'];

    // Save token for future requests
    await _storage.write(key: 'access_token', value: token);
    await _storage.write(key: 'refresh_token', value: response.data['data']['refreshToken']);

    return UserModel.fromJson(userData);
  }

  @override
  Future<void> verifyDriverNIN(String nin) async {
    final response = await apiClient.post('/auth/verify-nin', data: {
      'nin': nin,
    });
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'NIN Verification Failed');
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    final response = await apiClient.post('/auth/update-profile', data: user.toJson());
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await apiClient.get('/auth/me');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    try {
      await apiClient.post('/auth/logout');
    } catch (_) {}
  }
}
