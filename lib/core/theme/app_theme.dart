import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryNavy = Color(0xFF1F3B57);
  static const Color accentGreen = Color(0xFF4F8A3D);
  static const Color backgroundDark = Color(0xFF0F1E2E);
  static const Color cardDark = Color(0xFF162A40);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryNavy,
      primary: primaryNavy,
      secondary: accentGreen,
      surface: Colors.white,
      onSurface: primaryNavy,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: primaryNavy,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primaryNavy,
      onPrimary: Colors.white,
      secondary: accentGreen,
      onSecondary: Colors.white,
      surface: cardDark,
      onSurface: Colors.white,
      background: backgroundDark,
      onBackground: Colors.white70,
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyLarge: const TextStyle(color: Colors.white),
      bodyMedium: const TextStyle(color: Colors.white70),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: backgroundDark,
      foregroundColor: Colors.white,
    ),
  );
}
