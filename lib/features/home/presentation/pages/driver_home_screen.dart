import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/app_colors.dart';
import 'manifest_screen.dart';
import 'payment_transparency_screen.dart';
import 'professional_snapshot_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool _isOnline = false;
  int _selectedIndex = 0;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(6.5244, 3.3792),
    zoom: 12.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Driver Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Row(
            children: [
              Text(_isOnline ? 'Online' : 'Offline', style: const TextStyle(fontWeight: FontWeight.bold)),
              Switch(
                value: _isOnline,
                onChanged: (val) => setState(() => _isOnline = val),
                activeThumbColor: AppColors.accent,
              ),
            ],
          )
        ],
      ),
      body: Stack(
        children: [
          const GoogleMap(
            initialCameraPosition: _initialPosition,
            zoomControlsEnabled: false,
            myLocationEnabled: false, // Disabled to prevent main thread UI freezes/timeouts without permissions
            myLocationButtonEnabled: false,
            // Assuming we'd add polygons/heatmaps for "High-Value Professional Zones" here
          ),

          if (!_isOnline)
            Container(color: Colors.black45), // Dim screen if offline

          SafeArea(
            child: Column(
              children: [
                // Earnings Summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Today\'s Earnings', style: TextStyle(color: AppColors.textSubtle)),
                            Text('₦15,400', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                        IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 16), onPressed: (){})
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Active Ride / Incoming Request
                if (_isOnline)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildMockActiveRequest(),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentTransparencyScreen()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalSnapshotScreen()));
          }
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSubtle,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildMockActiveRequest() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('New Ride Request!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(12)),
                  child: const Text('High Value', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.circle, color: AppColors.primary, size: 12),
                SizedBox(width: 8),
                Text('Lekki Phase 1', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Container(margin: const EdgeInsets.only(left: 5), height: 20, width: 2, color: AppColors.textSubtle),
            const Row(
              children: [
                Icon(Icons.location_on, color: AppColors.danger, size: 16),
                SizedBox(width: 4),
                Text('Victoria Island', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fare Offer', style: TextStyle(color: AppColors.textSubtle)),
                Text('₦2,500', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.accent)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ManifestScreen()));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
