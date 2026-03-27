import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:isw_mobile_sdk/isw_mobile_sdk.dart';
import 'package:isw_mobile_sdk/models/isw_mobile_sdk_payment_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_colors.dart';
import '../../../home/presentation/pages/route_channel_screen.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';


class ActiveRideScreen extends StatefulWidget {
  const ActiveRideScreen({super.key});

  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  bool _isSosActive = false;
  bool _isPanelExpanded = false;

  void _triggerSos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency SOS'),
        content: const Text('Are you sure you want to send an SOS alert with your live location to emergency contacts and authorities?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isSosActive = true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment via SDK is only available on Mobile. Web support coming soon!'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    final tripBloc = context.read<TripBloc>();
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    if (authState is AuthAuthenticated) {
      tripBloc.add(ProcessPayment(
        rideId: "ride_123", // Should be dynamic
        payerType: "INITIATOR",
        customerName: authState.user.fullName,
        customerEmail: authState.user.email,
        customerId: authState.user.id,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
        if (state is TripLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );
        } else if (state is PaymentSuccess) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment Verified! Let\'s go!'),
              backgroundColor: AppColors.primary,
            ),
          );
        } else if (state is TripError) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment Error: ${state.message}'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: AppColors.professionalWhite.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'En Route to Dropoff',
              style: GoogleFonts.inter(
                color: AppColors.corporateSlate,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            const SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                value: 0.6,
                backgroundColor: AppColors.subtleGrey,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 4,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.corporateSlate),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sos, color: _isSosActive ? AppColors.danger : Colors.redAccent.withOpacity(0.7)),
            onPressed: _triggerSos,
          )
        ],
      ),
      body: Stack(
        children: [
          const GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(6.45, 3.4), zoom: 14),
            zoomControlsEnabled: false,
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildTopicOfTheDayBanner(),
                const SizedBox(height: 12),
                _buildBottomPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicOfTheDayBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.professionalWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondary, width: 2), // Danfo Yellow border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Topic of the Day",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: AppColors.corporateSlate,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "What's the most impactful tech trend in Lagos right now?",
                    style: GoogleFonts.roboto(
                      color: AppColors.textSubtleDark,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteChannelScreen()));
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isPanelExpanded = !_isPanelExpanded;
                });
              },
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.subtleGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '15 mins to Dropoff',
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  Text(
                    '2.5 km • Route optimized',
                    style: GoogleFonts.roboto(color: AppColors.textSubtleDark),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.subtleGrey),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=33'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ahmed Tunji',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.corporateSlate),
                    ),
                    Text(
                      'Blue Toyota Camry • KJA 123 XY',
                      style: GoogleFonts.roboto(color: AppColors.textSubtleDark, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.secondary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '4.9',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.corporateSlate),
                  ),
                ],
              ),
            ],
          ),
          
          if (_isPanelExpanded) ...[
            const SizedBox(height: 24),
            Text(
              'Co-Riders (Professional Snapshot)',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.corporateSlate),
            ),
            const SizedBox(height: 12),
            _buildProfessionalSnapshot('Jane D.', 'Product Manager', 'Fintech', 'https://i.pravatar.cc/150?img=5'),
            const SizedBox(height: 8),
            _buildProfessionalSnapshot('Obi M.', 'Venture Capitalist', 'Tech Investments', 'https://i.pravatar.cc/150?img=11'),
          ],

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.professionalWhite,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Pay for Ride (₦1,000)',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfessionalSnapshot(String name, String title, String industry, String avatarUrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.professionalWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.subtleGrey, width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.corporateSlate, fontSize: 14),
                ),
                Text(
                  title,
                  style: GoogleFonts.roboto(color: AppColors.corporateSlate, fontSize: 13),
                ),
                Text(
                  industry,
                  style: GoogleFonts.roboto(color: AppColors.textSubtleDark, fontSize: 12, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.handshake_outlined, color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Connection Request sent to $name'), backgroundColor: AppColors.primary),
              );
            },
          ),
        ],
      ),
    );
  }
}
