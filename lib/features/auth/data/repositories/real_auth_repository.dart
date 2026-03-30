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
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String role, // Expected: 'passenger' or 'driver'
  }) async {
    // 1. FIX: Send the exact keys the backend validator requires
    final response = await apiClient.post('/auth/signup', data: {
      'fullName': '$firstName $lastName', // Backend expects single fullName string
      'email': email,
      'phone': phone, // 👈 FIX: Matches backend 'phone' requirement
      'password': password,
      'role': role.toUpperCase(), // Backend expects 'PASSENGER' or 'DRIVER'
    });

    if (response.data['success'] == true) {
      final tokenData = response.data['data'];
      
      // Save tokens for session management
      await _storage.write(key: 'access_token', value: tokenData['accessToken']);
      await _storage.write(key: 'refresh_token', value: tokenData['refreshToken']);

      // 2. FIXING RED SQUIGGLES: Use parameters defined in your UserModel
      return UserModel(
        id: '', // Temporary ID until profile is fetched
        phone: phone,
        email: email,
        firstName: firstName,
        lastName: lastName,
        // Convert the String role into your UserRole enum
        role: UserRole.values.firstWhere(
          (e) => e.name == role.toLowerCase(),
          orElse: () => UserRole.passenger,
        ),
      );
    } else {
      throw Exception(response.data['message'] ?? 'Registration failed');
    }
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

      // Uses your model's fromJson which handles key variations
      return UserModel.fromJson(userData);
    } else {
      throw Exception(response.data['message'] ?? 'Login failed');
    }
  }

  @override
  Future<UserModel> verifyOtp(String emailOrPhone, String otp) async {
    // FIX: Backend expects 'code' for the OTP
    final response = await apiClient.post('/auth/verify-otp', data: {
      'code': otp, 
    });

    if (response.data['success'] == true) {
      final user = await getCurrentUser();
      if (user == null) throw Exception('User data not found after verification');
      return user;
    } else {
      throw Exception(response.data['message'] ?? 'Verification failed');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await apiClient.get('/auth/me'); 
      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Future<void> sendOtp(String emailOrPhone) async {
    await apiClient.post('/auth/send-otp', data: {
      'identity': emailOrPhone,
    });
  }

  @override
  Future<void> verifyDriverNIN(String nin) async {
    final response = await apiClient.post('/auth/verify-nin', data: {'nin': nin});
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'NIN Verification Failed');
    }
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    try {
      await apiClient.post('/auth/logout');
    } catch (_) {}
  }

  @override
  Future<List<dynamic>> getBanks() async {
    final response = await apiClient.get('/auth/bank-list');
    if (response.data['success'] == true) {
      return response.data['data'];
    }
    return [];
  }

  @override
  Future<void> requestWhatsAppOTP(String phoneNumber) async {
    await apiClient.post('/auth/send-whatsapp-otp', data: {'phone': phoneNumber});
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    // Use the model's toJson for consistent snake_case keys
    final response = await apiClient.post('/auth/update-profile', data: user.toJson());
    return UserModel.fromJson(response.data['data']);
  }

  @override
  Future<Map<String, dynamic>?> verifyBankAccount(String bankCode, String accountNumber) async {
    final response = await apiClient.post('/auth/verify-bank', data: {
      'accountNumber': accountNumber,
      'bankCode': bankCode,
    });
    return response.data['success'] == true ? response.data : null;
  }
}