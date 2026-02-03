import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Refined for Premium Feel
  static const deepEmerald = Color(0xFF044D3C); // Richer, deeper emerald
  static const primaryAccent = Color(0xFF067D5B); // Slightly more vibrant for interactions
  static const backgroundLight = Color(0xFFFAFAF9); // Warm grey/off-white (Stone-50)
  static const surface = Colors.white;
  
  // Semantic Colors
  static const success = Color(0xFF059669); // Emerald-600
  static const error = Color(0xFFDC2626); // Red-600
  static const warning = Color(0xFFD97706); // Amber-600
  static const info = Color(0xFF0284C7); // Sky-600

  static const radiantGold = Color(0xFFC59D17); // Slightly more grounded gold
  static const goldLight = Color(0xFFE8DCCA); 
  static const slateGrey = Color(0xFF1E293B); // Slate-800 for text
  static const slateLight = Color(0xFF64748B); // Slate-500 for secondary text
  static const footerEmerald = Color(0xFF022C22); // Almost black emerald

  // Legacy/Restored Colors
  static const sacredCream = Color(0xFFF5F5F4);
  static const secondaryNavy = Color(0xFF0F172A); // Slate-900
  static const softGold = Color(0xFFFCD34D); // Amber-300

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
        surface: surface,
        onSurface: slateGrey,
        tertiary: radiantGold,
        error: error,
      ),
      fontFamily: GoogleFonts.geist().fontFamily,
      textTheme: TextTheme(
        // Brand Title Headers (e.g., "MISHKAT LEARNING", "COURSE CATALOG")
        displayLarge: GoogleFonts.montserrat(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: deepEmerald,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: secondaryNavy,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: radiantGold,
          letterSpacing: 1.5,
          height: 1.2,
        ),
        // Auth/Welcome Titles
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: deepEmerald,
          height: 1.2,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: secondaryNavy,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: secondaryNavy,
        ),
        // Section titles (e.g., "About", "Student Reviews")
        titleLarge: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: secondaryNavy,
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: secondaryNavy,
        ),
        // Sub-labels (e.g., "Taught by")
        titleSmall: GoogleFonts.geist(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: slateLight,
          letterSpacing: 0.1,
        ),
        // Body: Geist
        bodyLarge: GoogleFonts.geist(
          fontSize: 16,
          color: slateGrey,
          height: 1.6, // Better readability
        ),
        bodyMedium: GoogleFonts.geist(
          fontSize: 14,
          color: slateGrey,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.geist(
          fontSize: 12,
          color: slateLight,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.geist(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.geistMono(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: radiantGold,
          letterSpacing: 1.2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: deepEmerald),
        scrolledUnderElevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepEmerald,
          foregroundColor: Colors.white,
          elevation: 2, // Slight lift
          shadowColor: deepEmerald.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(0, 56), // Standardized height
          textStyle: GoogleFonts.geist(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
          animationDuration: const Duration(milliseconds: 200),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: deepEmerald,
          side: const BorderSide(color: deepEmerald, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(0, 56),
          textStyle: GoogleFonts.geist(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: deepEmerald, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        hintStyle: GoogleFonts.geist(color: Colors.grey[400], fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.08)),
        ),
      ),
      iconTheme: const IconThemeData(
        color: slateGrey,
        size: 24,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.withValues(alpha: 0.1),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
