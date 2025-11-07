/// App Theme Configuration
/// 
/// Defines light and dark themes for the application.
/// Dark theme uses ChatGPT-style dark grey colors.

import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors
  static const _lightPrimary = Colors.blue;
  static const _lightBackground = Colors.white;
  static const _lightSurface = Color(0xFFF5F5F5);

  // Dark theme colors (Lighter dark grey, not too dark)
  static const _darkBackground = Color(0xFF3A3A3C);      // Main background (lighter)
  static const _darkSurface = Color(0xFF48484A);         // Slightly lighter
  static const _darkCard = Color(0xFF505052);            // Card color
  static const _darkBorder = Color(0xFF636366);          // Subtle borders
  static const _darkTextPrimary = Color(0xFFFFFFFF);     // Main text (white)
  static const _darkTextSecondary = Color(0xFFAEAEB2);   // Muted text

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightPrimary,
        brightness: Brightness.light,
      ),
      
      scaffoldBackgroundColor: _lightBackground,
      
      // App Bar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      
      // Cards
      cardTheme: CardThemeData(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Dark Theme (ChatGPT-style)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightPrimary,
        brightness: Brightness.dark,
        background: _darkBackground,
        surface: _darkSurface,
        surfaceVariant: _darkCard,
      ),
      
      scaffoldBackgroundColor: _darkBackground,
      
      // App Bar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: _darkBackground,
        foregroundColor: _darkTextPrimary,
      ),
      
      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        color: _darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkBorder),
        ),
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Text theme
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: _darkTextPrimary),
        bodyMedium: TextStyle(color: _darkTextPrimary),
        bodySmall: TextStyle(color: _darkTextSecondary),
      ),
    );
  }
}

