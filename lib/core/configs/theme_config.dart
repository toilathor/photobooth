import 'package:flutter/material.dart';

class ThemeConfig {
  static const Color lightPrimary = Color(0xFFCC3333);
  static const Color lightPrimaryContainer = Color(0xFFFDE0E6);
  static const Color lightSecondary = Color(0xFF800000);
  static const Color lightTertiary = Color(0xFF8A2BE2);

  static const Color darkPrimary = Color(0xFFFFB3B3);
  static const Color darkPrimaryContainer = Color(0xFF990000);
  static const Color darkBackground = Color(0xFF1C1B1F);

  static final ThemeData commercialLightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFEA4335), // Google Red
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFCE8E6),
      onPrimaryContainer: Color(0xFFC5221F),
      secondary: Color(0xFF1A73E8), // Google Blue
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF202124), // Google Dark Grey
      error: Color(0xFFB3261E),
      onError: Colors.white,
      tertiary: Color(0xFF34A853), // Google Green
      onTertiary: Colors.white,
      outline: Color(0xFFDADCE0), // Google Light Grey Outline
    ),
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 36,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static final ThemeData commercialDarkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFF28B82), // Google Light Red for Dark Mode
      onPrimary: Color(0xFF3B1715),
      primaryContainer: Color(0xFF5C2B29),
      onPrimaryContainer: Color(0xFFFAD2CF),
      secondary: Color(0xFF8AB4F8), // Google Light Blue for Dark Mode
      onSecondary: Color(0xFF172B4D),
      surface: Color(0xFF202124), // Google Dark Surface
      onSurface: Color(0xFFE8EAED), // Google Light Grey text
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      tertiary: Color(0xFF81C995), // Google Light Green
      onTertiary: Color(0xFF143A2B),
      outline: Color(0xFF5F6368), // Google Grey Outline
    ),
    scaffoldBackgroundColor: const Color(0xFF131314), // Google Dark Background
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 36,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
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
