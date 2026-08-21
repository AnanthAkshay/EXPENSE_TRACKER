import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand & Palette Tokens
  static const Color primaryColor = Color(0xFF6366F1); // Indigo Primary
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondaryColor = Color(0xFF06B6D4); // Cyan Secondary

  // Status & Escalation Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B); // Amber (>= 80%)
  static const Color dangerColor = Color(0xFFEF4444);  // Red (>= 100%)

  // Dark Palette
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Light Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Curated Muted Categorical Palette
  static const List<Color> categoryColors = [
    Color(0xFFFF6B6B),
    Color(0xFF4D96FF),
    Color(0xFF6BCB77),
    Color(0xFFFFD93D),
    Color(0xFF9D4EDD),
    Color(0xFF48CAE4),
    Color(0xFFFF85A1),
    Color(0xFF00B4D8),
    Color(0xFF8D99AE),
  ];

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurface,
        background: darkBackground,
        error: dangerColor,
      ),
      cardColor: darkCard,
      dividerColor: const Color(0xFF334155),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(color: darkTextPrimary, fontWeight: FontWeight.bold, fontSize: 32),
        titleLarge: GoogleFonts.outfit(color: darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 20),
        titleMedium: GoogleFonts.outfit(color: darkTextPrimary, fontWeight: FontWeight.w500, fontSize: 16),
        bodyLarge: GoogleFonts.inter(color: darkTextPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: darkTextSecondary, fontSize: 14),
        bodySmall: GoogleFonts.inter(color: darkTextSecondary, fontSize: 12),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurface,
        background: lightBackground,
        error: dangerColor,
      ),
      cardColor: lightCard,
      dividerColor: const Color(0xFFE2E8F0),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(color: lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 32),
        titleLarge: GoogleFonts.outfit(color: lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 20),
        titleMedium: GoogleFonts.outfit(color: lightTextPrimary, fontWeight: FontWeight.w500, fontSize: 16),
        bodyLarge: GoogleFonts.inter(color: lightTextPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: lightTextSecondary, fontSize: 14),
        bodySmall: GoogleFonts.inter(color: lightTextSecondary, fontSize: 12),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
