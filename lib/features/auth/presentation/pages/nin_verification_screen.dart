import 'package:flutter/material.dart';
import '../../../../core/api/kyc_service.dart';
import '../../../../core/app_colors.dart';

class NinVerificationScreen extends StatefulWidget {
  const NinVerificationScreen({super.key});

  @override
  State<NinVerificationScreen> createState() => _NinVerificationScreenState();
}

class _NinVerificationScreenState extends State<NinVerificationScreen> {
  final TextEditingController _ninController = TextEditingController();
  final KycService _kycService = KycService();
  bool _isLoading = false;

  void _submitNIN() async {
    final nin = _ninController.text.trim();
    if (nin.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NIN must be exactly 11 digits')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Call the backend service
    final errorMessage = await _kycService.verifyNIN(nin);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (errorMessage == null) {
      // Success!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NIN Verified! You earned the Verified badge.'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to the next step (e.g., Vehicle Registration or Driver Dashboard)
      Navigator.pushReplacementNamed(context, '/driver_dashboard');
    } else {
      // Show Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.professionalWhite,
      appBar: AppBar(
        title: const Text('Driver Verification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.corporateSlate),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your NIN',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: AppColors.corporateSlate,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We use Interswitch to securely verify your identity with the NIMC database. This keeps our community safe.',
              style: TextStyle(color: AppColors.textSubtleDark, fontSize: 16),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _ninController,
              keyboardType: TextInputType.number,
              maxLength: 11,
              style: const TextStyle(color: AppColors.corporateSlate),
              decoration: InputDecoration(
                labelText: 'National Identity Number (NIN)',
                labelStyle: const TextStyle(color: AppColors.textSubtleDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.badge, color: AppColors.textSubtleDark),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitNIN,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Verify Identity', 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
