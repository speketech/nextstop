import 'package:flutter/material.dart';

class AppColors {
  // Primary: "Lagos Electric Blue" - Professionalism and trust.
  static const Color primary = Color(0xFF007BFF); 
  
  // Secondary: "Ride Yellow" - Highlights, available seats, local touch.
  static const Color secondary = Color(0xFFFFD700); 

  // Corporate Slate - Deep rich charcoal/navy for backgrounds/text
  static const Color corporateSlate = Color(0xFF2C3E50); 
  
  // Professional White - Clean crisp white
  static const Color professionalWhite = Color(0xFFFFFFFF); 

  // Subtle Grey - Light neutral grey for dividers
  static const Color subtleGrey = Color(0xFFECF0F1); 
  
  // Accent: "Trust Green" - Success states, verified badges.
  static const Color accent = Color(0xFF2E8B57); 
  
  // Danger: "Alert Red" - Errors, emergencies.
  static const Color danger = Color(0xFFDC3545); 

  // Neutral Palette mapping
  static const Color background = professionalWhite;
  static const Color surface = professionalWhite;
  static const Color textBody = corporateSlate;
  
  // Using a less bright grey for text, to ensure readability, while using subtleGrey for dividers
  static const Color textSubtleDark = Color(0xFF7F8C8D); 
  static const Color textSubtle = subtleGrey; 
  
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF007BFF), Color(0xFF0056B3)], // Deeper blue gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
