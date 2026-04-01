import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color Palette ──
  static const Color primary = Color(0xFF7C4DFF);
  static const Color primaryLight = Color(0xFFB388FF);
  static const Color accent = Color(0xFF00E5FF);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF16213E);
  static const Color card = Color(0xFF0F3460);
  static const Color textPrimary = Color(0xFFE8E8E8);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFCA28);

  // ── Gradients ──
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
  );

  // ── Theme Data ──
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -1,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textSecondary,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceLight,
        indicatorColor: primary.withAlpha(50),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.outfit(fontSize: 12, color: textSecondary),
        ),
      ),
    );
  }
}
