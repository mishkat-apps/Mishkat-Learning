import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTheme {
  // Primary brand palette
  static const primaryEmerald = Color(0xFF064e3b);
  static const deepEmerald = Color(0xFF042f2e);
  static const radiantGold = Color(0xFFD4A017);
  static const softGold = Color(0xFFE5C171);
  static const secondaryNavy = Color(0xFF0D5E4D); // From main app theme
  
  // Dashboard specific
  static const sidebarBackground = Color(0xFF064e3b);
  static const sidebarHover = Color(0xFF065f46);
  static const scaffoldBackground = Color(0xFFF4F7F6);
  static const surfaceWhite = Colors.white;
  static const textPrimary = Color(0xFF134E4A);
  static const textSecondary = Color(0xFF64748B);
  
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryEmerald,
        primary: primaryEmerald,
        secondary: radiantGold,
        surface: surfaceWhite,
        error: Colors.redAccent,
      ),
      fontFamily: GoogleFonts.roboto().fontFamily,
      textTheme: TextTheme(
        headlineMedium: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontSize: 24,
        ),
        titleLarge: GoogleFonts.roboto(
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontSize: 18,
        ),
        bodyLarge: GoogleFonts.roboto(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.roboto(
          color: textSecondary,
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        color: surfaceWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: primaryEmerald),
      ),
    );
  }
}
