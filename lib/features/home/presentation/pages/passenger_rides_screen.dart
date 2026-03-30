import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/app_colors.dart';

class PassengerRidesScreen extends StatelessWidget {
  const PassengerRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Rides', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textBody)),
          backgroundColor: AppColors.background,
          elevation: 0,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSubtle,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUpcomingTrips(),
            _buildPastTrips(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTrips() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined, size: 64, color: AppColors.textSubtle.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No upcoming rides',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSubtleDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Book a ride to see it here.',
            style: GoogleFonts.roboto(color: AppColors.textSubtle),
          ),
        ],
      ),
    );
  }

  Widget _buildPastTrips() {
    // Placeholder past rides list
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.subtleGrey, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Yesterday, 5:30 PM', style: GoogleFonts.roboto(color: AppColors.textSubtleDark)),
                    Text('₦1,500', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textBody)),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.circle, color: AppColors.primary, size: 10),
                    SizedBox(width: 8),
                    Text('Victoria Island', style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  height: 16,
                  width: 2,
                  color: AppColors.subtleGrey,
                ),
                const Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.danger, size: 14),
                    SizedBox(width: 6),
                    Text('Lekki Phase 1', style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.secondary, size: 16),
                    const SizedBox(width: 4),
                    Text('5.0', style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text('Completed', style: GoogleFonts.roboto(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
