import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class ProfessionalSnapshotScreen extends StatelessWidget {
  const ProfessionalSnapshotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: (){}),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cover Photo / Header
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: AppColors.premiumGradient,
              ),
            ),
            
            // Profile Content
            Transform.translate(
              offset: const Offset(0, -60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Avatar and CTA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.background,
                            child: Icon(Icons.person, size: 50, color: AppColors.primary),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Networking request sent to Seyi! We will notify you when they accept.')),
                            );
                          },
                          icon: const Icon(Icons.handshake),
                          label: const Text('Connect'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Name and Title
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Seyi Adebayo', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Senior Software Engineer at TechCo', style: TextStyle(fontSize: 16, color: AppColors.textSubtleDark, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 12),
                    
                    // Badges
                    Row(
                      children: [
                        _buildBadge(Icons.verified_user, 'NIN Verified', AppColors.accent),
                        const SizedBox(width: 8),
                        _buildBadge(Icons.star, 'Top Carpooler', AppColors.secondary),
                        const SizedBox(width: 8),
                        _buildBadge(Icons.link, 'LinkedIn', const Color(0xFF0077b5)),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // About
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('About', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Passionate software engineer building scalable systems for the African market. Always happy to chat about AI, FinTech, and product strategy during the commute.',
                      style: TextStyle(height: 1.5),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Interests
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Professional Interests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInterestChip('AI / ML'),
                        _buildInterestChip('FinTech'),
                        _buildInterestChip('Product Management'),
                        _buildInterestChip('Startups'),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Mutual Connections
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Mutual Connections', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildMutualAvatar(),
                        Transform.translate(offset: const Offset(-10, 0), child: _buildMutualAvatar()),
                        Transform.translate(offset: const Offset(-20, 0), child: _buildMutualAvatar()),
                        Transform.translate(
                          offset: const Offset(-20, 0),
                          child: const Text(
                            '  2 Mutuals from TechCo', 
                            style: TextStyle(color: AppColors.textSubtleDark, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildInterestChip(String text) {
    return Chip(
      label: Text(text),
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.textSubtle),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildMutualAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      child: const CircleAvatar(
        radius: 15,
        backgroundColor: AppColors.textSubtle,
        child: Icon(Icons.person, size: 15, color: Colors.white),
      ),
    );
  }
}
