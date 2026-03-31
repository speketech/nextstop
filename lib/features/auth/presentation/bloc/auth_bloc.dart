import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/socket_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SocketService socketService;

  AuthBloc({required this.authRepository, required this.socketService}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RequestWhatsAppOtp>(_onRequestWhatsAppOtp);
    on<VerifyNinRequested>(_onVerifyNinRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    try {
      // 🚀 FIX: Safety net to handle network failures or initial unauthenticated states
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        await _handleSocketInit();
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // If there's any error during the check (like 401 or no internet), treat as unauthenticated
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(email: event.email, password: event.password);
      await _handleSocketInit();
      emit(AuthAuthenticated(user));
    } catch (e) {
      final message = _getErrorMessage(e);
      emit(AuthError(message));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.register(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        phone: event.phone,
        password: event.password,
        role: event.role,
      );
      await _handleSocketInit();
      emit(AuthAuthenticated(user));
    } catch (e) {
      final message = _getErrorMessage(e);
      emit(AuthError(message));
    }
  }

  // Helper to extract clean error messages
  String _getErrorMessage(Object e) {
    if (e is DioException) {
      return e.response?.data['message'] ?? e.message ?? e.toString();
    }
    return e.toString();
  }

  Future<void> _handleSocketInit() async {
    final token = await const FlutterSecureStorage().read(key: 'access_token');
    if (token != null) {
      socketService.initSocket(token);
    }
  }

  // ... (rest of handlers updated with _getErrorMessage)

  Future<void> _onSendOtpRequested(SendOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.sendOtp(event.emailOrPhone);
      emit(OtpSentState(event.emailOrPhone));
    } catch (e) { emit(AuthError(_getErrorMessage(e))); }
  }

  Future<void> _onVerifyOtpRequested(VerifyOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.verifyOtp(event.emailOrPhone, event.otp);
      await _handleSocketInit();
      emit(AuthAuthenticated(user));
    } catch (e) { emit(AuthError(_getErrorMessage(e))); }
  }

  Future<void> _onUpdateProfileRequested(UpdateProfileRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.updateProfile(event.user);
      await _handleSocketInit();
      emit(AuthAuthenticated(user));
    } catch (e) { emit(AuthError(_getErrorMessage(e))); }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onRequestWhatsAppOtp(RequestWhatsAppOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.requestWhatsAppOTP(event.phoneNumber);
      emit(OtpSentState(event.phoneNumber));
    } catch (e) { emit(AuthError(_getErrorMessage(e))); }
  }

  Future<void> _onVerifyNinRequested(VerifyNinRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.verifyDriverNIN(event.nin);
      emit(NinVerified());
    } catch (e) { emit(AuthError(_getErrorMessage(e))); }
  }
}