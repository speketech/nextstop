import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/app_colors.dart';

class ManifestScreen extends StatefulWidget {
  const ManifestScreen({super.key});

  @override
  State<ManifestScreen> createState() => _ManifestScreenState();
}

class _ManifestStop {
  final String title;
  final String address;
  final bool isPickup;
  bool isCheckedIn;

  _ManifestStop({
    required this.title,
    required this.address,
    required this.isPickup,
    this.isCheckedIn = false,
  });
}

class _ManifestScreenState extends State<ManifestScreen> {
  final List<_ManifestStop> _stops = [
    _ManifestStop(title: 'Seyi (Initiator)', address: 'Lekki Phase 1 Gate', isPickup: true, isCheckedIn: true),
    _ManifestStop(title: 'Chidi (Joiner)', address: 'Ikate Elegushi Junction', isPickup: true),
    _ManifestStop(title: 'Chidi – Drop Off', address: 'Victoria Island (Ademola Adetokunbo)', isPickup: false),
    _ManifestStop(title: 'Seyi – Drop Off', address: 'Victoria Island (Ahmadu Bello)', isPickup: false),
  ];

  int get _checkedInCount => _stops.where((s) => s.isPickup && s.isCheckedIn).length;
  int get _totalPickups => _stops.where((s) => s.isPickup).length;

  void _checkIn(int index) {
    setState(() => _stops[index].isCheckedIn = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_stops[index].title} checked in!',
            style: GoogleFonts.roboto(color: AppColors.professionalWhite)),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.professionalWhite,
      appBar: AppBar(
        backgroundColor: AppColors.professionalWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.corporateSlate),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ride Manifest',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.corporateSlate, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Summary Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.corporateSlate,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statWidget('$_checkedInCount/$_totalPickups', 'Checked In', AppColors.secondary),
                Container(width: 1, height: 40, color: AppColors.professionalWhite.withOpacity(0.2)),
                _statWidget('${_stops.length - _totalPickups}', 'Drop Offs', AppColors.primary),
                Container(width: 1, height: 40, color: AppColors.professionalWhite.withOpacity(0.2)),
                _statWidget('15 min', 'ETA', AppColors.professionalWhite),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _checkedInCount / _totalPickups,
                backgroundColor: AppColors.subtleGrey,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Vertical Timeline
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _stops.length,
              itemBuilder: (context, index) {
                final stop = _stops[index];
                final isLast = index == _stops.length - 1;
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline column
                      SizedBox(
                        width: 36,
                        child: Column(
                          children: [
                            // Dot
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: stop.isCheckedIn
                                    ? AppColors.primary
                                    : (stop.isPickup ? AppColors.secondary : AppColors.primary), // Yellow for pickup, blue for dropoff
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.professionalWhite, width: 2),
                                boxShadow: [BoxShadow(color: (stop.isPickup ? AppColors.secondary : AppColors.primary).withOpacity(0.3), blurRadius: 6)],
                              ),
                            ),
                            // Vertical line
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: AppColors.subtleGrey,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Stop Card
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: stop.isCheckedIn
                                ? AppColors.primary.withOpacity(0.05)
                                : AppColors.professionalWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: stop.isCheckedIn ? AppColors.primary : AppColors.subtleGrey,
                              width: stop.isCheckedIn ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: stop.isPickup
                                                ? AppColors.secondary.withOpacity(0.15)
                                                : AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            stop.isPickup ? 'PICK-UP' : 'DROP-OFF',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: stop.isPickup ? AppColors.corporateSlate : AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (stop.isCheckedIn)
                                          const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      stop.title,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.corporateSlate,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      stop.address,
                                      style: GoogleFonts.roboto(color: AppColors.textSubtleDark, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              // QR Scan button (only for uninitiated pickups)
                              if (stop.isPickup && !stop.isCheckedIn)
                                ElevatedButton(
                                  onPressed: () => _checkIn(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 0,
                                    minimumSize: Size.zero,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.qr_code_scanner, color: Colors.white, size: 16),
                                      const SizedBox(width: 4),
                                      Text('Scan', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Starting ride manifest navigation... Drive safely!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              'Start Ride',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.professionalWhite),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statWidget(String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 20, color: valueColor)),
        Text(label, style: GoogleFonts.roboto(color: AppColors.professionalWhite.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
