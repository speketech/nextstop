import 'package:dio/dio.dart';
import 'api_client.dart';

class KycService {
  final ApiClient _apiClient = ApiClient();

  // Request WhatsApp OTP
  Future<bool> requestWhatsAppOTP(String phone) async {
    try {
      final response = await _apiClient.post('/kyc/send-otp', data: {
        'phone': phone,
      });
      return response.data['success'] == true;
    } catch (e) {
      print('OTP Request Failed: $e');
      return false;
    }
  }

  // Verify the 6-digit code
  Future<bool> verifyOTP(String code) async {
    try {
      final response = await _apiClient.post('/kyc/verify-otp', data: {
        'code': code,
      });
      return response.data['success'] == true;
    } on DioException catch (e) {
      print('OTP Verification Failed: ${e.response?.data['message']}');
      return false;
    }
  }

  // Verify NIN
  Future<String?> verifyNIN(String nin) async {
    try {
      final response = await _apiClient.post('/kyc/verify-nin', data: {
        'nin': nin,
      });
      if (response.data['success'] == true) {
        return null; // Null means no error
      }
      return response.data['message'];
    } on DioException catch (e) {
      return e.response?.data['message'] ?? 'Failed to verify NIN';
    }
  }
}
