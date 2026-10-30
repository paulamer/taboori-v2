import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand HSL Colors represented as hex
  static const Color primaryTealLight = Color(0xFF0D7A68); // Taboori Deep Teal
  static const Color secondaryEmeraldLight = Color(0xFF10B981); // Emerald 500
  static const Color mintAccent = Color(0xFF5EEAD4); // Mint button accent
  static const Color darkGreenBg = Color(0xFF0B201D); // Dark Forest Alert background
  static const Color emergencyRed = Color(0xFFDC2626); // Emergency Ambulance 123
  static const Color accentAmberLight = Color(0xFFD97706); // Amber 600
  static const Color bgLight = Color(0xFFF8F9FA); // Clean off-white background
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0F172A); // Slate 900
  static const Color textMutedDark = Color(0xFF64748B); // Slate 500
  static const Color cardBorder = Color(0xFFE2E8F0); // Subtle card border

  static const Color primaryTealDark = Color(0xFF14B8A6); // Teal 500
  static const Color secondaryEmeraldDark = Color(0xFF34D399); // Emerald 400
  static const Color accentAmberDark = Color(0xFFFBBF24); // Amber 400
  static const Color bgDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color textLight = Color(0xFFF8FAFC); // Slate 50
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate 400

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryTealLight,
        secondary: secondaryEmeraldLight,
        tertiary: accentAmberLight,
        surface: surfaceLight,
        error: Color(0xFFEF4444),
      ),
      scaffoldBackgroundColor: bgLight,
      cardTheme: const CardThemeData(
        color: surfaceLight,
        elevation: 0,
      ),
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.bold, color: textDark),
        displayMedium: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.bold, color: textDark),
        titleLarge: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
        titleMedium: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: textDark),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: textMutedDark),
        labelLarge: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTealLight,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTealLight, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryTealDark,
        secondary: secondaryEmeraldDark,
        tertiary: accentAmberDark,
        surface: surfaceDark,
        error: Color(0xFFF87171),
      ),
      scaffoldBackgroundColor: bgDark,
      cardTheme: const CardThemeData(
        color: surfaceDark,
        elevation: 0,
      ),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.bold, color: textLight),
        displayMedium: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.bold, color: textLight),
        titleLarge: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: textLight),
        titleMedium: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, color: textLight),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: textLight),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: textMutedLight),
        labelLarge: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: bgDark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textLight),
        titleTextStyle: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTealDark,
          foregroundColor: bgDark,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTealDark, width: 2),
        ),
      ),
    );
  }
}
