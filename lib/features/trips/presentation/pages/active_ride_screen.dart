import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_colors.dart';
import '../../../home/presentation/pages/route_channel_screen.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_state.dart';
import 'ride_summary_screen.dart';
import '../../data/models/trip_model.dart';

class ActiveRideScreen extends StatefulWidget {
  final TripModel? trip;
  const ActiveRideScreen({super.key, this.trip});

  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  bool _isPanelExpanded = false;

  // Mock co-riders for UI demonstration
  final List<Map<String, String>> _coRiders = [
    {'name': 'Amara O.', 'title': 'Product Designer', 'company': 'Flutterwave', 'avatar': 'https://i.pravatar.cc/150?img=5'},
    {'name': 'Emeka N.', 'title': 'Backend Engineer', 'company': 'Paystack', 'avatar': 'https://i.pravatar.cc/150?img=7'},
  ];

  static const CameraPosition _ridePosition = CameraPosition(
    target: LatLng(6.4631, 3.3992), // Between Lekki and VI
    zoom: 14.0,
  );

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
        if (state is TripSuccess && state.trip.status == RideStatus.completed) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => RideSummaryScreen(trip: state.trip)),
          );
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: AppColors.professionalWhite.withValues(alpha: 0.92),
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                'En Route',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textBody, fontSize: 16),
              ),
            ],
          ),
          actions: [
            // SOS Button
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ElevatedButton(
                onPressed: () => _showSoSDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  minimumSize: const Size(48, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('SOS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Map — only rendered on non-web platforms using conditional
            _buildMap(),

            // Bottom sliding panel
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomPanel(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    if (kIsWeb) {
      // google_maps_flutter_web renders using HtmlElementView
      return const GoogleMap(
        initialCameraPosition: _ridePosition,
        zoomControlsEnabled: false,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
      );
    }
    return const GoogleMap(
      initialCameraPosition: _ridePosition,
      zoomControlsEnabled: false,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isPanelExpanded = !_isPanelExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.subtleGrey, borderRadius: BorderRadius.circular(2)),
            ),

            // Progress & ETA  
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ETA: 12 mins', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textBody)),
                      Text('Victoria Island', style: GoogleFonts.roboto(color: AppColors.textSubtleDark, fontSize: 13)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteChannelScreen())),
                  ),
                ],
              ),
            ),

            // Linear progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 0.45,
                  backgroundColor: AppColors.subtleGrey,
                  color: AppColors.primary,
                  minHeight: 6,
                ),
              ),
            ),

            // Expanded: Co-Rider Snapshots + Topic of the Day
            if (_isPanelExpanded) ...[
              const Divider(color: AppColors.subtleGrey, height: 1),
              _buildCoRiderSection(),
              _buildTopicOfTheDay(context),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCoRiderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Co-Riders', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textSubtleDark)),
          const SizedBox(height: 12),
          ..._coRiders.map((rider) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                CircleAvatar(radius: 22, backgroundImage: NetworkImage(rider['avatar']!)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rider['name']!, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textBody)),
                      Text('${rider['title']} · ${rider['company']}', style: GoogleFonts.roboto(color: AppColors.textSubtleDark, fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    minimumSize: const Size(70, 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Connect', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTopicOfTheDay(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.secondary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Topic of the Day', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.corporateSlate)),
                const SizedBox(height: 4),
                Text('How is AI reshaping fintech in West Africa?', style: GoogleFonts.roboto(fontSize: 12, color: AppColors.textSubtleDark)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: AppColors.corporateSlate, size: 20),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteChannelScreen())),
          ),
        ],
      ),
    );
  }

  void _showSoSDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Emergency SOS'),
        content: const Text('This will notify emergency services and your trusted contacts. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('SEND SOS'),
          ),
        ],
      ),
    );
  }
}