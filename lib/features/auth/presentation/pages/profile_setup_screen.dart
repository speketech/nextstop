import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../domain/models/user_model.dart';
import '../../../home/presentation/pages/passenger_home_screen.dart';
import '../../../home/presentation/pages/driver_home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  bool _isDriver = false;
  int _currentStep = 0;
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onStepContinue() {
    if (_isDriver) {
      if (_currentStep < 3) {
        setState(() => _currentStep += 1);
      } else {
        _submitProfile();
      }
    } else {
      if (_currentStep < 2) {
        setState(() => _currentStep += 1);
      } else {
        _submitProfile();
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _submitProfile() {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : state.user.firstName;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : state.user.lastName;

      final updatedUser = UserModel(
        id: state.user.id,
        phone: state.user.phone,
        firstName: firstName,
        lastName: lastName,
        email: state.user.email,
        role: _isDriver ? UserRole.driver : UserRole.passenger,
        ninVerified: true,
      );
      context.read<AuthBloc>().add(UpdateProfileRequested(updatedUser));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && state.user.ninVerified) {
          // If profile is "completed" (verified in our mock), go to home
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => state.user.role == UserRole.driver 
                  ? const DriverHomeScreen() 
                  : const PassengerHomeScreen(),
            ),
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return Column(
                children: [
                  // User Type Toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.textSubtle),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isDriver = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !_isDriver ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Passenger',
                                  style: TextStyle(
                                    color: !_isDriver ? Colors.white : AppColors.textBody,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isDriver = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _isDriver ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Driver',
                                  style: TextStyle(
                                    color: _isDriver ? Colors.white : AppColors.textBody,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
                      ),
                      child: Stepper(
                        type: StepperType.vertical,
                        currentStep: _currentStep,
                        onStepContinue: _onStepContinue,
                        onStepCancel: _onStepCancel,
                        steps: _isDriver ? _getDriverSteps() : _getPassengerSteps(),
                        controlsBuilder: (BuildContext context, ControlsDetails details) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 24.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: state is AuthLoading ? null : details.onStepContinue,
                                    child: state is AuthLoading 
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : Text((_isDriver ? _currentStep == 3 : _currentStep == 2) ? 'Submit' : 'Continue'),
                                  ),
                                ),
                                if (_currentStep > 0) ...[
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: details.onStepCancel,
                                      child: const Text('Back'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Step> _getPassengerSteps() {
    return [
      Step(
        title: const Text('Personal Info'),
        content: Column(
          children: [
            // Profile image placeholder
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.background,
              child: Icon(Icons.add_a_photo, size: 40, color: AppColors.textSubtle),
            ),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Job Title')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Company')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'LinkedIn URL (Optional)')),
          ],
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text('Commute & Safety'),
        content: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Preferred Commute Route (e.g., Lekki - VI)')),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Women-Only Ride Preference'),
                Switch(value: false, onChanged: (v){}, activeThumbColor: AppColors.primary),
              ],
            ),
          ],
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Text('Verification'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upload your National Identification Number (NIN) slip to receive a verified badge and build trust within the community.'),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload NIN Slip'),
            ),
          ],
        ),
        isActive: _currentStep >= 2,
      ),
    ];
  }

  List<Step> _getDriverSteps() {
    return [
      Step(
        title: const Text('Personal Info'),
        content: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.background,
              child: Icon(Icons.add_a_photo, size: 40, color: AppColors.textSubtle),
            ),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name')),
          ],
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text('Vehicle Info'),
        content: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Vehicle Make (e.g., Toyota)')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Vehicle Model (e.g., Camry)')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Year')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'License Plate')),
            const SizedBox(height: 16),
            // Comfort rating
            const Text('Vehicle Comfort Rating (1-5)'),
            Slider(value: 4, min: 1, max: 5, divisions: 4, label: '4', onChanged: (v){}),
          ],
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Text('Documents'),
        content: Column(
          children: [
            OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.upload), label: const Text('Driver\'s License')),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.upload), label: const Text('Vehicle Registration')),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.upload), label: const Text('Insurance')),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.upload), label: const Text('NIN Slip')),
          ],
        ),
        isActive: _currentStep >= 2,
      ),
      Step(
        title: const Text('Payouts'),
        content: const Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'Bank Name')),
            SizedBox(height: 16),
            TextField(decoration: InputDecoration(labelText: 'Account Number')),
          ],
        ),
        isActive: _currentStep >= 3,
      ),
    ];
  }
}
