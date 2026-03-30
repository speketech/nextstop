import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/app_colors.dart';
import 'professional_snapshot_screen.dart';

// Dark Corporate Slate background (almost black) per spec
const _darkSlate = Color(0xFF1A252F);
const _messageBubbleOthers = Color(0xFF2C3E50); // Corporate Slate muted grey

class RouteChannelScreen extends StatefulWidget {
  const RouteChannelScreen({super.key});

  @override
  State<RouteChannelScreen> createState() => _RouteChannelScreenState();
}

class _RouteChannelScreenState extends State<RouteChannelScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showMembers = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'Seyi Adebayo',
      'jobTitle': 'Senior SE @ Flutterwave',
      'message': 'Traffic building up around the toll gate. Taking the alternative route.',
      'time': '08:15 AM',
      'isMe': false,
      'avatarUrl': 'https://i.pravatar.cc/150?img=8',
    },
    {
      'sender': 'Ada Okore',
      'jobTitle': 'Brand Strategist @ Zinox',
      'message': 'Thanks for the heads up! See you at the pickup in 5.',
      'time': '08:17 AM',
      'isMe': false,
      'avatarUrl': 'https://i.pravatar.cc/150?img=5',
    },
    {
      'sender': 'You',
      'jobTitle': 'PM @ TechCorp',
      'message': "I'm at Lekki Phase 1 gate now.",
      'time': '08:18 AM',
      'isMe': true,
      'avatarUrl': '',
    },
  ];

  final List<Map<String, String>> _members = [
    {'name': 'Seyi Adebayo', 'title': 'Senior Software Engineer', 'avatar': 'https://i.pravatar.cc/150?img=8'},
    {'name': 'Ada Okore', 'title': 'Brand Strategist', 'avatar': 'https://i.pravatar.cc/150?img=5'},
    {'name': 'Bola Okafor', 'title': 'Venture Capital Analyst', 'avatar': 'https://i.pravatar.cc/150?img=11'},
    {'name': 'You', 'title': 'Product Manager', 'avatar': ''},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'sender': 'You',
        'jobTitle': 'PM @ TechCorp',
        'message': _messageController.text.trim(),
        'time': 'Just now',
        'isMe': true,
        'avatarUrl': '',
      });
      _messageController.clear();
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkSlate,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2D3D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.professionalWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lekki → VI Professionals',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.professionalWhite),
            ),
            Text(
              '${_members.length} members active',
              style: GoogleFonts.roboto(fontSize: 12, color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.group, color: _showMembers ? AppColors.primary : AppColors.professionalWhite),
            onPressed: () => setState(() => _showMembers = !_showMembers),
          ),
        ],
      ),
      body: Row(
        children: [
          // Chat area
          Expanded(
            child: Column(
              children: [
                // Pinned Topic of the Day – Danfo Yellow banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    border: const Border(bottom: BorderSide(color: AppColors.secondary, width: 2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.push_pin, color: AppColors.secondary, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Topic: What\'s the most impactful tech trend in Lagos right now?',
                          style: GoogleFonts.roboto(
                            color: AppColors.professionalWhite,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['isMe'] as bool;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMe) ...[
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfessionalSnapshotScreen())),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: msg['avatarUrl'].toString().isNotEmpty ? NetworkImage(msg['avatarUrl']) : null,
                                  backgroundColor: AppColors.primary,
                                  child: msg['avatarUrl'].toString().isEmpty ? const Icon(Icons.person, size: 16, color: Colors.white) : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isMe ? AppColors.primary : _messageBubbleOthers,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                                    bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe) ...[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            msg['sender'],
                                            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '· ${msg['jobTitle']}',
                                            style: GoogleFonts.roboto(fontSize: 11, color: AppColors.professionalWhite.withOpacity(0.5)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                    Text(
                                      msg['message'],
                                      style: GoogleFonts.roboto(color: AppColors.professionalWhite, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        msg['time'],
                                        style: GoogleFonts.roboto(fontSize: 10, color: AppColors.professionalWhite.withOpacity(0.5)),
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

                // Message Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  color: const Color(0xFF1E2D3D),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: _messageBubbleOthers,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    style: GoogleFonts.roboto(color: AppColors.professionalWhite, fontSize: 15),
                                    decoration: InputDecoration(
                                      hintText: 'Message the channel...',
                                      hintStyle: GoogleFonts.roboto(color: AppColors.professionalWhite.withOpacity(0.4)),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                    onSubmitted: (_) => _sendMessage(),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.attach_file, color: AppColors.primary, size: 20),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primary,
                          child: IconButton(
                            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                            onPressed: _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Side Member Drawer
          if (_showMembers)
            Container(
              width: 200,
              color: const Color(0xFF16212B),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Active Members',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.professionalWhite, fontSize: 14),
                    ),
                  ),
                  const Divider(color: Color(0xFF2C3E50), height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _members.length,
                      itemBuilder: (_, i) {
                        final m = _members[i];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundImage: m['avatar']!.isNotEmpty ? NetworkImage(m['avatar']!) : null,
                            backgroundColor: AppColors.primary,
                            child: m['avatar']!.isEmpty ? const Icon(Icons.person, size: 14, color: Colors.white) : null,
                          ),
                          title: Text(
                            m['name']!,
                            style: GoogleFonts.inter(color: AppColors.professionalWhite, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            m['title']!,
                            style: GoogleFonts.roboto(color: AppColors.professionalWhite.withOpacity(0.5), fontSize: 11),
                          ),
                        );
                      },
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
