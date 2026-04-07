import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// MaterialApp uchun asosiy theme
class AppTheme {
  AppTheme._();

  static const Color _darkBackground = Color(0xFF0F172A);
  static const Color _darkSurface = Color(0xFF162033);
  static const Color _darkCard = Color(0xFF1B2940);
  static const Color _darkBorder = Color(0xFF30415F);
  static const Color _darkHint = Color(0xFF94A3B8);

  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    surfaceColor: AppColors.white,
    cardColor: AppColors.cardBackground,
    borderColor: AppColors.border,
    dividerColor: AppColors.divider,
    hintColor: AppColors.textHint,
    appBarBackgroundColor: AppColors.primaryBlue,
    appBarForegroundColor: AppColors.white,
    bottomNavigationBackgroundColor: AppColors.white,
    bottomNavigationUnselectedColor: AppColors.textHint,
    shadowColor: AppColors.shadow,
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkBackground,
    surfaceColor: _darkSurface,
    cardColor: _darkCard,
    borderColor: _darkBorder,
    dividerColor: _darkBorder,
    hintColor: _darkHint,
    appBarBackgroundColor: _darkSurface,
    appBarForegroundColor: Colors.white,
    bottomNavigationBackgroundColor: _darkSurface,
    bottomNavigationUnselectedColor: _darkHint,
    shadowColor: Colors.black45,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
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
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.primaryBlue,
          secondary: AppColors.secondaryBlue,
          error: AppColors.danger,
          surface: surfaceColor,
          outline: borderColor,
          outlineVariant: dividerColor,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      fontFamily: 'Roboto',
      colorScheme: colorScheme,
      cardColor: cardColor,
      shadowColor: shadowColor,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackgroundColor,
        foregroundColor: appBarForegroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: appBarForegroundColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brightness == Brightness.dark
              ? AppColors.white
              : AppColors.primaryBlue,
          side: BorderSide(
            color: brightness == Brightness.dark
                ? colorScheme.outline
                : AppColors.primaryBlue,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: hintColor),
        labelStyle: TextStyle(color: hintColor),
        prefixIconColor: hintColor,
        suffixIconColor: hintColor,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cardColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bottomNavigationBackgroundColor,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: bottomNavigationUnselectedColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.dark ? _darkCard : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
