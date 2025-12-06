import 'package:flutter/material.dart';

const Color lightPrimary = Color(0xFFCC3333);
const Color lightPrimaryContainer = Color(0xFFFDE0E6);
const Color lightSecondary = Color(0xFF800000);
const Color lightTertiary = Color(0xFF8A2BE2);
const Color darkPrimary = Color(0xFFFFB3B3);
const Color darkPrimaryContainer = Color(0xFF990000);
const Color darkBackground = Color(0xFF1C1B1F);

final light = ThemeData(
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
      fontFamily: 'PlayfairDisplay',
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

final dark = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: darkPrimary,
    onPrimary: Color(0xFF660000),
    primaryContainer: darkPrimaryContainer,
    onPrimaryContainer: Color(0xFFFFDADA),
    secondary: Color(0xFFFFDADA),
    onSecondary: Color(0xFF400000),
    background: darkBackground,
    onBackground: Color(0xFFE6E1E5),
    surface: darkBackground,
    onSurface: Color(0xFFE6E1E5),
    error: Color(0xFFFFB4AB),
    onError: Colors.black,
    tertiary: Color(0xFFCFBCFF),
    onTertiary: Color(0xFF3E247D),
    outline: Color(0xFF8E9094),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontFamily: 'PlayfairDisplay',
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
