import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/presentation/pages/auth_screen.dart';

class PassengerProfileScreen extends StatelessWidget {
  const PassengerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        UserModel? user;
        if (state is AuthAuthenticated) {
          user = state.user;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Profile', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textBody)),
            backgroundColor: AppColors.background,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.danger),
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          body: user == null 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _buildProfileContent(context, user),
        );
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, UserModel user) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Profile Header
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                  ),
                  if (user.ninVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.professionalWhite,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, color: AppColors.primary, size: 24),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${user.firstName} ${user.lastName}',
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textBody),
              ),
              Text(
                'Software Engineer at TechCorp', // Mocked professional snapshot
                style: GoogleFonts.roboto(fontSize: 14, color: AppColors.textSubtleDark),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Settings Sections
        Text('ACCOUNT', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSubtleDark, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        _buildListTile(context: context, icon: Icons.person_outline, title: 'Personal Information'),
        _buildListTile(context: context, icon: Icons.work_outline, title: 'Professional Identity'),
        _buildListTile(context: context, icon: Icons.shield_outlined, title: 'Verification & Safety'),

        const SizedBox(height: 24),
        Text('COMMUTE', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSubtleDark, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        _buildListTile(context: context, icon: Icons.favorite_border, title: 'Saved Routes'),
        _buildListTile(
          context: context,
          icon: Icons.directions_car_outlined,
          title: 'Commute Preferences',
          subtitle: 'Enable recurring commute',
        ),

        const SizedBox(height: 24),
        Text('SUPPORT', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSubtleDark, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        _buildListTile(context: context, icon: Icons.help_outline, title: 'Help Center'),
        _buildListTile(context: context, icon: Icons.info_outline, title: 'About NextStop'),
      ],
    );
  }

  Widget _buildListTile({required BuildContext context, required IconData icon, required String title, String? subtitle}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.subtleGrey, width: 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.corporateSlate),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: AppColors.textBody)),
        subtitle: subtitle != null ? Text(subtitle, style: GoogleFonts.roboto(color: AppColors.textSubtleDark)) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSubtleDark),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title details coming soon to your professional profile.')),
          );
        },
      ),
    );
  }
}
