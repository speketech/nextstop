import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nextstop/features/auth/domain/models/user_model.dart';
import '../../../../core/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'otp_verification_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool isLogin;
  const AuthScreen({super.key, this.isLogin = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLogin;
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedRole = 'passenger'; // DB stores lowercase

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() => setState(() => _isLogin = !_isLogin);

  void _submit() {
    if (_isLogin) {
      if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
        context.read<AuthBloc>().add(LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter email and password')),
        );
      }
    } else {
      if (_emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty) {
        context.read<AuthBloc>().add(RegisterRequested(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole, // already lowercase
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSentState) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => OtpVerificationScreen(emailOrPhone: state.emailOrPhone)),
          );
        } else if (state is AuthAuthenticated) {
          if (state.user.role == UserRole.driver) {
            Navigator.pushReplacementNamed(context, '/driver_dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.professionalWhite,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.corporateSlate),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isLogin ? 'Welcome Back.' : 'Join NextStop.',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.corporateSlate,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin ? 'Log in to your professional account.' : 'Create your account in seconds.',
                    style: GoogleFonts.roboto(fontSize: 16, color: AppColors.textSubtleDark),
                  ),
                  const SizedBox(height: 32),

                  // LinkedIn prioritized (spec calls for premium overlay)
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0077b5), Color(0xFF005983)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFF0077b5).withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(FontAwesomeIcons.linkedin, color: Colors.white, size: 20),
                      label: Text(
                        'Continue with LinkedIn',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.subtleGrey)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'or continue with email',
                          style: GoogleFonts.roboto(color: AppColors.textSubtleDark, fontSize: 13),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.subtleGrey)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // First & Last Name fields (only for Sign Up)
                  if (!_isLogin) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _firstNameController,
                            style: GoogleFonts.roboto(color: AppColors.corporateSlate, fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              labelStyle: GoogleFonts.roboto(color: AppColors.textSubtleDark),
                              prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSubtleDark),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _lastNameController,
                            style: GoogleFonts.roboto(color: AppColors.corporateSlate, fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              labelStyle: GoogleFonts.roboto(color: AppColors.textSubtleDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email field
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.roboto(color: AppColors.corporateSlate, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.roboto(color: AppColors.textSubtleDark),
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSubtleDark),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (!_isLogin) ...[
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.roboto(color: AppColors.corporateSlate, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: GoogleFonts.roboto(color: AppColors.textSubtleDark),
                        prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textSubtleDark),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Role Selection — DB stores lowercase ('passenger' | 'driver')
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Passenger'),
                            selected: _selectedRole == 'passenger',
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedRole = 'passenger');
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('Driver'),
                            selected: _selectedRole == 'driver',
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedRole = 'driver');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.roboto(color: AppColors.corporateSlate, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: GoogleFonts.roboto(color: AppColors.textSubtleDark),
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSubtleDark),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSubtleDark,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),

                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text('Forgot Password?', style: GoogleFonts.roboto(color: AppColors.primary, fontWeight: FontWeight.w500)),
                      ),
                    )
                  else
                    const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: state is AuthLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: state is AuthLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            _isLogin ? 'Log In' : 'Sign Up',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.professionalWhite),
                          ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(FontAwesomeIcons.google, size: 16),
                          label: Text('Google', style: GoogleFonts.roboto(color: AppColors.corporateSlate)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.subtleGrey),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(FontAwesomeIcons.apple, size: 16, color: AppColors.corporateSlate),
                          label: Text('Apple', style: GoogleFonts.roboto(color: AppColors.corporateSlate)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.subtleGrey),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin ? "Don't have an account?" : "Already have an account?",
                        style: GoogleFonts.roboto(color: AppColors.textSubtleDark),
                      ),
                      TextButton(
                        onPressed: _toggleAuthMode,
                        child: Text(
                          _isLogin ? 'Sign Up' : 'Log In',
                          style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
