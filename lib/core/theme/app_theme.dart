import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color accent = Color(0xFF00ACC1);
  static const Color accentGreen = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color danger = Color(0xFFC62828);
  static const Color surface = Color(0xFFF5F7FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A237E);
  static const Color textSecondary = Color(0xFF546E7A);
  static const Color textMuted = Color(0xFF90A4AE);
  static const Color borderColor = Color(0xFFE0E7EF);
  static const Color headReachColor = Color(0xFF1565C0);
  static const Color midReachColor = Color(0xFF00897B);
  static const Color tailEndColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  static const Color infoColor = Color(0xFF0288D1);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 14, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 13, color: textSecondary),
        bodySmall: TextStyle(fontSize: 12, color: textMuted),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
    );
  }
}
