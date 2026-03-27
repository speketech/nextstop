import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/app_colors.dart';
import 'active_ride_screen.dart';

class FareNegotiationScreen extends StatefulWidget {
  const FareNegotiationScreen({super.key});

  @override
  State<FareNegotiationScreen> createState() => _FareNegotiationScreenState();
}

class _FareNegotiationScreenState extends State<FareNegotiationScreen> {
  double _proposedFare = 2000;
  final double _estimatedFareMin = 1800;
  final double _estimatedFareMax = 2500;

  String get _fairnessLabel {
    if (_proposedFare < _estimatedFareMin) return '⚠️ Below average — Match speed is low';
    if (_proposedFare > _estimatedFareMax) return '🚀 Premium offer — Fastest match!';
    return '✅ This fare is near average for this route';
  }

  Color get _sliderAccent {
    if (_proposedFare < _estimatedFareMin) return AppColors.danger;
    if (_proposedFare > _estimatedFareMax) return AppColors.accent;
    return AppColors.primary;
  }

  double get _fairnessMeterValue {
    final range = _estimatedFareMax - _estimatedFareMin;
    return ((_proposedFare - _estimatedFareMin) / range).clamp(0.0, 1.0);
  }

  void _showTransparencySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: AppColors.professionalWhite,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fare Breakdown', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.corporateSlate)),
              const SizedBox(height: 16),
              _breakdownRow('Estimated Fuel Cost', '₦800'),
              _breakdownRow('Vehicle Wear & Tear', '₦400'),
              _breakdownRow('Platform Fee', '₦150'),
              _breakdownRow('Driver Base Earnings', '₦650'),
              const Divider(height: 32, color: AppColors.subtleGrey),
              _breakdownRow('Total Estimate', '₦2,000', isTotal: true),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text('Got it', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.professionalWhite)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _breakdownRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.roboto(fontSize: isTotal ? 17 : 15, fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400, color: AppColors.corporateSlate)),
          Text(amount, style: GoogleFonts.inter(fontSize: isTotal ? 17 : 15, fontWeight: FontWeight.w700, color: isTotal ? AppColors.primary : AppColors.corporateSlate)),
        ],
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
        title: Text('Negotiate Fare', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.corporateSlate, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.primary),
            onPressed: _showTransparencySheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display Area
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.corporateSlate, Color(0xFF3B5068)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text('Estimated Range', style: GoogleFonts.roboto(color: AppColors.professionalWhite.withOpacity(0.7), fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '₦${_estimatedFareMin.toInt()} – ₦${_estimatedFareMax.toInt()}',
                      style: GoogleFonts.inter(color: AppColors.professionalWhite, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Text('Your Proposed Fare', style: GoogleFonts.roboto(color: AppColors.professionalWhite.withOpacity(0.7), fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '₦${_proposedFare.toInt()}',
                      style: GoogleFonts.inter(
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary, // Danfo Yellow amount accent per spec
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Fairness Meter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Budget', style: GoogleFonts.roboto(fontSize: 12, color: AppColors.textSubtleDark)),
                  Text('Premium', style: GoogleFonts.roboto(fontSize: 12, color: AppColors.textSubtleDark)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _fairnessMeterValue,
                  minHeight: 8,
                  backgroundColor: AppColors.subtleGrey,
                  valueColor: AlwaysStoppedAnimation<Color>(_sliderAccent),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _fairnessLabel,
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(fontSize: 13, color: _sliderAccent, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),

              // Custom Slider – Corporate Slate track, Danfo Yellow thumb
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.subtleGrey,
                  thumbColor: AppColors.secondary, // Danfo Yellow handle per spec
                  overlayColor: AppColors.secondary.withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                ),
                child: Slider(
                  value: _proposedFare,
                  min: 1000,
                  max: 4000,
                  divisions: 30,
                  label: '₦${_proposedFare.toInt()}',
                  onChanged: (value) => setState(() => _proposedFare = value),
                ),
              ),

              const SizedBox(height: 24),

              // Section Header
              Text(
                'Live Offers from Drivers',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.corporateSlate),
              ),
              const SizedBox(height: 12),

              // Driver Counter-Offer Cards – "Incoming Call" style
              Expanded(
                child: ListView.builder(
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    final offerAmount = (_proposedFare + (index * 200) + 100).toInt();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.professionalWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.subtleGrey),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${index + 20}'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Driver ${index == 0 ? 'Emeka' : 'Yusuf'}',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.corporateSlate),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: AppColors.secondary, size: 14),
                                    Text(
                                      ' ${4.7 + index * 0.2}',
                                      style: GoogleFonts.roboto(fontSize: 13, color: AppColors.textSubtleDark),
                                    ),
                                  ],
                                ),
                                Text(
                                  '₦$offerAmount',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveRideScreen())),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary, // Danfo Yellow Accept per spec
                                  foregroundColor: AppColors.professionalWhite,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                child: Text('Accept', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Counter',
                                  style: GoogleFonts.roboto(color: AppColors.corporateSlate, fontWeight: FontWeight.w500, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveRideScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text('Propose Fare', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.professionalWhite)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
