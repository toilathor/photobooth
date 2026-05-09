import 'package:flutter/material.dart';

class ThemeConfig {
  static const Color lightPrimary = Color(0xFFCC3333);
  static const Color lightPrimaryContainer = Color(0xFFFDE0E6);
  static const Color lightSecondary = Color(0xFF800000);
  static const Color lightTertiary = Color(0xFF8A2BE2);

  static const Color darkPrimary = Color(0xFFFFB3B3);
  static const Color darkPrimaryContainer = Color(0xFF990000);
  static const Color darkBackground = Color(0xFF1C1B1F);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimary,
      onPrimary: Colors.white,
      primaryContainer: lightPrimaryContainer,
      onPrimaryContainer: Color(0xFF800000),
      secondary: lightSecondary,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF1F2937),
      error: Color(0xFFB3261E),
      onError: Colors.white,
      tertiary: lightTertiary,
      onTertiary: Colors.white,
      outline: Color(0xFFD1D5DB),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Pacifico',
        fontSize: 36,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  static final ThemeData weddingTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFF5A0001),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF8B0000),
      onPrimaryContainer: Colors.white,
      secondary: const Color(0xFFFFD700),
      onSecondary: const Color(0xFF5A0001),
      surface: const Color(0xFF5A0001),
      onSurface: Colors.white,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      tertiary: const Color(0xFFFFD700),
      onTertiary: const Color(0xFF5A0001),
      outline: const Color(0xFFFFD700).withValues(alpha: 0.5),
    ),
    scaffoldBackgroundColor: const Color(0xFF5A0001),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Pacifico',
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: Color(0xFFD4AF37),
      ),
    ),
  );
}
