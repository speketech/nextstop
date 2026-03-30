import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/app_colors.dart';
import 'fare_negotiation_screen.dart';

class RideBookingScreen extends StatefulWidget {
  const RideBookingScreen({super.key});

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  bool _isRideShare = true;
  int _joinersCount = 1;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(6.4281, 3.4219), // Victoria Island, Lagos
    zoom: 13.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('New Ride', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBody)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textBody),
      ),
      body: Stack(
        children: [
          // Background Map Placeholder
          const GoogleMap(
            initialCameraPosition: _initialPosition,
            zoomControlsEnabled: false,
            myLocationEnabled: false, // Disabled to prevent main thread UI freezes/timeouts without permissions
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Search Bars (Pick up & Drop off)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, color: AppColors.primary, size: 16),
                            SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Current Location',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  fillColor: Colors.transparent,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 16),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: AppColors.danger, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Where to?',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  fillColor: Colors.transparent,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom Panel for Ride Details
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ride Preference', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              const Text('Alone'),
                              Switch(
                                value: _isRideShare,
                                onChanged: (val) => setState(() => _isRideShare = val),
                                activeThumbColor: AppColors.primary,
                              ),
                              const Text('Share'),
                            ],
                          )
                        ],
                      ),
                      
                      if (_isRideShare) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Available Seats (Joiners)'),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.textSubtle),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: _joinersCount > 1 ? () => setState(() => _joinersCount--) : null,
                                  ),
                                  Text('$_joinersCount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: _joinersCount < 3 ? () => setState(() => _joinersCount++) : null,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Sharing splits the cost and lets you network. You have selected 1 initiator + $_joinersCount joiner(s).', style: const TextStyle(color: AppColors.textSubtle, fontSize: 12)),
                      ],

                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const FareNegotiationScreen()));
                        },
                        child: const Text('Confirm Route'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
