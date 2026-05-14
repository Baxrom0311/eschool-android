import 'dart:ui';

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// MaterialApp uchun premium Material 3 theme - "Liquid Glass".
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    primaryColor: AppColors.aqua500,
    scaffoldBackgroundColor: Colors.transparent,
    surfaceColor: AppColors.glassSurfaceLight,
    cardColor: AppColors.glassSurfaceLight,
    borderColor: AppColors.glassBorderLight,
    dividerColor: AppColors.glassBorderLight,
    hintColor: AppColors.slate500,
    shadowColor: AppColors.aqua700.withValues(alpha: 0.18),
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    primaryColor: AppColors.aqua300,
    scaffoldBackgroundColor: Colors.transparent,
    surfaceColor: AppColors.glassSurfaceDark,
    cardColor: AppColors.glassSurfaceDark,
    borderColor: AppColors.glassBorderDark,
    dividerColor: AppColors.glassBorderDark,
    hintColor: AppColors.slate300,
    shadowColor: Colors.black.withValues(alpha: 0.45),
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
    final schemeSurfaceColor = isDark ? AppColors.slate900 : Colors.white;
    final schemeSurfaceContainerHighest = isDark
        ? AppColors.slate800
        : AppColors.slate100;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    ).copyWith(
      primary: primaryColor,
      onPrimary: isDark ? AppColors.slate950 : Colors.white,
      secondary: isDark ? AppColors.violet300 : AppColors.violet600,
      tertiary: isDark ? AppColors.rose300 : AppColors.pink500,
      surface: schemeSurfaceColor,
      onSurface: isDark ? AppColors.slate50 : AppColors.slate900,
      surfaceContainerHighest: schemeSurfaceContainerHighest,
      outline: borderColor,
      error: AppColors.danger,
    );

    final baseTextTheme = isDark
        ? Typography.whiteMountainView
        : Typography.blackMountainView;

    final textTheme = baseTextTheme.copyWith(
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w900,
        color: colorScheme.onSurface,
        letterSpacing: -1.0,
        fontFamily: 'Inter',
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
        letterSpacing: -0.8,
        fontFamily: 'Inter',
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 18,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
        fontFamily: 'Inter',
      ),
      bodyLarge: TextStyle(
        color: isDark ? AppColors.slate100 : AppColors.slate700,
        fontSize: 16,
        height: 1.5,
        fontFamily: 'Inter',
      ),
      bodyMedium: TextStyle(
        color: isDark ? AppColors.slate200 : AppColors.slate600,
        fontSize: 14,
        height: 1.5,
        fontFamily: 'Inter',
      ),
    );

    final glassBorder = BorderSide(
      color: borderColor.withValues(alpha: isDark ? 0.45 : 0.7),
      width: 1.1,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      fontFamily: 'Inter',
      cardColor: cardColor,
      dividerColor: dividerColor,
      hintColor: hintColor,
      shadowColor: shadowColor,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[
        LiquidGlassTheme(
          blurSigma: isDark ? 28 : 22,
          surfaceTint: surfaceColor,
          borderColor: borderColor,
          highlightColor: Colors.white.withValues(alpha: isDark ? 0.10 : 0.76),
          shadowColor: shadowColor,
          glowColor: primaryColor.withValues(alpha: isDark ? 0.24 : 0.18),
        ),
      ],

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: shadowColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: glassBorder,
        ),
        color: cardColor,
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.88),
          foregroundColor: isDark ? AppColors.slate950 : Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          elevation: 0,
          shadowColor: shadowColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.88),
          foregroundColor: isDark ? AppColors.slate950 : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          minimumSize: const Size.fromHeight(52),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: glassBorder,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          minimumSize: const Size.fromHeight(52),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: glassBorder,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: glassBorder,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.85),
            width: 1.6,
          ),
        ),
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: colorScheme.primary.withValues(alpha: 0.18),
        side: glassBorder,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        labelStyle: TextStyle(color: colorScheme.onSurface),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: glassBorder,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? AppColors.slate900.withValues(alpha: 0.9)
            : AppColors.slate900.withValues(alpha: 0.86),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
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

@immutable
class LiquidGlassTheme extends ThemeExtension<LiquidGlassTheme> {
  const LiquidGlassTheme({
    required this.blurSigma,
    required this.surfaceTint,
    required this.borderColor,
    required this.highlightColor,
    required this.shadowColor,
    required this.glowColor,
  });

  final double blurSigma;
  final Color surfaceTint;
  final Color borderColor;
  final Color highlightColor;
  final Color shadowColor;
  final Color glowColor;

  static LiquidGlassTheme of(BuildContext context) {
    return Theme.of(context).extension<LiquidGlassTheme>() ??
        LiquidGlassTheme(
          blurSigma: 22,
          surfaceTint: Theme.of(context).cardColor,
          borderColor: Theme.of(context).colorScheme.outline,
          highlightColor: Colors.white.withValues(alpha: 0.4),
          shadowColor: Theme.of(context).shadowColor,
          glowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
        );
  }

  @override
  LiquidGlassTheme copyWith({
    double? blurSigma,
    Color? surfaceTint,
    Color? borderColor,
    Color? highlightColor,
    Color? shadowColor,
    Color? glowColor,
  }) {
    return LiquidGlassTheme(
      blurSigma: blurSigma ?? this.blurSigma,
      surfaceTint: surfaceTint ?? this.surfaceTint,
      borderColor: borderColor ?? this.borderColor,
      highlightColor: highlightColor ?? this.highlightColor,
      shadowColor: shadowColor ?? this.shadowColor,
      glowColor: glowColor ?? this.glowColor,
    );
  }

  @override
  LiquidGlassTheme lerp(ThemeExtension<LiquidGlassTheme>? other, double t) {
    if (other is! LiquidGlassTheme) return this;
    return LiquidGlassTheme(
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t) ?? blurSigma,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t) ?? surfaceTint,
      borderColor: Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
      highlightColor: Color.lerp(highlightColor, other.highlightColor, t) ?? highlightColor,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t) ?? shadowColor,
      glowColor: Color.lerp(glowColor, other.glowColor, t) ?? glowColor,
    );
  }
}
