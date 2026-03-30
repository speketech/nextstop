import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/app_colors.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';
import '../../data/models/trip_model.dart';
import 'active_ride_screen.dart'; // fallback navigation 

class VirtualSeatMapScreen extends StatefulWidget {
  final String rideId;
  const VirtualSeatMapScreen({super.key, required this.rideId});

  @override
  State<VirtualSeatMapScreen> createState() => _VirtualSeatMapScreenState();
}

class _VirtualSeatMapScreenState extends State<VirtualSeatMapScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TripBloc>().add(GetRideDetails(widget.rideId));
  }

  void _requestToJoin(TripModel trip) {
    context.read<TripBloc>().add(JoinRide(widget.rideId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Route Discovery Map', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textBody)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textBody),
      ),
      body: BlocConsumer<TripBloc, TripState>(
        listener: (context, state) {
           if (state is TripSuccess) {
              // Usually if it's a successful join, it'll transition to active ride screen
              // For demonstration we'll just show success
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Join request pending initiator approval!'), backgroundColor: AppColors.accent),
              );
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ActiveRideScreen()));
           } else if (state is TripError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
              );
           }
        },
        builder: (context, state) {
          if (state is TripLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          TripModel? trip;
          if (state is TripSuccess) {
             trip = state.trip;
          }

          // Fallback UI for rendering even without API connection for demonstration
          int totalSeats = 14; 
          int occupied = trip?.currentJoinersCount ?? 3;
          int available = (trip?.maxJoiners ?? totalSeats) - occupied;

          return SafeArea(
            child: Column(
              children: [
                // Top Info Card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.subtleGrey, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Initiator: Alex B.', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textBody)),
                                Text('Product Manager', style: GoogleFonts.roboto(color: AppColors.textSubtleDark, fontSize: 13)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Text('$available Seats Left', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // Map View
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.professionalWhite,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.textSubtle.withOpacity(0.5), width: 4),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Text('Danfo Standard Layout', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textSubtle)),
                        const SizedBox(height: 24),
                        // Basic 14-seater representation mock
                        Expanded(
                           child: _buildDanfoSeatsGrid(occupied, totalSeats),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Panel
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Estimated Split Fare', style: GoogleFonts.roboto(color: AppColors.textSubtleDark, fontSize: 14)),
                          Text('₦${trip != null ? (trip.proposedFare / (trip.currentJoinersCount + 1)).toStringAsFixed(0) : '850'}', 
                               style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.corporateSlate)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: trip != null ? () => _requestToJoin(trip!) : null,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: Text('Request to Join', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDanfoSeatsGrid(int occupied, int totalSeats) {
    // A simple grid approximation of 3 - 3 - 4 layout (ignoring driver seat rows for joiners context)
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, 
        childAspectRatio: 1.0, 
        crossAxisSpacing: 16, 
        mainAxisSpacing: 24
      ),
      itemCount: 12, // Showing 12 passenger seats
      itemBuilder: (context, index) {
        bool isOccupied = index < occupied;
        
        return Container(
          decoration: BoxDecoration(
            color: isOccupied ? AppColors.subtleGrey : AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOccupied ? AppColors.textSubtle : AppColors.primary,
              width: isOccupied ? 1 : 2,
            ),
          ),
          child: isOccupied 
            ? const Center(
                child: CircleAvatar(
                   radius: 14,
                   backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
                ),
              )
            : const Center(
                child: Icon(Icons.event_seat, color: AppColors.primary),
              ),
        );
      },
    );
  }
}
