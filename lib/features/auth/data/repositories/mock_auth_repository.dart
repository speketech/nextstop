import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser;

  @override
  Future<void> sendOtp(String emailOrPhone) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    print('Mock: OTP sent to $emailOrPhone');
  }

  @override
  Future<UserModel> login({required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = UserModel(
      id: 'user_123',
      firstName: 'Chidi',
      lastName: 'Nwosu',
      email: email,
      phone: '08123456789',
      role: UserRole.passenger,
    );
    return _currentUser!;
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
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = UserModel(
      id: 'user_123',
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      role: role == 'driver' ? UserRole.driver : UserRole.passenger,
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> verifyOtp(String emailOrPhone, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // In mock, any 6-digit OTP works
    if (otp.length == 6) {
      _currentUser = UserModel(
        id: 'user_123',
        firstName: 'Chidi',
        lastName: 'Nwosu',
        email: emailOrPhone,
        phone: emailOrPhone.contains('@') ? '08123456789' : emailOrPhone,
        role: UserRole.passenger,
      );
      return _currentUser!;
    } else {
      throw Exception('Invalid OTP');
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = user;
    return _currentUser!;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<void> requestWhatsAppOTP(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    print('Mock: WhatsApp OTP requested for $phoneNumber');
  }

  @override
  Future<void> logout() async {
    // No-op
  }

  @override
  Future<void> verifyDriverNIN(String nin) async {
    await Future.delayed(const Duration(seconds: 1));
    print('Mock: NIN $nin verified');
  }
}
