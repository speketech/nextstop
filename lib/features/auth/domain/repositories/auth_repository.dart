import '../models/user_model.dart';

abstract class AuthRepository {
  Future<void> sendOtp(String emailOrPhone);
  Future<void> requestWhatsAppOTP(String phoneNumber);
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String role,
  });
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> verifyOtp(String emailOrPhone, String otp);
  Future<void> verifyDriverNIN(String nin);
  Future<UserModel> updateProfile(UserModel user);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}
