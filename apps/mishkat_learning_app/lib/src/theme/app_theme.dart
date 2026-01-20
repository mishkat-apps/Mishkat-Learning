import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const deepEmerald = Color(0xFF064e3b); // primary
  static const primaryAccent = Color(0xFF065f46);
  static const backgroundLight = Color(0xFFfcfaf7); // cream/paper
  static const backgroundDark = Color(0xFF0a1a15);
  static const accentEmerald = Color(0xFF14532d);
  static const radiantGold = Color(0xFFa38d5d); // gold-accent
  static const goldLight = Color(0xFFd4c5a3); // gold-light
  static const slateGrey = Color(0xFF2D3436);
  static const surface = Colors.white;

  // Legacy/Restored Colors (to fix breaking changes)
  static const sacredCream = Color(0xFFF4F0E6);
  static const secondaryNavy = Color(0xFF0B1324);
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
        background: backgroundLight,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: TextTheme(
        // Primary Headings: Inter (Design uses Inter for display)
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: deepEmerald,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: deepEmerald,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.playfairDisplay( // Serif for specialized headers
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: deepEmerald,
        ),
        // Headlines
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: deepEmerald,
        ),
        // Body: Inter
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: slateGrey,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: slateGrey,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
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
          textStyle: GoogleFonts.inter(
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
          textStyle: GoogleFonts.inter(
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
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: deepEmerald, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
      ),
    );
  }
}
