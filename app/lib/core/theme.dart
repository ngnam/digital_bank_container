import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF006943), // Kieng Long Bank green
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF006943),
      secondary: const Color(0xFF00B686),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF006943),
      foregroundColor: Colors.white,
    ),
    // Add more tokens as needed
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF00B686),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF00B686),
      secondary: const Color(0xFF006943),
      surface: const Color(0xFF23262B),
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF23262B),
      foregroundColor: Colors.white,
    ),
    // Add more tokens as needed
  );
}
