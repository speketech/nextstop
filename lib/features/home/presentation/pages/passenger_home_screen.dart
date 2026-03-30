import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/app_colors.dart';
import '../../../trips/presentation/pages/ride_booking_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'passenger_search_screen.dart';
import 'passenger_rides_screen.dart';
import 'passenger_profile_screen.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  int _selectedIndex = 0;
  bool _isRideShare = true; 

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(6.5244, 3.3792), // Lagos, Nigeria
    zoom: 12.0,
  );

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Stack(
            children: [
              // Background Map Placeholder
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFE0E0E0), // Fallback if map fails
                  child: const GoogleMap(
                    initialCameraPosition: _initialPosition,
                    zoomControlsEnabled: false,
                    myLocationEnabled: false, // Disabled to prevent main thread UI freezes/timeouts without permissions
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                  ),
                ),
              ),
              
              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(),
                    const Spacer(),
                    _buildBookingCard(),
                  ],
                ),
              ),
            ],
          ),
          const PassengerSearchScreen(),
          const PassengerRidesScreen(),
          const PassengerProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Profile Avatar
          GestureDetector(
             onTap: () {
                 // Open profile drawer or modal
             },
             child: Stack(
               children: [
                 const CircleAvatar(
                   radius: 20,
                   backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                 ),
                 Positioned(
                   bottom: 0,
                   right: 0,
                   child: Container(
                     padding: const EdgeInsets.all(2),
                     decoration: const BoxDecoration(
                       color: AppColors.professionalWhite,
                       shape: BoxShape.circle,
                     ),
                     child: const Icon(Icons.star, color: AppColors.secondary, size: 10),
                   ),
                 ),
               ],
             ),
          ),
          const SizedBox(width: 12),
          // Search Bar
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.corporateSlate, Color(0xFF4A6278)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search, color: AppColors.professionalWhite, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Where to, professional?',
                    style: GoogleFonts.roboto(
                      color: AppColors.professionalWhite.withOpacity(0.8),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.subtleGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ride Option',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.corporateSlate),
          ),
          const SizedBox(height: 16),
          // Segmented Control / Carousel
          Row(
            children: [
              Expanded(
                child: _buildRideOptionCard(
                  title: 'Ride Alone',
                  icon: Icons.directions_car,
                  isSelected: !_isRideShare,
                  onTap: () => setState(() => _isRideShare = false),
                  price: '₦2,500',
                  eta: '5 mins',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRideOptionCard(
                  title: 'Ride Share',
                  icon: Icons.groups,
                  isSelected: _isRideShare,
                  onTap: () => setState(() => _isRideShare = true),
                  price: '₦1,000',
                  eta: '8 mins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isRideShare)
            Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Connect with professionals on your route.',
                    style: GoogleFonts.roboto(color: AppColors.textSubtleDark, fontSize: 13),
                  ),
                ),
              ],
            ),
          if (_isRideShare) const SizedBox(height: 16),
          // CTA Button
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RideBookingScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Book My Ride',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.professionalWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideOptionCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required String price,
    required String eta,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.subtleGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.corporateSlate, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.corporateSlate,
                fontSize: 14,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Text(
                price,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: AppColors.corporateSlate, // Spec requests accent for amount, modifying below
                  fontSize: 16,
                ),
              ),
              Text(
                eta,
                style: GoogleFonts.roboto(
                  color: AppColors.textSubtleDark,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSubtleDark,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      elevation: 10,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Rides'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
