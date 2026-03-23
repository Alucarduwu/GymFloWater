import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF010204);
  static const Color surface = Color(0xFF0D0D12);
  static const Color surfaceElevated = Color(0xFF1A1A24);
  static const Color accent = Color(0xFF00F2FF); // Neon Cyan
  static const Color accentSecondary = Color(0xFFBC00FF); // Neon Purple
  static const Color accentLight = Color(0xFF70F9FF);
  static const Color accentDark = Color(0xFF00B8C4);
  static const Color success = Color(0xFF00FF9D);
  static const Color danger = Color(0xFFFF2D55);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color border = Color(0xFF21262D);
  static const Color white = Color(0xFFFFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white05 = Color(0x0DFFFFFF);

  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accentSecondary,
          surface: surface,
          onSurface: textPrimary,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          titleTextStyle: GoogleFonts.inter(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Color(0xFF010204), // Dark text on neon button
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: GoogleFonts.inter(
                fontWeight: FontWeight.w900, letterSpacing: 1.0),
            elevation: 8,
            shadowColor: accent.withOpacity(0.5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceElevated,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          labelStyle: const TextStyle(color: textSecondary),
          hintStyle: const TextStyle(color: textSecondary),
        ),
      );
}
