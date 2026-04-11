import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// MaterialApp uchun asosiy theme - Deep Professional Navy
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
    appBarBackgroundColor: AppColors.white,
    appBarForegroundColor: AppColors.slate900,
    bottomNavigationBackgroundColor: AppColors.white,
    bottomNavigationUnselectedColor: AppColors.slate400,
    shadowColor: const Color(0x0A0284C7), // Subtle Sky Blue shadow
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryBlue,
    scaffoldBackgroundColor: AppColors.slate900,
    surfaceColor: AppColors.slate800,
    cardColor: AppColors.slate800,
    borderColor: AppColors.slate700,
    dividerColor: AppColors.slate700,
    hintColor: AppColors.slate500,
    appBarBackgroundColor: AppColors.slate900,
    appBarForegroundColor: AppColors.white,
    bottomNavigationBackgroundColor: AppColors.slate800,
    bottomNavigationUnselectedColor: AppColors.slate500,
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
    required Color appBarBackgroundColor,
    required Color appBarForegroundColor,
    required Color bottomNavigationBackgroundColor,
    required Color bottomNavigationUnselectedColor,
    required Color shadowColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    ).copyWith(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: brightness == Brightness.light ? AppColors.skyBlue400 : AppColors.lightBlue,
      onSecondary: Colors.white,
      error: AppColors.danger,
      surface: surfaceColor,
      onSurface: brightness == Brightness.light ? AppColors.slate900 : AppColors.slate50,
      outline: borderColor,
      outlineVariant: dividerColor,
    );

    final textTheme = (brightness == Brightness.light
        ? Typography.blackMountainView
        : Typography.whiteMountainView).copyWith(
      headlineLarge: TextStyle(fontWeight: FontWeight.w900, color: brightness == Brightness.light ? AppColors.slate900 : AppColors.slate50, letterSpacing: -1.0),
      headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: brightness == Brightness.light ? AppColors.slate900 : AppColors.slate50, letterSpacing: -0.5),
      titleLarge: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: brightness == Brightness.light ? AppColors.slate900 : AppColors.slate50, letterSpacing: -0.2),
      bodyLarge: TextStyle(color: brightness == Brightness.light ? AppColors.slate700 : AppColors.slate200, fontSize: 16),
      bodyMedium: TextStyle(color: brightness == Brightness.light ? AppColors.slate600 : AppColors.slate400, fontSize: 14),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      cardColor: cardColor,
      shadowColor: shadowColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackgroundColor,
        foregroundColor: appBarForegroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: appBarForegroundColor,
          letterSpacing: -0.8,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32), // Increased to 32px for premium feel
          side: BorderSide(color: borderColor, width: 0.5), // Thinner, more professional border
        ),
        color: cardColor,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.2),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bottomNavigationBackgroundColor,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: bottomNavigationUnselectedColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light ? AppColors.slate100 : AppColors.slate800,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
        hintStyle: TextStyle(color: hintColor, fontSize: 14, fontWeight: FontWeight.w500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}
