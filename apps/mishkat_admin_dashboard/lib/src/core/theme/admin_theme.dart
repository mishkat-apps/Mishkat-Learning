import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTheme {
  // Zinc Palette (Shadcn-like)
  static const Color zinc950 = Color(0xFF09090B);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc50 = Color(0xFFFAFAFA);

  // Semantic Colors
  static const Color primary = zinc900;
  static const Color primaryForeground = Colors.white;
  static const Color secondary = zinc100;
  static const Color secondaryForeground = zinc900;
  static const Color muted = zinc100;
  static const Color mutedForeground = zinc500;
  static const Color accent = zinc100;
  static const Color accentForeground = zinc900;
  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveForeground = Colors.white;
  static const Color border = zinc200;
  static const Color input = zinc200;
  static const Color ring = zinc950;
  
  static const Color background = Colors.white;
  static const Color foreground = zinc950;

  // Legacy mappings for compatibility (will be refactored out)
  static const Color primaryEmerald = zinc900; 
  static const Color secondaryNavy = zinc900;
  static const Color scaffoldBackground = Color(0xFFFBFBFB); // Slight off-white
  static const Color textSecondary = zinc500;
  static const Color surfaceWhite = Colors.white;
  
  // Re-added for main_layout compatibility
  static const Color sidebarBackground = zinc950;
  static const Color radiantGold = Color(0xFFFFD700); // Gold
  static const Color sidebarHover = zinc800;

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: primaryForeground,
        secondary: secondary,
        onSecondary: secondaryForeground,
        surface: background,
        onSurface: foreground,
        error: destructive,
        onError: destructiveForeground,
        outline: border,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: foreground,
        displayColor: foreground,
      ),
      /* cardTheme: CardTheme(
        color: background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ), */
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: input),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: input),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: ring, width: 1.5),
        ),
        labelStyle: const TextStyle(color: zinc500, fontSize: 13),
        hintStyle: const TextStyle(color: zinc400, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: primaryForeground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: zinc900,
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
      iconTheme: const IconThemeData(
        color: zinc900,
        size: 20,
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
