// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

/**
 * 🎨 THE STYLE GUIDE: SOTRETRA EDITION
 * Updated to use the signature Green and White palette.
 */
class AppTheme {
  // Primary SOTRETRA Green
  static const Color sotretraGreen = Color(0xFF2E7D32);
  static const Color accentGreen = Color(0xFF4CAF50);

  static ThemeData get lightTheme {
    return ThemeData(
      // Enables the latest Google design standards (Material 3).
      useMaterial3: true,

      // Defining the ColorScheme is the modern way to handle colors in M3
      colorScheme: ColorScheme.fromSeed(
        seedColor: sotretraGreen,
        primary: sotretraGreen,
        secondary: accentGreen,
      ),

      // The background color for all screens.
      scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light grey for contrast

      // 📱 TOP BAR STYLE:
      appBarTheme: const AppBarTheme(
        backgroundColor: sotretraGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      // 🔘 BUTTON STYLE:
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sotretraGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Slightly rounder for a modern UI
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ✏️ INPUT FIELD STYLE (Optional but helpful for forms):
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: sotretraGreen, width: 2),
        ),
      ),
    );
  }
}