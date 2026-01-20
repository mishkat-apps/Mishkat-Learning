import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  
  static const deepEmerald = Color(0xFF0E6B5B);
  static const secondaryNavy = Color(0xFF0B1324);
  static const radiantGold = Color(0xFFC8A24A);
  static const sacredCream = Color(0xFFF4F0E6);
  static const slateGrey = Color(0xFF2D3436); // Keeping for backward compatibility or secondary text if needed
  
  // Mapping old names to new palette to minimize refactoring impact, or updating deprecated names where possible.
  // Better to update values.
  
  // Primary (Deep Emerald)
  // Secondary (Slate Grey) - Note: old was "Midnight Navy" #0B1324. New Slate is #2D3436 (Lighter).
  // Accent (Radiant Gold)
  // Surface (Sacred Cream)
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepEmerald,
        primary: deepEmerald,
        secondary: slateGrey,
        surface: sacredCream,
        onSurface: slateGrey,
        tertiary: radiantGold,
      ),
      scaffoldBackgroundColor: sacredCream,
      textTheme: TextTheme(
        // Primary Headings: Montserrat
        displayLarge: GoogleFonts.montserrat(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: deepEmerald, // Headers often Deep Emerald
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: deepEmerald,
        ),
        // Secondary/Body: Inter
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: slateGrey,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: slateGrey,
        ),
        // Quotes/Arabic: Amiri
        displaySmall: GoogleFonts.amiri(
          fontSize: 20, // Slightly larger for intricate script
          fontStyle: FontStyle.italic,
          color: deepEmerald,
          height: 1.8,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, // Or Deep Emerald if we want filled header? "Header backgrounds... Deep Emerald". But let's keep it transparent for cleaner look on dashboard, or maybe updated later.
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: deepEmerald),
        titleTextStyle: GoogleFonts.montserrat(color: deepEmerald, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepEmerald,
          foregroundColor: Colors.white,
          elevation: 4, // "Slight shine" / shadow
          shadowColor: Color(0x1406402B), // Soft shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14), // 12-16px range
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: deepEmerald,
          side: const BorderSide(color: deepEmerald, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white, // Or slightly off-white if sticking to cream theme? "Lifted feel above the cream background" implies card is likely white.
        elevation: 4,
        shadowColor: Color(0x1406402B), // Soft blurred shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
