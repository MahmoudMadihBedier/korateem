import 'package:flutter/material.dart';

// Enhance theme for modern Arabic UI and performance
final ThemeData korateemTheme = ThemeData(
  fontFamily: 'Cairo',
  brightness: Brightness.light,
  primaryColor: Color(0xFF1E88E5),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF1E88E5),
    primary: Color(0xFF1E88E5),
    secondary: Color(0xFF43A047),
  ),
  scaffoldBackgroundColor: Color(0xFFF5F5F5),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontFamily: 'Cairo',
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      color: Colors.black,
      fontFamily: 'Cairo',
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontFamily: 'Cairo',
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontFamily: 'Cairo',
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1E88E5),
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: 'Cairo',
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(),
    filled: true,
    fillColor: Colors.white,
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
