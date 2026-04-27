// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

/**
 * 🎨 THE STYLE GUIDE:
 * This class holds all the "look and feel" settings for the app.
 * If you want to change the app from Blue to Green, you only change it here!
 */
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Enables the latest Google design standards (Material 3).
      useMaterial3: true,

      // The "Primary" color used for main highlights.
      primarySwatch: Colors.blue,
      primaryColor: const Color(0xFF1976D2), // A specific Dark Blue

      // The background color for all screens.
      scaffoldBackgroundColor: Colors.white,

      // 📱 TOP BAR STYLE:
      // Sets the color and text for the top menu (AppBar) on every page.
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Colors.white, // White text/icons on the blue bar
        elevation: 0, // Flat design (no shadow)
      ),

      // 🔘 BUTTON STYLE:
      // Defines how every "ElevatedButton" in the app should look.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2), // Blue buttons
          foregroundColor: Colors.white,            // White text inside buttons
          minimumSize: const Size(double.infinity, 50), // Makes buttons full-width
          // Rounds the corners slightly (8 pixels).
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}