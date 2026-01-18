import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0x0E6B5B); // Hex: #0E6B5B
  static const secondaryColor = Color(0x0B1324); // Hex: #0B1324
  static const accentColor = Color(0xC8A24A); // Hex: #C8A24A
  static const surfaceColor = Color(0xF4F0E6); // Hex: #F4F0E6
  static const textColor = Color(0x111827); // Hex: #111827

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: surfaceColor,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          color: secondaryColor,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          color: secondaryColor,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
