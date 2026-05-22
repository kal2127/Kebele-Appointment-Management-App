import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color accentGold = Color(0xFFF9A825);
  static const Color softBackground = Color(0xFFF6F7F1);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: accentGold,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: softBackground,
      fontFamilyFallback: const [
        'Noto Sans Ethiopic',
        'Noto Sans Ethiopic UI',
        'Noto Sans',
        'Roboto',
      ],
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: softBackground,
        foregroundColor: Color(0xFF1B1B1B),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
