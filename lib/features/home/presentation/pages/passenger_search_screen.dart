import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/app_colors.dart';
import '../../../trips/presentation/pages/ride_booking_screen.dart';

class PassengerSearchScreen extends StatefulWidget {
  const PassengerSearchScreen({super.key});

  @override
  State<PassengerSearchScreen> createState() => _PassengerSearchScreenState();
}

class _PassengerSearchScreenState extends State<PassengerSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _recentLocations = [
    {'name': 'Lekki Phase 1', 'address': 'Admiralty Way, Lekki'},
    {'name': 'Victoria Island', 'address': 'Adeola Odeku St, VI'},
    {'name': 'Ikeja City Mall', 'address': 'Obafemi Awolowo Way, Ikeja'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Search Route', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textBody)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textBody),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Where to, professional?',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSubtle),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textSubtleDark),
                    onPressed: () => _searchController.clear(),
                  ),
                  filled: true,
                  fillColor: AppColors.professionalWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Recent & Saved Locations',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSubtleDark),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _recentLocations.length,
                  separatorBuilder: (context, index) => const Divider(color: AppColors.subtleGrey),
                  itemBuilder: (context, index) {
                    final loc = _recentLocations[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.subtleGrey,
                        child: Icon(Icons.location_on, color: AppColors.corporateSlate, size: 20),
                      ),
                      title: Text(loc['name']!, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textBody)),
                      subtitle: Text(loc['address']!, style: GoogleFonts.roboto(color: AppColors.textSubtleDark)),
                      onTap: () {
                        // Action on tap, like selecting this route for booking
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const RideBookingScreen()));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
