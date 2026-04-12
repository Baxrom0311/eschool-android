import 'package:flutter/material.dart';

/// Typography — barcha text stylelar. 
/// DIQQAT: Ranglar bu yerda hardcode qilinmagan, ular Theme'dan olinadi.
class AppTextStyles {
  AppTextStyles._();

  // ─── Constants ───
  static const String fontFamily = 'Inter';

  // ─── Headings ───
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    height: 1.2,
    letterSpacing: -1.0,
    fontFamily: fontFamily,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.3,
    letterSpacing: -0.8,
    fontFamily: fontFamily,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: -0.5,
    fontFamily: fontFamily,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: -0.2,
    fontFamily: fontFamily,
  );

  // ─── Body ───
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.1,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.1,
    fontFamily: fontFamily,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.2,
    fontFamily: fontFamily,
  );

  // ─── Special ───
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 0.2,
    fontFamily: fontFamily,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.1,
    fontFamily: fontFamily,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    fontFamily: fontFamily,
  );
}
