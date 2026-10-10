import 'package:flutter/material.dart';
import 'tokens.dart';

class AppTheme {
  // ---- Light Theme ----
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppTokens.lightBackground,
      primaryColor: AppTokens.primaryGreen,
      colorScheme: const ColorScheme.light(
        primary: AppTokens.primaryGreen,
        secondary: AppTokens.accentTeal,
        surface: AppTokens.lightSurface,
        error: AppTokens.expenseRed,
      ),
      fontFamily: 'HindSiliguri', // PRD অনুযায়ী বাংলা ফন্ট
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTokens.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppTokens.lightSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppTokens.textLightPrimary),
        bodyMedium: TextStyle(color: AppTokens.textLightSecondary),
      ),
    );
  }

  // ---- Dark Theme ----
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppTokens.darkBackground,
      primaryColor: AppTokens.accentTeal,
      colorScheme: const ColorScheme.dark(
        primary: AppTokens.accentTeal,
        secondary: AppTokens.primaryGreen,
        surface: AppTokens.darkSurface,
        error: AppTokens.expenseRed,
      ),
      fontFamily: 'HindSiliguri',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTokens.darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppTokens.darkSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppTokens.textDarkPrimary),
        bodyMedium: TextStyle(color: AppTokens.textDarkSecondary),
      ),
    );
  }
}
