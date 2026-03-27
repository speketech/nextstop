import 'package:equatable/equatable.dart';
import '../../domain/models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SendOtpRequested extends AuthEvent {
  final String emailOrPhone;
  const SendOtpRequested(this.emailOrPhone);
  @override
  List<Object> get props => [emailOrPhone];
}

class VerifyOtpRequested extends AuthEvent {
  final String emailOrPhone;
  final String otp;
  const VerifyOtpRequested(this.emailOrPhone, this.otp);
  @override
  List<Object> get props => [emailOrPhone, otp];
}

class UpdateProfileRequested extends AuthEvent {
  final UserModel user;
  const UpdateProfileRequested(this.user);
  @override
  List<Object> get props => [user];
}

class LogoutRequested extends AuthEvent {}

class RequestWhatsAppOtp extends AuthEvent {
  final String phoneNumber;
  const RequestWhatsAppOtp(this.phoneNumber);
  @override
  List<Object> get props => [phoneNumber];
}

class VerifyNinRequested extends AuthEvent {
  final String nin;
  const VerifyNinRequested(this.nin);
  @override
  List<Object> get props => [nin];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String role;
  const RegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
  });
  @override
  List<Object> get props => [firstName, lastName, email, phone, password, role];
}
