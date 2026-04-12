import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// MaterialApp uchun premium Material 3 theme - "Deep Professional Navy"
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    primaryColor: AppColors.skyBlue600,
    scaffoldBackgroundColor: AppColors.skyBlue50,
    surfaceColor: AppColors.white,
    cardColor: AppColors.white,
    borderColor: AppColors.slate200,
    dividerColor: AppColors.slate100,
    hintColor: AppColors.slate400,
    shadowColor: const Color(0x0A0284C7),
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    primaryColor: AppColors.skyBlue400, // Slightly brighter for dark mode pop
    scaffoldBackgroundColor: AppColors.slate900,
    surfaceColor: AppColors.slate800,
    cardColor: AppColors.slate800,
    borderColor: AppColors.slate700,
    dividerColor: AppColors.slate700,
    hintColor: AppColors.slate500,
    shadowColor: Colors.black45,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primaryColor,
    required Color scaffoldBackgroundColor,
    required Color surfaceColor,
    required Color cardColor,
    required Color borderColor,
    required Color dividerColor,
    required Color hintColor,
    required Color shadowColor,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    ).copyWith(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: isDark ? AppColors.skyBlue400 : AppColors.skyBlue600,
      surface: surfaceColor,
      onSurface: isDark ? AppColors.slate50 : AppColors.slate900,
      surfaceContainerHighest: isDark ? AppColors.slate800 : AppColors.slate100,
      outline: borderColor,
      error: AppColors.danger,
    );

    final baseTextTheme = isDark ? Typography.whiteMountainView : Typography.blackMountainView;
    
    final textTheme = baseTextTheme.copyWith(
      headlineLarge: TextStyle(fontWeight: FontWeight.w900, color: colorScheme.onSurface, letterSpacing: -1.0, fontFamily: 'Inter'),
      headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: colorScheme.onSurface, letterSpacing: -0.8, fontFamily: 'Inter'),
      titleLarge: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: colorScheme.onSurface, letterSpacing: -0.5, fontFamily: 'Inter'),
      bodyLarge: TextStyle(color: isDark ? AppColors.slate200 : AppColors.slate700, fontSize: 16, height: 1.5, fontFamily: 'Inter'),
      bodyMedium: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate600, fontSize: 14, height: 1.5, fontFamily: 'Inter'),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      fontFamily: 'Inter',
      cardColor: cardColor,
      shadowColor: shadowColor,
      textTheme: textTheme,
      
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w900),
      ),
      
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: borderColor.withValues(alpha: 0.5), width: 1.0),
        ),
        color: cardColor,
        margin: EdgeInsets.zero,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.2),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.slate800 : AppColors.slate100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: hintColor, fontSize: 14, fontWeight: FontWeight.w500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.slate900 : AppColors.white,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: hintColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
