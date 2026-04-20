import 'package:flutter/material.dart';

// Modern dark theme with green accents for Korateem app
final ThemeData korateemTheme = ThemeData(
  fontFamily: 'Cairo',
  brightness: Brightness.dark,
  useMaterial3: true,

  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _KorateemPageTransitionsBuilder(),
      TargetPlatform.iOS: _KorateemPageTransitionsBuilder(),
      TargetPlatform.macOS: _KorateemPageTransitionsBuilder(),
      TargetPlatform.windows: _KorateemPageTransitionsBuilder(),
      TargetPlatform.linux: _KorateemPageTransitionsBuilder(),
    },
  ),

  // Color scheme - Modern dark with vibrant green
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF43A047), // Vibrant green
    secondary: Color(0xFF66BB6A), // Light green
    tertiary: Color(0xFF4CAF50), // Standard green
    surface: Color(0xFF1E1E1E), // Deep dark background
    error: Color(0xFFCF6679),
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.white,
  ),

  // Scaffold background - Deep dark
  scaffoldBackgroundColor: Color(0xFF121212),

  // Text theme with Egyptian Arabic styling
  textTheme: TextTheme(
    displayLarge: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: 'Cairo',
      letterSpacing: 0.5,
    ),
    displayMedium: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: 'Cairo',
    ),
    headlineSmall: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: 'Cairo',
    ),
    titleLarge: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontFamily: 'Cairo',
    ),
    titleMedium: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontFamily: 'Cairo',
    ),
    titleSmall: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFFB0B0B0),
      fontFamily: 'Cairo',
    ),
    bodyLarge: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white,
      fontFamily: 'Cairo',
    ),
    bodyMedium: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xFFB0B0B0),
      fontFamily: 'Cairo',
    ),
    bodySmall: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFF808080),
      fontFamily: 'Cairo',
    ),
    labelLarge: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontFamily: 'Cairo',
    ),
  ),

  // AppBar theme - Dark with green accent
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    surfaceTintColor: Color(0xFF1E1E1E),
    elevation: 0,
    iconTheme: IconThemeData(color: Color(0xFF43A047)),
    titleTextStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: 'Cairo',
    ),
    centerTitle: true,
  ),

  // Card theme - Elevated with dark background
  cardTheme: CardThemeData(
    color: Color(0xFF2A2A2A),
    surfaceTintColor: Color(0xFF2A2A2A),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.zero,
  ),

  // Input decoration theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF2A2A2A),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF404040)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF404040)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF43A047), width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFFCF6679)),
    ),
    labelStyle: TextStyle(color: Color(0xFFB0B0B0), fontFamily: 'Cairo'),
    hintStyle: TextStyle(color: Color(0xFF808080), fontFamily: 'Cairo'),
  ),

  // Button themes - Vibrant green
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF43A047),
      foregroundColor: Colors.white,
      minimumSize: Size.fromHeight(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Cairo',
      ),
      elevation: 4,
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Color(0xFF43A047),
      side: BorderSide(color: Color(0xFF43A047), width: 2),
      minimumSize: Size.fromHeight(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Cairo',
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Color(0xFF43A047),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'Cairo',
      ),
    ),
  ),

  // FloatingActionButton theme
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF43A047),
    foregroundColor: Colors.white,
    elevation: 8,
    shape: CircleBorder(),
  ),

  // Bottom navigation bar theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    selectedItemColor: Color(0xFF43A047),
    unselectedItemColor: Color(0xFF808080),
    elevation: 12,
    type: BottomNavigationBarType.fixed,
    showSelectedLabels: true,
    showUnselectedLabels: true,
  ),

  // Chip theme
  chipTheme: ChipThemeData(
    backgroundColor: Color(0xFF2A2A2A),
    selectedColor: Color(0xFF43A047),
    side: BorderSide(color: Color(0xFF404040)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    labelStyle: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
  ),

  // Dialog theme
  dialogTheme: DialogThemeData(
    backgroundColor: Color(0xFF2A2A2A),
    elevation: 12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  // SnackBar theme
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Color(0xFF2A2A2A),
    contentTextStyle: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),

  // Progress indicator theme
  progressIndicatorTheme: ProgressIndicatorThemeData(color: Color(0xFF43A047)),
);

class _KorateemPageTransitionsBuilder extends PageTransitionsBuilder {
  const _KorateemPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.isFirst) return child;

    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    final fade = curved;
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(curved);

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
