import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';
import '../../data/models/trip_model.dart';

class RideSummaryScreen extends StatefulWidget {
  final TripModel trip;

  const RideSummaryScreen({super.key, required this.trip});

  @override
  State<RideSummaryScreen> createState() => _RideSummaryScreenState();
}

class _RideSummaryScreenState extends State<RideSummaryScreen> {
  int _driverRating = 5;

  void _processPayment() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      context.read<TripBloc>().add(ProcessPayment(
        rideId: widget.trip.id,
        payerType: 'passenger', // Hardcoded as per flow
        customerName: '${user.firstName} ${user.lastName}',
        customerEmail: user.email,
        customerId: user.id,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Estimating split fare if it's a shared ride and no final_fare is set
    final fare = widget.trip.finalFare ?? 
                 (widget.trip.rideType == RideType.ride_share && widget.trip.currentJoinersCount > 0 
                  ? (widget.trip.proposedFare / (widget.trip.currentJoinersCount + 1)) 
                  : widget.trip.proposedFare);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Ride Summary', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textBody)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Don't let user easily go back without paying/completing
      ),
      body: BlocConsumer<TripBloc, TripState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text('Payment Successful!'), backgroundColor: AppColors.accent),
            );
            Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
          } else if (state is TripError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Fare Display
                  Center(
                    child: Column(
                      children: [
                        Text('Total Amount', style: GoogleFonts.roboto(color: AppColors.textSubtleDark, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          '₦${fare.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 48, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Route Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.subtleGrey, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Route Summary', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.corporateSlate)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.circle, color: AppColors.primary, size: 12),
                              const SizedBox(width: 12),
                              Expanded(child: Text(widget.trip.pickupAddress, style: GoogleFonts.roboto(fontWeight: FontWeight.w500))),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 5),
                            height: 24,
                            width: 2,
                            color: AppColors.subtleGrey,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: AppColors.danger, size: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text(widget.trip.dropoffAddress, style: GoogleFonts.roboto(fontWeight: FontWeight.w500))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rating Section
                  Center(
                    child: Text('How was your trip with the driver?', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textBody)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _driverRating ? Icons.star : Icons.star_border,
                          color: AppColors.secondary,
                          size: 40,
                        ),
                        onPressed: () {
                          setState(() {
                            _driverRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  
                  if (widget.trip.rideType == RideType.ride_share) ...[
                     const SizedBox(height: 24),
                     Center(
                       child: Text('Rate your co-riders (Networking)', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textBody)),
                     ),
                     const SizedBox(height: 16),
                     Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: const Icon(Icons.star_border, color: AppColors.textSubtle, size: 32),
                            onPressed: () {},
                          );
                        }),
                      ),
                  ],

                  const SizedBox(height: 48),

                  // Pay Now Button
                  ElevatedButton(
                    onPressed: (state is TripLoading) ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary, // Danfo Yellow CTA
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: (state is TripLoading)
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: AppColors.professionalWhite))
                        : Text(
                            'Pay Now',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.professionalWhite),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
