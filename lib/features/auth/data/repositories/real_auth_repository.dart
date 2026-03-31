import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/api/api_client.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class RealAuthRepository implements AuthRepository {
  final ApiClient apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  RealAuthRepository({required this.apiClient});

  @override
  Future<UserModel> register({
    required String firstName, required String lastName,
    required String email, required String phone,
    required String password, required String role,
  }) async {
    final response = await apiClient.post('auth/signup', data: {
      'fullName': '$firstName $lastName',
      'email': email,
      'phone': phone,
      'password': password,
      'role': role.toUpperCase(),
    });

    if (response.data['success'] == true) {
      final tokenData = response.data['data'];
      await _storage.write(key: 'access_token', value: tokenData['accessToken']);
      await _storage.write(key: 'refresh_token', value: tokenData['refreshToken']);

      return UserModel(
        id: tokenData['userId'] ?? '', 
        phone: phone, 
        email: email, 
        firstName: firstName, 
        lastName: lastName,
        role: UserRole.values.firstWhere((e) => e.name == role.toLowerCase(), orElse: () => UserRole.passenger),
      );
    }
    throw Exception(response.data['message'] ?? 'Registration failed');
  }

  @override
  Future<UserModel> login({required String email, required String password}) async {
    final response = await apiClient.post('auth/login', data: {'email': email, 'password': password});
    if (response.data['success'] == true) {
      final userData = response.data['data']['user'];
      await _storage.write(key: 'access_token', value: response.data['data']['accessToken']);
      await _storage.write(key: 'refresh_token', value: response.data['data']['refreshToken']);
      return UserModel.fromJson(userData);
    }
    throw Exception(response.data['message'] ?? 'Login failed');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await apiClient.get('auth/me');
      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      // 🚀 FIX: Handle 401 (Unauthorized) by returning null instead of crashing
      if (e.response?.statusCode == 401) {
        return null;
      }
      rethrow;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel> verifyOtp(String emailOrPhone, String otp) async {
    final response = await apiClient.post('kyc/otp/verify', data: {'code': otp});
    if (response.data['success'] == true) {
      final user = await getCurrentUser();
      if (user == null) throw Exception('User not found after verification');
      return user;
    }
    throw Exception('Verification failed');
  }

  @override
  Future<void> verifyDriverNIN(String nin) async => await apiClient.post('kyc/verify-nin', data: {'nin': nin});

  @override
  Future<List<dynamic>> getBanks() async {
    final response = await apiClient.get('kyc/bank-list');
    return response.data['data'];
  }

  @override
  Future<void> requestWhatsAppOTP(String phoneNumber) async {
    await apiClient.post('kyc/otp/send', data: {'phone': phoneNumber, 'method': 'WHATSAPP'});
  }

  @override
  Future<Map<String, dynamic>?> verifyBankAccount(String bankCode, String accountNumber) async {
    final response = await apiClient.post('kyc/verify-bank', data: {'accountNumber': accountNumber, 'bankCode': bankCode});
    return response.data['success'] == true ? response.data : null;
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post('auth/logout');
    } catch (_) {} // Ignore logout network errors
    await _storage.deleteAll();
  }
  
  @override
  Future<void> sendOtp(String emailOrPhone) async => await apiClient.post('kyc/otp/send', data: {'phone': emailOrPhone, 'method': 'SMS'});

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    final response = await apiClient.post('auth/update-profile', data: user.toJson());
    return UserModel.fromJson(response.data['data']);
  }
}