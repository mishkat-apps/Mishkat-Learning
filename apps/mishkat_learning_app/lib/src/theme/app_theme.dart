import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const deepEmerald = Color(0xFF064e3b); // primary
  static const primaryAccent = Color(0xFF065f46);
  static const backgroundLight = Color(0xFFfcfaf7); // cream/paper
  static const surface = Color(0xFFFBFBFB);
  static const accentEmerald = Color(0xFF14532d);
  static const radiantGold = Color(0xFFD4A017); // Slightly darker, elegant gold
  static const footerEmerald = Color(0xFF062E26); // Deep charcoal emerald for footer
  static const goldLight = Color(0xFFd4c5a3); // gold-light
  static const slateGrey = Color(0xFF134E4A); // Dark Forest/Teal for Sidebar

  // Legacy/Restored Colors (to fix breaking changes)
  static const sacredCream = Color(0xFFF4F0E6);
  static const secondaryNavy = Color(0xFF0D5E4D); // Vibrant Deep Emerald for Header
  static const softGold = Color(0xFFE5C171);

  // Semantic Aliases
  static const primary = deepEmerald;
  static const secondary = slateGrey;
  static const tertiary = radiantGold;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepEmerald,
        primary: deepEmerald,
        secondary: slateGrey,
        surface: backgroundLight,
        onSurface: slateGrey,
        tertiary: radiantGold,
      ),
      fontFamily: GoogleFonts.geist().fontFamily,
      textTheme: TextTheme(
        // Brand Title Headers (e.g., "MISHKAT LEARNING", "COURSE CATALOG")
        displaySmall: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: radiantGold,
          letterSpacing: 2.0,
        ),
        // Auth/Welcome Titles
        headlineLarge: GoogleFonts.geist(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: deepEmerald,
        ),
        // Section titles (e.g., "About", "Student Reviews")
        titleLarge: GoogleFonts.geist(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: secondaryNavy,
        ),
        // Sub-labels (e.g., "Taught by")
        titleSmall: GoogleFonts.geist(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: secondaryNavy.withValues(alpha: 0.6),
        ),
        // Body: Inter
        bodyLarge: GoogleFonts.geist(
          fontSize: 16,
          color: slateGrey,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.geist(
          fontSize: 14,
          color: slateGrey,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.geist(
          fontSize: 12,
          color: slateGrey.withValues(alpha: 0.7),
        ),
        labelLarge: GoogleFonts.geist(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelSmall: GoogleFonts.geistMono(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: radiantGold,
          letterSpacing: 2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: deepEmerald),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepEmerald,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: GoogleFonts.geist(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: deepEmerald,
          side: const BorderSide(color: deepEmerald, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: GoogleFonts.geist(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: deepEmerald, width: 1.5),
        ),
        hintStyle: GoogleFonts.geist(color: Colors.grey[400], fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
    );
  }
}
